# Continuity: how one shape becomes the next

Contents:
1. The grammar (primitives, bridges, the rule of the shared silhouette)
2. An analysed chain: 98 seconds, one cut
3. The 18 techniques, each with an After Effects build
4. Building hand-offs in AE: the invisible swap, carrier nulls, path morphs
5. Planning a sequence: notation, checks, an original example
6. Failure modes and fixes

## 1. The grammar

A sequence is a chain of **states**. Between two states there is always a **bridge**: a moment where what is on
screen is simple enough to belong to both. The bridges are primitives:

| Primitive | Hands off to | Typical moves through it |
|---|---|---|
| **dot** | anything that starts small: lenses, buttons, pins, the centre of a ring | pop, split, orbit, travel |
| **disc** | round objects, buttons, dials, orbs, hearts (a heart collapses to a disc) | collapse, pop, zoom-through |
| **ring** | dials, progress/activity rings, check circles, toggle tracks, glyph outlines | draw-on, unravel, orbit trail |
| **line / bar** | anything thin: devices seen edge-on, cables, waveforms, baselines of text | rotate edge-on, fold, curl, split |
| **capsule (pill)** | toggles, camera modules, word marks in a box | stretch a dot into a pill, split a pill |
| **rounded rect** | cards, screens, icons, boxes, phones, watch faces | frame carry-over, layout morph |
| **arc** | partial rings, smiles, routes, hinges | trim, unwind into a stroke |

Rules that hold in every hand-off of the analysed piece:

- **The shared silhouette.** At the swap frame the outgoing and incoming shapes coincide: same position, same size,
  same colour. That is where layers are exchanged, and the eye cannot see the exchange.
- **The centre holds the eye.** The focal point stays near the middle of the frame. Things grow from the centre,
  collapse to it, orbit it, fan around it.
- **Simplify before you transform.** Detail fades out early in a move, so the object reaches the bridge as a plain
  silhouette. New detail arrives late, after the new silhouette is established.
- **Motion carries through.** The direction and speed of the outgoing move continue in the incoming one: a spin
  keeps spinning, a shrink keeps shrinking into the dot, a pull-back keeps pulling back while the new object forms.
- **Colour changes ride on motion.** Colour drains or floods while something else moves; it is never a beat of
  its own.

## 2. An analysed chain: 98 seconds, one cut

The study piece is a keynote opener (2019). It is listed here to show the grammar at work: it lists *what happens to
the shapes*. Do not rebuild its product drawings or logos; build your own subjects with the same moves. Times in
seconds; the technique numbers refer to section 3.

| Time | From → bridge → to | Techniques |
|---|---|---|
| 0.2–1.0 | full-frame white with a handwritten word → the white plate shrinks into a card → the card is the screen of a small computer whose body grows around it | 1 |
| 1.0–2.1 | computer shrinks; details fade → grey disc | 2 |
| 2.1–3.6 | disc splits into dots → dots orbit and lay down a ring → the ring thickens into a dial | 3, 4 |
| 3.4–6.3 | dial pops to full size (15% overshoot), gains a centre button and labels | 5 |
| 6.3–7.4 | dial shrinks; its centre button is now a black home button (rounded square inside a disc) | 2, 1 |
| 7.4–8.9 | the button's ring turns red, a dot appears → concentric arcs grow out of the ring: a fingerprint | 6 |
| 9.3–10.4 | the fingerprint's strokes fly apart and re-form as the corner brackets and features of a face-scan glyph | 6 |
| 10.4–11.6 | the glyph spins into a glassy blue orb → the orb thins into a blue ring → a check mark draws inside | 11, 7 |
| 11.6–12.7 | check shrinks to a dot → the dot is the knob of a toggle; the ring is its track | 8 |
| 12.7–13.9 | knob slides (UI ease) → the toggle splits into a white pill and a black pill, which tilt | 8, 3 |
| 13.9–15.4 | pills become coloured pieces in a ring on a dashed orbit → colourful computers revolving | 9, 4 |
| 15.4–16.1 | colour drains to white while they keep revolving | 10 |
| 16.1–19.7 | white computers on arms rotate edge-on into blades: a spinning star of lines | 11, 9 |
| 19.7–21.5 | blades collapse to a grey disc → zoom into a perforated texture → pull back: it is the face of a tower | 2, 13 |
| 21.5–22.5 | the tower turns to the front: a flat white square with a mark | 14 |
| 22.5–23.6 | the square tilts edge-on: a laptop seen side-on is a line with a coloured edge | 11 |
| 23.6–25.8 | the lid opens → coloured lids fan out → a spinning star of colours | 12, 9 |
| 25.8–28.6 | colour drains to white lines → lines multiply → four laptops in profile open, close, and merge into one line | 10, 3, 12 |
| 29.0–33.1 | the line splits → lines fold into a zigzag → compress → merge into one long hairline across the frame | 3, 12, 15 |
| 33.1–36.7 | the hairline curls into a cable with earbuds → it winds up, the buds drop into a case, the case closes | 15 |
| 36.7–38.4 | the case collapses onto a hairline → coloured blobs swell on the line like a waveform | 2, 15 |
| 38.4–40.8 | camera dives into a mesh around the orb → pulls back (1.5 s, log-scale) until the mesh is a ring | 13 |
| 40.8–41.4 | a dot runs round a thick black ring (0.6 s, accelerating) | 4 |
| 41.4–45.5 | the ring sits on a remote with two buttons → buttons slide and regroup; the panel darkens into a black box | 17 |
| 45.5–47.3 | the box squeezes into a pill → into a word mark | 17, 8 |
| 47.3–50.2 | a sparkle on the word mark swells into a white glow (0.37 s) → out of the glow pops a green disc (22% overshoot) | 16, 5 |
| 50.2–52.0 | a radar sweep turns inside the disc → the disc shrinks to a dot with an arc | 2 |
| 52.0–56.7 | dashed route lines curve around the dot → the dot is a lens; the lenses gather into a camera module on the corner of a phone outline | 15, 17 |
| 57.3–61.4 | white flash → a grid of outlined icons → the grid tilts into a corridor of frames → lands on one icon | 16, 17 |
| 61.4–65.0 | icon shrinks to a dot → the dot blooms into a flower of translucent circles → collapses to a dot | 2, 3 |
| 65.0–67.9 | a dark disc with a figure → figure changes → coloured dots at the top of the disc | 5, 17 |
| 67.9–69.7 | the dots draw out three rings → colour drains to one red ring | 6, 10 |
| 69.7–72.1 | the ring unwinds into a stroke that draws a heart outline → the heart fills | 6, 7 |
| 72.1–73.8 | heartbeat: shrink 0.77 s, grow 0.43 s → the heart becomes a red disc | 5, 2 |
| 73.8–75.6 | the disc turns edge-on: it is the red dot on the side of a watch | 11 |
| 75.6–79.7 | the watch turns; the camera pans along its band → other watches → a grid of fifteen → back to one | 14, 3 |
| 79.7–82.1 | the watch turns to the front; its coral face grows into the back of a coral phone | 14, 1 |
| 82.1–85.6 | the phone moves and shrinks → phones of every colour fan out from behind it (2.5 s, accelerating) | 9 |
| 85.6–87.4 | the phones turn edge-on: a radial burst of coloured lines | 11, 9 |
| 87.4–93.6 | the lines converge into a line of text → the second line pivots on the word both lines share | 15, 18 |
| 93.6–98.0 | hard cut to the logo: the only cut in the piece; with the text, the only long holds | — |

What the table shows:

- Every row starts from what the previous row ended with, except the last: the one cut is saved for the final
  statement, where an abrupt change means "this is the end".
- The dot, the disc, the ring and the line carry almost every hand-off. Detailed objects exist only between bridges.
- Big structural changes (a new scale, a new "world") come from the camera: zoom-through, pull-back, pan.
- The rhythm alternates: a burst of transformation, a brief settle on a readable state, the next burst (see
  `timing.md` for the numbers).

## 3. The 18 techniques

Each entry: what it is, where it happens in the study piece, why it works, and how to build it in After Effects.
Property paths use claude-ae's `Contents/Group 1/Contents/...` form (see `claude-ae.md`).

### 1. Frame carry-over (screen-in-screen)

**What:** the current frame (or the current object's face) becomes the screen or face of the next object.
**Seen:** 0.2–1.0 s (white plate → card → computer screen); 79.7–82.1 s (a watch face grows into a phone).
**Why it works:** the content the viewer is reading never leaves; only its context changes around it.
**AE:** a rounded-rect shape "Screen" whose Size is keyed from the comp size to the screen size (arrival ease:
influence out 10–20% / in 70–90%, 0.6–0.8 s). Parent the content (text, icon) to Screen. The new object's body is a
second rect behind Screen, keyed from exactly the screen size outward, starting a few frames *before* Screen
settles. Corner radius goes from 0 (full frame) to its final value. To go the other way (face → new object), scale the
face up while the rest of the old object fades fast (0.15–0.2 s) at the start of the move.

### 2. Collapse to a primitive

**What:** an object shrinks and simplifies into a dot, disc or line, which becomes the seed of the next idea.
**Seen:** computer → disc (1.0–2.1 s); case → hairline (36.7–37.3 s); icon → dot (61.4–62.0 s); heart → disc
(73.2–73.8 s).
**Why it works:** the viewer follows a shrinking thing to its centre; the moment it is a dot, anything can come out.
**AE:** two layers, the object and the primitive, under the same carrier null. Scale the object down with an
accelerating ease (influence out 50–80% / in 15–25%) so it *falls* into the bridge. Fade its inner details in the first
40% of the move. Round its corners on the way (rect Roundness → half its size) so a rounded rect lands as a disc. At the
swap frame the primitive takes over (see section 4).
**Timing:** 0.3–0.6 s into the swap; the next move starts on the swap frame with the momentum still on.

### 3. Split and multiply

**What:** one primitive divides into several, or one object becomes a grid or a fan of copies.
**Seen:** disc → dots (2.1–2.5 s); line → several lines (29.0 s); one watch → a grid of fifteen, revealed by a camera
pan (76.2–77.4 s); one phone → a fan (84.4–85.6 s).
**Why it works:** the copies start *inside* the original, so the eye sees one thing becoming many, not many
arriving.
**AE:** a Repeater on the shape group (Copies N, Offset 0) with its Transform Position (or Rotation) keyed from 0 to
the final spacing: every copy starts on top of the original and slides out with one shared ease. For grids, two
Repeaters (X then Y). If the copies need different content, use separate layers that start at the parent's position and
key only their offsets. Pair a grid reveal with a camera pull-back (scale the carrier null down) so the multiplication
also reads as "zooming out to see more".
**A bar that splits into dots, invisibly:** build the bar from N round-capped stroke segments laid end to end, each
overlapping the next by exactly one stroke width. Together they read as one seamless capsule, so the swap from a solid
bar is invisible; then pull the segments apart and shorten each to a dot.

### 4. Orbit with a trail

**What:** a dot travels round a centre and leaves a stroke behind it; the stroke becomes the next ring or arc.
**Seen:** dots lay down a ring (2.5–3.6 s); a dot runs round a black ring (40.8–41.4 s, 0.6 s, accelerating);
coloured pieces revolve on a dashed orbit (13.9–15.4 s).
**Why it works:** the trail is the path the eye just followed, made visible. The new ring is "drawn" by motion the
viewer already watched.
**AE:** a null "Orbit" at the centre with Rotation keyed; the dot is a small ellipse layer parented to Orbit, offset by
the radius. The ring is an ellipse with a Stroke and Trim Paths; drive Trim End from the orbit so the trail ends exactly
at the dot: `thisComp.layer("Orbit").transform.rotation / 3.6` (add a Trim Offset so 0% sits where the dot starts).
A stroke with Line Cap round reads as the dot's own trail. For a dashed orbit, set the Stroke's Dashes.
**Timing:** the orbit accelerates into the next event (measured: influence out 100% / in 25%, peak speed at 85%).

### 5. Pop from the centre (overshoot)

**What:** a small round element appears by scaling up past its size and settling back.
**Seen:** the dial pops (3.4–3.7 s, overshoot 15%); a green disc pops out of a white glow (50.0–50.6 s, overshoot
22%); the heartbeat (72.1–73.2 s: shrink 0.77 s, grow 0.43 s, no overshoot).
**Why it works:** the overshoot gives a tiny element the energy of a much larger move without travelling.
**AE:** Scale 0 → 100 in one segment with the measured curve `[0.22, 2.0, 0.39, 0.87]` (peaks about 21% over at a third
of the duration, settles in the remaining two thirds), or claude-ae's `pop` preset / `out_back` for a gentler 10%.
For spring physics use `ae_expression` template `spring`. Overshoot through speed only works on non-spatial
properties (Scale, Rotation, Opacity, sizes); for Position use three keys (target + overshoot, then target) or
separate dimensions.
**Timing:** 0.3–0.6 s. Use it on small, round things. A large object that overshoots looks bouncy, not elegant.

### 6. Stroke redraw: ring to glyph, unravel and re-form

**What:** the strokes of one icon pull back along their own paths and the same strokes draw the next icon.
**Seen:** a button's ring grows concentric arcs (7.4–8.9 s); those arcs fly apart and re-form as a face glyph
(9.3–10.4 s); coloured dots draw out three rings (67.9–68.5 s); a ring unwinds into a stroke that draws a heart
(69.7–71.5 s).
**Why it works:** stroke weight, colour and cap never change, so the viewer reads one continuous line that keeps
travelling and changes what it describes.
**AE:** one path per stroke, each with its own Trim Paths. *Unravel:* key Trim Start up to End (the stroke shrinks
along itself) while Trim Offset turns, accelerating. *Re-form:* the target strokes draw on (End 0 → 100, or Start
50 → 0 with End 50 → 100 to grow from the middle) with an arrival ease. Put each target path's first vertex where a
source stroke vanished, so the line appears to continue. Keep stroke width, colour and round caps identical. Stagger
strokes by 1–2 frames, inner to outer.
**Timing:** unravel 0.3–0.5 s accelerating; re-form 0.4–0.6 s with a long settle; overlap them by 3–6 frames.

### 7. Outline, then fill

**What:** a stroke draws the silhouette, then the fill flows in.
**Seen:** a check mark draws inside a ring (11.2–11.6 s); a heart outline draws, then fills (70.9–72.1 s).
**Why it works:** drawing explains the shape; filling gives it weight. The viewer watches it being made.
**AE:** Trim Paths trims every path above it in its group, and a trimmed path's fill is trimmed too. So put the stroke
and its Trim in one group and the fill in a second group with the same path (or a duplicate layer). Draw with Trim End
(arrival ease); bring the fill in by Opacity or by scaling it up from the centre, starting before the draw finishes.
A thick stroke growing in width until it covers the interior also reads as a flood.
**Timing:** draw 0.4–0.6 s; fill 0.2–0.3 s, overlapping the last third of the draw.

### 8. A primitive becomes a control

**What:** a primitive gains one element and becomes a functional thing: a dot plus a track is a toggle; a pill
divides into two pills.
**Seen:** a ring with a dot becomes a toggle (11.6–12.7 s); the knob slides (measured 1.07 s, influence 31% / 46%,
2% overshoot); the toggle splits into two pills (12.7–13.5 s); a box squeezes into a word mark (45.5–47.3 s).
**Why it works:** the viewer recognises a control by its behaviour (the slide) a split second after seeing its shape.
**AE:** capsules are rects whose Roundness is driven by `Math.min(size[0], size[1]) / 2` (see `claude-ae.md`); key
Size to stretch a disc into a pill. The knob slide uses `[0.22, -0.1, 0.68, 1.17]`: a slow start, a firm middle, a 2%
overshoot. UI-like moves are slower and more balanced than graphic moves (see `timing.md`).

### 9. Radial array and fan

**What:** copies arranged around a pivot that move as one system: spreading, spinning, collapsing.
**Seen:** coloured pieces revolve (13.9–15.4 s); white shapes rotate into a star (16.1–19.7 s); coloured lids fan out
and spin as a star (23.9–25.8 s); phones fan out from a stack (84.4–85.6 s; 2.5 s, accelerating into the next
transformation) and become a radial burst (85.6–87.4 s).
**Why it works:** one rig, one ease: the array reads as a single object with many parts, so it never looks busy.
**AE:** a Repeater with Copies N; key the Repeater's Transform Rotation from 0 (all copies stacked) to 360/N (evenly
spread) or to a small angle for a deck-of-cards fan; set the group's Anchor Point at the pivot. Spin the whole group
with its own Rotation. Between transformations a slow constant spin is one of the few places linear keys are right.

### 10. Colour drain and flood

**What:** colour leaves an object (to white or grey) or floods into it while it is moving.
**Seen:** colourful computers drain to white as they revolve (15.4–16.1 s); a colourful star drains to white lines
(25.8–26.1 s); three rings drain to a single red one (69.1–69.7 s).
**Why it works:** colour is meaning. Draining it says "this is about to become something else" without stopping.
**AE:** key the Fill/Stroke Color (in-out ease, 0.3–0.6 s), or put a white duplicate on top and fade it in, or add a
Tint/Fill effect with its amount keyed. Always overlap it with a move; a colour change on a still object reads as a
pause.

### 11. Rotate edge-on to a line

**What:** a flat object turns until it is seen edge-on and becomes a line; a line can open back into a face.
**Seen:** white shapes become blades (16.1–19.7 s); a square tilts into a laptop's edge (22.5–23.6 s); a red disc turns
edge-on into the side of a watch (73.8–75.6 s); phones turn into lines (85.6–87.4 s).
**Why it works:** the line is the most minimal shape there is, so it can be the edge of anything next.
**AE (flat, fast):** Scale X → 0 on the face with an accelerating ease, while a thin rect (the object's thickness)
keeps the edge visible as a line. **AE (3D):** a 3D layer with Y Rotation 0 → 90 and a swap to a line layer at 90°.
**Timing:** 0.3–0.5 s into the edge-on frame; the line keeps moving afterwards (spins, stretches, folds).

### 12. Hinge: open, close, fold

**What:** two parts joined at an edge open like a lid; a line folds into a zigzag; closing collapses back to a line.
**Seen:** a lid opens out of a line (23.3–24.0 s; the angle accelerates through a few degrees per frame, then whips
open); four profiles open and close into one line (26.8–28.6 s); lines fold into a zigzag (29.0–30.8 s).
**AE:** the lid is a rect with its Anchor Point on the hinge, parented to the base; key Rotation. For a perspective
read, scale the lid's face by cos(angle) (fake 3D) or use 3D layers and a camera. For folds, a path with vertices at
the folds and Path keyframes (same vertex count) from straight to zigzag.

### 13. Zoom-through to a texture, then pull back

**What:** the camera dives into a surface until its texture fills the frame, then pulls back to reveal the texture
belongs to something else.
**Seen:** a disc becomes a perforated texture that pulls back into a tower (19.7–21.5 s); an orb dives into a mesh that
pulls back into a ring (38.4–40.8 s; measured 1.5 s, influence 6% / 73% in log scale).
**Why it works:** at full-frame scale the texture has no context, so it can belong to anything.
**AE:** put the whole scene under a carrier null "CAM" and zoom it in **log scale** so the speed feels constant at
every magnification: add a Slider "Zoom (stops)" to CAM, key the slider with the ease, and set CAM's Scale expression
to `var s = 100 * Math.pow(2, effect("Zoom (stops)")("Slider")); [s, s];` (one stop doubles the size). The texture can
be a Repeater grid of discs, the Cell Pattern effect, or the Grid effect.

### 14. Turntable to the front

**What:** an object seen from the side turns to face the viewer and holds for a beat.
**Seen:** a tower (21.5–22.5 s); a watch (79.7–81.5 s).
**AE (flat):** the side panel scales X to 0 while the front panel scales X from 0, both anchored on their shared edge,
under one null that also drifts. **AE (3D):** 3D layers on a null with Y Rotation 90 → 0 and a camera. Arrival ease
with a long settle (influence out ~15% / in ~80%).

### 15. A line becomes a cable, a path, a waveform or text

**What:** the hairline is the most flexible primitive: it bends into a cable, runs a route, carries a waveform, or
closes into a line of letters.
**Seen:** a hairline curls into a cable with earbuds (33.1–34.3 s); a line carries swelling coloured blobs
(37.3–38.4 s); dashed routes curve around a dot (52.0–54.4 s); radial lines converge into a line of text (87.4–88.0 s).
**AE:** Path keyframes from a straight line to the curve (identical vertex counts and direction; add the extra vertices
to the straight version, spaced along it). Draw-on with Trim Paths. A waveform: Wiggle Paths or Zig Zag shape modifiers
with Size keyed up from 0, or ellipses along the line scaling on a Repeater. Text: a text layer whose characters scale
up from thin bars (a Scale animator with Y at 100 and X at 0, ranged) while the bars' layer fades.

### 16. Glow or flash bridge

**What:** a bright swell washes over the frame; the old content disappears under it and the new appears as it fades.
**Seen:** a sparkle swells into a white glow and a disc pops out of it (47.3–50.2 s; swell 0.37 s accelerating, fade
0.37 s balanced); a white flash opens the icon grid (57.3 s).
**Why it works:** brightness, not content, carries the eye. It changes everything on screen and still reads as
continuous. It often starts with a **switch-on**: at 47.87 s a black mark turns glowing white in a single frame, in
place, and the glow swells out of it. An instant change of state reads as an event, not a cut, as long as the shape
stays where it is.
**AE:** a solid with a radial Gradient Ramp (white at the centre → background at the edge) in Add or Screen mode, its
Opacity keyed up with an accelerating ease and down with a balanced one; or a Glow effect's intensity. Swap the
content at the brightest frame. For the switch-on, a hold key on the mark's Fill Color, then the glow.

### 17. Layout morph and perspective carousel

**What:** the parts of one object slide and resize into the parts of the next; or a flat grid tilts into perspective
and travels like a corridor, landing on one item.
**Seen:** a ring and buttons on a panel regroup into a box (41.4–45.5 s); an icon grid tilts into a corridor of frames
and lands on one icon (57.9–61.4 s).
**Why it works:** nothing disappears; every part has somewhere to go.
**AE:** one layer per part. Key Position and Size of each part to its new layout, staggered by 2–3 frames, the largest
part first. Change the backing panel's colour during the move. For the corridor: 3D layers and a camera moving in Z,
or fake it with the Transform effect's Skew and Scale.

### 18. Pivot on a shared element (type)

**What:** two lines of text that share a word change into each other around it: the shared word stays exactly where
it is while the other words fade out and new ones fade in around it.
**Seen:** the closing lines (90.4–91.1 s): the shared word keeps its contrast and sharpness unchanged throughout; the
change takes 0.7 s, the other words dip to about 25% contrast at the midpoint, and the new line is still centred.
**Why it works:** it is the shared silhouette applied to words: the eye stays on the word that does not move and reads
the new sentence around it.
**AE:** split each line into before / shared / after text layers; keep one shared-word layer through the change; fade
the outgoing parts (about 0.35 s, accelerating), then the incoming parts (about 0.35 s, arrival ease, a few px of blur
to 0). Position them with `sourceRectAtTime()` so the new line is centred (`typography-layout.md`, section 4).
The same idea works for any element two states share: a dot that stays while its context changes, a frame that stays
while its content changes.

## 4. Building hand-offs in AE

### The invisible swap

Most hand-offs are not single morphing shapes. They are **two layers that coincide for one frame**:

1. Animate A into the bridge state (a disc of 120 px, say, at the centre, white).
2. Build B so its first frame is that same bridge state.
3. Set A's out point and B's in point to the same frame (the swap frame). With claude-ae:
   `ae_edit_layer {layer: "A", out: 2.1}` and `ae_edit_layer {layer: "B", in: 2.1}`.
4. Check the swap frame and the frames on either side with `ae_render_frame` and a `region` around the bridge.
   Any difference in size, colour, edge or position shows up as a pop.

Motion blur makes the swap even smoother, as long as both layers have it on.

### Carrier nulls

Put the motion that should flow across a swap on a parent null that spans it: a "CAM" null for camera moves, a
"Carrier" null for a spin or travel. Swapping the children underneath does not interrupt the parent's ease, so the
momentum is continuous by construction. Key the children only for their own transformation (size, corners, colour).

### Path morphs

When the shape itself should morph (a line into a curve, a circle into a heart), key the path property
(`Contents/Group 1/Contents/Path 1/Path`) with ae_set_keyframes; values are `{points, inTangents, outTangents, closed}`.
Both keys need **the same number of vertices, the same starting vertex and the same direction**, or the shape turns
inside out. Add redundant vertices to the simpler shape. For a circle, use four vertices with tangents of 0.5523 ×
radius. Parametric shapes (Rectangle/Ellipse Path) cannot morph into each other; morph Size and Roundness instead
(a disc is a square rect with roundness = half its size; a pill is a wide one).

### Matching colour across the swap

Sample the bridge colour once and use it on both sides. If a colour drain finishes at the swap frame, the incoming
layer starts with the drained colour.

## 5. Planning a sequence

Write the chain before building, one line per beat:

```
<state> -[<technique>, <bridge>, <duration>, <ease>]-> <state>
```

Checks before building:

1. Does every beat start from something already on screen? If not, find the shared primitive.
2. Is the focal point near the centre at every swap?
3. Is there a camera move (zoom, pull-back, pan) for every change of scale or "world"?
4. Does each burst end on a readable state for at least 4–20 frames (longer only for text to read)?
5. Does each hand-off carry momentum (accelerate into the swap, continue after it)?
6. Are colour changes riding on moves?

A validated example: a fictional weather app intro, 9.5 s, built from this skill alone by a fresh session and checked
in AE (comp "Skill Test - Weather"; it passed all six checks, both swaps verified zoomed, eases within the measured
ranges):

```
(empty) -> coral dot                     [5 pop from the centre, 0.10-0.50 s, pop15]
dot -[grow; 3/9 eight rays slide out from behind the disc, disc, 0.43-1.30 s, dial/arrive;
      slow linear spin 18°/s; warm glow fades in]-> sun
sun -[2 rays retract + 10 coral -> charcoal, disc, 1.43-1.80 s, handoff]-> charcoal disc      (swap 1 at 1.80 s)
disc -[3 cloud lobes and base grow out of the disc, 1.80-2.53 s, arrive, 1-frame stagger;
       CAM log pull-back 0.32 -> 0 stops]-> rain cloud
cloud -[2 collapses into its base + charcoal -> blue, bar, 2.70-3.13 s, handoff]-> blue bar   (swap 2 at 3.13 s)
bar -[3 splits into 7 drops (round-capped segments), dots, 3.13-3.40 s, arrive]-> dots
dots -[fall and stretch into rain streaks, 2-frame stagger from the middle out; CAM tilts down and pushes in]-> rain
middle drop lands -[15 the impact point grows a horizon line both ways, arrive]-> drops squash to dots
  -> they grow into a 7-day rainfall chart (holds 0.4 s)
chart -[11 bars press back into the line, outside in, 5.23-5.70 s, handoff]-> one line
line -[15 shrinks to the word's width and turns near-black; the name rises out of the line, the subtitle hangs
       below it; CAM pushes in 0.08 -> 0.25 stops]-> app name + subtitle (readable 2.6 s)
-[2 the text sinks back into the line; the line shrinks to a dot and vanishes, in_expo]-> empty stage
```

Things this example taught: the sun needs a readable state before it collapses; every change of scale gets a camera
move; a camera that starts from rest needs a balanced ease (`timing.md`, rule 9); a falling drop lands *with* speed,
so its position is a group transform, not a path key.

## 6. Failure modes and fixes

| Symptom | Cause | Fix |
|---|---|---|
| A transition feels like a cut | the new object does not start from the old one's silhouette | find the bridge primitive; swap where they coincide |
| A visible pop at the swap | size, colour or edge mismatch on the swap frame | render the swap frame zoomed; match exactly |
| Busy, cluttered moments | copies moving with different eases or timings | make arrays one rig (Repeater) with one ease |
| Motion stops and starts | every move settles to rest before the next | accelerate into hand-offs; overlap the next move by 3–6 frames |
| Zoom feels like it slows down or speeds up | Scale keyed linearly in percent | key zoom in log scale (stops) |
| The eye loses the subject | the focal point jumps around the frame | keep the action near the centre; move the camera instead |
| Overshoot looks cheap | overshoot on large objects or on everything | reserve it for small round elements, 15–22% |
| A colour change reads as a pause | colour keyed on a still object | ride it on a move |
