# yazi terminal file manager. Also the backend for yazi.nvim in nvf.nix.
{
  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;
      # `y` opens yazi and cds the shell into the directory it was quit in.
      enableFishIntegration = true;
      shellWrapperName = "y";
    };
  };
}
