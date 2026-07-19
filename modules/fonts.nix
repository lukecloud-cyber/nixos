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
    dejavu_fonts
    noto-fonts
  ];

  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test name="family">
        <string>JetBrainsMono Nerd Font</string>
      </test>
      <edit name="family" mode="append" binding="strong">
        <string>Noto Sans Symbols 2</string>
      </edit>
    </match>
  '';
}
