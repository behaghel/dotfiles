{ pkgs, lib, stdenv, fetchFromGitHub }:

let
  arch = if stdenv.isAarch64 then "arm" else "x86";
in

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "ee5Fe1scu24B5lCTKA3BUJ2NmbnTxRh13vE4QbCQl4o=";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon Cocoa SkyLight
  ];

  buildPhase = ''
    make ${arch}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar_${arch} $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A custom macOS statusbar with shell plugin, interaction and graph support";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
