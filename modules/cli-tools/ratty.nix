{ inputs, ... }:

{
  imports = [ inputs.ratty.nixosModules.default ];
  programs.ratty.enable = true;
}
