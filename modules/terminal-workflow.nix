{ pkgs, ... }:

{
  # Configure Fish as the interactive shell with modern command replacements.
  programs.fish = {
    enable = true;
    generateCompletions = true;

    # Replace familiar commands while preserving short, memorable names.
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

    # Expand convenience abbreviations in-place so commands remain visible/editable.
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

    # Initialize shell history search and cross-shell completion bridges.
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

  # Enable the fast, context-aware cross-shell prompt.
  programs.starship.enable = true;

  # Track frequently visited directories and expose it as `cd`.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--cmd"
      "cd"
    ];
  };

  # Install the terminal applications referenced by the shell configuration above.
  environment.systemPackages = with pkgs; [
    vim # Classic terminal text editor and recovery fallback.
    wget # Non-interactive HTTP, HTTPS, and FTP downloader.
    btop # Interactive process, CPU, memory, disk, and network monitor.
    bash-preexec # Bash hooks required by tools that observe command execution.
    bat # Syntax-highlighted `cat` replacement.
    carapace # Multi-shell command completion engine.
    dysk # Compact disk and filesystem usage viewer.
    eza # Colorful, Git-aware `ls` replacement.
    fastfetch # Concise system information summary.
    fd # Fast, user-friendly `find` replacement.
    glow # Render Markdown in the terminal.
    ripgrep # Fast recursive text search used by `rg`.
    starship # Cross-shell prompt configured above.
    stress-ng # CPU, memory, I/O, and scheduler stress tester.
    tealdeer # Fast client for community `tldr` command examples.
    television # Fuzzy-search terminal picker for files and other data sources.
    trash-cli # Move files to the desktop trash instead of deleting immediately.
    ugrep # Fast grep-compatible search with richer output modes.
    uutils-coreutils # Rust implementation of GNU core utilities.
    zoxide # Frecency-based directory jumper configured above.
    duf # Human-readable disk usage overview.
    cowsay # Render messages in speech bubbles from ASCII characters.
    lolcat # Apply rainbow coloring to terminal text.
    tmux # Persistent, multiplexed terminal sessions.
    pciutils # Inspect PCI devices with tools such as `lspci`.
    unzip # Extract and inspect ZIP archives.
    util-linux # Essential Linux administration and block-device utilities.
    e2fsprogs
    p7zip# Inspect and repair ext2/ext3/ext4 filesystems.
  ];
}
