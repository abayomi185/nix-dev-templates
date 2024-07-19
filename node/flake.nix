{
  description = "Node development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [
      (final: prev: rec {
        nodejs = prev.nodejs_22;
        yarn = prev.yarn.override {inherit nodejs;};
      })
    ];
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
          bun
          node2nix
          nodejs
          prettierd
          typescript
          yaml-language-server
          yarn
        ];
      };
    });
  };
}
