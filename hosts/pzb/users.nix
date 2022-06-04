{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  users.users.cloud = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "network" "uucp" "dialout" "networkmanager" "docker" "audio" "video" "input" ];
    useDefaultShell = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [ xdg-user-dirs ];
}

