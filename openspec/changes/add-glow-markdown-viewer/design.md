## Context

This dotfiles repo is a flake-parts configuration where each host (`modules/hosts/<name>/default.nix`) is assembled from a list of named "aspects". Package sets are factored into shared aspect modules that expose both `flake.modules.nixos.<aspect>` and `flake.modules.darwin.<aspect>`, so one definition serves NixOS and nix-darwin alike.

The shared `tools` aspect (`modules/shared/tools.nix`) holds general-purpose CLI utilities (`curl`, `tree`, `ncdu`, `ffmpeg`, `tig`, …) and is imported by exactly the hosts that should receive a markdown viewer:

| Host      | Type        | Imports `tools`? | Should get glow? |
|-----------|-------------|------------------|------------------|
| `mac`     | darwin      | yes              | yes              |
| `desktop` | nixos       | yes              | yes              |
| `nas`     | nixos srv   | yes              | yes              |
| `asus`    | nixos srv   | yes              | yes              |
| `dell`    | nixos srv   | yes              | yes              |
| `rpi4b`   | nixos (Pi)  | **no**           | **no**           |

The requested target set (mac + desktop + servers, excluding the Pi) is therefore identical to the current membership of the `tools` aspect.

## Goals / Non-Goals

**Goals:**
- Make a modern, styled terminal markdown viewer available on the Mac, desktop, and all three servers.
- Keep the Raspberry Pi free of the tool.
- Reuse the existing aspect mechanism so the change is one edit with no per-host duplication.

**Non-Goals:**
- No shell aliases, `$PAGER`/`glow` integration, themes, or stylix wiring — package install only.
- No new flake inputs; glow ships in nixpkgs.
- No changes to the rpi4b host file.

## Decisions

**Decision: Use `glow` as the markdown viewer.**
Charmbracelet's `glow` is the de-facto modern CLI markdown renderer: it renders to a styled terminal via glamour, has a built-in pager, works headless over SSH, and is in nixpkgs (`pkgs.glow`, v2.1.2). Alternatives considered: `mdcat` (more a `cat`-style pipe filter, less of a reader/pager — weaker for browsing docs interactively) and `frogmouth` (a heavier Textual TUI browser, more than needed for "view a markdown file"). glow best fits "view markdown in any terminal, including over SSH."

**Decision: Add glow to the shared `tools` aspect rather than per-host or a new aspect.**
The `tools` aspect's membership already equals the desired target set {mac, desktop, nas, asus, dell} and excludes `rpi4b`. Adding `pkgs.glow` to the package list in `modules/shared/tools.nix` covers all five hosts with a one-line edit and automatically keeps the Pi excluded. Alternatives considered: (a) adding `glow` to each host's `environment.systemPackages` — five edits, duplicated, easy to drift; (b) creating a dedicated `markdown` aspect and wiring it into five host files — five+ edits for a single package, not worth the indirection. The shared-aspect approach is the smallest correct change and matches existing conventions (e.g., `tig` lives there the same way).

## Risks / Trade-offs

- **[Coupling to `tools` membership]** → If a future host imports `tools` but should not get glow, it would inherit the package. Mitigation: this exactly matches today's intent (every `tools` consumer is a full workstation/server); revisit only if a minimal host adopts `tools`.
- **[Pi exclusion is implicit, not enforced]** → The Pi is excluded only because it doesn't import `tools`. Mitigation: the spec records this intent and the change explicitly does not touch any aspect rpi4b imports, so the exclusion holds as long as that remains true.
- **[Closure size on servers]** → glow is a small Go binary; negligible impact on the server/Pi image sizes.

## Migration Plan

1. Add `glow` to the package list in `modules/shared/tools.nix`.
2. Rebuild each affected host (`nh darwin switch` for `mac`; `nh os switch`/`nixos-rebuild` per NixOS host) and confirm `glow --version`.
3. Rollback: remove the line and rebuild, or roll back to the previous generation; no state or data to migrate.
