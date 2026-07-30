{ pkgs, ... }:

{
  # Enable Docker and select Docker for OCI containers.
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  # Permit Docker access without sudo.
  users.users.sweet_cicero.extraGroups = [ "docker" ];

  # Install the Docker management tools.
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
