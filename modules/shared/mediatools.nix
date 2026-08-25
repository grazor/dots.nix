# Audio/video/image processing CLIs, shared by NixOS and nix-darwin. Split out
# of `tools` because these are large closures that headless service nodes (e.g.
# rpi4b) have no use for.
let
  packages = pkgs:
    with pkgs; [
      ffmpeg
      gifsicle
    ];
  aspect = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
in {
  flake.modules.nixos.mediatools = aspect;
  flake.modules.darwin.mediatools = aspect;
}
