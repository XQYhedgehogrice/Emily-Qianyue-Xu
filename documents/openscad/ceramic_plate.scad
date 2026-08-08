/*
    ALMOND PASTRY PROJECT
    CERAMIC PLATE

    This plate is based on the proportions used
    in the Three.js eating animation.

    Approximate diameter:
    160 mm

    Export workflow:
    1. Set MODE.
    2. Press F6.
    3. File > Export > Export as STL.
*/


// ============================================================
// GLOBAL QUALITY
// ============================================================

$fn = 128;


// ============================================================
// EXPORT MODE
// ============================================================

// Available:
// "preview"
// "plate_body"
// "blue_ring"
// "complete_geometry"

MODE = "preview";


// ============================================================
// MAIN DIMENSIONS
// ============================================================

// Maximum outside radius.
OUTER_RADIUS = 79.8;

// Radius of the lower plate body.
LOWER_RADIUS = 74.4;

// Main usable upper surface radius.
SURFACE_RADIUS = 70.8;

// Slightly smaller underside radius.
SURFACE_BOTTOM_RADIUS = 69.0;

// Total approximate plate height.
PLATE_HEIGHT = 10.0;


// ============================================================
// LOWER BASE
// ============================================================

BASE_HEIGHT = 6.1;

BASE_BOTTOM_RADIUS = 74.4;

BASE_TOP_RADIUS = 79.8;


// ============================================================
// UPPER SURFACE
// ============================================================

SURFACE_HEIGHT = 2.9;

SURFACE_BOTTOM_Z = 6.0;


// ============================================================
// RIM SETTINGS
// ============================================================

RIM_MAJOR_RADIUS = 76.2;

RIM_MINOR_RADIUS = 5.0;


// ============================================================
// DECORATIVE BLUE RING
// ============================================================

BLUE_RING_RADIUS = 66.7;

BLUE_RING_WIDTH = 0.85;

BLUE_RING_HEIGHT = 0.55;


// ============================================================
// TORUS HELPER
// ============================================================

module torus(
    major_radius,
    minor_radius
) {

    rotate_extrude(
        convexity = 10
    )

    translate([
        major_radius,
        0,
        0
    ])

    circle(
        r = minor_radius
    );
}


// ============================================================
// LOWER CERAMIC BODY
// ============================================================

module plate_lower_body() {

    cylinder(
        h = BASE_HEIGHT,
        r1 = BASE_BOTTOM_RADIUS,
        r2 = BASE_TOP_RADIUS
    );
}


// ============================================================
// UPPER CERAMIC SURFACE
// ============================================================

module plate_surface() {

    translate([
        0,
        0,
        SURFACE_BOTTOM_Z
    ])

    cylinder(
        h = SURFACE_HEIGHT,
        r1 = SURFACE_BOTTOM_RADIUS,
        r2 = SURFACE_RADIUS
    );
}


// ============================================================
// RAISED OUTER RIM
// ============================================================

module plate_outer_rim() {

    translate([
        0,
        0,
        8.1
    ])

    /*
        Flatten the torus slightly vertically.
        This gives the rim a ceramic plate profile
        rather than a completely round tube.
    */

    scale([
        1,
        1,
        0.55
    ])

    torus(
        RIM_MAJOR_RADIUS,
        RIM_MINOR_RADIUS
    );
}


// ============================================================
// COMPLETE CERAMIC BODY
// ============================================================

module plate_body() {

    union() {

        plate_lower_body();

        plate_surface();

        plate_outer_rim();
    }
}


// ============================================================
// DECORATIVE RING
// ============================================================

module decorative_ring() {

    translate([
        0,
        0,
        8.95
    ])

    difference() {

        cylinder(
            h = BLUE_RING_HEIGHT,
            r = BLUE_RING_RADIUS +
                BLUE_RING_WIDTH / 2
        );


        translate([
            0,
            0,
            -0.1
        ])

        cylinder(
            h = BLUE_RING_HEIGHT + 0.2,
            r = BLUE_RING_RADIUS -
                BLUE_RING_WIDTH / 2
        );
    }
}


// ============================================================
// COMPLETE GEOMETRY
// ============================================================

module complete_plate_geometry() {

    union() {

        plate_body();

        decorative_ring();
    }
}


// ============================================================
// PREVIEW
// ============================================================

module preview_plate() {

    /*
        White ceramic body.
    */

    color([
        0.96,
        0.95,
        0.91
    ])

    plate_body();


    /*
        Blue decorative ring.
        Color is visible only in OpenSCAD preview.
        STL export does not store this color.
    */

    color([
        0.10,
        0.22,
        0.42
    ])

    decorative_ring();
}


// ============================================================
// OUTPUT
// ============================================================

if (MODE == "plate_body") {

    plate_body();

}

else if (MODE == "blue_ring") {

    decorative_ring();

}

else if (MODE == "complete_geometry") {

    complete_plate_geometry();

}

else {

    preview_plate();
}