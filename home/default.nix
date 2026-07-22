{ lib, pkgs, ... }:

{
  # Define the user profile and files that belong directly in the home directory.
  home = {
    username = "sweet_cicero";
    homeDirectory = "/home/sweet_cicero";
    stateVersion = "26.05"; # Keep compatibility defaults fixed across Home Manager upgrades.

    # Keep GitHub authentication delegated to gh without storing credentials here.
    file.".gitconfig".text = ''
      [credential "https://github.com"]
        helper =
        helper = !${pkgs.gh}/bin/gh auth git-credential
      [credential "https://gist.github.com"]
        helper =
        helper = !${pkgs.gh}/bin/gh auth git-credential
    '';

    # Load reversing MCP servers only from this trusted project tree.
    file."Projects/reversing/.codex/config.toml".source = ./files/reversing-codex.toml;
  };

  # Manage XDG configuration, application data, and desktop MIME handlers.
  xdg = {
    enable = true;

    configFile = {
      # Configure Glow's terminal Markdown rendering defaults.
      "glow/glow.yml".text = ''
        style: "auto"
        mouse: false
        pager: true
        width: 80
        all: false
      '';

      # Make the Fish-based profile the default for KDE Konsole.
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
      # Define the Konsole profile referenced by konsolerc above.
      "konsole/Fish.profile".text = ''
        [Appearance]
        Font=JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0
        UseFontBrailleChararacters=true
        UseFontLineChararacters=false

        [General]
        Name=Fish
        Parent=FALLBACK/
      '';

      # Add a Steam launcher for Bloodlines 2 to the desktop application menu.
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

    # Route mail links to Brave and Heroic links to the Heroic launcher.
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

  # Install and configure user-facing tools whose settings live in the home directory.
  programs = {
    # Enable VS Code by default; individual NixOS hosts can override this value.
    vscode = {
      enable = lib.mkDefault true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide # Nix syntax, formatting, and language-server integration.
        ms-vscode.cpptools # Microsoft C/C++ IntelliSense, navigation, and debugging.
        ms-python.python # Core Python editing, testing, and environment integration.
        ms-python.vscode-pylance # Fast Python completion, navigation, and type analysis.
        ms-python.debugpy # Python debugging with breakpoints and variable inspection.
      ];
    };

    # Store searchable shell history in Atuin without adding duplicate Fish hooks.
    atuin = {
      enable = true;
      enableFishIntegration = false;
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
        sync.records = true;
      };
    };

    # Manage btop settings while using the system-installed btop package.
    btop = {
      enable = true;
      package = null; # Avoid installing a second copy alongside systemPackages.
      settings.graph_symbol = "braille";
    };

    # Configure the GitHub CLI and leave Git credential wiring to .gitconfig above.
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
