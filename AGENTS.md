# Working in dots

This repository manages NixOS, nix-darwin, and Home Manager configurations
using the dendritic pattern: flake-parts + import-tree + flake-file. Read
`README.md` for host roles, bootstrap steps, and operational details.

## Architecture and layout

- Every `*.nix` under `modules/` is auto-imported as a **flake-parts module**.
  Define NixOS, Darwin, or Home Manager modules inside the appropriate
  `flake.modules.{nixos,darwin,homeManager}.<aspect>` attribute; do not place a
  bare system or Home Manager module at the top level.
- Features are named aspects, composed through imports and host aspect lists.
  Follow this pattern instead of introducing custom per-feature enable flags.
- `modules/flake/` contains host builders, per-system arguments, flake-file
  integration, and formatting. `mkNixos` and `mkDarwin` live in `lib.nix`.
- `modules/hosts/<name>/default.nix` composes aspects and supplies host-specific
  settings through `machine`. Keep reusable behavior in aspects.
- `modules/nixos/`, `modules/darwin/`, and `modules/home/` contain platform and
  user aspects. `modules/shared/` exposes behavior for both system platforms;
  reuse shared definitions where practical.
- `modules/devshells/` defines language shells and shared pre-commit hooks.
- `modules/home/codex.nix` shares Codex defaults and skills across Home Manager
  profiles; `codex-dev.nix` adds container-specific behavior. Install skills with
  `copy-tree` into `~/.agents/skills/dots`: symlinked `SKILL.md` files caused
  discovery failures, and the namespace preserves manually installed skills.
- `secrets/` holds SOPS-encrypted files; `.sops.yaml` defines recipients.

## Generated flake and dependencies

- **Do not hand-edit `flake.nix`.** Declare inputs with
  `flake-file.inputs.<name>` in the module that uses them, then regenerate with
  `nix run .#write-flake` from the repository root.
- Preserve existing input `follows` relationships. Keep `flake.lock` changes
  scoped to the requested dependency work; avoid unrelated input upgrades.
- Git-backed flakes exclude untracked files. Make sure newly added modules
  and assets are included in the source used for evaluation; an untracked
  module can otherwise appear to pass checks without being evaluated.

## Personal scripts: ./bin to ~/.bin

- `bin/` is the source of truth for personal command-line scripts.
- The Home Manager `scripts` aspect in `modules/home/scripts.nix` is the
  linking helper: it enumerates `../../bin` with `builtins.readDir`, creates a
  `home.file.".bin/<name>"` source link for every entry, and adds `$HOME/.bin`
  to `home.sessionPath`. Home Manager realizes those links through the Nix
  store when the configuration is applied.
- Add or edit scripts in `./bin`, preserving executable permissions and the
  appropriate shebang. No manual per-script link registration is needed.
  Changes take effect in `~/.bin` after the relevant configuration is applied;
  edit the repository source rather than the managed links.
- Supply script runtime dependencies through the appropriate aspect; for
  example, `modules/home/imgsend.nix` supplies tools for `bin/imgsend`.

## Environment and validation

- Check for `.envrc` in the project and its parent directories, including
  ignored files. When direnv applies, run environment-dependent commands as
  `direnv exec <project-root> <command>` with the correct working directory.
  Do this again when switching projects or worktrees.
- If no direnv environment applies, use `nix develop .#nix -c <command>` when
  Nix development tools are needed. Entering these dev shells installs
  pre-commit hooks in the current repository.
- Match existing Nix style: Alejandra formatting, two-space indentation, and
  concise aspect names. `nix fmt` runs treefmt with Alejandra; the Nix shell
  also provides `statix check` and `deadnix`.
- For Nix changes, format affected files and run relevant lint/evaluation
  checks. `nix flake check --no-build` checks flake evaluation without building
  checks. Evaluate affected host derivations explicitly when relevant:

  ```sh
  nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
  nix eval .#darwinConfigurations.mac.config.system.build.toplevel.drvPath
  ```

- When build validation is needed, use `nix build --no-link` with the affected
  `nixosConfigurations.<host>.config.system.build.toplevel` or
  `darwinConfigurations.mac.system` flake attribute. Choose a builder matching
  the target platform; supported systems are `x86_64-linux`, `aarch64-linux`,
  and `aarch64-darwin`.
- For script changes, use the interpreter's syntax check and focused behavior
  checks; use ShellCheck for Bash where applicable. Documentation-only changes
  need a diff review, not system builds. Report checks run and any limitations.

## Host configuration and secrets

- Preserve `system.stateVersion` and `home.stateVersion` unless changing them
  is explicitly part of the task. They are compatibility settings.
- Hardware reports live at `modules/hosts/<name>/facter.json` for physical
  NixOS hosts. Inspect the actual report before relying on it; generate reports
  on the target device. Filesystems, LUKS, and bootloader settings remain
  host-specific configuration.
- Keep secrets encrypted. Do not commit plaintext credentials, age private
  keys, decrypted SSH mappings, or sensitive values in Nix expressions that
  would copy them into the Nix store. Preserve per-file recipient boundaries.
  Follow the README for SOPS editing and rekeying.
- Apply host configurations or restart deployed services only when the task
  calls for those operations. Repository edits alone do not require activation.
- Update `README.md` when changing documented host behavior, setup, or commands.

## Internal Avito integrations

- Use the `mcp-hub` MCP server first for internal Avito services such as Jira,
  Confluence, Stash, Mattermost, Grafana, Sentry, and QueryPad. Discover missing
  tools with `list_servers` / `search_tools`, then use `call_tool` (or
  `get_server` for details). Do not call internal HTTP APIs directly or scrape
  their web UIs when a Hub tool covers the task.
- If authorization is missing or expired, check `mcp_hub_status`, ask the user
  to re-authenticate in a separate terminal, then retry. Do not request personal
  tokens or use unauthenticated workarounds.
