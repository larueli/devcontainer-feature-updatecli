#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Updatecli Dev Container Feature ====="
REQUESTED_VERSION="${VERSION:-latest}"

REMOTE_USER="${_REMOTE_USER:-vscode}"
REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/home/${REMOTE_USER}}"

ensure_curl() {
    if command -v curl >/dev/null 2>&1; then
        echo "curl already installed."
        return 0
    fi

    echo "curl not found, installing..."

    # Try to source /etc/os-release for information (optional but nice)
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "Detected distro: ${ID:-unknown} (like: ${ID_LIKE:-})"
    fi

    # Alpine
    if command -v apk >/dev/null 2>&1; then
        apk update
        apk add --no-cache curl ca-certificates
        return 0
    fi

    # Debian / Ubuntu
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y --no-install-recommends curl ca-certificates
        rm -rf /var/lib/apt/lists/*
        return 0
    fi

    # RHEL / CentOS / Rocky / Alma etc.
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y curl ca-certificates
        return 0
    fi

    if command -v yum >/dev/null 2>&1; then
        yum install -y curl ca-certificates
        return 0
    fi

    # openSUSE / SLES
    if command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install curl ca-certificates
        return 0
    fi

    echo "ERROR: Could not install curl - no supported package manager (apk/apt-get/dnf/yum/zypper) found." >&2
    exit 1
}

ensure_curl

echo "Requested Updatecli version: ${REQUESTED_VERSION}"

# ---------------------------------------------------------------------------
# Detect platform
# ---------------------------------------------------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    OS_PART="Linux"
    ;;
  *)
    echo "❌ Unsupported OS for this feature: ${OS}. Devcontainers should be Linux-based."
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64)
    ARCH_PART="x86_64"
    ;;
  aarch64|arm64)
    ARCH_PART="arm64"
    ;;
  armv7l|armv6l|arm)
    ARCH_PART="arm"
    ;;
  *)
    echo "❌ Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

TARBALL="updatecli_${OS_PART}_${ARCH_PART}.tar.gz"

echo "Detected platform: ${OS_PART}/${ARCH_PART}"
echo "Tarball to download: ${TARBALL}"

# ---------------------------------------------------------------------------
# Resolve version (latest -> tag_name)
# ---------------------------------------------------------------------------
if [ "${REQUESTED_VERSION}" = "latest" ]; then
  echo "Resolving latest Updatecli version from GitHub releases..."

  REQUESTED_VERSION="$(
    curl -fsSL "https://api.github.com/repos/updatecli/updatecli/releases/latest" \
      | grep -oE '"tag_name":\s*"[^"]+"' \
      | cut -d'"' -f4
  )"

  if [ -z "${REQUESTED_VERSION}" ]; then
    echo "❌ Unable to determine latest release tag from GitHub API."
    exit 1
  fi

  echo "Latest version is: ${REQUESTED_VERSION}"
fi

BASE_URL="https://github.com/updatecli/updatecli/releases/download/${REQUESTED_VERSION}"
CHECKSUMS_URL="${BASE_URL}/checksums.txt"

echo "Using base URL: ${BASE_URL}"

# ---------------------------------------------------------------------------
# Download tarball + checksums and verify
# ---------------------------------------------------------------------------
WORKDIR="/tmp/updatecli-install"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "Downloading ${TARBALL}..."
curl -fsSLO "${BASE_URL}/${TARBALL}"

echo "Downloading checksums.txt..."
curl -fsSLO "${CHECKSUMS_URL}"

echo "Verifying checksum..."
grep -v sbom checksums.txt | grep "  ${TARBALL}" | sha256sum -c -

echo "Checksum verification OK ✅"

# ---------------------------------------------------------------------------
# Extract and install
# ---------------------------------------------------------------------------
echo "Extracting ${TARBALL}..."
tar -xzf "${TARBALL}"

if [ ! -f updatecli ]; then
  echo "❌ updatecli binary not found after extraction."
  ls -R .
  exit 1
fi

echo "Installing updatecli to /usr/local/bin..."
install -m 0755 updatecli /usr/local/bin/updatecli

# ---------------------------------------------------------------------------
# Permissions / user config
# ---------------------------------------------------------------------------
echo "Setting permissions..."

chown root:root /usr/local/bin/updatecli
chmod 0755 /usr/local/bin/updatecli

mkdir -p "${REMOTE_USER_HOME}/.config/updatecli"
chown -R "${REMOTE_USER}:${REMOTE_USER}" "${REMOTE_USER_HOME}/.config/updatecli"

echo "Updatecli installation complete 🎉"
updatecli version || true
