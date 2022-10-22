{ pkgs, ... }:

{
  imports = [ ./sway.nix ./i3.nix ./termite.nix ./nvim.nix ./bin.nix ./zsh.nix ./lefthook.nix ];

  # https://github.com/NixOS/nixpkgs/issues/196651
  # todo: remove workaround
  manual.manpages.enable = false;

  home.stateVersion = "22.11";
  #home.packages = with pkgs; [ ];
}
