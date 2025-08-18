{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      nix-path = ["nixpkgs=${inputs.nixpkgs.outPath}"];
    };
  };

  environment.systemPackages = with pkgs; [
    direnv
    nh
    patchelf
    nix-inspect
  ];
}
