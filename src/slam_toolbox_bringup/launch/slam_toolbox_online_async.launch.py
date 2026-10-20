import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration


def generate_launch_description():
    use_sim_time = LaunchConfiguration('use_sim_time')
    config_file = LaunchConfiguration('config_file')

    declare_use_sim_time_argument = DeclareLaunchArgument(
        'use_sim_time',
        default_value='false',
        description='Use simulation/Gazebo clock')
    declare_config_file_cmd = DeclareLaunchArgument(
        'config_file',
        default_value=os.path.join(get_package_share_directory('slam_toolbox_bringup'),
                                   'config', 'slam_toolbox_config.yaml'),
        description='Full path to the ROS2 parameters file to use for the slam_toolbox node')

    # Jazzy's SLAM Toolbox is a lifecycle node. Its upstream launch configures
    # and activates it; a plain Node action leaves it unconfigured.
    start_async_slam_toolbox_node = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('slam_toolbox'),
            'launch', 'online_async_launch.py')),
        launch_arguments={
            'slam_params_file': config_file,
            'use_sim_time': use_sim_time,
            'autostart': 'true',
            'use_lifecycle_manager': 'false',
        }.items())

    ld = LaunchDescription()

    ld.add_action(declare_use_sim_time_argument)
    ld.add_action(declare_config_file_cmd)
    ld.add_action(start_async_slam_toolbox_node)

    return ld
