{
  networking.networkmanager.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = true;

    interfaces.tailscale0 = {
      allowedTCPPorts = [ 47984 47989 47990 48010 ];
      allowedUDPPorts = [ 47998 47999 48000 48002 48010 ];
    };

    extraCommands = ''
      iptables -w -A nixos-fw -i wlp5s0 -s 192.168.1.0/24 -p tcp -m multiport --dports 47984,47989,47990,48010 -j nixos-fw-accept
      iptables -w -A nixos-fw -i wlp5s0 -s 192.168.1.0/24 -p udp -m multiport --dports 47998,47999,48000,48002,48010 -j nixos-fw-accept
    '';
  };
}
