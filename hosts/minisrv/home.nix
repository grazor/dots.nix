_: {
  home.stateVersion = "24.11";

  home.sessionVariables.EDITOR = "nvim";

  imports = [
    ../_common/home/fish.nix
    ../_common/home/scripts.nix
    ../_common/home/git.nix
  ];
}
