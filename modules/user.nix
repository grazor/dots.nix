{lib, ...}: {
  options.grazor.user = with lib; {
    uid = mkOption {
      type = types.int;
    };
    name = mkOption {
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
