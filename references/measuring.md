# Measuring a reference video's motion

How the numbers in `timing.md` were produced, so you can measure any reference the same way. The toolkit is
`scripts/measure.ps1` (PowerShell 5.1 with inline C#; no Python needed). Dot-source it first:

```powershell
. "$env:USERPROFILE\.claude\skills\ae-motion-design\scripts\measure.ps1"
```

Contents:
1. Clean frames
2. Rhythm: motion energy, runs and holds
3. Tracking an element
4. Fitting an ease
5. Traps
6. Checking a build against the reference
7. Tracing
8. Measuring the look: colour, layout, strokes, type, edge blur
9. Measuring the soundtrack, and picture against music

## 1. Clean frames

- Import the video (`ae_import`) and make a comp of it, e.g. "REF". Export PNGs in order:
  `Export-Frames -Comp 'REF' -From 0 -To 300 -Dir "<scratchpad>\ref"` (files `ref_<frame>.png`). It queues
  `saveFrameToPng` (asynchronous) and waits until every file exists; keep each call under about 800 frames.
- Long-GOP video can decode with block errors when AE seeks to a single frame: export in order, and trace or measure
  from the exported PNGs (`ae_trace` takes `image`).
- Bitrate is uneven. Key frames (every 150 frames in the study file) and some P-frames carry far more data than
  B-frames; take fine measurements from those.
- Compression blurs edges and adds ringing. Measure geometry (centroids, areas, angles), not individual edge pixels,
  and never copy the blur into a build: the original artwork was crisp.

## 2. Rhythm: motion energy, runs and holds

```powershell
$e   = [Motion]::DiffSeries($dir, 'ref_', 63, 1500)   # energy of frames 64..1500 (each vs the frame before)
$seg = [Motion]::Segments($e, 63, 3.0, 3)             # rows [start, end, isMotion]; runs under 3 frames merge
```

- Energy is the mean absolute difference (0–255) of the most-changed 16×16 block. Compression noise stays under
  about 3, so 3 separates holds from motion.
- DiffSeries handles about 1,450 1080p frames in 30 s; split longer videos across calls and save each series to a text
  file.
- Summarise: percentage of time in motion; median and quartiles of run and hold lengths; every hold over 15 frames;
  mean energy per second (the pulse).
- Inside AE, `ae_scenes {comp, step: 0.1}` gives a coarser map of holds, motion and cut-like jumps.

## 3. Tracking an element

```powershell
[Motion]::ColorTrack($png, 250, 40, 40, 70, 0, 0, 1920, 1080)   # pixels within 70 of rgb(250,40,40) in a region
[Motion]::BgFit($png, 960, 540, 1250)                            # radial background: [grey at centre, grey at R, rms]
[Motion]::ArtTrack($png, 236.8, 208.4, 1250, 18, 0, 0, 1920, 1080)  # pixels that differ from that background
```

Both trackers return `[count, cx, cy, angleDeg, major, minor]`: pixel count, centroid, the orientation of the second
moments in (−90°, 90°], and the extents of the equivalent rectangle. `ae_probe` measures the same from inside AE
(bbox, centre, size, area; `blobs` for several elements).

Pick the measure that carries the move: √count or major for a pop or a grow, the centroid for a slide, the angle for a
rotation, **log size** for a zoom, mean brightness in a region for a glow.

## 4. Fitting an ease

```powershell
$v = 2150..2190 | ForEach-Object { [Math]::Sqrt(([Motion]::ColorTrack("$dir\ref_$_.png", 250, 40, 40, 70, 0, 0, 1920, 1080))[0]) }
$moves = [Motion]::Moves([double[]]$v, 6, 10, 0.05)   # [start, end] index pairs, both ends at rest
foreach ($m in $moves) { Get-Ease ([double[]]$v[$m[0]..$m[1]]) ('heart f{0}-f{1}' -f (2150 + $m[0]), (2150 + $m[1])) }
```

Output reads like:

```
heart shrink (scale): 24 frames (0.77 s), AE influence out 16% / in 68% (rms 0.029), peak speed at 0.18 -> fast start, long settle
```

- `Moves(values, minFrames, minTravel, rest)` finds stretches that travel one way and start and end near standstill
  (speed below `rest` × the peak). Use rest **0.05**: at 0.2 it trims off the slow settle, which is the most
  characteristic part of an arrival.
- `Get-Ease` fits AE influences for keys at rest (`FitInfluence`, a 1% grid over cubic-bezier(out, 0, 1 − in, 1)).
  When the move overshoots by more than 2% it also prints the free cubic-bezier from `FitEase` (grid search, then
  coordinate descent over all four control points) and the overshoot.
- Readings: peak speed before 35% of the move is "fast start, long settle" (an arrival), after 65% "slow start, hard
  arrival" (a hand-off), in between "eases in and out".
- An rms under 0.03 (in normalised progress) is a good fit. Above about 0.05 the move is not one segment: a pop with
  its settle, a spring, or two moves joined. Split it or describe it with three keys.

## 5. Traps

- **Angle wrap.** PCA angles jump by 180° at ±90°. Unwrap before fitting, and trust angles only for elongated shapes
  (major/minor above 1.5).
- **Overlap.** Colour masks merge neighbouring copies (cards in a fan, rings in a stack); in the study piece one fanned
  card measured a 20° turn that it visibly did not make. Restrict the region, or choose a colour unique to the
  element, and sanity-check a track against a contact sheet before fitting it.
- **Zooms.** Fit log(size). In linear units a smooth camera move looks like a hard stop.
- **Motion blur.** Fast moves smear: a colour mask loses pixels and the area dips mid-move. Prefer centroids or
  extents for fast moves.
- **Rest frames.** Include a frame or two of rest on both sides, or the fit sees a non-zero start or end speed.
- **Hand-offs** don't end at rest. Moves() ends them where the next motion takes over; read the incoming influence as
  how hard the move drives into the hand-off.
- **Long moves.** Sampling every 2–3 frames reduces noise; the fit is in normalised time, so only the duration needs
  the step.

## 6. Checking a build against the reference

- `ae_compare {a: "REF", b: "BUILD", start, end, count}`: side by side, a difference image, a number per row. Zoom
  into anything suspicious with `ae_render_frame` and a `region`.
- Compare timing as well as pixels: measure the same property on the build (`ae_motion_curve`, `ae_probe`, or the same
  scripts on exported build frames) and compare the fitted influences and peak positions.

## 7. Tracing

`ae_trace` turns a rendered frame into editable shape layers. Use it on your own footage and designs, or to study
proportions; settings that give crisp, continuous outlines from compressed frames are `denoise: true`,
`edgeSmooth: 6`, `epsilon: 0.5`, `minHole: 40`, with `colors` (bottom to top) for flat multi-colour art, `palette` for
rival background shades, and `bgModel` for a radial background. Don't trace someone else's artwork to republish it:
measure its motion and build your own shapes.

## 8. Measuring the look: colour, layout, strokes, type, edge blur

The numbers in `color.md`, `typography-layout.md` and `blur.md` came from these calls (about 25 s for 578 frames):

```powershell
# per-frame colour and layout statistics; collect them with @([double]$f) + $s (not ($f, $s), which nests the array)
$s = [Look]::Stats($png, 960, 540, 1250, 18, 2)
# palette: colour pixels from every 10th frame, then k-means
$all = New-Object System.Collections.Generic.List[double]
foreach ($f in $frames) { $all.AddRange([Look]::ColourSamples("$dir\ref_$f.png", 960, 540, 1250, 18, 60, 4)) }
$km = [Look]::KMeans($all.ToArray(), 20, 25, 7)                 # [r, g, b, count] x 20
# stroke widths: art strength along a ray, then its bands at 50% of their peak
Get-Bands ([Look]::Line($png, 236.8, 208.3, 960, 540, 1250, 960, 540, 1500, 540, 1080)) 0.5
# grid and array spacing: connected regions with their bounding boxes
[Look]::Blobs($png, 236.8, 208.3, 960, 540, 1250, 25, 300, 0, 0, 1920, 1080)
# type: dark pixels per row (x-height, ascenders, baseline) and per column (letter and word gaps)
[Look]::RowCol($png, 0, 400, 1920, 280, 150)
# edge blur: blend profile across a moving edge; compare the 10-90% ramp with the edge speed
Get-Edge ([Look]::Blend($png, x0, y0, x1, y1, n, tR, tG, tB, bR, bG, bB)) 0.5
```

- `Stats` returns shares of colour, tint and dark/grey/white neutrals, 12 hue bins, the colour's mean HSL saturation and
  lightness, and the 2–98% bounding box and centroid of the artwork (see the comment in the script for the order).
- Count hues per frame as the bins holding at least 8% of that frame's colour pixels.
- An edge's 10–90% ramp grows by about 0.8 × shutter fraction × speed; compare moving edges with the same edges at rest
  before concluding anything about motion blur.
- Find cuts as isolated energy spikes: a frame above 40 that is more than four times every neighbour within two frames.
  Then look at it: an instant change of state in place (a mark switching on) is not a cut.

## 9. Measuring the soundtrack, and picture against music

Export the comp's audio with the "AIFF 48kHz" template, then `[Audio]::ReadAiff`, `Onsets`, `Tempo` and `Beats`
(`music.md`, section 3). To test how a piece syncs:

- **Picture onsets:** the positive change of the motion energy per frame; **picture hits:** its local maxima in the top
  10%, at least 6 frames apart.
- **Beat lock:** the phase of each hit within its beat; a phase concentration R near 0 (Rayleigh p well above 0.05)
  means the hits are not tied to the beat.
- **Accent lock:** for the strongest audio onsets (top 1–2%), how often a big picture change falls within ±3 frames,
  compared with random times. Then list the biggest picture changes and their distance to the nearest accent.
- **Punctuation:** check the hand-picked moments (flashes, switch-ons, text landing, cuts) one by one; that is where
  deliberate sync shows.
- Watch for PowerShell name clashes: a function called `R` collides with the `r` alias (Invoke-History).
