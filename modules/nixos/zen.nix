# Zen browser, wrapped with managed extensions and policies.
{inputs, ...}: {
  flake-file.inputs.zen-browser = {
    url = "github:youwen5/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.zen = {
    pkgs,
    lib,
    ...
  }: let
    extension = shortId: guid: {
      name = guid;
      value = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
        installation_mode = "normal_installed";
      };
    };

    prefs = {
      "extensions.autoDisableScopes" = 0;
      "extensions.pocket.enabled" = false;
    };

    extensions = [
      (extension "ublock-origin" "uBlock0@raymondhill.net")
      (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
      (extension "foxyproxy-standard" "foxyproxy@eric.h.jung")
      (extension "sponsorblock" "sponsorBlocker@ajay.app")
    ];
  in {
    environment.systemPackages = [
      (pkgs.wrapFirefox
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
        {
          extraPrefs = lib.concatLines (
            lib.mapAttrsToList (
              name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
            )
            prefs
          );

          extraPolicies = {
            DisableTelemetry = true;
            ExtensionSettings = builtins.listToAttrs extensions;
            SearchEngines.Default = "ddg";
          };
        })
    ];
  };
}
