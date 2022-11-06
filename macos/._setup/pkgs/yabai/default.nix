{ lib, stdenv, fetchzip, fetchFromGitHub, runCommand, darwin }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    rev = "v4.0.2";
    sha256 = "sha256-SwoXH6d0blE+S5i4n0Y9Q8AJuQAAaQs+CK3y1hAQoPU=";
  };

  buildSymlinks = runCommand "build-symlinks" { } ''
    mkdir -p $out/bin
    ln -s /usr/bin/xxd /usr/bin/xcrun /usr/bin/xcodebuild /usr/bin/tiffutil /usr/bin/qlmanage $out/bin
    '';

  nativeBuildInputs = [ buildSymlinks ];

  buildInputs = with darwin.apple_sdk.frameworks; [
    Carbon
    Cocoa
    ScriptingBridge
    SkyLight
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
  '';

  meta = with lib; {
    description = ''
      A tiling window manager for macOS based on binary space partitioning
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    platforms = platforms.darwin;
    maintainers = with maintainers; [ cmacrae shardy ];
    license = licenses.mit;
  };
}
    # (final: prev: {
    #  yabai = let
    #    version = "4.0.0-dev";
    #    buildSymlinks = prev.runCommand "build-symlinks" { } ''
    #      mkdir -p $out/bin
    #      ln -s /usr/bin/xcrun /usr/bin/xcodebuild /usr/bin/tiffutil /usr/bin/qlmanage $out/bin
    #    '';
    #  in prev.yabai.overrideAttrs (old: {
    #    inherit version;
    #    src = inputs.yabai-src;
    #    buildInputs = with prev.darwin.apple_sdk.frameworks; [
    #      Carbon
    #      Cocoa
    #      ScriptingBridge
    #      prev.xxd
    #      SkyLight
    #    ];
    #    nativeBuildInputs = [ buildSymlinks ];
    #  });
    # })
