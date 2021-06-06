# Nixos and home config

## Installation

```bash
nix-channel --add https://channels.nixos.org/nixos-unstable
nix-channel --update

# nixos-generate-config --show-hardware-config > ./hardware/<device>.nix
echo <device> > installation
ln -s ${pwd} /etc/nixos
nixos-rebuild switch
```
