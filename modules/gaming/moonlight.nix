{ pkgs, ... }:

{
  # Install the Moonlight client for connecting to Sunshine game-streaming hosts.
  environment.systemPackages = [
    pkgs.moonlight-qt # Qt desktop client for Sunshine game streams.
  ];
}
