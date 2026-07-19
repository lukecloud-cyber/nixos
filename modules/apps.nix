{ pkgs, ... }:

{
  programs.firefox.enable = true;
  # programs.ratty.enable = true;

  environment.systemPackages = with pkgs; [
    brave
    discord
    kdePackages.krdc
    kdePackages.kcalc
    unzip
    
    util-linux
    e2fsprogs
    onlyoffice-desktopeditors
  ];
}
