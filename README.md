# SunnySky X2212 DKS-Basic Motor Conversion

This project adapts the DKS-Basic RC chassis, using Frame A and the smaller
steering servo, to a SunnySky X2212-13 KV980 CW brushless motor.

The custom rear frame uses a clean cylindrical motor housing with the motor's
16 mm and 19 mm diagonal M3 mounting pattern. It is designed for M3x8
socket-head screws. A matching 14-tooth pinion preserves the original 3:1 gear
reduction with the existing 42-tooth `Gear-2`.

The pinion centers on the motor's 7.85 mm output boss and is retained by a
separate M6x1 nut on the threaded end of the motor output.

## Printable files

The finished STL files are in [`custom_motor_mount/output`](custom_motor_mount/output):

- `X2212_Rear_Frame_A_OnePiece.stl` — rear frame and cylindrical motor mount
- `X2212_Gear_1_A.stl` — earlier 9 mm-wide, smooth-bore 14-tooth pinion
- `X2212_Motor_Pattern_Test.stl` — mounting-hole test plate
- `X2212_Boss_Fit_Gauge.stl` — motor-boss clearance gauge

The editable OpenSCAD source and detailed printing and assembly instructions
are in [`custom_motor_mount`](custom_motor_mount).

Optional matched low-friction spur and herringbone gear sets are in
[`custom_motor_mount/smooth_gears`](custom_motor_mount/smooth_gears). Reprint
both gears and use them only as matched pairs.

Print the small test pieces before the final parts. Test the completed
drivetrain by hand, then perform the first powered test at low throttle with
the wheels off the ground.
