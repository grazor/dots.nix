{
  imports = [
    ./common.nix
    ./docker.nix
    ./openssh.nix
    ./pipewire.nix
    ./server.nix
    ./udev.nix
    ./user-defaults.nix
    ./wireless.nix

    ./nvidia.nix
    ./intel.nix

    ./hyprland.nix
    ./gnome.nix
    ./gui-apps.nix
  ];
}
