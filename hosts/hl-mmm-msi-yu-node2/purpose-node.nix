_: {
  grazor = {
    linux = {
      asServer = true;
      k3sServer = false;

      # no battery
      withBatterySave = false;

      withGuiApps = false;
      withGnome = false;
      withHyprland = false;
      withSteam = false;
    };
  };
}
