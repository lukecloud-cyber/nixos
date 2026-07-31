{
  # Provide a graphical interface for managing libvirt virtual machines.
  programs.virt-manager.enable = true;

  # Run the libvirt daemon and permit the primary user to manage its guests.
  virtualisation.libvirtd.enable = true;
  users.users.sweet_cicero.extraGroups = [ "libvirtd" ];
}
