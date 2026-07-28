# Docker environment

This Docker environment prepares the **CHILD/leader computer**. It contains
Ubuntu 22.04, ROS 2 Humble, ROS 2 Control, Pinocchio, the BNO055 driver,
DYNAMIXEL serial support, Matplotlib, I2C tools, `colcon`, `vcstool`, and
`rosdep`.

The container uses host networking for ROS 2 discovery and privileged device
access for the DYNAMIXEL USB adapter and I2C sensor. Review these permissions
before using it on a shared machine.

## Requirements

- Docker Engine
- Docker Compose plugin (`docker compose`)
- Linux host

Clone this repository before choosing either route:

```bash
git clone https://github.com/shuowenLLL/ICS-CHILD-Teleop.git
cd ICS-CHILD-Teleop
```

## Route 1: automatic source installation

Build the image using the host UID and GID:

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) \
  docker compose -f docker/compose.yaml build
```

Download all repositories listed in `child.repos`, install their package
dependencies, and build:

```bash
docker compose -f docker/compose.yaml run --rm teleop ./scripts/setup_workspace.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/install_dependencies.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/build_workspace.sh
```

The generated `src/`, `build/`, `install/`, and `log/` directories remain in
the cloned host directory. They are excluded from Git.

## Route 2: manual source installation inside Docker

Build the same image:

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) \
  docker compose -f docker/compose.yaml build
```

Create the source directory and clone every repository manually on the host:

```bash
mkdir -p src

git clone -b main https://github.com/shuowenLLL/CHILD.git src/CHILD
git clone -b ros2_humble https://github.com/shuowenLLL/PAPRAS-V0-Public.git src/PAPRAS-V0-Public
git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git src/DynamixelSDK
git clone -b humble https://github.com/ROBOTIS-GIT/dynamixel_interfaces.git src/dynamixel_interfaces
git clone -b master https://github.com/dheera/ros-imu-bno055.git src/ros-imu-bno055
```

Enter the container:

```bash
docker compose -f docker/compose.yaml run --rm teleop bash
```

Then install ROS package dependencies and build inside the container:

```bash
./scripts/install_dependencies.sh
./scripts/build_workspace.sh
```

## Running the leader

Enter the container:

```bash
docker compose -f docker/compose.yaml run --rm teleop bash
```

Inside the container:

```bash
source /opt/ros/humble/setup.bash
source /workspace/install/setup.bash
export ROS_DOMAIN_ID=55
ros2 launch teleop_leaders leader_hw_g1_all_limbs.launch.py
```

The ROS entrypoint automatically sources `/opt/ros/humble/setup.bash` and, when
available, `/workspace/install/setup.bash`.

## Hardware and GUI access

- The current leader configuration expects the DYNAMIXEL adapter at
  `/dev/ttyUSB0` and uses `1000000` baud.
- `network_mode: host` allows ROS 2 discovery on the host network.
- `privileged: true` exposes USB and I2C hardware to the container.
- `/tmp/.X11-unix` and `DISPLAY` are passed through for GUI applications.

If a GUI cannot connect to the display, allow local X11 access before starting
the container:

```bash
xhost +local:
```

Only use this command on a trusted local machine.

## Updating

For sources imported through `child.repos`:

```bash
docker compose -f docker/compose.yaml run --rm teleop vcs pull src
docker compose -f docker/compose.yaml run --rm teleop ./scripts/install_dependencies.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/build_workspace.sh
```

Rebuild the Docker image whenever `docker/Dockerfile` changes:

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) \
  docker compose -f docker/compose.yaml build
```
