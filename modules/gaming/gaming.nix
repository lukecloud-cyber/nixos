{ pkgs, ... }:

{
  # Load the NT synchronization primitive and tune latency/address-space limits.
  boot = {
    kernelModules = [ "ntsync" ]; # Improve Windows game synchronization under Wine.
    kernel.sysctl = {
      "kernel.sched_cfs_bandwidth_slice_us" = 3000; # Schedule CFS bandwidth in finer slices.
      "net.ipv4.tcp_fin_timeout" = 5; # Reclaim closed TCP connections sooner.
      "vm.max_map_count" = 2147483642; # Accommodate games with many memory mappings.
    };
  };

  # Download gaming packages from their project cache when available.
  nix.settings = {
    extra-substituters = [ "https://nix-gaming.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  programs = {
    # Let games request temporary CPU scheduling and performance tweaks.
    gamemode = {
      enable = true;
      settings.general.renice = 10; # Raise game process priority through GameMode.
    };

    # Install Steam with compatibility and game-session integrations.
    steam = {
      enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin # Community Proton build with extra game compatibility fixes.
      ];
      gamescopeSession.enable = true; # Offer a dedicated Gamescope compositor session.
      remotePlay.openFirewall = true; # Permit Steam Remote Play traffic.
      localNetworkGameTransfers.openFirewall = true; # Share game files with LAN peers.
    };
  };

  # Give logged-in desktop users access to the ntsync device.
  services.udev.extraRules = ''
    KERNEL=="ntsync", MODE="0660", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    heroic # Launcher for Epic, GOG, and Amazon game libraries.
    # moonlight-qt # GameStream client; currently disabled.
    steamtinkerlaunch # Wrapper for configuring tools such as MangoHud and mod managers.
  ];
}
