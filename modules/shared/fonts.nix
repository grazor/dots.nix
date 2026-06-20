# Fonts, shared by NixOS and nix-darwin.
let
  aspect = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
    ];
  };
in {
  flake.modules.nixos.fonts = aspect;
  flake.modules.darwin.fonts = aspect;
}
