{
  imports = [
    ./common.nix
    ./user-defaults.nix
    ./wireless.nix
    ./udev.nix
    ./pipewire.nix

    ./server.nix
    ./battery.nix
    ./k3s.nix

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
