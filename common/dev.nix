{ pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--registry-mirror=https://mirror.gcr.io";

  environment.systemPackages = with pkgs; [
    glibc.out
    python3
    shfmt
    shellcheck

    docker-compose
    file
    git
    jq
    gnumake
    ripgrep
  ];
}
