{ inputs, pkgs, ... }:

{
  # Trust nix-citizen's cache so the launcher and patched dependencies stay prebuilt.
  nix.settings = {
    extra-substituters = [ "https://nix-citizen.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  # Install the RSI launcher and raise PulseAudio latency to prevent audio dropouts.
  environment.systemPackages = [
    (inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher.override {
      extraEnvVars.PULSE_LATENCY_MSEC = "60";
    })
  ];
}
