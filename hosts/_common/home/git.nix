_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
    ignores = [
      ".envrc"
      ".lefthook"
      ".direnv"
    ];
  };
}
