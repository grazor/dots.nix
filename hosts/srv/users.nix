{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  users.users.cloud = {
    uid = 1100;
    isNormalUser = true;
    extraGroups = [ "network" "uucp" "dialout" "networkmanager" "docker" "audio" "video" "input" ];
    useDefaultShell = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];
  
  users.users.smball = {
    uid = 2000;
    isNormalUser = true;
    extraGroups = [ "smb" ];
    useDefaultShell = false;
  };

  users.groups.smb = {};

  environment.systemPackages = with pkgs; [ xdg-user-dirs ];
}

