{ pkgs, ... }:
let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "rustfmt"
      "clippy"
    ];
  };
in
{
  packages = [
    rustToolchain
    pkgs.git
    pkgs.nodejs_22
    pkgs.pkg-config
    pkgs.openssl
    pkgs.python3
  ];

  env.RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

  scripts.verify.exec = ''
    set -euo pipefail

    cargo test
    cargo test -p ralph-core smoke_runner
  '';

  enterShell = ''
    echo "devenv shell ready for ralph-orchestrator verification"
    rustc --version
    cargo --version
    echo "Run: verify"
  '';
}
