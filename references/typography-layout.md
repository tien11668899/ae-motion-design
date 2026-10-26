# Typography, composition and spacing

Measured from the study piece with `scripts/measure.ps1` (`[Look]::Stats`, `RowCol`, `Line`, `Blobs`) on 1920×1080
frames.

Contents:
1. Type in the study piece
2. Type rules
3. Kinetic type: how text arrives, changes and leaves
4. Type in After Effects (fonts on this PC, setting, animators, the word pivot)
5. Composition and spacing in the study piece
6. Spacing rules
7. Layout in After Effects

## 1. Type in the study piece

| Element | Measured |
|---|---|
| Opening word | hand-lettering, not a font: a monoline script drawn on, 892 × 308 px (46.5% of the frame width, 28.5% of the height), stroke about 25 px, black on pure white. Optically centred at (933, 504): a little left of and above the frame centre, which balances its trailing full stop and tall ascenders |
| Closing lines | Apple's San Francisco (SF Pro), Regular: stems 4.2 px on a cap height of 35 px (stem/cap 0.12). Cap height 3.2% of the frame height (about 50 px type at 1080p), x-height 25 px (0.71 of the cap height). Default tracking (letter gaps 1–5 px), normal word spaces (12–15 px, about a quarter em). Near-black (`#0E0E0E`) on the light grey stage, centred |
| Line length | one line at a time: 4 words, 559 px (29% of the frame width); then 5 words, 624 px (32%) |
| Vertical position | the x-height band (rows 527–551) is centred on the frame's centre line: optical centring on the lowercase, not on the bounding box |
| Logo | 137 px tall (12.7% of the frame height, about 3.9 × the text's cap height), centred |
| Hold | line 1 readable for about 2.0 s (4 words), line 2 about 2.6 s (5 words), the logo about 5 s. The rule "0.3 s per word + 1 s" predicts 2.2 s and 2.5 s |

## 2. Type rules

1. **Type is quiet; shapes are loud.** Small (cap height about 3% of the frame height), Regular weight, near-black,
   centred, one short line at a time. The shapes carry the energy; type carries the meaning.
2. **Hold 0.3 s per word + 1 s**, counted from the moment the line is readable. For Chinese titles, about 0.2 s per
   character + 1 s is a good starting point (a rule of thumb, not measured here).
3. **Centre optically.** Centre the x-height band (or the visual mass of a script) on the frame centre, not the
   bounding box; descenders and a full stop would otherwise pull the line off.
4. **Default tracking at body and caption sizes**; tighten slightly only for very large display type. Never wide-track
   lowercase.
5. **Bring text out of the preceding motion** (lines converging into words) and change lines by pivoting on what the
   two lines share. Text never pops in from nothing.
6. **The logo is the full stop**: bigger than the type (about 4× its cap height), held the longest, and the only thing
   the piece cuts to.
7. **Lettering is drawn, not typed.** A handwritten word animates as one monoline stroke with Trim Paths, round caps and
   joins, at a stroke weight that matches the hairline family of the piece.

## 3. Kinetic type: how text arrives, changes and leaves

**Arrive out of lines (0.9 s).** Coloured lines from the previous scene fly inward and the first line of text appears
where they meet, its letters packed together with the word spaces collapsed; the word spaces then open to normal and
the leftover coloured dots fade (energy settles after 27 frames). The spacing settle *is* the arrival.

**Change lines by a word pivot (0.7 s).** The two lines share a word. That word stays exactly where it is: its contrast
and sharpness do not change by a single level during the change. The other words fade out first and the new words fade
in around it (contrast in that area dips to about 25% at the midpoint), with only a hint of softening (edge ramp
1.5 → 2.5 px). The new line is still centred because the copy and the shared word's position were chosen together.
This is the shared-silhouette rule of `continuity.md` applied to type.

**Leave by a cut.** After the second line's hold, the piece cuts to the logo: the one hard cut in 98 seconds,
reserved for the final statement.

Other moves that fit this language: a tracking settle (tracking from −60 to 0 with an arrival ease), a cascade with a
small rise and a little blur (`ae_animate` preset `cascade`), a line drawing a baseline that the words then sit on.

## 4. Type in After Effects

**Fonts on this PC.** AE 2023 has no font-list API, so set the PostScript name and read back the warning that
`ae_add_layer` returns if AE substituted the font. These names were checked in AE 2023 on this PC:

| Font | PostScript names that work |
|---|---|
| SF Pro (variable, `C:\Windows\Fonts\SFPro.ttf`) | `SFPro-Regular`, `SFPro-Medium`, `SFPro-Semibold`, `SFPro-Bold` (`SFProDisplay-*` and `SFProText-*` do not exist here) |
| PingFang TC / SC | `.PingFang-TC-Medium`, `.PingFang-SC-Medium`: note the leading dot; the files are named Semibold but contain Medium |
| Microsoft JhengHei | `MicrosoftJhengHeiRegular`, `MicrosoftJhengHeiBold`, `MicrosoftJhengHeiLight` |
| others | `Bahnschrift-SemiBold` (and the other Bahnschrift styles), `ArialMT`; Segoe UI is invisible to AE here |

An unknown name does not raise an error: AE keeps the previous font or falls back to Times New Roman. Always compare
the font read back with the one you asked for.
- Check the licence before using a system font from another platform in a deliverable: SF Pro's licence covers
  mock-ups of interfaces for Apple platforms. For other work, a neo-grotesque with an open licence (Inter, for
  example) is the closest match; ask the user to install it.

**Setting a line like the study piece**

```
ae_add_layer {kind: "text", text: "...", font: "SFPro-Regular", fontSize: 50, fillColor: "#0E0E0E",
              justification: "center", tracking: 0, position: [960, 540]}
```

claude-ae centres a text layer's anchor on its bounds. For optical centring, measure the lowercase band with
`ae_probe` (or `sourceRectAtTime()` in an expression) and nudge the position until the x-height band is centred on
y = 540.

**Per-character animation.** `ae_animate` presets `type_on`, `cascade` and `tracking` cover most cases. For a custom
animator, use ae_eval with these matchNames (the bridge's own presets use them):

```
var l = CB.findLayer(CB.findComp('Intro'), 'Title');
var an = l.property('ADBE Text Properties').property('ADBE Text Animators').addProperty('ADBE Text Animator');
var props = an.property('ADBE Text Animator Properties');
props.addProperty('ADBE Text Opacity');          // also: ADBE Text Position 3D, ADBE Text Scale 3D,
props.addProperty('ADBE Text Blur');             //       ADBE Text Tracking Amount
var sel = an.property('ADBE Text Selectors').addProperty('ADBE Text Selector');
// sel: ADBE Text Percent Start / End / Offset; sel.property('ADBE Text Range Advanced') holds
// ADBE Text Range Shape (2 = ramp up), ADBE Text Levels Max Ease, ADBE Text Levels Min Ease, ADBE Text Selector Smoothness
```

Every animator property must be added (`addProperty`) before it can be set. Don't read a just-added animator
property's value in the same ae_eval: it throws "invalid numeric result" and the whole call rolls back.

**The word pivot.** Split each line into three text layers: the words before the shared word, the shared word, the
words after. Keep one shared-word layer on screen through the change. Fade the outgoing parts out (about 0.35 s,
accelerating), then fade the incoming parts in (about 0.35 s, arrival ease, Text Blur or Gaussian Blur from about 4 px
to 0). Place the incoming parts against the shared word with `sourceRectAtTime()` so the new line ends up centred.

**Drawn lettering.** One path per stroke of the word (`type: "path"`, `closed: false`, `lineCap: "round"`), stroke
weight matched to the piece, Trim Paths End keyed 0 → 100 with an arrival ease per stroke, strokes staggered so the pen
appears to travel.

## 5. Composition and spacing in the study piece

| Measure | Value |
|---|---|
| Artwork area | median 2.8% of the frame (quartiles 1.0% / 5.9%, 90th percentile 12.4%): about 97% of each frame is empty stage |
| Subject size (2–98% of artwork pixels) | height median 40% of the frame height (quartiles 24% / 61%); width median 26% of the frame width (15% / 38%) |
| Full-frame moments | 6% of frames: zoom-throughs, grids, flashes |
| Centring | artwork centroid a median 7 px from the frame centre (75th percentile 25 px, 90th 75 px); bounding-box centre 6 px (75th 28 px) |
| Grid, 4 × 2 icons | items 207 px, pitch 252.5 px: gap 45.5 px = 22% of an item; the grid covers 50% × 43% of the frame |
| Grid, 5 × 3 objects | items 247 px; column pitch 296 px (gap 20%), row pitch 341 px (gap 38%); covers 75% × 86% of the frame with about 7% top and bottom margins |
| Radial array of objects | six objects of about 200–219 px on a ring of radius about 205 px: object size ≈ ring radius, nearly touching |
| Radial array of lines | lines 260 px long centred about 310 px from the middle (inner ends about 180 px out) |
| Stroke families | hairlines 3.6–4 px (orbit trails, dial details) and a soft 8 px light line; icon strokes 15 px on a 290 px ring (1/19 of the diameter) and 24 px on a heart outline; bold rings 93–126 px (a 126 px ring on a 636 px diameter is 1/5); type stems 4.2 px; the script 25 px |

## 6. Spacing rules

1. **Small subject, big stage.** Keep the subject at about 25–60% of the frame height and let empty space frame it.
2. **Centre within a few pixels** and centre optically (visual mass, lowercase band), not by bounding box.
3. **One focal point.** When many things are on screen (grids, arrays) they behave as one system.
4. **Grid gaps about 20% of the item size**, looser between rows (up to about 40%) when the items are tall. A grid that
   becomes the whole world keeps about 7% margins (the claude-ae style guide's `safeMargin` is 0.07).
5. **Radial arrays are dense:** object size about equal to the ring radius; lines begin at about 0.6 of their centre
   radius.
6. **Stroke weights come in families.** Pick a hairline (about 4 px at 1080p), an icon stroke (about 1/19 of the icon's
   diameter) and, if needed, a bold ring (about 1/5); keep each family constant across the sequence, even while the
   camera zooms.

## 7. Layout in After Effects

- **Grid:** one item in a shape group plus two Repeaters (Copies = columns, Transform Position = [pitch, 0]; then
  Copies = rows, Position = [0, pitch]). Centre it by moving the group's Transform Position to
  [−(columns − 1) / 2 × pitch, −(rows − 1) / 2 × pitch].
- **Radial array:** one item whose path Position is offset by the radius, and a Repeater with Rotation 360 / copies
  (`claude-ae.md`, Repeater).
- **Keep hairlines constant through zooms:** on Stroke Width,
  `var s = length(toComp([0, 0]), toComp([100, 0])) / 100; value / s;` divides out the layer's and its parents'
  scale.
- **Check centring and size** on renders with `ae_probe` (bbox, centre) or `[Look]::Stats` on exported frames, and
  compare against the table in section 5.
