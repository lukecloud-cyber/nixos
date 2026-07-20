{ pkgs, lib, ... }:

let
  # Package RetDec's upstream binary release because nixpkgs does not provide it.
  retdec-bin = pkgs.stdenv.mkDerivation {
    pname = "retdec-bin";
    version = "5.0";

    src = pkgs.fetchurl {
      url = "https://github.com/avast/retdec/releases/download/v5.0/RetDec-v5.0-Linux-Release.tar.xz";
      hash = "sha256-5afdgph/9SuMcUiSJ30LHQGQq3eMAwNtAetpx2WKsaU=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook # Rewrite bundled ELF binaries to use Nix store libraries.
    ];
    buildInputs = with pkgs; [
      libffi # Foreign-function interface runtime required by bundled tools.
      libxml2 # XML parser used by RetDec components.
      ncurses # Terminal interface runtime.
      openssl # TLS and cryptographic runtime.
      stdenv.cc.cc.lib # GCC C++ runtime library.
      zlib # DEFLATE compression runtime.
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

  # Pin pycparser to the version compatible with the overridden angr release.
  pycparser = pkgs.python312Packages.pycparser.overridePythonAttrs (_: rec {
    version = "2.22";
    src = pkgs.fetchPypi {
      pname = "pycparser";
      inherit version;
      hash = "sha256-SRyL6cBA9TkPW/RKWwd1K9B/Vu35kjgbBccBQ57sEPY=";
    };
  });

  # Pin angr and relax dependency metadata that is stricter than its runtime needs.
  angr = pkgs.python312Packages.angr.overridePythonAttrs (old: rec {
    version = "9.2.154";
    src = pkgs.fetchPypi {
      pname = "angr";
      inherit version;
      hash = "sha256-jqOpUeZTxbrIG9C2nLVVn2Rl9U2Ci3H/Vd7ZIQfWD+4=";
    };
    build-system = (old.build-system or [ ]) ++ [
      pkgs.python312Packages.pyvex # Python bindings for angr's VEX IR engine.
      pkgs.python312Packages.wheel # Python wheel build support.
    ];
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
      "ailment"
      "claripy"
    ];
    dependencies =
      builtins.filter (dep: (dep.pname or "") != "pycparser") (old.dependencies or [ ])
      ++ [ pycparser ];
    catchConflicts = false;
    pythonImportsCheck = [ ];
    makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
      "--prefix"
      "PYTHONPATH"
      ":"
      "${pycparser}/lib/python3.12/site-packages"
    ];
  });

  # Keep a Python 3.12 unblob variant ready; installation remains disabled below.
  unblob = (pkgs.unblob.override { python3 = pkgs.python312; }).overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [
      "test_all_handlers[filesystem.btrfs_stream]"
    ];
  });

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

  # Avoid broken test-only dependency chains in current nixpkgs.
  sseStarlette = pkgs.python312Packages.sse-starlette.overridePythonAttrs (old: {
    doCheck = false;
    nativeCheckInputs = [ ];
    dependencies = (old.dependencies or [ ]) ++ [ pkgs.python312Packages.starlette ];
  });
  httpxSse = pkgs.python312Packages.httpx-sse.overridePythonAttrs (_: {
    doCheck = false;
    nativeCheckInputs = [ ];
  });
  # Build the MCP Python library version expected by the pinned Ghidra bridge.
  mcp = pkgs.python312Packages.buildPythonPackage {
    pname = "mcp";
    version = "1.5.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "mcp";
      version = "1.5.0";
      hash = "sha256-WydmwF5o4BogNIdeJQE5g5SYxheSFjp7Ih/BcMEvWqk=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'dynamic = ["version"]' 'version = "1.5.0"'
    '';
    build-system = with pkgs.python312Packages; [
      hatchling # PEP 517 build backend used by MCP.
      uv-dynamic-versioning # Hatch plugin that normally derives MCP's version.
    ];
    dependencies = [
      pkgs.python312Packages.anyio # Async concurrency abstraction.
      pkgs.python312Packages.httpx # Async-capable HTTP client.
      httpxSse # Server-sent-events support for HTTPX.
      pkgs.python312Packages.pydantic # Typed validation for protocol models.
      pkgs.python312Packages.pydantic-settings # Environment-backed settings models.
      sseStarlette # Server-sent-events responses for Starlette.
      pkgs.python312Packages.starlette # ASGI web framework used by MCP servers.
      pkgs.python312Packages.uvicorn # ASGI server for HTTP transports.
    ];
    pythonImportsCheck = [ "mcp.server.fastmcp" ];
    doCheck = false;
  };
  # Create a closed Python environment for the Ghidra MCP bridge.
  ghidraMcpPython = pkgs.python312.withPackages (_: [
    mcp # Model Context Protocol server library built above.
    pkgs.python312Packages.requests # HTTP client used to reach Ghidra.
  ]);
  # Expose the bridge as a normal command with its Python environment fixed.
  ghidraMcpBridge = pkgs.writeShellScriptBin "ghidra-mcp" ''
    exec ${ghidraMcpPython}/bin/python ${ghidraMcpSrc}/bridge_mcp_ghidra.py "$@"
  '';
in
{
  # Permit only the proprietary packages used by this toolkit.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "binaryninja-free"
      "ida-home-pc"
      "volatility3"
    ];

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
    binaryninja-free # Free edition of the Binary Ninja reverse-engineering platform.
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
    retdec-bin # Retargetable machine-code decompiler packaged above.
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
    qemu # Full-system and user-mode machine emulator.
    wineWow64Packages.stable # Run 32-bit and 64-bit Windows applications.
    dosbox # Emulate DOS-era x86 hardware and software.

    # Firmware and embedded targets
    binwalk # Identify and extract embedded files from firmware images.
    # unblob # Modern firmware extractor; disabled due to its broken test chain.
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
    python312Packages.uncompyle6 # Decompile Python bytecode to source.
    goresym # Recover symbols and metadata from stripped Go binaries.
    zeek # Analyze network traffic and emit structured security logs.
    mitmproxy # Interactive TLS-capable HTTP proxy for traffic inspection.
  ];

  # Install Wireshark with packet-capture integration.
  programs.wireshark.enable = true;
  # Permit the primary user to capture packets without running the GUI as root.
  users.users.sweet_cicero.extraGroups = [ "wireshark" ];
}
