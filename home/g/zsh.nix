{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    cdpath = "/home/g/Projects";

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
      PATH = "$PATH:/home/g/go/bin";
    };

    shellAliases = {
      ssh = "TERM=xterm ssh";
      gmt = "go mod tidy";
      vim = "nvim";
    };

    plugins = {
      ohMyZshModule = {
        enable = true;
        theme = "agnoster";
      };
    };

    initExtra = ''
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
