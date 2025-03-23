{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-buildx
    docker-compose
    docker-credential-helpers

    qemu

    src-cli
  ];
}
