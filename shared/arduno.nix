{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ arduino ];

  environment.sessionVariables = { "_JAVA_AWT_WM_NONREPARENTING" = "1"; };
}
