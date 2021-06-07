{ pkgs, ... }:

{
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
