{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
  opt = "k3sServer";

  my-kubernetes-helm = with pkgs;
    wrapHelm kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
        helm-diff
        helm-s3
        helm-git
      ];
    };

  my-helmfile = pkgs.helmfile-wrapped.override {
    inherit (my-kubernetes-helm) pluginsDir;
  };
in {
  options.grazor.linux.${opt} = lib.mkEnableOption "with k3s server";
  config = lib.mkIf cfg.${opt} {
    environment.systemPackages = [pkgs.nfs-utils my-kubernetes-helm my-helmfile];
    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };

    #networking.firewall.allowedTCPPorts = [
    #6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    #];
    #networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
    #];

    services.k3s = {
      enable = true;
      role = "server";
      #extraFlags = toString [
      # "--debug" # Optionally add additional args to k3s
      #];

      # multi-node server node
      #token = "<randomized common secret>";

      # server
      #clusterInit = true;

      # agent
      #serverAddr = "https://<ip of first node>:6443";
    };
  };
}
