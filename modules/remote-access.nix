{ pkgs, ... }:

{
  # Join the private Tailscale mesh and permit its transport traffic.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Host Sunshine game/desktop streaming without opening every interface.
  services.sunshine = {
    enable = true;
    openFirewall = false;
  };

  # Expose Sunshine only through Tailscale and the trusted local Wi-Fi subnet.
  networking.firewall = {
    interfaces.tailscale0 = {
      # Sunshine web, control, RTSP, and input channels.
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      # Sunshine video, audio, and control streams.
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };

  };

  environment.systemPackages = [
    pkgs.kdePackages.krdc # KDE client for RDP and VNC remote desktops.
  ];
}
