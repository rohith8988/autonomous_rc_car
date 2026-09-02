"""Spawn the RC car into Gazebo (gz sim, Harmonic) and bridge it to ROS 2.

    ros2 launch rc_car_description gz.launch.py

Control runs through ros2_control (see config/controllers.yaml), not a
/cmd_vel plugin -- this car has ONE traction DOF (solid rear axle) and the gz
AckermannSteering plugin requires two. Activate and drive:

    ros2 control load_controller --set-state active joint_state_broadcaster
    ros2 control load_controller --set-state active traction_controller
    ros2 control load_controller --set-state active steering_controller

    # axle rate [rad/s]                    <- ESP32 GPIO25 throttle PWM
    ros2 topic pub /traction_controller/commands \
        std_msgs/msg/Float64MultiArray "{data: [18.0]}" -r 20
    # [left, right] kingpin angles [rad]   <- ESP32 GPIO26 steering PWM
    ros2 topic pub /steering_controller/commands \
        std_msgs/msg/Float64MultiArray "{data: [0.386, 0.321]}" -r 20

Turning /cmd_vel into those two commands is a vehicle node's job -- which is
exactly what the ESP32 firmware does on the real car.

Topics: /joint_states, /odom_ground_truth, /tf, /clock  (bridged from gz).
"""
import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription, DeclareLaunchArgument
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    pkg = get_package_share_directory("rc_car_description")
    ros_gz_sim = get_package_share_directory("ros_gz_sim")
    urdf = os.path.join(pkg, "urdf", "rc_car.urdf")
    with open(urdf) as f:
        robot_description = f.read()

    world = LaunchConfiguration("world")

    gz = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(ros_gz_sim, "launch", "gz_sim.launch.py")),
        launch_arguments={"gz_args": ["-r -v3 ", world]}.items(),
    )

    rsp = Node(
        package="robot_state_publisher",
        executable="robot_state_publisher",
        output="screen",
        parameters=[{"robot_description": robot_description,
                     "use_sim_time": True}],
    )

    spawn = Node(
        package="ros_gz_sim",
        executable="create",
        output="screen",
        arguments=["-name", "rc_car", "-topic", "robot_description",
                   "-z", "0.05"],
    )

    bridge = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        output="screen",
        arguments=[
            "/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock",
            "/odom_ground_truth@nav_msgs/msg/Odometry[gz.msgs.Odometry",
            "/joint_states@sensor_msgs/msg/JointState@gz.msgs.Model",
            "/tf@tf2_msgs/msg/TFMessage@gz.msgs.Pose_V",
        ],
        parameters=[{"use_sim_time": True}],
    )

    return LaunchDescription([
        DeclareLaunchArgument("world", default_value="empty.sdf"),
        gz, rsp, spawn, bridge,
    ])
