{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

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

