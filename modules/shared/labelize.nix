# Preview ZPL/EPL label files from the shell:
#
#   zpl label.zpl -o label.png                  # shorthand for `labelize convert`
#   labelize convert label.zpl -t pdf --width 102 --height 76 --dpmm 8
#
# labelize renders Zebra (ZPL) and Eltron (EPL) label data locally — the
# offline equivalent of pasting into labelary.com, which is otherwise the only
# practical previewer. Checked against Labelary's own render of a
# text + Code 128 + QR + box label: the two are visually identical.
#
# Nothing ZPL-related is in nixpkgs (no package, no NixOS option), so it is
# built from source here. The dependency tree is pure Rust — image, imageproc
# and ab_glyph rather than fontconfig/freetype — so it needs no system
# libraries on either darwin or NixOS.
#
# Its own aspect rather than another line in `tools`, for the reason
# `mediatools` gives: none of this is in the binary cache, so every host taking
# the aspect compiles it. Attach it where labels are actually previewed.
#
# To bump: set `version`, replace `hash`/`cargoHash` with `lib.fakeHash` and
# take the `got:` line from each of the two resulting build failures.
let
  package = pkgs: let
    labelize = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
      pname = "labelize";
      version = "1.5.0";

      src = pkgs.fetchFromGitHub {
        owner = "GOODBOY008";
        repo = "labelize";
        tag = "v${finalAttrs.version}";
        hash = "sha256-LzOfZ0nnHBB2lRvgg3QcS6uYhfepDpjO5kBLG7cT/0o=";
      };

      cargoHash = "sha256-lsUk4vzMnfnLMVgcFQ+fCzLP2e1Hi/TyZwvtbJrreLs=";

      # The binary is gated behind `cli`. The `serve`/`playground` features add
      # axum + tokio for the HTTP mode, which is the cluster's job, not a
      # workstation's.
      buildFeatures = ["cli"];

      # The test suite's dev-dependencies pull in reqwest, and with it a TLS
      # stack, purely so the e2e tests can diff renders against the live
      # Labelary API — which the build sandbox has no network for, and which
      # those tests skip when unreachable. Nothing is verified by paying for
      # that, so the checks are off.
      doCheck = false;

      meta = {
        description = "Fast ZPL & EPL label parser and renderer";
        homepage = "https://github.com/GOODBOY008/labelize";
        license = with pkgs.lib.licenses; [mit bsd3];
        mainProgram = "labelize";
        platforms = pkgs.lib.platforms.unix;
      };
    });
  in [
    labelize

    # `convert` is the only subcommand used interactively, and typing it every
    # time is the difference between a tool that gets used and one that does
    # not. Every `labelize convert` flag still applies: `-o`, `-t pdf`,
    # `--width`, `--height`, `--dpmm`, `--antialias`.
    (pkgs.writeShellScriptBin "zpl" ''
      exec ${labelize}/bin/labelize convert "$@"
    '')
  ];

  aspect = {pkgs, ...}: {environment.systemPackages = package pkgs;};
in {
  flake.modules.nixos.labelize = aspect;
  flake.modules.darwin.labelize = aspect;
}
