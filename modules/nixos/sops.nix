# sops-nix defaults. Each host derives its age key from its SSH host key, so no
# extra key material lives in the repo. Individual secrets are declared next to
# their consumers (e.g. the k3s token in modules/nixos/k3s.nix).
#
# `validateSopsFiles` is off so the flake evaluates before the placeholder
# secrets file has been encrypted on a real host. Flip it back to `true` once
# secrets/k3s.yaml is a real sops file (see README).
{
  flake.modules.nixos.sops = {
    sops.defaultSopsFile = ../../secrets/k3s.yaml;
    sops.validateSopsFiles = false;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };
}
