{ inputs, ... }:

{
  # Replace the fallback kernel with the x86-64-v3, BORE, LTO CachyOS build.
  boot.kernelPackages =
    inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-bore-lto-x86_64-v3;
}
