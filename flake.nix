{
  description = "sweet_cicero NixOS system configuration";

  inputs = {
    # Rolling NixOS package and module collection.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Prebuilt CachyOS kernels and their NixOS module.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # Pre-generated command database used by comma/nix-index.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Star Citizen launcher package and binary cache configuration.
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Vendor hardware profiles used by the Dell laptop.
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      mkHost =
        hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nix-index-database.nixosModules.default
            ./configuration.nix
            hostModule
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost ./hosts/nixos;
        nixospc = mkHost ./hosts/nixospc;
      };
    };
}
