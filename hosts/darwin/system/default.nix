{
  pkgs,
  nvf,
  ...
}: {
  imports = [
    ./system.nix
    ./macos.nix

    #./brew.nix

    ../../_common/system/fonts.nix
    ../../_common/system/devtools.nix
  ];

  environment.systemPackages = [(import ../../_common/packages/nvf.nix {inherit pkgs nvf;})];

  services.openssh.enable = true;
  programs.fish.enable = true;
}
