# Camera and effects

The study piece is flat, but the same continuity grammar gets richer with a real 3D camera, light and well-chosen
effects. Names below were checked in AE 2023 on this PC (`ae_list`, ae_eval readbacks).

Contents:
1. When to go 3D
2. 3D setup: renderer, layers, camera
3. Camera moves and rigs
4. Depth of field, parallax, light
5. Effects palette by job
6. Using effects with taste

## 1. When to go 3D

- When a change of scale or world needs to feel physical: a dolly through layers instead of scaling a null.
- When the subject benefits from light and depth: soft shading on white objects, contact shadows, depth of field.
- When the piece should feel like a film rather than a diagram.

Keep the grammar: one subject at the centre, every new thing out of something on screen, camera moves for changes of
scale. A 2D CAM null (`claude-ae.md`, section 3) is still the right tool for flat pieces.

## 2. 3D setup: renderer, layers, camera

**Renderer.** `comp.renderers` lists `ADBE Advanced 3d`, `ADBE Standard 3d` and `ADBE Ernst` here. Use
`ADBE Advanced 3d`, AE's long-standing internal name for the Classic 3D renderer: it is the default for new comps, and
cameras, lights and depth of field render correctly through claude-ae with it. `ADBE Ernst` is the Cinema 4D renderer
(extruded, bevelled text and shapes). `ADBE Standard 3d` rendered only empty frames in a test on this PC, so avoid it.
Set it with `ae_eval {script: "CB.findComp('Intro').renderer = 'ADBE Advanced 3d';"}`.

**3D layers.** `ae_add_layer {..., threeD: true}` or `ae_edit_layer {layer, threeD: true}`. A 3D layer has Position
[x, y, z], X/Y/Z Rotation, Orientation, and Material Options (Casts Shadows, Accepts Shadows, Accepts Lights,
Ambient, Diffuse, Specular Intensity, Specular Shininess, Metal, Reflection, Transparency, Index of Refraction).

**Camera.** `ae_add_layer {kind: "camera", name: "Cam", zoom: 2666.7}`. Properties: Zoom, Depth of Field, Focus
Distance, Aperture, Blur Level, Iris Shape / Rotation / Roundness / Aspect Ratio / Diffraction Fringe, Highlight Gain /
Threshold / Saturation; transform: Point of Interest, Position (X/Y/Z), Orientation, X/Y/Z Rotation. In a 1920×1080
comp the default Zoom is 2666.7 px: a camera at [960, 540, −2666.7] looking at [960, 540, 0] shows layers at z = 0
exactly at their 2D size. AE's scripting call leaves a new camera at [0, 0, −zoom], looking obliquely at the centre;
claude-ae's `ae_add_layer` now moves it to [960, 540, −zoom] (fixed 2026-10-26). If a camera was made another way,
set Position and Point of Interest explicitly and check a frame.

## 3. Camera moves and rigs

| Move | How | Ease |
|---|---|---|
| push-in / pull-back (dolly) | camera Z Position, in log space for long moves (key a slider in stops, as with the CAM null) | `camera` after a hand-off, `camera_rest` from rest |
| truck / pedestal | camera X / Y Position and Point of Interest together | `arrive` |
| pan / tilt | move the Point of Interest only | `arrive`, slower than a truck |
| orbit | a 3D null "Rig" at the subject; parent the camera with `cam.setParentWithJump(rig)` in ae_eval, then set the camera's Position to [0, 0, −distance] and Point of Interest to [0, 0, 0] (both in the Rig's space); key the Rig's Y Rotation (X for a crane). Tested: the subject stays centred and the focus expression keeps it sharp | `handoff_long` or a slow constant drift |
| rack focus | key Focus Distance (or switch which layer the focus expression follows) | `arrive`, 0.5–1 s |
| dolly zoom | camera moves back while Zoom grows in proportion to the distance, so the subject keeps its size and the space stretches | `in_out` |
| roll | Z Rotation; rare, for energy | `handoff` |

Zoom-through to a texture (`continuity.md`, technique 13) becomes a real dolly through layers placed at increasing
depth. Keep the subject at the centre of every move; pan the Point of Interest rather than letting the subject drift.

## 4. Depth of field, parallax, light

- **Depth of field:** camera Depth of Field on; Aperture and Blur Level set the strength. Keep the subject in focus by
  expression on Focus Distance:
  `var s = thisComp.layer("Subject"); length(toWorld([0, 0, 0]), s.toWorld(s.anchorPoint));`
  Rack focus by changing which layer it names, or by keying it. Subtle is better: only the background and foreground
  should soften.
- **Parallax:** spread flat layers in Z (foreground −400, subject 0, background +800 to +2000). To keep a distant
  layer's apparent size, scale it by (zoom + z) / zoom.
- **Light:** an Ambient light (60–80%) plus one Point or Spot key light gives white objects soft form on a light stage
  (`color.md`, rule 5). For contact shadows: Casts Shadows on the light and on the object, Accepts Shadows on the
  floor or stage, Shadow Diffusion 20–60 px, Shadow Darkness 20–40%. Lights affect only 3D layers with Accepts Lights
  on.
- **Motion blur:** camera moves over 3D layers usually look better with motion blur on (`blur.md`).

## 5. Effects palette by job

All installed here (no third-party plugins apart from Mocha AE and Keylight). matchNames in brackets.

| Job | Effects |
|---|---|
| light and glow | Glow (`ADBE Glo2`), CC Light Rays, CC Light Burst 2.5, CC Light Sweep, Lens Flare (`ADBE Lens Flare`), Exposure (`ADBE Exposure2`), a radial Gradient Ramp in Add mode |
| depth and atmosphere | camera depth of field, Camera Lens Blur (`ADBE Camera Lens Blur`), Drop Shadow, Radial Shadow, Bevel Alpha |
| texture and finish | Add Grain (`VISINF Grain Implant`), Noise (`ADBE Noise2`), Fractal Noise, Turbulent Noise (`ADBE AIF Perlin Noise 3D`), Cell Pattern, Grid, 4-Color Gradient (`ADBE 4ColorGradient`) |
| distortion and lens | Displacement Map, Turbulent Displace, Bulge, CC Lens, Optics Compensation, Ripple, CC Ripple Pulse, Twirl, Polar Coordinates, Mirror, Motion Tile, CC Kaleida, Liquify |
| particles and simulation | CC Particle World, CC Particle Systems II, CC Star Burst, Shatter (`APC Shatter`), Card Dance (`APC CardDanceCam`), Card Wipe (`APC CardWipeCam`), Caustics (`APC Caustics`), Radio Waves (`APC Radio Waves`), CC Ball Action, CC Pixel Polly |
| time | Echo (`ADBE Echo`, trails), Posterize Time, Time Displacement, CC Wide Time, CC Force Motion Blur |
| transitions | Linear / Radial / Iris (`ADBE IRIS_WIPE`) / Gradient (`ADBE Gradient Wipe`) Wipe, Venetian Blinds, Block Dissolve, CC Light Wipe, CC Radial ScaleWipe, CC Scale Wipe, CC Glass Wipe, CC Grid Wipe, CC Twister |
| pseudo-3D | CC Sphere, CC Cylinder, CC Environment, CC Spotlight, Bevel Edges |
| music | Audio Spectrum (`ADBE AudSpect`), Audio Waveform (`ADBE AudWave`) |

`ae_effect` returns each effect's parameter list when it is added; read it instead of guessing parameter names.

## 6. Using effects with taste

1. **Every effect has a job**: light, depth, material, transition or energy. If it has none, leave it out.
2. **One family per moment.** Stack within a family (glow + rays + exposure for a light moment), change family when
   the scene changes.
3. **Effects follow motion and music.** A glow peaks on an accent, particles burst on a hit, focus racks as the subject
   arrives, light sweeps across a surface as it turns (`music.md`).
4. **Global finish on adjustment layers**: grain at 2–4%, a slight vignette, a soft overall glow; source shapes stay
   crisp vectors underneath.
5. **Blur and glow on precomps or adjustment layers**, not on shape layers (they clip at the layer bounds).
6. **Look at full resolution.** Glows, grain and particles change character at small preview sizes; check with
   `ae_render_frame` and a `region`.
