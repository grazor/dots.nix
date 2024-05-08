{ pkgs, ... }:

{
  imports = [ ./common ];

  time.timeZone = "Europe/Moscow";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  nix = {
    gc.automatic = true;
    settings.sandbox = true;
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "22.11";
}
