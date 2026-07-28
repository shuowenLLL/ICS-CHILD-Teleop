# ICS CHILD Teleoperation Workspace

ROS 2 Humble workspace manifest, installation scripts, and Docker environment
for the ICS CHILD teleoperation system.

This repository prepares the **CHILD/leader computer**. The G1 robot-side
Python environment is described separately below.

## Repositories

- [`CHILD`](https://github.com/shuowenLLL/CHILD): leader robot description,
  feedback controller, G1 teleoperation software, and DYNAMIXEL diagnostic
  tools.
- [`PAPRAS-V0-Public`](https://github.com/shuowenLLL/PAPRAS-V0-Public):
  provides the `papras_hardware_interface/DynamixelHardware` ROS 2 Control
  plugin used by `teleop_leaders`. It opens the DYNAMIXEL serial bus, applies
  the servo configuration, reads position/velocity/current, writes
  position/current commands, and contains the corrected XL330 indirect-read
  address (`230`).
- [`DynamixelSDK`](https://github.com/ROBOTIS-GIT/DynamixelSDK): low-level
  ROBOTIS serial communication SDK used by the PAPRAS hardware plugin and
  diagnostic scripts.
- [`dynamixel_interfaces`](https://github.com/ROBOTIS-GIT/dynamixel_interfaces):
  ROS 2 messages and services for reading, writing, rebooting, and monitoring
  DYNAMIXEL devices.
- [`ros-imu-bno055`](https://github.com/dheera/ros-imu-bno055): ROS 2 BNO055
  IMU driver.

The exact repository URLs and branches are recorded in
[`child.repos`](child.repos).

## Installation overview

Choose one route:

1. **Automatic Docker installation (recommended):** clone this repository and
   let the supplied scripts download all source repositories, install
   dependencies, and build the workspace.
2. **Manual native installation:** install ROS 2 and dependencies on the host,
   clone every source repository yourself, and build with `colcon`.

Do not copy `build/`, `install/`, or `log/` between machines. Recreate them by
building the workspace.

## Route 1: automatic Docker installation

Requirements:

- Docker Engine
- Docker Compose plugin (`docker compose`)
- a Linux host with access to the DYNAMIXEL USB adapter and BNO055 I2C device

Run:

```bash
git clone https://github.com/shuowenLLL/ICS-CHILD-Teleop.git
cd ICS-CHILD-Teleop

HOST_UID=$(id -u) HOST_GID=$(id -g) \
  docker compose -f docker/compose.yaml build

docker compose -f docker/compose.yaml run --rm teleop ./scripts/setup_workspace.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/install_dependencies.sh
docker compose -f docker/compose.yaml run --rm teleop ./scripts/build_workspace.sh
```

`setup_workspace.sh` reads `child.repos` and downloads the five repositories
into `src/`. See [DOCKER.md](DOCKER.md) for container details and the equivalent
manual Docker workflow.

Start the leader:

```bash
docker compose -f docker/compose.yaml run --rm teleop bash
source install/setup.bash
export ROS_DOMAIN_ID=55
ros2 launch teleop_leaders leader_hw_g1_all_limbs.launch.py
```

## Route 2: manual native installation

This route targets Ubuntu 22.04 with ROS 2 Humble. First install ROS 2 Humble
using the [official ROS instructions](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html),
then install the required packages:

```bash
sudo apt update
sudo apt install -y \
  git build-essential cmake \
  python3-pip python3-serial python3-matplotlib \
  python3-colcon-common-extensions python3-vcstool python3-rosdep \
  i2c-tools libi2c-dev \
  ros-humble-xacro \
  ros-humble-hardware-interface \
  ros-humble-controller-interface \
  ros-humble-controller-manager \
  ros-humble-ros2-control \
  ros-humble-ros2-controllers \
  ros-humble-pinocchio \
  ros-humble-bno055
```

Initialize `rosdep` once:

```bash
sudo rosdep init
rosdep update
```

If `rosdep init` reports that the sources file already exists, continue with
`rosdep update`.

Clone the workspace manager and each source repository:

```bash
git clone https://github.com/shuowenLLL/ICS-CHILD-Teleop.git
cd ICS-CHILD-Teleop
mkdir -p src

git clone -b main https://github.com/shuowenLLL/CHILD.git src/CHILD
git clone -b ros2_humble https://github.com/shuowenLLL/PAPRAS-V0-Public.git src/PAPRAS-V0-Public
git clone -b humble https://github.com/ROBOTIS-GIT/DynamixelSDK.git src/DynamixelSDK
git clone -b humble https://github.com/ROBOTIS-GIT/dynamixel_interfaces.git src/dynamixel_interfaces
git clone -b master https://github.com/dheera/ros-imu-bno055.git src/ros-imu-bno055
```

Install remaining package dependencies and build:

```bash
source /opt/ros/humble/setup.bash

sudo rosdep install \
  --from-paths src \
  --ignore-src \
  --rosdistro humble \
  --skip-keys "rviz eigen_conversions cmake_modules open_manipulator_msgs robotis_manipulator gazebo_ros_control" \
  -r -y

colcon build --symlink-install
source install/setup.bash
```

Allow the current user to access serial devices, then log out and back in:

```bash
sudo usermod -aG dialout "$USER"
```

Start the leader:

```bash
cd ICS-CHILD-Teleop
source /opt/ros/humble/setup.bash
source install/setup.bash
export ROS_DOMAIN_ID=55
ros2 launch teleop_leaders leader_hw_g1_all_limbs.launch.py
```

The current leader configuration expects `/dev/ttyUSB0` at `1000000` baud.
Verify the port before starting real hardware.

## G1 robot-side installation

The G1 side is separate from the CHILD/leader Docker environment. Based on the
original
[`Teleop_Instruction.md`](https://github.com/shuowenLLL/CHILD/blob/main/Teleop_Instruction.md),
create a smaller ROS workspace and skip the leader hardware package:

```bash
mkdir -p ~/ws_child/src
cd ~/ws_child/src
git clone -b main https://github.com/shuowenLLL/CHILD.git
touch CHILD/hw_interface/teleop_leaders/COLCON_IGNORE

cd ..
source /opt/ros/humble/setup.bash
colcon build --symlink-install
```

Create the Python environment and install the teleoperation dependencies:

```bash
cd ~/ws_child/src/CHILD
python3.8 -m pip install --user virtualenv
python3.8 -m virtualenv venv_child
source venv_child/bin/activate
pip install -r teleop_sw/requirements.txt

git clone https://github.com/unitreerobotics/unitree_sdk2_python.git
pip install -e unitree_sdk2_python
```

If a legacy requirement reports a `libxml2` installation error:

```bash
pip install lxml --only-binary :all:
pip install -r teleop_sw/requirements.txt
```

Edit `teleop_sw/cyclonedds.xml` and replace the two placeholder peer addresses
with the CHILD and G1 Wi-Fi IP addresses. Both machines must use the same
`ROS_DOMAIN_ID`, normally `55`.

Start the G1 teleoperation program:

```bash
export CYCLONEDDS_URI=file://$HOME/ws_child/src/CHILD/teleop_sw/cyclonedds.xml
export ROS_DOMAIN_ID=55

cd ~/ws_child
source install/setup.bash
source src/CHILD/venv_child/bin/activate
cd src/CHILD/teleop_sw

python -m run_g1_upper_body
# Or, in the appropriate G1 debug mode:
python -m run_g1_full_body_teleop
```

Follow the G1 operating-mode and emergency-stop instructions in the original
`Teleop_Instruction.md` before enabling real hardware.

## Updating and rebuilding

For an automatically imported workspace:

```bash
vcs pull src
./scripts/install_dependencies.sh
./scripts/build_workspace.sh
```
