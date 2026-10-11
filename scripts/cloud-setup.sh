#!/usr/bin/env bash
# Install Typst in an already checked-out Linux workspace; preserve Git and content.
set -euo pipefail

TYPST_VERSION="${TYPST_VERSION:-0.15.1}"
if command -v typst >/dev/null 2>&1; then
  typst --version
  exit 0
fi
if [ -x "$HOME/.local/bin/typst" ]; then
  "$HOME/.local/bin/typst" --version
  echo 'Add $HOME/.local/bin to PATH before building.'
  exit 0
fi
if [ "$(uname -s)" != Linux ]; then
  echo 'Automatic installation supports Linux. Install Typst manually on this OS.' >&2
  exit 1
fi
case "$(uname -m)" in
  x86_64) arch=x86_64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) echo 'Unsupported CPU architecture; install Typst manually.' >&2; exit 1 ;;
esac
command -v curl >/dev/null
command -v tar >/dev/null
setup_tmp="$(mktemp -d)"
trap 'rm -rf -- "$setup_tmp"' EXIT
archive="typst-${arch}-unknown-linux-musl"
curl --fail --location --silent --show-error --retry 3 \
  "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/${archive}.tar.xz" \
  -o "$setup_tmp/typst.tar.xz"
tar -xJf "$setup_tmp/typst.tar.xz" -C "$setup_tmp"
mkdir -p "$HOME/.local/bin"
install -m 0755 "$setup_tmp/$archive/typst" "$HOME/.local/bin/typst"
"$HOME/.local/bin/typst" --version
echo 'Add $HOME/.local/bin to PATH before building.'
