# SunnySky X2212 mount for the DKS-Basic chassis

This directory contains a clean cylindrical one-piece replacement for
`Rear-Frame_R_A` and a captive-locknut version of `Gear-1_A` for the SunnySky
X2212-13 KV980 CW outrunner. The original `Gear-2` is unchanged.

## Files

- `X2212_Rear_Frame_A_OnePiece.scad` — editable parametric source for every part.
- `output/X2212_Rear_Frame_A_OnePiece.stl` — clean cylindrical replacement rear
  frame.
- `output/X2212_Gear_1_A.stl` — 14-tooth pinion with an 8.10 mm boss bore,
  captive M6 locknut pocket and external 14 mm wrench flats.
- `output/X2212_Motor_Pattern_Test.stl` — quick test of the motor mounting holes
  and M3x8 screw engagement.
- `output/X2212_Boss_Fit_Gauge.stl` — 8.00, 8.10 and 8.20 mm bore gauges. The
  raised digits 0, 1 and 2 identify the three nominal bore sizes.
- `output/X2212_M6_Nut_Fit_Gauge.stl` — 10.25, 10.40 and 10.55 mm hex-pocket
  gauges. The labels 25, 40 and 55 identify the decimal part of each size.

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
- Pinion: original 14-tooth profile with an 8 mm toothed face and 14 mm total
  length. Its 8.10 mm bore centers on the smooth output boss.
- Pinion drive: a 10.40 mm-across-flats pocket rotationally captures a standard
  10 mm-across-flats M6 locknut. Torque is transferred by the six nut flats;
  it no longer depends on friction between the smooth boss and the printed
  bore.
- Pinion retention: use an M6 x 1 prevailing-torque locknut no more than 6.0 mm
  high. A DIN 985 nylon-insert locknut is the easiest option. Do not substitute
  an M6 screw.
- Gear pair: the original 14-tooth pinion and 42-tooth axle gear are preserved.
  The nominal centre distance is 28.9 mm.
- Gear adjustment: the four correctly paired motor holes are 5.0 mm slots,
  allowing the motor to
  move 0.8 mm toward or away from `Gear-2`. Minimum bell clearance remains about
  1.35 mm at either adjustment limit.

The output-boss dimensions are based on the supplied motor drawing. The 7.5 mm
smooth-boss length is inferred from the 42 mm overall length, 28 mm motor body
and 6.5 mm threaded section. Verify the boss and nut fits with the included
gauges before running the drivetrain.

## Test sequence

1. Print `X2212_Motor_Pattern_Test.stl` in PLA.
2. Confirm that all four M3x8 socket-head screws enter freely through the slots
   and tighten without bottoming out. Do not force a screw into the shallow
   motor threads.
3. Print `X2212_Boss_Fit_Gauge.stl`. Test 8.00, 8.10 and 8.20 mm bores and use
   the smallest one that slides fully over the 7.85 mm smooth boss without force.
4. If a bore other than 8.10 mm fits best, change `pinion_bore_d` in the SCAD
   source and re-export the pinion.
5. After buying the M6 locknut, print `X2212_M6_Nut_Fit_Gauge.stl`. Use the
   smallest pocket into which the nut can be pressed fully without splitting
   the gauge. If the 40 pocket is not best, change `m6_nut_af` to 10.25 or
   10.55 mm and re-export the pinion.
6. Print and dry-assemble the rear frame and pinion. Rotate the axle by hand to
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

Print the pinion with the open hex pocket on the build plate. Use at least 6
walls and 80–100% infill. Keep supports out of the nut pocket and boss bore.

## Assembly

1. Insert the motor from the gear side through the 30.5 mm cage opening.
2. Point the three motor wires through the slot in the rear plate.
3. Fasten the stationary motor base using four M3x8 socket-head screws. Do not
   add washers under these four heads; washers would reduce thread engagement.
4. Press the M6 locknut into the pinion's open hex pocket. For a nylon-insert
   nut, the nylon collar must face outward, toward the open end and away from
   the gear teeth. The nut must sit completely inside the pocket.
5. Slide the pinion's 8.10 mm sleeve over the 7.85 mm smooth boss. Hold the motor
   bell and turn the complete pinion to start the captured nut on the M6 thread.
   For the standard right-hand thread, tighten clockwise when viewed from the
   open nut-pocket end. If it does not start easily by hand, stop and verify the
   thread direction; never force it.
6. Use a 14 mm open-ended wrench on the pinion's external flats for the final
   snug tightening. Do not apply normal steel-fastener torque to the printed
   pinion. Confirm that the nut reaches its locking section and that the hex hub
   remains outside the toothed face of `Gear-2`.
7. Before fully tightening the four motor screws, slide the motor along its slots
   until the gears rotate freely with a small perceptible amount of backlash.
   Do not force the teeth tightly together.
8. Check bell clearance and gear motion by hand. Perform the first powered test
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
openscad --export-format binstl -o output/X2212_M6_Nut_Fit_Gauge.stl -D 'part="m6_nut_fit_gauge"' X2212_Rear_Frame_A_OnePiece.scad
```
