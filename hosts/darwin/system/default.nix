_: {
  imports = [
    ./system.nix
    ./macos.nix
    ./work.nix

    ./brew.nix

    ../../_common/system/nix.nix
    ../../_common/system/fonts.nix
    ../../_common/system/devtools.nix
  ];

  services.openssh.enable = true;
  programs.fish.enable = true;
}
