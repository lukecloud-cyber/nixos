{ config, lib, ... }:

{
  # Wait for Tailscale to create its address before Docker binds RDP.
  systemd.services.docker-dockur-windows-crackme-current = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
  };

  # Run an isolated Windows 11 lab for reverse-engineering challenge files.
  virtualisation.oci-containers.containers."dockur-windows-crackme-current" = {
    # Use the pinned Dockur Windows container image.
    image = "docker.io/dockurr/windows:5.14";

    # Configure the guest version, resources, locale, and guest credentials.
    environment = {
      VERSION = "11";
      RAM_SIZE = "16G";
      CPU_CORES = "8";
      DISK_SIZE = "120G";
      HV = "N";
      CPU_FLAGS = "svm=off";
      USERNAME = "Docker";
      PASSWORD = "admin";
      LANGUAGE = "English";
      REGION = "en-US";
      KEYBOARD = "en-US";
    };

    # Pass KVM and TUN devices into the guest container.
    devices = [
      "/dev/kvm:/dev/kvm"
      "/dev/net/tun:/dev/net/tun"
    ];

    # Allow the guest to manage its virtual network interface.
    capabilities.NET_ADMIN = true;

    # Expose the guest console locally and expose RDP locally and through Tailscale.
    ports = [
      "127.0.0.1:8006:8006"
      "127.0.0.1:5900:5900"
      "127.0.0.1:3390:3389/tcp"
      "127.0.0.1:3390:3389/udp"
      # ponytail: Update this address if Wi-Fi assigns a new host address.
      "192.168.1.228:3390:3389/tcp"
      "192.168.1.228:3390:3389/udp"
      # ponytail: Update this address if Tailscale assigns a new node address.
      "100.87.44.103:3390:3389/tcp"
      "100.87.44.103:3390:3389/udp"
    ];

    # Persist the Windows disk and share challenge files with the host.
    volumes = [
      "/home/sweet_cicero/docker/dockur-windows/labs/crackme-current:/storage:Z"
      "/home/sweet_cicero/docker/dockur-windows/shared:/shared:Z"
    ];

    # Allow extra time for the guest to stop cleanly.
    extraOptions = [ "--stop-timeout=120" ];

    # Run the container without root when Podman is selected.
    podman = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") {
      user = "sweet_cicero";
    };
  };
}
