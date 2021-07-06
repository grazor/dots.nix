{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    cdpath = "/home/g/Projects";
    theme = "agnoster";

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    sessionVariables = {
      NIX_REMOTE = "daemon";
    };
  };
}
