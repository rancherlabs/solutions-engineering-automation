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

get_latest_tag() {
  repo="$1"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | sed -n 's/.*"tag_name": "v\{0,1\}\([^"]*\)".*/\1/p'
}

require_cmd curl
require_cmd tar

arch="$(get_arch)"
version="$(get_latest_tag "etcd-io/etcd")"

if [ -z "$version" ]; then
  echo "Error: could not determine latest etcd version" >&2
  exit 1
fi

url="https://github.com/etcd-io/etcd/releases/download/v${version}/etcd-v${version}-linux-${arch}.tar.gz"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$url" -o "$tmp_dir/etcd.tar.gz"
tar -xzf "$tmp_dir/etcd.tar.gz" -C "$tmp_dir"

install -m 0755 "$tmp_dir/etcd-v${version}-linux-${arch}/etcdctl" /usr/local/bin/etcdctl

echo "etcdctl installed to /usr/local/bin/etcdctl"
