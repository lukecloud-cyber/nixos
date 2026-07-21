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
    # Declarative per-user packages and dotfiles.
    home-manager = {
      url = "github:nix-community/home-manager";
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
      # Build both machines from the same architecture, Home Manager profile,
      # and shared flake inputs; each host module supplies its hardware choices.
      mkHost =
        hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true; # Reuse the system's pinned and configured nixpkgs.
                useUserPackages = true; # Install Home Manager packages in the per-user profile.
                backupFileExtension = "hm-backup"; # Preserve replaced dotfiles instead of failing.
                users.sweet_cicero = import ./home; # Apply the shared user configuration to each host.
              };
            }
            hostModule
          ];
        };
    in
    {
      # Map stable flake output names to their host-specific modules.
      nixosConfigurations = {
        nixos = mkHost ./hosts/nixos;
        nixospc = mkHost ./hosts/nixospc;
      };
    };
}
