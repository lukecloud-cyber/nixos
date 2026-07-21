{ pkgs, ... }:

{
  # Join the private Tailscale mesh and permit its transport traffic.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Install a graphical client for connecting to remote desktops.
  environment.systemPackages = [
    pkgs.kdePackages.krdc # KDE client for RDP and VNC remote desktops.
  ];
}
