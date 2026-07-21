{
  # Run the Sunshine game-streaming host without opening ports on every interface.
  services.sunshine = {
    enable = true;
    openFirewall = false;
  };

  # Expose Sunshine's control, video, audio, and input ports only over Tailscale.
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [
      47984
      47989
      47990
      48010
    ];
    allowedUDPPorts = [
      47998
      47999
      48000
      48002
      48010
    ];
  };
}
