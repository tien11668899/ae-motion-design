# ae-motion-design

A [Claude Code](https://claude.com/claude-code) skill for motion design in Adobe After Effects, driven through
[claude-ae](https://github.com/tien11668899/claude-ae).

給 Claude Code 用的動態設計 skill：透過 claude-ae 操作 After Effects，做出形狀連續、節奏準確、畫面講究的動畫。

## What it covers

| File | Topic |
|---|---|
| `SKILL.md` | the core idea (one continuous chain of shapes), the look, workflow, quick reference |
| `references/continuity.md` | how one shape becomes the next: grammar, an analysed 98-second chain, 18 techniques with AE builds |
| `references/timing.md` | rhythm and easing measured frame by frame, as AE influences and cubic-beziers |
| `references/color.md` | colour use and palette structure, colour in motion |
| `references/typography-layout.md` | type, kinetic type, composition, spacing, stroke weights |
| `references/blur.md` | motion blur versus crisp frames, blur as light and transition |
| `references/music.md` | measuring a soundtrack and syncing to it |
| `references/camera-effects.md` | 3D camera moves and rigs, depth of field, light, effects by job |
| `references/liquid-glass.md` | two Liquid Glass rigs built from AE's own effects |
| `references/research.md` | finding references; Apple's HIG, spring model and SF Symbols vocabulary in AE terms |
| `references/claude-ae.md` | driving AE with the claude-ae tools: property paths, matchNames, gotchas |
| `references/measuring.md`, `scripts/measure.ps1` | measuring a reference video's motion, look and soundtrack (PowerShell + inline C#, no Python) |

## Install

Copy this folder to `~/.claude/skills/ae-motion-design` (on Windows `%USERPROFILE%\.claude\skills\ae-motion-design`).
Claude Code picks it up automatically.

## Requirements

- Adobe After Effects (tested on AE 2023, 23.0) with the claude-ae bridge running.
- Windows PowerShell 5.1 for `scripts/measure.ps1`.

## Notes

- The numbers were measured from a publicly broadcast keynote opener, for study. The skill holds measurements and
  descriptions only: no frames, audio, logos or other material from that film.
- Some paths and font notes describe the author's machine (`C:\Users\user\...`); adjust them for yours.
