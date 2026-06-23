# Stylix system-wide theming, shared by the desktop (NixOS) and mac (darwin).
{inputs, ...}: let
  # base16 theme applied on every platform; stylix's home-manager autoImport
  # then themes the HM programs (fish, tmux, neovim/nvf, fzf, starship, ...).
  settings = {pkgs, ...}: {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
      # We track stylix master, so skip the version-match warning vs nixos/darwin.
      enableReleaseChecks = false;

      fonts = {
        # Reuse the Nerd Fonts from modules/shared/fonts.nix.
        monospace = {
          package = pkgs.nerd-fonts.sauce-code-pro;
          name = "SauceCodePro Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.hack;
          name = "Hack Nerd Font";
        };
      };
    };
  };
in {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.stylix = {config, ...}: {
    imports = [inputs.stylix.nixosModules.stylix settings];

    # stylix's kmscon target sets `services.kmscon.config`, which this nixpkgs
    # doesn't have (it's `extraConfig`); drop the module (kmscon unused).
    disabledModules = ["${inputs.stylix}/modules/kmscon/nixos.nix"];

    # Solid-colour wallpaper from the scheme background, so no image file is
    # needed. Swap for a real path (e.g. ./data/wallpaper.png) when wanted.
    stylix.image = config.lib.stylix.pixel "base00";
  };

  # macOS: no wallpaper/console targets — just the shared theme, plus the
  # home-manager autoImport that themes fish/tmux/neovim/fzf/starship.
  flake.modules.darwin.stylix = {
    imports = [inputs.stylix.darwinModules.stylix settings];
  };
}
