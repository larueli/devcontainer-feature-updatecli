#!/usr/bin/env bash
set -euo pipefail

source dev-container-features-test-lib

echo "Running 'latest' scenario test..."

check "validate updatecli binary" command -v updatecli >/dev/null 2>&1

VERSION_OUTPUT="$(updatecli version || true)"
echo "updatecli version output: ${VERSION_OUTPUT}"

check "validate updatecli output" echo "${VERSION_OUTPUT}" | grep -i Application | grep -qiE "version|[0-9]+\.[0-9]+\.[0-9]+"

reportResults
