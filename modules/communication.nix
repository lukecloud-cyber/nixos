{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.discord # Desktop voice, video, and text chat client.
  ];
}
