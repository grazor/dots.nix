{
  config,
  pkgs,
  ...
}: {
  home.username = "smporyvaev";
  home.homeDirectory = "/Users/smporyvaev";
  home.stateVersion = "24.11";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo" "docker" "pip"];
      theme = "avit";
    };
    shellAliases = {vim = "nvim";};
  };
}
