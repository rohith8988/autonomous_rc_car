// ESP32-WROOM-32 38-pin devkit mount for the DKS-Basic Body_L side panel.
//
// The board hangs horizontally, component side up, held only by a groove along
// each long edge. No floor and no lid: the whole underside is open air, so every
// header pin stays reachable and dupont ends hang free. The board slides in from
// the +y end, which is also the USB end.
//
// Local frame:
//   x = inward from the panel inner face  (x 0   = body X 59)
//   y = along the panel, 0 at mount centre (y 0   = body Y -10, see README)
//   z = up                                 (z 0   = body Z 10, z 22 = the rim)
//
// Measured off DKS-Basic_DukeDoks_Body_L.stl: the inner face is flat and
// vertical over body Y -58..+56, the panel is exactly 6.00 mm thick (X 59..65)
// with a flat top rim at Z 32, and three chassis clip slots pierce it at
// Z 6.5..8.5. Nothing may sit below body Z 10.

part = "mount";              // "mount", "gauge" or "check"

/* [Board] measure yours, devkits vary by a few tenths */
board_l    = 51.5;           // along y
board_w    = 28.3;           // along x, inward from the panel
board_t    = 1.6;            // PCB thickness
fit        = 0.4;            // total slack on length and width
slack      = 0.3;            // vertical slack in the groove
edge_grip  = 1.0;            // how far the groove reaches onto the PCB edge.
                             // Drop to ~0.7 if the header plastic runs flush to
                             // the board edge and fouls the lower ledge.

/* [Frame] */
plate_t    = 2.5;            // back plate against the panel inner face
rail_t     = 2.5;            // outboard rail
arm_w      = 3.0;            // end arms, they sit outside the board ends
plate_h    = 22.0;           // z 0..22, top flush with the panel rim
z_board    = 17.0;           // underside of the PCB
under_arm  = 4.0;            // arm depth below the board
click      = 0.35;           // detent the board snaps over on the way in

/* [Panel + screws] */
panel_thk  = 6.0;            // measured: body X 59 -> 65
boss_x     = 5.5;            // nut boss depth
boss_yz    = 9.0;            // nut boss section
nut_af     = 6.1;            // M3 hex nut across flats + slack
nut_d      = 2.6;            // nut pocket depth
hole_d     = 3.3;            // M3 clearance

/* derived */
pl    = board_l + fit;               // pocket length
pw    = board_w + fit;               // pocket width
gap   = board_t + slack;             // groove height
x_pf  = plate_t;                     // plate face toward the board
x_b0  = x_pf - edge_grip;            // board inner edge, buried in the groove
x_b1  = x_b0 + pw;                   // board outer edge
x_rf  = x_b1 - edge_grip;            // rail face toward the board
x_end = x_rf + rail_t;
y_arm = pl/2;                        // arms start here, outside the board
boss_y0 = y_arm;                      // bosses start at the arms, clear of the pins
plate_l = 2*(boss_y0 + boss_yz);
screw_y = boss_y0 + boss_yz/2;
screw_z = 10.5;
plate_z0 = z_board - 2;              // the plate stops just under the board so
                                     // dupont housings on the inner header row
                                     // have open air all the way to the panel

/* keep-out checks against the measured panel */
z0_body  = 10.0;                     // body Z of z = 0
assert(z0_body >= 9.0, "mount would foul the chassis clip slots at body Z 6.5-8.5");
assert(z0_body + plate_h <= 32.0, "mount stands proud of the panel top rim");
assert(plate_l/2 <= 56.0, "mount is longer than the flat run of the panel");
assert(z_board + board_t + 1 <= plate_h, "board sticks out above the panel rim");
assert(boss_y0 >= board_l/2, "nut boss sits inside the header rows");
assert(screw_z + boss_yz/2 < z_board, "nut boss collides with the board");
assert(plate_z0 < z_board, "no ledge left for the inner groove");
assert(click > slack, "detent is shallower than the groove slack, board will not stay put");

module frame() {
    // back plate against the panel, only down to just under the board
    translate([0, -plate_l/2, plate_z0]) cube([x_pf, plate_l, plate_h - plate_z0]);
    // end stop arm, full height, closes the -y end of the groove
    translate([0, -y_arm - arm_w, z_board - under_arm])
        cube([x_end, arm_w, under_arm + gap + 1]);
    // entry arm, kept below the board so the board can slide in over it
    translate([0, y_arm, z_board - under_arm])
        cube([x_end, arm_w, under_arm]);
    // outboard rail
    translate([x_rf, -y_arm - arm_w, z_board - under_arm])
        cube([rail_t, 2*y_arm + arm_w, under_arm + gap + 1]);
    // nut bosses, outside the header rows so they never shadow a pin
    for (s = [-1, 1])
        translate([0, s > 0 ? boss_y0 : -boss_y0 - boss_yz, screw_z - boss_yz/2])
            cube([boss_x, boss_yz, z_board - (screw_z - boss_yz/2)]);
}

module pockets() {
    // the board slot itself, run out past the +y end so the board slides in
    translate([x_b0, -y_arm, z_board])
        cube([pw, y_arm + plate_l/2, gap]);
    // everything under the board between the lips: open air for the pins
    translate([x_pf, -y_arm, z_board - 40])
        cube([x_rf - x_pf, 2*y_arm, 40]);
    // and above it, so the USB shell and any wiring clear the frame
    translate([x_pf, -y_arm, z_board + gap])
        cube([x_rf - x_pf, y_arm + plate_l/2, 40]);
}

module screw_cuts() {
    for (s = [-1, 1]) translate([0, s*screw_y, screw_z]) {
        rotate([0, 90, 0]) translate([0, 0, -1])
            cylinder(h = boss_x + 2, d = hole_d, $fn = 32);
        // hex pocket opens inward, drop the nut in from the cabin side
        translate([boss_x - nut_d, 0, 0]) rotate([0, 90, 0])
            cylinder(h = nut_d + 0.1, d = nut_af/cos(30), $fn = 6);
    }
}

module detent() {
    // ridge on the rail ledge near the entry, the PCB rides over it and clicks
    translate([x_rf, pl/2 - 7, z_board])
        rotate([0, 90, 0]) rotate([0, 0, 90])
            cylinder(h = edge_grip, r = click, $fn = 24);
}

module mount() {
    union() {
        difference() { frame(); pockets(); }
        detent();
    }
    // screw features last so the pocket cut cannot eat the nut recess
}

module seated_board() {
    translate([x_b0 + fit/2, -board_l/2, z_board + slack/2])
        cube([board_w, board_l, board_t]);
}

if (part == "check")
    // Self-check: a seated board must touch nothing but the detent (excluded here).
    //   openscad -o chk.stl -D 'part="check"' ESP32_Body_Mount.scad   -> empty file
    intersection() { difference() { frame(); pockets(); } seated_board(); }
else if (part == "gauge")
    // 18 mm slice of the entry end: both grooves, the rail, the detent
    intersection() {
        difference() { mount(); screw_cuts(); }
        translate([-1, pl/2 - 12, -1]) cube([x_end + 2, 18, plate_h + 2]);
    }
else
    difference() { mount(); screw_cuts(); }
