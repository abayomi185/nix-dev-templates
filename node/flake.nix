{
  description = "Node development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [
        (final: prev: {
          nodejs = prev.nodejs_20;
          bun = prev.bun;
        })
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
      };
    in {
      devShell =
        pkgs.mkShell
        {
          packages = with pkgs; [node2nix nodejs bun];
        };
    });
}
