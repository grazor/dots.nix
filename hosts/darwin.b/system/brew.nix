_: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      autoUpdate = true;
      upgrade = true;
    };

    brews = ["syncthing"];
    casks = ["obsidian"];
  };
}
