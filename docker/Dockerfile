FROM ubuntu:22.04

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales tzdata curl gnupg2 lsb-release software-properties-common sudo \
    git build-essential cmake \
    python3-pip python3-argcomplete python3-dev python3-matplotlib python3-serial \
    usbutils udev i2c-tools libi2c-dev wget vim nano \
    libboost-all-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME}") main" \
      > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base ros-dev-tools ros-humble-xacro \
    ros-humble-hardware-interface ros-humble-controller-interface \
    ros-humble-controller-manager ros-humble-ros2-control \
    ros-humble-ros2-controllers ros-humble-pinocchio ros-humble-bno055 \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir \
    colcon-common-extensions==0.3.0 vcstool==0.3.0 rosdep==0.26.0

RUN rosdep init || true

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
    && usermod -aG dialout "${USERNAME}" \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh \
    && echo "source /opt/ros/humble/setup.bash" >> "/home/${USERNAME}/.bashrc"

USER "${USERNAME}"
WORKDIR /workspace

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
