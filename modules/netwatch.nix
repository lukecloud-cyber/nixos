{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.netwatch ];

  security.wrappers.netwatch = {
    source = "${pkgs.netwatch}/bin/netwatch";
    owner = "root";
    group = "users";
    permissions = "u+rx,g+x";
    capabilities = "cap_net_raw+ep";
  };
}
