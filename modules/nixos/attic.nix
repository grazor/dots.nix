# Private Nix binary cache (Attic at nix.porivaev.ru, deployed from the
# homelab repo, apps/attic). Every host pulls from it with a read token in the
# daemon's netrc and pushes whatever it builds through `attic watch-store`, so
# unfree builds cache.nixos.org never carries (the desktop's NVIDIA module)
# and aarch64 builds for the rpi4b are compiled once.
#
# Tokens live in secrets/attic.yaml; mint new ones per apps/attic/README.md.
{
  flake.modules.nixos.attic = {
    config,
    pkgs,
    ...
  }: let
    server = "https://nix.porivaev.ru/";
    cache = "main";
  in {
    sops.secrets = {
      # `machine nix.porivaev.ru` + `password <hosts-pull token>`.
      attic-netrc.sopsFile = ../../secrets/attic.yaml;
      attic-push-token.sopsFile = ../../secrets/attic.yaml;
    };

    nix.settings = {
      extra-substituters = ["${server}${cache}"];
      extra-trusted-public-keys = ["main:uuCQvn17hvSIJN4L/FVngejRLhxhtJ77HC2tex/NP/E="];
      netrc-file = config.sops.secrets.attic-netrc.path;
    };

    # Pushes every path that lands in the local store. Paths signed by
    # cache.nixos.org are skipped by the client, so only local builds upload.
    systemd.services.attic-watch-store = {
      description = "Push new store paths to the Attic cache";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      path = [pkgs.attic-client];
      environment.XDG_CONFIG_HOME = "%S/attic-watch-store";
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "attic-watch-store";
        LoadCredential = "token:${config.sops.secrets.attic-push-token.path}";
        Restart = "always";
        RestartSec = 30;
      };
      script = ''
        attic login --set-default homelab ${server} "$(< "$CREDENTIALS_DIRECTORY/token")"
        exec attic watch-store homelab:${cache}
      '';
    };
  };
}
