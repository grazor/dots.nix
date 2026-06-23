{inputs, ...}: {
  flake-file.inputs.workmux = {
    url = "github:raine/workmux";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.workmux = {pkgs, ...}: {
    home.packages = [
      inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.configFile."workmux/config.yaml".text = ''
      agent: codex
      mode: window
      window_prefix: wm-
      panes:
        - command: <agent>
          focus: true
        - split: horizontal
    '';
  };
}
