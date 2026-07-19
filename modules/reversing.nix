{ pkgs, lib, ... }:

let
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

  pycparser = pkgs.python312Packages.pycparser.overridePythonAttrs (_: rec {
    version = "2.22";
    src = pkgs.fetchPypi {
      pname = "pycparser";
      inherit version;
      hash = "sha256-SRyL6cBA9TkPW/RKWwd1K9B/Vu35kjgbBccBQ57sEPY=";
    };
  });

  angr = pkgs.python312Packages.angr.overridePythonAttrs (old: rec {
    version = "9.2.154";
    src = pkgs.fetchPypi {
      pname = "angr";
      inherit version;
      hash = "sha256-jqOpUeZTxbrIG9C2nLVVn2Rl9U2Ci3H/Vd7ZIQfWD+4=";
    };
    build-system = (old.build-system or [ ]) ++ [
      pkgs.python312Packages.pyvex
      pkgs.python312Packages.wheel
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

  unblob = (pkgs.unblob.override { python3 = pkgs.python312; }).overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [
      "test_all_handlers[filesystem.btrfs_stream]"
    ];
  });

  ghidraMcpSrc = pkgs.fetchFromGitHub {
    owner = "LaurieWired";
    repo = "GhidraMCP";
    rev = "27f316f80139e2d5dec882519a1bdf4aa46ac04c";
    hash = "sha256-9NzmYQqfvQm5wjmmPWOG1+g9zCzGrUrRZX+m1nRS0m4=";
  };

  ghidraMcpExtension = pkgs.stdenvNoCC.mkDerivation {
    pname = "ghidra-mcp-extension";
    version = "1.4";
    src = ghidraMcpSrc;
    nativeBuildInputs = [ pkgs.jdk21 ];

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
      hatchling
      uv-dynamic-versioning
    ];
    dependencies = [
      pkgs.python312Packages.anyio
      pkgs.python312Packages.httpx
      httpxSse
      pkgs.python312Packages.pydantic
      pkgs.python312Packages.pydantic-settings
      sseStarlette
      pkgs.python312Packages.starlette
      pkgs.python312Packages.uvicorn
    ];
    pythonImportsCheck = [ "mcp.server.fastmcp" ];
    doCheck = false;
  };
  ghidraMcpPython = pkgs.python312.withPackages (_: [
    mcp
    pkgs.python312Packages.requests
  ]);
  ghidraMcpBridge = pkgs.writeShellScriptBin "ghidra-mcp" ''
    exec ${ghidraMcpPython}/bin/python ${ghidraMcpSrc}/bridge_mcp_ghidra.py "$@"
  '';
in
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "binaryninja-free"
      "ida-home-pc"
      "volatility3"
    ];

  environment.systemPackages = with pkgs; [
    # Binary inspection and modification
    binutils
    elfutils
    patchelf
    pax-utils
    checksec
    upx
    detect-it-easy
    lief
    python312Packages.pefile
    python312Packages.pyelftools
    python312Packages.macholib

    # Disassemblers and decompilers
    ghidraWithMcp
    ghidraMcpBridge
    binaryninja-free
    radare2
    rizin
    cutter
    iaito
    edb

    # Debugging and runtime analysis
    gdb
    gef
    lldb
    rr
    strace
    ltrace
    valgrind
    frida-tools

    # Hex editors
    imhex
    okteta

    # Exploit development and symbolic execution
    pwntools
    ropgadget
    pwninit
    angr
    retdec-bin
    z3
    capstone
    keystone
    unicorn

    # Android
    android-tools
    apktool
    jadx
    dex2jar

    # Emulation and Windows targets
    qemu
    wineWow64Packages.stable
    dosbox

    # Firmware and embedded targets
    binwalk
    # unblob
    uefitool
    uefi-firmware-parser

    # Malware analysis and forensics
    yara
    yara-x
    capa
    flare-floss
    volatility3
    sleuthkit
    foremost
    exiftool

    # Managed code, Python bytecode, Go, and network/protocol analysis
    ilspycmd
    python312Packages.uncompyle6
    goresym
    zeek
    mitmproxy
  ];

  programs.wireshark.enable = true;
  users.users.sweet_cicero.extraGroups = [ "wireshark" ];
}
