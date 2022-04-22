{ pkgs, ... }:

{
  imports = [ ./sway.nix ./i3.nix ./termite.nix ./nvim.nix ./bin.nix ./zsh.nix ./lefthook.nix ];

  #home.packages = with pkgs; [ ];
}
