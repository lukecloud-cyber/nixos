{
  description = "sweet_cicero NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ratty = {
      url = "github:orhun/ratty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
      #  inputs.ratty.nixosModules.default
        inputs.nix-index-database.nixosModules.default
        inputs.nixos-hardware.nixosModules.dell-latitude-7490
        ./configuration.nix
      ];
    };
  };
} 
