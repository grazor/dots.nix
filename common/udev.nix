{ ... }:

{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", SYMLINK+="arduino"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0660", SYMLINK+="ttyArduinoUno"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", SYMLINK+="ttyArduinoNano2"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0660", SYMLINK+="ttyArduinoNano"

    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a0", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11a0", ATTRS{idProduct}=="db20", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11a0", ATTRS{idProduct}=="eb20", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a2", MODE="0666"

    SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", ATTRS{product}=="C922 Pro Stream Webcam", RUN="v4l2-ctl -d $devnode --set-ctrl=zoom_absolute=120 --set-ctrl=backlight_compensation=1"
  '';
}

