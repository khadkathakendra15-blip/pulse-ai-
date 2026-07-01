"""Pulse AI — AI engine (FastAPI).

Endpoints:
  GET  /health          liveness
  POST /coach           Pulse Coach reply (deterministic or LLM-grounded)
  POST /analyze         compute composite scores from raw vitals
"""
from __future__ import annotations

from fastapi import FastAPI

from . import coach, scoring
from .models import AnalyzeRequest, AnalyzeResponse, CoachReply, CoachRequest

app = FastAPI(title="Pulse AI Engine", version="1.0.0")


@app.get("/")
def root() -> dict:
    return {
        "service": "Pulse AI Engine",
        "status": "ok",
        "endpoints": ["GET /health", "POST /analyze", "POST /coach"],
        "docs": "/docs",
    }


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/coach", response_model=CoachReply)
def coach_endpoint(req: CoachRequest) -> CoachReply:
    return coach.run(req)


@app.post("/analyze", response_model=AnalyzeResponse)
def analyze_endpoint(req: AnalyzeRequest) -> AnalyzeResponse:
    signals = scoring.derive_signals(req.vitals)
    composite = scoring.compute(signals)
    return AnalyzeResponse(
        health=composite["health"],
        recovery=composite["recovery"],
        readiness=composite["readiness"],
        signals=signals,
    )
