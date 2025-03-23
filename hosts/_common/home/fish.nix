{shellInitLast ? ""}: {
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
      sessionVariables = {
        EDITOR = "nvim";
      };
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
