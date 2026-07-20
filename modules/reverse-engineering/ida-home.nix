{ pkgs, lib, ... }:

let
  # Wrap the proprietary IDA Home installer as a reproducible local package.
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
      # Libraries expected by IDA's bundled executables and Qt interface.
      runtimeLibs = with pkgs; [
        dbus # Desktop message bus IPC.
        fontconfig # Font discovery and matching.
        freetype # Font rasterization.
        glib # Core data types and event loops used by GTK.
        gtk3 # GTK desktop integration libraries.
        libdrm # Direct Rendering Manager interface.
        libglvnd # Vendor-neutral OpenGL dispatch library.
        libxcrypt-legacy # Legacy crypt symbols expected by proprietary binaries.
        libxkbcommon # Keyboard map handling for X11 and Wayland.
        stdenv.cc.cc.lib # GCC C++ runtime.
        wayland # Wayland client runtime.
        xcbutil # Common XCB convenience helpers.
        xcbutilcursor # XCB cursor management.
        xcbutilimage # XCB image conversion helpers.
        xcbutilkeysyms # XCB keyboard symbol helpers.
        xcbutilrenderutil # X Render helpers for XCB.
        xcbutilwm # XCB window-manager helpers.
        libice # X11 inter-client exchange runtime.
        libsm # X11 session-management runtime.
        libx11 # Core X11 client library.
        libxext # Common X11 protocol extensions.
        libxi # X11 input extension.
        libxrender # X11 Render extension.
        libxtst # X11 input-testing extension.
        libxcb # Low-level X protocol client library.
        python312 # Embedded IDAPython runtime.
        zlib # DEFLATE compression runtime.
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
        autoPatchelfHook # Point installer binaries at Nix store libraries.
        copyDesktopItems # Install generated desktop entries.
        makeWrapper # Create the launch wrapper with required environment variables.
      ];
      buildInputs = runtimeLibs; # Make runtime libraries visible to autoPatchelf.
      dontUnpack = true; # The source is a self-extracting installer, not an archive.

      # Ignore optional Qt backends and compositor libraries not needed here.
      autoPatchelfIgnoreMissingDeps = [
        "libQt6EglFSDeviceIntegration.so.6"
        "libQt6Network.so.6"
        "libQt6WaylandCompositor.so.6"
        "libQt6WlShellIntegration.so.6"
      ];

      # Run the vendor installer unattended, then wrap and register the result.
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

      # Add IDA to desktop application menus.
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
  environment.systemPackages = [
    ida-home-pc # Proprietary IDA Home disassembler built from the seeded installer.
  ];
}
