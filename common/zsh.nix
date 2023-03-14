{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "pip" ];
      theme = "avit";
    };
    shellAliases = { vim = "nvim"; };
  };

  console.font = "latarcyrheb-sun32";
}

