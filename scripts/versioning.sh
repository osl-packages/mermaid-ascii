#!/usr/bin/env bash
set -euo pipefail
echo "[II] Versioning pyproject.toml ..."

if [ "${1:-}" = "" ]; then
  echo "Version parameter is required."
  exit 1
fi

UPSTREAM_VERSION="$1"
NEW_VERSION="${UPSTREAM_VERSION#v}"   # strip leading v if present

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
PYPROJECT_PATH="${PROJECT_DIR}/pyproject.toml"

SEARCH_RE='^version[[:space:]]*=[[:space:]]*"([0-9]+\.[0-9]+\.[0-9]+)"[[:space:]]*#.*mermaid-ascii[[:space:]]*version'
line="$(grep -E "$SEARCH_RE" "$PYPROJECT_PATH" || true)"
if [ -z "${line}" ]; then
  echo "No version found in the pyproject.toml." >&2
  exit 1
fi

CURRENT_VERSION="$(printf '%s\n' "$line" | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')"

# in-place replace the tagged mermaid-ascii version line only
sed -Ei \
  's@^(version[[:space:]]*=[[:space:]]*")([0-9]+\.[0-9]+\.[0-9]+)("[[:space:]]*#.*mermaid-ascii[[:space:]]*version.*)$@\1'"$NEW_VERSION"'\3@' \
  "$PYPROJECT_PATH"

echo "[II] pyproject: ${PYPROJECT_PATH}"
echo "[II] Current version: ${CURRENT_VERSION}"
echo "[II] New version: ${NEW_VERSION}"

# Expose whether we actually changed the file
if git -C "$PROJECT_DIR" diff --quiet -- "$PYPROJECT_PATH"; then
  echo "[EE] The project uses already the latest version."
  exit 0
fi
