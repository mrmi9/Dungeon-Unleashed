# Dungeon Unleashed Known Issues

Last updated: 2026-07-01

- Visuals are placeholder geometry.
- Audio is procedural placeholder audio.
- A first automated balance pass is in place, but manual playtest tuning is still required.
- Room layout data includes 22 `.tres` layouts, and the playable route is now a seeded 10-14 room graph with a 7-9 room main path and 3-5 branch rooms. It still uses one prototype room scene, not a full instantiated 20+ room-template layer or TileMap room set.
- The active dungeon seed is visible on the minimap, the main menu supports fixed seed entry/random seed mode, the result screen can replay the current seed, and `F3` opens a developer debug map panel with copy support. The panel is functional but still developer-facing rather than polished production UI.
- Relic drop tables are configurable `.tres` resources, but pity rules and deeper rarity tuning are not implemented.
- Boss fight is prototype-grade. It has a clearer phase transition pause, warning, and basic floor hazard arena pressure, but still needs final tuning.
- Resolution settings only include 1280x720, 1600x900, and 1920x1080.
- Basic UI layout has automated checks at 1280x720, 1600x900, and 1920x1080, but still needs final visual polish.
- Key rebinding supports movement, reload, interact, and pause; mouse shoot and weapon number slots are still fixed.
- Result screen uses grouped text sections, but still needs visual polish.
- Build is unsigned and may trigger a Windows security warning.
- Godot project headless startup, export generation, and zip packaging are verified. Exported `.exe` automatic startup validation is currently unreliable in CLI, so a human launch and full manual playthrough are still required.
