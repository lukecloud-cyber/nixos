{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/storage.nix
    ./modules/nix.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    ./modules/user.nix
    ./modules/cli.nix
    ./modules/apps.nix
    ./modules/gaming.nix
    ./modules/fonts.nix
    ./modules/codex.nix
    ./modules/lazyvim.nix
  ];

  networking.hostName = "nixos";

  # Keep this at the release version of the first install.
  system.stateVersion = "26.05";
}
