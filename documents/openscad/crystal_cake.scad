/*
    CRYSTAL OSMANTHUS CAKE
    水晶桂花糕

    Designed for the Three.js food animation project.

    Visual goals:
    - Eight-petal flower silhouette
    - Very soft rounded gelatin edges
    - Slightly tapered side wall
    - Gently raised petal crowns
    - Shallow grooves between petals
    - Separate osmanthus inclusions
    - Whole and bitten states share the exact same origin

    Recommended STL exports:

    crystal_cake_whole_body.stl
    crystal_cake_whole_petals.stl
    crystal_cake_bitten_body.stl
    crystal_cake_bitten_petals.stl

    Export workflow:
    1. Change MODE.
    2. Press F6.
    3. File > Export > Export as STL.
*/


// ============================================================
// GLOBAL QUALITY
// ============================================================

/*
    A relatively high resolution is intentional.

    The future Three.js vertex shader will deform the cake
    to create gelatin wobble, so additional vertices help
    create a smoother deformation.
*/

$fn = 72;


// ============================================================
// EXPORT MODE
// ============================================================

/*
    Available modes:

    "preview_whole"
    "preview_bitten"
    "preview_three"

    "whole_body"
    "whole_petals"

    "bitten_body"
    "bitten_petals"
*/

MODE = "bitten_petals";


// ============================================================
// MAIN CAKE DIMENSIONS
// ============================================================

/*
    Approximate complete dimensions:
    diameter: about 44 mm
    height: about 26 mm
*/

CAKE_HEIGHT = 26;


// ============================================================
// FLOWER STRUCTURE
// ============================================================

// Number of flower petals.
LOBE_COUNT = 8;

// Radius from the center to each petal center.
PETAL_RING_RADIUS = 12.0;

// Radius of each petal in the 2D flower profile.
PETAL_RADIUS = 9.0;

// Central circle joins all petals together smoothly.
CENTER_RADIUS = 11.4;


// ============================================================
// GELATIN BODY SETTINGS
// ============================================================

// Main body before the raised flower crown.
BASE_BODY_HEIGHT = 24.0;

// Roundness added by Minkowski.
EDGE_ROUND = 1.8;

// Bottom is slightly wider than the upper body.
BOTTOM_SCALE = 0.97;

// Top is slightly narrower.
TOP_SCALE = 0.93;

// Height remaining inside the Minkowski operation.
CORE_EXTRUSION_HEIGHT =
    BASE_BODY_HEIGHT -
    EDGE_ROUND * 2;


// ============================================================
// FLOWER CROWN SETTINGS
// ============================================================

// Raised petal crowns make the top look soft and moulded.
CROWN_CENTER_RADIUS =
    PETAL_RING_RADIUS * 0.94;

// Radial size of each soft crown.
CROWN_RADIAL_RADIUS = 8.2;

// Tangential crown size.
CROWN_TANGENTIAL_RADIUS = 7.1;

// Vertical bulge.
CROWN_VERTICAL_RADIUS = 2.5;

// Crown center height.
CROWN_Z = 23.5;


// ============================================================
// TOP GROOVE SETTINGS
// ============================================================

// Radius of shallow grooves between petals.
GROOVE_RADIUS = 0.82;

// Beginning of each radial groove.
GROOVE_INNER_RADIUS = 4.6;

// End of each groove.
GROOVE_OUTER_RADIUS = 18.4;

// Groove elevation.
GROOVE_INNER_Z = 25.05;

GROOVE_OUTER_Z = 24.35;


// ============================================================
// BITE SETTINGS
// ============================================================

/*
    The bite is taken from the +Y side.

    This convention is useful because Whole and Bitten
    remain aligned exactly like the almond pastry workflow.
*/

BITE_RADIUS = 7.2;

BITE_Y = 19.2;

BITE_Z = 16.0;

BITE_SIDE_OFFSET = 5.6;


// ============================================================
// OSMANTHUS SETTINGS
// ============================================================

// Basic size of one visible flower fragment.
FLAKE_LENGTH = 2.6;

FLAKE_WIDTH = 0.75;

FLAKE_THICKNESS = 0.35;


// ============================================================
// THREE-CAKE PREVIEW SETTINGS
// ============================================================

PREVIEW_SPACING_X = 25;

PREVIEW_BACK_Y = 19;


// ============================================================
// 2D FLOWER PROFILE
// ============================================================

module flower_profile_2d() {

    union() {

        /*
            Central area prevents the eight petal circles
            from producing an overly thin flower center.
        */

        circle(
            r = CENTER_RADIUS
        );


        /*
            Eight overlapping circular lobes create
            the external flower silhouette.
        */

        for (
            index = [
                0 :
                LOBE_COUNT - 1
            ]
        ) {

            rotate(
                index *
                360 /
                LOBE_COUNT
            )

            translate([
                PETAL_RING_RADIUS,
                0
            ])

            circle(
                r = PETAL_RADIUS
            );
        }
    }
}


// ============================================================
// SOFT MAIN GELATIN BODY
// ============================================================

module soft_base_body() {

    /*
        Minkowski creates genuinely rounded physical geometry,
        rather than relying only on smooth shading.

        The sphere rounds:
        - top perimeter
        - bottom perimeter
        - petal valleys
        - side transitions
    */

    translate([
        0,
        0,
        EDGE_ROUND
    ])

    minkowski() {

        linear_extrude(
            height =
                CORE_EXTRUSION_HEIGHT,

            scale =
                TOP_SCALE /
                BOTTOM_SCALE,

            convexity = 10
        )

        scale([
            BOTTOM_SCALE,
            BOTTOM_SCALE
        ])

        flower_profile_2d();


        sphere(
            r = EDGE_ROUND,

            $fn = 30
        );
    }
}


// ============================================================
// ONE SOFT PETAL CROWN
// ============================================================

module one_petal_crown(
    angle
) {

    /*
        The ellipsoid is longer in the radial direction.
        This creates the soft raised surface visible on
        moulded crystal cakes.
    */

    rotate([
        0,
        0,
        angle
    ])

    translate([
        CROWN_CENTER_RADIUS,
        0,
        CROWN_Z
    ])

    scale([
        CROWN_RADIAL_RADIUS,
        CROWN_TANGENTIAL_RADIUS,
        CROWN_VERTICAL_RADIUS
    ])

    sphere(
        r = 1,

        $fn = 42
    );
}


// ============================================================
// ALL PETAL CROWNS
// ============================================================

module petal_crowns() {

    for (
        index = [
            0 :
            LOBE_COUNT - 1
        ]
    ) {

        one_petal_crown(

            index *
            360 /
            LOBE_COUNT
        );
    }
}


// ============================================================
// CENTRAL SOFT CROWN
// ============================================================

module central_crown() {

    /*
        This slightly raised center connects the eight petals
        without creating a sharp mechanical intersection.
    */

    translate([
        0,
        0,
        23.25
    ])

    scale([
        7.2,
        7.2,
        1.45
    ])

    sphere(
        r = 1,

        $fn = 48
    );
}


// ============================================================
// RAW GELATIN BODY
// ============================================================

module raw_crystal_body() {

    union() {

        soft_base_body();

        petal_crowns();

        central_crown();
    }
}


// ============================================================
// ONE PETAL GROOVE
// ============================================================

module one_petal_groove(
    angle
) {

    /*
        A hull between two spheres produces a rounded,
        shallow channel instead of a hard rectangular cut.
    */

    rotate([
        0,
        0,
        angle
    ])

    hull() {

        translate([
            GROOVE_INNER_RADIUS,
            0,
            GROOVE_INNER_Z
        ])

        sphere(
            r = GROOVE_RADIUS,

            $fn = 24
        );


        translate([
            GROOVE_OUTER_RADIUS,
            0,
            GROOVE_OUTER_Z
        ])

        sphere(
            r = GROOVE_RADIUS,

            $fn = 24
        );
    }
}


// ============================================================
// ALL TOP GROOVES
// ============================================================

module petal_grooves() {

    /*
        Grooves are positioned between adjacent petals.
    */

    for (
        index = [
            0 :
            LOBE_COUNT - 1
        ]
    ) {

        one_petal_groove(

            (
                index +
                0.5
            ) *
            360 /
            LOBE_COUNT
        );
    }
}


// ============================================================
// VERY SHALLOW CENTER DEPRESSION
// ============================================================

module center_depression() {

    /*
        A very subtle depression helps the flower center
        catch highlights like soft jelly.
    */

    translate([
        0,
        0,
        26.0
    ])

    scale([
        4.4,
        4.4,
        0.85
    ])

    sphere(
        r = 1,

        $fn = 40
    );
}


// ============================================================
// COMPLETE WHOLE CAKE BODY
// ============================================================

module whole_body() {

    difference() {

        raw_crystal_body();

        petal_grooves();

        center_depression();
    }
}


// ============================================================
// BITE CUTTERS
// ============================================================

module bite_cutters() {

    /*
        Three overlapping spheres create an organic,
        rounded bite suitable for a soft gelatin cake.
    */

    translate([
        0,
        BITE_Y,
        BITE_Z
    ])

    sphere(
        r = BITE_RADIUS,

        $fn = 48
    );


    translate([
        BITE_SIDE_OFFSET,
        BITE_Y - 0.6,
        BITE_Z + 0.5
    ])

    sphere(
        r = BITE_RADIUS * 0.92,

        $fn = 48
    );


    translate([
        -BITE_SIDE_OFFSET,
        BITE_Y - 0.4,
        BITE_Z - 0.4
    ])

    sphere(
        r = BITE_RADIUS * 0.95,

        $fn = 48
    );


    /*
        Lower cutter removes the remaining thin membrane
        and gives the bite more depth.
    */

    translate([
        0,
        BITE_Y + 2.2,
        BITE_Z - 4.7
    ])

    scale([
        1.15,
        1.0,
        0.72
    ])

    sphere(
        r = BITE_RADIUS,

        $fn = 44
    );
}


// ============================================================
// BITTEN BODY
// ============================================================

module bitten_body() {

    difference() {

        whole_body();

        bite_cutters();
    }
}


// ============================================================
// OSMANTHUS FLAKE
// ============================================================

module osmanthus_flake(
    position = [0,0,10],
    rotation = [0,0,0],
    size = [1,1,1]
) {

    translate(
        position
    )

    rotate(
        rotation
    )

    scale([
        FLAKE_LENGTH *
            size[0],

        FLAKE_WIDTH *
            size[1],

        FLAKE_THICKNESS *
            size[2]
    ])

    sphere(
        r = 1,

        $fn = 14
    );
}


// ============================================================
// INTERNAL OSMANTHUS FRAGMENTS
// ============================================================

module osmanthus_petals() {

    /*
        Positions are intentionally deterministic.

        Keeping the fragments mostly near the central region
        prevents them from protruding through the flower wall.
    */


    osmanthus_flake(
        [ 5.4,  3.0, 20.7],
        [18, 12,  34],
        [1.0, 1.0, 1.0]
    );


    osmanthus_flake(
        [-6.7,  1.8, 18.4],
        [42,  5, -18],
        [0.9, 1.2, 1.0]
    );


    osmanthus_flake(
        [ 1.3, -7.4, 18.1],
        [15, 38,  60],
        [1.1, 0.9, 1.0]
    );


    osmanthus_flake(
        [-3.9, -5.3, 14.6],
        [62, 20,  15],
        [0.8, 1.0, 1.1]
    );


    osmanthus_flake(
        [ 7.8, -2.8, 13.4],
        [25, 55, -42],
        [1.0, 0.8, 1.0]
    );


    osmanthus_flake(
        [ 0.2,  6.6, 12.1],
        [50,  8,  82],
        [1.2, 0.9, 1.0]
    );


    osmanthus_flake(
        [-8.6, -1.3, 10.0],
        [35, 42,  10],
        [0.85, 1.1, 1.0]
    );


    osmanthus_flake(
        [ 5.2,  5.8,  9.3],
        [66, 18, -50],
        [1.0, 0.9, 0.9]
    );


    osmanthus_flake(
        [-2.4,  3.9,  7.1],
        [20, 70,  32],
        [0.8, 1.2, 1.0]
    );


    osmanthus_flake(
        [ 8.7,  0.4,  7.8],
        [38, 26, -12],
        [0.9, 0.8, 1.0]
    );


    osmanthus_flake(
        [-7.3,  5.0, 15.8],
        [22, 58,  48],
        [1.15, 0.8, 1.0]
    );


    osmanthus_flake(
        [ 3.8, -3.5, 16.3],
        [56, 10, -28],
        [0.75, 1.2, 1.0]
    );


    osmanthus_flake(
        [-0.7, -1.5, 21.4],
        [15, 44,  65],
        [0.9, 1.0, 1.0]
    );


    osmanthus_flake(
        [ 9.3,  3.1, 17.0],
        [35, 12, -72],
        [0.75, 0.9, 1.0]
    );


    osmanthus_flake(
        [-9.0, -2.5, 19.1],
        [48, 32,  22],
        [0.85, 1.1, 1.0]
    );


    /*
        A few very small fragments make the interior
        feel less artificially arranged.
    */

    osmanthus_flake(
        [ 2.1,  1.0, 11.0],
        [72, 20,  30],
        [0.55, 0.7, 0.8]
    );


    osmanthus_flake(
        [-4.1,  7.5, 17.1],
        [30, 64, -20],
        [0.60, 0.8, 0.7]
    );


    osmanthus_flake(
        [ 6.0, -6.4, 20.0],
        [40, 18,  72],
        [0.65, 0.7, 0.8]
    );
}


// ============================================================
// WHOLE PETAL / INCLUSION EXPORT
// ============================================================

module whole_petals() {

    osmanthus_petals();
}


// ============================================================
// BITTEN PETAL EXPORT
// ============================================================

module bitten_petals() {

    /*
        Remove any flower fragments that would have occupied
        the missing bitten region.
    */

    difference() {

        osmanthus_petals();

        bite_cutters();
    }
}


// ============================================================
// WHOLE PREVIEW
// ============================================================

module preview_whole() {

    /*
        Transparency is only an OpenSCAD preview aid.
        STL files do not contain transparent materials.
    */

    color([
        1.00,
        0.70,
        0.15,
        0.42
    ])

    whole_body();


    color([
        0.95,
        0.38,
        0.04,
        1.00
    ])

    whole_petals();
}


// ============================================================
// BITTEN PREVIEW
// ============================================================

module preview_bitten() {

    color([
        1.00,
        0.70,
        0.15,
        0.42
    ])

    bitten_body();


    color([
        0.95,
        0.38,
        0.04,
        1.00
    ])

    bitten_petals();
}


// ============================================================
// THREE-CAKE PREVIEW
// ============================================================

module preview_three() {

    /*
        This roughly represents the future arrangement
        inside the bamboo steamer.
    */


    translate([
        0,
        PREVIEW_BACK_Y,
        0
    ])

    preview_whole();


    translate([
        -PREVIEW_SPACING_X,
        -10,
        0
    ])

    rotate([
        0,
        0,
        -10
    ])

    preview_whole();


    translate([
        PREVIEW_SPACING_X,
        -10,
        0
    ])

    rotate([
        0,
        0,
        12
    ])

    preview_whole();
}


// ============================================================
// OUTPUT
// ============================================================

if (
    MODE ==
    "whole_body"
) {

    whole_body();
}


else if (
    MODE ==
    "whole_petals"
) {

    whole_petals();
}


else if (
    MODE ==
    "bitten_body"
) {

    bitten_body();
}


else if (
    MODE ==
    "bitten_petals"
) {

    bitten_petals();
}


else if (
    MODE ==
    "preview_bitten"
) {

    preview_bitten();
}


else if (
    MODE ==
    "preview_three"
) {

    preview_three();
}


else {

    preview_whole();
}