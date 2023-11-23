{
  description = "Rust library for artificial intelligence";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, naersk, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        toolchain = fenix.packages.${system}.complete;

        naersk-lib = naersk.lib.${system}.override {
          inherit (toolchain) cargo rustc;
        };

        libai = naersk-lib.buildPackage {
          name = "libai";
          src = ./.;
        };
      in {
        packages.libai = libai;
        defaultPackage = self.packages.${system}.libai;

        devShell = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
          nativeBuildInputs = [
            (toolchain.withComponents [
              "cargo" "rustc" "rust-src" "rustfmt" "clippy"
            ])
          ];
          RUST_BACKTRACE = 0;
        };
      });
}
