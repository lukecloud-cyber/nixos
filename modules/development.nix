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

  # Load the shared Rust development shell whenever this project is entered.
  home-manager.users.sweet_cicero.home.file."Projects/rustlab/.envrc".text = ''
    use flake /etc/nixos#rustlab
  '';

  # Install command-line tools shared by development projects.
  environment.systemPackages = with pkgs; [
    glab # GitLab command-line client.
    shellcheck # Static analyzer for shell scripts.
    yq-go # Query and edit YAML, JSON, XML, and related formats.
  ];
}
