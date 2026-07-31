{ pkgs, ... }:

{
  # Join the private Tailscale mesh and permit its transport traffic.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Accept SSH connections only from declared public keys.
  services.openssh = {
    enable = true;
    openFirewall = false;
    authorizedKeysInHomedir = false;
    settings = {
      AllowUsers = [ "sweet_cicero" ];
      AuthenticationMethods = "publickey";
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  users.users.sweet_cicero.openssh.authorizedKeys.keys = [
    # The key fingerprint is SHA256:R2sFVRWHm6PZP4hyBLjuSfUEL7Cw1MzlqL31wm1lus4.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpXjpQ+9mksl6IctrYQzviuJ5QqCPf2FcRCS3PZk5ir"
    # The key fingerprint is SHA256:+ThtMUq1hM/Ub0GfVpi7jTXkGHM/KzQQ0K5EIjg+2/M.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhlrS7Xdxg+fhA0SWob9NV64VmBkuKA1UtGNFsNYoWG"
    # The key fingerprint is SHA256:m/NDBRNQXE9235tmOuH2UhUGKCu9ikUu39IDz1h1Wfo.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINtniCqpUHOj+LnRiS7oUp2dnPxH4SiFyDOKYp4IZjS"
  ];

  # Permit SSH from the local IPv4 LAN and the Tailscale interface.
  networking.firewall.extraCommands = ''
    iptables -w -A nixos-fw -s 192.168.1.0/24 -p tcp --dport 22 -j nixos-fw-accept
  '';
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Install a graphical client for connecting to remote desktops.
  environment.systemPackages = [
    pkgs.kdePackages.krdc # KDE client for RDP and VNC remote desktops.
  ];
}
