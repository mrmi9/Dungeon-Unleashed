#!/usr/bin/env python3
"""Generate the original Dungeon Unleashed authored SFX pack.

The generator uses deterministic synthesis and the Python standard library.
No third-party recordings, samples, or copyrighted game audio are used.
"""

from __future__ import annotations

import hashlib
import math
import random
import struct
import wave
from dataclasses import dataclass
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "audio" / "sfx" / "authored"


@dataclass(frozen=True)
class SoundSpec:
    duration: float
    start_hz: float
    end_hz: float
    wave: str = "sine"
    noise: float = 0.0
    harmonic: float = 0.2
    pulse_hz: float = 0.0
    impact: float = 0.0


SPECS = {
    "weapon_sidearm": SoundSpec(0.10, 920, 310, "square", 0.12, 0.14, 0, 0.7),
    "weapon_shotgun": SoundSpec(0.18, 240, 90, "triangle", 0.82, 0.12, 0, 1.0),
    "weapon_launcher": SoundSpec(0.24, 170, 58, "square", 0.38, 0.36, 0, 0.9),
    "weapon_laser": SoundSpec(0.17, 720, 1640, "sine", 0.08, 0.5, 34, 0.25),
    "weapon_melee": SoundSpec(0.16, 280, 780, "triangle", 0.55, 0.18, 0, 0.4),
    "weapon_staff": SoundSpec(0.23, 410, 970, "sine", 0.15, 0.52, 18, 0.18),
    "weapon_core": SoundSpec(0.25, 210, 680, "square", 0.2, 0.5, 12, 0.55),
    "hit": SoundSpec(0.10, 300, 145, "triangle", 0.65, 0.12, 0, 0.8),
    "crit": SoundSpec(0.18, 760, 1320, "square", 0.22, 0.45, 25, 0.7),
    "kill": SoundSpec(0.20, 250, 80, "sine", 0.28, 0.35, 0, 0.45),
    "hurt": SoundSpec(0.24, 155, 72, "square", 0.36, 0.22, 0, 0.85),
    "hp_heal": SoundSpec(0.28, 430, 980, "sine", 0.04, 0.5, 13, 0.1),
    "low_health": SoundSpec(0.30, 205, 118, "square", 0.12, 0.25, 7, 0.55),
    "low_health_heartbeat": SoundSpec(0.20, 126, 92, "sine", 0.04, 0.32, 5, 1.0),
    "low_health_recover": SoundSpec(0.28, 330, 720, "sine", 0.03, 0.45, 10, 0.12),
    "clear": SoundSpec(0.42, 392, 880, "sine", 0.03, 0.55, 8, 0.16),
    "chest": SoundSpec(0.36, 260, 780, "triangle", 0.12, 0.48, 15, 0.42),
    "reward": SoundSpec(0.32, 620, 1120, "sine", 0.02, 0.5, 17, 0.1),
    "buy": SoundSpec(0.20, 510, 850, "triangle", 0.04, 0.38, 20, 0.45),
    "fail": SoundSpec(0.22, 210, 96, "square", 0.16, 0.2, 9, 0.5),
    "energy_empty": SoundSpec(0.25, 310, 108, "square", 0.1, 0.28, 14, 0.42),
    "reload_ready": SoundSpec(0.19, 460, 1040, "triangle", 0.08, 0.4, 0, 0.75),
    "skill_fail": SoundSpec(0.22, 280, 130, "square", 0.12, 0.24, 11, 0.42),
    "skill_ready": SoundSpec(0.30, 520, 1280, "sine", 0.03, 0.5, 16, 0.18),
    "passive_focus": SoundSpec(0.26, 680, 1260, "sine", 0.02, 0.58, 22, 0.15),
    "passive_guard": SoundSpec(0.28, 220, 470, "square", 0.1, 0.34, 8, 0.62),
    "passive_energy": SoundSpec(0.27, 430, 1090, "triangle", 0.05, 0.58, 18, 0.2),
    "passive_speed": SoundSpec(0.20, 560, 1480, "sine", 0.14, 0.4, 31, 0.25),
    "passive_burst": SoundSpec(0.25, 260, 90, "triangle", 0.72, 0.2, 0, 0.92),
    "passive_support": SoundSpec(0.32, 390, 860, "sine", 0.03, 0.62, 12, 0.12),
    "passive_trigger": SoundSpec(0.24, 480, 750, "triangle", 0.05, 0.42, 14, 0.28),
    "blessing_clear": SoundSpec(0.38, 520, 1180, "sine", 0.02, 0.64, 9, 0.12),
    "blessing_kill": SoundSpec(0.28, 390, 170, "square", 0.18, 0.36, 15, 0.52),
    "blessing_guard": SoundSpec(0.30, 250, 540, "triangle", 0.1, 0.42, 7, 0.6),
    "blessing_resonance": SoundSpec(0.42, 360, 1320, "sine", 0.02, 0.7, 11, 0.1),
    "blessing_trigger": SoundSpec(0.30, 440, 920, "sine", 0.04, 0.52, 13, 0.2),
    "statue_skill": SoundSpec(0.36, 300, 790, "square", 0.08, 0.5, 9, 0.52),
    "statue_trigger": SoundSpec(0.34, 340, 690, "triangle", 0.04, 0.58, 8, 0.32),
    "statue_attune": SoundSpec(0.48, 390, 1260, "sine", 0.02, 0.72, 7, 0.18),
    "armor_gain": SoundSpec(0.22, 390, 720, "triangle", 0.08, 0.4, 0, 0.55),
    "armor_block": SoundSpec(0.16, 290, 190, "square", 0.42, 0.24, 0, 1.0),
    "projectile_block": SoundSpec(0.14, 860, 390, "triangle", 0.35, 0.4, 0, 1.0),
    "armor_break": SoundSpec(0.30, 310, 72, "square", 0.68, 0.22, 0, 0.95),
    "danger_warning": SoundSpec(0.22, 360, 570, "square", 0.08, 0.28, 10, 0.42),
    "danger_warning_line": SoundSpec(0.18, 720, 390, "square", 0.1, 0.34, 18, 0.4),
    "danger_warning_heavy": SoundSpec(0.34, 180, 330, "square", 0.2, 0.42, 6, 0.85),
    "enemy_summon_windup": SoundSpec(0.42, 180, 760, "square", 0.16, 0.52, 9, 0.32),
    "enemy_support_windup": SoundSpec(0.38, 350, 980, "sine", 0.05, 0.62, 12, 0.15),
    "enemy_shield_bash_windup": SoundSpec(0.30, 160, 310, "triangle", 0.38, 0.28, 7, 0.8),
    "enemy_action_windup": SoundSpec(0.30, 270, 610, "square", 0.12, 0.36, 11, 0.4),
    "boss_phase": SoundSpec(0.62, 95, 330, "square", 0.26, 0.62, 5, 1.0),
    "boss_died": SoundSpec(0.78, 130, 42, "triangle", 0.62, 0.38, 0, 1.0),
    "victory": SoundSpec(0.72, 440, 1320, "sine", 0.02, 0.72, 7, 0.18),
    "defeat": SoundSpec(0.74, 250, 72, "sine", 0.16, 0.48, 4, 0.45),
}


def oscillator(kind: str, phase: float) -> float:
    sine = math.sin(phase)
    if kind == "square":
        return math.tanh(sine * 3.0)
    if kind == "triangle":
        return (2.0 / math.pi) * math.asin(sine)
    return sine


def render(name: str, spec: SoundSpec) -> list[int]:
    frame_count = max(1, round(spec.duration * SAMPLE_RATE))
    seed = int.from_bytes(hashlib.sha256(name.encode()).digest()[:8], "little")
    rng = random.Random(seed)
    phase = 0.0
    harmonic_phase = 0.0
    filtered_noise = 0.0
    samples: list[float] = []

    for frame in range(frame_count):
        progress = frame / max(1, frame_count - 1)
        curved = progress * progress * (3.0 - 2.0 * progress)
        frequency = max(25.0, spec.start_hz + (spec.end_hz - spec.start_hz) * curved)
        phase += math.tau * frequency / SAMPLE_RATE
        harmonic_phase += math.tau * frequency * 1.997 / SAMPLE_RATE

        attack = min(1.0, frame / max(1.0, SAMPLE_RATE * 0.006))
        release_seconds = min(0.12, spec.duration * 0.48)
        release = min(1.0, (frame_count - frame) / max(1.0, SAMPLE_RATE * release_seconds))
        envelope = attack * release * (1.0 - 0.24 * progress)
        pulse = 1.0
        if spec.pulse_hz > 0.0:
            pulse_phase = math.tau * spec.pulse_hz * frame / SAMPLE_RATE
            pulse = 0.68 + 0.32 * max(0.0, math.sin(pulse_phase))

        raw_noise = rng.uniform(-1.0, 1.0)
        filtered_noise = filtered_noise * 0.62 + raw_noise * 0.38
        body = oscillator(spec.wave, phase)
        body += math.sin(harmonic_phase) * spec.harmonic
        body += filtered_noise * spec.noise

        impact_envelope = math.exp(-progress * 36.0)
        impact = rng.uniform(-1.0, 1.0) * spec.impact * impact_envelope
        samples.append((body * pulse + impact) * envelope)

    peak = max(max(abs(value) for value in samples), 0.001)
    gain = 0.88 / peak
    return [max(-32768, min(32767, round(value * gain * 32767))) for value in samples]


def write_wav(path: Path, samples: list[int]) -> None:
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(b"".join(struct.pack("<h", sample) for sample in samples))


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, spec in SPECS.items():
        write_wav(OUTPUT_DIR / f"{name}.wav", render(name, spec))
    print(f"Generated {len(SPECS)} original SFX in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
