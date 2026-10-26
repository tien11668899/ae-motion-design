# Driving After Effects with claude-ae

claude-ae is an MCP server (`C:\Users\user\source\claude-ae`) that talks to a bridge panel inside After Effects 2023.
Every mutating call is one undo step and all-or-nothing. Property paths, matchNames and parameter names below were
checked on AE 23.0.

Contents:
1. Start-up
2. Tool map
3. Building blocks, with calls
4. Shape modifiers and effects (matchNames)
5. Expressions
6. Keyframes
7. Looking at the result
8. ae_eval
9. Gotchas
10. Output, and the CLI fallback

## 1. Start-up

1. `ae_status`. If it reports OFFLINE: After Effects is closed, the panel is not open (Window > Claude Bridge.jsx,
   needed after every AE start), or AE is sitting on a modal dialog. Tell the user which; don't retry in a loop.
2. `ae_style_guide`. The default style is dark and editorial (bg `#0E0E12`, Bahnschrift + Microsoft JhengHei,
   arrivals `out_expo` 0.7 s, large display type). It is the general default. For keynote-style continuous motion, or
   whenever the user wants the look this skill measured, the skill's look wins (SKILL.md, "When rules disagree"):
   light radial stage, motion blur off on flat graphics, quiet type. Tell the user which one you follow.
3. Work in one comp per sequence, 1920×1080, 30 fps. `ae_create_comp` and `ae_add_layer` switch motion blur on; turn it
   off for the crisp flat look (`blur.md`).

## 2. Tool map

| Need | Tool |
|---|---|
| project, comps, layers, property paths | `ae_project`, `ae_comp_info`, `ae_layer_props` (every node lists its usable `path`), `ae_list` (effects, fonts, eases, presets, output templates) |
| create | `ae_create_comp`, `ae_add_layer` (text, shape, solid, adjustment, null, camera, light, footage, comp), `ae_import` |
| change a layer | `ae_edit_layer` (name, in/out/start/stretch, parent, 3D, motion blur, blend, track matte, moveTo, duplicate, precompose, delete) |
| set values | `ae_set_props` (paths, colours, text) |
| animate | `ae_set_keyframes` (exact eases), `ae_animate` (tuned presets: fade, slide_*, scale, pop, blur, wipe; text: type_on, cascade, tracking), `ae_expression` (spring, wiggle, loop, time, or source) |
| effects | `ae_effect` (add by matchName, or edit by index; params by name) |
| look | `ae_render_frame` (with `region` to zoom), `ae_contact_sheet`, `ae_motion_curve` |
| measure / match | `ae_probe`, `ae_scenes`, `ae_compare`, `ae_trace` |
| deliver | `ae_render_video`, `ae_save`, `ae_open_comp` |
| fix | `ae_undo` (your own last step), `ae_reload_bridge` (after editing the JSX) |
| anything else | `ae_eval` (ExtendScript) |

## 3. Building blocks, with calls

**The stage.** A light radial background keeps both colour and white objects readable (the study piece: grey 237 at
the centre to 208 at a radius of 1250 px).

```
ae_add_layer {kind: "solid", name: "BG", color: "#E6E6E6"}
ae_effect {layer: "BG", effect: "ADBE Ramp", params: {"Start of Ramp": [960, 540], "Start Color": "#ECECEC",
           "End of Ramp": [960, 1790], "End Color": "#D0D0D0", "Ramp Shape": 2}}      // 2 = radial
```

**The camera.** A null at the comp centre; everything else is parented to it. Scale it for zooms and pull-backs (in
log scale, see section 5).

- The bridge creates nulls with their Anchor Point at [0, 0]. Set CAM's anchor to [960, 540] (Position stays
  [960, 540]); then a child's position is simply its comp position.
- **Pan by keying CAM's Anchor Point**, the point of the scene that sits at the frame centre. Position is also the
  zoom pivot: moving it moves the zoom centre off the middle of the frame.
- Parent layers *before* you animate CAM: parenting compensates for the parent's transform at the comp's current time,
  and a parent at zero scale breaks it. To add a layer after CAM is animated, see section 9.

```
ae_add_layer {kind: "null", name: "CAM", position: [960, 540]}
ae_set_props {layer: "CAM", props: {"anchor": [960, 540]}}
ae_add_layer {kind: "shape", name: "Dot", parent: "CAM", position: [960, 540], shapes: [{type: "ellipse", size: [40, 40], fill: "#FFFFFF"}]}
```

**Primitives.** Each `shapes` entry becomes its own group ("Group 1", "Group 2", ... unless you give `name`). Rects and
ellipses are centred on the layer origin; paths are placed by their bounds.

```
ring    {type: "ellipse", size: [400, 400], stroke: "#1A1A1A", strokeWidth: 12, lineCap: "round", trim: {start: 0, end: 0}}
capsule {type: "rect", size: [120, 120], roundness: 60, fill: "#FFFFFF"}
line    {type: "path", points: [[-300, 0], [300, 0]], closed: false, stroke: "#FFFFFF", strokeWidth: 6, lineCap: "round"}
```

A stroke-only shape gets no fill. Put Trim Paths (`trim`) on strokes; it trims every path above it in the group,
fills included.

**Property paths** inside a shape layer (display names, verified):

```
Contents/Group 1/Contents/Ellipse Path 1/Size
Contents/Group 1/Contents/Rectangle Path 1/Size          .../Roundness   .../Position
Contents/Group 1/Contents/Path 1/Path
Contents/Group 1/Contents/Trim Paths 1/Start             .../End         .../Offset
Contents/Group 1/Contents/Stroke 1/Stroke Width          .../Color
Contents/Group 1/Contents/Fill 1/Color                   .../Opacity
Contents/Group 1/Contents/Repeater 1/Copies              .../Transform/Rotation   .../Transform/Position
Contents/Group 1/Transform/Rotation                      .../Position  .../Scale  .../Opacity
```

**Capsules.** A rect's literal Roundness above half its size renders as a rounded *square* in AE 2023. Drive it:

```
ae_expression {layer: "Pill", prop: "Contents/Group 1/Contents/Rectangle Path 1/Roundness",
  expression: "var s = content(\"Group 1\").content(\"Rectangle Path 1\").size; Math.min(s[0], s[1]) / 2;"}
```

Then key `.../Rectangle Path 1/Size` from [120, 120] (a disc) to [360, 120] (a pill).

**Path morphs.** Values are `{points, inTangents, outTangents, closed}` (tangents relative to their vertex, default
0). Same vertex count, same start vertex, same direction on both keys. A circle of radius r is four vertices with
tangents of 0.5523 r. Path keys ease through influence only, so they always start and arrive at rest: use rest-to-rest
eases (`[out, 0, 1 - in, 1]`), add a key for an overshoot, and when a shape must *land with speed*, move it with its
group's Transform Position (which can carry speed) and let the Path change only the outline.

```
ae_set_keyframes {layer: "Line", prop: "Contents/Group 1/Contents/Path 1/Path", ease: [0.12, 0, 0.2, 1], keys: [
  {t: 1.0, v: {points: [[-300, 0], [0, 0], [300, 0]], closed: false}},
  {t: 1.6, v: {points: [[-300, 0], [0, -200], [300, 0]], inTangents: [[0, 0], [-150, 0], [0, 0]],
               outTangents: [[0, 0], [150, 0], [0, 0]], closed: false}}]}
```

**Draw-on.**

```
ae_set_keyframes {layer: "Ring", prop: "Contents/Group 1/Contents/Trim Paths 1/End",
  keys: [{t: 0, v: 0}, {t: 0.6, v: 100}], ease: [0.12, 0, 0.2, 1]}
```

**Repeater** (no dedicated tool; add it with ae_eval, then key it with ae_set_keyframes). It repeats everything above
it in the group. Copies rotate about the Repeater's Anchor Point, so move the *path* off the group origin (e.g. the
rect's `Position` to [0, -200]) for a radial array, or to [0, -h/2] for a deck-of-cards fan pivoting at its base.

```
ae_eval {script: "var l = CB.findLayer(CB.findComp('Intro'), 'Blades');
  var g = l.property('ADBE Root Vectors Group').property(1).property('ADBE Vectors Group');
  var r = g.addProperty('ADBE Vector Filter - Repeater');
  r.property('ADBE Vector Repeater Copies').setValue(6);
  r.property('ADBE Vector Repeater Transform').property('ADBE Vector Repeater Position').setValue([0, 0]);
  r.property('ADBE Vector Repeater Transform').property('ADBE Vector Repeater Rotation').setValue(0);
  return r.name;"}
ae_set_keyframes {layer: "Blades", prop: "Contents/Group 1/Contents/Repeater 1/Transform/Rotation",
  keys: [{t: 2.0, v: 0}, {t: 2.6, v: 60}], ease: [0.12, 0, 0.2, 1]}
```

**Swaps.** `ae_edit_layer {layer: "A", out: 2.1}` and `ae_edit_layer {layer: "B", in: 2.1}`, then check frames 2.067,
2.1 and 2.133 with `ae_render_frame` and a `region`.

**Mattes and blending.** `ae_edit_layer {layer: "Glass FX", trackMatte: {layer: "Glass Matte", type: "alpha"}}`
(types: alpha, alpha_inverted, luma, luma_inverted). In AE 23 a matte can be any layer and is hidden automatically.
Blend modes: normal, add, screen, multiply, overlay, soft_light, hard_light, color_dodge, lighten, darken, difference.
An adjustment layer (`kind: "adjustment"`, or a shape layer with `adjustment: true`) applies its effects to everything
below it, inside its own shape when it is a shape layer.

**Text.** `ae_add_layer {kind: "text", text: "...", font: "Bahnschrift-SemiBold", fontSize: 96}`; check the returned
warning for font substitution (AE 2023 has no font-list API). Verified PostScript names on this PC: `SFPro-Regular`,
`SFPro-Medium`, `SFPro-Semibold`, `SFPro-Bold`, `.PingFang-TC-Medium`, `.PingFang-SC-Medium` (leading dot),
`MicrosoftJhengHeiRegular` / `Bold` / `Light`, `Bahnschrift-SemiBold`, `ArialMT`; Segoe UI is invisible to AE. Text
animators need `addProperty` on every property before setting it (use ae_eval or the text presets in ae_animate); the
matchNames and a recipe are in `typography-layout.md`, section 4.

**Motion blur.** Both the comp switch (`comp.motionBlur`) and the layer switch (`ae_edit_layer {motionBlur}`); shutter
settings through ae_eval (`comp.shutterAngle`, `comp.shutterPhase`, `comp.motionBlurSamplesPerFrame`,
`comp.motionBlurAdaptiveSampleLimit`). claude-ae turns motion blur on for new comps and layers; for a crisp flat look
switch it off (`blur.md`).

## 4. Shape modifiers and effects (matchNames)

Shape modifiers (add to a group's `ADBE Vectors Group` with ae_eval):

| Modifier | matchName | Properties |
|---|---|---|
| Repeater | `ADBE Vector Filter - Repeater` | Copies, Offset, Composite, Transform: Anchor Point, Position, Scale, Rotation, Start Opacity, End Opacity |
| Trim Paths | `ADBE Vector Filter - Trim` | Start, End, Offset, Trim Multiple Shapes |
| Wiggle Paths | `ADBE Vector Filter - Roughen` | Size, Detail, Points, Wiggles/Second |
| Wiggle Transform | `ADBE Vector Filter - Wiggler` | Wiggles/Second, Transform: Anchor Point, Position, Scale, Rotation |
| Zig Zag | `ADBE Vector Filter - Zigzag` | Size, Ridges per segment, Points |
| Offset Paths | `ADBE Vector Filter - Offset` | Amount, Line Join, Copies, Copy Offset |
| Merge Paths | `ADBE Vector Filter - Merge` | Mode |
| Round Corners | `ADBE Vector Filter - RC` | Radius |
| Pucker & Bloat | `ADBE Vector Filter - PB` | Amount |
| Twist | `ADBE Vector Filter - Twist` | Angle, Center |

Effects (add with `ae_effect {layer, effect: "<matchName>", params: {...}}`):

| Purpose | Effect: matchName |
|---|---|
| blur | Gaussian Blur: `ADBE Gaussian Blur 2` (Blurriness, Blur Dimensions, Repeat Edge Pixels); Fast Box Blur: `ADBE Box Blur2` (Blur Radius, Iterations, Repeat Edge Pixels); Directional Blur: `ADBE Motion Blur`; Radial Blur: `ADBE Radial Blur`; CC Radial Fast Blur: `CC Radial Fast Blur` (zoom-through streaks); Camera Lens Blur: `ADBE Camera Lens Blur`; Compound Blur: `ADBE Compound Blur`; CC Force Motion Blur: `CC Force Motion Blur`; Pixel Motion Blur: `ADBE OFMotionBlur` (the full list is in `blur.md`) |
| light | Glow: `ADBE Glo2` (Glow Threshold, Glow Radius, Glow Intensity, ...); CC Light Sweep: `CC Light Sweep` (Center, Direction, Shape, Width, Sweep Intensity, Edge Intensity, Edge Thickness, Light Color, Light Reception); Exposure: `ADBE Exposure2` |
| colour | Gradient Ramp: `ADBE Ramp` (Start of Ramp, Start Color, End of Ramp, End Color, Ramp Shape, Ramp Scatter, Blend With Original); Fill: `ADBE Fill`; Tint: `ADBE Tint`; Hue/Saturation: `ADBE HUE SATURATION`; Vibrance: `ADBE Vibrance`; Invert: `ADBE Invert` |
| mattes, thresholds | Levels (Individual Controls): `ADBE Pro Levels2` (Alpha Input Black, Alpha Input White, ...); Levels: `ADBE Easy Levels2`; Simple Choker: `ADBE Simple Choker`; Set Matte: `ADBE Set Matte3` |
| distortion | Transform: `ADBE Geometry2` (Anchor Point, Position, Uniform Scale, Scale Height, Scale Width, Skew, Skew Axis, Rotation, Opacity); CC Glass: `CC Glass` (Bump Map, Property, Softness, Height, Displacement, Light Height, Ambient, Diffuse, Specular, Roughness, Metal); Displacement Map: `ADBE Displacement Map` (Displacement Map Layer, Use For Horizontal/Vertical Displacement, Max Horizontal/Vertical Displacement); Turbulent Displace: `ADBE Turbulent Displace`; Bulge: `ADBE Bulge`; CC Sphere: `CC Sphere`; CC Bend It: `CC Bend It`; Optics Compensation: `ADBE Optics Compensation` |
| reveals | Linear Wipe: `ADBE Linear Wipe`; Radial Wipe: `ADBE Radial Wipe`; Venetian Blinds: `ADBE Venetian Blinds`; Stroke: `ADBE Stroke`; Write-on: `ADBE Write-on`; Scribble: `ADBE Scribble Fill` |
| textures | Grid: `ADBE Grid`; Cell Pattern: `ADBE Cell Pattern`; Fractal Noise: `ADBE Fractal Noise` |
| other | Drop Shadow: `ADBE Drop Shadow`; Echo: `ADBE Echo`; Slider Control: `ADBE Slider Control`; Point Control: `ADBE Point Control` |

Popup parameters take their 1-based item number (Ramp Shape 2 = radial).

## 5. Expressions

Templates via `ae_expression {layer, prop, template, options}`:

- `spring {freq, damping, min}`: each key change becomes a physical spring step. Good for arrivals; for exits to 0 use
  keys with `in_back` (a spring rebounds through 0). `min: 0` keeps scale/opacity from going negative.
- `wiggle {freq, amp}`, `loop {type: cycle | pingpong | offset | continue}`, `time {speed}`.

Snippets that keep continuity (write expressions in plain ES3 style: `var`, no arrow functions):

```
// Capsule: roundness = half the short side
var s = content("Group 1").content("Rectangle Path 1").size; Math.min(s[0], s[1]) / 2;

// Log-scale zoom on CAM.Scale; key the slider in stops (1 stop = 2x) with the camera ease
var s = 100 * Math.pow(2, effect("Zoom (stops)")("Slider")); [s, s];

// Trail that ends at an orbiting dot (on Trim Paths End; set Trim Offset so 0% is the start angle)
thisComp.layer("Orbit").transform.rotation / 3.6;

// Follow with a delay: overlap and drag between siblings
thisComp.layer("Leader").transform.position.valueAtTime(time - 0.08);

// Fake 3D turn: width follows the cosine of an angle slider
var a = effect("Turn")("Slider"); [value[0] * Math.cos(degreesToRadians(a)), value[1]];

// Inertial settle after each key (amp 0.02, freq 2, decay 6)
var amp = 0.02, freq = 2, decay = 6, n = 0;
if (numKeys > 0) { n = nearestKey(time).index; if (key(n).time > time) n--; }
if (n > 0) { var t = time - key(n).time, v = velocityAtTime(key(n).time - thisComp.frameDuration / 10);
  value + v * amp * Math.sin(freq * t * 2 * Math.PI) / Math.exp(decay * t); } else { value; }
```

Add sliders with `ae_effect {layer: "CAM", effect: "ADBE Slider Control", name: "Zoom (stops)"}`. ae_expression
returns any expression error; read it.

## 6. Keyframes

`ae_set_keyframes {layer, prop, keys: [{t, v, ease?}], ease?, clear?, keepBetween?}`

- Each segment uses the `ease` of its first key, else the call's `ease` (default `in_out`).
- Existing keys strictly between the first and last new key are removed (`keepBetween: true` keeps them);
  `clear: true` removes all keys first.
- Values: numbers, arrays, `#RRGGBB` colours, shape objects.
- `ease: "hold"` makes a step. Prefer in/out points for swaps; hold keys are for values that jump while visible.
- Eases: named (`timing.md` lists them with their curves) or `[x1, y1, x2, y2]`, converted exactly into AE speed and
  influence. The measured eases and copy-paste presets are in `timing.md`.

`ae_animate` presets are good for UI-ish arrivals and text (type_on, cascade, tracking); `stagger` offsets several
layers. For continuity work, explicit keys with measured eases are usually better.

## 7. Looking at the result

- `ae_contact_sheet {start, end, count, columns, cellWidth}` (max 48 frames): 12–24 frames over one beat to judge a
  transformation; 40 frames over 20 s to judge the flow.
- `ae_render_frame {time, region: [x, y, w, h]}`: zoom up to 4×; use it on every swap frame and on edges.
- `ae_motion_curve {layer, prop, start, end}`: value and speed per frame plus a reading (abrupt start/stop, linear,
  overshoot %, peak speed). Use it on every eased property you care about.
- `ae_probe`: colours at points, or the foreground's bbox, centre, size and area over several times (`blobs` for
  per-element tracking). It measures timing from pixels, for your build or a reference.
- `ae_compare {a, b, start, end, count}`: two comps side by side with a difference image and per-row numbers.
- `ae_scenes {comp, step}`: holds, motion and cut-like jumps over a comp. Its change is measured as a share of the
  frame, so on a light stage that is ~97% empty the default `hold: 0.15` calls small moves holds; use `hold: 0.01`.

Critique like a senior motion designer: where does the eye go at each swap, is there a pop, does each arrival settle,
does each hand-off carry speed, is anything moving that has no reason to? Two or three build-look-fix rounds are normal.

## 8. ae_eval

Runs ExtendScript (ES3) as one undo step. A body containing `return` runs as a function; otherwise the last
expression's value is returned. Helpers on `CB`: `findComp(ref)` (throws if missing), `findLayer(comp, ref)`,
`resolveProp(layer, path)`, `setValue(prop, value, time)`, `easeSegment(prop, keyA, keyB, ease)`, `toColor(hex)`,
`layerSummary(layer, comp)`.

ES3 means `var` only, no `let`/`const`, arrow functions, template strings or `JSON` assumptions; avoid reserved words
such as `long`. `comp.saveFrameToPng(time, file)` returns before the file exists, so wait for it.

## 9. Gotchas (AE 2023 and the bridge)

- The bridge panel must be opened after every AE start; `AfterFX.exe -r` does not reach a running AE on this PC.
- Segoe UI is invisible to AE here (it becomes Times New Roman). Defaults are Bahnschrift and Microsoft JhengHei.
- `ADBE Gaussian Blur 2` defaults to Repeat Edge Pixels **on**, which facets blurred mattes; set it false.
- A blur on a shape layer clips at the layer's bounds. Blur the composite (adjustment layer or precomp).
- Rect Roundness above half the size renders as a rounded square; use the capsule expression.
- Parent first, then animate the parent. Once CAM (or any parent) is animated, `ae_add_layer {parent}` compensates
  for the parent's transform at the current time and the new layer lands in the wrong place and scale (seen: moved to
  y 833 at 96%). Instead parent with `layer.setParentWithJump(parent)` in ae_eval and set the child's position and
  scale in the parent's space, then check with `ae_comp_info` or a render.
- Layers past the comp's end silently don't render; extend the comp and the layers' out points together.
- Layers from `ae_add_layer` and `ae_trace` come with motion blur on.
- `valueAtTime` right after `setValuesAtTimes` in one eval can throw "invalid numeric result"; split the calls. Reading
  a just-added text animator property's value throws the same error.
- A shape Gradient Fill's Colors cannot be set by script in AE 2023 (the call errors and the whole eval rolls back);
  use Gradient Ramp on a matted solid.
- An unknown font name raises no error: AE keeps the previous font or uses Times New Roman. Compare what you read back.
- In ae_eval, `addProperty` invalidates references you already hold to sibling properties ("Object is invalid"). Add
  everything first, then fetch the properties again by path or matchName before setting them.
- A text selector's Amount is `ADBE Text Range Advanced/ADBE Text Selector Max Amount`, not a direct child of the
  selector (asking the selector for it returns null and the eval rolls back).
- `setParentWithJump` keeps the child's values and reads them in the parent's space, so a parent null leaves its
  children in place only when its Anchor Point equals its Position (both [960, 540], like CAM).
- A track matte cannot be switched off over time. To reveal a layer inside a growing shape (glass growing into a
  window), duplicate the layer, matte only the duplicate with the shape's silhouette, and cut to the unmatted original
  on the frame the shape covers it completely.
- `layers.addCamera` leaves the camera at [0, 0, −zoom] (an oblique view of the centre). `ae_add_layer {kind: "camera"}`
  corrects this since 2026-10-26; cameras made with ae_eval need their Position set to [centre x, centre y, −zoom].
- Use the `ADBE Advanced 3d` renderer (Classic 3D, the default); `ADBE Standard 3d` rendered empty frames here
  (`camera-effects.md`).
- Menu commands run from scripts: `app.executeCommand(app.findMenuCommandId("Convert Audio to Keyframes"))` works with
  the audio layer selected and its comp open.
- AE 23 cannot open .aep files saved by 24.x; `tools\aep-dump.ps1` reads their layers, effects and expressions.
- The JSX bridge must stay ASCII-only; after editing it, `ae_reload_bridge`.
- Rebuilding the server while another session runs it: rename `claude-ae.exe`/`.dll` first, build into
  `server\dist`, then `--selftest` (ALL PASS).

## 10. Output, and the CLI fallback

`ae_render_video` renders H.264 at the highest bitrate available; if it reports USER_STOPPED mid-script, check the
file size before assuming it failed. For the audio alone (to measure music, `music.md`), pass
`template: "AIFF 48kHz"` and a `.aif` path inside the project folder; 107 s renders in about 2 s. `ae_save` saves the project; the last saved project is backed up before a
session's first change.

When the ae_* tools are not loaded in a session, call the server directly (images land in `.spool\cli\`):

```powershell
[Console]::OutputEncoding = New-Object Text.UTF8Encoding $false
'{"comp":"Intro","start":0,"end":4,"count":24}' | & 'C:\Users\user\source\claude-ae\server\dist\claude-ae.exe' --call ae_contact_sheet
```

Never pipe it into `Select-Object -First`: that kills the exe mid-call.
