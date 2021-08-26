{ pkgs, ... }:

{
  programs.adb.enable = true;
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    python3

    file
    git
    jq
    gnumake

    obsidian

    slack
    tdesktop

    #watson
  ];
}
