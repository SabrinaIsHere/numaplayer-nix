{ 
  stdenv,
  wrapGAppsHook3,
  fetchurl,
  pkgs,
  buildFHSEnvBubblewrap,
  lib,
}:
let
  pname = "numaplayer";
  version = "2.1.8";
  numaplayer = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://www.studiologic-music.com/api/get-files/NumaPlayer_${version}.deb";
      sha256 = "sha256-6GVQ4KiX9y4odDr85kqN+3kZP7+Ac/W+lnbmLiJ/rv0=";
    };

	buildInputs = with pkgs; [
      dpkg
	];

	nativeBuildInputs = [ 
      wrapGAppsHook3
	];

	unpackPhase = ''
      dpkg -x $src .
    '';

	installPhase = ''
	  runHook preInstall

      mkdir -p $out/opt/numaplayer
	  install -m755 -D usr/bin/Numa\ Player $out/opt/numaplayer
	  ln -s /home $out/home

	  runHook postInstall
	'';
  };
in
# This binary hard depends on /usr/bin/gsettings unfortunately
buildFHSEnvBubblewrap {
  inherit numaplayer;
  name = pname;

  targetPkgs = with pkgs; pkgs: [
    numaplayer
	freetype
	fontconfig
	curl
	glib
    glib.dev
	pipewire
    #libselinux
	stdenv.cc.cc
	alsa-lib
	#alsa-utils
	dconf
	#xdg-desktop-portal-wlr
    #at-spi2-atk
    #at-spi2-core
    #atk
    #cairo
    #coreutils
    #cups
    #dbus
    #expat
    #freetype
    #gdk-pixbuf
    #gtk3
    #libGL
    #libGLU
    #libdrm
    #libgbm
    #libkrb5
    #libxkbcommon
    #nspr
    #nss
    #pango
    #pciutils
    #pipewire
    #procps
    #qt5.qt3d
    #qt5.qtgamepad
    #qt5.qtlottie
    #qt5.qtmultimedia
    #qt5.qtremoteobjects
    #qt5.qtxmlpatterns
    #stdenv.cc.cc
    #udev
    #util-linux
    #wayland
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    #zlib
  ];
  
  extraBwrapArgs = [ "--bind /home /home" ];

  #multiPkgs = pkgs: [
  #  pkgs.alsa-lib
  #];

  runScript = "'/opt/numaplayer/Numa Player'";

  meta = with lib; {
    homepage = "https://www.studiologic-music.com/products/numaplayer/";
	description = "Virtual instrument and DAW plugin";
	platforms = platforms.linux;
	#license = licenses.unfree; Todo Re-enable when done debugging
  };
}
