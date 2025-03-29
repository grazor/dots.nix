{
  nixpkgs,
  pkgs,
  ...
}: {
  nix = {
	registry.nixpkgs.flake = nixpkgs;
    #package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      nix-path = ["nixpkgs=${nixpkgs.outPath}"];
    };
  };

  environment.systemPackages = with pkgs; [
    direnv
    nh
    patchelf
  ];
}
