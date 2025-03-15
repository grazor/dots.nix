{pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [lefthook];
  xdg.configFile."lefthook/general.yml".source = ./. + /config/lefthook.general.yml;

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        vim = "nvim";
        cat = "bat";
        gmt = "go mod tidy";
      };
      shellInitLast = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
        fish_add_path -p ~/.bin
        fish_add_path -p ~/.avito/bin
      '';
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
