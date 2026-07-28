# ICS CHILD Teleoperation Workspace

ROS 2 Humble workspace manifest and setup tools for the ICS CHILD teleoperation system.

## Repositories

- [`CHILD`](https://github.com/shuowenLLL/CHILD): teleoperation and diagnostic tools
- [`PAPRAS-V0-Public`](https://github.com/shuowenLLL/PAPRAS-V0-Public): PAPRAS controls with the XL330 indirect-read fix
- [`DynamixelSDK`](https://github.com/ROBOTIS-GIT/DynamixelSDK): ROBOTIS DYNAMIXEL SDK
- [`dynamixel_interfaces`](https://github.com/ROBOTIS-GIT/dynamixel_interfaces): ROS 2 interfaces for DYNAMIXEL
- [`ros-imu-bno055`](https://github.com/dheera/ros-imu-bno055): BNO055 IMU driver

## Create a workspace

Install ROS 2 Humble, `vcstool`, and `colcon`, then run:

```bash
git clone https://github.com/shuowenLLL/ICS-CHILD-Teleop.git
cd ICS-CHILD-Teleop
./scripts/setup_workspace.sh
./scripts/build_workspace.sh
```

The setup script imports all source repositories into `src/`. Generated
`build/`, `install/`, and `log/` directories are intentionally excluded from
Git.

## Docker

For a reproducible ROS 2 Humble environment, follow [DOCKER.md](DOCKER.md).
It includes the commands to build the image, import the source repositories,
install ROS package dependencies, and build the workspace.

## Update source repositories

```bash
vcs pull src
```

Rebuild after updating:

```bash
./scripts/build_workspace.sh
```
