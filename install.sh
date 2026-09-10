#!/usr/bin/env bash
set -euo pipefail

REPO="${KEEP_GOING_REPO:-szanuje/keep-going}"
INSTALL_DIR="${KEEP_GOING_INSTALL_DIR:-/usr/local/bin}"
TARGET="$INSTALL_DIR/keep-going"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "keep-going only supports macOS." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing dependency: GitHub CLI (gh)." >&2
  echo "Install it with: brew install gh" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated." >&2
  echo "Run: gh auth login" >&2
  exit 1
fi

if ! command -v cliclick >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Missing dependency: cliclick, and Homebrew is not available to install it." >&2
    echo "Install Homebrew first, then rerun this installer." >&2
    exit 1
  fi

  echo "Installing cliclick..."
  brew install cliclick
fi

tmp="$(mktemp)"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

echo "Downloading keep-going..."
gh api "repos/$REPO/contents/keep-going" \
  -H 'Accept: application/vnd.github.raw+json' > "$tmp"

if [[ ! -s "$tmp" ]] || [[ "$(head -n 1 "$tmp")" != '#!/usr/bin/env bash' ]]; then
  echo "Downloaded keep-going script looks invalid; refusing to install." >&2
  exit 1
fi

if [[ -d "$INSTALL_DIR" && -w "$INSTALL_DIR" ]]; then
  install -m 0755 "$tmp" "$TARGET"
else
  echo "Installing to $TARGET (administrator password may be required)..."
  sudo install -d "$INSTALL_DIR"
  sudo install -m 0755 "$tmp" "$TARGET"
fi

echo "Installed keep-going to $TARGET"
echo "Run: keep-going"
echo "Stop: Ctrl+C"
