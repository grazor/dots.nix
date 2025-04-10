{config, ...}: let
  inherit (config.grazor) user;
in {
  imports = [
    ./brew.nix
    ./sudo.nix
    ./common.nix
  ];

  users = {
    knownUsers = [user.name];
  };
}
