{
  description = "Templates for flake-driven environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [
          (
            final: prev:
              let
                exec = pkg: "${prev.${pkg}}/bin/${pkg}";
              in
              {
                format = prev.writeScriptBin "format" ''
                  ${exec "nixpkgs-fmt"} **/*.nix
                '';
                update = prev.writeScriptBin "update" ''
                  for dir in `ls -d */`; do # Iterate through all the templates
                    (
                      cd $dir
                      ${exec "nix"} flake update # Update flake.lock
                      ${exec "nix"} flake check  # Make sure things work after the update
                    )
                  done
                '';
              }
          )
        ];
        pkgs =
          import nixpkgs
            {
              inherit system overlays;
            };
      in
      with pkgs; {
        devShells.default = mkShell {
          buildInputs = [
            format
            update
          ];
        };
        templates = {
          rust = {
            path = ./rust;
            description = "Rust development environment";
          };
          go = {
            path = ./go;
            description = "Go development environment";
          };
        };
      }
    );
}
