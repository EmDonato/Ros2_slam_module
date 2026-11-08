"""Verify Jazzy SLAM Toolbox autostarts without sensors or map data mounts."""

import signal
import subprocess
import time

import rclpy
from lifecycle_msgs.msg import State
from lifecycle_msgs.srv import GetState


def main():
    process = subprocess.Popen([
        'ros2', 'launch', 'slam_toolbox_bringup',
        'slam.launch.py',
    ])
    rclpy.init()
    node = rclpy.create_node('slam_lifecycle_smoke')
    client = node.create_client(GetState, '/slam_toolbox/get_state')
    try:
        assert client.wait_for_service(timeout_sec=20), 'lifecycle service absent'
        deadline = time.monotonic() + 20
        active = False
        while time.monotonic() < deadline:
            assert process.poll() is None, 'launch exited'
            future = client.call_async(GetState.Request())
            rclpy.spin_until_future_complete(node, future, timeout_sec=2)
            if future.done() and future.result().current_state.id == State.PRIMARY_STATE_ACTIVE:
                active = True
                break
            time.sleep(0.1)
        assert active, 'SLAM Toolbox never reached active state'
        print('PASS: SLAM Toolbox configures and activates automatically')
    finally:
        process.send_signal(signal.SIGINT)
        try:
            process.wait(timeout=15)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
            raise
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
