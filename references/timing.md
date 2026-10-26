# Timing: measured rhythm and easing

Every number here was measured from the study piece (a 98-second keynote opener, 30 fps) with
`scripts/measure.ps1`. See `measuring.md` for how.

Contents:
1. The rhythm of the whole piece
2. Ten measured moves
3. Rules the measurements imply
4. Easing in After Effects (influence, speed, the conversion)
5. Carrying momentum across a key
6. Holds, reading time, stagger, motion blur
7. Copy-paste eases for ae_set_keyframes

## 1. The rhythm of the whole piece

Motion energy (the largest per-block change between consecutive frames) over frames 64–2953:

| Measure | Value |
|---|---|
| Time in motion | **88%** |
| Motion runs | 13; median **162 frames (5.4 s)**, quartiles 33 / 311 frames, longest 583 frames (19.4 s) |
| Holds | 13; median **9 frames (0.3 s)**, quartiles 4 / 20 frames |
| Holds longer than 15 frames | only three: 0.7 s on a check mark (a "done" moment), 1.8 s on the first line of text, 7.1 s on the second line and the logo at the end |
| Hard cuts | one, at 93.57 s, from the last line of text to the logo. One other single-frame jump (47.87 s) is not a cut: a mark switches from black to glowing white in place, and a glow swells from it. Every other large frame-to-frame change is fast motion (spins, orbits, zooms) |
| Pulse | a burst of transformation every 3–6 s, each ending in a brief settle on a readable state |

What it means: the rhythm comes from fast and slow **inside continuous motion**, not from stopping. A sequence that
holds still between beats feels like slides; this one never stops, but it settles often enough to be read.

## 2. Ten measured moves

AE influence values assume both keys at rest (speed 0), which is how the fits were made; the cubic-bezier column is
the same curve in CSS form, ready for `ae_set_keyframes`.

| Move | Duration | Influence out / in | cubic-bezier | Peak speed at | Reading |
|---|---|---|---|---|---|
| Heart grows (scale) | 0.43 s | 10% / 91% | `[0.10, 0, 0.09, 1]` | 7% | arrival |
| Heart shrinks (scale) | 0.77 s | 16% / 68% | `[0.16, 0, 0.32, 1]` | 18% | arrival |
| Camera pull-back (log scale) | 1.50 s | 6% / 73% | `[0.06, 0, 0.27, 1]` | 7% | arrival (camera) |
| Dial grows from small (scale) | 0.60 s | 61% / 88% | `[0.61, 0, 0.12, 1]` | 38% | in and out, long settle |
| Disc pops out of a glow (scale) | 0.60 s | — | `[0.22, 2.01, 0.39, 0.87]` | start | **overshoot 22%** |
| Dial pops (scale) | 0.33 s | — | — | 28% | **overshoot 15%** |
| Toggle knob slides (x) | 1.07 s | 31% / 46% | `[0.22, -0.10, 0.68, 1.17]` | 40% | UI: balanced, 2% overshoot |
| Phone fan turns (rotation) | 2.47 s | 48% / 14% | `[0.48, 0, 0.86, 1]` | 77% | hand-off: accelerates |
| Dot orbits a ring (angle) | 0.60 s | 100% / 25% | `[1.00, 0, 0.75, 1]` | 85% | hand-off |
| Glow swells (brightness) | 0.37 s | 79% / 18% | `[0.79, 0, 0.82, 1]` | 84% | hand-off |
| Glow fades (brightness) | 0.37 s | 19% / 14% | `[0.19, 0, 0.86, 1]` | 57% | balanced, near-linear middle |

## 3. Rules the measurements imply

1. **Arrivals leave fast and settle long.** Influence out 6–16%, in 68–91%; the peak speed comes in the first 7–18%
   of the move. Objects take 0.4–0.8 s; a camera move 1.2–1.6 s. The long settle *is* the hold: by the time the
   object visibly stops, the eye has already read it.
2. **Hand-offs accelerate into the next transformation.** Influence out 48–100%, in 14–25%; the peak speed comes at
   77–85%. Whatever happens next starts on that frame and inherits the speed. Durations range from 0.37 s (light) and
   0.6 s (a small orbit) to 2.5 s (a big fan).
3. **Pops overshoot 15–22% within 0.3–0.6 s, on small round elements only.** The peak comes about a third of the
   way in; the rest of the time is the settle.
4. **UI behaviours are slower and more balanced** (about 1 s, influence ~30% / ~45%, at most 2% overshoot). The
   realism tells the viewer "this is a control", in contrast to the graphic moves around it.
5. **Light is quick.** A glow swells in 0.37 s, accelerating, and fades in 0.37 s, balanced. Swap content at the
   brightest frame.
6. **Something that is both leaving small and arriving big** (a dial growing from a dot) eases at both ends: out ~60%,
   in ~90%.
7. **Scale and zoom live in log space.** The camera pull-back fits cleanly only in log scale; zoom in "stops"
   (see `continuity.md`, technique 13) or it seems to slow down as it shrinks.
8. **Constant drifts are linear** (a slow spin while an array waits) and slow, about 30°/s or less. The next eased
   move takes over from that speed.
9. **The fast-start camera ease belongs to hand-offs.** `[0.06, 0, 0.27, 1]` leaves at full speed, which is right
   when the camera move continues a transformation. A camera that starts from rest while the subject is still would
   yank the still subject away; give it a balanced start (about 45% / 75%, `[0.45, 0, 0.25, 1]`), or start it on the
   same frame as the subject's own move.

## 4. Easing in After Effects

An AE key has, for each side, a **speed** (units per second) and an **influence** (0.1–100% of the time to the
neighbouring key). Between key A and key B (duration dt, change Δ) the value follows a cubic Bézier in time and value,
with handles at (influence × dt, speed × influence × dt) from each key.

A CSS cubic-bezier `[x1, y1, x2, y2]` therefore maps exactly to:

- A outgoing: influence = x1, speed = y1 · Δ / (x1 · dt)
- B incoming: influence = 1 − x2, speed = (1 − y2) · Δ / ((1 − x2) · dt)

`ae_set_keyframes` does this conversion. Keys at rest are `[out, 0, 1 − in, 1]`, which is the form of the
measurements. AE's own Easy Ease is 33% / 33% (`[0.33, 0, 0.67, 1]`), soft and symmetric, rarely the right choice.

claude-ae's named eases and what they are for:

| Name | cubic-bezier | Use |
|---|---|---|
| `out_expo` | `[0.16, 1, 0.3, 1]` | snappy arrivals; starts at 6× average speed (harder than the study piece's arrivals) |
| `out_quint` | `[0.22, 1, 0.36, 1]` | arrivals, a little softer |
| `out` | `[0.25, 1, 0.5, 1]` | gentle arrivals |
| `in_out_expo` | `[0.87, 0, 0.13, 1]` | dramatic moves between two rest states |
| `in_out` | `[0.65, 0, 0.35, 1]` | ordinary moves between rest states |
| `in_expo` | `[0.7, 0, 0.84, 0]` | exits; **ends at full speed**, so use it where the next layer continues the motion |
| `in` | `[0.5, 0, 0.75, 0]` | softer exits |
| `out_back` | `[0.34, 1.56, 0.64, 1]` | about 10% overshoot |
| `in_back` | `[0.36, 0, 0.66, -0.56]` | wind-up exits; use it, not a spring, for scaling to 0 |
| `ease` | `[0.25, 0.1, 0.25, 1]` | the CSS default |
| `linear`, `hold` | — | drifts, type-on; hold keys for swaps |

Caveats:

- **Position is spatial**: its speed is along the motion path and cannot be negative, so overshoot through speed does
  nothing. Use three keys, separate dimensions, or the `spring` expression.
- Scale, Rotation, Opacity, sizes and sliders are non-spatial; a single segment with y1 > 1 or y2 > 1 overshoots.
  Checked in AE: `[0.22, 2.0, 0.39, 0.87]` on Scale overshoots 20% with peak speed at 8%; `[0.22, -0.1, 0.68, 1.17]`
  on a separated X Position overshoots 2% with peak speed at 43%.
- A single-segment overshoot (y2 ≠ 1) still has some speed at its last key, so the stop there is slightly abrupt.
  That is invisible on small overshoots of small elements; for a large one use three keys (overshoot value with a
  fast arrival, then the target with an in-out ease).
- To overshoot a position, separate its dimensions (`position.dimensionsSeparated = true` through ae_eval) and key
  `x position` / `y position`, which are non-spatial.
- Check every eased property with `ae_motion_curve`: it reports abrupt starts/stops, linear-looking motion and
  overshoot.

## 5. Carrying momentum across a key

Two segments meeting at a key read as one continuous move when the incoming speed of the first equals the outgoing
speed of the second:

```
v_end(A)   = (1 − y2_A) / (1 − x2_A) · Δ_A / dt_A
v_start(B) =  y1_B / x1_B           · Δ_B / dt_B
```

Example: a zoom of 3 stops in 0.8 s with `[0.6, 0, 0.9, 0.8]` ends at 0.2 / 0.1 × 3 / 0.8 = 7.5 stops/s. The next
segment (1 stop in 0.6 s) starts at that speed with y1 / x1 = 7.5 × 0.6 / 1 = 4.5, e.g. `[0.1, 0.45, 0.2, 1]`, and
settles long.

Simpler, and usually better: **don't put a key at the hand-off.** Let one eased segment on a carrier null span the
swap (`continuity.md`, section 4), and swap the children underneath it.

## 6. Holds, reading time, stagger, motion blur

**Holds inside the flow** last 4–20 frames (0.13–0.67 s). A "done" moment can earn 0.7 s.

**Text** needs about 0.3 s per word plus 1 s. In the study piece the two text lines hold 1.8 s and about 2.5 s and the
logo about 4 s, at the very end: long holds are spent only where there is something to read.

**Stagger.** Copies inside one rig (a Repeater array, a fan) share one ease and are not staggered: the system reads as
one object. In the fan, two of three tracked phones reached a quarter of their turn on the same frame; the third could
not be tracked reliably, so treat "one ease per array" as the observed default rather than a precise figure. Separate
siblings (strokes re-forming, rings drawing, parts of a layout morph) are staggered by 1–3 frames, the most important
or largest first. claude-ae's house rule is 0.04–0.1 s; its style guide default is 0.06 s.

**Motion blur.** The study piece renders its flat graphics without motion blur: edges moving 23–58 px per frame keep
a 3 px edge, the same as at rest. Every frame stays a crisp illustration, and the continuity carries the motion. Turn it
on for photographic or 3D material and for whips (`blur.md`). When it is on, both layers of a swap need it.

## 7. Copy-paste eases for ae_set_keyframes

```
arrive        [0.12, 0, 0.20, 1]     objects landing (influence 12% / 80%)
arrive_soft   [0.16, 0, 0.32, 1]     larger or slower landings
camera        [0.06, 0, 0.27, 1]     zooms and pull-backs that continue a hand-off, on a log-scale slider
camera_rest   [0.45, 0, 0.25, 1]     a camera move that starts from rest while the subject is still
land_moving   [0.50, 0, 0.75, 0.5]   arrives still moving (a drop hitting the ground and squashing)
dial          [0.61, 0, 0.12, 1]     growing from small to big
handoff       [0.80, 0, 0.80, 1]     accelerating into the next transformation
handoff_long  [0.48, 0, 0.86, 1]     big rotations and fans (2–2.5 s)
pop15         [0.20, 1.70, 0.30, 1]  small round element: ~14% overshoot, peak at a third, long settle
pop20         [0.22, 2.00, 0.39, 0.87]  ~20% overshoot at a third, settles over the last two thirds
ui            [0.22, -0.10, 0.68, 1.17] toggles and sliders, 2% overshoot
glow_up       [0.79, 0, 0.82, 1]     light swells
glow_down     [0.19, 0, 0.86, 1]     light fades
```
