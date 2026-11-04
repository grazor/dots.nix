# Persistent Incus development container.
{
  config,
  mkNixos,
  ...
}: {
  flake.nixosConfigurations.dev = mkNixos {
    aspects = m:
      with m; [
        base
        lxc-guest
        ssh-server
        tools
        devtools
        agent-dev
        user-cloud
      ];

    machine = {lib, ...}: {
      system.stateVersion = "26.05";

      systemd.network.networks."50-eth0" = {
        networkConfig.DHCP = lib.mkForce "no";
        address = ["192.168.2.64/24"];
        gateway = ["192.168.2.1"];
        dns = ["192.168.2.1"];
      };

      nix.settings = {
        max-jobs = lib.mkDefault 2;
        cores = lib.mkDefault 4;
      };

      users.users.cloud.linger = true;
      home-manager.users.cloud.imports = with config.flake.modules.homeManager; [
        agent-dev
        codex-dev
      ];
    };
  };
}
