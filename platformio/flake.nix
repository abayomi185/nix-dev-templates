{
  description = "PlatfomIO dev environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: let
      python = pkgs.python3;
      python_w_pkgs = python.withPackages (p: with p; [pip]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          platformio
          esptool
        ];

        shellHook = ''
          PYTHONPATH=${python_w_pkgs}/${python_w_pkgs.sitePackages}
        '';
      };
    });
  };
}
