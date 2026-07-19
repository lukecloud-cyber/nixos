{ pkgs, lib, ... }:

let
  ida-home-pc = pkgs.callPackage (
    { lib
    , stdenv
    , requireFile
    , autoPatchelfHook
    , copyDesktopItems
    , makeDesktopItem
    , makeWrapper
    }:

    let
      runtimeLibs = with pkgs; [
        dbus
        fontconfig
        freetype
        glib
        gtk3
        libdrm
        libglvnd
        libxcrypt-legacy
        libxkbcommon
        stdenv.cc.cc.lib
        wayland
        xcbutil
        xcbutilcursor
        xcbutilimage
        xcbutilkeysyms
        xcbutilrenderutil
        xcbutilwm
        libice
        libsm
        libx11
        libxext
        libxi
        libxrender
        libxtst
        libxcb
        python312
        zlib
      ];
    in
    stdenv.mkDerivation rec {
      pname = "ida-home-pc";
      version = "9.4";

      src = requireFile {
        name = "ida-home-pc_94_x64linux.run";
        sha256 = "sha256-htOTAwWa77hf06OTDU4BX48l/s2kPfsnq0KuKSsbCc4=";
        message = ''
          Add the IDA Home (PC) ${version} installer to the Nix store first:

            nix-store --add-fixed sha256 ~/ida-home/ida-home-pc_94_x64linux.run
        '';
      };

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
      ];
      buildInputs = runtimeLibs;
      dontUnpack = true;

      autoPatchelfIgnoreMissingDeps = [
        "libQt6EglFSDeviceIntegration.so.6"
        "libQt6Network.so.6"
        "libQt6WaylandCompositor.so.6"
        "libQt6WlShellIntegration.so.6"
      ];

      installPhase = ''
        runHook preInstall

        export HOME="$TMPDIR"

        ${stdenv.cc.libc}/lib64/ld-linux-x86-64.so.2 "$src" \
          --mode unattended --unattendedmodeui none --prefix "$out"

        rm -f "$out/uninstall" "$out/Uninstall IDA Home (PC) ${version}.desktop"

        makeWrapper "$out/ida" "$out/bin/ida" \
          --run "$out/idapyswitch --force-path ${pkgs.python312}/lib/libpython3.12.so" \
          --set QT_PLUGIN_PATH "$out/plugins" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:$out"

        install -Dm644 "$out/appico.png" \
          "$out/share/icons/hicolor/256x256/apps/ida-home-pc.png"

        runHook postInstall
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "ida-home-pc";
          desktopName = "IDA Home (PC)";
          exec = "ida";
          icon = "ida-home-pc";
          categories = [ "Development" ];
        })
      ];

      meta = {
        description = "IDA Home (PC) disassembler";
        homepage = "https://hex-rays.com/ida-home/";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        mainProgram = "ida";
      };
    }
  ) { };
in
{
  # This module is self-contained: importing it both defines the private IDA
  # package and adds it to systemPackages.
  #
  # IDA is proprietary, so Nix cannot fetch the installer. Seed the exact
  # installer into the store before building:
  #
  #   nix-store --add-fixed sha256 ~/ida-home/ida-home-pc_94_x64linux.run
  #
  # To upgrade later:
  #
  #   1. Download the new Linux .run installer from Hex-Rays.
  #   2. Get its Nix hash:
  #
  #        nix hash file --type sha256 ~/ida-home/ida-home-pc_94_x64linux.run
  #
  #   3. Update version, src.name, src.sha256, and the add-fixed command above.
  #   4. Add the new installer to the store:
  #
  #        nix-store --add-fixed sha256 ~/ida-home/ida-home-pc_94_x64linux.run
  #
  # Old IDA versions remain available through older NixOS generations until
  # those generations are garbage-collected.
  environment.systemPackages = [ ida-home-pc ];
}
