#!/usr/bin/env python3
"""Launch headless RTAB-Map with aligned RGB-D data and external odometry."""

import os
from pathlib import Path

import yaml
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, LogInfo, OpaqueFunction
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


VALID_MODES = {"mapping", "reset_mapping", "localization"}
VALID_LOG_LEVELS = {"debug", "info", "warn", "error", "fatal"}


def _parameter_section(document, name):
    section = document.get(name)
    if not isinstance(section, dict):
        raise RuntimeError(f"Missing '{name}' section in SLAM configuration")

    parameters = section.get("ros__parameters")
    if not isinstance(parameters, dict):
        raise RuntimeError(
            f"Missing '{name}.ros__parameters' section in SLAM configuration"
        )
    return parameters


def _required_string(parameters, name):
    value = parameters.get(name)
    if not isinstance(value, str) or not value.strip():
        raise RuntimeError(f"SLAM parameter '{name}' must be a non-empty string")
    return value.strip()


def _load_configuration(path):
    try:
        with path.open("r", encoding="utf-8") as stream:
            document = yaml.safe_load(stream)
    except OSError as error:
        raise RuntimeError(f"Cannot read SLAM configuration '{path}': {error}") from error
    except yaml.YAMLError as error:
        raise RuntimeError(f"Invalid YAML in SLAM configuration '{path}': {error}") from error

    if not isinstance(document, dict):
        raise RuntimeError(f"SLAM configuration '{path}' must contain a YAML mapping")
    return document


def _launch_setup(context):
    config_value = LaunchConfiguration("config_file").perform(context)
    config_path = Path(os.path.expanduser(config_value)).resolve()
    document = _load_configuration(config_path)

    bringup = _parameter_section(document, "slam_bringup")
    rtabmap_parameters = dict(_parameter_section(document, "rtabmap"))

    mode = _required_string(bringup, "mode")
    if mode not in VALID_MODES:
        allowed = ", ".join(sorted(VALID_MODES))
        raise RuntimeError(f"Unsupported SLAM mode '{mode}'; expected one of: {allowed}")

    namespace = _required_string(bringup, "namespace").strip("/")
    if not namespace:
        raise RuntimeError("SLAM namespace must not resolve to the root namespace")

    log_level = _required_string(bringup, "log_level").lower()
    if log_level not in VALID_LOG_LEVELS:
        allowed = ", ".join(sorted(VALID_LOG_LEVELS))
        raise RuntimeError(
            f"Unsupported RTAB-Map log level '{log_level}'; expected one of: {allowed}"
        )

    database_path = Path(
        os.path.expanduser(_required_string(bringup, "database_path"))
    ).resolve()
    if not database_path.parent.is_dir():
        raise RuntimeError(
            f"RTAB-Map database directory does not exist: {database_path.parent}"
        )
    if mode == "localization" and (
        not database_path.is_file() or database_path.stat().st_size == 0
    ):
        raise RuntimeError(
            f"Localization requires a non-empty RTAB-Map database: {database_path}"
        )

    topic_keys = (
        "rgb_topic",
        "depth_topic",
        "camera_info_topic",
        "odom_topic",
        "map_topic",
        "map_data_topic",
        "map_graph_topic",
        "cloud_map_topic",
        "info_topic",
    )
    topics = {key: _required_string(bringup, key) for key in topic_keys}

    detection_rate = rtabmap_parameters.get("Rtabmap/DetectionRate")
    try:
        if float(detection_rate) <= 0.0:
            raise ValueError
    except (TypeError, ValueError) as error:
        raise RuntimeError(
            "RTAB-Map parameter 'Rtabmap/DetectionRate' must be greater than zero"
        ) from error

    rtabmap_parameters["database_path"] = str(database_path)
    arguments = []

    if mode == "localization":
        rtabmap_parameters["Mem/IncrementalMemory"] = "false"
        rtabmap_parameters["Mem/InitWMWithAllNodes"] = "true"
    else:
        rtabmap_parameters["Mem/IncrementalMemory"] = "true"
        rtabmap_parameters["Mem/InitWMWithAllNodes"] = "false"
        if mode == "reset_mapping":
            arguments.append("-d")

    messages = [
        LogInfo(
            msg=(
                f"Starting headless RTAB-Map in '{mode}' mode with "
                f"database '{database_path}'"
            )
        )
    ]
    if mode == "reset_mapping":
        messages.append(
            LogInfo(msg=f"The existing RTAB-Map database will be deleted: {database_path}")
        )

    messages.append(
        Node(
            package="rtabmap_slam",
            executable="rtabmap",
            name="rtabmap",
            namespace=namespace,
            output="screen",
            emulate_tty=True,
            parameters=[rtabmap_parameters],
            remappings=[
                ("rgb/image", topics["rgb_topic"]),
                ("depth/image", topics["depth_topic"]),
                ("rgb/camera_info", topics["camera_info_topic"]),
                ("odom", topics["odom_topic"]),
                ("map", topics["map_topic"]),
                ("mapData", topics["map_data_topic"]),
                ("mapGraph", topics["map_graph_topic"]),
                ("cloud_map", topics["cloud_map_topic"]),
                ("info", topics["info_topic"]),
            ],
            arguments=arguments + ["--ros-args", "--log-level", log_level],
        )
    )
    return messages


def generate_launch_description():
    """Create the configurable headless RTAB-Map launch description."""
    default_config = os.path.join(
        get_package_share_directory("rtabmap_bringup"),
        "config",
        "slam.yaml",
    )

    return LaunchDescription(
        [
            DeclareLaunchArgument(
                "config_file",
                default_value=default_config,
                description="Absolute path to the SLAM YAML configuration file",
            ),
            OpaqueFunction(function=_launch_setup),
        ]
    )
