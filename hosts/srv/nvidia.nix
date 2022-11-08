{ pkgs, ... }:

{
  hardware.opengl.enable = true;

  boot.kernelModules = [ "nvidia" ];
  boot.kernelParams = [ "module_blacklist=i915" ];
  
  virtualisation.docker.enableNvidia = true;
}

