{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "pip" ];
    theme = "agnoster";
  };
  programs.zsh.shellAliases = { vim = "nvim"; };
  console.font = "latarcyrheb-sun32";
}
