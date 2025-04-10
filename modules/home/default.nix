{config, ...}: let
  inherit (config.grazor) user;
in {
  imports = [
    ./git.nix
    ./fish.nix
    ./tmux.nix
    ./scripts.nix
    ./ghostty.nix
  ];

  home.stateVersion = "24.11";

  users = {
    knownUsers = [user.name];
    users.${user.name} = {
      inherit (user) uid home shell;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
