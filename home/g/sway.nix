{ pkgs, home, ... }:

{
	wayland.windowManager.sway.enable = true;

home.packages = with pkgs; [
  swaylock # lockscreen
  swayidle # idle manager
  waybar # bar
  wofi # launcher
  mako # notification daemon
  termite # terminal emulator
  kanshi # hotplug displays

  wl-clipboard # clipboard tool
  clipman # clipboard manager
  slurp # screen area selection
  grim # image grabber

  flashfocus # window focus animation
  autotiling # smart tiling
];

	wayland.windowManager.sway.config = {
		terminal = "termite";
		menu = "${pkgs.rofi} -show run";
		modifier = "Mod4";


		bars."bar".command = "swaybar_command waybar";

	};


}
