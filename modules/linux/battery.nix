{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.linux;
  opt = "withBatterySave";
in {
  options.grazor.linux.${opt} = lib.mkEnableOption "battery save mode";
  config = lib.mkIf cfg.${opt} {
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        START_CHARGE_THRESH_BAT0 = 30; # 30 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 60; # 60 and above it stops charging
      };
    };
  };
}
