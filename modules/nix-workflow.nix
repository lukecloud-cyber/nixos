{ inputs, ... }:

{
  # Allow modules to select packages with non-free licenses.
  nixpkgs.config.allowUnfree = true;

  # Enable the modern Nix CLI and flake commands.
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # Make legacy nixpkgs lookups resolve to the flake's pinned nixpkgs input.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Let `, command` find and run packages using the prebuilt nix-index database.
  programs.nix-index-database.comma.enable = true;

  # Use nh as the friendly build/switch frontend for this system flake.
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";

    clean = {
      enable = true;
      # Retain generations from the last week and at least five generations.
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  # Run dynamically linked, non-Nix binaries by supplying NixOS libraries.
  programs.nix-ld.enable = true;
}
