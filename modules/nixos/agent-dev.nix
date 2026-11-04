# Workspace tools; language toolchains belong in project dev shells.
{
  flake.modules.nixos.agent-dev = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gh
      openspec
      kubectl
      kubernetes-helm
      kustomize
      sops
      age
      yq-go
      rsync
      btop
      lsof
      strace
      nix-output-monitor
      nix-inspect
      alejandra
      statix
      deadnix
    ];

    programs.nix-ld.enable = true;

    fonts = {
      fontconfig.enable = true;
      packages = with pkgs; [dejavu_fonts noto-fonts noto-fonts-color-emoji];
    };

    networking.firewall.enable = true;
    services.openssh.settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
