# Container-specific Codex context and a per-process browser for UI tasks.
{inputs, ...}: {
  flake-file.inputs.mcp-servers-nix = {
    url = "github:natsukium/mcp-servers-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.codex-dev = {pkgs, ...}: let
    # Taste Skill launches its own Chromium process. This container needs the
    # inner Chromium sandbox disabled, as with the existing Playwright MCP.
    taste-chromium = pkgs.writeShellScriptBin "taste-chromium" ''
      exec ${pkgs.chromium}/bin/chromium --no-sandbox "$@"
    '';
  in {
    imports = [inputs.mcp-servers-nix.homeManagerModules.default];

    mcp-servers.programs.playwright = {
      enable = true;
      package = pkgs.playwright-mcp;
      # Separate profiles per agent; disable Chromium's inner sandbox for LXC.
      args = ["--headless" "--isolated" "--no-sandbox"];
    };
    programs.mcp.enable = true;

    programs.codex = {
      enableMcpIntegration = true;
      context = ''
        This is a persistent NixOS development container, accessed over SSH.
        Projects live under ~/src, with separate tmux windows/sessions.
        Check each repo's AGENTS.md and .envrc, including parent directories.
        For direnv-managed repos run environment-dependent commands through
        direnv exec <project-root> <command> from the appropriate directory.
        Use each project's flake/toolchain when present.
        Playwright MCP provides a local browser for UI checks and screenshots.
        Dev servers bound to 127.0.0.1 can be viewed from the laptop using SSH
        local port forwarding; no firewall changes are needed for that.
      '';
    };

    home = {
      packages = with pkgs; [playwright-test playwright-mcp python3 nodejs];
      sessionPath = ["$HOME/.local/bin"];
      sessionVariables.CHROME_PATH = "${taste-chromium}/bin/taste-chromium";
      file."src/.keep".text = "";
    };
  };
}
