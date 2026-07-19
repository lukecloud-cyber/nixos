{ inputs, pkgs, ... }:

{
  boot = {
    kernelModules = [ "ntsync" ];
    kernel.sysctl = {
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "net.ipv4.tcp_fin_timeout" = 5;
      "vm.max_map_count" = 2147483642;
    };
  };

  nix.settings = {
    extra-substituters = [
      "https://nix-gaming.cachix.org"
      "https://nix-citizen.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  programs = {
    gamemode = {
      enable = true;
      settings.general.renice = 10;
    };

    steam = {
      enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  services.udev.extraRules = ''
    KERNEL=="ntsync", MODE="0660", TAG+="uaccess"
  '';

  services.sunshine = {
    enable = true;
    openFirewall = false;
  };

  environment.systemPackages = with pkgs; [
    heroic
   # moonlight-qt
    (inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher.override {
        extraEnvVars.PULSE_LATENCY_MSEC = "60";
      })
  ];
}
