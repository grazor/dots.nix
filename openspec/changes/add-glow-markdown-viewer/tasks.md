## 1. Add the package

- [x] 1.1 Add `glow` to the shared package list in `modules/shared/tools.nix` (place it near the other content tools, e.g. by `tig`)

## 2. Verify wiring

- [x] 2.1 Confirm `flake.nix` / config evaluates: `nix flake check` (or `nix eval .#darwinConfigurations.mac.system` and one nixos host) succeeds
- [x] 2.2 Confirm `glow` resolves in the affected hosts' `environment.systemPackages` (mac, desktop, nas, asus, dell)
- [x] 2.3 Confirm `rpi4b` does NOT include `glow` (it does not import the `tools` aspect — no change to its host file)

## 3. Build & smoke test

<!-- Build + binary smoke test done from this session (mac system closure built; `glow` 2.1.2 runs and renders markdown). Live activation/deploy left to the user. -->
- [ ] 3.1 Activate the `mac` host (`nh darwin switch` or equivalent) and run `glow --version` and `glow README.md` from the live PATH
- [ ] 3.2 Build/deploy at least one NixOS host (e.g. `desktop` or a server) and run `glow --version`; over SSH for a server to confirm headless rendering
