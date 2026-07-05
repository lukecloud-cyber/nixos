{ pkgs, ... }:

{
  programs.firefox.enable = true;
  # programs.ratty.enable = true;

  environment.systemPackages = with pkgs; [
    brave
    discord
  ];
}
