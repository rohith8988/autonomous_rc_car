"""View the model in RViz with sliders for every joint. No simulator needed.

    ros2 launch rc_car_description display.launch.py

Then in RViz add a 'RobotModel' display (Description Topic: /robot_description)
and a 'TF' display, and set Fixed Frame to base_footprint.
"""
import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    pkg = get_package_share_directory("rc_car_description")
    urdf = os.path.join(pkg, "urdf", "rc_car.urdf")
    with open(urdf) as f:
        robot_description = f.read()

    return LaunchDescription([
        Node(
            package="robot_state_publisher",
            executable="robot_state_publisher",
            output="screen",
            parameters=[{"robot_description": robot_description}],
        ),
        Node(
            package="joint_state_publisher_gui",
            executable="joint_state_publisher_gui",
            output="screen",
        ),
        Node(
            package="rviz2",
            executable="rviz2",
            output="screen",
        ),
    ])
