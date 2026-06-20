# Headless / server behaviour: ignore the lid switch and blank the console.
{
  flake.modules.nixos.headless = {
    services.logind.settings.Login.HandleLidSwitch = "ignore";
    boot.kernelParams = ["consoleblank=120"];
  };
}
