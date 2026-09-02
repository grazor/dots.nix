# Incus dev container on the nas: the usual shell, tmux, nvf and dev tools for
# user `cloud`. Toolchains are not baked in; a project's own flake or
# `nix develop github:grazor/dots.nix#rust` provides them.
#
# Start from the stock image and take it over with this configuration (`-l`
# because `incus exec` does not know the NixOS PATH):
#
#   incus launch images:nixos/26.05 dev -p default -p share
#   incus exec dev -- bash -lc 'nixos-rebuild switch --flake github:grazor/dots.nix#lxc'
#   incus exec dev -- su - cloud
#
# Later, from inside (--refresh to skip nix's cached copy of the repo):
#   sudo nixos-rebuild switch --refresh --flake github:grazor/dots.nix#lxc
#
# Or bake an image once on the nas and spawn instances from it in seconds:
#
#   nix build -o meta   github:grazor/dots.nix#nixosConfigurations.lxc.config.system.build.metadata
#   nix build -o rootfs github:grazor/dots.nix#nixosConfigurations.lxc.config.system.build.tarball
#   incus image import --alias dots-lxc meta/tarball/*.tar.xz rootfs/tarball/*.tar.xz
#   incus launch dots-lxc dev -p default -p share
#
# The NixOS firewall stays on inside. Apps under test are reached through
# incus proxy devices, which enter over loopback, so nothing needs opening:
#   incus config device add dev web proxy listen=tcp:0.0.0.0:5173 connect=tcp:127.0.0.1:5173
{mkNixos, ...}: {
  flake.nixosConfigurations.lxc = mkNixos {
    aspects = m:
      with m; [
        base
        lxc-guest
        ssh-server
        tools
        devtools
        user-cloud
      ];

    machine = {
      system.stateVersion = "26.05";
    };
  };
}
