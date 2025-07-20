_: {
  grazor = {
    linux = {
      asServer = false;
      withBatterySave = false;
      k3sServer = true;

      withGuiApps = true;
      withGnome = true;
      withHyprland = false;
      withSteam = true;
    };

    services = {
      xray.enable = true;
    };
  };
}
