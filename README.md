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
5. For k3s nodes (`dell`, `asus`), set up SOPS before the first real switch:
   replace the `.sops.yaml` age recipients, add the k3s/Flux values to
   `secrets/k3s.yaml`, encrypt it, and set `sops.validateSopsFiles = true`
   once the secret is real.
6. Install or switch:
   ```sh
   sudo nixos-install --flake .#dell      # fresh install from /mnt
   sudo nixos-rebuild switch --flake .#dell
   ```

Bootstrap order for the homelab cluster is `dell` first, then `asus`: `dell`
is the k3s server and `asus` joins it as an agent via `https://192.168.2.2:6443`.

Flux bootstrap runs from the k3s server only. After the external manifests repo
exists and the secrets are encrypted, enable it in `modules/hosts/dell/default.nix`:

```nix
grazor.flux = {
  enable = true;
  repository = "ssh://git@github.com/<owner>/<flux-repo>.git";
  branch = "main";
  path = "./clusters/homelab";
};
```

On activation, `flux-bootstrap.service` installs Flux controllers, creates the
Git deploy-key secret, creates the `sops-age` secret, and applies the root
`GitRepository` + `Kustomization`. The agent node (`asus`) does not run Flux
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

Secrets are stored in `secrets/k3s.yaml` and encrypted with SOPS. This repo
contains three secret values:

| Key | Purpose |
|-----|---------|
| `k3s-token` | k3s server/agent join token |
| `flux-deploy-key` | OpenSSH private deploy key Flux uses to read the manifests repo |
| `flux-sops-age-key` | age private key Flux uses to decrypt SOPS-encrypted manifests |

One-time setup:

1. Generate a personal age key and collect each host's age key from its SSH host key:
   ```sh
   age-keygen -o ~/.config/sops/age/keys.txt          # admin key
   nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub   # per host
   ```
2. Put those public keys into `.sops.yaml` (replace the `age1REPLACE_*` anchors).
3. Generate the Flux keys:
   ```sh
   age-keygen -o /tmp/flux-sops-age.key
   age-keygen -y /tmp/flux-sops-age.key > /tmp/flux-sops-age.pub

   ssh-keygen -t ed25519 -f /tmp/flux-deploy-key -C flux-homelab -N ""
   ```
4. Add `/tmp/flux-deploy-key.pub` as a deploy key in the external Flux
   manifests repository. Read-only access is enough for this NixOS bootstrap
   flow because the host creates Flux resources directly instead of pushing to
   the repo.
5. Encrypt this repo's secrets:
   ```sh
   sops secrets/k3s.yaml
   ```
   Set:
   ```yaml
   k3s-token: <token from the old ~/.token.k3s>
   flux-deploy-key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...
     -----END OPENSSH PRIVATE KEY-----
   flux-sops-age-key: |
     AGE-SECRET-KEY-...
   ```
6. Flip `sops.validateSopsFiles` back to `true` in `modules/nixos/sops.nix`.

The token is decrypted on-device to `/run/secrets/k3s-token` and used as
`services.k3s.tokenFile`. Flux secrets are decrypted to `/run/secrets/*`, then
`flux-bootstrap.service` copies them into Kubernetes secrets in the
`flux-system` namespace.

To add a new encrypted Kubernetes Secret to the external Flux manifests repo,
encrypt it with `/tmp/flux-sops-age.pub`:

```sh
SOPS_AGE_RECIPIENTS="$(cat /tmp/flux-sops-age.pub)" \
  sops --encrypt --encrypted-regex '^(data|stringData)$' \
  --in-place clusters/homelab/path/to/secret.yaml
```

Commit the encrypted YAML to the manifests repo. The private key stays in this
repo's encrypted `secrets/k3s.yaml` and is installed into the cluster as the
`sops-age` secret.
