# RTAB-Map Full Parameter Guide

This guide accompanies `rtabmap_full_structured.yaml`. The configuration is ordered by **what you are trying to tune**, not alphabetically by RTAB-Map prefix.

## Organization principle

The first sections contain the controls that are most likely to be changed on a mobile indoor robot. Inside each section, the **master/high-impact parameter comes first**, followed immediately by the parameters that refine that same behavior.

> **Important:** RGB, depth and scan topic names are normally configured as ROS 2 **remappings**, not as `ros__parameters`. Parameters such as `subscribe_rgb`, `subscribe_depth`, synchronization queues and QoS define how inputs are consumed; launch remappings define which topic names are connected.

## Recommended tuning order for indoor mapping

1. Inputs, frames, synchronization and QoS.
2. Node creation rate and density.
3. Global loop-closure strictness.
4. Local/proximity loop closure.
5. Visual/ICP registration.
6. Pose-graph consistency checks.
7. Occupancy and 3-D map generation.

## Indoor conservative overrides used in the YAML

| Parameter | Upstream default | File value | Purpose |
|---|---:|---:|---|
| `Rtabmap/DetectionRate` | `1` | `3.0` | Maximum RTAB-Map processing/update rate in Hz. |
| `Rtabmap/LoopThr` | `0.11` | `0.20` | Appearance-based global loop-closure acceptance threshold. Higher = more conservative. |
| `Mem/STMSize` | `10` | `30` | Number of recent nodes kept in Short-Term Memory, protecting them from normal loop-closure retrieval. |
| `Kp/MaxDepth` | `0` | `3.5` | Reject visual keypoints beyond this depth in metres; 0 means unlimited. |
| `VhEp/Enabled` | `false` | `true` | Verify visual loop hypotheses with epipolar geometry before metric registration. |
| `VhEp/MatchCountMin` | `8` | `12` | Minimum visual-word matches required by epipolar verification. |
| `RGBD/LinearUpdate` | `0.1` | `0.05` | Minimum translation in metres required to create/update a node. |
| `RGBD/AngularUpdate` | `0.1` | `0.05` | Minimum rotation in radians required to create/update a node. |
| `RGBD/OptimizeMaxError` | `3.0` | `3.0` | Reject loop/proximity constraints when graph optimization becomes too inconsistent. |
| `RGBD/CreateOccupancyGrid` | `false` | `true` | Create local occupancy data; Grid/* controls its construction. |
| `RGBD/ProximityByTime` | `false` | `false` | Search Short-Term Memory for proximity closures. |
| `RGBD/ProximityBySpace` | `true` | `false` | Search nearby graph nodes for local spatial loop closures. Risky in repetitive indoor layouts if odometry is wrong. |
| `RGBD/ProximityMaxGraphDepth` | `50` | `30` | Maximum graph depth explored for spatial proximity candidates. |
| `RGBD/ProximityMaxPaths` | `3` | `2` | Maximum graph paths evaluated for proximity detection. |
| `RGBD/ProximityPathFilteringRadius` | `1` | `0.5` | Radius used to thin candidate nodes along proximity paths. |
| `RGBD/ProximityAngle` | `45` | `30` | Maximum orientation difference in degrees for one-to-one proximity matching. |
| `RGBD/ProximityOdomGuess` | `false` | `true` | Use odometry as initial motion guess for proximity registration. |
| `Reg/Strategy` | `0` | `0` | Registration backend: 0 visual, 1 ICP, 2 visual followed by ICP. |
| `Reg/Force3DoF` | `false` | `true` | Restrict accepted registration to x, y and yaw. |
| `Vis/MinInliers` | `20` | `30` | Minimum feature inliers required to accept a visual transform. |
| `Vis/MaxDepth` | `0` | `3.5` | Maximum depth of visual registration features. |
| `Vis/CorNNDR` | `0.8` | `0.75` | NNDR for pairwise visual correspondence matching. Lower = stricter. |
| `Vis/CorGuessWinSize` | `40` | `40` | Pixel search window around predicted projections when a transform guess exists. |
| `Grid/Sensor` | `1` | `1` | Occupancy source: 0 laser, 1 depth, 2 both. |
| `Grid/DepthDecimation` | `4` | `4` | Depth-image decimation before local cloud/grid creation. |
| `Grid/RangeMin` | `0.0` | `0.20` | Minimum range included in occupancy processing. |
| `Grid/RangeMax` | `5.0` | `4.0` | Maximum range included in occupancy processing; 0 = unlimited. |
| `Grid/CellSize` | `0.05` | `0.05` | Occupancy-grid voxel/cell resolution in metres. |
| `Grid/NormalsSegmentation` | `true` | `true` | Use normals to separate ground from obstacles. |
| `Grid/MaxObstacleHeight` | `0.0` | `2.0` | Ignore obstacle points above this height; 0 disables. |
| `Grid/3D` | `true` | `true` | Build 3-D occupancy data rather than only projecting to a 2-D local grid. |
| `Grid/RayTracing` | `false` | `true` | Ray-trace free space from sensors to occupied cells. |

## 01 — Macro configuration / inputs / ROS 2

| Parameter | Type | File value | Purpose |
|---|---|---:|---|
| `use_sim_time` | bool | `false` | Use ROS simulation clock. |
| `frame_id` | string | `base_link` | Robot base frame. |
| `map_frame_id` | string | `map` | Global map frame. |
| `odom_frame_id` | string | `` | Use TF odometry from this frame when non-empty. |
| `publish_tf` | bool | `true` | Publish the map->odom transform. |
| `subscribe_rgb` | bool | `true` | Subscribe to RGB images. |
| `subscribe_depth` | bool | `true` | Subscribe to depth images. |
| `subscribe_rgbd` | bool | `false` | Subscribe to pre-synchronized RGBDImage messages. |
| `subscribe_stereo` | bool | `false` | Subscribe to stereo input. |
| `subscribe_scan` | bool | `false` | Subscribe to a 2-D LaserScan. |
| `subscribe_scan_cloud` | bool | `false` | Subscribe to a 3-D laser cloud. |
| `subscribe_odom` | bool | `true` | Subscribe to nav_msgs/Odometry. |
| `subscribe_odom_info` | bool | `false` | Subscribe to odometry diagnostics/info. |
| `rgbd_cameras` | int | `1` | Number of RGB-D cameras. |
| `approx_sync` | bool | `true` | Use approximate message synchronization. |
| `approx_sync_max_interval` | double | `0.10` | Maximum timestamp span for approximate synchronization. |
| `topic_queue_size` | int | `10` | Subscriber queue depth. |
| `sync_queue_size` | int | `10` | Synchronization queue depth. |
| `qos_image` | int | `2` | QoS reliability for images. |
| `qos_camera_info` | int | `2` | QoS reliability for CameraInfo. |
| `qos_odom` | int | `1` | QoS reliability for odometry. |
| `qos_scan` | int | `2` | QoS reliability for scan data. |
| `database_path` | string | `~/.ros/rtabmap.db` | RTAB-Map database file. |
| `delete_db_on_start` | bool | `false` | Delete the database on startup. |
| `config_path` | string | `` | Optional RTAB-Map INI configuration file. |
| `wait_for_transform` | double | `0.2` | Maximum wait for required TF transforms. |
| `odom_sensor_sync` | bool | `true` | Synchronize processing with odometry. |
| `tf_delay` | double | `0.05` | Delay applied to published map TF. |
| `tf_tolerance` | double | `0.1` | TF timestamp tolerance. |
| `image_transport` | string | `raw` | RGB image transport. |
| `depth_transport` | string | `raw` | Depth image transport. |
| `subscribe_scan_descriptor` | bool | `false` | Subscribe to scan descriptors. |
| `subscribe_sensor_data` | bool | `false` | Subscribe to RTAB-Map SensorData. |
| `subscribe_inter_odom_info` | bool | `false` | Subscribe to intermediate odometry info. |
| `subscribe_user_data` | bool | `false` | Subscribe to user data. |
| `queue_size` | int | `-1` | Legacy queue-size alias; -1 keeps dedicated queue settings. |
| `qos` | int | `0` | Generic QoS reliability policy. |
| `qos_user_data` | int | `0` | QoS reliability for user data. |
| `qos_sensor_data` | int | `0` | QoS reliability for SensorData. |
| `qos_gps` | int | `0` | QoS reliability for GPS. |
| `qos_imu` | int | `0` | QoS reliability for IMU. |
| `qos_env_sensor` | int | `0` | QoS reliability for environmental sensors. |
| `odom_tf_angular_variance` | double | `0.001` | Fallback angular variance when odometry is taken from TF. |
| `odom_tf_linear_variance` | double | `0.001` | Fallback linear variance when odometry is taken from TF. |
| `landmark_angular_variance` | double | `0.01` | Default angular landmark variance. |
| `landmark_linear_variance` | double | `0.001` | Default linear landmark variance. |
| `initial_pose` | string | `` | Optional initial localization pose. |
| `use_saved_map` | bool | `true` | Reuse the map stored in the database. |
| `use_action_for_goal` | bool | `false` | Use navigation action for goals. |
| `pub_loc_pose_only_when_localizing` | bool | `false` | Publish localization pose only in localization mode. |
| `staleness_factor` | double | `0.0` | Reject stale sensor data when enabled. |
| `gen_scan` | bool | `false` | Generate a synthetic scan from depth. |
| `gen_scan_min_depth` | double | `0.2` | Minimum depth for generated scan. |
| `gen_scan_max_depth` | double | `4.0` | Maximum depth for generated scan. |
| `gen_depth` | bool | `false` | Generate depth from scan/cloud. |
| `gen_depth_decimation` | int | `1` | Generated-depth decimation. |
| `gen_depth_fill_holes_size` | int | `0` | Generated-depth hole filling size. |
| `gen_depth_fill_iterations` | int | `0` | Generated-depth hole filling iterations. |
| `gen_depth_fill_holes_error` | double | `0.0` | Generated-depth hole filling error threshold. |
| `scan_cloud_max_points` | int | `0` | Maximum points retained from scan cloud. |
| `scan_cloud_is_2d` | bool | `false` | Treat input scan cloud as planar. |
| `stereo_to_depth` | bool | `false` | Convert stereo input to depth. |
| `is_rtabmap_paused` | bool | `false` | Start RTAB-Map paused. |
| `loc_thr` | double | `0.0` | Wrapper localization threshold when used. |
| `log_to_rosout_level` | int | `3` | RTAB-Map log/event level forwarded to rosout. |
| `map_filter_radius` | double | `0.0` | Map-node spatial filtering radius. |
| `map_filter_angle` | double | `30.0` | Map-node angular filtering threshold. |
| `map_cleanup` | bool | `true` | Remove cached data of nodes no longer in graph. |
| `map_always_update` | bool | `false` | Rebuild map outputs even when graph poses did not move. |
| `map_empty_ray_tracing` | bool | `true` | Enable empty-space ray tracing in map assembly. |
| `map_cache_loaded_on_init` | bool | `true` | Load map cache when opening an existing database. |
| `cloud_output_voxelized` | bool | `true` | Voxelize assembled output cloud. |
| `cloud_subtract_filtering` | bool | `false` | Subtract overlapping points while assembling clouds. |
| `cloud_subtract_filtering_min_neighbors` | int | `2` | Minimum neighbors for cloud subtraction filtering. |
| `latch` | bool | `true` | Latch/transient-local map publications. |
| `octomap_tree_depth` | int | `16` | Published OctoMap tree depth. |

## 02 — NODE CREATION, RATE & MEMORY

Controls when graph nodes are created and how recent/history memory is managed.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Rtabmap/DetectionRate` | float | `1` | `3.0` | Maximum RTAB-Map processing/update rate in Hz. |
| `RGBD/LinearUpdate` | float | `0.1` | `0.05` | Minimum translation in metres required to create/update a node. |
| `RGBD/AngularUpdate` | float | `0.1` | `0.05` | Minimum rotation in radians required to create/update a node. |
| `RGBD/LinearSpeedUpdate` | float | `0.0` | `0.0` | Maximum linear speed at which new nodes may be created; 0 means unlimited. |
| `RGBD/AngularSpeedUpdate` | float | `0.0` | `0.0` | Maximum angular speed at which new nodes may be created; 0 means unlimited. |
| `Mem/STMSize` | unsigned int | `10` | `30` | Number of recent nodes kept in Short-Term Memory, protecting them from normal loop-closure retrieval. |
| `Mem/IncrementalMemory` | bool | `true` | `true` | true = mapping/SLAM; false = localization mode. |
| `Mem/RehearsalSimilarity` | float | `0.6` | `0.6` | Similarity threshold used to merge/rehearse nearly identical consecutive locations. |
| `Rtabmap/MemoryThr` | int | `0` | `0` | Maximum Working Memory node count; 0 disables the limit. |
| `Rtabmap/TimeThr` | float | `0` | `0` | Maximum mapping-update computation time in ms; 0 disables the limit. |
| `Mem/RecentWmRatio` | float | `0.2` | `0.2` | memory and database-node handling setting: controls recent wm ratio. |
| `Mem/BadSignaturesIgnored` | bool | `false` | `false` | memory and database-node handling setting: controls bad signatures ignored. |
| `Mem/BinDataKept` | bool | `true` | `true` | Keep compressed sensor data in the database. |
| `Mem/CompressionParallelized` | bool | `true` | `true` | memory and database-node handling setting: controls compression parallelized. |
| `Mem/CovOffDiagIgnored` | bool | `true` | `true` | memory and database-node handling setting: controls cov off diag ignored. |
| `Mem/DepthAsMask` | bool | `true` | `true` | memory and database-node handling setting: controls depth as mask. |
| `Mem/DepthCompressionFormat` | string | `.rvl` | `.rvl` | memory and database-node handling setting: controls depth compression format. |
| `Mem/DepthMaskFloorThr` | float | `0.0` | `0.0` | memory and database-node handling setting: controls depth mask floor thr. |
| `Mem/GenerateIds` | bool | `true` | `true` | memory and database-node handling setting: controls generate ids. |
| `Mem/GlobalDescriptorStrategy` | int | `0` | `0` | memory and database-node handling setting: controls global descriptor strategy. |
| `Mem/ImageCompressionFormat` | string | `.jpg` | `.jpg` | memory and database-node handling setting: controls image compression format. |
| `Mem/ImageKept` | bool | `false` | `false` | Keep raw images in RAM. |
| `Mem/ImagePostDecimation` | unsigned int | `1` | `1` | memory and database-node handling setting: controls image post decimation. |
| `Mem/ImagePreDecimation` | unsigned int | `1` | `1` | memory and database-node handling setting: controls image pre decimation. |
| `Mem/InitWMWithAllNodes` | bool | `false` | `false` | memory and database-node handling setting: controls init wmwith all nodes. |
| `Mem/IntermediateNodeDataKept` | bool | `false` | `false` | memory and database-node handling setting: controls intermediate node data kept. |
| `Mem/LaserScanDownsampleStepSize` | int | `1` | `1` | memory and database-node handling setting: controls laser scan downsample step size. |
| `Mem/LaserScanNormalK` | int | `0` | `0` | memory and database-node handling setting: controls laser scan normal k. |
| `Mem/LaserScanNormalRadius` | float | `0.0` | `0.0` | memory and database-node handling setting: controls laser scan normal radius. |
| `Mem/LaserScanVoxelSize` | float | `0.0` | `0.0` | memory and database-node handling setting: controls laser scan voxel size. |
| `Mem/LoadVisualLocalFeaturesOnInit` | bool | `true` | `true` | memory and database-node handling setting: controls load visual local features on init. |
| `Mem/LocalizationDataSaved` | bool | `false` | `false` | memory and database-node handling setting: controls localization data saved. |
| `Mem/LocalizationReadOnly` | bool | `false` | `false` | memory and database-node handling setting: controls localization read only. |
| `Mem/MapLabelsAdded` | bool | `true` | `true` | memory and database-node handling setting: controls map labels added. |
| `Mem/NotLinkedNodesKept` | bool | `true` | `true` | memory and database-node handling setting: controls not linked nodes kept. |
| `Mem/RawDescriptorsKept` | bool | `true` | `true` | memory and database-node handling setting: controls raw descriptors kept. |
| `Mem/ReduceGraph` | bool | `false` | `false` | memory and database-node handling setting: controls reduce graph. |
| `Mem/RehearsalIdUpdatedToNewOne` | bool | `false` | `false` | memory and database-node handling setting: controls rehearsal id updated to new one. |
| `Mem/RehearsalWeightIgnoredWhileMoving` | bool | `false` | `false` | memory and database-node handling setting: controls rehearsal weight ignored while moving. |
| `Mem/RotateImagesUpsideUp` | bool | `false` | `false` | memory and database-node handling setting: controls rotate images upside up. |
| `Mem/SaveDepth16Format` | bool | `false` | `false` | memory and database-node handling setting: controls save depth16 format. |
| `Mem/StereoFromMotion` | bool | `false` | `false` | memory and database-node handling setting: controls stereo from motion. |
| `Mem/TransferSortingByWeightId` | bool | `false` | `false` | memory and database-node handling setting: controls transfer sorting by weight id. |
| `Mem/UseOdomFeatures` | bool | `true` | `true` | memory and database-node handling setting: controls use odom features. |
| `Mem/UseOdomGravity` | bool | `false` | `false` | memory and database-node handling setting: controls use odom gravity. |
| `RGBD/Enabled` | bool | `true` | `true` | Enable metric RGB-D/SLAM operation. |
| `RGBD/ForceOdom3DoF` | bool | `true` | `true` | Force odometry to planar motion when metric SLAM is planar. |
| `RGBD/GoalReachedRadius` | float | `0.5` | `0.5` | metric RGB-D SLAM setting: controls goal reached radius. |
| `RGBD/GoalsSavedInUserData` | bool | `false` | `false` | metric RGB-D SLAM setting: controls goals saved in user data. |
| `RGBD/InvertedReg` | bool | `false` | `false` | metric RGB-D SLAM setting: controls inverted reg. |
| `RGBD/LocalImmunizationRatio` | float | `0.25` | `0.25` | metric RGB-D SLAM setting: controls local immunization ratio. |
| `RGBD/LocalRadius` | float | `10` | `10` | metric RGB-D SLAM setting: controls local radius. |
| `RGBD/LocalizationPriorError` | double | `0.001` | `0.001` | metric RGB-D SLAM setting: controls localization prior error. |
| `RGBD/LocalizationSecondTryWithoutProximityLinks` | bool | `true` | `true` | metric RGB-D SLAM setting: controls localization second try without proximity links. |
| `RGBD/LocalizationSmoothing` | bool | `true` | `true` | metric RGB-D SLAM setting: controls localization smoothing. |
| `RGBD/MaxLocalRetrieved` | unsigned int | `2` | `2` | metric RGB-D SLAM setting: controls max local retrieved. |
| `RGBD/MaxOdomCacheSize` | int | `10` | `10` | metric RGB-D SLAM setting: controls max odom cache size. |
| `RGBD/NeighborLinkRefining` | bool | `false` | `false` | Refine odometry neighbor links using the selected registration backend. |
| `RGBD/NewMapOdomChangeDistance` | float | `0` | `0` | metric RGB-D SLAM setting: controls new map odom change distance. |
| `RGBD/PlanAngularVelocity` | float | `0` | `0` | metric RGB-D SLAM setting: controls plan angular velocity. |
| `RGBD/PlanLinearVelocity` | float | `0` | `0` | metric RGB-D SLAM setting: controls plan linear velocity. |
| `RGBD/PlanStuckIterations` | int | `0` | `0` | metric RGB-D SLAM setting: controls plan stuck iterations. |
| `RGBD/ScanMatchingIdsSavedInLinks` | bool | `true` | `true` | metric RGB-D SLAM setting: controls scan matching ids saved in links. |
| `RGBD/StartAtOrigin` | bool | `false` | `false` | metric RGB-D SLAM setting: controls start at origin. |
| `Rtabmap/CreateIntermediateNodes` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls create intermediate nodes. |
| `Rtabmap/ImageBufferSize` | unsigned int | `1` | `1` | RTAB-Map global runtime/loop-detection setting: controls image buffer size. |

## 03 — GLOBAL LOOP CLOSURE

Appearance-based place recognition and safeguards against false global loop closures.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Rtabmap/LoopThr` | float | `0.11` | `0.20` | Appearance-based global loop-closure acceptance threshold. Higher = more conservative. |
| `VhEp/Enabled` | bool | `false` | `true` | Verify visual loop hypotheses with epipolar geometry before metric registration. |
| `VhEp/MatchCountMin` | int | `8` | `12` | Minimum visual-word matches required by epipolar verification. |
| `RGBD/MaxLoopClosureDistance` | float | `0.0` | `0.0` | Maximum accepted metric distance for loop/localization constraints; 0 disables. |
| `RGBD/LoopCovLimited` | bool | `false` | `false` | Prevent loop closures from receiving unrealistically strong covariance relative to odometry. |
| `Rtabmap/LoopRatio` | float | `0` | `0` | Requires the new loop hypothesis to improve over the previous one by this ratio. |
| `RGBD/AggressiveLoopThr` | float | `0.05` | `0.05` | Alternative lower loop threshold used while linking an unconnected mapping session. |
| `RGBD/LoopClosureIdentityGuess` | bool | `false` | `false` | Use identity as initial transform guess for loop-closure registration. |
| `RGBD/LoopClosureReextractFeatures` | bool | `false` | `false` | Re-extract features during loop registration instead of reusing stored features. |
| `RGBD/LocalBundleOnLoopClosure` | bool | `false` | `false` | Run local bundle adjustment around accepted loop closures. |
| `Rtabmap/LoopGPS` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls loop gps. |
| `Rtabmap/VirtualPlaceLikelihoodRatio` | int | `0` | `0` | RTAB-Map global runtime/loop-detection setting: controls virtual place likelihood ratio. |
| `VhEp/RansacParam1` | float | `3` | `3` | epipolar loop-verification setting: controls ransac param1. |
| `VhEp/RansacParam2` | float | `0.99` | `0.99` | epipolar loop-verification setting: controls ransac param2. |

## 04 — LOCAL / PROXIMITY LOOP CLOSURE

Spatial and temporal local closures; especially important in houses with repeated room geometry.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `RGBD/ProximityBySpace` | bool | `true` | `false` | Search nearby graph nodes for local spatial loop closures. Risky in repetitive indoor layouts if odometry is wrong. |
| `RGBD/ProximityByTime` | bool | `false` | `false` | Search Short-Term Memory for proximity closures. |
| `RGBD/ProximityAngle` | float | `45` | `30` | Maximum orientation difference in degrees for one-to-one proximity matching. |
| `RGBD/ProximityOdomGuess` | bool | `false` | `true` | Use odometry as initial motion guess for proximity registration. |
| `RGBD/ProximityMaxGraphDepth` | int | `50` | `30` | Maximum graph depth explored for spatial proximity candidates. |
| `RGBD/ProximityMaxPaths` | int | `3` | `2` | Maximum graph paths evaluated for proximity detection. |
| `RGBD/ProximityPathFilteringRadius` | float | `1` | `0.5` | Radius used to thin candidate nodes along proximity paths. |
| `RGBD/ProximityPathMaxNeighbors` | int | `0` | `0` | Maximum neighbors used for one-to-many proximity matching; 0 disables that mode. |
| `RGBD/ProximityPathRawPosesUsed` | bool | `true` | `true` | Use odometry/raw path poses rather than optimized local poses when merging scans for proximity. |
| `RGBD/ProximityGlobalScanMap` | bool | `false` | `false` | metric RGB-D SLAM setting: controls proximity global scan map. |
| `RGBD/ProximityMergedScanCovFactor` | double | `100.0` | `100.0` | metric RGB-D SLAM setting: controls proximity merged scan cov factor. |

## 05 — VISUAL REGISTRATION

How visual correspondences become a metric transform and how that transform is validated.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Reg/Strategy` | int | `0` | `0` | Registration backend: 0 visual, 1 ICP, 2 visual followed by ICP. |
| `Reg/Force3DoF` | bool | `false` | `true` | Restrict accepted registration to x, y and yaw. |
| `Reg/RepeatOnce` | bool | `true` | `true` | Run a second registration pass using the first result as a guess. |
| `Vis/EstimationType` | int | `1` | `1` | Visual pose estimation: 0 3D-3D, 1 PnP 3D-2D, 2 epipolar 2D-2D. |
| `Vis/MinInliers` | int | `20` | `30` | Minimum feature inliers required to accept a visual transform. |
| `Vis/PnPReprojError` | float | `2` | `2` | PnP RANSAC reprojection-error threshold in pixels. |
| `Vis/Iterations` | int | `300` | `300` | Maximum visual RANSAC/pose-estimation iterations. |
| `Vis/MaxFeatures` | int | `1000` | `1000` | Maximum features used by visual registration. |
| `Vis/MaxDepth` | float | `0` | `3.5` | Maximum depth of visual registration features. |
| `Vis/MinDepth` | float | `0` | `0` | visual registration setting: controls min depth. |
| `Vis/CorType` | int | `0` | `0` | visual registration setting: controls cor type. |
| `Vis/CorNNType` | int | `1` | `1` | visual registration setting: controls cor nntype. |
| `Vis/CorNNDR` | float | `0.8` | `0.75` | NNDR for pairwise visual correspondence matching. Lower = stricter. |
| `Vis/CorGuessWinSize` | int | `40` | `40` | Pixel search window around predicted projections when a transform guess exists. |
| `Vis/MinInliersDistribution` | float | `0.0` | `0.0` | visual registration setting: controls min inliers distribution. |
| `Vis/MeanInliersDistance` | float | `0.0` | `0.0` | visual registration setting: controls mean inliers distance. |
| `Vis/PnPMaxVariance` | float | `0.0` | `0.0` | visual registration setting: controls pn pmax variance. |
| `GMS/ThresholdFactor` | double | `6.0` | `6.0` | GMS feature matching setting: controls threshold factor. |
| `GMS/WithRotation` | bool | `false` | `false` | GMS feature matching setting: controls with rotation. |
| `GMS/WithScale` | bool | `false` | `false` | GMS feature matching setting: controls with scale. |
| `PyMatcher/Cuda` | bool | `true` | `true` | Python/SuperGlue matcher setting: controls cuda. |
| `PyMatcher/Iterations` | int | `20` | `20` | Python/SuperGlue matcher setting: controls iterations. |
| `PyMatcher/Model` | string | `indoor` | `indoor` | Python/SuperGlue matcher setting: controls model. |
| `PyMatcher/Path` | string | `` | `` | Python/SuperGlue matcher setting: controls path. |
| `PyMatcher/Threshold` | float | `0.2` | `0.2` | Python/SuperGlue matcher setting: controls threshold. |
| `Vis/BundleAdjustment` | int | `1` | `1` | visual registration setting: controls bundle adjustment. |
| `Vis/CorFlowEps` | float | `0.01` | `0.01` | visual registration setting: controls cor flow eps. |
| `Vis/CorFlowErrorThreshold` | float | `20` | `20` | visual registration setting: controls cor flow error threshold. |
| `Vis/CorFlowGpu` | bool | `false` | `false` | visual registration setting: controls cor flow gpu. |
| `Vis/CorFlowIterations` | int | `30` | `30` | visual registration setting: controls cor flow iterations. |
| `Vis/CorFlowMaxLevel` | int | `3` | `3` | visual registration setting: controls cor flow max level. |
| `Vis/CorFlowMinEigThreshold` | float | `1e-4` | `1e-4` | visual registration setting: controls cor flow min eig threshold. |
| `Vis/CorFlowUseMinEigenVals` | bool | `true` | `true` | visual registration setting: controls cor flow use min eigen vals. |
| `Vis/CorFlowWinSize` | int | `16` | `16` | visual registration setting: controls cor flow win size. |
| `Vis/CorGuessMatchToProjection` | bool | `false` | `false` | visual registration setting: controls cor guess match to projection. |
| `Vis/DepthAsMask` | bool | `true` | `true` | visual registration setting: controls depth as mask. |
| `Vis/DepthMaskFloorThr` | float | `0.0` | `0.0` | visual registration setting: controls depth mask floor thr. |
| `Vis/EpipolarGeometryVar` | float | `0.1` | `0.1` | visual registration setting: controls epipolar geometry var. |
| `Vis/FeatureType` | int | `8` | `8` | Feature family used specifically by visual registration. |
| `Vis/GridCols` | int | `1` | `1` | visual registration setting: controls grid cols. |
| `Vis/GridRows` | int | `1` | `1` | visual registration setting: controls grid rows. |
| `Vis/InlierDistance` | float | `0.1` | `0.1` | visual registration setting: controls inlier distance. |
| `Vis/PnPFlags` | int | `0` | `0` | visual registration setting: controls pn pflags. |
| `Vis/PnPRefineIterations` | int | `0` | `0` | visual registration setting: controls pn prefine iterations. |
| `Vis/PnPSamplingPolicy` | unsigned int | `1` | `1` | visual registration setting: controls pn psampling policy. |
| `Vis/PnPSplitLinearCovComponents` | bool | `false` | `false` | visual registration setting: controls pn psplit linear cov components. |
| `Vis/PnPVarianceMedianRatio` | int | `4` | `4` | visual registration setting: controls pn pvariance median ratio. |
| `Vis/RefineIterations` | int | `5` | `5` | visual registration setting: controls refine iterations. |
| `Vis/RoiRatios` | string | `0.0 0.0 0.0 0.0` | `0.0 0.0 0.0 0.0` | visual registration setting: controls roi ratios. |
| `Vis/SSC` | bool | `false` | `false` | visual registration setting: controls ssc. |
| `Vis/SubPixEps` | float | `0.02` | `0.02` | visual registration setting: controls sub pix eps. |
| `Vis/SubPixIterations` | int | `0` | `0` | visual registration setting: controls sub pix iterations. |
| `Vis/SubPixWinSize` | int | `3` | `3` | visual registration setting: controls sub pix win size. |

## 06 — POSE-GRAPH OPTIMIZATION

Back-end graph optimizer and consistency protection.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `RGBD/OptimizeMaxError` | float | `3.0` | `3.0` | Reject loop/proximity constraints when graph optimization becomes too inconsistent. |
| `Optimizer/Strategy` | int | `2` | `2` | Pose-graph optimizer backend: TORO/g2o/GTSAM/Ceres depending on build. |
| `Optimizer/Iterations` | int | `20` | `20` | Maximum graph-optimization iterations. |
| `Optimizer/Epsilon` | double | `0.00001` | `0.00001` | Optimization convergence tolerance. |
| `Optimizer/Robust` | bool | `false` | `false` | Enable robust graph optimization where supported. |
| `Optimizer/VarianceIgnored` | bool | `false` | `false` | Ignore edge covariance and use identity information matrices. |
| `Optimizer/PriorsIgnored` | bool | `true` | `true` | Ignore global/GPS/marker priors during graph optimization. |
| `Optimizer/LandmarksIgnored` | bool | `false` | `false` | Ignore landmark constraints during graph optimization. |
| `Optimizer/GravitySigma` | float | `0.3` | `0.3` | Strength of gravity-orientation constraints. |
| `GTSAM/Incremental` | bool | `false` | `false` | GTSAM optimizer setting: controls incremental. |
| `GTSAM/Optimizer` | int | `1` | `1` | GTSAM optimizer setting: controls optimizer. |
| `g2o/Optimizer` | int | `0` | `0` | g2o optimizer setting: controls optimizer. |
| `g2o/Solver` | int | `3` | `3` | g2o optimizer setting: controls solver. |
| `GTSAM/IncRelinearizeSkip` | int | `1` | `1` | GTSAM optimizer setting: controls inc relinearize skip. |
| `GTSAM/IncRelinearizeThreshold` | double | `0.01` | `0.01` | GTSAM optimizer setting: controls inc relinearize threshold. |
| `Optimizer/Baseline` | double | `0.075` | `0.075` | pose-graph/bundle optimizer setting: controls baseline. |
| `Optimizer/DisparityVariance` | double | `1.0` | `1.0` | pose-graph/bundle optimizer setting: controls disparity variance. |
| `Optimizer/PixelVariance` | double | `1.0` | `1.0` | pose-graph/bundle optimizer setting: controls pixel variance. |
| `Optimizer/RobustKernelDelta` | double | `8` | `8` | pose-graph/bundle optimizer setting: controls robust kernel delta. |
| `RGBD/OptimizeFromGraphEnd` | bool | `false` | `false` | metric RGB-D SLAM setting: controls optimize from graph end. |
| `RGBD/OptimizeMaxErrorRepairRadius` | float | `0.0` | `0.0` | metric RGB-D SLAM setting: controls optimize max error repair radius. |

## 07 — OCCUPANCY / 3-D GRID GENERATION

Depth/LiDAR local grids and global occupancy integration.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `RGBD/CreateOccupancyGrid` | bool | `false` | `true` | Create local occupancy data; Grid/* controls its construction. |
| `Grid/Sensor` | int | `1` | `1` | Occupancy source: 0 laser, 1 depth, 2 both. |
| `Grid/CellSize` | float | `0.05` | `0.05` | Occupancy-grid voxel/cell resolution in metres. |
| `Grid/RangeMin` | float | `0.0` | `0.20` | Minimum range included in occupancy processing. |
| `Grid/RangeMax` | float | `5.0` | `4.0` | Maximum range included in occupancy processing; 0 = unlimited. |
| `Grid/DepthDecimation` | unsigned int | `4` | `4` | Depth-image decimation before local cloud/grid creation. |
| `Grid/3D` | bool | `true` | `true` | Build 3-D occupancy data rather than only projecting to a 2-D local grid. |
| `Grid/NormalsSegmentation` | bool | `true` | `true` | Use normals to separate ground from obstacles. |
| `Grid/MaxObstacleHeight` | float | `0.0` | `2.0` | Ignore obstacle points above this height; 0 disables. |
| `Grid/MaxGroundHeight` | float | `0.0` | `0.0` | local occupancy-grid setting: controls max ground height. |
| `Grid/MinGroundHeight` | float | `0.0` | `0.0` | local occupancy-grid setting: controls min ground height. |
| `Grid/MaxGroundAngle` | float | `45` | `45` | Maximum normal angle from vertical for classifying ground. |
| `Grid/NormalK` | int | `20` | `20` | Neighbors used for normal estimation. |
| `Grid/RayTracing` | bool | `false` | `true` | Ray-trace free space from sensors to occupied cells. |
| `Grid/ClusterRadius` | float | `0.1` | `0.1` | Clustering radius used after ground/obstacle segmentation. |
| `Grid/MinClusterSize` | int | `10` | `10` | Minimum cluster size kept in occupancy generation. |
| `GridGlobal/OccupancyThr` | float | `0.5` | `0.5` | Probability threshold above which a cell is considered occupied. |
| `GridGlobal/ProbHit` | float | `0.7` | `0.7` | Occupancy probability update for a hit. |
| `GridGlobal/ProbMiss` | float | `0.4` | `0.4` | Occupancy probability update for a miss/free-space observation. |
| `Grid/DepthRoiRatios` | string | `0.0 0.0 0.0 0.0` | `0.0 0.0 0.0 0.0` | local occupancy-grid setting: controls depth roi ratios. |
| `Grid/FlatObstacleDetected` | bool | `true` | `true` | local occupancy-grid setting: controls flat obstacle detected. |
| `Grid/FootprintHeight` | float | `0.0` | `0.0` | local occupancy-grid setting: controls footprint height. |
| `Grid/FootprintLength` | float | `0.0` | `0.0` | local occupancy-grid setting: controls footprint length. |
| `Grid/FootprintWidth` | float | `0.0` | `0.0` | local occupancy-grid setting: controls footprint width. |
| `Grid/GroundIsObstacle` | bool | `false` | `false` | local occupancy-grid setting: controls ground is obstacle. |
| `Grid/MapFrameProjection` | bool | `false` | `false` | local occupancy-grid setting: controls map frame projection. |
| `Grid/NoiseFilteringMinNeighbors` | int | `5` | `5` | local occupancy-grid setting: controls noise filtering min neighbors. |
| `Grid/NoiseFilteringRadius` | float | `0.0` | `0.0` | local occupancy-grid setting: controls noise filtering radius. |
| `Grid/PreVoxelFiltering` | bool | `true` | `true` | local occupancy-grid setting: controls pre voxel filtering. |
| `Grid/Scan2dUnknownSpaceFilled` | bool | `false` | `false` | local occupancy-grid setting: controls scan2d unknown space filled. |
| `Grid/ScanDecimation` | int | `1` | `1` | local occupancy-grid setting: controls scan decimation. |
| `GridGlobal/AltitudeDelta` | float | `0` | `0` | global occupancy-map setting: controls altitude delta. |
| `GridGlobal/Eroded` | bool | `false` | `false` | global occupancy-map setting: controls eroded. |
| `GridGlobal/FloodFillDepth` | unsigned int | `0` | `0` | global occupancy-map setting: controls flood fill depth. |
| `GridGlobal/FootprintRadius` | float | `0.0` | `0.0` | global occupancy-map setting: controls footprint radius. |
| `GridGlobal/MaxNodes` | int | `0` | `0` | global occupancy-map setting: controls max nodes. |
| `GridGlobal/MinSize` | float | `0.0` | `0.0` | global occupancy-map setting: controls min size. |
| `GridGlobal/ProbClampingMax` | float | `0.971` | `0.971` | Maximum clamped occupancy probability. |
| `GridGlobal/ProbClampingMin` | float | `0.1192` | `0.1192` | Minimum clamped occupancy probability. |
| `GridGlobal/UpdateError` | float | `0.01` | `0.01` | global occupancy-map setting: controls update error. |

## 08 — ICP / LIDAR REGISTRATION

Geometric scan registration and ICP validation.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Icp/Strategy` | int | `1` | `1` | ICP implementation backend. |
| `Icp/MaxTranslation` | float | `0.2` | `0.2` | Maximum translation correction accepted from ICP. |
| `Icp/MaxRotation` | float | `0.78` | `0.78` | Maximum rotation correction accepted from ICP in radians. |
| `Icp/VoxelSize` | float | `0.05` | `0.05` | Voxel downsampling size before ICP. |
| `Icp/RangeMin` | float | `0` | `0` | Minimum ICP range. |
| `Icp/RangeMax` | float | `0` | `0` | Maximum ICP range. |
| `Icp/MaxCorrespondenceDistance` | float | `0.1` | `0.1` | Maximum distance between paired ICP points. |
| `Icp/CorrespondenceRatio` | float | `0.1` | `0.1` | Minimum valid correspondence ratio required to accept ICP. |
| `Icp/Iterations` | int | `30` | `30` | Maximum ICP iterations. |
| `Icp/PointToPlane` | bool | `true` | `true` | Use point-to-plane ICP where geometry supports it. |
| `Icp/PointToPlaneMinComplexity` | float | `0.02` | `0.02` | Minimum scan structural complexity required for point-to-plane ICP. |
| `Icp/ReciprocalCorrespondences` | bool | `true` | `true` | ICP registration setting: controls reciprocal correspondences. |
| `Icp/CCFilterOutFarthestPoints` | bool | `false` | `false` | ICP registration setting: controls ccfilter out farthest points. |
| `Icp/CCMaxFinalRMS` | float | `0.2` | `0.2` | ICP registration setting: controls ccmax final rms. |
| `Icp/CCSamplingLimit` | unsigned int | `50000` | `50000` | ICP registration setting: controls ccsampling limit. |
| `Icp/DebugExportFormat` | string | `` | `` | ICP registration setting: controls debug export format. |
| `Icp/DownsamplingStep` | int | `1` | `1` | ICP registration setting: controls downsampling step. |
| `Icp/Epsilon` | float | `0` | `0` | ICP registration setting: controls epsilon. |
| `Icp/FiltersEnabled` | int | `3` | `3` | ICP registration setting: controls filters enabled. |
| `Icp/Force4DoF` | bool | `false` | `false` | ICP registration setting: controls force4 do f. |
| `Icp/OutlierRatio` | float | `0.85` | `0.85` | ICP registration setting: controls outlier ratio. |
| `Icp/PMConfig` | string | `` | `` | ICP registration setting: controls pmconfig. |
| `Icp/PMMatcherEpsilon` | float | `0.0` | `0.0` | ICP registration setting: controls pmmatcher epsilon. |
| `Icp/PMMatcherIntensity` | bool | `false` | `false` | ICP registration setting: controls pmmatcher intensity. |
| `Icp/PMMatcherKnn` | int | `1` | `1` | ICP registration setting: controls pmmatcher knn. |
| `Icp/PointToPlaneComplexityCentered` | bool | `false` | `false` | ICP registration setting: controls point to plane complexity centered. |
| `Icp/PointToPlaneGroundNormalsUp` | float | `0.0` | `0.0` | ICP registration setting: controls point to plane ground normals up. |
| `Icp/PointToPlaneK` | int | `5` | `5` | ICP registration setting: controls point to plane k. |
| `Icp/PointToPlaneLowComplexityStrategy` | int | `1` | `1` | ICP registration setting: controls point to plane low complexity strategy. |
| `Icp/PointToPlaneRadius` | float | `0.0` | `0.0` | ICP registration setting: controls point to plane radius. |

## 09 — VISUAL FEATURE EXTRACTION & MATCHING

Vocabulary and detector/descriptor tuning.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Kp/DetectorStrategy` | int | `8` | `8` | Feature detector/descriptor family used for vocabulary creation. |
| `Kp/MaxFeatures` | int | `500` | `500` | Maximum visual features extracted per image. |
| `Kp/MaxDepth` | float | `0` | `3.5` | Reject visual keypoints beyond this depth in metres; 0 means unlimited. |
| `Kp/MinDepth` | float | `0` | `0` | Reject visual keypoints closer than this depth. |
| `Kp/NndrRatio` | float | `0.8` | `0.8` | NNDR for visual-word matching. Lower values are more selective. |
| `Kp/NNStrategy` | int | `1` | `1` | visual-word/keypoint extraction setting: controls nnstrategy. |
| `Kp/GridRows` | int | `1` | `1` | visual-word/keypoint extraction setting: controls grid rows. |
| `Kp/GridCols` | int | `1` | `1` | visual-word/keypoint extraction setting: controls grid cols. |
| `Kp/RoiRatios` | string | `0.0 0.0 0.0 0.0` | `0.0 0.0 0.0 0.0` | visual-word/keypoint extraction setting: controls roi ratios. |
| `Kp/BadSignRatio` | float | `0.5` | `0.5` | visual-word/keypoint extraction setting: controls bad sign ratio. |
| `Kp/SSC` | bool | `false` | `false` | visual-word/keypoint extraction setting: controls ssc. |
| `BRIEF/Bytes` | int | `32` | `32` | BRIEF descriptor setting: controls bytes. |
| `BRISK/Octaves` | int | `3` | `3` | BRISK detector/descriptor setting: controls octaves. |
| `BRISK/PatternScale` | float | `1` | `1` | BRISK detector/descriptor setting: controls pattern scale. |
| `BRISK/Thresh` | int | `30` | `30` | BRISK detector/descriptor setting: controls thresh. |
| `Bayes/FullPredictionUpdate` | bool | `false` | `false` | Bayesian loop-closure prediction setting: controls full prediction update. |
| `Bayes/PredictionLC` | string | `0.1 0.36 0.30 0.16 0.062 0.0151 0.00255 0.000324 2.5e-05 1e-06 4.8e-08 1.2e-09 1.9e-11 2.2e-13 1.7e-15 8.5e-18 2.9e-20 6.9e-23` | `0.1 0.36 0.30 0.16 0.062 0.0151 0.00255 0.000324 2.5e-05 1e-06 4.8e-08 1.2e-09 1.9e-11 2.2e-13 1.7e-15 8.5e-18 2.9e-20 6.9e-23` | Bayesian loop-closure prediction setting: controls prediction lc. |
| `Bayes/SparsePrediction` | bool | `true` | `true` | Bayesian loop-closure prediction setting: controls sparse prediction. |
| `Bayes/VirtualPlacePriorThr` | float | `0.9` | `0.9` | Bayesian loop-closure prediction setting: controls virtual place prior thr. |
| `FAST/CV` | int | `0` | `0` | FAST detector setting: controls cv. |
| `FAST/Gpu` | bool | `false` | `false` | FAST detector setting: controls gpu. |
| `FAST/GpuKeypointsRatio` | double | `0.05` | `0.05` | FAST detector setting: controls gpu keypoints ratio. |
| `FAST/GridCols` | int | `0` | `0` | FAST detector setting: controls grid cols. |
| `FAST/GridRows` | int | `0` | `0` | FAST detector setting: controls grid rows. |
| `FAST/MaxThreshold` | int | `200` | `200` | FAST detector setting: controls max threshold. |
| `FAST/MinThreshold` | int | `7` | `7` | FAST detector setting: controls min threshold. |
| `FAST/NonmaxSuppression` | bool | `true` | `true` | FAST detector setting: controls nonmax suppression. |
| `FAST/Threshold` | int | `20` | `20` | FAST detector setting: controls threshold. |
| `FREAK/NOctaves` | int | `4` | `4` | FREAK descriptor setting: controls noctaves. |
| `FREAK/OrientationNormalized` | bool | `true` | `true` | FREAK descriptor setting: controls orientation normalized. |
| `FREAK/PatternScale` | float | `22` | `22` | FREAK descriptor setting: controls pattern scale. |
| `FREAK/ScaleNormalized` | bool | `true` | `true` | FREAK descriptor setting: controls scale normalized. |
| `GFTT/BlockSize` | int | `3` | `3` | Good-Features-To-Track detector setting: controls block size. |
| `GFTT/Gpu` | bool | `false` | `false` | Good-Features-To-Track detector setting: controls gpu. |
| `GFTT/K` | double | `0.04` | `0.04` | Good-Features-To-Track detector setting: controls k. |
| `GFTT/MinDistance` | double | `7` | `7` | Good-Features-To-Track detector setting: controls min distance. |
| `GFTT/QualityLevel` | double | `0.001` | `0.001` | Good-Features-To-Track detector setting: controls quality level. |
| `GFTT/UseHarrisDetector` | bool | `false` | `false` | Good-Features-To-Track detector setting: controls use harris detector. |
| `KAZE/Diffusivity` | int | `1` | `1` | KAZE detector/descriptor setting: controls diffusivity. |
| `KAZE/Extended` | bool | `false` | `false` | KAZE detector/descriptor setting: controls extended. |
| `KAZE/NOctaveLayers` | int | `4` | `4` | KAZE detector/descriptor setting: controls noctave layers. |
| `KAZE/NOctaves` | int | `4` | `4` | KAZE detector/descriptor setting: controls noctaves. |
| `KAZE/Threshold` | float | `0.001` | `0.001` | KAZE detector/descriptor setting: controls threshold. |
| `KAZE/Upright` | bool | `false` | `false` | KAZE detector/descriptor setting: controls upright. |
| `Kp/ByteToFloat` | bool | `false` | `false` | visual-word/keypoint extraction setting: controls byte to float. |
| `Kp/DictionaryPath` | string | `` | `` | visual-word/keypoint extraction setting: controls dictionary path. |
| `Kp/FlannIndexSaved` | bool | `false` | `false` | visual-word/keypoint extraction setting: controls flann index saved. |
| `Kp/FlannRebalancingFactor` | float | `2.0` | `2.0` | visual-word/keypoint extraction setting: controls flann rebalancing factor. |
| `Kp/FlannThreads` | int | `1` | `1` | visual-word/keypoint extraction setting: controls flann threads. |
| `Kp/IncrementalDictionary` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls incremental dictionary. |
| `Kp/IncrementalFlann` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls incremental flann. |
| `Kp/NewWordsComparedTogether` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls new words compared together. |
| `Kp/Parallelized` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls parallelized. |
| `Kp/SerializeWithChecksum` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls serialize with checksum. |
| `Kp/SubPixEps` | double | `0.02` | `0.02` | visual-word/keypoint extraction setting: controls sub pix eps. |
| `Kp/SubPixIterations` | int | `0` | `0` | visual-word/keypoint extraction setting: controls sub pix iterations. |
| `Kp/SubPixWinSize` | int | `3` | `3` | visual-word/keypoint extraction setting: controls sub pix win size. |
| `Kp/TfIdfLikelihoodUsed` | bool | `true` | `true` | visual-word/keypoint extraction setting: controls tf idf likelihood used. |
| `ORB/EdgeThreshold` | int | `19` | `19` | ORB detector/descriptor setting: controls edge threshold. |
| `ORB/FirstLevel` | int | `0` | `0` | ORB detector/descriptor setting: controls first level. |
| `ORB/Gpu` | bool | `false` | `false` | ORB detector/descriptor setting: controls gpu. |
| `ORB/NLevels` | int | `3` | `3` | ORB detector/descriptor setting: controls nlevels. |
| `ORB/PatchSize` | int | `31` | `31` | ORB detector/descriptor setting: controls patch size. |
| `ORB/ScaleFactor` | float | `2` | `2` | ORB detector/descriptor setting: controls scale factor. |
| `ORB/ScoreType` | int | `0` | `0` | ORB detector/descriptor setting: controls score type. |
| `ORB/WTA_K` | int | `2` | `2` | ORB detector/descriptor setting: controls wta k. |
| `PyDescriptor/Dim` | int | `4096` | `4096` | Python global-descriptor setting: controls dim. |
| `PyDescriptor/Path` | string | `` | `` | Python global-descriptor setting: controls path. |
| `PyDetector/Cuda` | bool | `true` | `true` | Python feature-detector backend setting: controls cuda. |
| `PyDetector/Path` | string | `` | `` | Python feature-detector backend setting: controls path. |
| `SIFT/ContrastThreshold` | double | `0.04` | `0.04` | SIFT detector/descriptor setting: controls contrast threshold. |
| `SIFT/EdgeThreshold` | double | `10` | `10` | SIFT detector/descriptor setting: controls edge threshold. |
| `SIFT/GaussianThreshold` | float | `2.0` | `2.0` | SIFT detector/descriptor setting: controls gaussian threshold. |
| `SIFT/Gpu` | bool | `false` | `false` | SIFT detector/descriptor setting: controls gpu. |
| `SIFT/MaxGaussianThreshold` | float | `0.0` | `0.0` | SIFT detector/descriptor setting: controls max gaussian threshold. |
| `SIFT/NOctaveLayers` | int | `3` | `3` | SIFT detector/descriptor setting: controls noctave layers. |
| `SIFT/PreciseUpscale` | bool | `false` | `false` | SIFT detector/descriptor setting: controls precise upscale. |
| `SIFT/RootSIFT` | bool | `false` | `false` | SIFT detector/descriptor setting: controls root sift. |
| `SIFT/Sigma` | double | `1.6` | `1.6` | SIFT detector/descriptor setting: controls sigma. |
| `SIFT/Upscale` | bool | `false` | `false` | SIFT detector/descriptor setting: controls upscale. |
| `SURF/Extended` | bool | `false` | `false` | SURF detector/descriptor setting: controls extended. |
| `SURF/GpuKeypointsRatio` | float | `0.01` | `0.01` | SURF detector/descriptor setting: controls gpu keypoints ratio. |
| `SURF/GpuVersion` | bool | `false` | `false` | SURF detector/descriptor setting: controls gpu version. |
| `SURF/HessianThreshold` | float | `500` | `500` | SURF detector/descriptor setting: controls hessian threshold. |
| `SURF/OctaveLayers` | int | `2` | `2` | SURF detector/descriptor setting: controls octave layers. |
| `SURF/Octaves` | int | `4` | `4` | SURF detector/descriptor setting: controls octaves. |
| `SURF/Upright` | bool | `false` | `false` | SURF detector/descriptor setting: controls upright. |
| `SuperPoint/Cuda` | bool | `true` | `true` | SuperPoint backend setting: controls cuda. |
| `SuperPoint/ModelPath` | string | `` | `` | SuperPoint backend setting: controls model path. |
| `SuperPoint/NMS` | bool | `true` | `true` | SuperPoint backend setting: controls nms. |
| `SuperPoint/NMSRadius` | int | `4` | `4` | SuperPoint backend setting: controls nmsradius. |
| `SuperPoint/Threshold` | float | `0.010` | `0.010` | SuperPoint backend setting: controls threshold. |
| `SuperPointRpautrat/Cuda` | bool | `true` | `true` | Rpautrat SuperPoint backend setting: controls cuda. |
| `SuperPointRpautrat/ModelPath` | string | `` | `` | Rpautrat SuperPoint backend setting: controls model path. |
| `SuperPointRpautrat/NMS` | bool | `true` | `true` | Rpautrat SuperPoint backend setting: controls nms. |
| `SuperPointRpautrat/NMSRadius` | int | `4` | `4` | Rpautrat SuperPoint backend setting: controls nmsradius. |
| `SuperPointRpautrat/Threshold` | float | `0.005` | `0.005` | Rpautrat SuperPoint backend setting: controls threshold. |
| `SuperPointRpautrat/WeightsPath` | string | `` | `` | Rpautrat SuperPoint backend setting: controls weights path. |

## 10 — ODOMETRY: COMMON

Generic RTAB-Map odometry controls and frame-to-map settings.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Odom/Strategy` | int | `0` | `0` | Internal RTAB-Map odometry backend selection. |
| `Odom/Holonomic` | bool | `true` | `true` | Whether the platform is allowed to move laterally. |
| `Odom/GuessMotion` | bool | `true` | `true` | Predict the next transform from previous motion. |
| `Odom/KeyFrameThr` | float | `0.3` | `0.3` | Visual keyframe inlier-ratio threshold. |
| `Odom/VisKeyFrameThr` | int | `150` | `150` | Absolute visual inlier threshold for creating a keyframe. |
| `Odom/ScanKeyFrameThr` | float | `0.9` | `0.9` | Geometric/ICP inlier-ratio threshold for creating a keyframe. |
| `Odom/ImageDecimation` | unsigned int | `1` | `1` | generic RTAB-Map odometry setting: controls image decimation. |
| `Odom/AlignWithGround` | bool | `false` | `false` | Align initial odometry orientation to the ground/gravity direction. |
| `Odom/Deskewing` | bool | `true` | `true` | Deskew LiDAR scans when timing/IMU or motion information is available. |
| `Odom/ResetCountdown` | int | `0` | `0` | generic RTAB-Map odometry setting: controls reset countdown. |
| `OdomF2M/MaxSize` | int | `2000` | `2000` | frame-to-map odometry setting: controls max size. |
| `OdomF2M/ScanMaxSize` | int | `2000` | `2000` | frame-to-map odometry setting: controls scan max size. |
| `OdomF2M/BundleAdjustment` | int | `1` | `1` | frame-to-map odometry setting: controls bundle adjustment. |
| `Odom/FillInfoData` | bool | `true` | `true` | generic RTAB-Map odometry setting: controls fill info data. |
| `Odom/FilteringStrategy` | int | `0` | `0` | generic RTAB-Map odometry setting: controls filtering strategy. |
| `Odom/GuessSmoothingDelay` | float | `0` | `0` | generic RTAB-Map odometry setting: controls guess smoothing delay. |
| `Odom/ImageBufferSize` | unsigned int | `1` | `1` | generic RTAB-Map odometry setting: controls image buffer size. |
| `Odom/KalmanMeasurementNoise` | float | `0.01` | `0.01` | generic RTAB-Map odometry setting: controls kalman measurement noise. |
| `Odom/KalmanProcessNoise` | float | `0.001` | `0.001` | generic RTAB-Map odometry setting: controls kalman process noise. |
| `Odom/ParticleLambdaR` | float | `100` | `100` | generic RTAB-Map odometry setting: controls particle lambda r. |
| `Odom/ParticleLambdaT` | float | `100` | `100` | generic RTAB-Map odometry setting: controls particle lambda t. |
| `Odom/ParticleNoiseR` | float | `0.002` | `0.002` | generic RTAB-Map odometry setting: controls particle noise r. |
| `Odom/ParticleNoiseT` | float | `0.002` | `0.002` | generic RTAB-Map odometry setting: controls particle noise t. |
| `Odom/ParticleSize` | unsigned int | `400` | `400` | generic RTAB-Map odometry setting: controls particle size. |
| `OdomF2M/BundleAdjustmentMaxFrames` | int | `10` | `10` | frame-to-map odometry setting: controls bundle adjustment max frames. |
| `OdomF2M/BundleAdjustmentMaxKeyFramesPerFeature` | int | `0` | `0` | frame-to-map odometry setting: controls bundle adjustment max key frames per feature. |
| `OdomF2M/BundleAdjustmentMinMotion` | float | `0.0` | `0.0` | frame-to-map odometry setting: controls bundle adjustment min motion. |
| `OdomF2M/BundleUpdateFeatureMapOnAllFrames` | bool | `false` | `false` | frame-to-map odometry setting: controls bundle update feature map on all frames. |
| `OdomF2M/FloorThreshold` | float | `0.0` | `0.0` | frame-to-map odometry setting: controls floor threshold. |
| `OdomF2M/InitDepthFactor` | float | `0.05` | `0.05` | frame-to-map odometry setting: controls init depth factor. |
| `OdomF2M/MaxNewFeatures` | int | `0` | `0` | frame-to-map odometry setting: controls max new features. |
| `OdomF2M/ScanRange` | float | `0` | `0` | frame-to-map odometry setting: controls scan range. |
| `OdomF2M/ScanSubtractAngle` | float | `45` | `45` | frame-to-map odometry setting: controls scan subtract angle. |
| `OdomF2M/ScanSubtractRadius` | float | `0.05` | `0.05` | frame-to-map odometry setting: controls scan subtract radius. |
| `OdomF2M/ValidDepthRatio` | float | `0.75` | `0.75` | frame-to-map odometry setting: controls valid depth ratio. |
| `OdomMono/InitMinFlow` | float | `100` | `100` | monocular odometry setting: controls init min flow. |
| `OdomMono/InitMinTranslation` | float | `0.1` | `0.1` | monocular odometry setting: controls init min translation. |
| `OdomMono/MaxVariance` | float | `0.01` | `0.01` | monocular odometry setting: controls max variance. |
| `OdomMono/MinTranslation` | float | `0.02` | `0.02` | monocular odometry setting: controls min translation. |

## 11 — DATABASE / STORAGE

SQLite and persistent storage controls.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `DbSqlite3/CacheSize` | unsigned int | `10000` | `10000` | SQLite page-cache size used by the RTAB-Map database. |
| `DbSqlite3/JournalMode` | int | `3` | `3` | SQLite journal mode. |
| `DbSqlite3/Synchronous` | int | `0` | `0` | SQLite durability/synchronous mode. |
| `DbSqlite3/InMemory` | bool | `false` | `false` | SQLite database setting: controls in memory. |
| `DbSqlite3/TempStore` | int | `2` | `2` | SQLite database setting: controls temp store. |
| `Db/TargetVersion` | string | `` | `` | database compatibility setting: controls target version. |

## 12 — STEREO DEPTH

Stereo correspondence and dense stereo backends.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Stereo/DenseStrategy` | int | `0` | `0` | stereo correspondence setting: controls dense strategy. |
| `Stereo/MinDisparity` | float | `0.5` | `0.5` | stereo correspondence setting: controls min disparity. |
| `Stereo/MaxDisparity` | float | `128.0` | `128.0` | stereo correspondence setting: controls max disparity. |
| `Stereo/OpticalFlow` | bool | `true` | `true` | stereo correspondence setting: controls optical flow. |
| `Stereo/MaxLevel` | int | `5` | `5` | stereo correspondence setting: controls max level. |
| `Stereo/Gpu` | bool | `false` | `false` | stereo correspondence setting: controls gpu. |
| `Stereo/Eps` | double | `0.01` | `0.01` | stereo correspondence setting: controls eps. |
| `Stereo/ErrorThreshold` | double | `50` | `50` | stereo correspondence setting: controls error threshold. |
| `Stereo/Iterations` | int | `30` | `30` | stereo correspondence setting: controls iterations. |
| `Stereo/MinEigThreshold` | double | `1e-4` | `1e-4` | stereo correspondence setting: controls min eig threshold. |
| `Stereo/SSD` | bool | `true` | `true` | stereo correspondence setting: controls ssd. |
| `Stereo/UseMinEigenVals` | bool | `true` | `true` | stereo correspondence setting: controls use min eigen vals. |
| `Stereo/WinHeight` | int | `3` | `3` | stereo correspondence setting: controls win height. |
| `Stereo/WinWidth` | int | `15` | `15` | stereo correspondence setting: controls win width. |
| `StereoBM/BlockSize` | int | `15` | `15` | OpenCV StereoBM setting: controls block size. |
| `StereoBM/Disp12MaxDiff` | int | `-1` | `-1` | OpenCV StereoBM setting: controls disp12 max diff. |
| `StereoBM/MinDisparity` | int | `0` | `0` | OpenCV StereoBM setting: controls min disparity. |
| `StereoBM/NumDisparities` | int | `128` | `128` | OpenCV StereoBM setting: controls num disparities. |
| `StereoBM/PreFilterCap` | int | `31` | `31` | OpenCV StereoBM setting: controls pre filter cap. |
| `StereoBM/PreFilterSize` | int | `9` | `9` | OpenCV StereoBM setting: controls pre filter size. |
| `StereoBM/SpeckleRange` | int | `4` | `4` | OpenCV StereoBM setting: controls speckle range. |
| `StereoBM/SpeckleWindowSize` | int | `100` | `100` | OpenCV StereoBM setting: controls speckle window size. |
| `StereoBM/TextureThreshold` | int | `10` | `10` | OpenCV StereoBM setting: controls texture threshold. |
| `StereoBM/UniquenessRatio` | int | `15` | `15` | OpenCV StereoBM setting: controls uniqueness ratio. |
| `StereoSGBM/BlockSize` | int | `15` | `15` | OpenCV StereoSGBM setting: controls block size. |
| `StereoSGBM/Disp12MaxDiff` | int | `1` | `1` | OpenCV StereoSGBM setting: controls disp12 max diff. |
| `StereoSGBM/MinDisparity` | int | `0` | `0` | OpenCV StereoSGBM setting: controls min disparity. |
| `StereoSGBM/Mode` | int | `0` | `0` | OpenCV StereoSGBM setting: controls mode. |
| `StereoSGBM/NumDisparities` | int | `128` | `128` | OpenCV StereoSGBM setting: controls num disparities. |
| `StereoSGBM/P1` | int | `2` | `2` | OpenCV StereoSGBM setting: controls p1. |
| `StereoSGBM/P2` | int | `5` | `5` | OpenCV StereoSGBM setting: controls p2. |
| `StereoSGBM/PreFilterCap` | int | `31` | `31` | OpenCV StereoSGBM setting: controls pre filter cap. |
| `StereoSGBM/SpeckleRange` | int | `4` | `4` | OpenCV StereoSGBM setting: controls speckle range. |
| `StereoSGBM/SpeckleWindowSize` | int | `100` | `100` | OpenCV StereoSGBM setting: controls speckle window size. |
| `StereoSGBM/UniquenessRatio` | int | `20` | `20` | OpenCV StereoSGBM setting: controls uniqueness ratio. |

## 13 — MARKERS / LANDMARKS / IMU FILTER

Fiducial landmarks and IMU orientation filtering.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `RGBD/MarkerDetection` | bool | `false` | `false` | metric RGB-D SLAM setting: controls marker detection. |
| `Marker/Strategy` | int | `0` | `0` | fiducial marker setting: controls strategy. |
| `Marker/Dictionary` | int | `0` | `0` | fiducial marker setting: controls dictionary. |
| `Marker/Length` | float | `0` | `0` | fiducial marker setting: controls length. |
| `Marker/MaxRange` | float | `0.0` | `0.0` | fiducial marker setting: controls max range. |
| `Marker/MinRange` | float | `0.0` | `0.0` | fiducial marker setting: controls min range. |
| `ImuFilter/MadgwickGain` | double | `0.1` | `0.1` | IMU orientation-filter setting: controls madgwick gain. |
| `ImuFilter/ComplementaryGainAcc` | double | `0.01` | `0.01` | IMU orientation-filter setting: controls complementary gain acc. |
| `ImuFilter/ComplementaryBiasAlpha` | double | `0.01` | `0.01` | IMU orientation-filter setting: controls complementary bias alpha. |
| `ImuFilter/ComplementaryDoAdpativeGain` | bool | `true` | `true` | IMU orientation-filter setting: controls complementary do adpative gain. |
| `ImuFilter/ComplementaryDoBiasEstimation` | bool | `true` | `true` | IMU orientation-filter setting: controls complementary do bias estimation. |
| `ImuFilter/MadgwickZeta` | double | `0.0` | `0.0` | IMU orientation-filter setting: controls madgwick zeta. |
| `Marker/Lengths` | string | `` | `` | fiducial marker setting: controls lengths. |
| `Marker/MaxDepthError` | float | `0.01` | `0.01` | fiducial marker setting: controls max depth error. |
| `Marker/Priors` | string | `` | `` | fiducial marker setting: controls priors. |
| `Marker/PriorsVarianceAngular` | float | `0.001` | `0.001` | fiducial marker setting: controls priors variance angular. |
| `Marker/PriorsVarianceLinear` | float | `0.001` | `0.001` | fiducial marker setting: controls priors variance linear. |
| `Marker/VarianceAngular` | float | `0.01` | `0.01` | fiducial marker setting: controls variance angular. |
| `Marker/VarianceLinear` | float | `0.001` | `0.001` | fiducial marker setting: controls variance linear. |
| `Marker/VarianceOrientationIgnored` | bool | `false` | `false` | fiducial marker setting: controls variance orientation ignored. |
| `MarkerAprilTag/Debug` | bool | `false` | `false` | AprilTag detector setting: controls debug. |
| `MarkerAprilTag/DecodeSharpening` | double | `0.25` | `0.25` | AprilTag detector setting: controls decode sharpening. |
| `MarkerAprilTag/NThreads` | int | `1` | `1` | AprilTag detector setting: controls nthreads. |
| `MarkerAprilTag/QuadDecimate` | float | `1.0` | `1.0` | AprilTag detector setting: controls quad decimate. |
| `MarkerAprilTag/QuadSigma` | float | `0.0` | `0.0` | AprilTag detector setting: controls quad sigma. |
| `MarkerAprilTag/RefineEdges` | bool | `true` | `true` | AprilTag detector setting: controls refine edges. |
| `MarkerOpenCV/CornerRefinementMethod` | int | `0` | `0` | OpenCV marker detector setting: controls corner refinement method. |

## 14 — PUBLISHING / DIAGNOSTICS / MISC

Statistics, logging, output and less frequently tuned generic controls.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `Rtabmap/PublishStats` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls publish stats. |
| `Rtabmap/PublishLastSignature` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls publish last signature. |
| `Rtabmap/PublishRAMUsage` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls publish ramusage. |
| `Rtabmap/StatisticLogged` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls statistic logged. |
| `Rtabmap/SaveWMState` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls save wmstate. |
| `Rtabmap/ComputeRMSE` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls compute rmse. |
| `Rtabmap/ImagesAlreadyRectified` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls images already rectified. |
| `Rtabmap/MaxRepublished` | unsigned int | `2` | `2` | RTAB-Map global runtime/loop-detection setting: controls max republished. |
| `Rtabmap/MaxRetrieved` | unsigned int | `2` | `2` | RTAB-Map global runtime/loop-detection setting: controls max retrieved. |
| `Rtabmap/PublishLikelihood` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls publish likelihood. |
| `Rtabmap/PublishPdf` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls publish pdf. |
| `Rtabmap/RectifyOnlyFeatures` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls rectify only features. |
| `Rtabmap/StartNewMapOnGoodSignature` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls start new map on good signature. |
| `Rtabmap/StartNewMapOnLoopClosure` | bool | `false` | `false` | RTAB-Map global runtime/loop-detection setting: controls start new map on loop closure. |
| `Rtabmap/StatisticLoggedHeaders` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls statistic logged headers. |
| `Rtabmap/StatisticLogsBufferedInRAM` | bool | `true` | `true` | RTAB-Map global runtime/loop-detection setting: controls statistic logs buffered in ram. |
| `Rtabmap/WorkingDirectory` | string | `` | `` | RTAB-Map global runtime/loop-detection setting: controls working directory. |

## 15 — ADVANCED ODOMETRY BACKENDS

Backend-specific parameters: Fovis, Viso2, ORB-SLAM, OpenVINS, MSCKF, LOAM, LIO-SAM, etc.

| Parameter | Type | Upstream default | File value | Purpose |
|---|---|---:|---:|---|
| `OdomCuVSLAM/MulticamMode` | int | `0` | `0` | cuVSLAM backend setting: controls multicam mode. |
| `OdomFovis/BucketHeight` | int | `80` | `80` | Fovis odometry backend setting: controls bucket height. |
| `OdomFovis/BucketWidth` | int | `80` | `80` | Fovis odometry backend setting: controls bucket width. |
| `OdomFovis/CliqueInlierThreshold` | double | `0.1` | `0.1` | Fovis odometry backend setting: controls clique inlier threshold. |
| `OdomFovis/FastThreshold` | int | `20` | `20` | Fovis odometry backend setting: controls fast threshold. |
| `OdomFovis/FastThresholdAdaptiveGain` | double | `0.005` | `0.005` | Fovis odometry backend setting: controls fast threshold adaptive gain. |
| `OdomFovis/FeatureSearchWindow` | int | `25` | `25` | Fovis odometry backend setting: controls feature search window. |
| `OdomFovis/FeatureWindowSize` | int | `9` | `9` | Fovis odometry backend setting: controls feature window size. |
| `OdomFovis/InlierMaxReprojectionError` | double | `1.5` | `1.5` | Fovis odometry backend setting: controls inlier max reprojection error. |
| `OdomFovis/MaxKeypointsPerBucket` | int | `25` | `25` | Fovis odometry backend setting: controls max keypoints per bucket. |
| `OdomFovis/MaxMeanReprojectionError` | double | `10.0` | `10.0` | Fovis odometry backend setting: controls max mean reprojection error. |
| `OdomFovis/MaxPyramidLevel` | int | `3` | `3` | Fovis odometry backend setting: controls max pyramid level. |
| `OdomFovis/MinFeaturesForEstimate` | int | `20` | `20` | Fovis odometry backend setting: controls min features for estimate. |
| `OdomFovis/MinPyramidLevel` | int | `0` | `0` | Fovis odometry backend setting: controls min pyramid level. |
| `OdomFovis/StereoMaxDisparity` | int | `128` | `128` | Fovis odometry backend setting: controls stereo max disparity. |
| `OdomFovis/StereoMaxDistEpipolarLine` | double | `1.5` | `1.5` | Fovis odometry backend setting: controls stereo max dist epipolar line. |
| `OdomFovis/StereoMaxRefinementDisplacement` | double | `1.0` | `1.0` | Fovis odometry backend setting: controls stereo max refinement displacement. |
| `OdomFovis/StereoRequireMutualMatch` | bool | `true` | `true` | Fovis odometry backend setting: controls stereo require mutual match. |
| `OdomFovis/TargetPixelsPerFeature` | int | `250` | `250` | Fovis odometry backend setting: controls target pixels per feature. |
| `OdomFovis/UpdateTargetFeaturesWithRefined` | bool | `false` | `false` | Fovis odometry backend setting: controls update target features with refined. |
| `OdomFovis/UseAdaptiveThreshold` | bool | `true` | `true` | Fovis odometry backend setting: controls use adaptive threshold. |
| `OdomFovis/UseBucketing` | bool | `true` | `true` | Fovis odometry backend setting: controls use bucketing. |
| `OdomFovis/UseHomographyInitialization` | bool | `true` | `true` | Fovis odometry backend setting: controls use homography initialization. |
| `OdomFovis/UseImageNormalization` | bool | `false` | `false` | Fovis odometry backend setting: controls use image normalization. |
| `OdomFovis/UseSubpixelRefinement` | bool | `true` | `true` | Fovis odometry backend setting: controls use subpixel refinement. |
| `OdomLIOSAM/AngVar` | float | `0.01` | `0.01` | LIO-SAM backend setting: controls ang var. |
| `OdomLIOSAM/ConfigPath` | string | `` | `` | LIO-SAM backend setting: controls config path. |
| `OdomLIOSAM/EdgeThreshold` | float | `1.0` | `1.0` | LIO-SAM backend setting: controls edge threshold. |
| `OdomLIOSAM/HorizonScan` | int | `1800` | `1800` | LIO-SAM backend setting: controls horizon scan. |
| `OdomLIOSAM/ImuAccBiasN` | float | `0.0002` | `0.0002` | LIO-SAM backend setting: controls imu acc bias n. |
| `OdomLIOSAM/ImuAccNoise` | float | `0.01` | `0.01` | LIO-SAM backend setting: controls imu acc noise. |
| `OdomLIOSAM/ImuGravity` | float | `9.80511` | `9.80511` | LIO-SAM backend setting: controls imu gravity. |
| `OdomLIOSAM/ImuGyrBiasN` | float | `0.00003` | `0.00003` | LIO-SAM backend setting: controls imu gyr bias n. |
| `OdomLIOSAM/ImuGyrNoise` | float | `0.001` | `0.001` | LIO-SAM backend setting: controls imu gyr noise. |
| `OdomLIOSAM/LinVar` | float | `0.01` | `0.01` | LIO-SAM backend setting: controls lin var. |
| `OdomLIOSAM/NScan` | int | `16` | `16` | LIO-SAM backend setting: controls nscan. |
| `OdomLIOSAM/Sensor` | int | `0` | `0` | LIO-SAM backend setting: controls sensor. |
| `OdomLIOSAM/SurfThreshold` | float | `0.1` | `0.1` | LIO-SAM backend setting: controls surf threshold. |
| `OdomLOAM/AngVar` | float | `0.01` | `0.01` | LOAM/FLOAM odometry setting: controls ang var. |
| `OdomLOAM/LinVar` | float | `0.01` | `0.01` | LOAM/FLOAM odometry setting: controls lin var. |
| `OdomLOAM/LocalMapping` | bool | `true` | `true` | LOAM/FLOAM odometry setting: controls local mapping. |
| `OdomLOAM/Resolution` | float | `0.2` | `0.2` | LOAM/FLOAM odometry setting: controls resolution. |
| `OdomLOAM/ScanPeriod` | float | `0.1` | `0.1` | LOAM/FLOAM odometry setting: controls scan period. |
| `OdomLOAM/Sensor` | int | `2` | `2` | LOAM/FLOAM odometry setting: controls sensor. |
| `OdomMSCKF/FastThreshold` | int | `10` | `10` | MSCKF-VIO backend setting: controls fast threshold. |
| `OdomMSCKF/GridCol` | int | `5` | `5` | MSCKF-VIO backend setting: controls grid col. |
| `OdomMSCKF/GridMaxFeatureNum` | int | `4` | `4` | MSCKF-VIO backend setting: controls grid max feature num. |
| `OdomMSCKF/GridMinFeatureNum` | int | `3` | `3` | MSCKF-VIO backend setting: controls grid min feature num. |
| `OdomMSCKF/GridRow` | int | `4` | `4` | MSCKF-VIO backend setting: controls grid row. |
| `OdomMSCKF/InitCovAccBias` | double | `0.01` | `0.01` | MSCKF-VIO backend setting: controls init cov acc bias. |
| `OdomMSCKF/InitCovExRot` | double | `0.00030462` | `0.00030462` | MSCKF-VIO backend setting: controls init cov ex rot. |
| `OdomMSCKF/InitCovExTrans` | double | `0.000025` | `0.000025` | MSCKF-VIO backend setting: controls init cov ex trans. |
| `OdomMSCKF/InitCovGyroBias` | double | `0.01` | `0.01` | MSCKF-VIO backend setting: controls init cov gyro bias. |
| `OdomMSCKF/InitCovVel` | double | `0.25` | `0.25` | MSCKF-VIO backend setting: controls init cov vel. |
| `OdomMSCKF/MaxCamStateSize` | int | `20` | `20` | MSCKF-VIO backend setting: controls max cam state size. |
| `OdomMSCKF/MaxIteration` | int | `30` | `30` | MSCKF-VIO backend setting: controls max iteration. |
| `OdomMSCKF/NoiseAcc` | double | `0.05` | `0.05` | MSCKF-VIO backend setting: controls noise acc. |
| `OdomMSCKF/NoiseAccBias` | double | `0.01` | `0.01` | MSCKF-VIO backend setting: controls noise acc bias. |
| `OdomMSCKF/NoiseFeature` | double | `0.035` | `0.035` | MSCKF-VIO backend setting: controls noise feature. |
| `OdomMSCKF/NoiseGyro` | double | `0.005` | `0.005` | MSCKF-VIO backend setting: controls noise gyro. |
| `OdomMSCKF/NoiseGyroBias` | double | `0.001` | `0.001` | MSCKF-VIO backend setting: controls noise gyro bias. |
| `OdomMSCKF/OptTranslationThreshold` | double | `0` | `0` | MSCKF-VIO backend setting: controls opt translation threshold. |
| `OdomMSCKF/PatchSize` | int | `15` | `15` | MSCKF-VIO backend setting: controls patch size. |
| `OdomMSCKF/PositionStdThreshold` | double | `8.0` | `8.0` | MSCKF-VIO backend setting: controls position std threshold. |
| `OdomMSCKF/PyramidLevels` | int | `3` | `3` | MSCKF-VIO backend setting: controls pyramid levels. |
| `OdomMSCKF/RansacThreshold` | double | `3` | `3` | MSCKF-VIO backend setting: controls ransac threshold. |
| `OdomMSCKF/RotationThreshold` | double | `0.2618` | `0.2618` | MSCKF-VIO backend setting: controls rotation threshold. |
| `OdomMSCKF/StereoThreshold` | double | `5` | `5` | MSCKF-VIO backend setting: controls stereo threshold. |
| `OdomMSCKF/TrackPrecision` | double | `0.01` | `0.01` | MSCKF-VIO backend setting: controls track precision. |
| `OdomMSCKF/TrackingRateThreshold` | double | `0.5` | `0.5` | MSCKF-VIO backend setting: controls tracking rate threshold. |
| `OdomMSCKF/TranslationThreshold` | double | `0.4` | `0.4` | MSCKF-VIO backend setting: controls translation threshold. |
| `OdomOKVIS/ConfigPath` | string | `` | `` | OKVIS backend setting: controls config path. |
| `OdomORBSLAM/AccNoise` | double | `0.1` | `0.1` | ORB-SLAM odometry backend setting: controls acc noise. |
| `OdomORBSLAM/AccWalk` | double | `0.0001` | `0.0001` | ORB-SLAM odometry backend setting: controls acc walk. |
| `OdomORBSLAM/Bf` | double | `0.076` | `0.076` | ORB-SLAM odometry backend setting: controls bf. |
| `OdomORBSLAM/Fps` | float | `0.0` | `0.0` | ORB-SLAM odometry backend setting: controls fps. |
| `OdomORBSLAM/GyroNoise` | double | `0.01` | `0.01` | ORB-SLAM odometry backend setting: controls gyro noise. |
| `OdomORBSLAM/GyroWalk` | double | `0.000001` | `0.000001` | ORB-SLAM odometry backend setting: controls gyro walk. |
| `OdomORBSLAM/Inertial` | bool | `false` | `false` | ORB-SLAM odometry backend setting: controls inertial. |
| `OdomORBSLAM/MapSize` | int | `3000` | `3000` | ORB-SLAM odometry backend setting: controls map size. |
| `OdomORBSLAM/MaxFeatures` | int | `1000` | `1000` | ORB-SLAM odometry backend setting: controls max features. |
| `OdomORBSLAM/SamplingRate` | double | `0` | `0` | ORB-SLAM odometry backend setting: controls sampling rate. |
| `OdomORBSLAM/ThDepth` | double | `40.0` | `40.0` | ORB-SLAM odometry backend setting: controls th depth. |
| `OdomORBSLAM/VocPath` | string | `` | `` | ORB-SLAM odometry backend setting: controls voc path. |
| `OdomOpen3D/MaxDepth` | float | `3.0` | `3.0` | Open3D odometry setting: controls max depth. |
| `OdomOpen3D/Method` | int | `0` | `0` | Open3D odometry setting: controls method. |
| `OdomOpenVINS/AccelerometerNoiseDensity` | double | `0.01` | `0.01` | OpenVINS backend setting: controls accelerometer noise density. |
| `OdomOpenVINS/AccelerometerRandomWalk` | double | `0.001` | `0.001` | OpenVINS backend setting: controls accelerometer random walk. |
| `OdomOpenVINS/CalibCamExtrinsics` | bool | `false` | `false` | OpenVINS backend setting: controls calib cam extrinsics. |
| `OdomOpenVINS/CalibCamIntrinsics` | bool | `false` | `false` | OpenVINS backend setting: controls calib cam intrinsics. |
| `OdomOpenVINS/CalibCamTimeoffset` | bool | `false` | `false` | OpenVINS backend setting: controls calib cam timeoffset. |
| `OdomOpenVINS/CalibIMUGSensitivity` | bool | `false` | `false` | OpenVINS backend setting: controls calib imugsensitivity. |
| `OdomOpenVINS/CalibIMUIntrinsics` | bool | `false` | `false` | OpenVINS backend setting: controls calib imuintrinsics. |
| `OdomOpenVINS/ConfigPath` | string | `` | `` | OpenVINS backend setting: controls config path. |
| `OdomOpenVINS/DtSLAMDelay` | double | `0.0` | `0.0` | OpenVINS backend setting: controls dt slamdelay. |
| `OdomOpenVINS/FeatRepMSCKF` | int | `0` | `0` | OpenVINS backend setting: controls feat rep msckf. |
| `OdomOpenVINS/FeatRepSLAM` | int | `4` | `4` | OpenVINS backend setting: controls feat rep slam. |
| `OdomOpenVINS/FiMaxBaseline` | double | `40` | `40` | OpenVINS backend setting: controls fi max baseline. |
| `OdomOpenVINS/FiMaxCondNumber` | double | `10000` | `10000` | OpenVINS backend setting: controls fi max cond number. |
| `OdomOpenVINS/FiMaxRuns` | int | `5` | `5` | OpenVINS backend setting: controls fi max runs. |
| `OdomOpenVINS/FiRefineFeatures` | bool | `true` | `true` | OpenVINS backend setting: controls fi refine features. |
| `OdomOpenVINS/FiTriangulate1d` | bool | `false` | `false` | OpenVINS backend setting: controls fi triangulate1d. |
| `OdomOpenVINS/GravityMag` | double | `9.81` | `9.81` | OpenVINS backend setting: controls gravity mag. |
| `OdomOpenVINS/GyroscopeNoiseDensity` | double | `0.001` | `0.001` | OpenVINS backend setting: controls gyroscope noise density. |
| `OdomOpenVINS/GyroscopeRandomWalk` | double | `0.0001` | `0.0001` | OpenVINS backend setting: controls gyroscope random walk. |
| `OdomOpenVINS/InitDynInflationBa` | double | `100.0` | `100.0` | OpenVINS backend setting: controls init dyn inflation ba. |
| `OdomOpenVINS/InitDynInflationBg` | double | `10.0` | `10.0` | OpenVINS backend setting: controls init dyn inflation bg. |
| `OdomOpenVINS/InitDynInflationOri` | double | `10.0` | `10.0` | OpenVINS backend setting: controls init dyn inflation ori. |
| `OdomOpenVINS/InitDynInflationVel` | double | `100.0` | `100.0` | OpenVINS backend setting: controls init dyn inflation vel. |
| `OdomOpenVINS/InitDynMLEMaxIter` | int | `50` | `50` | OpenVINS backend setting: controls init dyn mlemax iter. |
| `OdomOpenVINS/InitDynMLEMaxThreads` | int | `6` | `6` | OpenVINS backend setting: controls init dyn mlemax threads. |
| `OdomOpenVINS/InitDynMLEMaxTime` | double | `0.05` | `0.05` | OpenVINS backend setting: controls init dyn mlemax time. |
| `OdomOpenVINS/InitDynMLEOptCalib` | bool | `false` | `false` | OpenVINS backend setting: controls init dyn mleopt calib. |
| `OdomOpenVINS/InitDynMinDeg` | double | `10.0` | `10.0` | OpenVINS backend setting: controls init dyn min deg. |
| `OdomOpenVINS/InitDynMinRecCond` | double | `1e-15` | `1e-15` | OpenVINS backend setting: controls init dyn min rec cond. |
| `OdomOpenVINS/InitDynNumPose` | int | `6` | `6` | OpenVINS backend setting: controls init dyn num pose. |
| `OdomOpenVINS/InitDynUse` | bool | `false` | `false` | OpenVINS backend setting: controls init dyn use. |
| `OdomOpenVINS/InitIMUThresh` | double | `1.0` | `1.0` | OpenVINS backend setting: controls init imuthresh. |
| `OdomOpenVINS/InitMaxDisparity` | double | `10.0` | `10.0` | OpenVINS backend setting: controls init max disparity. |
| `OdomOpenVINS/InitMaxFeatures` | int | `50` | `50` | OpenVINS backend setting: controls init max features. |
| `OdomOpenVINS/InitWindowTime` | double | `2.0` | `2.0` | OpenVINS backend setting: controls init window time. |
| `OdomOpenVINS/Integration` | int | `1` | `1` | OpenVINS backend setting: controls integration. |
| `OdomOpenVINS/LeftMaskPath` | string | `` | `` | OpenVINS backend setting: controls left mask path. |
| `OdomOpenVINS/MaxClones` | int | `11` | `11` | OpenVINS backend setting: controls max clones. |
| `OdomOpenVINS/MaxMSCKFInUpdate` | int | `50` | `50` | OpenVINS backend setting: controls max msckfin update. |
| `OdomOpenVINS/MaxSLAM` | int | `50` | `50` | OpenVINS backend setting: controls max slam. |
| `OdomOpenVINS/MaxSLAMInUpdate` | int | `25` | `25` | OpenVINS backend setting: controls max slamin update. |
| `OdomOpenVINS/MinPxDist` | int | `15` | `15` | OpenVINS backend setting: controls min px dist. |
| `OdomOpenVINS/NumPts` | int | `200` | `200` | OpenVINS backend setting: controls num pts. |
| `OdomOpenVINS/RightMaskPath` | string | `` | `` | OpenVINS backend setting: controls right mask path. |
| `OdomOpenVINS/TryZUPT` | bool | `true` | `true` | OpenVINS backend setting: controls try zupt. |
| `OdomOpenVINS/UpMSCKFChi2Multiplier` | double | `1.0` | `1.0` | OpenVINS backend setting: controls up msckfchi2 multiplier. |
| `OdomOpenVINS/UpMSCKFSigmaPx` | double | `1.0` | `1.0` | OpenVINS backend setting: controls up msckfsigma px. |
| `OdomOpenVINS/UpSLAMChi2Multiplier` | double | `1.0` | `1.0` | OpenVINS backend setting: controls up slamchi2 multiplier. |
| `OdomOpenVINS/UpSLAMSigmaPx` | double | `1.0` | `1.0` | OpenVINS backend setting: controls up slamsigma px. |
| `OdomOpenVINS/UseFEJ` | bool | `true` | `true` | OpenVINS backend setting: controls use fej. |
| `OdomOpenVINS/UseKLT` | bool | `true` | `true` | OpenVINS backend setting: controls use klt. |
| `OdomOpenVINS/UseStereo` | bool | `true` | `true` | OpenVINS backend setting: controls use stereo. |
| `OdomOpenVINS/ZUPTChi2Multiplier` | double | `0.0` | `0.0` | OpenVINS backend setting: controls zuptchi2 multiplier. |
| `OdomOpenVINS/ZUPTMaxDisparity` | double | `0.5` | `0.5` | OpenVINS backend setting: controls zuptmax disparity. |
| `OdomOpenVINS/ZUPTMaxVelodicy` | double | `0.1` | `0.1` | OpenVINS backend setting: controls zuptmax velodicy. |
| `OdomOpenVINS/ZUPTNoiseMultiplier` | double | `10.0` | `10.0` | OpenVINS backend setting: controls zuptnoise multiplier. |
| `OdomOpenVINS/ZUPTOnlyAtBeginning` | bool | `false` | `false` | OpenVINS backend setting: controls zuptonly at beginning. |
| `OdomVINSFusion/ConfigPath` | string | `` | `` | VINS-Fusion backend setting: controls config path. |
| `OdomViso2/BucketHeight` | double | `50` | `50` | libviso2 odometry backend setting: controls bucket height. |
| `OdomViso2/BucketMaxFeatures` | int | `2` | `2` | libviso2 odometry backend setting: controls bucket max features. |
| `OdomViso2/BucketWidth` | double | `50` | `50` | libviso2 odometry backend setting: controls bucket width. |
| `OdomViso2/InlierThreshold` | double | `2.0` | `2.0` | libviso2 odometry backend setting: controls inlier threshold. |
| `OdomViso2/MatchBinsize` | int | `50` | `50` | libviso2 odometry backend setting: controls match binsize. |
| `OdomViso2/MatchDispTolerance` | int | `2` | `2` | libviso2 odometry backend setting: controls match disp tolerance. |
| `OdomViso2/MatchHalfResolution` | bool | `true` | `true` | libviso2 odometry backend setting: controls match half resolution. |
| `OdomViso2/MatchMultiStage` | bool | `true` | `true` | libviso2 odometry backend setting: controls match multi stage. |
| `OdomViso2/MatchNmsN` | int | `3` | `3` | libviso2 odometry backend setting: controls match nms n. |
| `OdomViso2/MatchNmsTau` | int | `50` | `50` | libviso2 odometry backend setting: controls match nms tau. |
| `OdomViso2/MatchOutlierDispTolerance` | int | `5` | `5` | libviso2 odometry backend setting: controls match outlier disp tolerance. |
| `OdomViso2/MatchOutlierFlowTolerance` | int | `5` | `5` | libviso2 odometry backend setting: controls match outlier flow tolerance. |
| `OdomViso2/MatchRadius` | int | `200` | `200` | libviso2 odometry backend setting: controls match radius. |
| `OdomViso2/MatchRefinement` | int | `1` | `1` | libviso2 odometry backend setting: controls match refinement. |
| `OdomViso2/RansacIters` | int | `200` | `200` | libviso2 odometry backend setting: controls ransac iters. |
| `OdomViso2/Reweighting` | bool | `true` | `true` | libviso2 odometry backend setting: controls reweighting. |

## Notes

- The file contains the complete set of **617 unique RTAB-Map core parameters** extracted from the current upstream `Parameters.h`, plus the commonly used ROS 2 wrapper/subscription/map-output parameters.
- Optional backends such as SURF, SuperPoint, ORB-SLAM, Fovis, libviso2, OpenVINS, MSCKF, LOAM/FLOAM, LIO-SAM, GTSAM, g2o and some ICP implementations are build-dependent.
- A parameter being listed does **not** guarantee that its optional backend is compiled into your local RTAB-Map build.
- Parameters marked `# [INDOOR OVERRIDE]` in the YAML differ from the upstream default.

## Runtime checks

```bash
ros2 param list /rtabmap
ros2 param get /rtabmap "Rtabmap/LoopThr"
rtabmap --params
```

## Topic remapping example

```python
remappings=[
    ('rgb/image', '/camera/color/image_raw'),
    ('rgb/camera_info', '/camera/color/camera_info'),
    ('depth/image', '/camera/aligned_depth_to_color/image_raw'),
    ('odom', '/odom'),
    ('scan', '/scan'),
]
```

## Upstream source files used as reference

- `rtabmap/corelib/include/rtabmap/core/Parameters.h`
- `rtabmap_ros/rtabmap_slam/src/CoreWrapper.cpp`
- `rtabmap_ros/rtabmap_sync/src/CommonDataSubscriber.cpp`
- `rtabmap_ros/rtabmap_util/src/MapsManager.cpp`