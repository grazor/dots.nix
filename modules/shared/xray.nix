# Portable VPN: every host runs its own xray client, an HTTP proxy on :9998
# (all interfaces, unauthenticated) whose only outbound is the VLESS server.
# The config is secrets/xray.bin, the whole xray JSON as one sops blob;
# replace it with:
#   sops encrypt --filename-override secrets/xray.bin \
#     --input-type binary --output-type binary config.json > secrets/xray.bin
# The firewall keeps :9998 host-local, except on hosts with the `proxy` aspect.
let
  sopsFile = ../../secrets/xray.bin;
  port = 9998;
  proxy = "http://127.0.0.1:${toString port}";
  proxyEnvironment = {
    all_proxy = proxy;
    http_proxy = proxy;
    https_proxy = proxy;
    # Keep loopback, the Attic cache, and the home LAN direct.
    no_proxy = "localhost,127.0.0.1,::1,.porivaev.ru,192.168.0.0/16";
  };
in {
  flake.modules.nixos.xray = {config, ...}: {
    sops.secrets.xray = {
      inherit sopsFile;
      format = "binary";
      restartUnits = ["xray.service"];
    };

    services.xray = {
      enable = true;
      settingsFile = config.sops.secrets.xray.path;
    };

    # Substitutes and fixed-output fetches inherit these variables and are
    # several times faster than the direct route. Flake inputs are fetched
    # by the client and do not inherit the unit's environment.
    # Set on the unit, not through nix.envVars: nixpkgs also exports those as
    # session variables, which put every login shell and browser on the proxy.
    systemd.services.nix-daemon.environment = proxyEnvironment;
    home-manager.extraSpecialArgs.xrayProxyEnvironment = proxyEnvironment;
  };

  flake.modules.darwin.xray = {
    config,
    pkgs,
    ...
  }: let
    user = config.system.primaryUser;
  in {
    home-manager.extraSpecialArgs.xrayProxyEnvironment = proxyEnvironment;

    # No host SSH key to derive from: the mac decrypts with the admin key.
    sops.age.keyFile = "/Users/${user}/.config/sops/age/keys.txt";
    sops.secrets.xray = {
      inherit sopsFile;
      format = "binary";
      name = "xray.json";
      owner = user;
    };

    launchd.user.agents.xray.serviceConfig = {
      ProgramArguments = [
        "${pkgs.xray}/bin/xray"
        "run"
        "-format"
        "json"
        "-c"
        config.sops.secrets.xray.path
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/xray.log";
    };
  };
}
