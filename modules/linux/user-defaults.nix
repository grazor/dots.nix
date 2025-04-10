{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.grazor) user;
  cfg = config.grazor.linux;
in {
  options.grazor.linux.withUserDefaults = lib.mkEnableOption "with user defaults";
  config = lib.mkIf cfg.withUserDefaults {
    users.defaultUserShell = user.shell;
    users.users.${user.name} = {
      inherit (user) uid name;

      isNormalUser = true;
      extraGroups = [
        "wheel"
        "network"
        "uucp"
        "dialout"
        "networkmanager"
        "docker"
        "audio"
        "video"
        "input"
        "sway"
        "uinput"
      ];
      useDefaultShell = true;
    };

    nix.settings.trusted-users = ["root" "@wheel"];

    environment.systemPackages = with pkgs; [xdg-user-dirs];
  };
}
