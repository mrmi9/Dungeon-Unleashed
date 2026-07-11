# Dungeon Unleashed Known Issues

Last updated: 2026-07-11

## High Priority

- Full manual gameplay validation is still required on the exported Windows build. Godot project headless startup, export generation, zip packaging, and exported `.exe` runtime room-spawn validation have passed; a human full playthrough is still required for controls, audio, and pacing.
- Basic UI layout is now covered by an automated 1280x720 / 1600x900 / 1920x1080 smoke test, but manual visual review is still required for final spacing, hierarchy, and readability.
- A first automated balance pass is in place for route economy, shop prices, elite pressure, and boss health, but manual playtest tuning is still required.
- The three Boss encounters now have distinct signature attacks, second-phase mechanics, warnings, animation states, and authored audio, but still need full-run difficulty and accessibility tuning.

## Medium Priority

- Visuals now mix original PNG/SVG action atlases, content icons, biome floors, surface atlases, trim atlases, telegraphs, and procedural fallback geometry. The remaining fallbacks and inconsistent pixel density still need a unified final-art pass.
- Combat and music use 54 original authored SFX and 7 original authored music tracks. Final loudness balance, voice priority, long-loop fatigue, and speaker/headphone review are still required.
- The playable route is a seeded three-biome graph with independent layout pools and special rooms, but rooms still share one data-driven `CombatRoom` scene instead of a true authored room-template/TileMap layer.
- The active dungeon seed is visible on the minimap, the main menu supports fixed seed entry/random seed mode, the result screen can replay the current seed, and `F3` opens a developer debug map panel with copy support. The panel is functional but still developer-facing rather than polished production UI.
- Resolution settings support only three presets: 1280x720, 1600x900, 1920x1080.
- Key rebinding supports movement, reload, interact, and pause; mouse shoot and weapon number slots are still fixed.
- Relic rewards now have per-source `.tres` drop tables, shared Rare+ exposure pity for reward rooms/normal chests, and Rare+ floors for premium/Boss chests. Full-run rarity distribution and selection-rate tuning still require simulation plus manual playtests.
- Chest and shop presentation is functional but still visually plain.
- Result screen now uses grouped text sections, but still needs icons, stronger visual hierarchy, and final layout polish.

## Low Priority

- The Windows build is unsigned and may trigger Windows security warnings.
- There is no installer or auto-update flow.
- No external analytics or crash reporting is integrated.
- No localization pass has been done.

## Already Verified

- Main Godot scene starts in headless CLI.
- Three connected biomes, three Bosses, six characters, 40 weapons, 45 relics, 18 normal enemy variants, six elite modifiers, the lobby/codex/training flow, and controller input contracts are covered by automated smoke tests.
- Original authored SFX/music resources, biome floor/surface/trim visuals, enemy/Boss action atlases, and content icon registries are imported and validated by the content pipeline.
- Relic reward pacing covers shared miss counting, one-slot Rare+ guarantees, source hard floors, Shop isolation, and run reset.
- Windows release `.exe` export completed.
- Exported `.exe` startup and first-room enemy spawning are verified through the OpenGL/Compatibility runtime room-spawn check.
- Full smoke test suite passes.
- Resource reference and scene `load_steps` checks pass.
- Windows prototype zip is generated.
