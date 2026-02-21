{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "Ralph Orchestrator dev environment";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    just
    cargo-watch
    cargo-nextest
    nodejs_22
    pkg-config
    openssl
    python3
  ];

  # https://devenv.sh/languages/
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" "rust-src" ];
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo "Welcome to Ralph Orchestrator development environment!"
    echo ""
    echo "Available commands:"
    echo "  just check     - Run all checks (fmt, lint, test)"
    echo "  just fmt       - Format code"
    echo "  just lint      - Run clippy"
    echo "  just test      - Run tests"
    echo "  just build     - Build release binary"
    echo "  verify         - Run cargo tests + smoke tests"
  '';

  scripts.verify.exec = ''
    set -euo pipefail

    cargo test
    cargo test -p ralph-core smoke_runner
  '';

  scripts.pre-commit-check.exec = ''
    echo "🔍 Running pre-commit checks..."

    # Check formatting
    echo "📐 Checking formatting..."
    if ! cargo fmt --all -- --check; then
      echo "❌ Formatting check failed. Run 'cargo fmt --all' to fix."
      exit 1
    fi

    # Run clippy
    echo "🔧 Running clippy..."
    if ! cargo clippy --all-targets --all-features -- -D warnings; then
      echo "❌ Clippy check failed. Fix warnings before committing."
      exit 1
    fi

    echo "✅ Pre-commit checks passed!"
  '';

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    rustfmt.enable = true;
    clippy.enable = true;
  };

  enterShell = ''
    echo "devenv shell ready for ralph-orchestrator verification"
    rustc --version
    cargo --version
    echo "Run: just check or verify"
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep "2."
    cargo --version | grep "1."
    rustc --version | grep "1."
    rustfmt --version | grep "rustfmt"
    cargo-clippy --version | grep "clippy"
  '';

  # See full reference at https://devenv.sh/reference/options/
}
