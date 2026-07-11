#!/usr/bin/env python3
"""Generate original authored music loops for Dungeon Unleashed."""

from __future__ import annotations

import hashlib
import math
import random
import struct
import wave
from dataclasses import dataclass
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "audio" / "music" / "authored"
MINOR_SCALE = (0, 2, 3, 5, 7, 8, 10)


@dataclass(frozen=True)
class MusicSpec:
    bpm: float
    bars: int
    root_midi: int
    progression: tuple[int, ...]
    melody: tuple[int, ...]
    intensity: float
    percussion: float


TRACKS = {
    "menu": MusicSpec(92, 4, 45, (0, 5, 3, 0), (0, 2, 4, 2, 5, 4, 2, 0), 0.52, 0.18),
    "biome_outer_warrens": MusicSpec(112, 4, 43, (0, 3, 5, 0), (0, 2, 3, 4, 2, 5, 4, 2), 0.68, 0.52),
    "biome_iron_catacombs": MusicSpec(120, 4, 41, (0, 1, 5, 0), (0, 4, 2, 5, 1, 4, 3, 2), 0.76, 0.68),
    "biome_void_foundry": MusicSpec(124, 4, 40, (0, 4, 1, 0), (0, 6, 2, 5, 1, 4, 6, 3), 0.78, 0.62),
    "boss": MusicSpec(132, 4, 38, (0, 1, 0, 5), (0, 1, 4, 1, 5, 1, 6, 4), 0.92, 0.9),
    "victory": MusicSpec(120, 2, 48, (0, 3), (0, 2, 4, 6, 4, 5, 6, 7), 0.72, 0.38),
    "defeat": MusicSpec(90, 2, 43, (0, 5), (4, 3, 2, 1, 0, -1, -2, -3), 0.56, 0.22),
}


def midi_hz(note: int) -> float:
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def scale_note(root: int, degree: int) -> int:
    octave, index = divmod(degree, len(MINOR_SCALE))
    return root + octave * 12 + MINOR_SCALE[index]


def note_envelope(position: float, power: float = 0.65) -> float:
    return max(0.0, math.sin(math.pi * min(max(position, 0.0), 1.0))) ** power


def render(track_id: str, spec: MusicSpec) -> tuple[list[int], float]:
    seconds_per_beat = 60.0 / spec.bpm
    duration = spec.bars * 4.0 * seconds_per_beat
    frame_count = round(duration * SAMPLE_RATE)
    seed = int.from_bytes(hashlib.sha256(track_id.encode()).digest()[:8], "little")
    rng = random.Random(seed)
    noise_values = [rng.uniform(-1.0, 1.0) for _ in range(frame_count)]
    left: list[float] = []
    right: list[float] = []

    for frame in range(frame_count):
        time = frame / SAMPLE_RATE
        beat = time / seconds_per_beat
        bar_index = int(beat // 4.0)
        bar_position = beat % 4.0
        beat_index = int(beat)
        beat_position = beat % 1.0
        eighth_index = int(beat * 2.0)
        eighth_position = (beat * 2.0) % 1.0
        chord_degree = spec.progression[bar_index % len(spec.progression)]
        chord_notes = (
            scale_note(spec.root_midi, chord_degree),
            scale_note(spec.root_midi, chord_degree + 2),
            scale_note(spec.root_midi, chord_degree + 4),
        )

        bar_time = bar_position * seconds_per_beat
        chord_envelope = note_envelope(bar_position / 4.0, 0.42)
        pad = 0.0
        for voice_index, note in enumerate(chord_notes):
            frequency = midi_hz(note + 12)
            phase = math.tau * frequency * bar_time
            pad += (math.sin(phase) + math.sin(phase * 2.01) * 0.16) * (0.11 - voice_index * 0.012)
        pad *= chord_envelope

        local_beat_time = beat_position * seconds_per_beat
        bass_note = scale_note(spec.root_midi - 12, chord_degree)
        bass_frequency = midi_hz(bass_note)
        bass_envelope = note_envelope(beat_position, 0.5)
        bass = math.sin(math.tau * bass_frequency * local_beat_time) * bass_envelope * 0.23
        bass += math.sin(math.tau * bass_frequency * 2.0 * local_beat_time) * bass_envelope * 0.045

        arp_degree = chord_degree + (0, 2, 4, 2)[eighth_index % 4]
        arp_frequency = midi_hz(scale_note(spec.root_midi + 12, arp_degree))
        local_eighth_time = eighth_position * seconds_per_beat * 0.5
        arp_envelope = note_envelope(eighth_position, 0.82)
        arp = math.sin(math.tau * arp_frequency * local_eighth_time) * arp_envelope * 0.14
        arp_pan = -0.42 if eighth_index % 2 == 0 else 0.42

        melody_degree = spec.melody[beat_index % len(spec.melody)]
        melody_frequency = midi_hz(scale_note(spec.root_midi + 12, melody_degree))
        melody_envelope = note_envelope(beat_position, 0.72)
        lead = math.sin(math.tau * melody_frequency * local_beat_time) * melody_envelope * 0.105
        lead += math.sin(math.tau * melody_frequency * 3.0 * local_beat_time) * melody_envelope * 0.018

        kick_time = local_beat_time
        kick_frequency = 82.0 - 34.0 * min(1.0, kick_time / max(seconds_per_beat * 0.35, 0.001))
        kick = math.sin(math.tau * kick_frequency * kick_time) * math.exp(-kick_time * 15.0) * 0.28
        snare = 0.0
        if beat_index % 4 in (1, 3):
            snare = noise_values[frame] * math.exp(-kick_time * 22.0) * 0.13
        hats = 0.0
        if eighth_index % 2 == 1:
            hats = noise_values[frame] * math.exp(-local_eighth_time * 55.0) * 0.045
        drums = (kick + snare + hats) * spec.percussion

        master = spec.intensity
        if track_id in ("victory", "defeat"):
            remaining = max(0.0, duration - time)
            master *= min(1.0, remaining / max(seconds_per_beat * 0.9, 0.001))

        center = (pad + bass + lead + drums) * master
        left.append(center + arp * (1.0 - arp_pan) * spec.intensity)
        right.append(center + arp * (1.0 + arp_pan) * spec.intensity)

    peak = max(max(abs(value) for value in left), max(abs(value) for value in right), 0.001)
    gain = 0.82 / peak
    samples: list[int] = []
    for left_value, right_value in zip(left, right):
        samples.append(max(-32768, min(32767, round(left_value * gain * 32767))))
        samples.append(max(-32768, min(32767, round(right_value * gain * 32767))))
    return samples, duration


def write_wav(path: Path, samples: list[int]) -> None:
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(b"".join(struct.pack("<h", sample) for sample in samples))


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for track_id, spec in TRACKS.items():
        samples, duration = render(track_id, spec)
        write_wav(OUTPUT_DIR / f"{track_id}.wav", samples)
        print(f"{track_id}: {duration:.2f}s")
    print(f"Generated {len(TRACKS)} original music tracks in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
