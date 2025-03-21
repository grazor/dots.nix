_: let
  shellInitLast = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    fish_add_path -p ~/.bin
    fish_add_path -p ~/.avito/bin
  '';
in {
  home.stateVersion = "24.11";

  imports = [
    (import ../_common/home/fish.nix {inherit shellInitLast;})
    ../_common/home/scripts.nix
    ../_common/home/git.nix
  ];
}
