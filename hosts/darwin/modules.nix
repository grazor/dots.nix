inputs @ {
  home-manager,
  pkgs,
  nvf,
  ...
}: let
  user = rec {
    uid = 501;
    user = "smporyvaev";
    home = "/Users/${user}";
    shell = pkgs.fish;
  };
in [
  (import ./system {inherit inputs;})

  {
    environment.systemPackages = [
      (import ../_common/packages/nvf.nix {inherit pkgs nvf;})
    ];
  }

  home-manager.darwinModules.home-manager
  {
    users = {
      knownUsers = [user.user];
      users.${user.user} = {
        inherit (user) uid home shell;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user.user} = import ./home.nix {inherit user pkgs;};
    };
  }
]
