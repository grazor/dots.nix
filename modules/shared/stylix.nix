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

    home-manager.sharedModules = [
      ({
        config,
        lib,
        options,
        ...
      }: {
        stylix.targets = {
          # rofi is unused, and stylix's rofi target still sets the renamed
          # `programs.rofi.font`, which warns on every eval.
          rofi.enable = false;

          # On GNOME stylix's HM qt target copies `platform = "gnome"` from
          # NixOS, then warns it's unsupported and sets the deprecated
          # `qt.platformTheme.name = "gnome"`. The NixOS qt target already
          # themes Qt system-wide (gnome + adwaita-dark), so the HM one is
          # redundant.
          qt.enable = false;

          # stylix's nvf target sets the renamed `vim.statusline.lualine.theme`;
          # the base16 theme is set below under the new option path instead.
          nvf.enable = false;
        };

        programs = lib.optionalAttrs (options.programs ? nvf) {
          nvf.settings.vim = {
            theme = {
              enable = true;
              name = "base16";
              base16-colors = {
                inherit
                  (config.lib.stylix.colors.withHashtag)
                  base00
                  base01
                  base02
                  base03
                  base04
                  base05
                  base06
                  base07
                  base08
                  base09
                  base0A
                  base0B
                  base0C
                  base0D
                  base0E
                  base0F
                  ;
              };
            };
            statusline.lualine.setupOpts.options.theme = "base16";
          };
        };
      })
    ];
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
