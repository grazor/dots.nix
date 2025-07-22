{
  lib,
  config,
  ...
}: let
  cfg = config.grazor;
  username = cfg.user.name;
in {
  options.grazor.withAuthorizedKeys = lib.mkEnableOption "with authorized keys setup";
  config = lib.mkIf cfg.withAuthorizedKeys {
    users.users.${username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEs9zEKgXOgoUr9thW7WsoBnPU3cVTSYsdfdMknmf7PG emerg"

      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn5dz1yRCugoCCeQbLIL8GJ36e7vlv48bPQ6dem0myc deskw"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJLUzThrMDq7aDnSB3gQzpd8RVI5jwghcxh/11dgsYW deskn"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDW3nxkH6KTgkDKyI9tgc9yhSPlruzSiIxXBnS4A6JY work"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEcA3dCkiqDQtsoP0MicTylt6rQCntGf6XeWif0TecA cloud"
    ];
  };
}
