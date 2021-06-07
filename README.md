# Nixos and home config

## Installation

```bash
nix-channel --add https://channels.nixos.org/nixos-unstable
nix-channel --update

ln -s ${pwd} /etc/nixos
sudo nixos-rebuild switch --flake '/etc/nixos#<device>'
```

## Add new device

```bash
mkdir ./hosts/<device>
nixos-generate-config --show-hardware-config > ./hosts/<device>/hardware.nix
```
