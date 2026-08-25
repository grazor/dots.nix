# Extra CLI utilities, shared by NixOS and nix-darwin.
let
  packages = pkgs:
    with pkgs; [
      inetutils
      netcat
      curl

      file
      tree
      unar
      unzip

      ncdu
      dua

      tig
      glow
    ];
  aspect = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
in {
  flake.modules.nixos.tools = aspect;
  flake.modules.darwin.tools = aspect;
}
