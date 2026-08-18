#!/usr/bin/env bash
# Verify a parent fnox.toml is visible from a child directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

if ! command -v fnox >/dev/null 2>&1; then
  info "Skipping fnox hierarchy check (fnox not installed)"
  exit 0
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

export FNOX_CONFIG_DIR="$tmpdir/config"
mkdir -p "$tmpdir/src/app"

fnox init --global --skip-wizard --non-interactive >/dev/null

cat >"$tmpdir/src/fnox.toml" <<'EOF'
[providers.plain]
type = "plain"

[secrets]
SHARED_CLI_TOKEN = { default = "from-parent" }
EOF

got="$(cd "$tmpdir/src/app" && fnox get SHARED_CLI_TOKEN)"
[[ "$got" == "from-parent" ]] || die "expected child dir to inherit SHARED_CLI_TOKEN, got: $got"

files="$(cd "$tmpdir/src/app" && fnox config-files)"
printf '%s\n' "$files" | grep -F "$tmpdir/src/fnox.toml" >/dev/null ||
  die "child config-files did not include parent fnox.toml"

info "fnox hierarchy check passed"
