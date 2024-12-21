{
  description = "Python development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: let
      python = pkgs.python312;
      pythonPackages = pkgs.python312Packages;
    in {
      default = pkgs.mkShell {
        venvDir = ".venv";
        packages = with pkgs;
          [
            python
            pyright
            black
            isort
            vscode-extensions.ms-python.debugpy
          ]
          ++ (with pythonPackages; [
            pip
            venvShellHook
          ]);
      };
    });
  };
}
