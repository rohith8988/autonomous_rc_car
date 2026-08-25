# SunnySky X2212 mount for the DKS-Basic chassis

This directory contains a clean cylindrical one-piece replacement for
`Rear-Frame_R_A` and a matching version of `Gear-1_A` for the SunnySky X2212-13
KV980 CW outrunner. The original `Gear-2` is unchanged.

## Files

- `X2212_Rear_Frame_A_OnePiece.scad` — editable parametric source for every part.
- `output/X2212_Rear_Frame_A_OnePiece.stl` — clean cylindrical replacement rear
  frame.
- `output/X2212_Gear_1_A.stl` — earlier 9 mm-wide 14-tooth pinion with a smooth
  8.10 mm boss bore.
- `output/X2212_Motor_Pattern_Test.stl` — quick test of the motor mounting holes
  and M3x8 screw engagement.
- `output/X2212_Boss_Fit_Gauge.stl` — 8.00, 8.10 and 8.20 mm bore gauges. The
  raised digits 0, 1 and 2 identify the three nominal bore sizes.

Optional matched low-friction spur and herringbone gear pairs, including their
own parametric source and instructions, are in [`smooth_gears`](smooth_gears).

## Design basis

- Motor rotor: 27.5 mm diameter in a 31.8 mm cage opening.
- Motor body: 28 mm long.
- Motor rear holes: one opposite pair spaced 16 mm and the other spaced 19 mm,
  on diagonal axes 45 degrees from the wire centreline; M3 x 0.5, 2.8 mm deep.
- Rear plate: 5.4 mm thick. M3x8 screws engage 2.6 mm of the motor threads.
- Motor shell: continuous 28 mm-long cylinder, 37.0 mm outside diameter and
  31.8 mm inside diameter. The clean 2.6 mm wall replaces all exposed beams,
  gussets and hoops while distributing load around the full circumference.
  The rear wire opening remains unchanged.
- Output: 7.85 mm smooth locating boss followed by a 6.5 mm M6 x 1 thread.
- Pinion: original 14-tooth profile, 9 mm face width and 8.10 mm smooth bore.
  A separate standard M6 x 1 nut retains it on the motor's external thread.
  Do not substitute an M6 screw.
- Gear pair: the original 14-tooth pinion and 42-tooth axle gear are preserved.
  The nominal centre distance is 28.9 mm.
- Gear adjustment: the four correctly paired motor holes are 5.0 mm slots,
  allowing the motor to
  move 0.8 mm toward or away from `Gear-2`. Minimum bell clearance remains about
  1.35 mm at either adjustment limit.

The output-boss dimensions are based on the supplied motor drawing. The 7.5 mm
smooth-boss length is inferred from the 42 mm overall length, 28 mm motor body
and 6.5 mm threaded section. Verify the boss fit with the included gauge before
running the drivetrain.

## Test sequence

1. Print `X2212_Motor_Pattern_Test.stl` in PLA.
2. Confirm that all four M3x8 socket-head screws enter freely through the slots
   and tighten without bottoming out. Do not force a screw into the shallow
   motor threads.
3. Print `X2212_Boss_Fit_Gauge.stl`. Test 8.00, 8.10 and 8.20 mm bores and use
   the smallest one that slides fully over the 7.85 mm smooth boss without force.
4. If a bore other than 8.10 mm fits best, change `pinion_bore_d` in the SCAD
   source and re-export the pinion.
5. Print and dry-assemble the rear frame and pinion. Rotate the axle by hand to
   verify free bell rotation and smooth gear mesh before powering the motor.

## Suggested printing setup

For the first PLA fit test:

- 0.4 mm nozzle
- 0.2 mm layers
- 4 walls
- 35–45% gyroid infill
- Supports beneath the elevated rear motor plate

For the final PETG mount, use at least 5 walls and 45–60% gyroid infill. Orient
the large original-frame face on the build plate exactly as exported. Use
normal or tree supports under the elevated rear plate; keep support material
out of the motor-clearance bore and M3 holes where possible.

Print the pinion with either flat gear face on the build plate. Use at least 6
walls and 80–100% infill. Keep supports out of the boss bore.

## Assembly

1. Insert the motor from the gear side through the 31.8 mm cage opening.
2. Point the three motor wires through the slot in the rear plate.
3. Fasten the stationary motor base using four M3x8 socket-head screws. Do not
   add washers under these four heads; washers would reduce thread engagement.
4. Slide the pinion over the 7.85 mm smooth boss with its teeth aligned to
   `Gear-2`.
5. Install a standard M6 x 1 nut on the exposed motor thread and tighten it
   snugly against the pinion. Do not apply normal steel-fastener torque to the
   printed gear. Use a small amount of medium-strength threadlocker if the
   drivetrain will run in both directions.
6. Before fully tightening the four motor screws, slide the motor along its slots
   until the gears rotate freely with a small perceptible amount of backlash.
   Do not force the teeth tightly together.
7. Check bell clearance and gear motion by hand. Perform the first powered test
   with the wheels unloaded and at very low throttle.

The pinion and 42-tooth gear are not screwed together. Their teeth mesh
externally: motor -> 14-tooth pinion -> 42-tooth `Gear-2` -> rear axle. This
preserves the original 3:1 reduction.

The motor is substantially more powerful than the brushed motor for which this
printed drivetrain was designed. Stop immediately if the pinion slips, the nut
loosens, the gears bind, or the printed frame begins to soften.

## Export commands

Run these commands from this directory:

```sh
mkdir -p output
openscad --export-format binstl -o output/X2212_Rear_Frame_A_OnePiece.stl -D 'part="mount"' X2212_Rear_Frame_A_OnePiece.scad
openscad --export-format binstl -o output/X2212_Gear_1_A.stl -D 'part="pinion"' X2212_Rear_Frame_A_OnePiece.scad
openscad --export-format binstl -o output/X2212_Motor_Pattern_Test.stl -D 'part="motor_pattern_test"' X2212_Rear_Frame_A_OnePiece.scad
openscad --export-format binstl -o output/X2212_Boss_Fit_Gauge.stl -D 'part="boss_fit_gauge"' X2212_Rear_Frame_A_OnePiece.scad
```
