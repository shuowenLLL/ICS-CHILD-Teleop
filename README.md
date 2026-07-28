# ICS CHILD Teleoperation Workspace

ROS 2 Humble workspace manifest and setup tools for the ICS CHILD teleoperation system.

## Repositories

- `CHILD`: ICS teleoperation and diagnostic tools
- `PAPRAS-V0-Public`: PAPRAS controls with the XL330 indirect-read fix
- `DynamixelSDK`: ROBOTIS DYNAMIXEL SDK
- `dynamixel_interfaces`: ROS 2 interfaces for DYNAMIXEL
- `ros-imu-bno055`: BNO055 IMU driver

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

## Update source repositories

```bash
vcs pull src
```

Rebuild after updating:

```bash
./scripts/build_workspace.sh
```
