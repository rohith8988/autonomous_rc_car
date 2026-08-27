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
// spur_pinion, spur_pinion_m3, spur_gear2,
// herringbone_pinion, herringbone_pinion_m3, herringbone_gear2,
// preview_spur, preview_herringbone

original_gear2 = "../../DKS_Basic_Chassis/STL/DKS-Basic_DukeDoks_Gear-2.stl";

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

// Balanced M3x8 flexure-clamp option. The 8 mm tooth face seats against the
// motor and a 6 mm collar clamps the M6 threaded output section. Two opposing
// socket-head screws keep the rotating pinion balanced; no nuts are needed.
m3_pinion_total_h = 14.0;
m3_clamp_start_z = tooth_face_h;
m3_clamp_h = m3_pinion_total_h - tooth_face_h;
m3_clamp_outer_d = 16.0;
m3_threaded_shaft_bore_d = 6.30;
m3_clearance_d = 3.40;
m3_thread_pilot_d = 2.80;
m3_socket_head_d = 5.80;
m3_axis_z = m3_clamp_start_z + m3_clamp_h / 2;
m3_axis_x = 4.80;
m3_head_seat_y = -3.40;
m3_thread_end_y = 4.60;
flexure_slot_w = 0.80;
flexure_slot_end_x = 6.10;

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

module spur_pinion_body() {
    union() {
        linear_extrude(height = tooth_face_h, convexity = 12)
            gear_profile_2d(pinion_teeth, pinion_profile_shift);

        // Non-meshing motor-side collar preserves the 9 mm total length.
        translate([0, 0, tooth_face_h - eps])
            cylinder(d = pinion_collar_d,
                     h = pinion_total_h - tooth_face_h + eps);
    }
}

module cylinder_along_y(diameter, y0, y1, x, z) {
    translate([x, (y0 + y1) / 2, z])
        rotate([90, 0, 0])
            cylinder(d = diameter, h = abs(y1 - y0), center = true, $fn = 48);
}

module one_m3_flexure_cut() {
    // Blind-ended radial slit through the clamp collar only. It opens into the
    // 6.30 mm thread-section bore and leaves an outer flexure bridge.
    hull()
        for (x = [m3_threaded_shaft_bore_d / 2 - 0.20,
                  flexure_slot_end_x])
            translate([x, 0, m3_clamp_start_z - eps])
                cylinder(d = flexure_slot_w,
                         h = m3_clamp_h + 2 * eps, $fn = 24);

    // Flush socket-head recess and clearance through the near clamp arm.
    cylinder_along_y(m3_socket_head_d, -9.0, m3_head_seat_y,
                     m3_axis_x, m3_axis_z);
    cylinder_along_y(m3_clearance_d, m3_head_seat_y - eps, 0.65,
                     m3_axis_x, m3_axis_z);

    // The M3x8 screw forms its own thread in this deliberately undersized hole.
    cylinder_along_y(m3_thread_pilot_d, 0.35, m3_thread_end_y,
                     m3_axis_x, m3_axis_z);
}

module m3_flexure_clamp_cuts() {
    // The tooth face locates on the 7.85 mm smooth boss.
    translate([0, 0, -eps])
        cylinder(d = pinion_bore_d,
                 h = m3_clamp_start_z + 2 * eps);

    // The smaller stepped bore surrounds and clamps the external M6 thread.
    translate([0, 0, m3_clamp_start_z - eps])
        cylinder(d = m3_threaded_shaft_bore_d,
                 h = m3_clamp_h + 2 * eps);

    // The second clamp is an exact 180-degree copy for rotational balance.
    for (angle = [0, 180])
        rotate([0, 0, angle])
            one_m3_flexure_cut();
}

module smooth_spur_pinion() {
    difference() {
        spur_pinion_body();

        translate([0, 0, -eps])
            cylinder(d = pinion_bore_d, h = pinion_total_h + 2 * eps);
    }
}

module smooth_spur_pinion_m3() {
    difference() {
        union() {
            linear_extrude(height = tooth_face_h, convexity = 12)
                gear_profile_2d(pinion_teeth, pinion_profile_shift);

            translate([0, 0, m3_clamp_start_z - eps])
                cylinder(d = m3_clamp_outer_d, h = m3_clamp_h + eps);
        }
        m3_flexure_clamp_cuts();
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

module herringbone_pinion_body() {
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
}

module smooth_herringbone_pinion() {
    difference() {
        herringbone_pinion_body();

        translate([0, 0, -eps])
            cylinder(d = pinion_bore_d, h = pinion_total_h + 2 * eps);
    }
}

module smooth_herringbone_pinion_m3() {
    difference() {
        union() {
            herringbone_profile(pinion_teeth, pinion_profile_shift, 1);

            // Root-only bridge across the herringbone center relief.
            translate([0, 0, herringbone_half_h - eps])
                cylinder(r = root_r(pinion_teeth, pinion_profile_shift),
                         h = herringbone_center_relief + 2 * eps);

            translate([0, 0, m3_clamp_start_z - eps])
                cylinder(d = m3_clamp_outer_d, h = m3_clamp_h + eps);
        }
        m3_flexure_clamp_cuts();
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
else if (part == "spur_pinion_m3")
    smooth_spur_pinion_m3();
else if (part == "spur_gear2")
    smooth_spur_gear2();
else if (part == "herringbone_pinion")
    smooth_herringbone_pinion();
else if (part == "herringbone_pinion_m3")
    smooth_herringbone_pinion_m3();
else if (part == "herringbone_gear2")
    smooth_herringbone_gear2();
else if (part == "preview_spur")
    pair_preview(false);
else if (part == "preview_herringbone")
    pair_preview(true);
else
    assert(false, str("Unknown part selector: ", part));
