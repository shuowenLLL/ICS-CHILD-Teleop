#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v vcs >/dev/null 2>&1; then
  echo "vcstool is required. Install it with: sudo apt install python3-vcstool" >&2
  exit 1
fi

mkdir -p "${workspace_dir}/src"
vcs import "${workspace_dir}/src" < "${workspace_dir}/child.repos"
