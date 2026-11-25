# Antigravity CLI alongside the shared Codex profile.
{
  flake.modules.homeManager.antigravity = {
    config,
    lib,
    osConfig,
    pkgs,
    ...
  }: let
    home = config.home.homeDirectory;
    sharedSkills = "${home}/.agents/skills";
    codexHome = "${home}/.codex";
    geminiConfig = "${home}/.gemini/config";
    manifestName = "dots-skills.json";
    json = pkgs.formats.json {};
    mergeJson = path: staticSettings: jqOperation:
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs path staticSettings jqOperation;
        format = "json";
        empty = "{}";
        mode = "600";
      };

    # Antigravity scans one level deep unless a manifest names the nested
    # skills explicitly. Use the bundle to generate paths to the shared copies.
    bundle = config.programs.agent-skills.targetBundlePaths.agents;
    skillManifest =
      pkgs.runCommand "antigravity-skills.json" {
        nativeBuildInputs = [pkgs.findutils pkgs.jq];
      } ''
        set -o pipefail
        find -L ${bundle} -type f -name SKILL.md -printf '%P\0' |
          jq -Rs --arg shared ${lib.escapeShellArg sharedSkills} \
            --arg codex ${lib.escapeShellArg "${codexHome}/skills"} '
              {entries: (
                [{path: $shared}, {path: $codex, exclude: [".system"]}]
                + (split("\u0000") | map(select(length > 0) | rtrimstr("/SKILL.md"))
                   | sort | map({path: ($shared + "/dots/" + .)}))
              )}
            ' > "$out"
      '';

    statusLine = pkgs.writeShellScript "antigravity-status-line" ''
      exec ${lib.getExe pkgs.jq} -r '
        [
          (.context_window | select((.context_window_size // 0) > 0 and .remaining_percentage != null)
            | "context \(.remaining_percentage | round)% left"),
          (.context_window | select(.total_input_tokens != null)
            | "\(.total_input_tokens + (.total_output_tokens // 0)) tokens"),
          ((.quota // {}) | to_entries[] | select(.value.disabled != true)
            | select(.value.remaining_fraction != null)
            | "\(.key) \(.value.remaining_fraction * 100 | round)% left")
        ] | join(" · ")
      '
    '';
    settings = json.generate "antigravity-settings.json" {
      agentMode = "accept-edits";
      toolPermission = "always-proceed";
      artifactReviewPolicy = "always-proceed";
      enableTerminalSandbox = false;
      allowNonWorkspaceAccess = true;
      statusLine = {
        type = "command";
        command = toString statusLine;
      };
    };
    manifestReference = json.generate "antigravity-skill-manifest-reference.json" {
      inherits = [{path = "${geminiConfig}/${manifestName}";}];
    };
    playwright = config.programs.mcp.servers.playwright or null;
    proxy = osConfig.home-manager.extraSpecialArgs.xrayProxyEnvironment or null;
    package =
      if proxy == null
      then pkgs.antigravity-cli
      else
        pkgs.writeShellScriptBin "agy" ''
          ${lib.concatMapAttrsStringSep "\n" (name: value: "export ${name}=${lib.escapeShellArg value} ${lib.toUpper name}=${lib.escapeShellArg value}")
            proxy}
          exec ${lib.getExe pkgs.antigravity-cli} "$@"
        '';
  in {
    home = {
      packages = [package];
      file = {
        ".gemini/config/${manifestName}".source = skillManifest;
        ".gemini/config/rules/dots-codex.md".text = ''
          ---
          trigger: always_on
          ---
          @[Codex global instructions](~/.codex/AGENTS.md)
        '';
      };

      activation.antigravitySettings = lib.hm.dag.entryAfter ["linkGeneration"] (
        (mergeJson "${home}/.gemini/antigravity-cli/settings.json" settings "$dynamic * $static")
        + (mergeJson "${geminiConfig}/skills.json" manifestReference ''
          $dynamic | .inherits = ((.inherits // []) as $existing
            | $static.inherits[0] as $managed
            | if any($existing[]; .path == $managed.path) then $existing else $existing + [$managed] end)
        '')
        + lib.optionalString (playwright != null) (mergeJson "${geminiConfig}/mcp_config.json"
          (json.generate "antigravity-playwright.json" {
            mcpServers.playwright = {inherit (playwright) command args;};
          })
          "$dynamic | .mcpServers.playwright = $static.mcpServers.playwright")
      );
    };
  };
}
