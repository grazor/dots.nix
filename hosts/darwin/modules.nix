{
  home-manager,
  nvf,
  pkgs,
  ...
}: let
  uid = 501;
  username = "smporyvaev";
  home = "/Users/${username}";
in [
  (import ./system {inherit pkgs nvf;})
  home-manager.darwinModules.home-manager
  {
    users = {
      knownUsers = [username];
      users.${username} = {
        inherit uid home;
        shell = pkgs.fish;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${username} = import ./user.nix {inherit username home pkgs;};
    };
  }
]
