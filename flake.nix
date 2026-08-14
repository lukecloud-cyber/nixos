{
  description = "sweet_cicero NixOS system configuration";

  inputs = {
    # Rolling NixOS package and module collection.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Prebuilt CachyOS kernels and their NixOS module.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # GPU-rendered terminal emulator and its NixOS module.
    ratty = {
      url = "github:orhun/ratty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inputs.flake-compat.follows = "nix-cachyos-kernel/flake-compat";
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

      # Provide the Python tutorial environment without installing its packages globally.
      devShells.x86_64-linux.python-tutorial =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = [
            pkgs.python3
            pkgs.python3Packages.numpy
            pkgs.python313Packages.ipython
          ];

          env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.libz
          ];
        };

      # Provide the Rust toolchain, editor support, and common Cargo workflows.
      devShells.x86_64-linux.rustlab =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            rustc # Rust compiler.
            cargo # Build tool and package manager.
            rust-analyzer # Language server for editor integration.
            rustfmt # Standard formatter.
            clippy # Standard linter.
            cargo-edit # Add, remove, and upgrade dependencies from Cargo.
            cargo-watch # Re-run commands when source files change.
            cargo-audit # Check dependencies for known vulnerabilities.
            cargo-nextest # Faster test runner.
            pkg-config # Discover native libraries used by crates.
            openssl # Common native TLS dependency.
          ];

          env.RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };

      # Provide tools for x86-64 NASM assembly, linking, debugging, and runtime analysis.
      devShells.x86_64-linux.asm-lab =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            nasm
            binutils
            gcc
            gnumake
            gdb
            valgrind
            strace
          ];
        };
    };
}
