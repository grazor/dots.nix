{
  imports = [
    ./common.nix
    ./user-defaults.nix
    ./wireless.nix
    ./udev.nix
    ./server.nix
    ./pipewire.nix

    ./docker.nix
    ./openssh.nix
    ./steam.nix

    ./nvidia.nix
    ./intel.nix

    ./hyprland.nix
    ./gnome.nix
    ./gui-apps.nix
  ];
}
