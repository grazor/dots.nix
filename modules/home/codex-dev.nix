# Interactive Codex CLI in tmux, with a per-process browser for UI tasks.
{
  flake.modules.homeManager.codex-dev = {pkgs, ...}: {
    programs.codex = {
      enable = true;
      mutableSettings = true;
      settings.mcp_servers.playwright = {
        command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
        # Separate profiles per agent; disable Chromium's inner sandbox for LXC.
        args = ["--headless" "--isolated" "--no-sandbox"];
        startup_timeout_sec = 60;
      };
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

    home.packages = with pkgs; [playwright-test playwright-mcp];
    home.sessionPath = ["$HOME/.local/bin"];

    home.file."src/.keep".text = "";
  };
}
