# Keep the workstation SSH host mappings encrypted, including their addresses.
{config, ...}: let
  sshHome = config.flake.modules.homeManager.ssh-client;
  sopsFile = ../../secrets/ssh-config.bin;
in {
  flake.modules.homeManager.ssh-client = {
    config,
    lib,
    pkgs,
    osConfig,
    ...
  }: {
    # Only the runtime path enters the Nix store, never the decrypted hosts.
    # Leave the rest of an existing, manually maintained config intact.
    home.activation.privateSshHosts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.python3}/bin/python3 ${./data/ssh-include.py} \
        ${lib.escapeShellArg "${config.home.homeDirectory}/.ssh/config"} \
        ${lib.escapeShellArg osConfig.sops.secrets.ssh-config.path}
    '';
  };

  flake.modules.nixos.ssh-client = {
    sops.secrets.ssh-config = {
      inherit sopsFile;
      format = "binary";
      owner = "g";
      mode = "0600";
    };
    home-manager.sharedModules = [sshHome];
  };

  flake.modules.darwin.ssh-client = {config, ...}: let
    user = config.system.primaryUser;
  in {
    sops.age.keyFile = "/Users/${user}/.config/sops/age/keys.txt";
    sops.secrets.ssh-config = {
      inherit sopsFile;
      format = "binary";
      owner = user;
      mode = "0600";
    };
    home-manager.sharedModules = [sshHome];
  };
}
