#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ros_setup="/opt/ros/humble/setup.bash"

if [[ ! -f "${ros_setup}" ]]; then
  echo "ROS 2 Humble setup file was not found: ${ros_setup}" >&2
  exit 1
fi

if ! command -v colcon >/dev/null 2>&1; then
  echo "colcon is required. Install it with: sudo apt install python3-colcon-common-extensions" >&2
  exit 1
fi

source "${ros_setup}"
cd "${workspace_dir}"
colcon build --symlink-install
