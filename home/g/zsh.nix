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
      size = 1000000;
    };

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

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
      ls = "exa";
      cd = "z";
    };

    initExtra = ''
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      compdef _watson watson

      watsonpropmt() {
          RPROMPT="$(watson status)"
      }

      if [ ! -z "$SCRATCHTERM" ]; then
          precmd() {
              watsonpropmt;
          }
      fi
    '';
  };
}
