{ pkgs, ... }:

{
  # Enable Firefox through its NixOS program module.
  programs.firefox.enable = true;

  # Install additional graphical web browsers system-wide.
  environment.systemPackages = [
    pkgs.brave # Chromium-based browser with built-in privacy protections.
  ];
}
