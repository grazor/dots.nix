{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    #"--disable=traefik"
    "--service-node-port-range=1-65535"
  ];

  virtualisation.containerd = {
    enable = true;
    settings = {
      disabled_plugins = ["io.containerd.grpc.v1.cri" "io.containerd.snapshotter.v1"];
    };
  };

  environment.systemPackages = [ pkgs.k3s ];
}
