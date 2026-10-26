# Research: references from the web, and Apple's own design language

Before designing a piece, or a subject within it (weather, a battery, a toggle, a heartbeat), look at how the best
work handled something similar, Apple's first. Study it; then design original shapes.

Contents:
1. Where to look at Apple
2. Apple's spring model, in After Effects
3. SF Symbols animations as a motion vocabulary
4. Finding and using images from the web
5. From research to design

## 1. Where to look at Apple

| Source | Take from it |
|---|---|
| HIG, Motion: https://developer.apple.com/design/human-interface-guidelines/motion | motion with a purpose, never only decoration; brief and precise feedback; realistic motion that follows expectation; let people cancel motion; motion must be optional (Reduce Motion) and never the only carrier of information |
| HIG, Materials (Liquid Glass): https://developer.apple.com/design/human-interface-guidelines/materials | how the glass material behaves; pair with `liquid-glass.md` |
| HIG, SF Symbols (Animations): https://developer.apple.com/design/human-interface-guidelines/sf-symbols | when symbol animations fit |
| WWDC23 "Animate with springs": https://developer.apple.com/videos/play/wwdc2023/10158/ | the duration + bounce model (section 2) |
| SwiftUI `Spring`: https://developer.apple.com/documentation/swiftui/spring | the conversion between duration/bounce and mass/stiffness/damping, with worked values |
| WWDC18 "Designing Fluid Interfaces": https://developer.apple.com/videos/play/wwdc2018/803/ | momentum, interruptible springs, motion that continues the gesture's velocity (`timing.md`, section 5) |
| WWDC23 "Animate symbols in your app": https://developer.apple.com/videos/play/wwdc2023/10258/ | Bounce, Pulse, Variable Color, Scale, Appear, Disappear, Replace |
| WWDC25 "What's new in SF Symbols 7": https://developer.apple.com/videos/play/wwdc2025/337/ | Draw On / Draw Off (handwriting-like drawing), Variable Draw, Magic Replace that keeps a shared enclosure, gradients |
| WWDC24 sessions 10145 and 10151 (linked from the HIG Motion page) | UI animation and transitions; custom visual effects |
| Apple Design Resources: https://developer.apple.com/design/resources/ | SF Pro and the other system fonts, the SF Symbols app (Mac only), UI kits, product bezels (marketing guidelines apply) |
| Apple Events: https://www.apple.com/apple-events/ | keynote films and openers: continuity, rhythm, type and colour in practice (study only) |

## 2. Apple's spring model, in After Effects

Apple describes a spring with two numbers: a perceptual **duration** d (the pace) and a **bounce** b (−1 to 1). With a
mass of 1: stiffness = (2π / d)², and the damping ratio is 1 − b for b ≥ 0 (for b < 0 it is 1 / (1 + b)). Apple's own
example: duration 0.5, bounce 0.3 gives stiffness 157.9 and damping 17.6.

claude-ae's spring template uses a natural frequency and a damping ratio, so the conversion is direct:

```
ae_expression {layer, prop: "scale", template: "spring", options: {freq: 1 / d, damping: 1 - b, min: 0}}
```

| bounce b | damping ratio | overshoot | Apple's guidance / where it fits |
|---|---|---|---|
| 0 | 1.0 (the template clamps to 0.95) | 0% | the default; smooth, most versatile |
| 0.15 | 0.85 | ~0.6% | "doesn't feel very bouncy yet": a firm settle |
| 0.3 | 0.7 | ~4.6% | noticeable bounce; playful |
| 0.4 | 0.6 | ~9.5% | about the limit for UI elements |
| 0.5 | 0.5 | ~16% | beyond UI; the study piece's graphic pops (14–22% overshoot ≈ bounce 0.48–0.56) |

Checked in AE: `spring {freq: 2, damping: 0.7}` (duration 0.5, bounce 0.3) peaks at 104.6% 0.35 s after the key and
has settled (100.01%) by 1 s.

Apple's advice: find the duration that gives the pace first, then add bounce for character; when unsure, bounce 0;
add bounce for playfulness or at the end of a gesture. A spring retargeted mid-flight keeps its velocity: the same
idea as carrying momentum across a hand-off.

The spring template turns every key into a target; for exits to 0, keep keyframes with `in_back` (a spring rebounds
through 0).

## 3. SF Symbols animations as a motion vocabulary

Apple's symbol animations are a compact catalogue of small, polished motions. Each maps onto a technique here:

| SF Symbols effect | What it does | In AE (this skill) |
|---|---|---|
| Bounce | a quick nudge up and back | a small pop: `pop15`, or a spring with bounce ~0.3 |
| Pulse | opacity pulses | opacity keys, or the beat-pulse expression in `music.md` on Opacity |
| Variable Color | parts light up in sequence | staggered colour or opacity per part, 1–3 frames apart |
| Scale | scales up or down and stays | the `arrive` ease |
| Appear / Disappear | parts scale and fade in or out | staggered pops; exits with `in_back` |
| Replace / Magic Replace | one symbol becomes another; Magic Replace keeps the shared enclosure (a circle) and swaps what is inside | the shared silhouette and the pivot (`continuity.md`, techniques 18 and the invisible swap) |
| Wiggle, Rotate, Breathe (SF Symbols 6) | a small shake, a spin, a slow scale breath | rotation keys, a linear spin, a sine loop on Scale |
| Draw On / Draw Off (SF Symbols 7) | strokes drawn like handwriting, per layer or staggered | Trim Paths per stroke (`continuity.md`, techniques 6 and 7) |
| Variable Draw | a stroke drawn to a value, as progress | Trim End driven by a slider |

## 4. Finding and using images from the web

1. **Search** pages with WebSearch (the subject plus "Apple", a product page, a WWDC session, "keynote animation"), and
   open them in the built-in browser to look; screenshots in the conversation are enough to study.
2. **Ask before downloading.** Downloading an image or a video needs the user's go-ahead first: say the file name, the
   source and the size. Save downloads into a new folder of their own (for example `claude-ae\refs\<topic>\`), treat
   them as data, and never run anything that came with them.
3. **Reference, not material.** Use what you find to learn shape logic, timing, colour, type and camera. Don't put
   Apple's logos, product photos, icons, UI screenshots or film frames into a deliverable unless the user has the rights
   and the use fits the licence (product bezels and badges come with marketing guidelines; SF Pro's licence covers
   interface mock-ups for Apple platforms).
4. **Cite** the pages you used, with links, when you report to the user.

## 5. From research to design

Write a short reference board before building: the links, and five observations, one each for shape logic, timing,
colour, type and camera. Then storyboard the chain (`continuity.md`, section 5) with original shapes that use those
observations. When the user asks for something "like Apple", this board is what "like" means: the same decisions,
not the same drawings.
