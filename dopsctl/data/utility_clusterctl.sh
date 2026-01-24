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
url="https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-${arch}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$url" -o "$tmp_dir/clusterctl"
install -m 0755 "$tmp_dir/clusterctl" /usr/local/bin/clusterctl

echo "clusterctl installed to /usr/local/bin/clusterctl"
