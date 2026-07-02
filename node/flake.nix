{
  description = "Node development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [
      (final: prev: let
        bunVersion = "1.3.14";
        bunSources = {
          aarch64-darwin = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/bun-darwin-aarch64.zip";
            hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
          };
          x86_64-linux = prev.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/bun-linux-x64.zip";
            hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
          };
        };
      in {
        bun = prev.bun.overrideAttrs (oldAttrs: {
          version = bunVersion;
          src =
            bunSources.${final.stdenv.hostPlatform.system}
            or (throw "Unsupported system: ${final.stdenv.hostPlatform.system}");
          passthru = oldAttrs.passthru // {sources = bunSources;};
        });
      })
      (final: prev: rec {
        nodejs = prev.nodejs_24;
        yarn = prev.yarn.override {inherit nodejs;};
        pnpm = prev.pnpm.override {inherit nodejs;};
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
          astro-language-server
          bun
          nodejs
          pnpm
          prettierd
          tailwindcss-language-server
          typescript
          typescript-language-server
          vscode-langservers-extracted
          vtsls
          yaml-language-server
          yarn
        ];
      };
    });
  };
}
