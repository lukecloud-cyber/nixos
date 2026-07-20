{ lib, pkgs, ... }:

{
  # Install systemd-boot into the EFI System Partition.
  boot.loader.systemd-boot.enable = true;
  # Allow NixOS to create and update firmware boot entries.
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the newest nixpkgs kernel unless another module overrides it.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
}
