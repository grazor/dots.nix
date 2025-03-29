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
  (import ./system inputs)
  #(import ./services inputs)
  (import ../_common/system/authorized-keys.nix {username = user.name;})
  {
    networking.hostName = "dell";
    system.stateVersion = "24.11";
  }

  {
    programs.fish.enable = true;
    environment.systemPackages = [
      (import ../_common/packages/nvf.nix {inherit pkgs nvf;})
      #(import ../_common/packages/fleeting-chat.nix {inherit pkgs;})
    ];
  }

  (import ./user.nix {inherit user pkgs;})
  home-manager.nixosModules.home-manager
  {
    users = {
      users.${user.name} = {inherit (user) uid home shell;};
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user.name} = import ./home.nix {inherit user pkgs;};
    };
  }
]
