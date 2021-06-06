{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
    }))
  ];

  environment.variables = { EDITOR = "nvim"; };

  environment.systemPackages = with pkgs; [
    nodejs
    yarn
    neovim-nightly
    (neovim.override {
      vimAlias = true;
      withNodeJs = true;
    })
  ];
}
