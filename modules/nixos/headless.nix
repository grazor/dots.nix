# Headless / server behaviour: ignore the lid switch and blank the console.
{
  flake.modules.nixos.headless = {
    # Explicit for all three cases so a laptop server never sleeps on lid close.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
    boot.kernelParams = ["consoleblank=120"];
  };
}
