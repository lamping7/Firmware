#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PX4_SRC_DIR="$( cd "${DIR}/../" && pwd )"
PX4_BIN_DIR="$( cd "${DIR}/../../../bin/" && pwd )"

source /opt/ros/kinetic/setup.bash
source ${PX4_SRC_DIR}/Tools/setup_gazebo.bash ${PX4_SRC_DIR} ${PX4_SRC_DIR}/build/posix_sitl_default

export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:${PX4_BIN_DIR}:${PX4_SRC_DIR}:${PX4_SRC_DIR}/Tools/sitl_gazebo
echo ${ROS_PACKAGE_PATH}

echo "$(ls -l)"

rostest px4 "$@"
