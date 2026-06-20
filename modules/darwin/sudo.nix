# Touch ID for sudo (with tmux reattach so it works inside tmux).
{
  flake.modules.darwin.sudo = {
    security.pam.services.sudo_local.touchIdAuth = true;
    security.pam.services.sudo_local.reattach = true;
  };
}
