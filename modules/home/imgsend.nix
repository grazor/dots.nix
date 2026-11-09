{...}: {
  # The scripts aspect links bin/imgsend; this aspect supplies its tools.
  flake.modules.homeManager.imgsend = {pkgs, ...}: {
    home.packages =
      [pkgs.coreutils pkgs.gnugrep pkgs.openssh]
      ++ (
        if pkgs.stdenv.hostPlatform.isDarwin
        then [pkgs.pngpaste]
        else [pkgs.wl-clipboard]
      );
  };
}
