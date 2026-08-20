{ pkgs, ... }:

{
  # Configure Yazi with a reproducible Markdown preview.
  programs.yazi = {
    enable = true;

    plugins.piper = pkgs.yaziPlugins.piper;

    settings.yazi.plugin.prepend_previewers = [
      {
        url = "*.md";
        run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=$t "$1"'';
      }
    ];
  };

  # Keep the selected Yazi directory when the function exits.
  programs.fish.interactiveShellInit = ''
    function y
      set -l tmp (mktemp -t "yazi-cwd.XXXXX")
      command yazi $argv --cwd-file="$tmp"

      if read cwd < "$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
      end

      rm -f -- "$tmp"
    end
  '';
}
