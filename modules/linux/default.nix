{
  imports = [
    ./common.nix
    ./user-defaults.nix
    ./wireless.nix
    ./udev.nix
    ./pipewire.nix

    ./server.nix
    ./battery.nix
    ./proxy.nix

    ./k3s_server.nix
    ./k3s_agent.nix

    ./docker.nix
    ./openssh.nix
    ./steam.nix
    ./heroic.nix

    ./nvidia.nix
    ./intel.nix

    ./hyprland.nix
    ./gnome.nix
    ./gui-apps.nix
    ./qmk.nix

    # native services
    ./zigbee2mqtt.nix
  ];
}
