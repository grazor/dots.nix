# TLP power management + Intel thermal daemon.
{
  flake.modules.nixos.battery = {
    # Reacts to the package approaching its thermal limit instead of leaving
    # everything to hardware throttling.
    services.thermald.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        # Hosts using this module are headless nodes that live on AC
        # permanently, so the AC branch is the only one that really runs.
        # Treating AC as "desktop burst" pinned the i7-10850H near max turbo
        # even at ~5% load and cooked the lid-closed chassis.
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # intel_pstate still climbs under real load; these only bias the
        # idle/light-load behaviour, which is where the heat was being wasted.
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        # 70% of the 5.1 GHz max turbo is ~3.6 GHz, still well above the 2.7 GHz
        # base clock. Power scales super-linearly with frequency, so the top of
        # the turbo range costs far more heat than it buys throughput here.
        CPU_MAX_PERF_ON_AC = 70;
        CPU_MIN_PERF_ON_BAT = 0;
        # Battery means a power outage here, not portable use — the node keeps
        # serving k3s, so don't starve it.
        CPU_MAX_PERF_ON_BAT = 50;

        # Dell EC thermal/fan profile; it powers on as "performance", which
        # holds a high sustained power limit and runs hot at idle.
        # Choices on the Dell: cool quiet balanced performance.
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "cool";

        # Needs firmware support for charge thresholds; verify with `tlp-stat -b`.
        START_CHARGE_THRESH_BAT0 = 30;
        STOP_CHARGE_THRESH_BAT0 = 60;
      };
    };
  };
}
