{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    arduino
  ];
}
