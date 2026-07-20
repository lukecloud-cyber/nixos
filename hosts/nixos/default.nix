{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-7490
    inputs.nix-index-database.nixosModules.default
    ../../modules/boot.nix
    ../../modules/nix-workflow.nix
    ../../modules/local-network.nix
    ../../modules/remote-access.nix
    ../../modules/regional-settings.nix
    ../../modules/plasma-workstation.nix
    ../../modules/sweet-cicero.nix
    ../../modules/terminal-workflow.nix
    ../../modules/development-workflow.nix
    ../../modules/browsers.nix
    ../../modules/communication.nix
    ../../modules/office.nix
    ../../modules/gaming/gaming.nix
    ../../modules/fonts.nix
    ../../modules/codex.nix
    ../../modules/reverse-engineering/ida-home.nix
    ../../modules/reverse-engineering/tools.nix
    ../../modules/neovim-lazyvim.nix
    ../../modules/container-development.nix
  ];

  networking.hostName = "nixos";

  boot.initrd.luks.devices."luks-fa6ca2aa-a1ea-4a94-9f2d-6a9d78ba1878".device =
    "/dev/disk/by-uuid/fa6ca2aa-a1ea-4a94-9f2d-6a9d78ba1878";

  system.stateVersion = "26.05";
}
