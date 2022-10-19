{ pkgs, ... }:

{
  imports = [ ./sway.nix ./i3.nix ./termite.nix ./nvim.nix ./bin.nix ./zsh.nix ./lefthook.nix ];

  home.stateVersion = "22.11";
  #home.packages = with pkgs; [ ];
}
