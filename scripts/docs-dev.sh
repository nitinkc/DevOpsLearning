#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LABS_SRC="$ROOT_DIR/labs/"
LABS_DEST="$ROOT_DIR/docs/labs/"
MKDOCS_BIN="$ROOT_DIR/.venv/bin/mkdocs"
DEV_ADDR="${DOCS_DEV_ADDR:-127.0.0.1:8000}"

sync_labs() {
  rsync -a --delete "$LABS_SRC" "$LABS_DEST"
}

cleanup() {
  if [[ -n "${SYNC_PID:-}" ]]; then
    kill "$SYNC_PID" 2>/dev/null || true
  fi
}

if [[ "${1:-}" == "--sync-only" ]]; then
  sync_labs
  echo "Synced labs/ -> docs/labs/"
  exit 0
fi

if [[ ! -x "$MKDOCS_BIN" ]]; then
  echo "mkdocs not found at $MKDOCS_BIN"
  echo "Create the venv and install requirements first."
  exit 1
fi

sync_labs

if command -v fswatch >/dev/null 2>&1; then
  # Event-driven sync if fswatch is installed.
  fswatch -o "$ROOT_DIR/labs" | while read -r _; do
    sync_labs
  done &
  SYNC_PID=$!
else
  # Fallback polling every 2s keeps docs/labs mirrored during editing.
  while true; do
    sync_labs
    sleep 2
  done &
  SYNC_PID=$!
fi

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"
exec "$MKDOCS_BIN" serve --dev-addr "$DEV_ADDR"

