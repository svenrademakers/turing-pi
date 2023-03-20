{
  description = "Turing-pi depelopment and deployment flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, nix-filter }:
    let 
    system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
  };
  in
    with pkgs;
  {
    packages."x86_64-linux" =rec { 
      turing_pi = stdenv.mkDerivation {
        name = "turing_pi";
        version = "0.0.1";
        __noChroot = true;
        src = ./.;
        dontConfigure = true;
        installPhase = ''
          # this package does not have any artifacts as it used as a source
          # input for the buildroot derivation.
          cp -r . $out
          '';
      };

      buildroot = stdenv.mkDerivation {
        name = "buildroot";
        src = fetchzip {
          url = "https://buildroot.org/downloads/buildroot-2022.02.1.tar.gz";
          sha256 =
            "sha256-J6MS6+UHeRU95Np3PIZOiG5bHJgogLaB0BbhqC/RkTQ=";
        };

        nativeBuildInputs = [ 
          turing_pi 
          which 
          coreutils
          perl 
          unzip
          file
          rsync
          cpio
          git
          bc
          wget
          flock
        ];

       configurePhase = ''
         cp ${turing_pi.src}/.config . 
         '';

        makeFlags = [
            "BR2_EXTERNAL=${turing_pi.out}/br2t113pro"
        ];

        buildPhase = ''
           file support/scripts/br2-external
           patchShebangs support/scripts/br2-external
           patchShebangs support/dependencies/dependencies.sh
           patchShebangs support/scripts/*
           patchShebangs support/download/*
           make $makeFlags 100ask_t113-pro_spinand_core_defconfig
         cp ${turing_pi.src}/.config . 
         make V=1
          '';
      dontInstall=true;
      };

      default = buildroot;
    };

    devShells."x86_64-linux" = {
      default = stdenv.mkDerivation rec {
        name = "native development shell";
        src = self;
      };
    };
  };
}
