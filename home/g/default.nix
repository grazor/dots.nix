{ pkgs, ... }:

{
  imports =
    [ ./sway ./i3.nix ./termite.nix ./nvim.nix ./bin.nix ./assets.nix ./zsh.nix ./lefthook.nix ./dev.nix ./hyprland ];

  # https://github.com/NixOS/nixpkgs/issues/196651
  # todo: remove workaround
  manual.manpages.enable = false;

  home.stateVersion = "22.11";
}
