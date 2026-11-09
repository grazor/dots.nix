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
| `asus` | Asus node | NixOS | homelab k3s **agent**/worker + shared HP USB printer/scanner (headless, user `cloud`) |
| `nas` | Homebuilt NAS | NixOS | homelab k3s **agent**/storage worker with ZFS + Incus dev containers (headless, user `cloud`) |
| `rpi4b` | Raspberry Pi 4B | NixOS | native Zigbee2MQTT bridge to the k3s MQTT broker (headless, user `pi`) |
| `lxc` | Incus container | NixOS | dev container guest on `nas`: shell, tmux, nvf, dev tools (user `cloud`) |
| `surfr` | Incus container | NixOS | live surfr host on `nas` (user `cloud`) |
| `dev` | Incus container | NixOS | persistent multi-repo Codex/tmux workspace (user `cloud`) |
| `desktop` | Desktop PC | NixOS | gaming workstation — GNOME + NVIDIA + Steam (user `g`) |
| `mac` | Work MacBook | nix-darwin | dev machine (user `smporyvaev`) |

## Candle dataset service on dev

The `dev` host runs `surfr-candles.service` at boot as `cloud`. It serves a
Unix socket at `/var/lib/surfr-candles/store/candles.sock` and advances warmed
minute and native daily series hourly using public delayed MOEX ISS data. The Surfr client
endpoint is exported as `SURFR_CANDLES_ENDPOINT` in new login shells.
Configuration is `/etc/surfr/candles.toml`; data stays outside the checkout.
The checkout on `dev` has ignored symlinks from `data/candles` and
`config/candles.toml` to these shared paths, so its default CLI paths work too.
The deployed Surfr ISS client paces HTTP requests to one per second; concurrency
is one, automatic read-triggered fetching is disabled, and failures restart
after five minutes.

Build and install the daemon from the Surfr checkout, then apply this host:

```sh
cd ~/src/surfr
nix develop -c cargo build --release -p candles
sudo install -d -o cloud -g users -m 0750 /var/lib/surfr-candles/bin
sudo systemctl stop surfr-candles.service
sudo install -o cloud -g users -m 0755 target/release/candles /var/lib/surfr-candles/bin/candles
sudo nixos-rebuild switch --flake ~/src/configs/dots.nix#dev
sudo systemctl start surfr-candles.service
```

`surfr-candles-backfill.service` downloads full committed research windows
through the daemon's RPC API while it continues serving. The reproducible plan
and runner come from Surfr's `config/candles-backfill.json` and
`scripts/candles_backfill.py`, installed under `/var/lib/surfr-candles/backfill/`
alongside `crates/candles-proto/proto/candles.proto` (named `candles.proto`).
Refresh these files when changing the research universe, then restart the
backfill service. It resumes from stored coverage and retries failures after
an hour. Downloads may take days at the request cap.

Check `backfill/status.json` for actual completion, empty series, and failures;
a planned ticker is not necessarily covered yet. After successful downloads,
`surfr-candles-scan.service` briefly stops the daemon, scans/repairs cash-market
corporate actions and restarts it. Final status is `complete` or `needs_review`
with details in `backfill/scan.log`. Futures use the native `1dn` settlement
lane, and polling stops once a contract's expiry has been covered. Newly
warmed series join the hourly polling roster without a restart.

For a manual CLI warm, stop the backfill worker and daemon first because the
daemon holds the exclusive writer lock, and restart them even if warming fails.

```sh
sudo systemctl stop surfr-candles-backfill
sudo systemctl stop surfr-candles
/var/lib/surfr-candles/bin/candles warm --config /etc/surfr/candles.toml \
  --tickers SBER GAZP LKOH --interval 1m --from 2026-11-02 --to 2026-11-03
sudo systemctl start surfr-candles
sudo systemctl start surfr-candles-backfill
journalctl -u surfr-candles -n 50
```

The expanded plan covers 1,583 stored series (1,249 futures/perpetual contracts,
228 native daily cash-market series, and 106 minute series). These are targets,
not a claim that backfilling has finished. Consult `status.json` and query the
daemon's coverage before a backtest or ML run.

The service is managed by the declarative `dev` host configuration. Keep the
`/var/lib/surfr-candles/nix-runtime-*` GC roots: they retain the deployed
binary's glibc and libgcc. Refresh those roots from
`ldd /var/lib/surfr-candles/bin/candles` whenever rebuilding with a new toolchain.

## Repository push destinations

On `dev`, both `~/src/configs/dots.nix` and `~/src/surfr` fetch from GitHub
through `origin`. Their default push remote is `origin`, with two push URLs:
GitHub first, then `ssh://git@git.porivaev.ru/porivaev/<repository>.git`.
A normal `git push` therefore sends commits to both destinations. A separate
`secondary` remote allows fetching and inspecting the secondary repository.
These are local Git settings; commits alone do not trigger a network push.

## Layout

```
flake.nix                 # flake-parts + import-tree entrypoint (minimal)
modules/                  # every *.nix is a flake-parts module (auto-imported)
  flake/                  # option declaration, host builders, devShells, perSystem args
  devshells/              # per-language `nix develop` shells + shared pre-commit wiring
  nixos/                  # flake.modules.nixos.<aspect>
  darwin/                 # flake.modules.darwin.<aspect>
  home/                   # flake.modules.homeManager.<aspect>
  shared/                 # aspects for both NixOS and darwin (tools/devtools/fonts)
  hosts/<name>/           # one host each: default.nix composes aspects; facter.json = hardware
bin/                      # small helper scripts on PATH (project, proxy, …)
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
5. For k3s nodes (`dell`, `asus`, `nas`), the secrets in `secrets/k3s.yaml` are already
   encrypted, but only the admin age key can decrypt them. Before the first real
   switch, add this host's age recipient and re-key so the host can decrypt at
   activation (see the "Secrets" section for the `ssh-to-age` + `updatekeys`
   steps). Skip this and activation will fail to decrypt.
   For `rpi4b`, do the same with `secrets/zigbee2mqtt.yaml`.
6. Install or switch:
   ```sh
   sudo nixos-install --flake .#dell      # fresh install from /mnt
   sudo nixos-rebuild switch --flake .#dell
   ```

Bootstrap order for the homelab cluster is `dell` first, then `asus` / `nas`:
`dell` is the k3s server and both agents join its configured API endpoint.
The `nas` node registers with `storage=nas` and the `storage=nas:NoSchedule`
taint, so only workloads with the matching selector and toleration are scheduled
there.

`nas` also runs Incus for throwaway dev containers (Rust apps, Telegram bots).
Instances are ZFS datasets under `rpool/incus`; the `share` profile mounts the
SMB `shared` folder at `/share` inside the container. The `lxc` configuration
is the guest: the usual shell, tmux, nvf and dev tools for user `cloud`, no
toolchains (a project's own flake, or `nix develop github:grazor/dots.nix#rust`,
provides those).

For a persistent workspace with Codex, the agent sidebar/review tools and
Playwright, use `nixosConfigurations.dev` instead. Language toolchains come
from project dev shells.

Mac and dev Codex sessions default to full access (`danger-full-access`,
`approval_policy = "never"`). Start a new session after rebuilding to pick up
the defaults; an explicit CLI flag or session permission selection can override them.

When using Mac tmux → SSH → dev tmux, `C-]` passes tmux keys to dev. On dev,
copy-mode `y`, mouse selection, and Neovim visual yanks send text to the Mac
clipboard through OSC 52. Both tmux servers need the updated configuration;
reload each after switching its host.
The dev status bar uses a blue background and an orange `SSH:dev` session label
to distinguish it from the Mac's status bar, including after reattaching.

To use a clipboard image in a remote Codex session, run `imgsend dev` on the Mac
or the GNOME Wayland desktop. The argument is an SSH alias. The command uploads
the image to a private `/tmp/imgsend.*` directory on that host, then replaces
the local clipboard with the remote image path. Paste the path into Codex. It
leaves the clipboard unchanged if capture or upload fails. Apply the Mac or
desktop configuration before using it. On the Mac, the Karabiner `Working`
profile binds `Ctrl+Shift+V` in Ghostty to `imgsend dev`. After the upload
finishes, press `Cmd+V` to paste the remote image path into Codex. The shortcut
sets the Nix/Homebrew PATH explicitly because Karabiner runs outside the
interactive shell.

`rpi4b` is intentionally not a k3s node. It runs native Zigbee2MQTT against the
USB coordinator and publishes to the k3s Mosquitto LoadBalancer. Its frontend
listens on port 8080; reserve its configured address for `rpi4b` or update the
homelab EndpointSlice. The homelab k3s repo keeps only the `z2m.porivaev.ru`
Traefik route to that frontend. After
moving the dongle, keep the in-cluster Zigbee2MQTT workload disabled so only one
instance owns the coordinator.

Flux is bootstrapped from outside this repo: run `flux bootstrap` (or the
homelab repo's `scripts/setup.sh`) against the cluster by hand. The Flux deploy
key and the Sealed Secrets controller key are no longer kept here either — the
nodes only carry the k3s join token.

### macOS

1. Install Nix and clone this repository.
2. Run the darwin configuration:
   ```sh
   nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake .#mac
   ```
3. After the first activation, use the installed `darwin-rebuild` command for
   subsequent switches.

Karabiner-Elements is installed by the Mac configuration. Its complete profiles,
keyboard mappings and mouse settings live in
`modules/darwin/data/karabiner.json`, captured from the Mac's current configuration.
Each rebuild restores that file to `~/.config/karabiner/karabiner.json` as a
writable, user-owned file. If it replaces a different configuration, the first
replacement saves `karabiner.json.before-dots` alongside it. GUI edits work
immediately but are reset on rebuild; to keep them, copy the live file back into
the repo before rebuilding:

```sh
cp ~/.config/karabiner/karabiner.json modules/darwin/data/karabiner.json
```

## Rebuild

```sh
# NixOS hosts
sudo nixos-rebuild switch --flake .#dell      # or asus / nas / rpi4b / desktop

# macOS
darwin-rebuild switch --flake .#mac

# dev shells
nix develop .#rust        # or nix / python3 / node / go / lua / qmk
```

For per-directory use, `bin/project` points direnv at one of these shells:

```sh
project                   # detect language/version from $PWD, pick a shell
project init rust         # or: use / detect / list / checks / clean
```

Entering a shell installs its pre-commit hooks in the current repo — alejandra
for nix everywhere, plus `rustfmt` / `prettier` / `ruff` / `stylua` per language
and `statix` + `deadnix` in the `nix` shell (wired in
`modules/devshells/hooks.nix`). The direnv hook also names the current tmux
window after the project directory.

`project` also reads shells from other roots (`SHELLS_BASE_PATH`, e.g.
`~/Avito/shells`). Such a root can ship an executable `.project-hook` to register
its own suggestions + checks — `project` calls it with `suggest` (print
`<shell>\t<reason>\t<version>` for `$PWD`) and `checks <shell>`. The Avito hook,
for example, reads `go.mod`'s `go X.Y` and resolves it to `avito.go.X.Y` (or the
nearest available). Hook suggestions win over the built-in detection above.

## Secrets (sops-nix)

SOPS recipients are per *file*, not per key: everyone listed on a file can
decrypt every value in it. So the k3s material is split by who must read it.

`secrets/k3s.yaml` — every node is a recipient, so it holds exactly one value:

| Key | Purpose | Consumed by |
|-----|---------|-------------|
| `k3s-token` | k3s server/agent join token | `services.k3s.tokenFile` on `dell` + `asus` + `nas` (`k3s-base`) |

`secrets/server.yaml` — admin + the control-plane node only:

| Key | Purpose | Consumed by |
|-----|---------|-------------|
| `code-ssh-key` | `cloud@hl-dell-node1` git push key for the homelab repo | symlinked to `/home/cloud/.ssh/k3s-flux` on the server (`k3s-server`) |
| `k3s-sealed-secrets-private` | Sealed Secrets controller key (RSA 4096) | `/run/secrets/k3s-sealed-secrets-private` on the server (`k3s-server`) |

The matching **cert is public** and deliberately unencrypted, at
`modules/nixos/data/sealed-secrets.crt` — `k3s-server` puts it at
`/etc/sealed-secrets.crt`, and `kubeseal --cert` needs no age key to seal
against it. RSA rather than ed25519 because sealed-secrets wraps its AES
session key with RSA-OAEP and kubeseal rejects any other key type.

Installing the key into the cluster is manual, since nothing bootstraps Flux
from here any more:

```sh
kubectl -n sealed-secrets create secret tls graz-sealed-key \
  --cert=/etc/sealed-secrets.crt \
  --key=/run/secrets/k3s-sealed-secrets-private
kubectl -n sealed-secrets label secret graz-sealed-key \
  sealedsecrets.bitnami.com/sealed-secrets-key=active
kubectl -n sealed-secrets delete pod -l name=sealed-secrets-controller
```

`secrets/zigbee2mqtt.yaml` holds the native Raspberry Pi Zigbee2MQTT MQTT
password:

| Key | Purpose | Consumed by |
|-----|---------|-------------|
| `zigbee2mqtt-mqtt-password` | Mosquitto password for MQTT user `z2m` | `services.zigbee2mqtt` on `rpi4b` |

`secrets/users.yaml` holds login password hashes for declarative accounts:

| Key | Purpose | Consumed by |
|-----|---------|-------------|
| `pi-password` | yescrypt/sha-512 hash for the `pi` account | `users.users.pi.hashedPasswordFile` via `user-pi` |

These are declared with `neededForUsers = true` so sops-nix decrypts them to
`/run/secrets-for-users` *before* the user activation script runs; a plain
`sops.secrets` entry lands too late and the account would be created locked.

Recipients live in `.sops.yaml`. Currently only the **admin** age key
(`~/.config/sops/age/keys.txt` on this machine) can decrypt. Each NixOS host
decrypts at activation using an age key derived from its SSH host key, so before
the first real switch on `dell`/`asus`/`nas`/`rpi4b` you must add the host
recipients and re-key:

```sh
# On each host, derive its age recipient from the SSH host key:
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

1. Uncomment the relevant `dell` / `asus` / `nas` / `rpi4b` anchors in
   `.sops.yaml` and paste the recipients from above.
2. Re-encrypt the data key for the new recipients:
   ```sh
   nix run nixpkgs#sops -- updatekeys secrets/k3s.yaml
   nix run nixpkgs#sops -- updatekeys secrets/zigbee2mqtt.yaml
   ```

> **macOS:** the admin key is at `~/.config/sops/age/keys.txt`, which is *not*
> the default location sops checks on macOS. Export
> `SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt` before running `sops` to
> decrypt / `updatekeys`.

To edit a value (e.g. swap the generated `k3s-token` for an existing one):

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix run nixpkgs#sops -- secrets/k3s.yaml
```

### Private SSH aliases

The `ssh-client` aspect is enabled on `mac`, `desktop`, `dell`, `nas`, `asus`,
and `dev`. Its encrypted
`secrets/ssh-config.bin` contains the complete host mappings so their addresses
stay out of Git and the Nix store. The admin age key and those five NixOS
hosts' SSH host keys are recipients.

| Alias | User | Connection |
|-------|------|------------|
| `vru` | `root` | RU gateway |
| `vde` | `root` | German exit, with `ProxyJump vru` |
| `dell`, `asus`, `nas` | `cloud` | Direct LAN connection |
| `desktop` | `g` | Direct LAN connection |
| `dev`, `surfr` | `cloud` | Direct LAN connection |

Rebuilding any enabled host decrypts the file for its primary user and adds an
`Include` for the runtime secret to `~/.ssh/config`. Existing entries are kept;
the first edit saves `~/.ssh/config.before-dots-ssh`, and the config is kept at
mode `0600`. An existing symlink is left untouched and must get the Include
in its source configuration. These mappings contain no passwords or private
keys; SSH uses each host's existing keys and agent.

To edit the private mappings with the admin key:

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix run nixpkgs#sops -- \
  --input-type binary --output-type binary secrets/ssh-config.bin
```

On the Mac, add or verify all listed aliases in that file, then rekey it for
the newly configured NixOS hosts:

```sshconfig
Host dev
  HostName 192.168.2.64
  User cloud

Host surfr
  HostName 192.168.2.32
  User cloud
```

```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix run nixpkgs#sops -- \
  updatekeys secrets/ssh-config.bin
```

Commit the rekeyed file before rebuilding `dell`, `asus`, `nas`, or `dev`.

### Adding new in-cluster secrets

The homelab cluster uses **Sealed Secrets**, not Flux SOPS. To add a Kubernetes
secret to the manifests repo, seal it against the controller cert and commit the
`SealedSecret` (see the homelab repo's `scripts/secret.sh`):

```sh
kubectl -n <ns> create secret generic <name> --dry-run=client \
  --from-file=<field>=/dev/stdin -o yaml | kubeseal --cert sealed.crt -o yaml
```
