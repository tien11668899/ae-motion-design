# Music: rhythm and sync

Claude cannot listen. It can measure a soundtrack's waveform (onsets, tempo, beats, accents, loudness) and line the
animation up with the numbers; the user has to listen to the result and say whether it feels right. Say so.

Contents:
1. What the study piece does (measured)
2. Three levels of sync
3. Measuring a soundtrack
4. Building to the music in After Effects
5. Checks

## 1. What the study piece does

The soundtrack was exported from AE (output template "AIFF 48kHz") and measured with `scripts/measure.ps1`
(`[Audio]::Onsets`, `Tempo`, `Beats`):

| Measure | Value |
|---|---|
| Tempo | **72.25 BPM**, steady throughout: one beat = 0.8325 s = **25 frames at 30 fps** (a strong double-time pulse at 143 BPM) |
| Bar / phrase | 4-beat bars of 3.33 s; 4-bar phrases of 13.32 s, starting 0.38, 13.70, 27.02, 40.34, 53.66, 66.98, 80.30, 93.62 s |
| Shape | music from 0.4 s to about 94.5 s; quieter at the start, louder after 14 s, dips at 28–36 s and 54–62 s |
| Visual rhythm vs beat | **not beat-locked.** Picture hits fall evenly across the beat (139 hits, phase concentration R = 0.10, p ≈ 0.22); picture and audio onsets do not correlate at any lag within ±12 frames (r ≤ 0.03); at the 84 strongest accents a big picture change happens 56% of the time, against 48% at random times; of the 20 biggest picture changes only 2 sit within 3 frames of an accent (3.5 expected by chance) |
| Visual intensity vs music | weak: picture motion against onset density over 5 s windows r = 0.30, against loudness r = 0.14 |
| Moments that *are* locked | the mark that switches on (47.87 s) lands 1.5 frames after a strong accent; the white flash into the icon grid (56.97 s) 0.5 frames before one; the first line of text settles 1 frame after one (88.60 s); a disc pop starts 7 frames *before* an accent so its overshoot peak hits it (50.07 s → 50.29 s); the cut to the logo (93.57 s) is 1.5 frames before the downbeat of the last phrase, and the music then fades within a second |
| Durations in beats | moves of ½ beat (0.43 s), ¾ (0.6 s), 1 (0.77 s), 1¼ (1.07 s), about 2 (1.5 s camera), 3 (2.47 s fan); holds of ⅓ beat; motion runs of about 1.6 bars. Not quantised to the beat |

So the piece runs its continuous transformations on their own easing rhythm and locks only its punctuation to the
music: light events, the text landing and the final cut, which lands on a phrase downbeat.

## 2. Three levels of sync

Choose one before building, and tell the user which:

| Level | What lands on the music | Feels like | Use for |
|---|---|---|---|
| **Punctuation** (the study piece) | flashes, switch-ons, glow peaks, the text landing, the final cut on a phrase downbeat | fluid and elegant; the music and the picture breathe together without marching | keynote openers, brand films, product stories |
| **Phrase** | each scene of the chain starts on a bar or phrase downbeat; the punctuation as above | structured, chaptered | explainers, longer pieces with clear sections |
| **Beat** | the impact of every move on a beat or half-beat; durations in beats | energetic, music-video | launch teasers, social cuts, fast promos |

## 3. Measuring a soundtrack

1. Get the music into AE (`ae_import`) and onto a comp. Export it as uncompressed audio:
   `ae_render_video {comp: "Music", path: "C:\\Users\\user\\source\\claude-ae\\.spool\\audio\\music.aif", template: "AIFF 48kHz"}`
   (keep the file inside the project folder; it is the path AE and the shell both see).
2. Measure it (about 1 s for 107 s of audio):

```powershell
. "$env:USERPROFILE\.claude\skills\ae-motion-design\scripts\measure.ps1"
$rate = 0.0; $x = [Audio]::ReadAiff($aif, [ref]$rate)
$on = [Audio]::Onsets($x, $rate, 100)                 # [onset, loudness dB, low-band flux] x frames at 100 fps
$o = for ($i = 0; $i -lt $on.Length / 3; $i++) { $on[3 * $i] }
$t = [Audio]::Tempo([double[]]$o, 100, 60, 200)        # [bestBpm, strength, then bpm/ac pairs]
$beats = [Audio]::Beats([double[]]$o, 100, $t[0], 100)  # beat times in seconds
```

3. Check the tempo over windows (`Tempo` on 24 s slices): a steady value means one grid; a value that doubles or
   changes marks a section. Octave errors are common: 72 and 143 BPM are the same music at half and double time.
4. Accents: the strongest onset peaks (top 1–2%, at least 300 ms apart). These are where light events and cuts go.
5. Sections: loudness per second; rises and dips mark where the piece can change gear.
6. Bars and phrases: count beats from the first strong downbeat in fours, and phrases in four bars. Verify by eye
   against the loudness changes and by asking the user.

## 4. Building to the music in After Effects

**Markers.** Put the beats on the comp as markers, labelling bar starts, so keys can snap to them and expressions can
read them:

```
ae_eval {script: "var c = CB.findComp('Intro'), b = [0.38, 1.2125, 2.045 /* ... */];
  for (var i = 0; i < b.length; i++) c.markerProperty.setValueAtTime(b[i], new MarkerValue(i % 4 == 0 ? 'bar ' + (i / 4 + 1) : ''));
  return b.length;"}
```

**Design in beats.** At 72 BPM a beat is 25 frames; at 120 BPM 15; at 90 BPM 20. Give each beat of the storyboard a
length in beats (an arrival ½–1 beat, a camera move about 2, a big rotation 3–4, a scene about one phrase).

**Anticipate so the perceived moment lands on the mark**, not the first key:

| Move | Perceived moment | Start it |
|---|---|---|
| pop (`pop15`, `pop20`) | the overshoot peak, at about ⅓ of the duration | ⅓ × duration before the beat |
| arrival (`arrive`) | "landed": 90% of the travel is done at about 60% of the duration | 0.6 × duration before the beat |
| hand-off (`handoff`) | the end, where the speed peaks and the swap happens | so it *ends* on the beat |
| glow / flash | the brightest frame (end of `glow_up`) | so the swell ends on the accent |
| cut | the cut frame | on the phrase downbeat, or 1–2 frames before it |
| text | the moment the line becomes readable | on an accent; then hold 0.3 s per word + 1 s |

**Beat pulse** (a beat-level accent for a light or a mark; use sparingly). On Scale or a glow's intensity:

```
var m = thisComp.marker, n = 0;
if (m.numKeys > 0) { n = m.nearestKey(time).index; if (m.key(n).time > time) n--; }
var t = n > 0 ? time - m.key(n).time : 1e3, k = 1 + 0.06 * Math.exp(-10 * t);
[value[0] * k, value[1] * k];
```

**Music-reactive light.** Keyframe Assistant > Convert Audio to Keyframes makes an "Audio Amplitude" layer with
Left, Right and Both Channels sliders, one key per frame. From a script: select only the audio layer, open its comp,
then `app.executeCommand(app.findMenuCommandId("Convert Audio to Keyframes"))` (tested here). Link a glow or a soft
light to "Both Channels" with an expression and smooth it (`smooth(0.2, 5)`). The Audio
Spectrum and Audio Waveform effects (`ADBE AudSpect`, `ADBE AudWave`) draw the music itself. Keep both subtle: in the
study piece the shapes never visibly pump with the music.

**Ending.** End the picture on the last phrase downbeat and let the music's tail play under the held final frame.

## 5. Checks

- Print each locked event's offset to its marker in frames: within ±1 frame for light events and cuts, ±2 for text.
- Render with sound (the H.264 templates carry audio) and ask the user to listen; Claude cannot hear the result.
- Watch for the march: if every move hits every beat in a piece meant to be elegant, release the transformations and
  keep only the punctuation on the music.
