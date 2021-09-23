let nixpkgs = import <nixpkgs> {};
in nixpkgs.buildFHSUserEnv {
   name = "fhs";
   targetPkgs = pkgs: [];
   multiPkgs = pkgs: [ pkgs.dpkg ];
   runScript = "bash";
}
