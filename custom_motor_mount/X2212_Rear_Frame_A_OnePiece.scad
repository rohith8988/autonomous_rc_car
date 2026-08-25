/*
  DKS-Basic / SunnySky X2212-13 KV980 CW conversion

  Clean cylindrical one-piece replacement for Rear-Frame_R_A plus a matching
  Gear-1_A pinion.
  Dimensions are in millimetres.

  The motor drawing supplied with the project specifies:
    - 27.5 mm rotor diameter
    - 28 mm motor body length
    - one opposite M3 pair spaced 16 mm and the other spaced 19 mm
    - both opposite-pair axes are 45 degrees from the wire centreline
    - four M3 x 0.5 holes, 2.8 mm deep
    - 7.85 mm output boss
    - 6.5 mm long M6 x 1 output thread

  Select an export with, for example:
    openscad -o output/X2212_Rear_Frame_A_OnePiece.stl \
      -D 'part="mount"' X2212_Rear_Frame_A_OnePiece.scad
*/

$fn = 96;

part = "mount"; // mount, pinion, motor_pattern_test, boss_fit_gauge, preview

original_frame = "../Single Pieces/Single Pieces/DKS-Basic_DukeDoks_Rear-Frame_R_A.stl";
original_pinion = "../Single Pieces/Single Pieces/DKS-Basic_DukeDoks_Gear-1_A.stl";

// Coordinates reverse-engineered from the original Rear-Frame_R_A STL.
// The 14/42 tooth pair has an approximately 28.9 mm pitch-centre distance.
// X follows the original slot centres; Y sets the nominal pitch distance to
// the rear axle centre at approximately [-29, 138].
motor_center = [-39.5, 111.1];
frame_bottom_z = 15.0;
frame_top_z = 22.0;

// Motor and fit parameters.
motor_rotor_d = 27.5;
motor_body_length = 28.0;
motor_clearance_d = 31.8; // Allows bell clearance throughout gear adjustment.
cage_outer_d = 37.0;
rear_plate_t = 5.4;       // M3x8 gives 2.6 mm engagement in a 2.8 mm thread.

// Rear mounting pattern. The motor wires point toward -Y. The drawing gives
// diametric spacing between opposite holes, not the sides of a rectangle:
//   - 16 mm pair: top-left to bottom-right (135 / 315 degrees)
//   - 19 mm pair: top-right to bottom-left (45 / 225 degrees)
mount_pair_16_d = 16.0;
mount_pair_19_d = 19.0;
m3_clearance_d = 3.4;
gear_adjustment = 0.8;    // Motor travel in either direction, in millimetres.
gear_adjustment_angle = atan2(138.0 - motor_center[1],
                              -29.0 - motor_center[0]);

// Output and pinion parameters.
output_boss_d = 7.85;
pinion_bore_d = 8.10;     // Tight FDM starting fit; verify with the fit gauge.
pinion_thickness = 9.0;   // Leaves 5 mm of M6 thread for the retaining nut.
pinion_core_d = 12.8;     // Fills the two obsolete radial clamp holes.

eps = 0.05;
motor_front_z = frame_bottom_z;
rear_mount_face_z = motor_front_z + motor_body_length;

module at_motor_center(z = 0) {
    translate([motor_center[0], motor_center[1], z]) children();
}

module annulus(outer_d, inner_d, height) {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, -eps]) cylinder(d = inner_d, h = height + 2 * eps);
    }
}

module adjustment_slot(height, hole_d = m3_clearance_d) {
    hull()
        for (travel = [-gear_adjustment, gear_adjustment])
            translate([travel, 0, -eps])
                cylinder(d = hole_d, h = height + 2 * eps);
}

module motor_bolt_pattern(height, hole_d = m3_clearance_d) {
    pair_16_r = mount_pair_16_d / 2;
    pair_19_r = mount_pair_19_d / 2;

    for (a = [135, 315])
        translate([pair_16_r * cos(a), pair_16_r * sin(a), 0])
            rotate([0, 0, gear_adjustment_angle])
                adjustment_slot(height, hole_d);

    for (a = [45, 225])
        translate([pair_19_r * cos(a), pair_19_r * sin(a), 0])
            rotate([0, 0, gear_adjustment_angle])
                adjustment_slot(height, hole_d);
}

module rear_motor_plate() {
    difference() {
        cylinder(d = cage_outer_d, h = rear_plate_t);

        // Rear bearing/shaft ventilation.
        translate([0, 0, -eps]) cylinder(d = 10.0, h = rear_plate_t + 2 * eps);

        // Match the four larger ventilation openings shown on the motor drawing.
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a])
                translate([10.5, 0, -eps])
                    cylinder(d = 5.5, h = rear_plate_t + 2 * eps);

        motor_bolt_pattern(rear_plate_t);

        // Radial wire exit. This does not intersect the lower mounting holes.
        translate([-4.75, -cage_outer_d / 2 - eps, -eps])
            cube([9.5, 10.5, rear_plate_t + 2 * eps]);
    }
}

module clean_motor_tube() {
    // A continuous 2.6 mm wall is cleaner and distributes motor loads around
    // the entire circumference without exposed ribs, hoops or gussets.
    at_motor_center(motor_front_z)
        annulus(cage_outer_d, motor_clearance_d, motor_body_length);
}

module one_piece_mount_raw() {
    difference() {
        union() {
            import(original_frame, convexity = 10);

            clean_motor_tube();

            at_motor_center(rear_mount_face_z)
                rear_motor_plate();
        }

        // Continuous clearance for the rotating outrunner bell. The cut stops at
        // the inner face of the stationary rear motor plate.
        at_motor_center(motor_front_z - eps)
            cylinder(d = motor_clearance_d,
                     h = motor_body_length + 2 * eps);
    }
}

module printable_mount() {
    // Put the original frame's lowest face on Z=0 for direct slicing.
    translate([0, 0, -frame_bottom_z]) one_piece_mount_raw();
}

module x2212_pinion() {
    difference() {
        intersection() {
            union() {
                // Preserve the exact original tooth profile and tooth count.
                import(original_pinion, convexity = 10);

                // Replace the original split-clamp core with a continuous hub.
                cylinder(d = pinion_core_d, h = 10.0);
            }

            translate([-20, -20, 0])
                cube([40, 40, pinion_thickness]);
        }

        translate([0, 0, -eps])
            cylinder(d = pinion_bore_d, h = pinion_thickness + 2 * eps);
    }
}

module motor_pattern_test() {
    difference() {
        cylinder(d = cage_outer_d, h = rear_plate_t);
        translate([0, 0, -eps]) cylinder(d = 10.0, h = rear_plate_t + 2 * eps);
        motor_bolt_pattern(rear_plate_t);
        translate([-4.75, -cage_outer_d / 2 - eps, -eps])
            cube([9.5, 10.5, rear_plate_t + 2 * eps]);
    }
}

module boss_fit_gauge() {
    test_bores = [8.00, 8.10, 8.20];
    test_outer_d = 13.0;
    spacing = 17.0;
    gauge_h = 4.0;

    union() {
        for (i = [0 : len(test_bores) - 1]) {
            translate([i * spacing, 0, 0])
                difference() {
                    cylinder(d = test_outer_d, h = gauge_h);
                    translate([0, 0, -eps])
                        cylinder(d = test_bores[i], h = gauge_h + 2 * eps);
                }

            // Attached label tab. Raised last digit:
            // 0 = 8.00, 1 = 8.10, 2 = 8.20.
            translate([i * spacing - 3.0, -9.0, 0])
                cube([6.0, 3.5, 1.0]);
            translate([i * spacing, -7.25, 1.0])
                linear_extrude(height = 0.6)
                    text(str(i), size = 4, halign = "center", valign = "center");
        }

        // Break-away links keep the three gauges together during printing.
        for (i = [0 : len(test_bores) - 2])
            translate([i * spacing + test_outer_d / 2 - 0.5, -1.0, 0])
                cube([spacing - test_outer_d + 1.0, 2.0, 1.0]);
    }
}

module motor_mockup() {
    color([0.18, 0.18, 0.2, 0.65])
        at_motor_center(motor_front_z)
            cylinder(d = motor_rotor_d, h = motor_body_length);

    color([0.65, 0.65, 0.68, 0.9])
        at_motor_center(motor_front_z - 14.0)
            cylinder(d = output_boss_d, h = 14.0);
}

module assembly_preview() {
    color([0.25, 0.55, 0.8, 1.0]) one_piece_mount_raw();
    motor_mockup();

    color([0.95, 0.58, 0.12, 1.0])
        translate([motor_center[0], motor_center[1],
                   motor_front_z - pinion_thickness])
            x2212_pinion();
}

if (part == "mount")
    printable_mount();
else if (part == "pinion")
    x2212_pinion();
else if (part == "motor_pattern_test")
    motor_pattern_test();
else if (part == "boss_fit_gauge")
    boss_fit_gauge();
else if (part == "preview")
    assembly_preview();
else
    assert(false, str("Unknown part selector: ", part));
