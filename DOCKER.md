# Docker environment

The Docker image includes ROS 2 Humble, colcon, vcstool, rosdep, ros2_control,
Pinocchio, the BNO055 driver, serial support, Matplotlib, and I2C tools.

## Build

Build the image with the same user and group IDs as the host:

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) \
  docker compose -f docker/compose.yaml build
```

## Set up a new workspace

Import the source repositories, install package dependencies, and build:

```bash
docker compose -f docker/compose.yaml run --rm teleop ./scripts/setup_workspace.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/install_dependencies.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/build_workspace.sh
```

Open an interactive development shell:

```bash
docker compose -f docker/compose.yaml run --rm teleop
```

The container uses host networking for ROS 2 discovery and privileged device
access for DYNAMIXEL USB adapters and I2C sensors. Review these permissions
before using the configuration on a shared machine.
