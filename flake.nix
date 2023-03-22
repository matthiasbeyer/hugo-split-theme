{
  description = "The mmbeyer.de website hugo style";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };

      theme = pkgs.stdenv.mkDerivation {
        name = "hugo-split-theme";

        src =
          let
            markdownFilter = path: _type: pkgs.lib.hasSuffix ".md" path;
            filterPath = path: type: builtins.any (f: f path type) [
              markdownFilter
              pkgs.lib.cleanSourceFilter
            ];
          in
          pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = filterPath;
          };

        phases = [ "unpackPhase" "buildPhase" ];

        buildPhase = ''
          mkdir $out
          cp -r ./* $out/
        '';
      };
    in
    rec {
      checks = {
        inherit theme;
        default = checks.theme;
      };

      packages = {
        inherit theme;
        default = packages.theme;
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.hugo
        ];
      };
    });
}
