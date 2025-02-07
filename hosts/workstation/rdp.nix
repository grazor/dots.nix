{ ... }:

{
  services.rustdesk-server = {
    enable = true;
    signal.enable = false;
    relay.enable = false;
  };
}
