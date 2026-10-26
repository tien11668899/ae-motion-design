# Colour

Measured from the study piece with `[Look]::Stats` and `[Look]::KMeans` (`scripts/measure.ps1`): 578 frames, one every
5 frames from 2.1 s to 98.4 s. "Artwork" means every pixel at least 18 RGB levels away from the fitted background.

Contents:
1. What the study piece does
2. Its palette
3. Rules
4. Colour in motion
5. After Effects recipes
6. Checks

## 1. What the study piece does

| Measure | Value |
|---|---|
| Stage | radial light grey, level 236.8 (`#EDEDED`) at the centre to 208.3 (`#D0D0D0`) at 1250 px, unchanged all the way through. The opening uses pure white (`#FFFFFF`) until the frame shrinks into a card. Never a dark background |
| Neutral artwork | 77% of all artwork pixels: dark 24% (average level 32, `#202020`), grey 25%, white 28% (`#F2F2F2`–`#FFFFFF`) |
| Colour artwork | 20.5% of artwork pixels, plus 2.9% pale tints |
| Frames with any colour | 45% of the frames that show artwork; the other 55% are black, white and grey only |
| Hues on screen at once | one hue in 42% of the colour frames, two in 10%, three or four in 34%, five or more in 14% |
| Saturation and lightness (HSL) | saturation median 0.78 (quartiles 0.67 / 0.93), lightness median 0.62 (0.55 / 0.67): vivid mid-tones, no dark or muddy colours, few pastels |
| Hue share of all colour pixels | red 53%, cyan 10%, azure 9%, orange 6.5%, mint 6.5%, pink 4%, yellow-green 3%, blue 2%, green 2%, yellow 2%, violet 2% |
| Colour over time | bursts of colour (median 3.8 s) inside monochrome stretches (median 5.5 s). Sparse accents in the first half (7.7–13.2, 14.2–16.0, 23.2–26.0, 37.3–41.2 s), mostly colour from 57 to 88 s, and a monochrome ending: black type and logo from 87.8 s |
| Text | near-black (dark text pixels average level 13–14, `#0E0E0E`) |

Contrast against the stage centre (WCAG ratio): text about 16.5:1, dark artwork about 14:1, the vivid colours
1.9–3.9:1 (green 1.9, coral 2.5, blue 3.5, red 3.9), white only 1.17:1. White objects are therefore defined by their
shading, edges and shadows, never by contrast alone.

## 2. Its palette

k-means over 411,586 colour pixels (every 10th frame), the largest swatches first. Some swatches are shading of the
main ones.

| Family | Swatches (share of colour pixels) |
|---|---|
| warm accent | coral `#FD674E` 26%, red `#E9180C` 13%, light coral `#FD736C` 7%, crimson `#F70741` 1.4%, dark red `#9F2136` 4% (shading) |
| cool companions | pale cyan `#98E6EA` 7%, teal `#68D3C6` 5%, cyan `#1DCBD6` 3.5% |
| greens | green `#32C75C` 5%, lime `#A0F707` 2.5%, olive `#598E3A` 1.3% (shading) |
| blues and violets | blue `#3A7AE7` 4%, violet `#7366C0` 2%, steel `#3C6587` 1.5% |
| pinks, peaches, yellow | rose `#D26874` 4%, pink `#F14373` 3.5%, light pink `#EAAACE` 1.7%, peach `#DC9F8E` 4%, light peach `#F8C8A6` 2%, yellow `#EED04A` 1.4% |

Use the structure, not the hex codes: one warm accent that owns the piece, cool companions, and full families only
when the subject is variety.

## 3. Rules

1. **Neutral first.** Build the sequence in black, white and grey on a light stage, then add colour where it means
   something. Colour is the exception: about a fifth of the artwork, about half of the time.
2. **One accent, or the whole family.** A colour frame shows one hue (an accent with meaning: red for a heart) or three
   or more (a range of variants). Two competing hues are rare.
3. **Vivid mid-tones.** HSL saturation 0.7–0.95, lightness 0.5–0.7. On a light stage, dark or greyed colours look
   dirty and pastels disappear.
4. **Type and fine detail in near-black** (about 14–16:1). Colour is for shapes; 2–4:1 is enough for a large shape,
   not for text or hairlines.
5. **White needs form.** White on light grey is 1.17:1; give white objects shading, an edge, a contact shadow or a
   coloured neighbour.
6. **Colour has a rhythm.** Let it arrive in bursts of 3–5 s and fall back to neutral; build towards the most
   colourful stretch late in the piece and end neutral, so the last statement (type, logo) is the calmest frame.
7. **Colour changes ride on motion** (drain, flood) or happen as an instant switch when something turns on: in the
   study piece a black mark flips to glowing white in one frame (47.87 s) and a glow swells from it.

## 4. Colour in motion

- **Drain to white / flood with colour:** key the Fill (or Stroke) Color over 0.3–0.6 s with `in_out` while the object
  moves (`continuity.md`, technique 10).
- **Switch on:** a hold key (`ease: "hold"`) from the dark colour to white, then a glow swell (`glow_up` 0.37 s) and fade
  (`glow_down` 0.37 s) from `timing.md`.
- **Colour hand-off at a swap:** the incoming layer starts in the outgoing layer's colour at the swap frame, then
  changes.
- **RGB interpolation goes through grey.** AE blends colour keys channel by channel, so red to cyan passes a dull grey
  midpoint. Add a key at an in-between hue, or blend in HSL with an expression on the colour property:

```
// Slider "Mix" 0..100 keyed with the ease; c1, c2 are the two colours (RGBA 0..1)
var c1 = [0.99, 0.40, 0.31, 1], c2 = [0.11, 0.80, 0.84, 1];
var a = rgbToHsl(c1), b = rgbToHsl(c2), t = effect("Mix")("Slider") / 100;
var dh = b[0] - a[0]; if (dh > 0.5) dh -= 1; if (dh < -0.5) dh += 1;   // shortest way round the hue circle
var h = a[0] + dh * t; if (h < 0) h += 1; if (h > 1) h -= 1;
hslToRgb([h, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, 1]);
```

## 5. After Effects recipes

- **The stage:** a solid with Gradient Ramp (`ADBE Ramp`), radial, `#ECECEC` at the centre to `#D0D0D0` 1250 px out
  (`claude-ae.md`, section 3).
- **Fills and strokes:** set `fill`/`stroke` in `ae_add_layer` shapes; key `Contents/Group 1/Contents/Fill 1/Color`.
- **Drain via an effect:** Tint (`ADBE Tint`) or Fill (`ADBE Fill`) with its amount or opacity keyed, on the layer or
  on an adjustment layer above a group.
- **Gradients:** Gradient Ramp (`ADBE Ramp`) on a solid matted to the shape (`ae_edit_layer` track matte): every value
  is scriptable. A shape's own Gradient Fill (`ADBE Vector Graphic - G-Fill`: Type, Start Point, End Point, Highlight
  Length, Highlight Angle, Colors, Opacity) can be added and its points keyed, but its **Colors cannot be set by
  script** in AE 2023 (the call errors and rolls back); set those by hand or use the ramp.
- **Banding** in big soft gradients (8 bpc): first raise Gradient Ramp's Ramp Scatter to 24–64, which dithers the
  ramp and removed visible bands in a test build. Switching the project to 16 bpc
  (`app.project.bitsPerChannel = 16`) also works but changes every comp in the project, so ask first.
- **Soft multi-colour light** (an orb, a wallpaper): saturated ellipses blended with Screen or Add under one blur
  adjustment layer (`blur.md`).

## 6. Checks

- Render a frame and look at it in greyscale (Hue/Saturation with Master Saturation −100 on an adjustment layer, or
  `ae_probe` levels): the hierarchy should survive without colour.
- Count the hues in each frame of the contact sheet: one accent or a family, rarely two.
- Text and hairlines at least 7:1 against what is behind them; aim for near-black on the light stage.
- `[Look]::Stats` on exported frames of your own build gives the same numbers as the table in section 1, so a build can
  be compared with a reference.
