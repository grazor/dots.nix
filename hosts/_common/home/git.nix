_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Sergey Poryvaev";
    userEmail = "porivaevs@gmail.com";
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
