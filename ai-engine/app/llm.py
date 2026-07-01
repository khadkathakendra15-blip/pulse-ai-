"""LLM provider abstraction for the Pulse Coach.

Default provider is **Anthropic Claude** via the official `anthropic` SDK.
Model defaults to `claude-opus-4-8` (override with `PULSE_LLM_MODEL`). The
client is created lazily so the engine boots and serves deterministic canned
replies even when no API key is configured.

Other providers (OpenAI, Gemini) are intentionally left as stubs — fill them in
only if you actually need a non-Claude path.
"""
from __future__ import annotations

import os
from typing import Optional


class LLMResult:
    def __init__(self, text: str, model: str, usage: dict):
        self.text = text
        self.model = model
        self.usage = usage


class LLMUnavailable(RuntimeError):
    """Raised when no provider is configured or the call fails."""


class AnthropicProvider:
    def __init__(self) -> None:
        self.model = os.environ.get("PULSE_LLM_MODEL", "claude-opus-4-8")
        self._client = None

    def _client_or_raise(self):
        if self._client is not None:
            return self._client
        if not os.environ.get("ANTHROPIC_API_KEY"):
            raise LLMUnavailable("ANTHROPIC_API_KEY is not set")
        try:
            import anthropic  # imported lazily — optional at boot
        except ImportError as e:  # pragma: no cover
            raise LLMUnavailable("anthropic SDK not installed") from e
        self._client = anthropic.Anthropic()
        return self._client

    def generate(self, system: str, user: str, max_tokens: int = 1024) -> LLMResult:
        client = self._client_or_raise()
        try:
            msg = client.messages.create(
                model=self.model,
                max_tokens=max_tokens,
                system=system,
                messages=[{"role": "user", "content": user}],
            )
        except Exception as e:  # surface as engine-level unavailability
            raise LLMUnavailable(str(e)) from e

        text = "".join(b.text for b in msg.content if getattr(b, "type", None) == "text")
        usage = {
            "input_tokens": getattr(msg.usage, "input_tokens", None),
            "output_tokens": getattr(msg.usage, "output_tokens", None),
        }
        return LLMResult(text=text, model=msg.model, usage=usage)


def get_provider() -> Optional[AnthropicProvider]:
    """Return the configured provider, or None to force deterministic replies."""
    name = os.environ.get("PULSE_LLM_PROVIDER", "anthropic").lower()
    if name == "anthropic":
        return AnthropicProvider()
    # 'openai' / 'gemini' — wire the respective SDK here if needed.
    return None
