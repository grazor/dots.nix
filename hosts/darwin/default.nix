{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.vim
  ];

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
