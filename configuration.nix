{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/cachyos-kernel.nix
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
    ./modules/ida-home-pc.nix
    ./modules/reversing.nix
    ./modules/lazyvim.nix
    ./modules/containers.nix
  ];
   

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixospc";

  # Keep this at the release version of the first install.
  system.stateVersion = "26.05";
}
