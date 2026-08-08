#!/usr/bin/env bash
# Build architecture-independent Debian package for context-variables.
# Usage: ./packaging/build-deb.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="${ROOT}/packaging"
OUT_DIR="${OUT_DIR:-${ROOT}/dist}"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/context-variables-deb.XXXXXX")"
BUILD_VENV="$(mktemp -d "${TMPDIR:-/tmp}/context-variables-wheel.XXXXXX")"

cleanup() { rm -rf "${STAGE}" "${BUILD_VENV}"; }
trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    echo "On Debian/Ubuntu: sudo apt install -y $2" >&2
    exit 1
  fi
}

require_cmd python3 "python3"
require_cmd rsync "rsync"
require_cmd dpkg-deb "dpkg"
require_cmd fakeroot "fakeroot"

if ! python3 -c 'import ensurepip' >/dev/null 2>&1; then
  PY_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
  echo "error: ensurepip missing. sudo apt install -y python3-venv python${PY_VER}-venv" >&2
  exit 1
fi

VERSION="$(
  python3 - <<'PY' "${ROOT}/pyproject.toml"
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r'(?m)^version\s*=\s*"([^"]+)"', text)
if not m:
    raise SystemExit("version not found in pyproject.toml")
print(m.group(1))
PY
)"

PKG_NAME="context-variables"
DEB_NAME="${PKG_NAME}_${VERSION}_all.deb"
OPT="${STAGE}/opt/context-variables"

echo "Building ${DEB_NAME} (version ${VERSION})"
mkdir -p "${OPT}/wheels" "${STAGE}/usr/bin" "${STAGE}/DEBIAN" "${OUT_DIR}"

rsync -a "${ROOT}/docs/" "${OPT}/docs/"
rsync -a "${ROOT}/examples/" "${OPT}/examples/"
install -m 0644 "${ROOT}/README.md" "${OPT}/README.md"
install -m 0644 "${ROOT}/pyproject.toml" "${OPT}/pyproject.toml"

python3 -m venv "${BUILD_VENV}"
# shellcheck disable=SC1091
source "${BUILD_VENV}/bin/activate"
pip install --upgrade pip wheel
pip wheel --no-deps --wheel-dir="${OPT}/wheels" "${ROOT}"
deactivate

for cmd in generate-contexts vars-grid; do
  install -m 0755 "${PKG_DIR}/usr-bin/${cmd}" "${STAGE}/usr/bin/${cmd}"
done
install -m 0755 "${PKG_DIR}/debian/postinst" "${STAGE}/DEBIAN/postinst"
install -m 0755 "${PKG_DIR}/debian/prerm" "${STAGE}/DEBIAN/prerm"
install -m 0755 "${PKG_DIR}/debian/postrm" "${STAGE}/DEBIAN/postrm"

INSTALLED_SIZE="$(du -sk "${STAGE}" | awk '{print $1}')"
cat > "${STAGE}/DEBIAN/control" <<EOF
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: all
Maintainer: Gary Brooks <gxbrooks@gmail.com>
Installed-Size: ${INSTALLED_SIZE}
Depends: python3 (>= 3.10), python3-venv, python3-pip, python3-yaml
Homepage: https://github.com/gxbrooks/context-variables
Description: Generate context-specific config from variables.yaml
 Reads a project vars/ directory (variables.yaml, contexts.yaml, optional
 secrets.yaml) and writes context files under vars/contexts/.
 .
 CLIs: generate-contexts, vars-grid. See /opt/context-variables/docs/usage.md.
EOF

fakeroot dpkg-deb --build "${STAGE}" "${OUT_DIR}/${DEB_NAME}" >/dev/null
echo "Wrote ${OUT_DIR}/${DEB_NAME}"
dpkg-deb --info "${OUT_DIR}/${DEB_NAME}"
echo "Install with:  sudo dpkg -i ${OUT_DIR}/${DEB_NAME}"
