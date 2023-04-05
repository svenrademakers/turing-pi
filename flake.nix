{
  description = "Turing-pi depelopment and deployment flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    turing_pi = {
      url = "./bmc4tpi";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, nix-filter, turing_pi }:
    let 
    system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
  };
  in
    with pkgs;
  {
    packages."x86_64-linux" =rec { 

      cross_compiler = callPackage ./gcc_linaro.nix {};

      kernel_image = stdenvNoCC.mkDerivation {
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
      };

      default = kernel_image;
    };

    devShells."x86_64-linux" = {
      default = stdenv.mkDerivation rec {
        name = "native development shell";
        src = self;
      };
    };
  };
}
