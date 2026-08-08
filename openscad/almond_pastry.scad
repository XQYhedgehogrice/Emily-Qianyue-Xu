/*
    ALMOND PASTRY / 杏仁饼
    Parametric OpenSCAD model for a whole pastry and a one-bite cross-section state.

    Coordinate convention:
    - X axis: left / right
    - Y axis: front / back
    - Z axis: up / down
    - The bite is taken from the +Y side.

    Export workflow:
    1. Change MODE to the required object.
    2. Press F6 to render.
    3. Use File > Export > Export as STL.

    Recommended files for the THREE.js animation:
    - almond_whole_body.stl
    - almond_bitten_shell.stl
    - almond_bitten_core.stl
*/

// -----------------------------------------------------------------------------
// GLOBAL QUALITY SETTINGS
// -----------------------------------------------------------------------------

// Increase this value for a smoother final STL, or reduce it for faster previews.
$fn = 96;

// -----------------------------------------------------------------------------
// EXPORT MODE
// -----------------------------------------------------------------------------

// Available values:
// "preview_whole", "preview_bitten", "preview_comparison",
// "whole_body", "whole_shell", "whole_core",
// "bitten_shell", "bitten_core", "crumbs"
MODE = "preview_bitten";

// -----------------------------------------------------------------------------
// MAIN PASTRY DIMENSIONS
// -----------------------------------------------------------------------------

// Overall pastry diameter in millimetres.
PASTRY_DIAMETER = 52;

// Overall pastry height in millimetres.
PASTRY_HEIGHT = 18;

// Convenience radius derived from the diameter.
PASTRY_RADIUS = PASTRY_DIAMETER / 2;

// Amount of soft rounding at the upper and lower perimeter.
EDGE_INSET = 1.8;

// -----------------------------------------------------------------------------
// SIDE GROOVE SETTINGS
// -----------------------------------------------------------------------------

// Number of vertical mould grooves around the side wall.
SIDE_GROOVE_COUNT = 28;

// Radius of each groove-cutting cylinder.
SIDE_GROOVE_RADIUS = 0.85;

// Percentage of pastry height covered by the side grooves.
SIDE_GROOVE_HEIGHT_RATIO = 0.74;

// -----------------------------------------------------------------------------
// TOP RELIEF SETTINGS
// -----------------------------------------------------------------------------

// Height of the embossed pattern above the pastry surface.
RELIEF_HEIGHT = 0.75;

// Small overlap that guarantees the relief joins the pastry body cleanly.
RELIEF_OVERLAP = 0.18;

// Radius of the outer decorative petal ring.
OUTER_PATTERN_RADIUS = 20.8;

// Number of repeated petals around the outer ring.
OUTER_PETAL_COUNT = 20;

// Radii for the two circular relief lines.
OUTER_RING_RADIUS = 17.8;
INNER_RING_RADIUS = 15.9;
RING_WIDTH = 0.75;

// Use a Chinese text symbol when the selected font is available.
// Set this to false to use the font-independent geometric seal instead.
USE_TEXT_SYMBOL = false;

// Change this font name if the Chinese character does not appear on your system.
SYMBOL_FONT = "Noto Sans CJK SC:style=Bold";

// The centre character can be changed to another auspicious character.
SYMBOL_TEXT = "福";

// -----------------------------------------------------------------------------
// INTERNAL CORE SETTINGS
// -----------------------------------------------------------------------------

// The inner core is modelled as a flattened ellipsoid.
CORE_RADIUS_X = 15.6;
CORE_RADIUS_Y = 14.2;
CORE_RADIUS_Z = 4.8;

// Slightly shift the core to avoid a perfectly mechanical centre.
CORE_OFFSET = [0.4, -0.8, -0.2];

// The cavity is slightly larger than the visible core to prevent coplanar faces.
CORE_CAVITY_SCALE = 1.035;

// -----------------------------------------------------------------------------
// BITE SETTINGS
// -----------------------------------------------------------------------------

// Approximate depth of the first bite measured inward from the +Y side.
BITE_DEPTH = 15;

// Vertical position of the main bite cluster.
BITE_HEIGHT = 1.0;

// -----------------------------------------------------------------------------
// OPTIONAL SURFACE DETAIL SETTINGS
// -----------------------------------------------------------------------------

// Enable shallow pits that break up the perfectly smooth top surface.
ENABLE_TOP_PITS = true;

// Enable a small group of separate crumb objects for animation or still renders.
ENABLE_CRUMBS = true;

// -----------------------------------------------------------------------------
// HELPER: 2D CAPSULE SHAPE
// -----------------------------------------------------------------------------

// Create a rounded rectangle-like capsule in 2D.
module capsule_2d(length = 4, width = 1.8) {
    hull() {
        translate([-(length - width) / 2, 0]) circle(d = width, $fn = 24);
        translate([ (length - width) / 2, 0]) circle(d = width, $fn = 24);
    }
}

// -----------------------------------------------------------------------------
// HELPER: EMBOSSED RING
// -----------------------------------------------------------------------------

// Create a raised circular ring that slightly overlaps the pastry body.
module relief_ring(outer_radius, ring_width, z_position) {
    translate([0, 0, z_position])
        difference() {
            cylinder(h = RELIEF_HEIGHT + RELIEF_OVERLAP,
                     r = outer_radius,
                     center = false);

            translate([0, 0, -0.05])
                cylinder(h = RELIEF_HEIGHT + RELIEF_OVERLAP + 0.1,
                         r = outer_radius - ring_width,
                         center = false);
        }
}

// -----------------------------------------------------------------------------
// BASE BODY: SOFT MOULDED DISC
// -----------------------------------------------------------------------------

// Build the general pastry volume from several thin cylinders joined by hull().
// The varying radii create a soft upper edge, a fuller middle, and a rounded base.
module rounded_body_blank() {
    hull() {
        // Bottom control ring.
        translate([0, 0, -PASTRY_HEIGHT / 2 + 0.45])
            cylinder(h = 0.5,
                     r = PASTRY_RADIUS - EDGE_INSET,
                     center = true);

        // Lower-middle control ring.
        translate([0, 0, -PASTRY_HEIGHT * 0.22])
            cylinder(h = 0.5,
                     r = PASTRY_RADIUS - 0.15,
                     center = true);

        // Upper-middle control ring.
        translate([0, 0, PASTRY_HEIGHT * 0.19])
            cylinder(h = 0.5,
                     r = PASTRY_RADIUS,
                     center = true);

        // Top control ring, slightly smaller to create a gentle shoulder.
        translate([0, 0, PASTRY_HEIGHT / 2 - 0.45])
            cylinder(h = 0.5,
                     r = PASTRY_RADIUS - EDGE_INSET - 0.35,
                     center = true);
    }
}

// -----------------------------------------------------------------------------
// SIDE GROOVE CUTTERS
// -----------------------------------------------------------------------------

// Create evenly spaced vertical cutters around the pastry side wall.
module side_groove_cutters() {
    groove_height = PASTRY_HEIGHT * SIDE_GROOVE_HEIGHT_RATIO;

    for (angle = [0 : 360 / SIDE_GROOVE_COUNT : 360 - 360 / SIDE_GROOVE_COUNT]) {
        rotate([0, 0, angle])
            translate([PASTRY_RADIUS - 0.05, 0, -0.35])
                cylinder(h = groove_height,
                         r = SIDE_GROOVE_RADIUS,
                         center = true,
                         $fn = 24);
    }
}

// -----------------------------------------------------------------------------
// TOP SURFACE PIT CUTTERS
// -----------------------------------------------------------------------------

// Add a deterministic set of shallow pits instead of using random geometry.
// These pits suggest a dry and crumbly surface without creating a heavy mesh.
module top_pit_cutters() {
    top_z = PASTRY_HEIGHT / 2 - 0.35;

    // Each entry contains [x, y, radius, x_scale, y_scale].
    pit_data = [
        [-11.0,  3.5, 0.60, 1.30, 0.85],
        [ -7.0, -8.5, 0.48, 0.90, 1.35],
        [ -3.0, 10.5, 0.42, 1.15, 0.80],
        [  2.5, -5.5, 0.55, 1.20, 0.90],
        [  5.5,  8.5, 0.50, 0.85, 1.25],
        [ 10.5, -2.0, 0.62, 1.35, 0.80],
        [ 13.5,  5.0, 0.38, 0.90, 1.10],
        [-14.0, -3.5, 0.40, 1.10, 0.95],
        [  0.5, 13.5, 0.34, 0.80, 1.25],
        [  8.0, 12.0, 0.36, 1.25, 0.85]
    ];

    for (pit = pit_data) {
        translate([pit[0], pit[1], top_z + 0.12])
            scale([pit[3], pit[4], 0.42])
                sphere(r = pit[2], $fn = 20);
    }
}

// -----------------------------------------------------------------------------
// MOULDED BODY WITH SIDE GROOVES AND SURFACE PITS
// -----------------------------------------------------------------------------

// Subtract the side grooves and optional surface pits from the rounded blank.
module moulded_body() {
    difference() {
        rounded_body_blank();
        side_groove_cutters();

        if (ENABLE_TOP_PITS) {
            top_pit_cutters();
        }
    }
}

// -----------------------------------------------------------------------------
// FONT-INDEPENDENT CENTRE SEAL
// -----------------------------------------------------------------------------

// Create a simple geometric seal when a Chinese font is unavailable.
// The pattern is deliberately stylised rather than an exact written character.
module geometric_seal_2d() {
    union() {
        // Outer square frame.
        difference() {
            square([12.0, 12.0], center = true);
            square([9.8, 9.8], center = true);
        }

        // Upper horizontal motif.
        translate([0, 3.2]) square([7.2, 1.25], center = true);

        // Middle split motif.
        translate([-2.2, 0.4]) square([2.4, 1.25], center = true);
        translate([ 2.2, 0.4]) square([2.4, 1.25], center = true);

        // Lower horizontal motif.
        translate([0, -2.4]) square([7.2, 1.25], center = true);

        // Short central vertical motif.
        square([1.25, 6.4], center = true);
    }
}

// -----------------------------------------------------------------------------
// TOP EMBOSSED ORNAMENT
// -----------------------------------------------------------------------------

// Create the outer petals, two circular rings, and the centre symbol.
module top_ornament() {
    relief_z = PASTRY_HEIGHT / 2 - 0.45;

    // Create the repeated outer petal border.
    for (angle = [0 : 360 / OUTER_PETAL_COUNT : 360 - 360 / OUTER_PETAL_COUNT]) {
        rotate([0, 0, angle])
            translate([OUTER_PATTERN_RADIUS, 0, relief_z])
                rotate([0, 0, 90])
                    linear_extrude(height = RELIEF_HEIGHT + RELIEF_OVERLAP)
                        capsule_2d(length = 4.0, width = 1.85);
    }

    // Create the outer circular relief line.
    relief_ring(OUTER_RING_RADIUS, RING_WIDTH, relief_z);

    // Create the inner circular relief line.
    relief_ring(INNER_RING_RADIUS, RING_WIDTH, relief_z);

    // Create either a Chinese character or a geometric seal in the centre.
    translate([0, 0, relief_z]) {
        if (USE_TEXT_SYMBOL) {
            linear_extrude(height = RELIEF_HEIGHT + RELIEF_OVERLAP)
                text(SYMBOL_TEXT,
                     size = 13.5,
                     font = SYMBOL_FONT,
                     halign = "center",
                     valign = "center");
        } else {
            linear_extrude(height = RELIEF_HEIGHT + RELIEF_OVERLAP)
                geometric_seal_2d();
        }
    }
}

// -----------------------------------------------------------------------------
// COMPLETE DECORATED OUTER FORM
// -----------------------------------------------------------------------------

// Join the moulded pastry body and the embossed top ornament.
module decorated_outer_form() {
    union() {
        moulded_body();
        top_ornament();
    }
}

// -----------------------------------------------------------------------------
// INTERNAL ALMOND CORE
// -----------------------------------------------------------------------------

// Create a flattened ellipsoidal core with a small natural-looking offset.
module almond_core(scale_factor = 1.0) {
    translate(CORE_OFFSET)
        scale([
            CORE_RADIUS_X * scale_factor,
            CORE_RADIUS_Y * scale_factor,
            CORE_RADIUS_Z * scale_factor
        ])
            sphere(r = 1, $fn = 72);
}

// -----------------------------------------------------------------------------
// BITE CUTTERS
// -----------------------------------------------------------------------------

// Create an irregular first-bite volume from overlapping spheres.
// The larger spheres establish the main bite and the smaller spheres break up
// the edge so that it reads as crumbly rather than perfectly machined.
module bite_cutters() {
    main_y = PASTRY_RADIUS - BITE_DEPTH * 0.52;
    side_y = PASTRY_RADIUS - BITE_DEPTH * 0.38;

    union() {
        // Main central bite volume.
        translate([0, main_y, BITE_HEIGHT])
            scale([1.05, 1.00, 0.92])
                sphere(r = 10.8, $fn = 64);

        // Left tooth volume.
        translate([-8.6, side_y, BITE_HEIGHT + 0.4])
            scale([1.00, 1.05, 0.95])
                sphere(r = 8.4, $fn = 56);

        // Right tooth volume.
        translate([8.4, side_y, BITE_HEIGHT - 0.2])
            scale([1.00, 1.05, 0.92])
                sphere(r = 8.1, $fn = 56);

        // Upper-left crumb break.
        translate([-4.5, main_y - 3.2, BITE_HEIGHT + 6.8])
            sphere(r = 3.2, $fn = 32);

        // Upper-right crumb break.
        translate([5.2, main_y - 2.8, BITE_HEIGHT + 6.3])
            sphere(r = 2.8, $fn = 32);

        // Lower central crumb break.
        translate([1.2, main_y - 2.5, BITE_HEIGHT - 7.0])
            sphere(r = 2.6, $fn = 28);
    }
}

// -----------------------------------------------------------------------------
// WHOLE PASTRY OUTPUTS
// -----------------------------------------------------------------------------

// Create one solid whole pastry for the initial unbitten animation state.
module whole_body() {
    decorated_outer_form();
}

// Create the hollow outer portion for a multi-material whole preview or export.
module whole_shell() {
    difference() {
        decorated_outer_form();
        almond_core(CORE_CAVITY_SCALE);
    }
}

// Create the separate inner core for a multi-material whole preview or export.
module whole_core() {
    almond_core(1.0);
}

// -----------------------------------------------------------------------------
// BITTEN PASTRY OUTPUTS
// -----------------------------------------------------------------------------

// Create the bitten outer shell and remove a slightly oversized core cavity.
module bitten_shell() {
    difference() {
        difference() {
            decorated_outer_form();
            almond_core(CORE_CAVITY_SCALE);
        }

        bite_cutters();
    }
}

// Create the visible remaining inner core after the same bite is removed.
module bitten_core() {
    difference() {
        almond_core(1.0);
        bite_cutters();
    }
}

// -----------------------------------------------------------------------------
// OPTIONAL CRUMB CLUSTER
// -----------------------------------------------------------------------------

// Create a few low-poly crumbs that can be exported and animated separately.
module crumb_cluster() {
    if (ENABLE_CRUMBS) {
        crumb_data = [
            [-7.5, 18.5, -7.5, 1.15, 0.8, 0.65, 18],
            [-3.0, 21.0, -8.5, 0.85, 0.7, 0.55, 26],
            [ 2.0, 19.0, -7.8, 1.00, 0.65, 0.70, -12],
            [ 6.5, 21.5, -8.2, 0.75, 0.55, 0.50, 33],
            [ 9.0, 18.0, -7.0, 0.95, 0.70, 0.60, -24],
            [-1.0, 23.0, -6.8, 0.70, 0.50, 0.45, 9]
        ];

        for (crumb = crumb_data) {
            translate([crumb[0], crumb[1], crumb[2]])
                rotate([crumb[6], crumb[6] * 0.7, crumb[6] * 1.3])
                    scale([crumb[3], crumb[4], crumb[5]])
                        sphere(r = 1, $fn = 12);
        }
    }
}

// -----------------------------------------------------------------------------
// COLOURED PREVIEW MODULES
// -----------------------------------------------------------------------------

// Preview the whole pastry with a warm baked biscuit colour.
module preview_whole() {
    color([0.88, 0.68, 0.38])
        whole_body();
}

// Preview the bitten shell and inner core using different colours.
module preview_bitten() {
    color([0.88, 0.68, 0.38])
        bitten_shell();

    color([0.96, 0.78, 0.56])
        bitten_core();

    color([0.90, 0.70, 0.42])
        crumb_cluster();
}

// Preview the whole and bitten states side by side for alignment checking.
module preview_comparison() {
    translate([-PASTRY_DIAMETER * 0.62, 0, 0])
        preview_whole();

    translate([PASTRY_DIAMETER * 0.62, 0, 0])
        preview_bitten();
}

// -----------------------------------------------------------------------------
// MODE SELECTOR
// -----------------------------------------------------------------------------

// Display exactly one export object or one preview arrangement.
if (MODE == "preview_whole") {
    preview_whole();
} else if (MODE == "preview_bitten") {
    preview_bitten();
} else if (MODE == "preview_comparison") {
    preview_comparison();
} else if (MODE == "whole_body") {
    whole_body();
} else if (MODE == "whole_shell") {
    whole_shell();
} else if (MODE == "whole_core") {
    whole_core();
} else if (MODE == "bitten_shell") {
    bitten_shell();
} else if (MODE == "bitten_core") {
    bitten_core();
} else if (MODE == "crumbs") {
    crumb_cluster();
} else {
    // Fall back to the comparison preview when MODE contains an invalid value.
    preview_comparison();
}
