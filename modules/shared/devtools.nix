# Developer tooling, shared by NixOS and nix-darwin.
let
  packages = pkgs:
    with pkgs; [
      python3
      shfmt
      shellcheck

      git
      jq
      gnumake
      ripgrep
      jira-cli-go

      # For the `psql` client; nixpkgs ships no client-only split of this.
      postgresql

      k9s
      fluxcd
    ];
  aspect = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
in {
  flake.modules.nixos.devtools = aspect;
  flake.modules.darwin.devtools = aspect;
}
