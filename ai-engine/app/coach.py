"""Pulse Coach — the AI health companion.

Pipeline (route → answer → format). This is deliberately a plain, typed
pipeline rather than a framework so it runs with zero extra dependencies and
stays debuggable. It maps cleanly onto **LangGraph** when you want branching,
memory, and tool nodes: each function below becomes a node, `route()` becomes a
conditional edge, and the dashboard `context` becomes graph state. Swap in
`langgraph` (see requirements.txt) without changing the HTTP surface.

Behaviour:
  - A known `promptKey` ('recovery' | 'plan' | 'workout') returns a
    deterministic, bilingual structured reply — works fully offline.
  - Otherwise, if an LLM provider is configured, the coach answers free-form,
    grounded in the user's current health numbers.
  - With no provider, it falls back to a safe deterministic message.
"""
from __future__ import annotations

from .models import CoachReply, CoachRequest
from .llm import get_provider, LLMUnavailable


def _np(req: CoachRequest) -> bool:
    return (req.lang or "np") == "np"


# ── Deterministic canned analyses (mirror the app's quick-prompt replies) ──
def _canned(req: CoachRequest) -> CoachReply | None:
    np = _np(req)
    key = req.promptKey
    if key == "recovery":
        return CoachReply(
            kind="analysis",
            title="Recovery कम भएको कारण" if np else "Why your recovery dropped",
            chips=[
                {"l": "Deep sleep", "v": "38 min", "d": "down"},
                {"l": "Resting HR", "v": "64 bpm", "d": "up"},
                {"l": "Stress load", "v": "Elevated", "d": "up"},
            ],
            rec=("आज हल्का गतिविधि गर्नुहोस्। ५ मिनेट breathing session गर्नुहोस्।" if np
                 else "Keep today light. Try a 5-min breathing session and sleep on time tonight."),
            conf=92,
            outcome=("भोलि Recovery ७५–८०+ हुन सक्छ यदि आज समयमा सुत्नुभयो।" if np
                     else "Recovery could reach 75–80+ tomorrow if you sleep on time tonight."),
        )
    if key == "plan":
        return CoachReply(
            kind="text",
            text=("आजको स्वास्थ्य योजना ☀️\n\n• बिहान: Strength training\n• दिउँसो: २.५L पानी\n"
                  "• साँझ: १०:१५ अघि सुत्ने तयारी\n• रातको दिनचर्या: ५ मिनेट breathing" if np
                  else "Today's plan ☀️\n\n• Morning: Strength training\n• Midday: Drink 2.5L water\n"
                       "• Evening: Wind down before 10:15 PM\n• Night: 5-min breathing session"),
        )
    if key == "workout":
        return CoachReply(
            kind="analysis",
            title="आज workout गर्न सकिन्छ" if np else "Yes — your body is ready",
            chips=[
                {"l": "Recovery score", "v": "89/100", "d": "up"},
                {"l": "Readiness", "v": "84/100", "d": "up"},
                {"l": "HRV", "v": "68ms", "d": "up"},
            ],
            rec=("Strength training वा HIIT उत्तम। राम्ररी warm-up र cool-down गर्नुहोस्।" if np
                 else "Strength or HIIT is ideal. Warm up well and don't skip your cool-down."),
            conf=96,
            outcome=("आजको workout पछि recovery कायम रहन सक्छ — राम्रो निद्रागरे।" if np
                     else "Recovery should hold strong post-workout if you sleep well tonight."),
        )
    return None


def _system_prompt(req: CoachRequest) -> str:
    scores = (req.context or {}).get("scores", {})
    vitals = (req.context or {}).get("vitals", {})
    lang = "Nepali (Devanagari)" if _np(req) else "English"
    return (
        "You are Pulse Coach, a concise, encouraging AI health companion inside a "
        "wearable app. Ground every claim in the user's data below; never invent numbers. "
        "Frame readings as wellness estimates, not medical diagnoses, and recommend a "
        "clinician for anything concerning.\n"
        f"Respond in {lang}. Keep it to 2–4 short sentences.\n\n"
        f"Current scores: {scores}\nLatest vitals: {vitals}"
    )


def run(req: CoachRequest) -> CoachReply:
    # 1) Deterministic path for the quick-prompt chips.
    canned = _canned(req)
    if canned is not None:
        return canned

    # 2) Grounded free-form answer via the configured LLM, if available.
    provider = get_provider()
    if provider is not None:
        try:
            result = provider.generate(_system_prompt(req), req.message)
            return CoachReply(kind="text", text=result.text, model=result.model, usage=result.usage)
        except LLMUnavailable:
            pass  # fall through to the safe default

    # 3) Offline fallback.
    return CoachReply(
        kind="text",
        text=("अहिले AI coach उपलब्ध छैन, तर तपाईंको data हेर्दा आज सन्तुलित दिन बनाउनुहोस् — "
              "हाइड्रेशन, हल्का गतिविधि र समयमा निद्रा।" if _np(req)
              else "The AI coach is offline right now, but based on your data: aim for a balanced "
                   "day — hydrate, keep activity light, and sleep on time."),
    )
