#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
MERMAIDASCII_DIR="$PROJECT_DIR/build/mermaid_ascii"

rm -rf "$MERMAIDASCII_DIR"
git clone https://github.com/AlexanderGrooff/mermaid-ascii "$MERMAIDASCII_DIR"

pushd "$MERMAIDASCII_DIR" >/dev/null

MERMAIDASCII_VERSION="$(git tag --sort=-v:refname | head -n 1)"
git checkout "$MERMAIDASCII_VERSION"

# bump pyproject version in the packaging repo
"$PROJECT_DIR/scripts/versioning.sh" "$MERMAIDASCII_VERSION"

# build OS-specific binary
GOOS="$(go env GOOS)"
BIN_NAME="mermaid-ascii"
if [[ "$GOOS" == "windows" ]]; then
  BIN_NAME="mermaid-ascii.exe"
fi

go build -o "$BIN_NAME"

mkdir -p "$PROJECT_DIR/src/mermaid_ascii"
cp -f "$BIN_NAME" "$PROJECT_DIR/src/mermaid_ascii/$BIN_NAME"
# 'chmod' is a noop on Windows; ignore errors
chmod +x "$PROJECT_DIR/src/mermaid_ascii/$BIN_NAME" 2>/dev/null || true

popd >/dev/null
rm -rf "$MERMAIDASCII_DIR"
