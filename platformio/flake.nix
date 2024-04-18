{
  description = "PlatfomIO dev environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3;
        python_w_pkgs = python.withPackages (p:
          with p; [
            pip
          ]);
      in {
        devShells.default = pkgs.mkShell {
          buildInputs =
            [
              python_w_pkgs
            ]
            ++ (with pkgs; [
              platformio
              esptool
            ]);

          shellHook = ''
            PYTHONPATH=${python_w_pkgs}/${python_w_pkgs.sitePackages}
          '';
        };
      }
    );
}
