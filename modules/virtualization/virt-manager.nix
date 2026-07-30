{
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  users.users.sweet_cicero.extraGroups = [ "libvirtd" ];
}
