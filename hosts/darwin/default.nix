{pkgs, ...}: {
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./system.nix
    ./macos.nix
    #./homebrew.nix
    ./fonts.nix
    #./zsh.nix

    ../../common/dev.nix
  ];

  programs.fish.enable = true;

  services.openssh.enable = true;
  services.karabiner-elements.enable = true;

  environment.systemPackages = with pkgs; [
    #obsidian
    iterm2
    raycast
  ];
}
