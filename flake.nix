# SPDX-FileCopyrightText: © 2025 Jeffrey C. Ollie
# SPDX-License-Identifier: MIT

{
  description = "zig-uuid";

  inputs = {
    nixpkgs = {
      url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    };
    # The toolchain is the official 0.17.0 release binary, packaged by the
    # overlay, rather than nixpkgs' Zig.
    zig = {
      url = "git+https://git.jcollie.dev/jeff/zig-overlay.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zon2nix = {
      url = "github:jcollie/zon2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      zig,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      makePackages =
        system:
        import nixpkgs {
          inherit system;
        };
      zigFor = system: zig.packages.${system}."0.17.0";
      # Only the systems the overlay has a Zig for.
      forAllSystems = lib.genAttrs (
        builtins.filter (system: zig.packages ? ${system}) lib.systems.flakeExposed
      );
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = makePackages system;
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.git-pages-cli
              pkgs.pinact
              pkgs.reuse
              (zigFor system)
            ];
          };
        }
      );
    };
}
