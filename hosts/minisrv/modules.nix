inputs @ {
  home-manager,
  pkgs,
  nvf,
  ...
}: let
  user = rec {
    uid = 1000;
    name = "cloud";
    home = "/home/${name}";
    shell = pkgs.fish;
  };
in [
  (import ./system {inherit inputs;})
  (import ./services {inherit inputs;})
  (import ../_common/system/authorized-keys.nix {username = user.name;})

  {
    environment.systemPackages = [
      (import ../_common/packages/nvf.nix {inherit pkgs nvf;})
      (import ../_common/packages/fleeting-chat.nix {inherit pkgs;})
    ];
  }

  (import ./user.nix {inherit user pkgs;})
  home-manager.darwinModules.home-manager
  {
    users = {
      knownUsers = [user.name];
      users.${user.name} = {inherit (user) uid home shell;};
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user.name} = import ./home.nix {inherit user pkgs;};
    };
  }
]
