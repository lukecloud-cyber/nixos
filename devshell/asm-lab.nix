{
  # Let direnv load the centrally declared development shell in this project.
  home-manager.users.sweet_cicero.home.file."Projects/asm-lab/.envrc".text = ''
    use flake /etc/nixos#asm-lab
  '';
}
