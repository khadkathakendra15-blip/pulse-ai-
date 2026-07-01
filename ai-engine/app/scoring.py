"""Composite health scoring — Python mirror of the backend ScoreService.

Kept here so the AI engine can score independently (e.g. for `/analyze` or
for grounding the coach) without a round-trip to the backend.
"""
from __future__ import annotations

from .models import Vitals

WEIGHTS = {"sleep": 0.30, "hrv": 0.25, "heart": 0.20, "stress": 0.10, "activity": 0.10, "recovery": 0.05}


def _clamp(n: float) -> int:
    return max(0, min(100, round(n)))


def derive_signals(v: Vitals) -> dict[str, int]:
    s: dict[str, int] = {}
    if v.sleepMinutes is not None:
        s["sleep"] = _clamp(v.sleepMinutes / 480 * 100)        # 8h ⇒ 100
    if v.hrv is not None:
        s["hrv"] = _clamp((v.hrv - 20) / 60 * 100)             # 20–80ms ⇒ 0–100
    if v.heartRate is not None:
        s["heart"] = _clamp((80 - v.heartRate) / 40 * 100)     # 40bpm best
    if v.stress is not None:
        s["stress"] = _clamp(100 - v.stress)
    if v.steps is not None:
        s["activity"] = _clamp(v.steps / 10000 * 100)
    overnight = [s[k] for k in ("sleep", "hrv", "heart") if k in s]
    if overnight:
        s["recovery"] = _clamp(sum(overnight) / len(overnight))
    return s


def _weighted(signals: dict[str, int], weights: dict[str, float]) -> int:
    total = wsum = 0.0
    for key, w in weights.items():
        if key in signals:
            total += signals[key] * w
            wsum += w
    return _clamp(total / wsum) if wsum else 0


def compute(signals: dict[str, int]) -> dict[str, int]:
    return {
        "health": _weighted(signals, WEIGHTS),
        "recovery": _weighted(signals, {"sleep": 0.4, "hrv": 0.35, "heart": 0.25}),
        "readiness": _weighted(signals, {"recovery": 0.5, "hrv": 0.3, "stress": 0.2}),
    }
