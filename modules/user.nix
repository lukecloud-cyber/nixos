{ pkgs, ... }:

{
  users.users."sweet_cicero" = {
    isNormalUser = true;
    description = "sweet_cicero";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}
