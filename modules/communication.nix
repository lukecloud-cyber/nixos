{ pkgs, ... }:

{
  # Install desktop communication clients system-wide.
  environment.systemPackages = [
    pkgs.discord # Desktop voice, video, and text chat client.
  ];
}
