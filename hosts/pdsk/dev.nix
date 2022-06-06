{ pkgs, ... }:

{
  programs.adb.enable = true;

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
