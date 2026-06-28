# Per-user aspects: each creates the system account and wires up the user's
# home-manager profile by composing homeManager aspects. The username maps 1:1
# to a device role, so the account identity lives here rather than in flags.
{config, ...}: let
  hm = config.flake.modules.homeManager;

  linuxGroups = [
    "wheel"
    "network"
    "uucp"
    "dialout"
    "networkmanager"
    "docker"
    "audio"
    "video"
    "input"
    "sway"
    "uinput"
  ];

  # SSH public keys authorized for the primary user on every host.
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEs9zEKgXOgoUr9thW7WsoBnPU3cVTSYsdfdMknmf7PG emerg"

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn5dz1yRCugoCCeQbLIL8GJ36e7vlv48bPQ6dem0myc deskw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJLUzThrMDq7aDnSB3gQzpd8RVI5jwghcxh/11dgsYW deskn"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDW3nxkH6KTgkDKyI9tgc9yhSPlruzSiIxXBnS4A6JY work"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEcA3dCkiqDQtsoP0MicTylt6rQCntGf6XeWif0TecA cloud"
  ];
in {
  flake.modules.nixos = {
    # cloud — homelab nodes (Dell, Asus): no GUI, no tmux autostart.
    user-cloud = {pkgs, ...}: {
      users.users.cloud = {
        uid = 1000;
        isNormalUser = true;
        home = "/home/cloud";
        shell = pkgs.fish;
        extraGroups = linuxGroups;
        openssh.authorizedKeys.keys = authorizedKeys;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.cloud = {
          home.stateVersion = "25.05";
          imports = with hm; [fish tmux git scripts nvf nix-index];
        };
      };
    };

    # pi — lightweight service nodes: SSH + sudo, no home-manager profile.
    user-pi = {pkgs, ...}: {
      users.users.pi = {
        uid = 1000;
        isNormalUser = true;
        home = "/home/pi";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "network"
          "networkmanager"
          "dialout"
          "uucp"
        ];
        openssh.authorizedKeys.keys = authorizedKeys;
      };
    };

    # g — desktop workstation: tmux autostart on login.
    user-g = {pkgs, ...}: {
      users.users.g = {
        uid = 1000;
        isNormalUser = true;
        home = "/home/g";
        shell = pkgs.fish;
        extraGroups = linuxGroups;
        openssh.authorizedKeys.keys = authorizedKeys;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.g = {
          home.stateVersion = "25.05";
          imports = with hm; [fish tmux tmux-autostart git scripts nvf nix-index];
        };
      };
    };
  };
}
