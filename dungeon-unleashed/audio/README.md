# Audio Asset Notes

Combat and interface feedback use the original PCM WAV pack in `audio/sfx/authored/`. The files are generated deterministically by `tools/generate_sfx_pack.py` from layered oscillators, filtered noise, envelopes, and fixed per-sound parameters. They do not contain third-party recordings or audio copied from another game.

`scripts/audio/SfxLibrary.gd` owns the event-key and weapon-key mapping. `AudioFeedback.gd` keeps a procedural fallback only as a diagnostic guard for unknown or missing SFX assets; supported production events must resolve to authored files.

Menu, three-biome combat, boss, victory, and defeat music use the original stereo PCM WAV pack in `audio/music/authored/`. `tools/generate_music_pack.py` rebuilds all seven tracks, while `scripts/audio/MusicLibrary.gd` owns track keys and loop policy. Runtime playback uses two Music-bus players for crossfades; no music is synthesized during gameplay.

Before final audio lock, perform speaker/headphone listening passes for loudness, loop perception, SFX masking, and crossfade timing.
