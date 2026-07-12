# Dungeon Unleashed Windows Playtest

Build date: 2026-07-12
Engine: Godot 4.7 stable
Renderer: GL Compatibility / OpenGL
Source checkpoint: `codex/relic-reward-pacing`
SHA-256: `85094A352F4087A22467582B51BFCF8F24940164401CC6F28DC07460F7B8BC2B`

## How To Run

Run `Dungeon Unleashed.exe`.

## Controls

- Move: `WASD`
- Aim: mouse or right stick
- Shoot: left mouse button or gamepad trigger
- Active skill: `Space` or gamepad face button
- Reload: `R`
- Switch weapons: `1`, `2`, `3`
- Interact: `E`
- Pause: `Esc`
- Developer debug map: `F3`

## Current Build

- Three connected biomes with independent layouts, enemies, terrain, music, and Boss encounters.
- Six playable characters, 40 weapons, 48 relics, Boss talents, event blessings, and statues.
- Original authored combat SFX and seven music tracks.
- Shooting hot path uses local ammo HUD updates, cached weapon icons, pooled SFX voices, and one aim-assist query per physics frame.
- Room-state minimap updates reuse existing markers, passive HUD work is cached/throttled, and combat text uses a bounded 48-entry pool.
- Reward-room and normal-chest Rare+ exposure pity; premium and Boss chests have Rare+ floors.
- Three legendary relics now support multi-shot, energy-sustain, and chain builds; full-run rarity rates are covered by deterministic simulation.
- Armory, shop, Boss, and cursed-event weapons use separate rarity tables with deterministic full-run rarity and weapon-form coverage.
- Fixed seed and Replay Seed reproduce route/layout, event rules, chest rolls, central choices, and shop stock when the same interaction order is followed.
- Keyboard/mouse and controller input are supported; controller deadzone and hint-switch thresholds are configurable.

## Playtest Focus

- Complete at least one full three-biome run or record where the run ended.
- Note the top-right seed for every route, reward, or room-layout issue.
- Check whether each biome, elite modifier, and Boss mechanic is readable during dense combat.
- Compare weapon and relic choices: identify which choices changed the way you played.
- Check shop/chest reward value and whether Rare+ pity feels too early or too late.
- Replay the same seed with the same route and interaction order; compare event, chest, choice, and shop results.
- Check Music/SFX balance with headphones or speakers.
- Hold fire with the pistol, shotgun, and a high-rate weapon; note any hitch on first shot, sustained fire, reload completion, or weapon switching.
- Watch for stalls when entering combat, starting a wave, clearing a room, spawning a reward, or claiming it; verify the minimap current-room marker remains correct.
- Create dense simultaneous hits with shotgun, chain, explosion, or rapid-fire weapons; check that combat text remains readable while capped at 48 entries.
- Test death, victory, restart, pause, settings persistence, keyboard/mouse, and controller input where available.

Use `PLAYTEST_FEEDBACK.md` for notes and check `KNOWN_ISSUES.md` before reporting a bug.

The packaged fixed-seed room runtime check passed before this build was launched for playtesting.
