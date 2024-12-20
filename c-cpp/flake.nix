{
  description = "C-CPP development environment";

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
    devShells = forEachSupportedSystem ({pkgs}: {
      default =
        pkgs.mkShell.override {
          # Override stdenv in order to change compiler:
          # stdenv = pkgs.clangStdenv;
        }
        {
          buildInputs = with pkgs; [
            vscode-extensions.vadimcn.vscode-lldb
          ];
          packages = with pkgs;
            [
              clang-tools
              cmake
              codespell
              conan
              cppcheck
              doxygen
              gtest
              lcov
              vcpkg
              vcpkg-tool
              # Zig
              zig
              zls
            ]
            ++ (
              if system == "aarch64-darwin"
              then []
              else [gdb]
            );

          CODE_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
          LIB_LLDB_PATH = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb";
        };
    });
  };
}
