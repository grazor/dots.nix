# What every NixOS system shares, containers included: Nix itself, the shell,
# time zone and locale. `common` adds what only a real machine needs.
{inputs, ...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      settings = {
        experimental-features = "nix-command flakes";
        nix-path = ["nixpkgs=${inputs.nixpkgs.outPath}"];
        trusted-users = ["root" "@wheel"];
        # Keep dev-shell build deps across GC so direnv shells aren't rebuilt.
        keep-outputs = true;
        keep-derivations = true;
      };
    };

    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;

    environment.enableAllTerminfo = true;

    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
