"""Use the upstream SLAM Toolbox bringup with this module's configuration."""
from pathlib import Path
import yaml
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, OpaqueFunction
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration


def start(context):
    config = LaunchConfiguration('config_file').perform(context)
    clock = LaunchConfiguration('use_sim_time').perform(context)
    if clock == 'config':
        params = yaml.safe_load(Path(config).read_text())['slam_toolbox']['ros__parameters']
        clock = str(params.get('use_sim_time', False)).lower()
    upstream = Path(get_package_share_directory('slam_toolbox')) / 'launch/online_async_launch.py'
    return [IncludeLaunchDescription(PythonLaunchDescriptionSource(str(upstream)),
            launch_arguments={'slam_params_file': config, 'use_sim_time': clock, 'autostart': 'true'}.items())]


def generate_launch_description():
    default = str(Path(get_package_share_directory('slam_toolbox_bringup')) / 'config/slam_toolbox_config.yaml')
    return LaunchDescription([
        DeclareLaunchArgument('config_file', default_value=default),
        DeclareLaunchArgument('use_sim_time', default_value='config', choices=['config', 'true', 'false']),
        OpaqueFunction(function=start),
    ])
