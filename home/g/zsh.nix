{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    completionInit = ""; # re-evaluating completions adds 2.5 sec to startup time

    cdpath = [ "/home/g/Projects" ];
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      size = 100000000;
    };

    enableAutosuggestions = true;
	syntaxHighlighting.enable = true;

    sessionVariables = {
      NIX_REMOTE = "daemon";
      NIXPKGS_ALLOW_INSECURE = 1;

      GOPATH = "/home/g/go:/home/g/Projects";
      PATH = "$PATH:/home/g/.bin:/home/g/go/bin";
    };

    shellAliases = {
      ssh = "TERM=xterm ssh";
      gmt = "go mod tidy";
      vim = "nvim";
      cd = "z";
    };

    initExtra = ''
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"

      git config --get alias.jr > /dev/null || git config --global alias.jr '!/home/g/.bin/git-jira'

      [ -e /home/g/.rc ] && source /home/g/.rc
    '';
  };
}
