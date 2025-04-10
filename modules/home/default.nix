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

  users = {
    knownUsers = [user.name];
    users.${user.name} = {
      inherit (user) uid home shell;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.name}.home.stateVersion = "24.11";
  };
}
