{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    generateCompletions = true;

    shellAliases = {
      cat = "bat";
      df = "dysk";
      find = "fd";
      grep = "ugrep";
      la = "eza -la --icons=auto --group-directories-first --git";
      ll = "eza -lah --icons=auto --group-directories-first --git";
      ls = "eza --icons=auto --group-directories-first";
      lt = "eza --tree --icons=auto --group-directories-first";
      md = "glow";
      rm = "trash-put";
      n = "nvim";
    };

    shellAbbrs = {
      catp = "bat --plain";
      cdd = "cd -";
      g = "git";
      h = "atuin search";
      less = "bat --paging=always";
      nb = "nh os build";
      ns = "nh os switch";
      nt = "nh os test";
      nu = "nh os build --update";
      tree = "eza --tree --icons=auto --group-directories-first";
    };

    interactiveShellInit = ''
      set -gx CARAPACE_BRIDGES zsh,fish,bash,inshellisense

      if type -q atuin
        atuin init fish | source
      end

      if type -q carapace
        carapace _carapace | source
      end
    '';
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--cmd"
      "cd"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  programs.git = {
    enable = true;
    config.user = {
      email = "luke.cloud@gmail.com";
      name = "Luke Cloud";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    codex
    btop
    atuin
    bash-preexec
    bat
    carapace
    chezmoi
    direnv
    dysk
    eza
    fastfetch
    fd
    gh
    glab
    glow
    ripgrep
    shellcheck
    starship
    stress-ng
    tealdeer
    television
    trash-cli
    ugrep
    uutils-coreutils
    yq-go
    zoxide
    duf
    cowsay
    lolcat
    tmux
  ];
}
