ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-base-noble

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy
ARG USERNAME=slam
ARG UID=1000
ARG GID=1000

SHELL ["/bin/bash", "-c"]

# Noble reserves UID/GID 1000 for its default ubuntu account.
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi && \
    groupadd --gid ${GID} ${USERNAME} && \
    useradd --create-home --uid ${UID} --gid ${GID} \
        --shell /bin/bash ${USERNAME}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-colcon-common-extensions \
    python3-yaml \
    ros-${ROS_DISTRO}-launch-ros \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-rtabmap-slam \
    ros-${ROS_DISTRO}-slam-toolbox \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ws

COPY src/ src/
COPY config/ config/

RUN source "/opt/ros/${ROS_DISTRO}/setup.bash" && \
    colcon build \
        --merge-install \
        --packages-select rtabmap_bringup slam_toolbox_bringup \
        --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && \
    rm -rf build log

RUN mkdir -p /data && \
    chown -R ${USERNAME}:${USERNAME} /ws /data

COPY docker-entrypoint.sh /ros_module_entrypoint.sh
RUN chmod 0755 /ros_module_entrypoint.sh

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    ROS_DOMAIN_ID=0 \
    ROS_LOCALHOST_ONLY=0 \
    MODULE_SETUP=/ws/install/setup.bash \
    RCUTILS_LOGGING_USE_STDOUT=1 \
    RCUTILS_LOGGING_BUFFERED_STREAM=1

USER ${USERNAME}

ENTRYPOINT ["/ros_module_entrypoint.sh"]
CMD ["ros2", "launch", "rtabmap_bringup", "slam.launch.py", "config_file:=/ws/config/slam.yaml"]
