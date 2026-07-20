{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixospc";

  boot.initrd.luks.devices."luks-b19e4fb2-d47e-4d14-87d8-617fab2d8c78".device =
    "/dev/disk/by-uuid/b19e4fb2-d47e-4d14-87d8-617fab2d8c78";

  networking.firewall.extraCommands = ''
    iptables -w -A nixos-fw -i wlp5s0 -s 192.168.1.0/24 -p tcp -m multiport --dports 47984,47989,47990,48010 -j nixos-fw-accept
    iptables -w -A nixos-fw -i wlp5s0 -s 192.168.1.0/24 -p udp -m multiport --dports 47998,47999,48000,48002,48010 -j nixos-fw-accept
  '';
}
