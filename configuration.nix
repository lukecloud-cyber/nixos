{ ... }:

{
  # Compose the machine from small, purpose-specific NixOS modules.
  imports = [
    ./modules/boot.nix # EFI bootloader and fallback kernel selection.
    # Remove this import to fall back to linuxPackages_latest from boot.nix.
    ./modules/cachyos-kernel.nix # Performance-tuned CachyOS kernel override.
    ./modules/nix-workflow.nix # Flakes, caches, cleanup, and Nix command helpers.
    ./modules/local-network.nix # NetworkManager and baseline firewall policy.
    ./modules/remote-access.nix # Tailscale and Sunshine remote access.
    ./modules/regional-settings.nix # Time zone and US English locale.
    ./modules/plasma-workstation.nix # Plasma desktop, display, audio, and printing.
    ./modules/sweet-cicero.nix # Primary user account and privileges.
    ./modules/terminal-workflow.nix # Fish shell and command-line utilities.
    ./modules/development-workflow.nix # Git, direnv, and repository tooling.
    ./modules/browsers.nix # Firefox and Brave browsers.
    ./modules/communication.nix # Chat applications.
    ./modules/office.nix # Calculator and office suite.
    ./modules/gaming/gaming.nix # Steam and general gaming optimizations.
    ./modules/gaming/start-citizen.nix # Star Citizen launcher and cache.
    ./modules/fonts.nix # Text, symbol, and programming fonts.
    ./modules/codex.nix # Codex CLI and its machine-wide policy.
    ./modules/reverse-engineering/ida-home.nix # Locally supplied IDA Home package.
    ./modules/reverse-engineering/tools.nix # Reverse-engineering toolkit.
    ./modules/neovim-lazyvim.nix # Neovim, LazyVim, plugins, and language tools.
    ./modules/container-development.nix # Docker engine and management tools.
  ];

  # Keep this at the release version of the first install.
  system.stateVersion = "26.05";
}
