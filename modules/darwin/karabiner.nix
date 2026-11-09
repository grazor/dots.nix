# Restore the checked-in keyboard/mouse configuration on every Mac rebuild.
{
  flake.modules.homeManager.karabiner = {
    config,
    lib,
    pkgs,
    ...
  }: let
    source = ./data/karabiner.json;
    target = "${config.xdg.configHome}/karabiner/karabiner.json";
  in {
    # Karabiner needs a real, user-owned file to watch and rewrite. A Nix-store
    # symlink for karabiner.json prevents it from noticing configuration changes.
    home.activation.karabinerConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      karabiner_target=${lib.escapeShellArg target}
      run ${pkgs.coreutils}/bin/install -d -m 700 "$(dirname "$karabiner_target")"
      if ! ${pkgs.diffutils}/bin/cmp -s ${source} "$karabiner_target"; then
        if [ -e "$karabiner_target" ] && [ ! -e "$karabiner_target.before-dots" ]; then
          run ${pkgs.coreutils}/bin/cp -p "$karabiner_target" "$karabiner_target.before-dots"
        fi
        run ${pkgs.coreutils}/bin/install -m 600 ${source} "$karabiner_target"
      fi
    '';
  };
}
