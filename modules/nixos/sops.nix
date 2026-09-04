# sops-nix defaults. Each host derives its age key from its SSH host key, so no
# extra key material lives in the repo. Individual secrets are declared next to
# their consumers: the k3s token and the `code` git key both live in
# modules/nixos/k3s.nix, next to the k3s aspects that use them.
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.sops = {
    sops = {
      defaultSopsFile = ../../secrets/k3s.yaml;
      validateSopsFiles = true;
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };
}
