{ config, lib, ... }:

{
  virtualisation.oci-containers.containers."dockur-windows-crackme-current" = {
    image = "docker.io/dockurr/windows:5.14";

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

    devices = [
      "/dev/kvm:/dev/kvm"
      "/dev/net/tun:/dev/net/tun"
    ];

    capabilities.NET_ADMIN = true;

    ports = [
      "127.0.0.1:8006:8006"
      "127.0.0.1:5900:5900"
      "0.0.0.0:3390:3389/tcp"
      "0.0.0.0:3390:3389/udp"
    ];

    volumes = [
      "/home/sweet_cicero/docker/dockur-windows/labs/crackme-current:/storage:Z"
      "/home/sweet_cicero/docker/dockur-windows/shared:/shared:Z"
    ];

    extraOptions = [ "--stop-timeout=120" ];

    # Run the container without root when Podman is selected.
    podman = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") {
      user = "sweet_cicero";
    };
  };
}
