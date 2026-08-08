/* ============================================================
   Chinese New Year Cookie Feast
   Custom GLSL Shader Source

   This file contains the custom GLSL shader code used in the
   final Three.js project.

   The shaders are injected into Three.js built-in materials
   through material.onBeforeCompile().

   Sections:
   1. Almond Pastry Shader
   2. Crystal Osmanthus Cake Jelly Shader
   3. Procedural Wood Shader
   ============================================================ */


/* ============================================================
   1. ALMOND PASTRY SHADER
   ============================================================ */


/* ------------------------------------------------------------
   ALMOND PASTRY - VERTEX SHADER UNIFORMS / VARYINGS
   Injected into:
   #include <common>
   ------------------------------------------------------------ */

uniform float uTime;
uniform float uMotionStrength;

varying vec3 vObjectPosition;
varying vec3 vObjectNormal;


/* ------------------------------------------------------------
   ALMOND PASTRY - OBJECT NORMAL
   Injected after:
   #include <beginnormal_vertex>
   ------------------------------------------------------------ */

vObjectNormal =
    normalize(
        objectNormal
    );


/* ------------------------------------------------------------
   ALMOND PASTRY - SUBTLE VERTEX MOTION
   Injected after:
   #include <begin_vertex>

   This produces a subtle procedural deformation while the
   pastry is being moved.
   ------------------------------------------------------------ */

float pastryWave =
    sin(
        uTime *
        10.0 +
        position.x *
        0.15 +
        position.y *
        0.11
    ) *
    cos(
        uTime *
        7.0 +
        position.z *
        0.18
    );

transformed +=
    objectNormal *
    pastryWave *
    0.045 *
    uMotionStrength;

vObjectPosition =
    transformed;


/* ============================================================
   ALMOND PASTRY - FRAGMENT SHADER
   ============================================================ */


/* ------------------------------------------------------------
   UNIFORMS
   ------------------------------------------------------------ */

uniform float uTextureEnabled;
uniform float uMaterialType;
uniform float uTextureScale;
uniform float uCoreFillingBlend;

uniform sampler2D uShellSurfaceColor;
uniform sampler2D uShellSurfaceRoughness;

uniform sampler2D uShellRidgesColor;
uniform sampler2D uShellRidgesRoughness;

uniform sampler2D uCrumbColor;
uniform sampler2D uCrumbRoughness;

uniform sampler2D uFillingColor;
uniform sampler2D uFillingRoughness;

varying vec3 vObjectPosition;
varying vec3 vObjectNormal;

float customRoughness =
    0.8;


/* ------------------------------------------------------------
   HASH FUNCTION

   Produces deterministic pseudo-random values from 3D
   coordinates.
   ------------------------------------------------------------ */

float hash31(
    vec3 p
){

    p =
        fract(
            p *
            0.1031
        );

    p +=
        dot(
            p,
            p.yzx +
            33.33
        );

    return fract(
        (
            p.x +
            p.y
        ) *
        p.z
    );
}


/* ------------------------------------------------------------
   3D VALUE NOISE

   Used to add natural baked color variation.
   ------------------------------------------------------------ */

float noise3(
    vec3 p
){

    vec3 i =
        floor(
            p
        );

    vec3 f =
        fract(
            p
        );

    f =
        f *
        f *
        (
            3.0 -
            2.0 *
            f
        );


    float a =
        hash31(
            i
        );

    float b =
        hash31(
            i +
            vec3(
                1,
                0,
                0
            )
        );

    float c =
        hash31(
            i +
            vec3(
                0,
                1,
                0
            )
        );

    float d =
        hash31(
            i +
            vec3(
                1,
                1,
                0
            )
        );

    float e =
        hash31(
            i +
            vec3(
                0,
                0,
                1
            )
        );

    float f1 =
        hash31(
            i +
            vec3(
                1,
                0,
                1
            )
        );

    float g =
        hash31(
            i +
            vec3(
                0,
                1,
                1
            )
        );

    float h =
        hash31(
            i +
            vec3(
                1
            )
        );


    return mix(

        mix(

            mix(
                a,
                b,
                f.x
            ),

            mix(
                c,
                d,
                f.x
            ),

            f.y
        ),

        mix(

            mix(
                e,
                f1,
                f.x
            ),

            mix(
                g,
                h,
                f.x
            ),

            f.y
        ),

        f.z
    );
}


/* ------------------------------------------------------------
   COLOR SATURATION
   ------------------------------------------------------------ */

vec3 saturateColor(
    vec3 colorValue,
    float amount
){

    float luminance =
        dot(
            colorValue,
            vec3(
                0.299,
                0.587,
                0.114
            )
        );

    return mix(
        vec3(
            luminance
        ),
        colorValue,
        amount
    );
}


/* ------------------------------------------------------------
   COLOR CONTRAST
   ------------------------------------------------------------ */

vec3 adjustContrast(
    vec3 colorValue,
    float contrastValue
){

    return (
        colorValue -
        0.5
    ) *
    contrastValue +
    0.5;
}


/* ------------------------------------------------------------
   TRIPLANAR BLENDING WEIGHTS

   The surface normal determines how much each projection
   contributes.

   X projection -> YZ plane
   Y projection -> XZ plane
   Z projection -> XY plane
   ------------------------------------------------------------ */

vec3 getTriWeights(
    vec3 normalValue
){

    vec3 weights =
        pow(
            abs(
                normalize(
                    normalValue
                )
            ),
            vec3(
                5.0
            )
        );

    weights /=
        max(
            weights.x +
            weights.y +
            weights.z,
            0.0001
        );

    return weights;
}


/* ------------------------------------------------------------
   TRIPLANAR COLOR SAMPLING
   ------------------------------------------------------------ */

vec3 sampleTriColor(
    sampler2D textureMap,
    vec3 positionValue,
    vec3 normalValue,
    float scaleValue
){

    vec3 weights =
        getTriWeights(
            normalValue
        );


    vec3 xSample =
        texture2D(
            textureMap,
            positionValue.yz *
            scaleValue
        ).rgb;


    vec3 ySample =
        texture2D(
            textureMap,
            positionValue.xz *
            scaleValue
        ).rgb;


    vec3 zSample =
        texture2D(
            textureMap,
            positionValue.xy *
            scaleValue
        ).rgb;


    /*
     * Texture color is manually converted from gamma space
     * because the imported texture maps use NoColorSpace.
     */

    xSample =
        pow(
            max(
                xSample,
                vec3(0)
            ),
            vec3(
                2.2
            )
        );


    ySample =
        pow(
            max(
                ySample,
                vec3(0)
            ),
            vec3(
                2.2
            )
        );


    zSample =
        pow(
            max(
                zSample,
                vec3(0)
            ),
            vec3(
                2.2
            )
        );


    return
        xSample *
        weights.x +

        ySample *
        weights.y +

        zSample *
        weights.z;
}


/* ------------------------------------------------------------
   TRIPLANAR GRAYSCALE / ROUGHNESS SAMPLING
   ------------------------------------------------------------ */

float sampleTriValue(
    sampler2D textureMap,
    vec3 positionValue,
    vec3 normalValue,
    float scaleValue
){

    vec3 weights =
        getTriWeights(
            normalValue
        );


    return

        texture2D(
            textureMap,
            positionValue.yz *
            scaleValue
        ).r *
        weights.x +

        texture2D(
            textureMap,
            positionValue.xz *
            scaleValue
        ).r *
        weights.y +

        texture2D(
            textureMap,
            positionValue.xy *
            scaleValue
        ).r *
        weights.z;
}


/* ============================================================
   ALMOND SURFACE COLOR AND ROUGHNESS
   Injected after:
   #include <color_fragment>
   ============================================================ */

vec3 normalValue =
    normalize(
        vObjectNormal
    );


vec3 textureColor =
    diffuseColor.rgb;


float textureRoughness =
    0.8;


/* ------------------------------------------------------------
   MATERIAL TYPE 0
   OUTER ALMOND PASTRY SHELL
   ------------------------------------------------------------ */

if(
    uMaterialType <
    0.5
){

    /*
     * Surfaces facing the pastry's local Z direction are
     * treated more like the top/bottom surface.
     */

    float topWeight =
        smoothstep(
            0.34,
            0.82,
            abs(
                normalValue.z
            )
        );


    vec3 surfaceColor =
        sampleTriColor(
            uShellSurfaceColor,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    vec3 ridgeColor =
        sampleTriColor(
            uShellRidgesColor,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    float surfaceRoughness =
        sampleTriValue(
            uShellSurfaceRoughness,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    float ridgeRoughness =
        sampleTriValue(
            uShellRidgesRoughness,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    /*
     * Blend side ridge texture and top surface texture.
     */

    textureColor =
        mix(
            ridgeColor,
            surfaceColor,
            topWeight
        );


    textureRoughness =
        mix(
            ridgeRoughness,
            surfaceRoughness,
            topWeight
        );


    /*
     * Large-scale baked color variation.
     */

    textureColor *=
        0.90 +
        noise3(
            vObjectPosition *
            0.19
        ) *
        0.18;


    /*
     * Fine-scale surface variation.
     */

    textureColor *=
        0.96 +
        noise3(
            vObjectPosition *
            0.75
        ) *
        0.06;


    /*
     * Slightly darken side regions.
     */

    textureColor *=
        1.0 -
        (
            1.0 -
            topWeight
        ) *
        0.12;


    textureColor =
        saturateColor(
            textureColor,
            1.20
        );


    textureColor =
        adjustContrast(
            textureColor,
            1.15
        );


    /*
     * Warm baked tint.
     */

    textureColor.r *=
        1.03;

    textureColor.g *=
        1.01;


    /*
     * Keep the shell relatively rough.
     */

    textureRoughness =
        clamp(
            0.72 +
            textureRoughness *
            0.22,
            0.66,
            0.98
        );
}


/* ------------------------------------------------------------
   MATERIAL TYPE 1
   EXPOSED CRUMB + FILLING
   ------------------------------------------------------------ */

else{

    vec3 crumbColor =
        sampleTriColor(
            uCrumbColor,
            vObjectPosition,
            normalValue,
            uTextureScale *
            1.18
        );


    vec3 fillingColor =
        sampleTriColor(
            uFillingColor,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    float crumbRoughness =
        sampleTriValue(
            uCrumbRoughness,
            vObjectPosition,
            normalValue,
            uTextureScale *
            1.18
        );


    float fillingRoughness =
        sampleTriValue(
            uFillingRoughness,
            vObjectPosition,
            normalValue,
            uTextureScale
        );


    /*
     * Add procedural variation between crumb and filling.
     */

    float fillingMask =
        clamp(
            uCoreFillingBlend +
            (
                noise3(
                    vObjectPosition *
                    0.18
                ) -
                0.5
            ) *
            0.24,
            0.0,
            1.0
        );


    textureColor =
        mix(
            crumbColor,
            fillingColor,
            fillingMask
        );


    textureColor =
        saturateColor(
            textureColor,
            1.16
        );


    textureColor =
        adjustContrast(
            textureColor,
            1.10
        );


    textureColor.r *=
        1.04;

    textureColor.g *=
        1.01;


    /*
     * Slight directional shading variation.
     */

    textureColor *=
        mix(
            0.90,
            1.0,
            smoothstep(
                -0.2,
                0.75,
                abs(
                    normalValue.z
                )
            )
        );


    /*
     * Crumb remains dry and rough.
     */

    crumbRoughness =
        clamp(
            0.74 +
            crumbRoughness *
            0.22,
            0.72,
            0.98
        );


    /*
     * Filling is smoother than the baked shell.
     */

    fillingRoughness =
        clamp(
            0.22 +
            fillingRoughness *
            0.26,
            0.20,
            0.58
        );


    textureRoughness =
        mix(
            crumbRoughness,
            fillingRoughness,
            fillingMask
        );
}


/* ------------------------------------------------------------
   FINAL TEXTURE BLENDING
   ------------------------------------------------------------ */

diffuseColor.rgb =
    mix(
        diffuseColor.rgb,
        textureColor,
        uTextureEnabled
    );


customRoughness =
    clamp(
        textureRoughness,
        0.18,
        1.0
    );


/* ------------------------------------------------------------
   FINAL ROUGHNESS OVERRIDE

   Injected after:
   #include <roughnessmap_fragment>
   ------------------------------------------------------------ */

roughnessFactor =
    mix(
        roughnessFactor,
        customRoughness,
        uTextureEnabled *
        0.96
    );



/* ============================================================
   2. CRYSTAL OSMANTHUS CAKE JELLY SHADER
   ============================================================ */


/* ------------------------------------------------------------
   JELLY VERTEX SHADER UNIFORMS

   Injected into MeshPhysicalMaterial through onBeforeCompile().
   ------------------------------------------------------------ */

uniform float uTime;
uniform float uEnergy;
uniform float uPhase;

uniform float uMinZ;
uniform float uHeight;


/* ------------------------------------------------------------
   JELLY VERTEX DEFORMATION

   Injected after:
   #include <begin_vertex>
   ------------------------------------------------------------ */


/*
 * Normalize the vertex height.
 *
 * h = 0 at the bottom of the cake
 * h = 1 at the top of the cake
 */

float h =
    clamp(
        (
            position.z -
            uMinZ
        ) /
        uHeight,
        0.0,
        1.0
    );


/*
 * Anchor the bottom of the cake.
 *
 * The lower region moves less while the upper region is
 * allowed to wobble more freely.
 */

float anchor =
    smoothstep(
        0.03,
        0.36,
        h
    );


/*
 * Three independent oscillation waves create more organic
 * motion than a single sine wave.
 */

float w1 =
    sin(
        uTime *
        10.5 +
        uPhase +
        h *
        4.2 +
        position.x *
        0.052
    );


float w2 =
    cos(
        uTime *
        12.4 +
        uPhase *
        1.7 +
        h *
        2.9 -
        position.y *
        0.05
    );


float w3 =
    sin(
        uTime *
        8.7 +
        uPhase *
        0.72 +
        position.x *
        0.034 +
        position.y *
        0.032
    );


/*
 * Horizontal jelly deformation.
 */

transformed.x +=
    (
        w1 *
        0.82 +
        w2 *
        0.32
    ) *
    uEnergy *
    anchor;


/*
 * Secondary horizontal / depth deformation.
 */

transformed.y +=
    (
        w2 *
        0.68 +
        w3 *
        0.26
    ) *
    uEnergy *
    anchor;


/*
 * Vertical deformation is smaller than horizontal movement.
 */

transformed.z +=
    w3 *
    uEnergy *
    0.36 *
    anchor;



/* ============================================================
   JELLY MATERIAL PARAMETERS
   ============================================================

   These values are configured in JavaScript through
   THREE.MeshPhysicalMaterial and are included here as
   documentation because they work together with the GLSL
   deformation shader.

   Crystal body:

   color               = 0xffd66c
   roughness           = 0.11
   opacity             = 0.60
   transmission        = 0.66
   thickness           = 1.10
   ior                 = 1.34
   clearcoat           = 0.84
   clearcoatRoughness  = 0.06

   Osmanthus petals:

   color               = 0xe58c28
   roughness           = 0.27
   opacity             = 0.90
   transmission        = 0.10
   thickness           = 0.18
   ior                 = 1.34
   clearcoat           = 0.42
   clearcoatRoughness  = 0.16

   ============================================================ */



/* ============================================================
   JELLY SECONDARY MOTION EQUATION
   ============================================================

   The GLSL shader receives uEnergy from JavaScript.

   The energy value decays over time using:

       A(t) = A0 * exp(-lambda * t)

   Actual JavaScript implementation:

       data.energy *= exp(-deltaTime * 2.05)

   The resulting energy is supplied to the shader as uEnergy.

   This allows the cake to continue wobbling after the
   steamer or chopsticks stop moving.

   ============================================================ */



/* ============================================================
   3. PROCEDURAL WOOD SHADER
   ============================================================ */


/* ------------------------------------------------------------
   WOOD VERTEX SHADER
   ------------------------------------------------------------ */

varying vec3 vWoodPosition;


/*
 * Injected after:
 * #include <begin_vertex>
 */

vWoodPosition =
    position;


/* ------------------------------------------------------------
   WOOD FRAGMENT SHADER
   ------------------------------------------------------------ */

uniform vec3 uLightColor;
uniform vec3 uDarkColor;

varying vec3 vWoodPosition;


/*
 * Large wood-grain pattern.
 */

float grain =
    0.5 +
    0.5 *
    sin(
        vWoodPosition.y *
        8.5 +
        sin(
            vWoodPosition.z *
            2.9
        ) *
        1.7
    );


/*
 * Fine grain variation.
 */

float fineGrain =
    0.5 +
    0.5 *
    sin(
        vWoodPosition.y *
        27.0
    );


/*
 * Blend the dark and light wood colors.
 */

diffuseColor.rgb =
    mix(
        uDarkColor,
        uLightColor,
        grain *
        0.82 +
        fineGrain *
        0.18
    );



/* ============================================================
   END OF CUSTOM SHADER SOURCE
   ============================================================ */