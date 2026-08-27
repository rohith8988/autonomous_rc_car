# Software

This directory is reserved for the control software. The approved Version 1
work contains documentation and circuitry only; it does not yet include
firmware.

Planned stages are:

1. ESP32 Bluetooth Classic connection to a PS4 controller.
2. Steering and bidirectional throttle output using the Version 1 GPIO map.
3. ROS 2 node integration for commands and telemetry.
4. A ROS 2 robot-description package containing the URDF and meshes.

The electrical interface that future firmware must implement is documented in
[`Hardware/Electronics/version_1`](../Hardware/Electronics/version_1/).
