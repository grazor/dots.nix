inputs: {
  home.stateVersion = "24.11";

  home.sessionVariables.EDITOR = "nvim";

  imports = [
    (import ../_common/home/fish.nix (inputs
      // {
        tmuxIntegration = true;
      }))
    (import ../_common/home/ghostty.nix {package = null;})
    ../_common/home/tmux.nix
    ../_common/home/scripts.nix
    ../_common/home/git.nix
  ];
}
