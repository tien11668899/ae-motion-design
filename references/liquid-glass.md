# Liquid Glass in After Effects

Built-in effects only (AE 2023). Rig A was built and rendered on this machine
(`C:\Users\user\source\claude-ae\projects\Liquid Glass.aep`, comp "Liquid Glass", render `renders\liquid-glass.mp4`);
open that comp to see every value below in place. Rig B was read from a reference project made in AE 24.6 and has not
been rebuilt here, so check it frame by frame as you build it.

## What sells the material

- **Refraction at the edges**: the content behind bends near the rim. Inside, a slight magnification, a little frost,
  and a lift in exposure and vibrance.
- **Light**: a crisp thin rim, a soft inner glow fading from the edge inward, two glints at opposite angles, and a soft
  contact shadow **outside** the silhouette only.
- **Something with detail behind it**: large type, a faint grid, coloured blobs. Over a flat background the
  refraction is invisible.

## Choosing a rig

| | Rig A: metaball glass | Rig B: shape-as-adjustment |
|---|---|---|
| Shapes | several; they split and merge like liquid | one rounded rect |
| Look | domed, CC Glass lighting, glints | flat lens, rim-only refraction |
| Cost | five or six layers plus two precomps; slower | four or five layers; fast |
| Use for | a capsule that splits into orbs, blobs merging, a liquid toggle | a glass panel or button sliding over content |

## Rig A: metaball glass (proven)

1. **`LG Shapes`** precomp, comp-sized, white shapes on transparent:
   - `Core`: a rect whose Roundness is driven by the capsule expression
     (`var s = content("Group 1").content("Rectangle Path 1").size; Math.min(s[0], s[1]) / 2;`).
   - Orbs: ellipses **parented to Core before Core's scale is animated** (parenting to a zero-scale parent breaks).
   - On top, a "Gooey" adjustment layer: Gaussian Blur 26 with **Repeat Edge Pixels off** (on, the circle gets facets
     at its tangent points), then Levels (Individual Controls) with Alpha Input Black 0.47 and Alpha Input White 0.53.
     The blur-then-threshold makes nearby shapes merge with liquid necks.
2. **`LG Height`** precomp: `LG Shapes` plus Gaussian Blur 34 (repeat edges off). A dome-shaped height map.
3. **Main comp**, top to bottom (AE 23 track mattes can reference any layer):
   - **Glint A / Glint B**: `LG Shapes` + Fill white + CC Light Sweep (Direction 72 / −108, Shape Smooth, Width 70, Sweep
     Intensity 0, Edge Intensity 100, Edge Thickness 6, Light Reception **Cutout**). Center expression:
     `var p = comp("LG Shapes").layer("Core").toComp([0, 0]); [p[0], p[1]];`. Blend Add, opacity 75 / 45.
   - **Inner Glow**: `LG Shapes` + Fill white, track matte `Glass Height` **alpha inverted**, Screen, opacity 35.
   - **Rim**: `LG Shapes` + Fill white + Linear Wipe for the falloff, track matte `Rim Matte` (`LG Shapes` + Simple
     Choker 2.5, hidden) **alpha inverted**, Add, opacity 55.
   - **Glass FX**: an adjustment layer, track matte `Glass Matte` (`LG Shapes`, hidden), with effects in this order:
     1. Transform: Anchor Point and Position use the Core expression above; Scale 104 → 107 while it is a capsule, 101
        while the orbs are apart (otherwise off-centre orbs ghost).
     2. CC Glass: Bump Map `Glass Height`, Property Alpha, Softness 14, Height 30, Displacement 55 (higher doubles
        letters inside small orbs), Light Height 35, Ambient **100**, Diffuse 10 (lower turns it into dark marble),
        Specular 85, Roughness 0.04, **Metal 0** (white highlights).
     3. Gaussian Blur 3 (frost), Exposure +0.3, Vibrance 45.
   - **Glass Height**: `LG Height`, hidden; the bump map and a matte.
   - **Glass Shadow**: `LG Shapes` + Fill black + blur 38, offset +30 px in y, opacity 42, track matte `Glass Matte`
     **alpha inverted**. Without that matte the glass refracts its own shadow and turns muddy.
   - The content behind (title), then the wallpaper.
4. **Wallpaper**: large, unblurred, screen-blended ellipses drifting with `wiggle(0.12, 170)`, and **one** comp-sized
   blur adjustment above them. A blur on each shape layer clips into rectangles.

claude-ae calls for the parts that are easy to get wrong:

```
ae_effect {layer: "Gooey", effect: "ADBE Gaussian Blur 2", params: {"Blurriness": 26, "Repeat Edge Pixels": false}}
ae_effect {layer: "Gooey", effect: "ADBE Pro Levels2", params: {"Alpha Input Black": 0.47, "Alpha Input White": 0.53}}
ae_effect {layer: "Glass FX", effect: "CC Glass", params: {"Bump Map": "Glass Height", "Property": 4, "Softness": 14,
           "Height": 30, "Displacement": 55, "Light Height": 35, "Ambient": 100, "Diffuse": 10, "Specular": 85,
           "Roughness": 0.04, "Metal": 0}}                                              // Property 4 = Alpha
ae_effect {layer: "Glint A", effect: "CC Light Sweep", params: {"Direction": 72, "Shape": 2, "Width": 70,
           "Sweep Intensity": 0, "Edge Intensity": 100, "Edge Thickness": 6, "Light Reception": 3}}  // Shape 2 = Smooth, 3 = Cutout
ae_edit_layer {layer: "Glass FX", trackMatte: {layer: "Glass Matte", type: "alpha"}}
ae_edit_layer {layer: "Glass Shadow", trackMatte: {layer: "Glass Matte", type: "alpha_inverted"}}
```

## Rig B: shape-as-adjustment glass (from a reference project; verify as you build)

- **Box**: a rounded-rect shape layer with the **Adjustment switch on** (`ae_edit_layer {adjustment: true}`), so its
  effects act on everything below, inside the shape. Effects in order: Fast Box Blur 16, Transform with Scale 108 (the
  lens; keep its anchor and position on the box centre), Tint (amount keyed), Displacement Map (luminance, 220 px on
  both axes, map layer = `Map`).
  - Size comes from two Slider Controls (X, Y). The sliders and Position use the inertial settle expression
    (amp 0.02, freq 2, decay 6; see `claude-ae.md`).
- **Map**: the same rect as a 60 px **stroke** with Fast Box Blur 20, hidden. It is the displacement source, so only
  the rim band refracts.
- **Lights**: four copies of the rect following Box by expression: (A) 19 px stroke, blur 4, Set Matte to Box, 20%;
  (B) 60 px stroke, blur 40, Set Matte, 40%; (C, D) 60 px stroke + CC Light Sweep, Cutout, directions 72° and −109°,
  about 41%.
- **Background**: a saturated fill plus two Grid effects (a coarse 599 px grid with 8.6 px lines and a fine 120 px grid
  with 1.3 px lines, light cyan), so the bending is obvious.

## Glass in a continuous sequence

Glass is a material, so it rides on the continuity techniques instead of replacing them:

- **Split and merge** (`continuity.md`, techniques 3 and 2) are native to Rig A: animate orbs out of Core and the
  gooey threshold draws the liquid neck; bring them back and they merge. The neck breaks when the gap between the shapes
  passes roughly the blur radius, so put that frame on purpose, e.g. on the beat.
- **Stretch a disc into a pill** (technique 8): key Core's Size; the capsule expression keeps it round-ended. A glass
  toggle is a glass knob sliding in a glass track with the `ui` ease.
- **A lens travelling over content** (technique 1 in reverse): the glass moves and the content stays; the refraction
  shows the motion. Use the arrival ease plus the inertial settle so it lands like a physical object.
- **Glints follow the shape** through the Core expression, so they stay attached through every morph.

## Pitfalls

- A blur on a shape layer clips at the layer bounds. Blur the composite with an adjustment layer or a precomp.
- A white additive highlight over near-white type is invisible: there is no headroom. Use colour or darker content.
- CC Glass on an adjustment layer refracts whatever is under it, including your own shadow. Matte the shadow to the
  outside of the glass.
- `ADBE Gaussian Blur 2` defaults to Repeat Edge Pixels on; switch it off on every gooey or height-map blur.
- Literal Roundness above half the size renders as a rounded square; drive it by expression.
