# Nix Dev Templates using Flakes

> Inspired by [the-nix-way/dev-templates](https://github.com/the-nix-way/dev-templates)

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

To initialize (where `${ENV}` is listed in the table below):

```shell
nix flake init --template github:the-nix-way/dev-templates#${ENV}
```

Here's an example (for the [`rust`](./rust) template):

```shell
# Initialize in the current project
nix flake init --template github:abayomi185/nix-dev-templates#rust

# Create a new project
nix flake new --template github:abayomi185/nix-dev-templates#rust ${NEW_PROJECT_DIRECTORY}
```

You can also use these flakes directly, one off using:

```shell
nix develop github:abayomi185/nix-dev-templates#rust
```

Or perpetually by putting into your `.envrc`, the following (see: [Determinate systems - Nix Direnv](https://determinate.systems/posts/nix-direnv/)):

```shell
use flake "github:abayomi185/nix-dev-templates?dir=rust"
```

## How to use the templates

Once your preferred template has been initialized, you can use the provided shell in two ways:

1. If you have [`nix-direnv`][nix-direnv] installed, you can initialize the environment by running `direnv allow`.
2. If you don't have `nix-direnv` installed, you can run `nix develop` to open up the Nix-defined shell.

## Available templates

| Language/framework/tool | Template                      |
| :---------------------- | :---------------------------- |
| [AWS-SAM]               | [`aws-sam`](./aws-sam/)       |
| [Bun]                   | [`bun`](./bun/)               |
| [Expo]                  | [`expo`](./expo/)             |
| [Deno]                  | [`deno`](./deno/)             |
| [Go]                    | [`go`](./go/)                 |
| [Kubernetes]            | [`yaml`](./kubernetes/)       |
| [Nix]                   | [`nix`](./nix/)               |
| [node]                  | [`node`](./node/)             |
| [Python]                | [`python`](./python/)         |
| [Rust]                  | [`rust`](./rust/)             |
| [Rustup]                | [`rustup`](./rustup/)         |
| [Rust ESP32]            | [`rust_esp32`](./rust_esp32/) |
| [Zig]                   | [`zig`](./zig/)               |
