{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
  };
  environment.shellAliases = {vim = "nvim";};
}
