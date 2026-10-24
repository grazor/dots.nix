# Sunshine game-stream host for Moonlight clients on the LAN (the mac). Pair
# once in the web UI at https://desktop:47990; apps and settings live there
# too, since declaring either here makes the config file read-only.
{
  flake.modules.nixos.sunshine = {
    lib,
    pkgs,
    ...
  }: {
    services = {
      sunshine = {
        enable = true;
        autoStart = true;
        # KMS capture of the GNOME Wayland session needs CAP_SYS_ADMIN.
        capSysAdmin = true;
        openFirewall = true;
        # CUDA hands captured frames to NVENC; without it Sunshine falls back to
        # software encoding. Unfree, so it builds locally once and then comes
        # from the Attic cache.
        package = pkgs.sunshine.override {cudaSupport = true;};
      };

      # Moonlight finds the host over mDNS. The nixpkgs sunshine module still
      # sets the obsolete avahi.publish.* options, which warn on every eval;
      # null them and set what they stood for directly.
      avahi = {
        publish.enable = lib.mkForce null;
        publish.userServices = lib.mkForce null;
        settings.publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
        };
      };

      # Sunshine is a user service tied to the graphical session, so after a
      # reboot there must be one to stream instead of the GDM greeter.
      displayManager.autoLogin = {
        enable = true;
        user = "g";
      };
    };
    # GNOME autologin races the getty on tty1 and lands on a black screen.
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
