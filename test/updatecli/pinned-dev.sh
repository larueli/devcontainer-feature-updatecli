#!/usr/bin/env bash
set -euo pipefail

source dev-container-features-test-lib

EXPECTED_VERSION="0.110.0"

echo "Running 'pinned' scenario test (expected: ${EXPECTED_VERSION})..."

check "validate updatecli binary" command -v updatecli >/dev/null 2>&1

VERSION_OUTPUT="$(updatecli version || true)"
echo "updatecli version output: ${VERSION_OUTPUT}"

check "validate updatecli version" echo "${VERSION_OUTPUT}" | grep -q "${EXPECTED_VERSION}"

reportResults
