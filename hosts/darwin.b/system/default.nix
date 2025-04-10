{pkgs, ...}: {
  imports = [
    ./system.nix
    ./macos.nix
    ./work.nix

    ./brew.nix

    ../../_common/system/nix.nix
    ../../_common/system/tools.nix
    ../../_common/system/fonts.nix
    ../../_common/system/devtools.nix
  ];

  # TODO:
  # - tmux
  # - import local.rc
  # - link apps
  # - fish project cd script
  #services.syncthing.enable = true;

  environment.systemPackages = [pkgs.xray];
  launchd.user.agents.xray = {
    command = "${pkgs.xray}/bin/xray";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  services.openssh.enable = true;
  programs.fish.enable = true;
}
