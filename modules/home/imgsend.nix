{...}: {
  flake.modules.homeManager.imgsend = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "imgsend";
        runtimeInputs =
          [pkgs.coreutils pkgs.gnugrep pkgs.openssh]
          ++ (
            if pkgs.stdenv.hostPlatform.isDarwin
            then [pkgs.pngpaste]
            else [pkgs.wl-clipboard]
          );
        text = builtins.readFile ./data/imgsend.sh;
      })
    ];
  };
}
