{ stdenv, fetchurl, dpkg, lib, autoPatchelfHook, glib, nss, dbus, atk, cups, libdrm, gtk3, gtk4
, pango, cairo, expat, libX11, libXcomposite, libXdamage, libXext, libXrandr, libxcb, libXtst
, alsa-lib, mesa, popt, libxcrypt-legacy }:

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

in stdenv.mkDerivation {
	pname = "ktalk";
	inherit version;

  src = fetchurl {
    url = "https://st.ktalk.host/ktalk-app/linux/ktalk${version}${arch}.deb";
    inherit sha256;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    atk
	popt
    dbus
	libxcrypt-legacy
    cups
	mesa
    gtk3
    libxcb
    pango
    expat
    cairo
    libdrm
    libX11
    glib
    nss
    libXcomposite
    libXdamage
    libXext
    libXrandr
  ];

  runtimeDependencies = [ gtk3 gtk4 libXtst mesa glib ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "${dpkg}/bin/dpkg-deb -x $src .";

  installPhase = ''
        mkdir -p $out/bin
    	cp -r usr/share $out
        cp -r opt $out

    	ln -s "$out/opt/Толк/ktalk" "$out/bin/ktalk"

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
