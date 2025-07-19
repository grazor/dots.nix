{config, ...}: let
  inherit (config.grazor) user;
in {
  imports = [
    ./git.nix
    ./fish.nix
    ./tmux.nix
    ./scripts.nix
    ./ghostty.nix
    ./hyprland.nix
  ];

  users = {
    users.${user.name} = {
      inherit (user) uid home shell;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${user.name}.home.stateVersion = "25.05";
  };
}
