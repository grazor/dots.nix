_: {
  grazor = {
    linux = {
      asServer = true;

      k3sServer = false;
      k3sAgent = true;
      k3sServerAddt = "https://192.168.2.2:6443";

      # no battery
      withBatterySave = false;

      withGuiApps = false;
      withGnome = false;
      withHyprland = false;
      withSteam = false;
    };
  };
}
