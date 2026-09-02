# RC Car Project

DKS-Basic ESP32 RC car: PS4 controller over Bluetooth Classic, ESC + steering
servo, custom motor mount, and a ROS 2 URDF/simulation bringup.

## Structure

- `Hardware/Electronics/` — wiring diagram, BOM, electrical schematics
- `Hardware/Mechanical/` — chassis, motor mount, ESP32 mount (CAD/STL)
- `Software/rc_car_firmware/` — ESP32 Arduino firmware (gamepad -> ESC/servo)
- `Software/rc_car_description/` — ROS 2 package: URDF, meshes, RViz/Gazebo launch

## Firmware

Open `Software/rc_car_firmware/rc_car_firmware.ino` in the Arduino IDE (or
arduino-cli) with ESP32 board support, `Bluepad32`, and `ESP32Servo`
installed. GPIO pinout is in `Hardware/Electronics/version_1/Wiring_Table.md`.

## ROS 2 package

```
colcon build --packages-select rc_car_description
ros2 launch rc_car_description display.launch.py
```

Meshes under `Software/rc_car_description/meshes/` are staged from the STLs
in `Hardware/Mechanical/`.
