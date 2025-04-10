{lib, ...}: {
  options.grazor.user = with lib; {
    uid = mkOption {
      type = types.int;
    };
    name = mkOption {
      type = types.str;
    };
    gid = mkOption {
      type = types.int;
    };
    group = mkOption {
      type = types.str;
    };
    home = mkOption {
      type = types.str;
    };
    shell = mkOption {
      type = types.shellPackage;
    };
  };
}
