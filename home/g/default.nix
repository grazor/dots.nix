{ pkgs, ... }:

{
  imports = [ ./sway.nix ./i3.nix ./termite.nix ./nvim.nix ./bin.nix ./zsh.nix ./tmux.nix ];

  home.packages = with pkgs; [ zoxide direnv obsidian brightnessctl ripgrep zoom-us ];
}
