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
    packages."x86_64-linux" = rec { 

      cross_compiler = callPackage ./gcc_linaro.nix {};

      tpi_bmc = stdenv.mkDerivation {
        name ="tpi_bmc";
        src = ./app/bmc;
        buildInputs = [ cjson  which];
        configurePhase = '' which gcc '';
      };

      kernel_image = callPackage ./linux_kernel.nix { cross_compiler= cross_compiler;};
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
