## Why

Markdown is the default format for the READMEs, notes, and docs scattered across these machines, but reading it raw in a terminal (`cat`/`less`) is noisy and hard to scan. A modern CLI markdown renderer gives readable, styled output everywhere — including over SSH on the headless servers where no GUI viewer exists.

## What Changes

- Adopt **glow** (Charmbracelet, packaged in nixpkgs as `glow`, v2.1.2) as the standard terminal markdown viewer.
- Add `glow` to the shared `tools` aspect (`modules/shared/tools.nix`), so it is installed via `environment.systemPackages` on every host that already imports `tools`.
- Coverage follows the existing `tools` aspect membership: the Mac (`mac`), the desktop workstation (`desktop`), and the three homelab servers (`nas`, `asus`, `dell`).
- Explicitly **exclude** the Raspberry Pi (`rpi4b`), which already does not import `tools` — no change is required to keep it excluded.

## Capabilities

### New Capabilities
- `cli-markdown-viewer`: A terminal-based markdown rendering tool available on the workstation and server hosts (but not the constrained Raspberry Pi), provisioned through the shared `tools` aspect.

### Modified Capabilities
<!-- No existing specs in openspec/specs/; nothing to modify. -->

## Impact

- **Files**: `modules/shared/tools.nix` (one package added to the shared list).
- **Hosts affected (gain `glow`)**: `mac`, `desktop`, `nas`, `asus`, `dell`.
- **Hosts intentionally unaffected**: `rpi4b` (does not import the `tools` aspect).
- **Dependencies**: `pkgs.glow` from the pinned `nixpkgs-unstable` input; no new flake inputs.
- **Risk**: Minimal — additive package only; no configuration, services, or breaking changes.
