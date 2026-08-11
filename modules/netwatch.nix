{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.netwatch ];
}
