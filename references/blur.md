# Blur

Contents:
1. What the study piece does (measured)
2. When to use motion blur
3. Motion blur in After Effects
4. Blur as a material: soft light, glows, shadows, frost
5. Blur as a transition
6. Blur effects (matchNames) and pitfalls

## 1. What the study piece does

**No motion blur on its flat graphics.** A moving edge blurred by a shutter gets a wider 10–90% ramp: about
0.8 × (shutter angle / 360) × speed in px per frame. Measured with `[Look]::Blend` and `Get-Edge`:

| Edge | Speed | 10–90% ramp | A 180° shutter would give |
|---|---|---|---|
| a disc popping out of a glow | 23–58 px/frame | 2.9–3.3 px | 9–23 px |
| a heart growing into a disc | 36 px/frame | 2.7 px | 14 px |
| the same edges at rest | 0 | 2.7–3.9 px | — |

Fast rotations (blades fanning out, phones fanning, a dot running round a ring) are just as crisp by eye. Every frame is
a clean illustration, and the motion reads through easing and continuity instead.

**Blur is used as light and material**: a white radial glow that swells and fades (0.37 s each), a soft multi-colour
orb, a radar sweep with a soft gradient tail, a soft shadow under fanned objects, a fine light mesh.

**Type changes soften only slightly:** during the word pivot the changing words' edge ramp goes from 1.5 to 2.5 px at
the midpoint; it is mostly a fade (`typography-layout.md`).

## 2. When to use motion blur

| Look | Motion blur |
|---|---|
| Flat, crisp vector graphics with eased, continuous motion (the study piece) | off, or a small shutter (45–90°) |
| Photographic or 3D-rendered material, camera moves over footage, realistic objects | on, 180° |
| A whip or speed transition | on, 180–360°, or a Directional Blur tied to speed |
| Fast long linear travel that strobes (an edge jumping more than about a third of the object per frame across many frames) | on, or slow the move down |
| Very fast short pops and spins in a flat piece | off; the eye follows the shape change, not the edge |

claude-ae switches motion blur on for every new layer and comp (its house rule). For the crisp flat look, switch it off
deliberately and say so; check a few of the fastest frames afterwards.

## 3. Motion blur in After Effects

- Two switches: the comp's (`comp.motionBlur`) and each layer's (`ae_edit_layer {motionBlur: false}`).
- Comp settings (Composition Settings > Advanced), scriptable through ae_eval: `comp.shutterAngle` (180),
  `comp.shutterPhase`, `comp.motionBlurSamplesPerFrame` (16), `comp.motionBlurAdaptiveSampleLimit` (128). A comp made
  by script starts with phase 0, so the blur trails forward from the frame time; set the phase to −angle / 2 to centre
  it. Raise the samples when fast rotations show steps in the blur.
- Shape-group transforms, Repeater copies and expression-driven motion are all blurred with their layer.
- The Transform effect blurs its own motion only with its "Use Composition’s Shutter Angle" checkbox or its own
  Shutter Angle.
- Nested comps: the precomp's layers are blurred by the precomp's own settings; a time-remapped precomp needs
  CC Force Motion Blur. Footage needs Pixel Motion Blur.

```
ae_eval {script: "var c = CB.findComp('Intro'); c.motionBlur = true; c.shutterAngle = 90; c.shutterPhase = -45;
                  c.motionBlurSamplesPerFrame = 16; return [c.shutterAngle, c.shutterPhase];"}
```

## 4. Blur as a material

- **Soft orb:** an ellipse filled with a saturated colour and blurred 40–80 px. A blur on a shape layer clips at the
  layer bounds, so blur through an adjustment layer above it or inside a precomp, or use a radial gradient that fades
  to transparent instead of a blur.
- **Multi-colour light** (an orb, a wallpaper): three or four saturated ellipses drifting slowly (`wiggle(0.12, 170)`),
  blended with Screen or Add, under **one** comp-sized blur adjustment layer.
- **Glow bridge:** a solid with a radial Gradient Ramp (white at the centre to black), blended Add, opacity keyed with
  `glow_up` / `glow_down` (`timing.md`); or the Glow effect (`ADBE Glo2`) with Glow Intensity keyed.
- **Contact shadow:** a duplicate of the silhouette, filled black, blurred 30–40 px, offset 20–30 px down, opacity
  30–45%, matted to the outside of the object (`liquid-glass.md`).
- **Frost:** a 2–4 px blur under glass, with a slight exposure lift.

## 5. Blur as a transition

- **Focus pull swap:** the outgoing element blurs 0 → 8–20 px while it fades (about 0.3 s, accelerating); the incoming
  element sharpens 8–20 → 0 px while it appears (0.3–0.4 s, arrival ease); overlap them by 2–4 frames. For type, use
  the Text Blur animator property so it can cascade per character.
- **Zoom-through streaks:** CC Radial Fast Blur in Zoom mode, its amount rising and falling with the zoom speed of a
  log-scale camera move.
- **Whip:** Directional Blur along the travel direction, its length tied to speed; about 180° worth is
  `length(transform.position.velocity) * thisComp.frameDuration * 0.5` px.

## 6. Blur effects (matchNames) and pitfalls

Verified in AE 2023 with `ae_list {what: "effects", query: "blur"}`:

| Effect | matchName | Use |
|---|---|---|
| Gaussian Blur | `ADBE Gaussian Blur 2` | soft shapes, glows, mattes (set Repeat Edge Pixels false) |
| Fast Box Blur | `ADBE Box Blur2` | fast; Iterations 3 looks Gaussian |
| Directional Blur | `ADBE Motion Blur` | streaks, whips |
| Radial Blur | `ADBE Radial Blur` | spin or zoom blur around a point |
| CC Radial Fast Blur | `CC Radial Fast Blur` | fast zoom streaks |
| CC Radial Blur | `CC Radial Blur` | spin and zoom variants |
| CC Vector Blur | `CC Vector Blur` | flowing, map-driven smear |
| CC Cross Blur | `CS CrossBlur` | separate horizontal and vertical blur |
| Camera Lens Blur | `ADBE Camera Lens Blur` | depth of field, bokeh shapes, a blur map for depth |
| Compound Blur | `ADBE Compound Blur` | blur driven by a layer's luminance |
| Channel Blur | `ADBE Channel Blur` | per-channel blur |
| Bilateral Blur / Smart Blur | `ADBE Bilateral` / `ADBE Smart Blur` | edge-preserving smoothing |
| CC Force Motion Blur | `CC Force Motion Blur` | motion blur for precomps and time remapping |
| Pixel Motion Blur | `ADBE OFMotionBlur` | motion blur for footage |

Pitfalls:

- `ADBE Gaussian Blur 2` defaults to Repeat Edge Pixels **on** in AE 2023: it clips and facets blurred mattes. Set it
  false.
- A blur on a shape layer clips at the layer bounds; blur the composite.
- Large blurs over gradients band in 8 bpc. Dither first (Gradient Ramp's Ramp Scatter 24–64, or a little noise);
  switching the project to 16 bpc changes every comp in it, so ask before doing that.
- Big blurs are slow to render; preview with Fast Box Blur and switch to Gaussian for the final if needed.
- With motion blur on, both layers of a swap need it on, or the swap frame pops.
