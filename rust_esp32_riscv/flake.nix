{
  description = "ESP32 (RISC-V) Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs = {
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  }: let
    overlays = [
      (import rust-overlay)
      (final: prev: {
        rustToolchain = let
          rust = prev.rust-bin;
          projectDir = builtins.getEnv "PWD";
          projectRustToolchain = projectDir + "/rust-toolchain.toml";
        in
          if builtins.pathExists projectRustToolchain
          then
            (
              builtins.trace "rust-toolchain.toml found in project directory ${projectDir}"
              rust.fromRustupToolchainFile
              projectRustToolchain
            )
          else
            (
              builtins.trace "rust-toolchain.toml not found in ${projectDir}, using default (stable)"
              rust.stable.latest.default.override {
                extensions = [
                  "rust-src"
                  "rustfmt"
                ];
              }
            );
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
          cargo-espflash
          esp-generate
          ldproxy
          probe-rs-tools
          rustToolchain
          taplo
          vscode-extensions.vadimcn.vscode-lldb
          vscode-langservers-extracted
        ];

        # for debugging with lsp in neovim
        CODE_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
        LIB_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb";
      };
    });
  };
}
