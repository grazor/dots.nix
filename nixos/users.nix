{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  users.users.g = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "network" "uucp" "dialout" "networkmanager" "docker" "audio" "video" "input" "sway" ];
    useDefaultShell = true;
  };

  nix.trustedUsers = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [ xdg-user-dirs ];
}
