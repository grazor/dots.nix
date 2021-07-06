{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    cdpath = "/home/g/Projects";

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    sessionVariables = {
      NIX_REMOTE = "daemon";
    };

    ohMyZshModule = {
      enable = true;
      theme = "agnoster";
    };
  };
}
