{ ... }:

{
  imports = [ ./sway.nix ./nvim.nix ];

  programs.mako.enable = true;
  programs.mako.anchor = "top-right";
}
