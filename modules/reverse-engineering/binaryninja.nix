{ pkgs, lib, ... }:

let
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

        build-system = [ ps.setuptools ];
        buildInputs = [ pkgs.sqlite ];
        pythonImportsCheck = [ "pysqlite3" ];
      };
      tenacity = ps.tenacity.overridePythonAttrs (_: rec {
        version = "8.5.0";
        src = pkgs.fetchPypi {
          pname = "tenacity";
          inherit version;
          hash = "sha256-i8bAyKCbMebK0TxHr77RpWdRglCpoXFBhYLtjZwgyng=";
        };
      });
      sqlite-vec = ps."sqlite-vec".overridePythonAttrs (old: {
        dependencies = (old.dependencies or [ ]) ++ [ ps.numpy ];
        # ponytail: nixpkgs' check pulls OpenAI only for tests; drop this override when it no longer does.
        doInstallCheck = false;
        nativeCheckInputs = [ ];
      });
    in
    [
      ps.arrow
      ps.httpx
      ps.jinja2
      ps."markdown-it-py"
      ps.networkx
      ps.numpy
      ps.orjson
      ps.packaging
      ps.psutil
      ps.pydantic
      ps.pygments
      pysqlite3
      ps.pyyaml
      ps.requests
      sqlite-vec
      tenacity
    ]
  );

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
      runtimeLibs = [
        curl
        dbus
        fontconfig
        freetype
        libglvnd
        libxkbcommon
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-wm
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtshadertools
        stdenv.cc.cc.lib
        wayland
        xorg.libX11
        xorg.libxcb
        zlib
      ];
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
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
        unzip
      ];
      buildInputs = runtimeLibs;
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
  environment.systemPackages = [ binaryninja-personal ];
  system.extraDependencies = [ binaryninja-personal.src ];
}
