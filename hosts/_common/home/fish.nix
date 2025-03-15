{shellInitLast ? []}: {
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat";
        gmt = "go mod tidy";
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
