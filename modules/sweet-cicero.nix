{ pkgs, ... }:

{
  # Define the primary interactive desktop user.
  users.users."sweet_cicero" = {
    isNormalUser = true;
    description = "sweet_cicero";
    extraGroups = [
      "networkmanager" # Permit managing network connections.
      "wheel" # Grant sudo access.
    ];
    shell = pkgs.fish; # Use Fish as the login shell.
    packages = with pkgs; [
      kdePackages.kate # KDE graphical text and source editor.
    ];
  };

  # Allow wheel members to use sudo without an interactive password.
  security.sudo.wheelNeedsPassword = false;
}
