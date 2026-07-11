# Dungeon Unleashed Known Issues

Last updated: 2026-07-12

- Full manual three-biome playthrough validation is still required for pacing, difficulty, controls, audio balance, and final feel.
- Visuals mix original PNG/SVG atlases with remaining procedural fallback geometry; pixel density and final-art consistency are not locked.
- Rooms use independent data-driven layouts but still share one `CombatRoom` scene rather than a full authored room-template/TileMap layer.
- Boss mechanics and warnings are implemented but still need final difficulty and accessibility tuning.
- Reward pity and deterministic reward streams are automated, but full-run rarity distribution and selection rates still need manual tuning.
- The `F3` map panel is developer-facing rather than final player UI.
- Resolution presets are limited to 1280x720, 1600x900, and 1920x1080.
- Key rebinding covers movement, reload, interact, and pause; mouse shoot and number-key weapon slots remain fixed.
- The result screen, chests, shops, and lobby still need final visual hierarchy and presentation polish.
- The build is unsigned and may trigger a Windows security warning.
- Fixed seed replay assumes the same interaction order; it is deterministic replay, not recorded input playback.

Automated performance, room-flow, full-run, export, and packaged first-room checks pass. Human validation is still required for dense-hit readability and transition feel across several consecutive rooms.
