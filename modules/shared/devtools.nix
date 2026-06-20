# Developer tooling, shared by NixOS and nix-darwin.
let
  packages = pkgs:
    with pkgs; [
      python3
      shfmt
      shellcheck

      file
      git
      jq
      gnumake
      ripgrep
      jira-cli-go

      k9s
      fluxcd
    ];
  aspect = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
in {
  flake.modules.nixos.devtools = aspect;
  flake.modules.darwin.devtools = aspect;
}
