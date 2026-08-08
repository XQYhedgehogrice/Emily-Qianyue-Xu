/*
    BAMBOO STEAMER
    For Crystal Osmanthus Cake Animation

    Designed to work beside the existing almond pastry plate.

    Approximate dimensions:
    - Outer diameter: 136 mm
    - Inner usable diameter: about 124 mm
    - Basket height: 30 mm
    - Designed for three crystal cakes

    Export workflow:
    1. Change MODE.
    2. Press F6.
    3. File > Export > Export as STL.

    Recommended animation export:
    MODE = "basket_complete";

    Optional lid:
    MODE = "lid";
*/


// ============================================================
// GLOBAL QUALITY
// ============================================================

$fn = 96;


// ============================================================
// EXPORT MODE
// ============================================================

/*
    Available values:

    "preview_open"
    "preview_with_lid"

    "basket_wall"
    "basket_floor"
    "basket_complete"

    "lid"
*/

MODE = "preview_open";


// ============================================================
// MAIN BASKET DIMENSIONS
// ============================================================

// Complete outer diameter.
OUTER_DIAMETER = 136;

// Complete outer radius.
OUTER_RADIUS = OUTER_DIAMETER / 2;

// Main bamboo wall thickness.
WALL_THICKNESS = 5.5;

// Inner usable radius.
INNER_RADIUS = OUTER_RADIUS - WALL_THICKNESS;

// Total basket height.
BASKET_HEIGHT = 30;

// Bottom floor height above world zero.
FLOOR_Z = 4.5;


// ============================================================
// WALL SHAPE
// ============================================================

// Main cylindrical wall starts slightly above the bottom.
WALL_BOTTOM_Z = 2.0;

// Main wall height.
WALL_BODY_HEIGHT = 26;


// ============================================================
// BAMBOO RIM SETTINGS
// ============================================================

// Raised bands around the outside.
BAND_PROJECTION = 1.25;

// Vertical thickness of each band.
BAND_HEIGHT = 2.1;

// Heights of decorative binding bands.
LOWER_BAND_Z = 4.0;

MIDDLE_BAND_Z = 15.2;

UPPER_BAND_Z = 26.3;


// ============================================================
// TOP RIM
// ============================================================

// Extra thick top ring.
TOP_RIM_HEIGHT = 3.6;

// Extra radial thickness.
TOP_RIM_PROJECTION = 1.8;


// ============================================================
// BOTTOM SUPPORT RING
// ============================================================

BOTTOM_RING_HEIGHT = 3.0;

BOTTOM_RING_WIDTH = 5.2;


// ============================================================
// FLOOR BAMBOO STRIPS
// ============================================================

// Width of each long bamboo strip.
SLAT_WIDTH = 6.0;

// Gap between neighbouring strips.
SLAT_GAP = 3.5;

// Thickness of each strip.
SLAT_THICKNESS = 2.4;

// Approximate strip count across the floor.
SLAT_COUNT = 13;


// ============================================================
// CROSS SUPPORT STRIPS
// ============================================================

// Two wider strips hold the parallel bamboo floor together.
CROSS_STRIP_WIDTH = 4.0;

CROSS_STRIP_THICKNESS = 1.5;

CROSS_STRIP_OFFSET = 24;


// ============================================================
// LID SETTINGS
// ============================================================

LID_OUTER_RADIUS = OUTER_RADIUS + 0.7;

LID_RIM_WIDTH = 5.2;

LID_RIM_HEIGHT = 4.2;

LID_WEAVE_THICKNESS = 1.45;

LID_STRIP_WIDTH = 7.0;

LID_STRIP_GAP = 2.4;


// ============================================================
// HANDLE SETTINGS
// ============================================================

HANDLE_WIDTH = 26;

HANDLE_POST_RADIUS = 2.2;

HANDLE_HEIGHT = 9;

HANDLE_BAR_RADIUS = 2.0;


// ============================================================
// HELPER: RING
// ============================================================

module ring(
    outer_radius,
    inner_radius,
    height
) {

    difference() {

        cylinder(
            h = height,
            r = outer_radius
        );

        translate([
            0,
            0,
            -0.1
        ])

        cylinder(
            h = height + 0.2,
            r = inner_radius
        );
    }
}


// ============================================================
// MAIN BAMBOO WALL
// ============================================================

module basket_main_wall() {

    translate([
        0,
        0,
        WALL_BOTTOM_Z
    ])

    ring(
        OUTER_RADIUS,
        INNER_RADIUS,
        WALL_BODY_HEIGHT
    );
}


// ============================================================
// OUTER BINDING BAND
// ============================================================

module outside_band(
    z_position
) {

    translate([
        0,
        0,
        z_position
    ])

    ring(
        OUTER_RADIUS +
            BAND_PROJECTION,

        OUTER_RADIUS -
            0.8,

        BAND_HEIGHT
    );
}


// ============================================================
// TOP RIM
// ============================================================

module basket_top_rim() {

    translate([
        0,
        0,
        BASKET_HEIGHT -
            TOP_RIM_HEIGHT
    ])

    ring(

        OUTER_RADIUS +
            TOP_RIM_PROJECTION,

        INNER_RADIUS -
            1.0,

        TOP_RIM_HEIGHT
    );
}


// ============================================================
// BOTTOM SUPPORT RING
// ============================================================

module basket_bottom_ring() {

    translate([
        0,
        0,
        1
    ])

    ring(

        OUTER_RADIUS,

        OUTER_RADIUS -
            BOTTOM_RING_WIDTH,

        BOTTOM_RING_HEIGHT
    );
}


// ============================================================
// COMPLETE WALL
// ============================================================

module basket_wall() {

    union() {

        basket_main_wall();

        basket_bottom_ring();

        basket_top_rim();


        outside_band(
            LOWER_BAND_Z
        );


        outside_band(
            MIDDLE_BAND_Z
        );


        outside_band(
            UPPER_BAND_Z
        );
    }
}


// ============================================================
// ONE FLOOR SLAT
// ============================================================

module one_floor_slat(
    x_position
) {

    translate([
        x_position,
        0,
        FLOOR_Z
    ])

    cube(
        [
            SLAT_WIDTH,

            INNER_RADIUS *
                2.15,

            SLAT_THICKNESS
        ],

        center = true
    );
}


// ============================================================
// PARALLEL BAMBOO FLOOR
// ============================================================

module parallel_floor_slats() {

    intersection() {

        /*
            Circular clipping volume.
        */

        translate([
            0,
            0,
            FLOOR_Z
        ])

        cylinder(
            h = SLAT_THICKNESS +
                0.2,

            r = INNER_RADIUS -
                1.5,

            center = true
        );


        /*
            Parallel bamboo strips.
        */

        union() {

            for (
                i = [
                    -floor(
                        SLAT_COUNT / 2
                    )
                    :
                    floor(
                        SLAT_COUNT / 2
                    )
                ]
            ) {

                one_floor_slat(

                    i *
                    (
                        SLAT_WIDTH +
                        SLAT_GAP
                    )
                );
            }
        }
    }
}


// ============================================================
// CROSS SUPPORT STRIP
// ============================================================

module one_cross_strip(
    y_position
) {

    intersection() {

        translate([
            0,
            y_position,
            FLOOR_Z -
                1.45
        ])

        cube(
            [
                INNER_RADIUS *
                    2.1,

                CROSS_STRIP_WIDTH,

                CROSS_STRIP_THICKNESS
            ],

            center = true
        );


        translate([
            0,
            0,
            FLOOR_Z
        ])

        cylinder(
            h = 5,

            r = INNER_RADIUS -
                2,

            center = true
        );
    }
}


// ============================================================
// COMPLETE BASKET FLOOR
// ============================================================

module basket_floor() {

    union() {

        parallel_floor_slats();


        one_cross_strip(
            CROSS_STRIP_OFFSET
        );


        one_cross_strip(
            -CROSS_STRIP_OFFSET
        );
    }
}


// ============================================================
// SMALL BAMBOO TIES
// ============================================================

module bamboo_tie(
    x_position,
    y_position
) {

    translate([
        x_position,
        y_position,
        FLOOR_Z +
            1.6
    ])

    rotate([
        0,
        0,
        45
    ])

    cube(
        [
            5.4,
            1.3,
            0.8
        ],

        center = true
    );
}


// ============================================================
// FLOOR TIE DETAILS
// ============================================================

module floor_ties() {

    for (
        x = [
            -42,
            -28,
            -14,
            0,
            14,
            28,
            42
        ]
    ) {

        bamboo_tie(
            x,
            CROSS_STRIP_OFFSET
        );


        bamboo_tie(
            x,
            -CROSS_STRIP_OFFSET
        );
    }
}


// ============================================================
// COMPLETE OPEN STEAMER
// ============================================================

module basket_complete() {

    union() {

        basket_wall();

        basket_floor();

        floor_ties();
    }
}


// ============================================================
// LID OUTER RIM
// ============================================================

module lid_outer_rim() {

    ring(

        LID_OUTER_RADIUS,

        LID_OUTER_RADIUS -
            LID_RIM_WIDTH,

        LID_RIM_HEIGHT
    );
}


// ============================================================
// ONE LID WEAVE STRIP
// ============================================================

module lid_strip(
    offset_value,
    strip_angle,
    z_position
) {

    rotate([
        0,
        0,
        strip_angle
    ])

    translate([
        offset_value,
        0,
        z_position
    ])

    cube(
        [
            LID_STRIP_WIDTH,

            LID_OUTER_RADIUS *
                2.2,

            LID_WEAVE_THICKNESS
        ],

        center = true
    );
}


// ============================================================
// LID WOVEN SURFACE
// ============================================================

module lid_weave() {

    intersection() {

        cylinder(
            h = 4,

            r =
                LID_OUTER_RADIUS -
                LID_RIM_WIDTH +
                0.8
        );


        union() {

            /*
                First diagonal layer.
            */

            for (
                i = [
                    -8 : 8
                ]
            ) {

                lid_strip(

                    i *
                    (
                        LID_STRIP_WIDTH +
                        LID_STRIP_GAP
                    ),

                    45,

                    1.2
                );
            }


            /*
                Second diagonal layer.
            */

            for (
                i = [
                    -8 : 8
                ]
            ) {

                lid_strip(

                    i *
                    (
                        LID_STRIP_WIDTH +
                        LID_STRIP_GAP
                    ),

                    -45,

                    2.1
                );
            }
        }
    }
}


// ============================================================
// LID HANDLE
// ============================================================

module lid_handle() {

    /*
        Left post.
    */

    translate([
        -HANDLE_WIDTH / 2,
        0,
        4
    ])

    cylinder(
        h = HANDLE_HEIGHT,
        r = HANDLE_POST_RADIUS
    );


    /*
        Right post.
    */

    translate([
        HANDLE_WIDTH / 2,
        0,
        4
    ])

    cylinder(
        h = HANDLE_HEIGHT,
        r = HANDLE_POST_RADIUS
    );


    /*
        Soft horizontal grip using hull.
    */

    hull() {

        translate([
            -HANDLE_WIDTH / 2,
            0,
            4 +
            HANDLE_HEIGHT
        ])

        sphere(
            r = HANDLE_BAR_RADIUS
        );


        translate([
            HANDLE_WIDTH / 2,
            0,
            4 +
            HANDLE_HEIGHT
        ])

        sphere(
            r = HANDLE_BAR_RADIUS
        );
    }
}


// ============================================================
// COMPLETE LID
// ============================================================

module lid() {

    union() {

        lid_outer_rim();

        lid_weave();

        lid_handle();
    }
}


// ============================================================
// PREVIEW OPEN BASKET
// ============================================================

module preview_open() {

    /*
        Main light bamboo body.
    */

    color([
        0.73,
        0.49,
        0.24
    ])

    basket_wall();


    /*
        Slightly lighter floor strips.
    */

    color([
        0.84,
        0.64,
        0.36
    ])

    basket_floor();


    /*
        Darker ties.
    */

    color([
        0.62,
        0.39,
        0.18
    ])

    floor_ties();
}


// ============================================================
// PREVIEW WITH LID
// ============================================================

module preview_with_lid() {

    preview_open();


    /*
        Lift the lid slightly above the basket so both
        objects remain visible in preview.
    */

    translate([
        0,
        0,
        36
    ])

    color([
        0.82,
        0.61,
        0.33
    ])

    lid();
}


// ============================================================
// OUTPUT
// ============================================================

if (
    MODE ==
    "basket_wall"
) {

    basket_wall();
}


else if (
    MODE ==
    "basket_floor"
) {

    union() {

        basket_floor();

        floor_ties();
    }
}


else if (
    MODE ==
    "basket_complete"
) {

    basket_complete();
}


else if (
    MODE ==
    "lid"
) {

    lid();
}


else if (
    MODE ==
    "preview_with_lid"
) {

    preview_with_lid();
}


else {

    preview_open();
}