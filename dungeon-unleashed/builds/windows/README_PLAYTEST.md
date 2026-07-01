# Dungeon Unleashed Windows Prototype

Build date: 2026-07-01
Engine: Godot 4.7 stable
Renderer: GL Compatibility / OpenGL

## How To Run

Run `Dungeon Unleashed.exe`.

## Controls

- Move: `WASD`
- Aim: mouse
- Shoot: left mouse button
- Reload: `R`
- Switch weapons: `1`, `2`, `3`
- Interact with chests/shop items: `E`
- Pause: `Esc`
- Developer debug map: `F3`
- Settings can rebind movement, reload, interact, and pause keyboard controls.

## What To Test

- Start from the main menu and complete the seeded 12-15 room branching route.
- Try the main menu seed field: leave it blank for a random route, enter a number for a fixed route, and use Replay Seed on the result screen to reproduce the same route.
- Check whether the start, combat, reward, armory, healing, elite, shop, branch reward, late combat, and boss rooms feel visually and spatially distinct despite using placeholder art. Main-path length, branch count, branch placement, and selected room layouts now vary by generation seed, but this build still uses one prototype room scene with data-driven layouts.
- Check the top-right minimap seed label. If you report a map/layout issue, include this seed so the layout can be reproduced in development.
- Press `F3` to open the developer debug map panel. Use `Copy Map` when reporting route, seed, or room-connection issues.
- Verify combat rooms lock and unlock correctly.
- Collect rewards, open chests, replace weapons in armory rooms, recover in healing rooms, buy shop items, and choose relics.
- Check whether shop prices force a meaningful choice instead of letting you buy everything.
- Fight the boss, watch the phase-two arena floor hazards, and open the boss reward chest to finish the run.
- Try death and victory flows, then restart or return to main menu.
- Check Settings for Master, SFX, Music, Resolution, and Fullscreen persistence.
- Check that Settings, Pause, Relic Choice, and Result panels do not overlap the bottom-right input hint at 1280x720 or higher.

## Feedback

Use the included `PLAYTEST_FEEDBACK.md` template to record notes.
Check `KNOWN_ISSUES.md` before filing a bug.

## Known Prototype Limits

- Visuals are placeholder geometry.
- Audio is procedural placeholder audio, not final authored sound.
- Balance is first-pass and not final.
- Key rebinding covers movement, reload, interact, and pause; mouse shoot and weapon number slots are still fixed.
- The build is unsigned, so Windows may show a security warning.
