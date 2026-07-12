# Dungeon Unleashed Known Issues

Last updated: 2026-07-12

## High Priority

- Full manual gameplay validation is still required on the exported Windows build. Godot project headless startup, export generation, zip packaging, and exported `.exe` runtime room-spawn validation have passed; a human full playthrough is still required for controls, audio, and pacing.
- Basic UI layout is now covered by an automated 1280x720 / 1600x900 / 1920x1080 smoke test, but manual visual review is still required for final spacing, hierarchy, and readability.
- A first automated balance pass is in place for route economy, shop prices, elite pressure, and boss health, but manual playtest tuning is still required.
- The three Boss encounters now have distinct signature attacks, second-phase mechanics, warnings, animation states, and authored audio, but still need full-run difficulty and accessibility tuning.

## Medium Priority

- Visuals now mix original PNG/SVG action atlases, content icons, biome floors, surface atlases, trim atlases, telegraphs, and procedural fallback geometry. The remaining fallbacks and inconsistent pixel density still need a unified final-art pass.
- Combat and music use 54 original authored SFX and 7 original authored music tracks. Final loudness balance, voice priority, long-loop fatigue, and speaker/headphone review are still required.
- The playable route is a seeded three-biome graph with independent layout pools and special rooms, but rooms still share one data-driven `CombatRoom` scene instead of a true authored room-template/TileMap layer.
- The active dungeon seed now reproduces route/layout generation, central relic/talent/blessing/statue choices, room event rules, chest rolls, and shop stock when the same interaction order is followed. `F3` exposes the seed/map for debugging, but the panel is still developer-facing rather than polished production UI; this is deterministic replay, not recorded input playback.
- Resolution settings support only three presets: 1280x720, 1600x900, 1920x1080.
- Key rebinding supports movement, reload, interact, and pause; mouse shoot and weapon number slots are still fixed.
- Relic rewards now have per-source `.tres` drop tables, shared Rare+ exposure pity for reward rooms/normal chests, Rare+ floors for premium/Boss chests, and deterministic full-run distribution coverage. Manual playtests are still required for perceived value and build-selection tuning.
- Weapon rewards now use per-source `.tres` tables for armories, shops, Boss chests, and cursed events, with deterministic full-run rarity and weapon-form coverage. Manual playtests are still required for replacement decisions and perceived shop value.
- Chest and shop presentation is functional but still visually plain.
- Result screen now uses a victory/defeat icon, a compact four-metric strip, six icon-labelled detail sections, and one horizontal action row. Final art styling and broader manual readability review are still required.

## Low Priority

- The Windows build is unsigned and may trigger Windows security warnings.
- There is no installer or auto-update flow.
- No external analytics or crash reporting is integrated.
- Simplified Chinese is the default player-facing language and is covered by a dedicated residue/performance smoke test. Additional locales are not planned for v1.

## Already Verified

- Main Godot scene starts in headless CLI.
- Three connected biomes, three Bosses, six characters, 40 weapons, 48 relics, 18 normal enemy variants, six elite modifiers, the lobby/codex/training flow, and controller input contracts are covered by automated smoke tests.
- Original authored SFX/music resources, biome floor/surface/trim visuals, enemy/Boss action atlases, and content icon registries are imported and validated by the content pipeline.
- Relic reward pacing covers shared miss counting, one-slot Rare+ guarantees, source hard floors, Shop isolation, and run reset.
- A 1,500-run production-config simulation covers real ownership filtering, random/highest-rarity selection strategies, all five relic sources, deterministic replay, and bounded Rare+/Epic+/Legendary rates.
- A 3,000-run production-config simulation covers all guaranteed armory/Boss rewards, shop listings, one-in-six cursed events, rarity floors, seven weapon classes, five fire modes, deterministic replay, and bounded build-form rates.
- Named run/room reward streams cover same-seed replay, cross-source relic RNG isolation, event/chest/shop output, menu seed application, and full-run completion.
- Windows release `.exe` export completed.
- Exported `.exe` startup and first-room enemy spawning are verified through the OpenGL/Compatibility runtime room-spawn check.
- Full smoke test suite passes.
- Complete Chinese result formatting, result summary icons, compact/expanded result modes, and 1280x720 result layout are covered by automated smoke tests.
- Resource reference and scene `load_steps` checks pass.
- Windows prototype zip is generated.
