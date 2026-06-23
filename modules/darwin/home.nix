# Work MacBook user (smporyvaev): account + home-manager profile.
{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  flake.modules.darwin.user-smporyvaev = {pkgs, ...}: {
    users.knownUsers = ["smporyvaev"];
    users.users.smporyvaev = {
      uid = 501;
      home = "/Users/smporyvaev";
      shell = pkgs.fish;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.smporyvaev = {
        home.stateVersion = "25.05";
        imports = with hm; [fish tmux tmux-autostart git scripts nvf nix-index];
      };
    };
  };
}
