{ pkgs ? import <nixpkgs> { }
}:
with pkgs;
stdenv.mkDerivation {
  name = "gcc linaro 7.2.1";
  src = fetchzip {
    url =
      "https://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabi/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz";
    sha256 =
      "sha256-iiFgWIPcb6MKZkMOhl9qVROE/cILWDXY8vcaoDZBh5Q=";
  };

  nativeBuildInputs = [
    lzma
    expat
    autoPatchelfHook
  ];

  configurePhase = ''
    # remove gdb for now, as its missing dependencies
    rm bin/arm-linux-gnueabi-gdb lib/libcc1.so.0.0.0
    rm lib/gcc/arm-linux-gnueabi/7.2.1/plugin/libcc1plugin.so.0.0.0
    rm lib/gcc/arm-linux-gnueabi/7.2.1/plugin/libcp1plugin.so.0.0.0
    '';

  installPhase = ''cp -R . $out '';
}

