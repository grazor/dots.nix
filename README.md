# dots

NixOS + nix-darwin + home-manager config, organized with the **dendritic pattern**
([flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree)).

Every `*.nix` under `modules/` is a flake-parts module and is auto-imported. Reusable
behaviour is exposed as *aspects* under `flake.modules.{nixos,darwin,homeManager}.<name>`;
each host is built by **composing** aspects (no per-feature enable flags).

## Hosts

| Host | Device | Type | Role |
|------|--------|------|------|
| `dell` | Dell laptop | NixOS | homelab k3s **server** + WireGuard server (headless, user `cloud`) |
| `asus` | Asus node | NixOS | homelab k3s **agent**/worker (headless, user `cloud`) |
| `desktop` | Desktop PC | NixOS | gaming workstation — GNOME + NVIDIA + Steam (user `g`) |
| `mac` | Work MacBook | nix-darwin | dev machine (user `smporyvaev`) |

## Layout

```
flake.nix                 # flake-parts + import-tree entrypoint (minimal)
modules/                  # every *.nix is a flake-parts module (auto-imported)
  flake/                  # option declaration, host builders, devShells, perSystem args
  nixos/                  # flake.modules.nixos.<aspect>
  darwin/                 # flake.modules.darwin.<aspect>
  home/                   # flake.modules.homeManager.<aspect>
  shared/                 # aspects for both NixOS and darwin (tools/devtools/fonts)
  hosts/<name>/           # one host each: default.nix composes aspects; facter.json = hardware
secrets/                  # sops-encrypted secrets
.sops.yaml                # sops recipients / creation rules
```

Everything lives under `modules/` — there is no separate `hosts/` tree. Each
host is just another flake-parts module (`modules/hosts/<name>/default.nix`) that
declares its configuration via the `mkNixos` / `mkDarwin` helpers and composes
named aspects.

## Hardware (nixos-facter)

Hardware is detected by [nixos-facter](https://github.com/numtide/nixos-facter)
instead of a hand-written `hardware-configuration.nix`. The committed
`modules/hosts/<name>/facter.json` files are **empty placeholders (`{}`)** — you
must regenerate a real report on each device before switching, otherwise the
build will be missing kernel modules and won't boot:

```sh
sudo nixos-facter -o modules/hosts/<name>/facter.json
```

Filesystems, LUKS and the boot loader are *not* covered by facter and are
declared inline in each host's `default.nix`.

## Bootstrap

First-time setup has two separate phases: get enough Nix running to evaluate the
flake, then switch the host to its composed configuration.

### NixOS

1. Boot the NixOS installer or an existing NixOS system.
2. Prepare disks and mounts for the target host. The UUIDs in
   `modules/hosts/<name>/default.nix` must match the real root, boot and swap
   devices before install/switch.
3. Clone this repository on the target system:
   ```sh
   git clone <repo-url> /mnt/etc/nixos/dots
   cd /mnt/etc/nixos/dots
   ```
   On an already running system, use any local checkout path instead of
   `/mnt/etc/nixos/dots`.
4. Generate the host hardware report on that device:
   ```sh
   sudo nix run nixpkgs#nixos-facter -- -o modules/hosts/<name>/facter.json
   ```
5. For k3s nodes (`dell`, `asus`), the secrets in `secrets/k3s.yaml` are already
   encrypted, but only the admin age key can decrypt them. Before the first real
   switch, add this host's age recipient and re-key so the host can decrypt at
   activation (see the "Secrets" section for the `ssh-to-age` + `updatekeys`
   steps). Skip this and activation will fail to decrypt.
6. Install or switch:
   ```sh
   sudo nixos-install --flake .#dell      # fresh install from /mnt
   sudo nixos-rebuild switch --flake .#dell
   ```

Bootstrap order for the homelab cluster is `dell` first, then `asus`: `dell`
is the k3s server and `asus` joins it as an agent via `https://192.168.2.2:6443`.

Flux bootstrap runs from the k3s server (`dell`) only; it is already enabled
there via `grazor.flux.enable = true` (defaults point at
`ssh://git@github.com/grazor/homelab`, path `./cluster`). On activation,
`flux-bootstrap.service`:

1. restores the **Sealed Secrets** controller key as the TLS secret
   `sealed-secrets/graz-sealed-key` (labeled active) so the `SealedSecret`
   manifests committed in the homelab repo decrypt in-cluster;
2. installs the Flux controllers;
3. creates the Git deploy-key secret plus the root `GitRepository` +
   `Kustomization` (equivalent to `cluster/flux-system/gotk-sync.yaml`).

In-cluster secrets are decrypted by the sealed-secrets controller — Flux does
**not** use SOPS decryption. The agent node (`asus`) does not run Flux
bootstrap; it just joins the k3s cluster.

### macOS

1. Install Nix and clone this repository.
2. Run the darwin configuration:
   ```sh
   nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake .#mac
   ```
3. After the first activation, use the installed `darwin-rebuild` command for
   subsequent switches.

## Rebuild

```sh
# NixOS hosts
sudo nixos-rebuild switch --flake .#dell      # or asus / desktop

# macOS
darwin-rebuild switch --flake .#mac

# dev shells
nix develop .#rust        # or python3 / node / lua / qmk
```

## Secrets (sops-nix)

`secrets/k3s.yaml` is encrypted with SOPS (age) and **already populated**. It
holds five values:

| Key | Purpose | Consumed by |
|-----|---------|-------------|
| `k3s-token` | k3s server/agent join token | `services.k3s.tokenFile` on `dell` + `asus` |
| `flux-deploy-key` | OpenSSH deploy key for the homelab manifests repo | `flux-bootstrap.service` (GitRepository secret) |
| `sealed-secrets-tls-crt` | Sealed Secrets controller cert | restored as `sealed-secrets/graz-sealed-key` |
| `sealed-secrets-tls-key` | Sealed Secrets controller key | restored as `sealed-secrets/graz-sealed-key` |
| `code-ssh-key` | `cloud@hl-dell-node1` git push key | installed to `/home/cloud/.ssh/id_ed25519` on `dell` |

Recipients live in `.sops.yaml`. Currently only the **admin** age key
(`~/.config/sops/age/keys.txt` on this machine) can decrypt. Each NixOS host
decrypts at activation using an age key derived from its SSH host key, so before
the first real switch on `dell`/`asus` you must add the host recipients and
re-key:

```sh
# On each host, derive its age recipient from the SSH host key:
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

1. Uncomment the `dell` / `asus` anchors in `.sops.yaml` and paste the
   recipients from above.
2. Re-encrypt the data key for the new recipients:
   ```sh
   nix run nixpkgs#sops -- updatekeys secrets/k3s.yaml
   ```

> **macOS:** the admin key is at `~/.config/sops/age/keys.txt`, which is *not*
> the default location sops checks on macOS. Export
> `SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt` before running `sops` to
> decrypt / `updatekeys`.

To edit a value (e.g. swap the generated `k3s-token` for an existing one):

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix run nixpkgs#sops -- secrets/k3s.yaml
```

### Adding new in-cluster secrets

The homelab cluster uses **Sealed Secrets**, not Flux SOPS. To add a Kubernetes
secret to the manifests repo, seal it against the controller cert and commit the
`SealedSecret` (see the homelab repo's `scripts/secret.sh`):

```sh
kubectl -n <ns> create secret generic <name> --dry-run=client \
  --from-file=<field>=/dev/stdin -o yaml | kubeseal --cert sealed.crt -o yaml
```
