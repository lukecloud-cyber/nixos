{ pkgs, ... }:

{
  # Enable Podman and select Podman for OCI containers.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  virtualisation.oci-containers.backend = "podman";

  # Configure rootless Podman with persistent user services.
  users.users.sweet_cicero = {
    linger = true;
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    podman-compose # Define and run multi-container Podman applications.
    podman-tui # Manage Podman containers from a terminal interface.
  ];
}
