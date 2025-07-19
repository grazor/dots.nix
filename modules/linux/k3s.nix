{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
  opt = "k3sServer";
in {
  options.grazor.linux.${opt} = lib.mkEnableOption "with k3s server";
  config = lib.mkIf cfg.${opt} {
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
    environment.systemPackages = with pkgs; [kubernetes-helm];
  };
}
