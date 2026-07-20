{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-7490
  ];

  networking.hostName = "nixos";

  boot.initrd.luks.devices."luks-fa6ca2aa-a1ea-4a94-9f2d-6a9d78ba1878".device =
    "/dev/disk/by-uuid/fa6ca2aa-a1ea-4a94-9f2d-6a9d78ba1878";
}
