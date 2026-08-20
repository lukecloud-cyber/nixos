{ pkgs, lib, ... }:

let
  # Package RetDec's binary release because the stock source fails with CMake 4.
  retdec-bin = pkgs.stdenv.mkDerivation {
    pname = "retdec-bin";
    version = "5.0";

    src = pkgs.fetchurl {
      url = "https://github.com/avast/retdec/releases/download/v5.0/RetDec-v5.0-Linux-Release.tar.xz";
      hash = "sha256-5afdgph/9SuMcUiSJ30LHQGQq3eMAwNtAetpx2WKsaU=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = with pkgs; [
      libffi
      libxml2
      ncurses
      openssl
      stdenv.cc.cc.lib
      zlib
    ];

    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -a . "$out"
      runHook postInstall
    '';

    meta = {
      description = "Retargetable machine-code decompiler";
      homepage = "https://retdec.com";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "retdec-decompiler";
    };
  };

  # Use the Pycparser release that matches the pinned Angr API.
  pycparser = pkgs.python312Packages.pycparser.overridePythonAttrs (_: rec {
    version = "2.22";
    src = pkgs.fetchPypi {
      pname = "pycparser";
      inherit version;
      hash = "sha256-SRyL6cBA9TkPW/RKWwd1K9B/Vu35kjgbBccBQ57sEPY=";
    };
  });

  # Use the newest Angr release that matches the nixpkgs dependency set.
  angr = pkgs.python312Packages.angr.overridePythonAttrs (old: rec {
    version = "9.2.154";
    src = pkgs.fetchPypi {
      pname = "angr";
      inherit version;
      hash = "sha256-jqOpUeZTxbrIG9C2nLVVn2Rl9U2Ci3H/Vd7ZIQfWD+4=";
    };
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
      "ailment"
      "claripy"
    ];
    dependencies =
      builtins.filter (dependency: (dependency.pname or "") != "pycparser") (old.dependencies or [ ])
      ++ [ pycparser ];
    catchConflicts = false;
    pythonImportsCheck = [ ];
    makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
      "--prefix"
      "PYTHONPATH"
      ":"
      "${pycparser}/${pkgs.python312.sitePackages}"
    ];
  });

  # Add Python 3.12.14 to Xdis's supported patch releases.
  uncompyle6 = pkgs.python312Packages.uncompyle6.override {
    xdis = pkgs.python312Packages.xdis.overridePythonAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace xdis/magics.py \
          --replace-fail \
          '"3.12.11 3.12.12 3.12.13",' \
          '"3.12.11 3.12.12 3.12.13 3.12.14",'
      '';
    });
  };

  # Pin the shared GhidraMCP source used by both the extension and Python bridge.
  ghidraMcpSrc = pkgs.fetchFromGitHub {
    owner = "LaurieWired";
    repo = "GhidraMCP";
    rev = "27f316f80139e2d5dec882519a1bdf4aa46ac04c";
    hash = "sha256-9NzmYQqfvQm5wjmmPWOG1+g9zCzGrUrRZX+m1nRS0m4=";
  };

  # Compile the Java extension and restrict its MCP listener to localhost.
  ghidraMcpExtension = pkgs.stdenvNoCC.mkDerivation {
    pname = "ghidra-mcp-extension";
    version = "1.4";
    src = ghidraMcpSrc;
    nativeBuildInputs = [
      pkgs.jdk21 # Java compiler and JAR tooling compatible with Ghidra.
    ];

    postPatch = ''
      substituteInPlace src/main/java/com/lauriewired/GhidraMCPPlugin.java \
        --replace-fail 'new InetSocketAddress(port)' 'new InetSocketAddress("127.0.0.1", port)'
    '';

    buildPhase =
      let
        jarDir = "${pkgs.ghidra}/lib/ghidra/Ghidra";
        classpath = lib.concatStringsSep ":" [
          "${jarDir}/Features/Base/lib/Base.jar"
          "${jarDir}/Features/Decompiler/lib/Decompiler.jar"
          "${jarDir}/Framework/Docking/lib/Docking.jar"
          "${jarDir}/Framework/Generic/lib/Generic.jar"
          "${jarDir}/Framework/Gui/lib/Gui.jar"
          "${jarDir}/Framework/Project/lib/Project.jar"
          "${jarDir}/Framework/SoftwareModeling/lib/SoftwareModeling.jar"
          "${jarDir}/Framework/Utility/lib/Utility.jar"
        ];
      in
      ''
        runHook preBuild
        mkdir classes
        javac -cp '${classpath}' -d classes src/main/java/com/lauriewired/GhidraMCPPlugin.java
        jar --create --file GhidraMCP.jar --manifest src/main/resources/META-INF/MANIFEST.MF -C classes .
        runHook postBuild
      '';

    installPhase = ''
      runHook preInstall
      extension=$out/lib/ghidra/Ghidra/Extensions/GhidraMCP
      install -Dm644 GhidraMCP.jar "$extension/lib/GhidraMCP.jar"
      install -Dm644 src/main/resources/Module.manifest "$extension/Module.manifest"
      install -Dm644 src/main/resources/extension.properties "$extension/extension.properties"
      substituteInPlace "$extension/extension.properties" \
        --replace-fail 'version=11.3.2' 'version=${pkgs.ghidra.version}' \
        --replace-fail 'ghidraVersion=11.3.2' 'ghidraVersion=${pkgs.ghidra.version}'
      touch "$extension/.dbDirLock"
      runHook postInstall
    '';
  };

  # Install Ghidra with the locally built MCP extension included.
  ghidraWithMcp = pkgs.ghidra.withExtensions (_: [ ghidraMcpExtension ]);

  # Create a closed Python environment for the Ghidra MCP bridge.
  ghidraMcpPython =
    (pkgs.python312.override {
      packageOverrides = final: previous: {
        "sse-starlette" = previous."sse-starlette".overridePythonAttrs (old: {
          dependencies = (old.dependencies or [ ]) ++ [ final.starlette ];
          doCheck = false;
        });
      };
    }).withPackages
      (ps: [
        (ps.mcp.overridePythonAttrs (_: {
          doCheck = false;
        })) # Model Context Protocol server library.
        ps.requests # HTTP client used to reach Ghidra.
      ]);
  # Expose the bridge as a normal command with its Python environment fixed.
  ghidraMcpBridge = pkgs.writeShellScriptBin "ghidra-mcp" ''
    exec ${ghidraMcpPython}/bin/python ${ghidraMcpSrc}/bridge_mcp_ghidra.py "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    # Binary inspection and modification
    binutils # GNU assemblers, linkers, and binary inspection tools.
    elfutils # ELF and DWARF inspection utilities and libraries.
    patchelf # Edit ELF interpreters and runtime search paths.
    pax-utils # Inspect ELF dependencies, symbols, and hardening properties.
    checksec # Report binary and process exploit mitigations.
    upx # Compress and decompress executable files.
    detect-it-easy # Identify executable formats, packers, and compilers.
    lief # Parse and modify ELF, PE, and Mach-O binaries.
    python312Packages.pefile # Parse and inspect Windows PE files from Python.
    python312Packages.pyelftools # Parse ELF and DWARF data from Python.
    python312Packages.macholib # Analyze Mach-O binaries and dependencies from Python.

    # Disassemblers and decompilers
    ghidraWithMcp # Ghidra software reverse-engineering suite with MCP extension.
    ghidraMcpBridge # MCP server that relays analysis requests to Ghidra.
    radare2 # Command-line reverse-engineering framework.
    rizin # Fork of radare2 with analysis and patching tools.
    cutter # Qt graphical interface for Rizin.
    iaito # Qt graphical interface for radare2.
    edb # Graphical debugger modeled after OllyDbg.

    # Debugging and runtime analysis
    gdb # GNU source-level and machine-level debugger.
    gef # Enhanced commands and views for exploit development in GDB.
    lldb # LLVM debugger for native programs.
    rr # Record and deterministically replay Linux program execution.
    strace # Trace system calls and signals.
    ltrace # Trace dynamic library calls.
    valgrind # Detect memory errors and profile native programs.
    frida-tools # Dynamic instrumentation command-line tools.

    # Hex editors
    imhex # Pattern-aware graphical hex editor for reverse engineering.
    okteta # KDE graphical hexadecimal editor.

    # Exploit development and symbolic execution
    pwntools # Python framework for exploit development and CTF challenges.
    ropgadget # Find return-oriented programming gadgets in binaries.
    pwninit # Prepare challenge binaries with matching loaders and libraries.
    angr # Python binary-analysis and symbolic-execution framework.
    retdec-bin # Retargetable machine-code decompiler.
    z3 # SMT solver used for symbolic constraints.
    capstone # Multi-architecture disassembly engine.
    keystone # Multi-architecture assembler engine.
    unicorn # Multi-architecture CPU emulation engine.

    # Android
    android-tools # ADB, fastboot, and Android device utilities.
    apktool # Decode and rebuild Android APK resources and bytecode.
    jadx # Decompile Android DEX/APK files to Java-like source.
    dex2jar # Convert Android DEX bytecode to Java class/JAR files.

    # Emulation and Windows targets
    wineWow64Packages.stable # Run 32-bit and 64-bit Windows applications.
    dosbox # Emulate DOS-era x86 hardware and software.

    # Firmware and embedded targets
    binwalk # Identify and extract embedded files from firmware images.
    uefitool # Inspect and edit UEFI firmware images.
    uefi-firmware-parser # Parse UEFI firmware structures from Python.

    # Malware analysis and forensics
    yara # Match files and memory against malware-analysis rules.
    yara-x # Rust-based next-generation YARA scanning engine.
    capa # Infer executable capabilities from code patterns.
    flare-floss # Extract obfuscated strings from malware binaries.
    volatility3 # Analyze memory images for digital forensics.
    sleuthkit # Inspect filesystems and disk images for forensic evidence.
    foremost # Recover files by carving known headers and footers.
    exiftool # Read and edit metadata across many file formats.

    # Managed code, Python bytecode, Go, and network/protocol analysis
    ilspycmd # Command-line decompiler for .NET assemblies.
    uncompyle6 # Decompile Python bytecode to source.
    goresym # Recover symbols and metadata from stripped Go binaries.
    zeek # Analyze network traffic and emit structured security logs.
    mitmproxy # Interactive TLS-capable HTTP proxy for traffic inspection.
  ];

  # Install Wireshark with packet-capture integration.
  programs.wireshark.enable = true;
  # Permit the primary user to capture packets without running the GUI as root.
  users.users.sweet_cicero.extraGroups = [ "wireshark" ];
}
