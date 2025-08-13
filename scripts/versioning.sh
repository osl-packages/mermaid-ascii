#!/usr/bin/env bash
set -euo pipefail
echo "[II] Versioning pyproject.toml ..."

if [ "${1:-}" = "" ]; then
  echo "Version parameter is required."
  exit 1
fi

UPSTREAM_VERSION="$1"
BUILD_NUM="${2:-}"                   # optional
NEW_VERSION="${UPSTREAM_VERSION#v}"  # strip leading v if present

# If a build number was provided, append a PEP 440 post release
if [[ -n "$BUILD_NUM" ]]; then
  if [[ ! "$BUILD_NUM" =~ ^[0-9]+$ ]]; then
    echo "[EE] BUILD_NUM must be numeric, got: $BUILD_NUM" >&2
    exit 1
  fi
  NEW_VERSION="${NEW_VERSION}.post${BUILD_NUM}"
fi

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
PYPROJECT_PATH="${PROJECT_DIR}/pyproject.toml"

# Match ANY quoted version (not just X.Y.Z) on the mermaid-ascii marker line
SEARCH_RE='^version[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*#.*mermaid-ascii[[:space:]]*version'
line="$(grep -E "$SEARCH_RE" "$PYPROJECT_PATH" || true)"
if [ -z "${line}" ]; then
  echo "No version found in the pyproject.toml." >&2
  exit 1
fi

CURRENT_VERSION="$(printf '%s\n' "$line" | sed -E 's/.*"([^"]+)".*/\1/')"

# In-place replace: keep everything, swap only the quoted version on that marker line
sed -Ei \
  's@^(version[[:space:]]*=[[:space:]]*")([^"]+)("([[:space:]]*#.*mermaid-ascii[[:space:]]*version.*))$@\1'"$NEW_VERSION"'\3@' \
  "$PYPROJECT_PATH"

echo "[II] pyproject: ${PYPROJECT_PATH}"
echo "[II] Current version: ${CURRENT_VERSION}"
echo "[II] New version: ${NEW_VERSION}"

# Exit 0 if unchanged so the workflow can short-circuit
if git -C "$PROJECT_DIR" diff --quiet -- "$PYPROJECT_PATH"; then
  echo "[EE] The project uses already the latest version."
  exit 0
fi
