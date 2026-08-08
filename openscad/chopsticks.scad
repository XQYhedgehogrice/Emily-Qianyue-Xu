/*
    ALMOND PASTRY PROJECT
    CHOPSTICKS

    This model is based on the proportions used
    in the Three.js eating animation.

    Approximate conversion:
    1 Three.js unit = 17.93 mm

    Export workflow:
    1. Set MODE.
    2. Press F6.
    3. File > Export > Export as STL.
*/


// ============================================================
// GLOBAL QUALITY
// ============================================================

$fn = 48;


// ============================================================
// EXPORT MODE
// ============================================================

// Available:
// "preview_pair"
// "single_chopstick"
// "pair"

MODE = "preview_pair";


// ============================================================
// MAIN DIMENSIONS
// ============================================================

// Total chopstick length.
CHOPSTICK_LENGTH = 122;

// Radius at the thick rear end.
REAR_RADIUS = 1.88;

// Radius at the gripping tip.
TIP_RADIUS = 0.99;

// Decorative rear cap length.
CAP_LENGTH = 6.8;

// Decorative rear cap radius.
CAP_RADIUS = 2.0;


// ============================================================
// PAIR SETTINGS
// ============================================================

// Distance between the two chopsticks in preview mode.
PAIR_GAP = 20;

// Small angle used to make the pair look more natural.
PAIR_ANGLE = 2.5;


// ============================================================
// SINGLE CHOPSTICK BODY
// ============================================================

module chopstick_body() {

    /*
        OpenSCAD cylinders grow along Z.
        The thin end is placed at Z = 0.
    */

    cylinder(
        h = CHOPSTICK_LENGTH,
        r1 = TIP_RADIUS,
        r2 = REAR_RADIUS
    );
}


// ============================================================
// REAR DECORATIVE CAP
// ============================================================

module chopstick_cap() {

    translate([
        0,
        0,
        CHOPSTICK_LENGTH - CAP_LENGTH
    ])

    cylinder(
        h = CAP_LENGTH,
        r = CAP_RADIUS
    );
}


// ============================================================
// COMPLETE SINGLE CHOPSTICK
// ============================================================

module single_chopstick() {

    union() {

        chopstick_body();

        chopstick_cap();
    }
}


// ============================================================
// CHOPSTICK PAIR
// ============================================================

module chopstick_pair() {

    /*
        The pair is separated along X.
        Both tips begin near Z = 0.
    */

    translate([
        -PAIR_GAP / 2,
        0,
        0
    ])

    rotate([
        0,
        -PAIR_ANGLE,
        0
    ])

    single_chopstick();


    translate([
        PAIR_GAP / 2,
        0,
        0
    ])

    rotate([
        0,
        PAIR_ANGLE,
        0
    ])

    single_chopstick();
}


// ============================================================
// PREVIEW VERSION
// ============================================================

module preview_pair() {

    /*
        Rotate the pair so the chopsticks appear horizontal
        in the standard OpenSCAD perspective view.
    */

    rotate([
        90,
        0,
        0
    ])

    chopstick_pair();
}


// ============================================================
// OUTPUT
// ============================================================

if (MODE == "single_chopstick") {

    single_chopstick();

}

else if (MODE == "pair") {

    chopstick_pair();

}

else {

    preview_pair();
}