{
  description = "Go development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    goVersion = "1_22";
    overlays = [(final: prev: {go = prev."go_${goVersion}";})];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          go # specified by overlay
          gotools # goimports, godoc, etc.
          golangci-lint # https://github.com/golangci/golangci-lint
          gotestsum
        ];
      };
    });
  };
}
