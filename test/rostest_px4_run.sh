#! /bin/bash

PX4_BIN_DIR=/usr/bin
PX4_SRC_DIR=/usr/share/px4

source /opt/ros/kinetic/setup.bash
source ${PX4_SRC_DIR}/Tools/setup_gazebo.bash ${PX4_SRC_DIR} ${PX4_SRC_DIR}/build/posix_sitl_default

export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:${PX4_BIN_DIR}:${PX4_SRC_DIR}:${PX4_SRC_DIR}/Tools/sitl_gazebo

rostest px4 "$@"
