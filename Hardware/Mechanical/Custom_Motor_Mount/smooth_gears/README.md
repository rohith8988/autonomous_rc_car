# Matched low-friction gear sets

These files provide two new matched 14/42-tooth gear pairs for the SunnySky
X2212 DKS-Basic conversion. They preserve the 3:1 ratio, Ø8.10 mm motor boss
fit, external M6 pinion nut, and original Gear-2 axle and screw interfaces.

The **spur pair** is the recommended starting point. It has the lowest drag and
is the most tolerant of FDM printing. The **herringbone pair** uses opposed 12°
helices for quieter, more gradual engagement without the axial thrust of a
single-helical gear.

Both pairs use a 1.03 mm module, 20° pressure angle, corrected tooth profiles,
0.25 mm total designed backlash, root clearance, and light tip relief. Never
mix a spur gear with a herringbone gear.

## Files

- `output/X2212_Smooth_Spur_Gear_1_14T.stl`
- `output/X2212_Smooth_Spur_Gear_1_14T_M3_Clamp.stl`
- `output/X2212_Smooth_Spur_Gear_2_42T.stl`
- `output/X2212_Smooth_Herringbone_Gear_1_14T.stl`
- `output/X2212_Smooth_Herringbone_Gear_1_14T_M3_Clamp.stl`
- `output/X2212_Smooth_Herringbone_Gear_2_42T.stl`
- `X2212_Smooth_Gear_Sets.scad` — editable parametric source

## Printing and setup

Print each gear flat at 0.2 mm layers with a 0.4 mm nozzle, at least six walls,
and 80–100% infill. Use elephant-foot compensation if available. PETG, ABS or
ASA is preferable for the final drivetrain; PLA is suitable for fit testing.

Install both gears from the same pair. Begin with the motor near the middle of
its adjustment slots. Turn the axle through a full revolution by hand and leave
a small perceptible amount of backlash. If necessary, move the motor only
0.1–0.2 mm farther from Gear-2 before tightening all four M3 screws.

Run the first powered test with the wheels unloaded and at very low throttle.

## M3 clamp pinions

If an M6 retaining nut is unavailable, use the matching `_M3_Clamp` pinion.
Its 8 mm tooth section fits the smooth motor boss and its 6 mm outer collar
clamps around the M6 threaded section. Each pinion uses **two M3x8 socket-head
screws** positioned opposite each other for balance. No M3 nuts are required.

1. Before fitting the motor, carefully drive each M3 screw into its 2.8 mm pilot
   hole to form the printed thread, then remove it.
2. Install the pinion with its tooth face toward the motor. Slide it on until
   the 8 mm tooth section seats against the rotating motor face and the clamp
   collar surrounds the M6 threaded section.
3. Reinstall both screws and tighten them alternately in quarter turns until the
   pinion cannot slip or slide by hand.
4. Stop as soon as the pinion is secure. Over-tightening can strip the printed
   thread or crack the flexure bridges.

The screw heads must sit completely inside their counterbores. Always install
both screws; running with only one would unbalance the pinion at motor speed.

## Export

Run from this directory:

```sh
openscad --export-format binstl -o output/X2212_Smooth_Spur_Gear_1_14T.stl -D 'part="spur_pinion"' X2212_Smooth_Gear_Sets.scad
openscad --export-format binstl -o output/X2212_Smooth_Spur_Gear_1_14T_M3_Clamp.stl -D 'part="spur_pinion_m3"' X2212_Smooth_Gear_Sets.scad
openscad --export-format binstl -o output/X2212_Smooth_Spur_Gear_2_42T.stl -D 'part="spur_gear2"' X2212_Smooth_Gear_Sets.scad
openscad --export-format binstl -o output/X2212_Smooth_Herringbone_Gear_1_14T.stl -D 'part="herringbone_pinion"' X2212_Smooth_Gear_Sets.scad
openscad --export-format binstl -o output/X2212_Smooth_Herringbone_Gear_1_14T_M3_Clamp.stl -D 'part="herringbone_pinion_m3"' X2212_Smooth_Gear_Sets.scad
openscad --export-format binstl -o output/X2212_Smooth_Herringbone_Gear_2_42T.stl -D 'part="herringbone_gear2"' X2212_Smooth_Gear_Sets.scad
```
