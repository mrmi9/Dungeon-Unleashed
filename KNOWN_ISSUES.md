# Dungeon Unleashed Known Issues

Last updated: 2026-07-01

## High Priority

- Full manual gameplay validation is still required on the exported Windows build. Godot project headless startup, export generation, and zip packaging have passed; exported `.exe` automatic startup validation is currently unreliable in CLI and should be confirmed by a human launch.
- Basic UI layout is now covered by an automated 1280x720 / 1600x900 / 1920x1080 smoke test, but manual visual review is still required for final spacing, hierarchy, and readability.
- A first automated balance pass is in place for route economy, shop prices, elite pressure, and boss health, but manual playtest tuning is still required.
- Boss fight is still prototype-grade. It now has a clear phase transition pause, warning, and basic floor hazard arena pressure, but still needs final encounter tuning.

## Medium Priority

- Visuals are placeholder geometry.
- Audio is procedural placeholder audio, not authored final sound.
- Room layout data now includes 22 `.tres` layouts, and the playable route is now a seeded 10-14 room graph with a 7-9 room main path and 3-5 branch rooms. It still uses one prototype room scene, not a true 20 to 30 distinct instantiated room-template layer or TileMap room set.
- The active dungeon seed is visible on the minimap, the main menu supports fixed seed entry/random seed mode, and the result screen can replay the current seed. The debug map text remains developer-facing rather than a polished in-game panel.
- Resolution settings support only three presets: 1280x720, 1600x900, 1920x1080.
- Key rebinding supports movement, reload, interact, and pause; mouse shoot and weapon number slots are still fixed.
- Relic rewards now use separate `.tres` drop table resources for reward rooms, shops, normal chests, premium chests, and boss chests, but pity rules and deeper rarity tuning are not implemented.
- Chest and shop presentation is functional but still visually plain.
- Result screen now uses grouped text sections, but still needs icons, stronger visual hierarchy, and final layout polish.

## Low Priority

- The Windows build is unsigned and may trigger Windows security warnings.
- There is no installer or auto-update flow.
- No external analytics or crash reporting is integrated.
- No localization pass has been done.

## Already Verified

- Main Godot scene starts in headless CLI.
- Windows release `.exe` export completed.
- Exported `.exe` automatic headless startup was attempted this round but is not counted as passed because the exported runner did not reliably quit from CLI.
- Full smoke test suite passes.
- Resource reference and scene `load_steps` checks pass.
- Windows prototype zip is generated.
