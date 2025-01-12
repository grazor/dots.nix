{ pkgs, ... }:

{
  environment.variables = {
    EDITOR = "nvim";
  };

  # environment.systemPackages = with pkgs; [
  #   neovim
  #   # neovim-nightly
  #   (neovim.override {
  #     vimAlias = true;
  #     withNodeJs = true;
  #   })
  # ];
}
