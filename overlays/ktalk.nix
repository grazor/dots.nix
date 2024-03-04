{ stdenv, fetchurl, dpkg, lib, autoPatchelfHook, glib, nss, dbus, atk, cups, libdrm, gtk3, gtk4
, pango, cairo, expat, libX11, libXcomposite, libXdamage, libXext, libXrandr, libxcb, libXtst
, alsa-lib, mesa, popt, libxcrypt-legacy, makeShellWrapper

#
, wrapGAppsHook, at-spi2-atk, at-spi2-core
, fontconfig, freetype, gdk-pixbuf
, libcxx, libglvnd, libnotify, libpulseaudio, libuuid
, libXcursor, libXfixes
, wayland, libdbusmenu, libappindicator-gtk3, libXScrnSaver
, libXi, libXrender, libxshmfence, nspr
, systemd, libunity
, libGL

#, makeDesktopItem, lib, stdenv, makeShellWrapper, alsa-lib, 
#, 
#, systemd, writeScript, python3, runCommand
#, 
#, speechd
}:


let

  version = "2.9.0";


  sha256 = {
    "x86_64-linux" = "sha256-1ASXr3eChfxiTqco/2G954Frs3LKi+bV7ExHMzo6wd8=";
    "aarch64-linux" = "0wsv4mvwrvsaz1pwiqs94b3854h5l8ff2dbb1ybxmvwjbfrkdcqc";
  }."${stdenv.system}";

  arch = {
    "x86_64-linux" = "amd64";
    "aarch64-linux" = "aarch64";
  }."${stdenv.system}";

in stdenv.mkDerivation rec {
    pname = "ktalk";
    inherit version;

  src = fetchurl {
    url = "https://st.ktalk.host/ktalk-app/linux/ktalk${version}${arch}.deb";
    inherit sha256;
  };

  nativeBuildInputs = [
    dpkg
    alsa-lib
    autoPatchelfHook
    cups
    libdrm
    libuuid
    libXdamage
    libX11
    libXScrnSaver
    libXtst
    libxcb
    libxshmfence
    mesa
    nss
    libxcrypt-legacy
    popt
    wrapGAppsHook
	makeShellWrapper
  ];

  dontWrapGApps = true;

  libPath = lib.makeLibraryPath ([
    libcxx
    systemd
    libpulseaudio
    libdrm
    mesa
    stdenv.cc.cc
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libglvnd
    libnotify
    libX11
    libXcomposite
    libunity
    libuuid
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    nspr
    libxcb
    pango
    libXScrnSaver
    libappindicator-gtk3
    libdbusmenu
    wayland
  ]);

  runtimeDeps = [libGL];


  unpackPhase = "${dpkg}/bin/dpkg-deb -x $src .";

  installPhase = ''
        mkdir -p $out/bin
        cp -r usr/share $out
        cp -r opt $out

        ln -s "$out/opt/Толк/ktalk" "$out/bin/ktalk"

        wrapProgramShell $out/bin/ktalk \
            "''${gappsWrapperArgs[@]}" \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
            --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
            --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/Толк

        chmod -R g-w $out
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/ktalk.desktop \
      --replace /opt/Толк/ $out/bin/
  '';

  meta = {
    description = "Ktalk";
    homepage = "https://kontur.ru/talk";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-linux" "x86_64-linux" ];
  };
}
