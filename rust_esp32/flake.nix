{
  description = "ESP32 Rust development environment with FHS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [
          (import rust-overlay)
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustFhsEnv = pkgs.buildFHSUserEnv {
          name = "rust-fhs-env";
          targetPkgs = pkgs:
            with pkgs; [
              rustup
              vscode-extensions.vadimcn.vscode-lldb
              espup
              ldproxy
              cargo-espflash
            ];
          multiPkgs = pkgs:
            with pkgs; [
              # Additional packages if necessary
            ];
          runScript = "zsh";
          profile = ''
            echo "Setting up ESP environment"
            # See .envrc for more details on the use of this environment variable
            export INSIDE_RUST_FHS_ENV=1

            # Set up debugger path
            export CODE_LLDB_PATH="${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            export LIB_LLDB_PATH="${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so";

            # Exit immediately if a command exits with a non-zero status.
            set -e

            # Source the ESP environment variables
            . /home/yomi/export-esp.sh

            # Set rust-analyzer to nightly x86_64-unknown-linux-gnu
            ln -sf ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer ~/.rustup/toolchains/esp/bin/rust-analyzer
          '';
        };
      in {
        devShells.default = rustFhsEnv.env;
      }
    );
}
