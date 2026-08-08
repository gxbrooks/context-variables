#!/usr/bin/env bash
# Install context-variables onto a Linux system (venv + wrappers).
# Usage:
#   sudo ./packaging/install.sh
#   PREFIX=$HOME/.local ./packaging/install.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-/opt/context-variables}"
BIN_DIR="${BIN_DIR:-}"
if [[ -z "${BIN_DIR}" ]]; then
  if [[ "${PREFIX}" == /opt/* ]]; then
    BIN_DIR=/usr/local/bin
  else
    BIN_DIR="${PREFIX}/bin"
  fi
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    echo "On Debian/Ubuntu: sudo apt install -y $2" >&2
    exit 1
  fi
}

require_cmd python3 "python3"
require_cmd rsync "rsync"

PY_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
if ! python3 -c 'import ensurepip' >/dev/null 2>&1; then
  echo "error: Python ensurepip/venv is not available." >&2
  echo "  sudo apt install -y python3-venv python${PY_VER}-venv" >&2
  exit 1
fi

echo "Installing context-variables into ${PREFIX}"
mkdir -p "${PREFIX}"
rsync -a --delete \
  --exclude '.venv' \
  --exclude 'venv' \
  --exclude '__pycache__' \
  --exclude '.pytest_cache' \
  --exclude '*.egg-info' \
  --exclude '.git' \
  --exclude 'dist' \
  --exclude 'tmp' \
  "${ROOT}/" "${PREFIX}/"

rm -rf "${PREFIX}/.venv"
python3 -m venv "${PREFIX}/.venv"
# shellcheck disable=SC1091
source "${PREFIX}/.venv/bin/activate"
pip install --upgrade pip
pip install "${PREFIX}"

mkdir -p "${BIN_DIR}"
for cmd in generate-contexts vars-grid; do
  ln -sfn "${PREFIX}/.venv/bin/${cmd}" "${BIN_DIR}/${cmd}"
done

echo "Installed docs at ${PREFIX}/docs/"
echo "Binaries linked into ${BIN_DIR}: generate-contexts vars-grid"
echo "Point at a project vars dir: generate-contexts --vars-dir /path/to/vars"
echo "See ${PREFIX}/docs/usage.md"
