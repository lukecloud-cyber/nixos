{ pkgs, ... }:

{
  # Run the Docker daemon and provide its command-line client.
  virtualisation.docker.enable = true;

  # Let the primary user access Docker without sudo.
  users.users.sweet_cicero.extraGroups = [ "docker" ];

  # Install tools for defining and interactively managing Docker workloads.
  environment.systemPackages = with pkgs; [
    docker-compose # Define and run multi-container Docker applications.
    lazydocker # Terminal user interface for Docker resources and logs.
  ];
}
