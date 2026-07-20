{ pkgs, ... }:

{
  home = {
    username = "sweet_cicero";
    homeDirectory = "/home/sweet_cicero";
    stateVersion = "26.05";

    # Keep GitHub authentication delegated to gh without storing credentials here.
    file.".gitconfig".text = ''
      [credential "https://github.com"]
        helper =
        helper = !${pkgs.gh}/bin/gh auth git-credential
      [credential "https://gist.github.com"]
        helper =
        helper = !${pkgs.gh}/bin/gh auth git-credential
    '';
  };

  xdg = {
    enable = true;

    configFile = {
      "glow/glow.yml".text = ''
        style: "auto"
        mouse: false
        pager: true
        width: 80
        all: false
      '';

      "konsolerc".text = ''
        [Desktop Entry]
        DefaultProfile=Fish.profile

        [General]
        ConfigVersion=1

        [Notification Messages]
        CloseAllTabs=true
        CloseSingleTab=true

        [UiSettings]
        ColorScheme=
      '';
    };

    dataFile = {
      "konsole/Fish.profile".text = ''
        [Appearance]
        Font=JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0
        UseFontBrailleChararacters=true
        UseFontLineChararacters=false

        [General]
        Name=Fish
        Parent=FALLBACK/
      '';

      "applications/Vampire The Masquerade - Bloodlines 2.desktop" = {
        executable = true;
        text = ''
          [Desktop Entry]
          Name=Vampire: The Masquerade - Bloodlines 2
          Comment=Play this game on Steam
          Exec=steam steam://rungameid/532790
          Icon=steam
          Terminal=false
          Type=Application
          Categories=Game;
        '';
      };
    };

    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/mailto" = "brave-browser.desktop";
        "x-scheme-handler/heroic" = "com.heroicgameslauncher.hgl.desktop";
      };
      defaultApplications = {
        "x-scheme-handler/mailto" = "brave-browser.desktop";
        "x-scheme-handler/heroic" = "com.heroicgameslauncher.hgl.desktop";
      };
    };
  };

  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = false;
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
        sync.records = true;
      };
    };

    btop = {
      enable = true;
      package = null;
      settings.graph_symbol = "braille";
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = false;
      settings = {
        git_protocol = "https";
        prompt = "enabled";
        aliases.co = "pr checkout";
      };
    };
  };
}
