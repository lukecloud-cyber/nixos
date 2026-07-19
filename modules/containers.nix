{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  users.users.sweet_cicero.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
