"""Deterministic, explainable task-to-skill routing."""

from __future__ import annotations

import re
from dataclasses import dataclass

from .catalog import Skill


TOKEN_RE = re.compile(r"[a-z0-9][a-z0-9.-]*")


@dataclass(frozen=True)
class Route:
    skill: Skill
    score: int
    reasons: tuple[str, ...]


def _normalise(text: str) -> tuple[str, set[str]]:
    lowered = text.casefold()
    return lowered, set(TOKEN_RE.findall(lowered))


def rank(prompt: str, skills: list[Skill], limit: int = 3) -> list[Route]:
    if not prompt or not prompt.strip():
        return []
    lowered, tokens = _normalise(prompt)
    routes: list[Route] = []
    for skill in skills:
        score = 0
        reasons: list[str] = []
        for keyword in skill.keywords:
            key = keyword.casefold()
            if " " in key and key in lowered:
                score += 8
                reasons.append(f"phrase:{keyword}")
            elif key in tokens:
                score += 3
                reasons.append(f"token:{keyword}")
        category = skill.category.casefold()
        if category in tokens:
            score += 2
            reasons.append(f"category:{skill.category}")
        if score:
            routes.append(Route(skill=skill, score=score, reasons=tuple(reasons)))
    routes.sort(key=lambda item: (-item.score, item.skill.risk_class, item.skill.id))
    return routes[:limit]


def authority_warning(prompt: str, route: Route | None) -> str | None:
    if route is None:
        return "No confident route; gather target, platform, symptom, and intended outcome."
    mutation_words = {"apply", "change", "delete", "disable", "enable", "install", "remove", "restart", "reboot", "restore", "reset", "set", "update"}
    _, tokens = _normalise(prompt)
    if tokens & mutation_words and route.skill.risk_class != "R0":
        return f"{route.skill.risk_class} mutation: explicit target, authority, preview, verification, and recovery are required."
    return None
