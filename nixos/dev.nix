{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    python3

    file
    git
    jq
    gnumake
    ripgrep
  ];
}
