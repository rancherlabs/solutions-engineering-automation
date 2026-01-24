#!/bin/bash
set -euo pipefail

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: missing required command: $1" >&2
    exit 1
  fi
}

get_arch() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
}

require_cmd curl

arch="$(get_arch)"
url="https://github.com/jqlang/jq/releases/latest/download/jq-linux-${arch}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$url" -o "$tmp_dir/jq"
install -m 0755 "$tmp_dir/jq" /usr/local/bin/jq

echo "jq installed to /usr/local/bin/jq"
