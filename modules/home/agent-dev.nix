# Agentic dev workspace. workmux drives a 3-pane tmux layout for running coding
# agents side by side, plus the OpenSpec CLI for spec-driven development.
#
# Opt-in feature spanning two aspects, both enabled only on the macOS host:
#   - darwin.agent-dev      → OpenSpec CLI (Homebrew), composed in the host's
#                             `aspects` list.
#   - homeManager.agent-dev → workmux + its config, imported into the user's
#                             home-manager profile.
{inputs, ...}: {
  flake-file.inputs.workmux = {
    url = "github:raine/workmux";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # OpenSpec (`openspec` CLI) is installed via Homebrew rather than its upstream
  # Nix flake, which builds against an EOL nodejs_20 that nixpkgs marks insecure.
  flake.modules.darwin.agent-dev = {
    homebrew.brews = ["openspec"];
  };

  flake.modules.homeManager.agent-dev = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
  in {
    home.packages = [
      # Upstream's darwin-only sandbox tests (Lima / apple-container mount
      # paths) write to absolute paths and fail under Nix's read-only build
      # sandbox, breaking the build on macOS. Skip the test phase — they are
      # environment artifacts, not defects in the binary we ship.
      (inputs.workmux.packages.${system}.default.overrideAttrs (_: {
        doCheck = false;
      }))
    ];

    # `wm add <feature>` spins up a worktree window with the layout below.
    programs.fish.shellAbbrs.wm = "workmux";

    # prefix + a pops the workmux dashboard over the current pane. Lives here
    # rather than in modules/home/tmux.nix so the binding only exists on hosts
    # that actually ship workmux; extraConfig merges across both modules.
    programs.tmux.extraConfig = ''
      bind a display-popup -h 30 -w 100 -E "workmux dashboard"
    '';

    # Layout: claude (left, full height) | term (top-right) / terminal (bottom-right).
    #   +--------+--------+
    #   |        |  term  |
    #   | claude +--------+
    #   |        |  term  |
    #   +--------+--------+
    xdg.configFile."workmux/config.yaml".text = ''
      agent: claude
      mode: window
      nerdfont: true
      window_prefix: wm-
      panes:
        - command: 'claude --dangerously-skip-permissions --permission-mode bypassPermissions --model opus'
          focus: true
        - split: horizontal
        - split: vertical
    '';
  };
}
