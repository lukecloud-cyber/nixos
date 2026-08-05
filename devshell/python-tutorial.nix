{
  # Let direnv load the centrally declared development shell in this project.
  home-manager.users.sweet_cicero.home.file."Projects/python_tutorial/.envrc".text = ''
    use flake /etc/nixos#python-tutorial
  '';
}
