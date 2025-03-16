{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3
    shfmt
    shellcheck

    file
    git
    jq
    gnumake
    ripgrep
    k9s
  ];
}
