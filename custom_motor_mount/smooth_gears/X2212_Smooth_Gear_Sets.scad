/*
  Matched low-friction gear sets for the SunnySky X2212 DKS-Basic conversion.

  This source creates a 14/42-tooth, 3:1 pair in two variants:
    - corrected involute spur gears
    - shallow herringbone gears with cancelling axial thrust

  The original Gear-2 hub and axle interface are retained verbatim. Only its
  toothed rim is replaced. Dimensions are in millimetres.

  Export example:
    openscad --export-format binstl \
      -o output/X2212_Smooth_Spur_Gear_1_14T.stl \
      -D 'part="spur_pinion"' X2212_Smooth_Gear_Sets.scad
*/

$fn = 120;

part = "spur_pinion";
// spur_pinion, spur_gear2, herringbone_pinion, herringbone_gear2,
// preview_spur, preview_herringbone

original_gear2 = "../../Single Pieces/Single Pieces/DKS-Basic_DukeDoks_Gear-2.stl";

// Matched tooth system.
module_size = 1.03;
pressure_angle = 20;
pinion_teeth = 14;
gear2_teeth = 42;
pinion_profile_shift = 0.25;
gear2_profile_shift = -0.25;
backlash_total = 0.25;
backlash_per_gear = backlash_total / 2;
root_clearance = 0.25;
tip_relief = 0.10;
root_fillet = 0.18;

// Interfaces and face widths.
pinion_bore_d = 8.10;
pinion_total_h = 9.0;
tooth_face_h = 8.0;
pinion_collar_d = 12.8;
gear2_total_h = 15.0006;

// The replacement Gear-2 rim overlaps the retained original core by 0.75 mm.
// All axle, screw and hub features lie well inside this protected diameter.
gear2_core_clip_d = 39.50;
gear2_rim_inner_d = 38.00;

// Herringbone geometry: 3.6 + 0.8 + 3.6 = 8.0 mm.
helix_angle = 12;
herringbone_half_h = 3.6;
herringbone_center_relief = 0.8;
helix_slices = 18; // One geometric twist slice per 0.2 mm print layer.

flank_steps = 12;
tip_arc_steps = 5;
eps = 0.04;

function pitch_r(teeth) = module_size * teeth / 2;
function base_r(teeth) = pitch_r(teeth) * cos(pressure_angle);
function addendum_r(teeth, shift) =
    pitch_r(teeth) + module_size * (1 + shift) - tip_relief;
function root_r(teeth, shift) =
    pitch_r(teeth) - module_size - root_clearance + module_size * shift;
function inv_angle(angle_deg) = tan(angle_deg) - angle_deg * PI / 180;
function tooth_thickness(teeth, shift) =
    PI * module_size / 2
    + 2 * shift * module_size * tan(pressure_angle)
    - backlash_per_gear;
function pitch_half_angle(teeth, shift) =
    tooth_thickness(teeth, shift) / (2 * pitch_r(teeth));
function flank_half_angle(teeth, shift, radius) =
    pitch_half_angle(teeth, shift)
    + inv_angle(pressure_angle)
    - inv_angle(acos(base_r(teeth) / radius));
function polar(radius, angle_rad) =
    [radius * cos(angle_rad * 180 / PI),
     radius * sin(angle_rad * 180 / PI)];
function lerp(a, b, amount) = a + (b - a) * amount;

function tooth_points(teeth, shift) =
    let(
        rb = base_r(teeth),
        rr = root_r(teeth, shift),
        ra = addendum_r(teeth, shift),
        base_half = flank_half_angle(teeth, shift, rb),
        tip_half = flank_half_angle(teeth, shift, ra)
    )
    concat(
        [polar(rr, -base_half)],
        [for (i = [0 : flank_steps])
            let(radius = lerp(rb, ra, i / flank_steps))
            polar(radius, -flank_half_angle(teeth, shift, radius))],
        [for (i = [1 : tip_arc_steps - 1])
            polar(ra, lerp(-tip_half, tip_half, i / tip_arc_steps))],
        [for (i = [flank_steps : -1 : 0])
            let(radius = lerp(rb, ra, i / flank_steps))
            polar(radius, flank_half_angle(teeth, shift, radius))],
        [polar(rr, base_half)]
    );

module raw_gear_profile_2d(teeth, shift) {
    union() {
        circle(r = root_r(teeth, shift), $fn = teeth * 12);

        for (tooth = [0 : teeth - 1])
            rotate(tooth * 360 / teeth)
                polygon(points = tooth_points(teeth, shift));
    }
}

module gear_profile_2d(teeth, shift) {
    // Closing the raw outline rounds only the sharp concave root transitions.
    offset(delta = -root_fillet)
        offset(r = root_fillet, $fn = 24)
            raw_gear_profile_2d(teeth, shift);
}

module gear_rim_2d(teeth, shift, inner_d) {
    difference() {
        gear_profile_2d(teeth, shift);
        circle(d = inner_d, $fn = 160);
    }
}

module retained_gear2_core() {
    intersection() {
        import(original_gear2, convexity = 12);
        translate([0, 0, -eps])
            cylinder(d = gear2_core_clip_d,
                     h = gear2_total_h + 2 * eps,
                     $fn = 180);
    }
}

module smooth_spur_pinion() {
    difference() {
        union() {
            linear_extrude(height = tooth_face_h, convexity = 12)
                gear_profile_2d(pinion_teeth, pinion_profile_shift);

            // Non-meshing motor-side collar preserves the 9 mm total length.
            translate([0, 0, tooth_face_h - eps])
                cylinder(d = pinion_collar_d,
                         h = pinion_total_h - tooth_face_h + eps);
        }

        translate([0, 0, -eps])
            cylinder(d = pinion_bore_d, h = pinion_total_h + 2 * eps);
    }
}

module smooth_spur_gear2() {
    union() {
        retained_gear2_core();

        linear_extrude(height = tooth_face_h, convexity = 12)
            gear_rim_2d(gear2_teeth, gear2_profile_shift,
                        gear2_rim_inner_d);
    }
}

function half_twist(teeth) =
    herringbone_half_h * tan(helix_angle) / pitch_r(teeth) * 180 / PI;

module helical_profile_half(teeth, shift, height, twist, inner_d = 0) {
    linear_extrude(height = height, twist = twist,
                   slices = helix_slices, convexity = 14)
        if (inner_d > 0)
            gear_rim_2d(teeth, shift, inner_d);
        else
            gear_profile_2d(teeth, shift);
}

module herringbone_profile(teeth, shift, hand = 1, inner_d = 0) {
    twist = hand * half_twist(teeth);
    upper_z = herringbone_half_h + herringbone_center_relief;

    // Lower helix approaches the center; upper helix returns to zero phase.
    helical_profile_half(teeth, shift, herringbone_half_h,
                         twist, inner_d);

    translate([0, 0, upper_z])
        linear_extrude(height = herringbone_half_h, twist = -twist,
                       slices = helix_slices, convexity = 14)
            rotate(twist)
                if (inner_d > 0)
                    gear_rim_2d(teeth, shift, inner_d);
                else
                    gear_profile_2d(teeth, shift);
}

module smooth_herringbone_pinion() {
    difference() {
        union() {
            herringbone_profile(pinion_teeth, pinion_profile_shift, 1);

            // Root-only bridge across the 0.8 mm center relief.
            translate([0, 0, herringbone_half_h - eps])
                cylinder(r = root_r(pinion_teeth, pinion_profile_shift),
                         h = herringbone_center_relief + 2 * eps);

            translate([0, 0, tooth_face_h - eps])
                cylinder(d = pinion_collar_d,
                         h = pinion_total_h - tooth_face_h + eps);
        }

        translate([0, 0, -eps])
            cylinder(d = pinion_bore_d, h = pinion_total_h + 2 * eps);
    }
}

module smooth_herringbone_gear2() {
    union() {
        retained_gear2_core();

        // Opposite hand to the pinion so the two external gears mesh.
        herringbone_profile(gear2_teeth, gear2_profile_shift, -1,
                            gear2_rim_inner_d);

        // Root-only annular bridge leaves the center relief tooth-free.
        translate([0, 0, herringbone_half_h - eps])
            difference() {
                cylinder(r = root_r(gear2_teeth, gear2_profile_shift),
                         h = herringbone_center_relief + 2 * eps);
                translate([0, 0, -eps])
                    cylinder(d = gear2_rim_inner_d,
                             h = herringbone_center_relief + 4 * eps);
            }
    }
}

module pair_preview(herringbone = false) {
    center_distance = 28.8766;

    color([0.95, 0.56, 0.12])
        if (herringbone)
            smooth_herringbone_pinion();
        else
            smooth_spur_pinion();

    color([0.20, 0.55, 0.85])
        translate([center_distance, 0, 0])
            rotate([0, 0, 180 / gear2_teeth])
                if (herringbone)
                    smooth_herringbone_gear2();
                else
                    smooth_spur_gear2();
}

if (part == "spur_pinion")
    smooth_spur_pinion();
else if (part == "spur_gear2")
    smooth_spur_gear2();
else if (part == "herringbone_pinion")
    smooth_herringbone_pinion();
else if (part == "herringbone_gear2")
    smooth_herringbone_gear2();
else if (part == "preview_spur")
    pair_preview(false);
else if (part == "preview_herringbone")
    pair_preview(true);
else
    assert(false, str("Unknown part selector: ", part));
