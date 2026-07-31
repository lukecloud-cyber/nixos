{ pkgs, ... }:

{
  # Install the QEMU system emulator for virtual machines and foreign targets.
  environment.systemPackages = [
    pkgs.qemu # Emulate hardware for virtual machines and foreign architectures.
  ];
}
