{
  tmuxIntegration ? false,
  pkgs,
  ...
}: let
  shellUserImport = ''
    [ -e ~/.fish.user.rc ] && source ~/.fish.user.rc
  '';

  shellInitLast =
    shellUserImport
    + (
      if tmuxIntegration
      then ''
        [ -z "$TMUX" ] && tmux new-session -A -s main
      ''
      else ""
    );
in {
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat";
      };
      shellAbbrs = {
        gst = "git status";
        gmt = "go mod tidy";
      };

      interactiveShellInit = ''
        set fish_greeting
      '';
      inherit shellInitLast;
    };

    bat.enable = true;

    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--disable-up-arrow"];
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
