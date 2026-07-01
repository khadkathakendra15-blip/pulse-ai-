"""Request/response schemas for the AI engine."""
from __future__ import annotations

from typing import Any, Optional
from pydantic import BaseModel


class CoachRequest(BaseModel):
    message: str
    lang: str = "np"  # 'np' | 'en'
    promptKey: Optional[str] = None  # 'recovery' | 'plan' | 'workout'
    context: dict[str, Any] = {}  # dashboard payload from the backend


class AnalysisChip(BaseModel):
    l: str
    v: str
    d: str  # 'up' | 'down'


class CoachReply(BaseModel):
    kind: str  # 'text' | 'analysis'
    text: str = ""
    title: str = ""
    rec: str = ""
    conf: int = 0
    outcome: str = ""
    chips: list[AnalysisChip] = []
    model: Optional[str] = None
    usage: dict[str, Any] = {}


class Vitals(BaseModel):
    heartRate: Optional[float] = None
    hrv: Optional[float] = None
    spo2: Optional[float] = None
    steps: Optional[float] = None
    sleepMinutes: Optional[float] = None
    stress: Optional[float] = None
    temperature: Optional[float] = None


class AnalyzeRequest(BaseModel):
    vitals: Vitals


class AnalyzeResponse(BaseModel):
    health: int
    recovery: int
    readiness: int
    signals: dict[str, int]
