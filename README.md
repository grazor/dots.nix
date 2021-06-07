# Nixos and home config

## Installation

```bash
nix-channel --add https://channels.nixos.org/nixos-unstable
nix-channel --update

# nixos-generate-config --show-hardware-config > ./hardware/<device>.nix
ln -s ${pwd} /etc/nixos
sudo nixos-rebuild switch --flake '/etc/nixos#<device>'
```
