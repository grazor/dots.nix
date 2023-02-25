{ pkgs, lib, config, ... }:

with lib;

{
  home.packages = with pkgs; [
	eww-wayland # bar
	pamixer
	brightnessctl
	(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

	# configuration
	xdg.configFile."eww/eww.scss".source = ./eww.scss;
	xdg.configFile."eww/eww.yuck".source = ./eww.yuck;

	# scripts
	xdg.configFile."eww/scripts/battery.sh" = {
		source = ./scripts/battery.sh;
		executable = true;
	};

	xdg.configFile."eww/scripts/wifi.sh" = {
		source = ./scripts/wifi.sh;
		executable = true;
	};

	xdg.configFile."eww/scripts/brightness.sh" = {
		source = ./scripts/brightness.sh;
		executable = true;
	};

	xdg.configFile."eww/scripts/workspaces.sh" = {
		source = ./scripts/workspaces.sh;
		executable = true;
	};

	xdg.configFile."eww/scripts/workspaces.lua" = {
		source = ./scripts/workspaces.lua;
		executable = true;
	};
}

