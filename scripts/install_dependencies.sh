#!/usr/bin/env bash
set -euo pipefail

workspace_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ros_setup="/opt/ros/humble/setup.bash"

if [[ ! -f "${ros_setup}" ]]; then
  echo "ROS 2 Humble setup file was not found: ${ros_setup}" >&2
  exit 1
fi

if ! command -v rosdep >/dev/null 2>&1; then
  echo "rosdep is required. Install it with: sudo apt install python3-rosdep" >&2
  exit 1
fi

source "${ros_setup}"

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init
fi

rosdep update
sudo rosdep install \
  --from-paths "${workspace_dir}/src" \
  --ignore-src \
  --rosdistro humble \
  --skip-keys "rviz eigen_conversions cmake_modules open_manipulator_msgs robotis_manipulator gazebo_ros_control" \
  -r \
  -y
