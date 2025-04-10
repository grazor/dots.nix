_: {
  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = 6;
}
