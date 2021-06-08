{ pkgs, ... }:

{
  environment.variables = { EDITOR = "nvim"; };

  environment.systemPackages = with pkgs; [
    nodejs
    yarn
    python-language-server
    (neovim.override {
      vimAlias = true;
      withNodeJs = true;
    })
  ];
}
