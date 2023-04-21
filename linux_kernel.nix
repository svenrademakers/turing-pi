{ pkgs ? import <nixpkgs> { }, 
    turing_pi ? {
      url = "./bmc4tpi";
      flake = false;
    },
 cross_compiler,
}:
with pkgs;
stdenv.mkDerivation {
        name = "linux 5.4 100ask_t113-pro";
        src = fetchgit {
          url =
            "https://e.coding.net/weidongshan/100ask_t113-pro/linux-5.4.git";
          rev =
            "5112fdd843715f1615703ca5ce2a06c1abe5f9ee";
          sha256= "sha256-Tk+NOASjEMfxZhu0Q6/9/M5K4hHskEoO7VA2y5LCdUk=";
        };

        nativeBuildInputs = [ 
          cross_compiler
          gcc11
          flex
          bison
          coreutils
          libelf
          bc
          autoPatchelfHook
        ];

        makeFlags = [
          "ARCH=arm"
          "CROSS_COMPILE=arm-linux-gnueabi-"
        ];

       configurePhase = ''
          patchShebangs scripts/* 
         '';

       buildPhase = ''
         cp ${turing_pi}/config/kernelconfig .config
         make $makeFlags oldconfig
         make $makeFlags V=1 -j$NIX_BUILD_CORES
         '';

        installPhase = ''cp -R . $out '';
        dontFixup = true;
        dontStrip = true;
      }

