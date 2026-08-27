# DKS-Basic ESP32 RC Car

This repository contains the mechanical and electrical work for a DKS-Basic
3D-printed RC car converted to a SunnySky X2212-13 KV980 brushless motor and an
ESP32 control system.

## Project layout

- [`Software`](Software/) — reserved for the PS4-controller firmware, ROS 2
  node, and robot-description software. No firmware is included in Version 1.
- [`Hardware/Mechanical`](Hardware/Mechanical/) — original DKS-Basic chassis
  files, the custom X2212 motor mount, matched gears, and motor drawings.
- [`Hardware/Electronics`](Hardware/Electronics/) — versioned electrical
  diagrams, wiring tables, bills of materials, and commissioning instructions.

## Installed mechanical configuration

- DKS-Basic chassis using Front Frame A
- SunnySky X2212-13 KV980 CW sensorless brushless motor
- TowardPro MG90S micro steering servo
- Custom cylindrical X2212 rear motor mount
- 14-tooth pinion and 42-tooth axle gear, giving a 3:1 reduction
- M3-clamp pinion variants that do not require an M6 locknut

## Version 1 electrical configuration

Version 1 uses an original ESP32 with Bluetooth Classic, a PS4 controller, a
3S 2200 mAh LiPo, and a 50 A bidirectional sensorless brushless ESC with an
integrated 5 V/5 A UBEC. The ESC drives the motor while its UBEC powers the
ESP32 and steering servo.

See the complete [Version 1 electronics package](Hardware/Electronics/version_1/)
before connecting the battery.

## Safety

The 3S battery can deliver destructive fault current, and the converted motor
is much more powerful than the original drivetrain. Use the specified fuse and
DC-rated master switch, raise the wheels for commissioning, and establish a
neutral throttle signal before arming the ESC.
