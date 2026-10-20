# labelr: label printing for the Niimbot B21 Pro over Bluetooth LE
# (git.porivaev.ru/porivaev/labelr). Runs the prebuilt aarch64 binary that
# labelr's CI publishes to the Forgejo package registry for each version tag,
# so nothing compiles here. Attach to the host the printer is near; the
# cluster's Traefik proxies label.porivaev.ru to it (homelab apps/labelr).
#
# New release: put its version and the matching `labelr-aarch64-linux.sri`
# into `version` and `hash` below:
#   curl -s https://git.porivaev.ru/api/packages/porivaev/generic/labelr/<version>/labelr-aarch64-linux.sri
{
  flake.modules.nixos.labelr = {
    config,
    lib,
    pkgs,
    ...
  }: let
    port = 8081; # 8080 is the Zigbee2MQTT frontend on rpi4b

    package = pkgs.stdenv.mkDerivation rec {
      pname = "labelr";
      version = "0.2.0";
      src = pkgs.fetchurl {
        url = "https://git.porivaev.ru/api/packages/porivaev/generic/labelr/${version}/labelr-aarch64-linux";
        hash = "sha256-XdBt/WVGpvKXQl7eVv/RQ/SHER+ZadM7h6VwnyDGktQ=";
      };
      dontUnpack = true;
      # Built on Debian bookworm (glibc 2.36): relink against this system's
      # loader, glibc, libgcc_s and libdbus.
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.dbus pkgs.stdenv.cc.cc.lib];
      installPhase = "install -Dm755 $src $out/bin/labelr";
      meta.mainProgram = "labelr";
    };

    settings = {
      listen = "0.0.0.0:${toString port}";
      public_url = "https://label.porivaev.ru";
      state_dir = "/var/lib/labelr";
      timezone = "Europe/Moscow";
      printer = {
        kind = "ble";
        match_name = "B21_PRO";
      };
      labels = {
        sizes = ["50x30" "40x30"];
        default = "50x30";
      };
      # The provider is homelab's authentik blueprint labelr.yaml; its client
      # secret is sealed there and kept here in secrets/labelr.yaml.
      oidc = {
        issuer = "https://auth.porivaev.ru/application/o/labelr/";
        client_id = "labelr";
      };
      homebox.url = "https://homebox.porivaev.ru";
    };
    configFile = (pkgs.formats.toml {}).generate "labelr.toml" settings;

    secrets = {
      LABELR_OIDC__CLIENT_SECRET = "labelr-oidc-client-secret";
      LABELR_HOMEBOX__API_KEY = "labelr-homebox-api-key";
    };
  in {
    sops.secrets = lib.mapAttrs' (_: name:
      lib.nameValuePair name {
        sopsFile = ../../secrets/labelr.yaml;
        restartUnits = ["labelr.service"];
      })
    secrets;

    sops.templates."labelr.env" = {
      owner = "labelr";
      mode = "0400";
      content = lib.concatLines (lib.mapAttrsToList (var: name: "${var}=${config.sops.placeholder.${name}}") secrets);
      restartUnits = ["labelr.service"];
    };

    hardware.bluetooth.enable = true;

    users.users.labelr = {
      isSystemUser = true;
      group = "labelr";
      description = "labelr service";
    };
    users.groups.labelr = {};

    # BlueZ only answers root and listed users on the system bus.
    services.dbus.packages = [
      (pkgs.writeTextDir "share/dbus-1/system.d/labelr-bluez.conf" ''
        <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
          "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy user="labelr">
            <allow send_destination="org.bluez"/>
            <allow send_interface="org.freedesktop.DBus.ObjectManager"/>
            <allow send_interface="org.freedesktop.DBus.Properties"/>
          </policy>
        </busconfig>
      '')
    ];

    networking.firewall.allowedTCPPorts = [port];

    environment.systemPackages = [package];

    systemd.services.labelr = {
      description = "labelr label printing service";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target" "bluetooth.service"];
      after = ["network-online.target" "bluetooth.service"];
      environment.RUST_LOG = "labelr=info,niimbot=info";
      serviceConfig = {
        ExecStart = "${lib.getExe package} serve --config ${configFile}";
        User = "labelr";
        Group = "labelr";
        StateDirectory = "labelr";
        EnvironmentFile = config.sops.templates."labelr.env".path;
        Restart = "on-failure";
        RestartSec = 5;
        # Bluetooth is reached over D-Bus (AF_UNIX), so no AF_BLUETOOTH.
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
      };
    };
  };
}
