# sops-nix defaults. Each host derives its age key from its SSH host key, so no
# extra key material lives in the repo. Individual secrets are declared next to
# their consumers (k3s token in modules/nixos/k3s.nix; Flux/Sealed Secrets keys
# in the flux-bootstrap module; the dell `code` key in hosts/dell).
{
  flake.modules.nixos.sops = {
    sops.defaultSopsFile = ../../secrets/k3s.yaml;
    sops.validateSopsFiles = true;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
