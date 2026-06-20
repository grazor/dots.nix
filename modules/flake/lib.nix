# Host builders, exposed as module args so each host file under modules/hosts/
# can declare its own configuration. `aspects` receives the merged
# flake.modules.<class> set; `machine` is the host-specific module
# (hostname, filesystems, facter report, ...).
{
  inputs,
  config,
  ...
}: {
  _module.args.mkNixos = {
    system ? "x86_64-linux",
    aspects ? (_: []),
    machine,
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules =
        (aspects config.flake.modules.nixos)
        ++ [
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.nixos-facter-modules.nixosModules.facter
          machine
        ];
    };

  _module.args.mkDarwin = {
    system ? "aarch64-darwin",
    aspects ? (_: []),
    machine,
  }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules =
        (aspects config.flake.modules.darwin)
        ++ [
          inputs.home-manager.darwinModules.home-manager
          machine
        ];
    };
}
