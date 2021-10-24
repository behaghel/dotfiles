with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "i3-autodisplay";
  src = fetchurl { url = "https://github.com/lpicanco/i3-autodisplay/releases/download/v0.5/i3-autodisplay-0.5-linux-amd64"; sha256 = "1j5dk9b2kfai85ypb90027wghr1fskg7fzggfwlqfphwni8fp7ic"; };
  # src = [ ./i3-autodisplay-0.5-linux-amd64 ];
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ makeWrapper ];
  unpackPhase = "cp $src $name";
  buildPhase = "chmod +x $name";
  installPhase = "mkdir -p $out/bin; mv $name $out/bin";
}
