#!/usr/bin/env bash
set -euo pipefail

source dev-container-features-test-lib

echo "Running 'latest' scenario test..."

check "validate updatecli binary" command -v updatecli >/dev/null 2>&1

EXPECTED_VERSION="$(
    curl -fsSL "https://api.github.com/repos/updatecli/updatecli/releases/latest" \
      | grep -oE '"tag_name":\s*"[^"]+"' \
      | cut -d'"' -f4 \
      | sed 's/v//g'
  )"

VERSION_OUTPUT="$(updatecli version || true)"
echo "updatecli version output: ${VERSION_OUTPUT}"

check "validate updatecli version" echo "${VERSION_OUTPUT}" | grep -q "${EXPECTED_VERSION}"

reportResults
