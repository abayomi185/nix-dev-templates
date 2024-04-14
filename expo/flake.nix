{
  description = "Expo dev environment";

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
        (final: prev: rec {
          nodejs = prev.nodejs_18;
          yarn = prev.yarn.override {inherit nodejs;};
        })
      ];
      pkgs = import nixpkgs {
        inherit overlays system;
      };
      buildDeps = with pkgs; [git];
      devDeps = with pkgs;
        buildDeps
        ++ [
          node2nix
          nodejs
          yarn
          prettierd
          yaml-language-server
          nodePackages.typescript-language-server
          nodePackages.expo-cli
          nodePackages.eas-cli
        ];
    in {
      devShell = pkgs.mkShell {buildInputs = devDeps;};
    });
}
