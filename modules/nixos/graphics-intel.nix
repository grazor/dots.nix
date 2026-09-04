# Intel iGPU with VAAPI acceleration.
{
  flake.modules.nixos.graphics-intel = {pkgs, ...}: {
    services.xserver.videoDrivers = ["modesetting"];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        # iHD, the driver for Gen9 and newer: Comet Lake (dell), Alder Lake
        # (nas), Raptor Lake (asus). The older i965 (intel-vaapi-driver) tops
        # out around Gen9 and cannot drive the Xe parts at all; it was also
        # overridden here with enableHybridCodec, which forced every host to
        # compile it from source for a hybrid VP9 path none of this hardware
        # needs -- they all decode VP9 natively.
        intel-media-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
}
