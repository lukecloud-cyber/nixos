{ pkgs, lib, ... }:

let
  # Build the Python environment required by the Binary Ninja Sidekick plugin.
  sidekickPython = pkgs.python312.withPackages (
    ps:
    let
      pysqlite3 = ps.buildPythonPackage rec {
        pname = "pysqlite3";
        version = "0.6.0";
        pyproject = true;

        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-7PURK2Kk5sBEOJV+ND/pZycHvTGR94nsrmyVsiaqa7Y=";
        };

        build-system = [ ps.setuptools ]; # Build the package with setuptools.
        buildInputs = [ pkgs.sqlite ]; # Link against SQLite during the build.
        pythonImportsCheck = [ "pysqlite3" ];
      };
      # Pin Tenacity to the version required by Sidekick.
      tenacity = ps.tenacity.overridePythonAttrs (_: rec {
        version = "8.5.0";
        src = pkgs.fetchPypi {
          pname = "tenacity";
          inherit version;
          hash = "sha256-i8bAyKCbMebK0TxHr77RpWdRglCpoXFBhYLtjZwgyng=";
        };
      });
      # Add NumPy to the SQLite vector extension runtime dependencies.
      sqlite-vec = ps."sqlite-vec".overridePythonAttrs (old: {
        dependencies = (old.dependencies or [ ]) ++ [ ps.numpy ];
        # ponytail: nixpkgs' check pulls OpenAI only for tests; drop this override when it no longer does.
        doInstallCheck = false;
        nativeCheckInputs = [ ];
      });
    in
    [
      ps.arrow # Columnar data structures and serialization.
      ps.httpx # HTTP client used by Sidekick services.
      ps.jinja2 # Template engine used by generated content.
      ps."markdown-it-py" # Markdown parser used by Sidekick.
      ps.networkx # Graph data structures for analysis workflows.
      ps.numpy # Numerical array support for analysis tools.
      ps.orjson # Fast JSON serialization and parsing.
      ps.packaging # Parse and compare Python package versions.
      ps.psutil # Read process and system information.
      ps.pydantic # Validate structured configuration and data.
      ps.pygments # Render syntax-highlighted source code.
      pysqlite3 # SQLite bindings with the required package version.
      ps.pyyaml # Parse YAML configuration and data.
      ps.requests # HTTP client used by Python integrations.
      sqlite-vec # SQLite vector search extension.
      tenacity # Retry failed operations with backoff.
    ]
  );

  # Fetch the pinned Sidekick plugin archive from Binary Ninja.
  sidekickPlugin = pkgs.fetchzip {
    url = "https://extensions.binary.ninja/v1/extensions/21efa4ff-9499-4dff-affc-8715225b5b2d/versions/200d0f99-70ed-4462-93b7-2dbfbc75d0e0/platforms/3602/download?notrack=1";
    extension = "zip";
    hash = "sha256-NtUKlHrfX1EJXPUNdE5zWxg2uWr7nyvEjJvw0azDx14=";
  };

  # Package the proprietary Binary Ninja Personal archive as a reproducible local package.
  binaryninja-personal = pkgs.callPackage (
    {
      autoPatchelfHook,
      copyDesktopItems,
      curl,
      dbus,
      fontconfig,
      freetype,
      lib,
      libglvnd,
      libxkbcommon,
      libxcb-image,
      libxcb-keysyms,
      libxcb-render-util,
      libxcb-wm,
      makeDesktopItem,
      makeWrapper,
      qt6,
      requireFile,
      stdenv,
      unzip,
      wayland,
      xorg,
      zlib,
    }:

    let
      # Supply the shared libraries expected by Binary Ninja and its plugins.
      runtimeLibs = [
        curl # Transfer data for plugin and network features.
        dbus # Desktop message bus communication.
        fontconfig # Discover and match installed fonts.
        freetype # Rasterize fonts for the graphical interface.
        libglvnd # Dispatch OpenGL calls to the active driver.
        libxkbcommon # Parse keyboard layouts for X11 and Wayland.
        libxcb-image # Create XCB images.
        libxcb-keysyms # Translate X11 keyboard symbols.
        libxcb-render-util # Provide XRender helpers for XCB.
        libxcb-wm # Provide X11 window-manager helpers.
        qt6.qtbase # Provide the core Qt runtime.
        qt6.qtdeclarative # Provide Qt Quick and QML support.
        qt6.qtshadertools # Provide Qt shader tooling.
        stdenv.cc.cc.lib # Provide the GCC C++ runtime.
        wayland # Provide the Wayland client runtime.
        xorg.libX11 # Provide the X11 client runtime.
        xorg.libxcb # Provide the low-level X protocol client.
        zlib # Provide DEFLATE compression support.
      ];
      # Register Binary Ninja database file types with desktop environments.
      mimeInfo = pkgs.writeText "application-x-binaryninja.xml" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="application/x-binaryninja">
            <comment>Binary Ninja Analysis Database</comment>
            <icon name="application-x-binaryninja"/>
            <glob pattern="*.bndb"/>
            <glob pattern="*.bnpm"/>
            <glob pattern="*.bnta"/>
            <sub-class-of type="application/x-sqlite3"/>
          </mime-type>
        </mime-info>
      '';
    in
    stdenv.mkDerivation {
      pname = "binaryninja-personal";
      version = "5.3";

      src = requireFile {
        name = "binaryninja_linux_stable_personal.zip";
        sha256 = "sha256-RbxS0lW8sWcTQ6Sk5Ify6Ublu5vfdjQCFLdwWUSTE24=";
        message = ''
          Add the Binary Ninja Personal archive to the Nix store first:

            nix-store --add-fixed sha256 ~/binaryninja/binaryninja_linux_stable_personal.zip
        '';
      };

      nativeBuildInputs = [
        autoPatchelfHook # Rewrite ELF interpreters and library paths.
        copyDesktopItems # Install the generated desktop entry.
        makeWrapper # Create the launch wrapper with plugin paths.
        unzip # Extract the vendor archive.
      ];
      buildInputs = runtimeLibs; # Link the vendor binaries against the supplied libraries.
      sourceRoot = "binaryninja";
      dontWrapQtApps = true; # Binary Ninja ships Qt plugins and its own qt.conf.

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -a . "$out"

        mkdir -p "$out/bin"
        makeWrapper "$out/binaryninja" "$out/bin/binaryninja" \
          --prefix PATH : "${lib.makeBinPath [ pkgs.pyright ]}" \
          --prefix PYTHONPATH : "$out/python:$out/python3:${sidekickPlugin}:${sidekickPython}/${pkgs.python312.sitePackages}" \
          --prefix LD_LIBRARY_PATH : "${pkgs.python312}/lib"

        install -Dm644 "$out/docs/img/logo.png" \
          "$out/share/icons/hicolor/256x256/apps/binaryninja.png"
        install -Dm644 ${mimeInfo} \
          "$out/share/mime/packages/application-x-binaryninja.xml"

        runHook postInstall
      '';

      # Keep documentation challenge binaries byte-for-byte intact instead of
      # treating them as application executables during ELF patching.
      preFixup = ''
        mv "$out/docs/files" "$TMPDIR/binaryninja-doc-files"
      '';
      postFixup = ''
        mkdir -p "$out/docs"
        mv "$TMPDIR/binaryninja-doc-files" "$out/docs/files"
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "com.vector35.binaryninja";
          desktopName = "Binary Ninja Personal";
          comment = "A reverse engineering platform";
          exec = "binaryninja %u";
          icon = "binaryninja";
          mimeTypes = [
            "application/x-binaryninja"
            "x-scheme-handler/binaryninja"
          ];
          categories = [ "Development" ];
        })
      ];

      meta = {
        description = "Interactive decompiler, disassembler, and debugger";
        homepage = "https://binary.ninja/";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        mainProgram = "binaryninja";
      };
    }
  ) { };
in
{
  # Reproduce linux-setup.sh's user integration declaratively.
  home-manager.users.sweet_cicero.home.file = {
    ".binaryninja/lastrun".text = "${binaryninja-personal}\n";
    ".binaryninja/plugins/Vector35_Sidekick".source = sidekickPlugin;
    ".local/lib/python${pkgs.python312.pythonVersion}/site-packages/binaryninja.pth".text = ''
      ${binaryninja-personal}/python
      ${binaryninja-personal}/python3
      ${sidekickPlugin}
      ${sidekickPython}/${pkgs.python312.sitePackages}
    '';
  };

  # This module is self-contained: importing it defines and installs the package.
  # To upgrade, replace the archive, update version and sha256 above, seed the new
  # fixed-output path, and rebuild the system.
  environment.systemPackages = [
    binaryninja-personal # Proprietary Binary Ninja Personal package.
  ];
  system.extraDependencies = [ binaryninja-personal.src ]; # Keep the installer source reachable.
}
