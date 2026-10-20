# Headless ROS 2 SLAM

This module runs one of two headless SLAM algorithms in a ROS 2 Jazzy Docker
container:

| Selector | Algorithm | Main input | Configuration |
| --- | --- | --- | --- |
| `rtab` (default) | RTAB-Map RGB-D SLAM | Aligned RGB and depth, camera calibration, and odometry | `config/slam.yaml` |
| `toolbox` | SLAM Toolbox 2D SLAM | Laser scan and odometry TF | `config/slam_toolbox_config.yaml` |

The image targets a Raspberry Pi 5 (`linux/arm64`) by default. It contains both
algorithms, while `slam.sh` selects the package, launch file, and configuration
used by the container.

This module does not start sensor drivers, an EKF, `robot_state_publisher`,
RViz, or any other visualization process. Those components must be provided by
the rest of the robot system.

## Architecture

RTAB-Map uses RGB-D observations and external odometry:

```text
RGB image + aligned depth + camera info ----+
                                              +--> RTAB-Map --> 2D/3D map data
EKF odometry + robot/camera TF --------------+
```

SLAM Toolbox uses a planar laser scan and the robot TF tree:

```text
LaserScan on /scan --------------------------+
                                              +--> SLAM Toolbox --> 2D map
odom -> base_footprint TF -------------------+
```

Only one algorithm runs in the `robot-slam` container at a time. Both
algorithms normally publish `map -> odom`, so no other node should publish that
transform concurrently.

## Prerequisites

The host must provide:

- Docker Engine with the Docker Compose v2 plugin;
- a running Docker daemon;
- a Linux host when using the supplied host-network configuration;
- write access to `data/`, used for persistent RTAB-Map data;
- ROS publishers and transforms required by the selected algorithm.

Run the built-in prerequisite check from this directory:

```bash
./slam.sh check
```

The check validates Docker, Compose, both configuration files, the Compose
model, and the writable data directory.

## Sensor and TF requirements

### RTAB-Map

The default configuration expects:

| Input | Default name | Type or requirement |
| --- | --- | --- |
| RGB image | `/camera/realsense/color/image_raw` | `sensor_msgs/msg/Image` |
| Aligned depth | `/camera/realsense/aligned_depth_to_color/image_raw` | `sensor_msgs/msg/Image` |
| Camera calibration | `/camera/realsense/color/camera_info` | `sensor_msgs/msg/CameraInfo` |
| Odometry | `/odom` | `nav_msgs/msg/Odometry` |
| Robot TF | `odom -> base_link` | Normally published by the EKF |
| Camera TF | `base_link -> ... -> optical frame` | Transforms matching the image headers |

RGB and depth must be geometrically aligned and timestamped closely enough for
approximate synchronization. The current maximum synchronization interval is
`0.10` seconds. The camera driver is responsible for RGB/depth alignment; this
module does not launch `rtabmap_sync/rgbd_sync`.

RTAB-Map uses `base_link` as its robot frame and publishes `map -> odom`. Do
not change `frame_id` to the camera frame while `/odom` describes `base_link`.

### SLAM Toolbox

The default configuration expects:

| Input | Default name | Type or requirement |
| --- | --- | --- |
| Laser scan | `/scan` | `sensor_msgs/msg/LaserScan` |
| Robot TF | `odom -> base_footprint` | Dynamic odometry transform |
| Laser TF | `base_footprint -> ... -> laser frame` | Transform matching the scan header |

SLAM Toolbox publishes `map -> odom`. Its configured robot frame is
`base_footprint`, which intentionally differs from RTAB-Map's `base_link`.
Change the appropriate YAML file if the robot uses a different frame layout.

## Build and start

`create` builds the image when needed, creates or recreates the container, and
starts it in the background. A separate build is optional.

Build the default ARM64 image without starting a container:

```bash
./slam.sh build
```

Start RTAB-Map, the default algorithm:

```bash
./slam.sh create
```

The explicit RTAB-Map selectors are also accepted:

```bash
./slam.sh create rtab
./slam.sh create rtabmap
```

Start SLAM Toolbox:

```bash
./slam.sh create toolbox
```

`slam_toolbox` is accepted as an alias:

```bash
./slam.sh create slam_toolbox
```

Running `create` with the other selector recreates the service with the newly
selected ROS package and configuration. `start` and `restart` retain the
algorithm stored in the existing container; they do not accept a selector.

For a native x86-64 development build or run:

```bash
ROBOT_PLATFORM=linux/amd64 ./slam.sh build
ROBOT_PLATFORM=linux/amd64 ./slam.sh create toolbox
```

All ROS 2 processes that need to communicate must use the same domain ID:

```bash
ROS_DOMAIN_ID=7 ./slam.sh create rtab
```

The service uses host networking, Cyclone DDS, and `ROS_LOCALHOST_ONLY=0`. It
does not require privileged mode or hardware device mounts because sensor data
arrives over ROS.

## Management commands

| Command | Short form | Effect |
| --- | --- | --- |
| `./slam.sh build` | — | Build the image without creating a container |
| `./slam.sh create [ALGORITHM]` | `./slam.sh -c [ALGORITHM]` | Build and start the selected algorithm |
| `./slam.sh start` | `./slam.sh -s` | Start the existing container |
| `./slam.sh stop` | `./slam.sh -t` | Stop the container gracefully |
| `./slam.sh restart` | `./slam.sh -r` | Restart the existing container |
| `./slam.sh remove` | `./slam.sh -x` | Stop and remove the container; bind-mounted data remains |
| `./slam.sh status` | — | Show the service state |
| `./slam.sh logs` | — | Follow the container logs; Ctrl-C stops following only |
| `./slam.sh check` | — | Validate local prerequisites and configuration |
| `./slam.sh help` | `./slam.sh -h` | Show command help |

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `ROBOT_PLATFORM` | `linux/arm64` | Docker target platform; use `linux/amd64` on an x86-64 development host |
| `ROS_DOMAIN_ID` | `0` | ROS 2 DDS domain shared with the other robot modules |
| `HOST_UID` | `1000` | UID assigned to the non-root `slam` user in the image |
| `HOST_GID` | `1000` | GID assigned to the non-root `slam` user in the image |

Changing `HOST_UID` or `HOST_GID` requires rebuilding the image.

## Configuration

The complete local `config/` directory is mounted read-only at `/ws/config`.
Configuration edits therefore do not require an image rebuild, but the
container must be restarted before a ROS node reloads them.

### RTAB-Map configuration

`config/slam.yaml` contains:

- `slam_bringup.ros__parameters`: runtime mode, namespace, database path,
  topic remappings, and log level;
- `rtabmap.ros__parameters`: parameters passed to the upstream
  `rtabmap_slam/rtabmap` node.

Important current defaults are:

| Setting | Value |
| --- | --- |
| Mode | `reset_mapping` |
| Namespace | `/rtabmap` |
| Database | `/data/rtabmap.db` |
| Robot frame | `base_link` |
| Map frame | `map` |
| Detection rate | `3.0` Hz |
| Approximate-sync maximum interval | `0.10` s |

RTAB-Map supports these configured modes:

| Mode | Behaviour |
| --- | --- |
| `mapping` | Create a database or continue mapping from the existing database |
| `reset_mapping` | Delete the configured database before starting a new map |
| `localization` | Load an existing, non-empty database without adding map nodes |

> **Warning:** the repository currently defaults to `reset_mapping`. Every
> RTAB-Map start deletes `/data/rtabmap.db`. Change the mode to `mapping` before
> relying on database persistence.

The host `data/` directory is bind-mounted at `/data`, so `rtabmap.db` survives
container replacement in `mapping` and `localization` modes.

### SLAM Toolbox configuration

`config/slam_toolbox_config.yaml` is passed directly to the
`async_slam_toolbox_node`. Important defaults include:

| Setting | Value |
| --- | --- |
| Mode | `mapping` |
| Scan topic | `/scan` |
| Robot frame | `base_footprint` |
| Odometry frame | `odom` |
| Map frame | `map` |
| Map resolution | `0.025` m/cell |
| Map update interval | `2.0` s |
| Interactive mode | enabled |

SLAM Toolbox maps are not automatically written to the host `data/` directory.
Use its save/serialization services and choose a path under `/data` when map
persistence is required. Localization also requires a previously serialized
pose graph and the corresponding localization settings in the YAML file.

## ROS outputs

### RTAB-Map outputs

With the default `/rtabmap` namespace, the principal outputs are:

| Topic | Type or purpose |
| --- | --- |
| `/rtabmap/map` | `nav_msgs/msg/OccupancyGrid` |
| `/rtabmap/mapData` | RTAB-Map graph and compressed sensor data |
| `/rtabmap/mapGraph` | Optimized pose graph |
| `/rtabmap/cloud_map` | `sensor_msgs/msg/PointCloud2` assembled map |
| `/rtabmap/info` | Processing and loop-closure statistics |

### SLAM Toolbox outputs and services

The principal outputs are:

| Name | Type or purpose |
| --- | --- |
| `/map` | `nav_msgs/msg/OccupancyGrid` |
| `/map_metadata` | `nav_msgs/msg/MapMetaData` |
| `/pose` | `geometry_msgs/msg/PoseWithCovarianceStamped` |
| `/slam_toolbox/graph_visualization` | Pose-graph visualization markers |
| `/slam_toolbox/scan_visualization` | Corrected scan visualization |

Useful services include `/slam_toolbox/save_map`,
`/slam_toolbox/serialize_map`, `/slam_toolbox/deserialize_map`, and
`/slam_toolbox/pause_new_measurements`.

## Validation

Run local syntax and configuration checks:

```bash
./slam.sh check
bash -n slam.sh
python3 -m py_compile \
  src/rtabmap_bringup/launch/slam.launch.py \
  src/slam_toolbox_bringup/launch/slam_toolbox_online_async.launch.py
docker compose config --quiet
```

Build natively on an x86-64 development system and verify both packages:

```bash
ROBOT_PLATFORM=linux/amd64 docker compose build slam
docker run --rm --platform linux/amd64 robot-modules/slam:jazzy \
  ros2 pkg prefix rtabmap_bringup
docker run --rm --platform linux/amd64 robot-modules/slam:jazzy \
  ros2 pkg prefix slam_toolbox_bringup
```

Hardware validation should additionally confirm:

- the selected input topics publish at the expected rate;
- all required TF transforms are connected and use consistent timestamps;
- `map -> odom` has exactly one publisher;
- the map updates while the robot moves;
- RTAB-Map's database grows in `mapping` mode, or SLAM Toolbox can serialize
  and reload its pose graph;
- offboard ROS 2 processes on the same domain can receive the desired outputs.

A successful image build proves that the software is installed, but it cannot
validate sensor calibration, TF geometry, clock synchronization, DDS network
configuration, or mapping quality on the physical robot.

## Troubleshooting

Follow the container output first:

```bash
./slam.sh status
./slam.sh logs
```

Check inputs from another ROS 2 shell on the same domain:

```bash
ros2 topic hz /odom
ros2 topic hz /camera/realsense/color/image_raw
ros2 topic hz /camera/realsense/aligned_depth_to_color/image_raw
ros2 topic hz /scan
```

Check the transform expected by the selected algorithm:

```bash
ros2 run tf2_ros tf2_echo odom base_link          # RTAB-Map
ros2 run tf2_ros tf2_echo odom base_footprint     # SLAM Toolbox
```

If no ROS data is visible across machines, confirm that every process uses the
same `ROS_DOMAIN_ID`, host firewalls allow DDS traffic, multicast/routing works
on the network, and the computers' clocks are synchronized.

## Jazzy lifecycle validation

The local Toolbox launch delegates lifecycle configure/activate to Jazzy's
upstream `online_async_launch.py`, retaining `config_file` and `use_sim_time`.
A plain process launch is insufficient for the Jazzy lifecycle node.

After building, test activation without sensors or persistent map mounts:

```bash
docker run --rm --network none -e ROS_DOMAIN_ID=174 \
  -v "$PWD/tests:/tests:ro" robot-modules/slam:jazzy \
  python3 /tests/smoke_lifecycle.py
```
