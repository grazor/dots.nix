{pkgs, ...}: {
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--registry-mirror=https://mirror.gcr.io";

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
