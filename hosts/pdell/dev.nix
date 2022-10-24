{ pkgs, ... }:

{
  programs.adb.enable = false;

  environment.systemPackages = with pkgs; [
    python3

    file
    git
    jq
    gnumake
    ripgrep

    slack
    tdesktop
    zoom-us
    obsidian

    #watson
  ];
}
