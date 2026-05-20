# SPDX-FileCopyrightText: © 2025 Jeffrey C. Ollie
# SPDX-License-Identifier: MIT

{
  description = "zig-uuid";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      lib = nixpkgs.lib;
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      makePackages =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        };
      forAllSystems = (function: lib.genAttrs platforms (system: function (makePackages system)));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.zig_0_16
            pkgs.pinact
            pkgs.reuse
          ];
        };
      });
    };
}
