---
name: ae-motion-design
description: >-
  Motion-design craft for After Effects driven through the claude-ae MCP tools (ae_* tools): plan animations as one
  continuous chain where every shape grows out of the one before (primitive bridges, collapse/expand, rotate-to-edge,
  zoom-through, stroke redraw, outline-to-fill, fan and radial arrays, dot-and-trail, glow bridges), time them with
  easing measured from a top-tier keynote opener (AE influence values, durations, overshoot, handoff acceleration),
  build them with shape layers, path morphs, trim paths, repeaters and expressions, add Liquid Glass materials, choose
  colour (neutral stage, vivid accents in bursts), set type (small, centred, word-pivot line changes, SF Pro and CJK
  fonts on this PC), lay out and space elements (subject size, centring, grid gaps, stroke-weight families), decide on
  motion blur versus crisp frames and use blur as light, sync to music (tempo, beats, accents, phrase-level sync,
  beat markers), use the 3D camera, lights and effects with purpose, research references on the web (Apple's HIG,
  WWDC springs and SF Symbols animations, keynote films), and measure a reference video's motion, look and soundtrack
  (frame export, motion energy, tracking, ease fitting, palette, layout, edge blur, beat tracking). Use this whenever
  the user wants an animation, motion graphic, transition, morph, logo or product reveal, title sequence, kinetic type,
  music-synced edit, camera move, or glass/liquid-glass look in After Effects, mentions claude-ae, AE, keyframes,
  easing, colour, typography, spacing, blur, rhythm, beats, camera or effects in motion work, asks how good animation is
  timed or designed or how Apple does it, or wants a reference video analysed, even if they don't name this skill.
  中文觸發：AE 動畫、動態設計、形狀連續、轉場、變形、關鍵影格、緩動、液態玻璃、配色、顏色、字體、文字編排、排版、
  間距、構圖、模糊、動態模糊、光暈、配樂、節奏、對拍、拍點、攝影機、運鏡、特效、找參考、蘋果的設計、參考片分析、
  做得像蘋果發表會那樣流暢。
---

# AE motion design: continuity, timing, look, and building it in After Effects

This skill holds what was learned by taking a world-class motion piece apart frame by frame (a 2019 keynote opener:
about 30 product ideas in 98 seconds, with a single cut, at the very end) and from building inside After Effects
through claude-ae. It covers how such a piece keeps the eye locked, the numbers behind its timing and its look, and how
to build that in AE.

Read the parts you need:

| When you are... | Read |
|---|---|
| planning a sequence, or a transition between two things | `references/continuity.md` (the shape-chain grammar and 18 transition techniques, each with an AE build) |
| choosing durations, easing, overshoot, stagger | `references/timing.md` (measured moves as AE influences and cubic-beziers, plus the rules they imply) |
| choosing colours, a palette, colour changes | `references/color.md` (measured colour use, the palette's structure, colour in motion) |
| setting type, kinetic type, composition, spacing, grids, stroke weights | `references/typography-layout.md` (measured type and layout, fonts on this PC, the word pivot) |
| motion blur, soft light, glows, focus pulls | `references/blur.md` (why the study piece has no motion blur, blur as material and transition) |
| music, rhythm, beats, cutting to a track | `references/music.md` (the study piece's tempo and what it locks to the music; sync levels; beat markers) |
| a 3D camera, lights, depth of field, effects | `references/camera-effects.md` (renderers, camera moves and rigs, effects palette by job, taste) |
| finding references, Apple's own design language | `references/research.md` (Apple sources, Apple's spring model in AE, SF Symbols vocabulary, web images) |
| driving AE (which tool does what, shape/path/repeater recipes, gotchas) | `references/claude-ae.md` |
| making a glass or liquid-glass material | `references/liquid-glass.md` |
| studying a reference video's motion, or matching one | `references/measuring.md` and `scripts/measure.ps1` |

## The core idea: one continuous thread

The measured piece moves **88% of the time**. Its 13 motion runs last 5.4 s at the median, and the holds between
them last 0.3 s at the median (one 0.7 s pause inside the flow; long holds only at the very end, for reading text and
the logo). It cuts exactly once, from the last line of text to the logo. Yet it reads effortlessly. The reason is
that **the viewer's eye never has to search**: every new object grows out of something already on screen, in the
same place, usually at the centre. A cut makes the eye hunt for the new subject; a continuous transformation hands the
gaze from one idea to the next.

So design a sequence as a **chain of shapes**, not a list of scenes:

```
Object A --(collapse)--> primitive --(transform)--> primitive' --(expand)--> Object B --> ...
```

The primitives are the bridges: **dot, disc, ring, line/bar, capsule (pill), rounded rect, arc**. Every complex thing
is built from them and passes through one on the way to the next. For example:

- A card holding a word becomes a computer's screen.
- The computer shrinks into a disc, which splits into dots.
- The dots orbit into a click wheel, whose centre button becomes a home button.
- Its ring becomes a fingerprint, whose strokes unravel and re-form as a face glyph.
- And so on, for 98 seconds.

Pick the bridge by **shared geometry**: round things hand off through a disc or ring, flat devices through a bar or
line, cables and outlines through a line.

Four habits make the chain feel effortless:

1. **Carry momentum through the handoff.** A move that leads into a transformation *accelerates* into it rather
   than settling. The measured handoffs peak at 77–85% of their duration. The next move continues in the same
   direction: rotations keep their sense, a zoom keeps going.
2. **Overlap.** Start the next transformation before the last one has settled. Holds inside the flow are 4–20 frames.
3. **Settle arrivals long.** When something lands, it leaves fast and settles long. Measured arrivals put peak
   speed at 5–20% of the move, with an AE incoming influence of 70–90%.
4. **Stay at the centre and move the camera.** The focal point barely leaves the middle of the frame. Big changes
   in scale are camera moves (scale a parent null), not objects flying around.

Colour changes happen *during* motion and carry meaning: a device turns from colour to white as it becomes the next
product, and red belongs to the heart. Inside the flow, glows and flashes stand in for cuts: a bright swell (0.37 s,
accelerating) hides the swap.

## The look

The same frames, measured for their look (`color.md`, `typography-layout.md`, `blur.md`):

- **A big quiet stage.** A light radial grey (`#EDEDED` → `#D0D0D0`); the artwork covers a median 2.8% of the frame,
  stands about 40% of the frame height, and sits within a few pixels of the centre.
- **Neutral first, colour as meaning.** 77% of the artwork is black, white or grey; colour shows up in 45% of the
  frames, as one vivid accent or a whole family, in bursts of about 4 s, building towards the end and leaving a
  neutral ending.
- **Quiet type.** One short line at a time, SF Pro Regular at about 3% of the frame height, near-black, optically
  centred, held 0.3 s per word + 1 s. Lines change by pivoting on a shared word.
- **Families of line weights**: hairlines about 4 px, icon strokes about 1/19 of the icon, bold rings about 1/5.
- **Crisp frames.** No motion blur on the flat graphics (edges moving 58 px per frame stay 3 px sharp); blur exists
  only as light: glows, soft orbs, shadows.

## When rules disagree

claude-ae's own quality bar and `ae_style_guide` are general defaults: a dark editorial stage, motion blur on, large
display type with wide-tracked small caps. This skill's look contradicts them on purpose. Precedence:

1. What the user asks for.
2. For keynote-style continuous motion, or whenever the user wants this measured look: this skill (light radial stage,
   motion blur off on flat graphics, quiet type at about 3% of the frame height, default tracking).
3. Otherwise the style guide and the server's quality bar.

Say which one you are following whenever you depart from the style guide, so the choice is visible.

## Workflow

0. **Research.** Look at how Apple (and other top work) treated a similar subject: HIG, WWDC sessions, SF Symbols
   animations, keynote films (`research.md`). Write a five-line reference board (shape logic, timing, colour, type,
   camera). Ask before downloading anything; references are for study, not for copying.
1. **Storyboard the chain in words before touching AE.** One line per beat: `A -[bridge, technique, duration]-> B`.
   Check that every beat starts from a shape already on screen. If one doesn't, find the shared primitive. The
   technique catalogue in `references/continuity.md` lists what is possible. Decide the look at the same time: the
   stage, the one accent colour (and where colour bursts happen), the type, the line-weight family
   (`color.md`, `typography-layout.md`, `blur.md`).
2. **Block the timing** with the numbers in `references/timing.md`: an arrival is 0.4–0.8 s with a long settle; a
   handoff is an accelerating move into the next morph; a camera move is 1.2–1.6 s in log scale; a pop overshoots
   14–22%; a UI slide is about 1 s and balanced. Keep holds short unless text must be read (about 0.3 s per word
   plus 1 s). With music, measure it first (`music.md`), choose the sync level (punctuation, phrase or beat), put beat
   markers on the comp and time the punctuation so its perceived moment lands on an accent.
3. **Build with claude-ae** (`references/claude-ae.md`):
   - `ae_status`, then `ae_style_guide`.
   - One comp per sequence, centred composition. Motion blur off for a crisp flat look, on for photographic or 3D
     material (`blur.md`); claude-ae turns it on by default.
   - Shape layers built from primitives; path keyframes with matched vertex counts for morphs; Trim Paths for line
     draws; Repeaters for arrays.
   - A parent null as the camera for flat pieces; a real 3D camera with light and depth of field when the piece
     should feel physical (`camera-effects.md`). Effects each with a job: light, depth, material, transition, energy.
   - `ae_set_keyframes` with explicit eases. A move from rest to rest is
     `cubic-bezier(out, 0, 1 - in, 1)` built from AE influences; the named presets start fast.
4. **Look, then fix.** Use `ae_contact_sheet` for the flow (12–24 frames over a beat), `ae_motion_curve` for each
   eased property (it reports abrupt starts and stops, linear-looking motion, and overshoot), and `ae_render_frame`
   with a region for edges. Two or three build-look-fix rounds are normal.
5. **If you are matching a reference**, measure it first (`references/measuring.md`): its rhythm, the moves' eases,
   and which shape bridges which. Then build your own shapes with that timing.

## Studying someone else's animation

Learning from a reference means taking its *technique* (timing, easing, the transition grammar) and building your
own designs with it. The measurements in this skill came from studying a commercial piece. The skill keeps the
numbers and techniques, not its artwork. When a user wants something "like" a famous piece, give them that piece's
rhythm and transitions with original shapes. Copying its product drawings, logos or icons frame for frame makes a
copy of someone else's work, which is not yours to publish.

## Quick reference

| Situation | Duration | Ease (AE influence out/in, or cubic-bezier) |
|---|---|---|
| Object arrives / settles | 0.4–0.8 s | 10–20% / 70–90% → e.g. `[0.12, 0, 0.2, 1]` |
| Camera push / pull-back | 1.2–1.6 s, log scale | continuing a hand-off: 5–10% / 70–75% → `[0.06, 0, 0.27, 1]`; starting from rest: `[0.45, 0, 0.25, 1]` |
| Small round element pops in | 0.3–0.6 s | overshoot 14–20%: `[0.20, 1.70, 0.30, 1]` or `[0.22, 2.0, 0.39, 0.87]` (`out_back` is ~10%) |
| Handoff into the next morph | 0.4–2.5 s | 50–100% / 15–25% (accelerate) → `[0.8, 0, 0.8, 1]` |
| UI-like slide (toggle) | ~1 s | 30% / 45%, ≤ 3% overshoot: `[0.22, -0.1, 0.68, 1.17]` |
| Hold inside the flow | 4–20 frames | — |
| Fan / radial array | one move | all copies share one ease; copy i turns i × angle(t) |
| Separate siblings (strokes, rings, layout parts) | each 0.4–0.8 s | stagger 1–3 frames (0.04–0.1 s), largest or most important first |
| Swap between two layers | one frame | silhouettes coincide exactly; check the swap frame zoomed with `ae_render_frame` |
| Line of text | 0.3 s per word + 1 s (Chinese: ~0.2 s per character + 1 s) | arrive 0.9 s out of the previous motion; change lines by a word pivot in 0.7 s |
| Music (study piece) | 72.25 BPM = 25 frames per beat; 4-bar phrases of 13.3 s | flow free of the beat; flashes, switch-ons, text landings within 1–2 frames of accents; final cut on a phrase downbeat |
| Landing on a beat | start a pop ⅓ of its duration early, an arrival 0.6 of its duration early | end hand-offs and glow swells on the beat |
| Apple-style spring | duration d, bounce b | `spring {freq: 1/d, damping: 1 − b}`; b 0 smooth, 0.15 firm, 0.3 playful, ≤ 0.4 for UI |

| Look decision | Default taken from the study piece |
|---|---|
| Stage | light radial grey `#ECECEC` → `#D0D0D0` (1250 px), never pure black |
| Subject | about 25–60% of the frame height, centred within ~25 px, ~97% of the frame empty |
| Colour | neutral first; one vivid accent (HSL S 0.7–0.95, L 0.5–0.7) or a full family, in 3–5 s bursts |
| Type | SF Pro (or the licence-appropriate substitute) Regular, cap height ~3% of frame height, `#0E0E0E`, centred on the x-height |
| Line weights | hairline ~4 px at 1080p; icon stroke ~1/19 of the icon; bold ring ~1/5 |
| Grid | gap ~20% of the item (rows up to ~40%); ~7% margins when the grid fills the frame |
| Motion blur | off for crisp flat graphics; on (180°) for photographic or 3D material |
