{
  # Let NetworkManager manage wired, wireless, and VPN connections.
  networking.networkmanager.enable = true;

  # Drop unsolicited traffic, ignore ping, and reject spoofed return paths.
  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = true;
  };

  # Join the private Tailscale mesh and permit its transport traffic.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
