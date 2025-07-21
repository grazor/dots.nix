_: {
  grazor = {
    linux = {
      asServer = true;
      withBatterySave = true;
      k3sServer = false;

      withGuiApps = false;
      withGnome = false;
      withHyprland = false;
      withSteam = false;
    };

    services = {
      xray.enable = false;
    };
  };
}
