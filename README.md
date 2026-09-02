# Headless RGB-D SLAM

This standalone ROS 2 Humble module runs RTAB-Map on an edge computer using
aligned RGB-D images and external odometry. It is designed for Raspberry Pi 5
(`linux/arm64`) and does not start a camera driver, visual odometry, ICP
odometry, RViz, or `rtabmap_viz`.

The default integration is:

```text
RealSense RGB + aligned depth + camera info ----+
                                                  +--> RTAB-Map --> map data
EKF odometry ------------------------------------+
```

The RealSense and EKF remain independent modules. This module depends only on
standard ROS 2 and RTAB-Map interfaces.

## Runtime requirements

Before starting SLAM, the robot bringup must provide:

- color images on `/camera/realsense/color/image_raw`;
- depth aligned to color on
  `/camera/realsense/aligned_depth_to_color/image_raw`;
- color calibration on `/camera/realsense/color/camera_info`;
- EKF odometry on `/odom` as `nav_msgs/msg/Odometry`;
- the transform `odom -> base_link` from the EKF;
- a complete static transform chain from `base_link` through the robot-mounted
  `realsense_link` to the optical frame carried by the image headers.

The expected RealSense profile is 640x480 at 15 FPS with hardware stream
synchronization and depth-to-color alignment enabled. RTAB-Map processes at
most 5 frames per second by default, so the camera can keep publishing at 15
FPS without forcing every image through the SLAM pipeline.

Aligned depth and RGB synchronization are produced by the RealSense driver.
The EKF odometry has an independent clock cadence, so RTAB-Map's internal
approximate policy pairs it with the synchronized camera frames. The default
maximum interval is 40 ms and is configurable through
`approx_sync_max_interval`. No separate `rtabmap_sync/rgbd_sync` node is
launched.

## Build and run

Build the default `linux/arm64` image:

```bash
./slam.sh build
```

Start it in the background:

```bash
./slam.sh create
```

For a native x86-64 development build:

```bash
ROBOT_PLATFORM=linux/amd64 ./slam.sh build
```

All containers that exchange ROS data must use the same domain:

```bash
ROS_DOMAIN_ID=7 ./slam.sh create
```

The Compose example uses host networking and Cyclone DDS. It has no hardware
mounts and does not require privileged mode.

## Configuration

`config/slam.yaml` is mounted read-only into the container. It has two
sections:

- `slam_bringup.ros__parameters` controls the runtime mode, namespace,
  database, topic remappings, and log level;
- `rtabmap.ros__parameters` is passed to the upstream RTAB-Map node, allowing
  additional supported RTAB-Map parameters to be added without changing the
  launch file.

The launch file can also use another configuration:

```bash
ros2 launch rtabmap_bringup slam.launch.py \
  config_file:=/absolute/path/to/slam.yaml
```

### Database modes

| Mode | Behaviour |
| --- | --- |
| `mapping` | Create a database or continue mapping from the existing one. |
| `reset_mapping` | Delete the configured database before creating a new map. |
| `localization` | Load an existing non-empty database without adding map nodes. |

The default is `mapping`. The database is stored in `data/rtabmap.db`, which
survives container replacement. Select `reset_mapping` deliberately because it
deletes that file when RTAB-Map starts.

### Processing rate

`Rtabmap/DetectionRate` is `5.0` Hz by default. This is independent of the
15 FPS RealSense stream. If processing takes longer than 200 ms per update,
CPU usage remains saturated, or the Raspberry Pi thermally throttles, reduce
the value to `3.0` or `2.0`. The bounded input queues prevent old frames from
accumulating while RTAB-Map is busy.

### Frames

RTAB-Map uses `base_link` as its robot frame and publishes `map -> odom`. The
EKF remains the only publisher of `odom -> base_link`. `realsense_link` is the
camera mounting frame in the robot description; it must be connected to
`base_link` and to the optical frame reported by the RealSense messages.

Do not change RTAB-Map's `frame_id` to `realsense_link` while `/odom` describes
`base_link`, because that would mix camera and robot poses.

## ROS outputs

With the default namespace, the main outputs are:

| Topic | Type or purpose |
| --- | --- |
| `/rtabmap/map` | `nav_msgs/msg/OccupancyGrid` for 2D navigation |
| `/rtabmap/mapData` | RTAB-Map graph and compressed sensor data |
| `/rtabmap/mapGraph` | Optimized pose graph |
| `/rtabmap/cloud_map` | Assembled `sensor_msgs/msg/PointCloud2` map |
| `/rtabmap/info` | Processing and loop-closure statistics |

The outputs are visible to an offboard computer on the same ROS domain. A
future offboard configuration can reconstruct the detailed 3D environment
from `/rtabmap/mapData` with the `rtabmap_rviz_plugins/MapCloud` display, or
show `/rtabmap/cloud_map` with RViz's standard PointCloud2 display. No offboard
or visualization code is included here.

## Validation

Static and container checks:

```bash
./slam.sh check
python3 -m py_compile src/rtabmap_bringup/launch/slam.launch.py
xmllint --noout src/rtabmap_bringup/package.xml
docker compose config --quiet
docker compose build
docker compose run --rm slam ros2 pkg executables rtabmap_slam
```

Hardware validation must additionally confirm that `/rtabmap/info` updates,
the database grows, the TF tree is complete, and an offboard ROS 2 process can
receive `mapData` and `cloud_map`. A successful image build alone does not
prove RealSense, EKF, TF, or cross-host DDS behaviour.
