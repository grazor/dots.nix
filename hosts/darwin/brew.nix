{
  # TODO:
  # move to modules
  # add ghostty option
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
