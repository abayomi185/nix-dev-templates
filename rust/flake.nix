{
  description = "Rust development environment";

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
        in
          if builtins.pathExists ./rust-toolchain.toml
          then
            (
              builtins.trace "rust-toolchain.toml found"
              rust.fromRustupToolchainFile
              ./rust-toolchain.toml
            )
          else
            (
              builtins.trace "rust-toolchain.toml not found"
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
          rust-analyzer
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
