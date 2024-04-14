{
  description = "Templates for flake-driven environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    overlays = [
      (final: prev: let
        exec = pkg: "${prev.${pkg}}/bin/${pkg}";
      in {
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
      })
    ];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    # System-specific outputs
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          format
          update
        ];
      };
    });

    # Non-system-specific outputs
    templates = {
      expo = {
        path = ./expo;
        description = "Expo development environment";
      };
      go = {
        path = ./go;
        description = "Go development environment";
      };
      rust = {
        path = ./rust;
        description = "Rust development environment";
      };
    };

    rust = ./rust/flake.nix;
    go = ./rust/go.nix;
    expo = ./expo/flake.nix;
  };
}
