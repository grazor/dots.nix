inputs @ {
  home-manager,
  pkgs,
  nvf,
  ...
}: let
  user = rec {
    uid = 501;
    name = "smporyvaev";
    home = "/Users/${name}";
    shell = pkgs.fish;
  };
in [
  (import ./system {inherit inputs;})
  (import ../_common/system/authorized-keys.nix {username = user.name;})

  {
    environment.systemPackages = [
      (import ../_common/packages/nvf.nix {inherit pkgs nvf;})
    ];
  }

  home-manager.darwinModules.home-manager
  {
    users = {
      knownUsers = [user.name];
      users.${user.name} = {
        inherit (user) uid home shell;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user.name} = import ./home.nix {inherit user pkgs;};
    };
  }
]
