# Thank god for the zoom-us repo, lots of this is based on that
# I tried to patch the binary but it hard depends on /usr/gsettings and almost certainly some other stuff
# TODO Test in a vm that it works outside my system
# TODO Update script
# TODO Desktop file [done]
# TODO Link plugin somewhere useful
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

	dontConfigure = true;
	dontBuild = true;

	unpackPhase = ''
      dpkg -x $src .
    '';

	installPhase = ''
	  runHook preInstall

      mkdir -p $out
	  cp -r usr/* $out

	  runHook postInstall
	'';
  };
in
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
	stdenv.cc.cc
	alsa-lib
	dconf
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
  ];

  extraBwrapArgs = [ 
    "--bind $HOME $HOME" 
  ];
  # Links vst3 plugin to ~/.vst3 and adds desktop file to output
  extraInstallCommands = ''
	cp -r ${numaplayer}/lib $out/lib
	mkdir -p ~/.vst3
    ln -s $out/lib/vst3/Numa\ Player.vst3 ~/.vst3/Numa\ Player.vst3
	
    cp -r ${numaplayer}/share $out/share
    substituteInPlace \
      $out/share/applications/Numa\ Player.desktop \
      --replace-fail /bin/ $out/bin/
  '';

  runScript = "'/bin/Numa Player'";

  meta = {
    homepage = "https://www.studiologic-music.com/products/numaplayer/";
	description = "Virtual instrument and DAW plugin";
	sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
	platforms = [ "x86_64-linux" ];
	maintainers = with lib.maintainers; [ sabrinaishere ];
	mainProgram = "Numa\ Player";
	#license = lib.licenses.unfree; Todo Re-enable when done debugging
  };
}
