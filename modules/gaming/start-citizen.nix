{ inputs, pkgs, ... }:

{
  nix.settings = {
    extra-substituters = [ "https://nix-citizen.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  environment.systemPackages = [
    (inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher.override {
      extraEnvVars.PULSE_LATENCY_MSEC = "60";
    })
  ];
}
