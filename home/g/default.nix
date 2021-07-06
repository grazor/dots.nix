{ pkgs, ... }:

{
  imports = [ ./sway.nix ./termite.nix ./nvim.nix ./bin.nix ./zsh.nix ];

  home.packages = with pkgs;
    [
      #watson # time tracker
    ];
}
