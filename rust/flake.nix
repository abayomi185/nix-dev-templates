{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [
          (import rust-overlay)
          (final: prev: {
            rustToolchain = let
              rust = prev.rust-bin;
              toolchainFile =
                if builtins.pathExists ./rust-toolchain.toml
                then ./rust-toolchain.toml
                else if builtins.pathExists ./rust-toolchain
                then ./rust-toolchain
                else null;
            in
              if toolchainFile != null
              then rust.fromRustupToolchainFile toolchainFile
              else rust.stable.latest.default;
          })
        ];
        pkgs =
          import nixpkgs
          {
            inherit system overlays;
          };
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [
              rustToolchain
              rust-analyzer
              vscode-extensions.vadimcn.vscode-lldb
            ];

            CODE_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            LIB_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";
          };
        }
    );
}
