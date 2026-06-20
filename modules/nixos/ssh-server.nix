# OpenSSH server with password auth disabled. Authorized keys are attached to
# each host's primary user (see modules/nixos/users.nix).
{
  flake.modules.nixos.ssh-server = {
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
  };
}
