{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.iosevka
    nerd-fonts.meslo-lg
    nerd-fonts.sauce-code-pro
  ];
}
