# Agentic dev workspace: the tools used to drive coding agents and to read back
# what they changed.
#
# Opt-in feature spanning two aspects, both enabled only on the macOS host:
#   - darwin.agent-dev      → OpenSpec CLI (Homebrew), composed in the host's
#                             `aspects` list.
#   - homeManager.agent-dev → diffx + the tmux agent sidebar, imported into the
#                             user's home-manager profile.
{
  # OpenSpec (`openspec` CLI) is installed via Homebrew rather than its upstream
  # Nix flake, which builds against an EOL nodejs_20 that nixpkgs marks insecure.
  flake.modules.darwin.agent-dev = {
    homebrew.brews = ["openspec"];
  };

  flake.modules.homeManager.agent-dev = {pkgs, ...}: let
    # diffx — reviews a git diff in a local GitHub-PR-like web UI, so agent
    # output gets read as a PR instead of as terminal scrollback. Not in
    # nixpkgs; built from the published npm tarball, which already ships the
    # bundled `dist/` (client included), so nothing is compiled here.
    #
    # `dist/cli.mjs` imports only the five deps kept by the jq filter below.
    # The React ones upstream declares as runtime `dependencies` are in fact
    # build-time only; dropping them together with `devDependencies` takes the
    # vendored lockfile — and the closure Nix has to fetch — from 328 packages
    # down to 24. package.json is patched in `postPatch` rather than in the
    # lockfile alone because `npm ci` refuses a lockfile that does not match it.
    #
    # To bump: set `version` + `hash`, unpack that tarball, apply the same jq
    # filter to its package.json, regenerate ./data/diffx-package-lock.json with
    #
    #   npm install --package-lock-only --ignore-scripts
    #
    # and take the new `npmDepsHash` from the `got:` line of the npm-deps hash
    # mismatch on the next build.
    diffx = pkgs.buildNpmPackage (finalAttrs: {
      pname = "diffx";
      version = "0.16.0";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/diffx-cli/-/diffx-cli-${finalAttrs.version}.tgz";
        hash = "sha256-UphRUM8ekj1JobfgWVULH4txN0MS4aFyGe1XBBRvg7s=";
      };

      # Runs in the npm-deps fetcher too, so the lockfile it installs from is
      # the same one `npm ci` later verifies against package.json.
      postPatch = ''
        ${pkgs.jq}/bin/jq 'del(.devDependencies, .scripts)
          | .dependencies |= with_entries(select(.key | IN(
              "@hono/node-server", "editorconfig", "get-port", "hono", "open")))' \
          package.json > package.json.patched
        mv package.json.patched package.json
        cp ${./data/diffx-package-lock.json} package-lock.json
      '';

      npmDepsHash = "sha256-lxsOsKCl1PrLCB/X1Uj6TXWj4kJP2ulIw0+GyYNPs2E=";

      # The tarball ships a prebuilt `dist/`; there is no build script to run
      # (and `postPatch` drops `scripts` along with the dev dependencies).
      dontNpmBuild = true;

      meta = {
        description = "Local code review tool for git diffs with a GitHub PR-like web UI";
        homepage = "https://github.com/wong2/diffx";
        license = pkgs.lib.licenses.mit;
        mainProgram = "diffx";
      };
    });

    # tmux-agent-sidebar — a sidebar pane listing every Claude Code / Codex /
    # OpenCode agent running across all sessions, with its status, last prompt
    # and git state. prefix + e toggles it in the current window, prefix + E
    # everywhere. Neither the plugin nor its binary is in nixpkgs.
    tmux-agent-sidebar = let
      version = "0.13.0";

      src = pkgs.fetchFromGitHub {
        owner = "hiroppy";
        repo = "tmux-agent-sidebar";
        tag = "v${version}";
        hash = "sha256-NiqLgMvWbSW3M80ZUWdmmm2VkVqy8eTGcPkrOCsaasI=";
      };

      binary = pkgs.rustPlatform.buildRustPackage {
        pname = "tmux-agent-sidebar";
        inherit version src;

        cargoHash = "sha256-mOEs2J1o9VeVOXY55r8O52TqoM2GuYU3tVoh5h+yH0s=";

        # Both tests shell out to git against CARGO_MANIFEST_DIR expecting a
        # real checkout; fetchFromGitHub unpacks a tarball with no .git, so they
        # cannot pass in the sandbox. The rest of the suite still runs.
        checkFlags = [
          "--skip=group::tests::resolve_git_info_for_real_repo"
          "--skip=group::tests::worktree_and_main_share_same_repo_root"
        ];

        meta = {
          description = "tmux sidebar that monitors AI coding agents across all windows and sessions";
          homepage = "https://github.com/hiroppy/tmux-agent-sidebar";
          license = pkgs.lib.licenses.mit;
          mainProgram = "tmux-agent-sidebar";
        };
      };
    in
      pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-agent-sidebar";
        # Default would be tmux_agent_sidebar.tmux (dashes mapped to
        # underscores); upstream keeps the dashes.
        rtpFilePath = "tmux-agent-sidebar.tmux";
        inherit version src;

        # tmux-agent-sidebar.tmux prefers $PLUGIN_DIR/bin over PATH and then
        # checks the binary's `version` against Cargo.toml; dropping the Nix
        # build in here satisfies both, so its install wizard never fires.
        postInstall = ''
          mkdir -p "$target/bin"
          ln -s ${pkgs.lib.getExe binary} "$target/bin/tmux-agent-sidebar"
        '';
      };
  in {
    home.packages = [diffx];

    # Merges with the plugin list in modules/home/tmux.nix; kept here so the
    # sidebar only builds on hosts that actually run coding agents.
    programs.tmux.plugins = [
      {
        plugin = tmux-agent-sidebar;
        # No sidebar until prefix + e asks for one. This has to be set here
        # rather than in `extraConfig`, which home-manager emits *after* the
        # plugin loads: agent-sidebar.conf reads @sidebar_auto_create at load
        # time to decide whether to register its after-new-window hook, and
        # that hook does not re-read the option when it fires.
        extraConfig = "set -g @sidebar_auto_create off";
      }
    ];
  };
}
