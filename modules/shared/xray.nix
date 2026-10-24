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

    # Only the nix daemon goes through it: substitutes from cache.nixos.org
    # and fixed-output fetches (which inherit these variables) are several
    # times faster than the direct route. The rest of the host stays direct,
    # and flake input fetches run in the client, so they are not covered.
    nix.envVars = let
      proxy = "http://127.0.0.1:${toString port}";
    in {
      all_proxy = proxy;
      http_proxy = proxy;
      https_proxy = proxy;
      # The Attic cache and anything else at home stays direct.
      no_proxy = "localhost,127.0.0.1,::1,.porivaev.ru,192.168.0.0/16";
    };
  };

  flake.modules.darwin.xray = {
    config,
    pkgs,
    ...
  }: let
    user = config.system.primaryUser;
  in {
    # No host SSH key to derive from: the mac decrypts with the admin key.
    sops.age.keyFile = "/Users/${user}/.config/sops/age/keys.txt";
    sops.secrets.xray = {
      inherit sopsFile;
      format = "binary";
      owner = user;
    };

    launchd.user.agents.xray.serviceConfig = {
      # The secret has no extension, so the format must be given.
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
