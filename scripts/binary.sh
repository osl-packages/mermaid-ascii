#!/usr/bin/env bash
set -euo pipefail

BUMP=false
if [[ "${1:-}" == "--bump" ]]; then
  BUMP=true
fi

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
MERMAIDASCII_DIR="$PROJECT_DIR/build/mermaid_ascii"

rm -rf "$MERMAIDASCII_DIR"
git clone https://github.com/AlexanderGrooff/mermaid-ascii "$MERMAIDASCII_DIR"

pushd "$MERMAIDASCII_DIR" >/dev/null

MERMAIDASCII_VERSION="$(git tag --sort=-v:refname | head -n 1)"
git checkout "$MERMAIDASCII_VERSION"

if $BUMP; then
  echo "[II] Bumping pyproject version to $MERMAIDASCII_VERSION ..."
  "$PROJECT_DIR/scripts/versioning.sh" "$MERMAIDASCII_VERSION"
fi

# Decide binary name without using 'go env'
BIN_NAME="mermaid-ascii"
if [[ "${RUNNER_OS:-}" == "Windows" ]]; then
  BIN_NAME="mermaid-ascii.exe"
  echo "[II] GOROOT=$GOROOT"
fi

go version
go build -o "$BIN_NAME"

mkdir -p "$PROJECT_DIR/src/mermaid_ascii"
cp -f "$BIN_NAME" "$PROJECT_DIR/src/mermaid_ascii/$BIN_NAME"
chmod +x "$PROJECT_DIR/src/mermaid_ascii/$BIN_NAME" 2>/dev/null || true

popd >/dev/null
rm -rf "$MERMAIDASCII_DIR"
