{ pkgs, ... }:

{
  # Install programming fonts and broad Unicode fallbacks system-wide.
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only # Nerd Font icons without an accompanying text face.
    nerd-fonts.jetbrains-mono # Developer-focused monospaced Nerd Font.
    nerd-fonts.fira-code # Monospaced Nerd Font with programming ligatures.
    nerd-fonts.hack # Highly legible monospaced Nerd Font.
    nerd-fonts.caskaydia-cove # Cascadia Code-derived Nerd Font with ligatures.
    nerd-fonts.caskaydia-mono # Cascadia Code-derived Nerd Font without ligatures.
    nerd-fonts.iosevka # Narrow, configurable programming Nerd Font.
    nerd-fonts.meslo-lg # Menlo-derived Nerd Font commonly used by prompts.
    nerd-fonts.sauce-code-pro # Source Code Pro-derived Nerd Font.
    dejavu_fonts # General-purpose Latin, Greek, and Cyrillic typefaces.
    noto-fonts # Broad Unicode coverage and fallback fonts.
  ];

  # Fall back to Noto symbols when JetBrains Mono lacks a requested glyph.
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
