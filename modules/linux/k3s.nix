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
