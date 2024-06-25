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
        forEachDir = exec: ''
          for dir in */; do
            (
              cd "''${dir}"

              ${exec}
            )
          done
        '';
      in {
        format = prev.writeScriptBin "format" ''
          ${exec "alejandra"} **/*.nix
        '';
        check = final.writeShellApplication {
          name = "check";
          text = forEachDir ''
            echo "checking ''${dir}"
            nix flake check --all-systems --no-build
          '';
        };
        update = final.writeShellApplication {
          name = "update";
          text = forEachDir ''
            echo "updating ''${dir}"
            nix flake update
          '';
        };
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
  };
}
