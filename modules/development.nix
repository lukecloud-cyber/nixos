{ pkgs, ... }:

{
  # Load project-specific environments automatically, backed by Nix shells.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  # Install Git and set the default commit identity.
  programs.git = {
    enable = true;
    config.user = {
      email = "luke.cloud@gmail.com";
      name = "Luke Cloud";
    };
  };

  # Install command-line tools shared by development projects.
  environment.systemPackages = with pkgs; [
    direnv # Load and unload per-directory shell environments.
    glab # GitLab command-line client.
    shellcheck # Static analyzer for shell scripts.
    yq-go # Query and edit YAML, JSON, XML, and related formats.
  ];
}
