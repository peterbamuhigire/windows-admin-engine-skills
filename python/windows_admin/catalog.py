"""Load and validate the JSON-compatible YAML catalogue without dependencies."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ALLOWED_RISKS = {"R0", "R1", "R2", "R3", "R4", "R5"}
ALLOWED_MATURITY = {
    "SUPPORTED", "LAB_VALIDATED", "PARTIAL", "EXPERIMENTAL",
    "BLOCKED", "NOT_ASSESSED", "DEPRECATED",
}


@dataclass(frozen=True)
class Skill:
    id: str
    path: str
    category: str
    trigger: str
    exclusions: tuple[str, ...]
    dependencies: tuple[str, ...]
    platforms: tuple[str, ...]
    risk_class: str
    script_tier: str
    maturity: str
    owner: str
    last_verified: str
    sources: tuple[str, ...]
    keywords: tuple[str, ...]


def load_json_yaml(path: Path) -> dict[str, Any]:
    """Read a YAML 1.2 file encoded as the JSON-compatible subset."""
    try:
        data = json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"Cannot load {path}: {exc}") from exc
    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain an object at the root")
    return data


def load_catalog(repo: Path) -> list[Skill]:
    data = load_json_yaml(repo / "engine" / "catalog.yaml")
    if data.get("schema_version") != "1.0":
        raise ValueError("Unsupported catalogue schema_version")
    raw_skills = data.get("skills")
    if not isinstance(raw_skills, list) or not raw_skills:
        raise ValueError("Catalogue skills must be a non-empty list")
    skills: list[Skill] = []
    seen: set[str] = set()
    for index, raw in enumerate(raw_skills):
        if not isinstance(raw, dict):
            raise ValueError(f"skills[{index}] must be an object")
        missing = {
            "id", "path", "category", "trigger", "exclusions", "dependencies",
            "platforms", "risk_class", "script_tier", "maturity", "owner",
            "last_verified", "sources", "keywords",
        } - raw.keys()
        if missing:
            raise ValueError(f"skills[{index}] missing {sorted(missing)}")
        if raw["id"] in seen:
            raise ValueError(f"Duplicate skill id: {raw['id']}")
        if raw["risk_class"] not in ALLOWED_RISKS:
            raise ValueError(f"Invalid risk class for {raw['id']}")
        if raw["maturity"] not in ALLOWED_MATURITY:
            raise ValueError(f"Invalid maturity for {raw['id']}")
        seen.add(raw["id"])
        skills.append(Skill(
            id=raw["id"], path=raw["path"], category=raw["category"],
            trigger=raw["trigger"], exclusions=tuple(raw["exclusions"]),
            dependencies=tuple(raw["dependencies"]), platforms=tuple(raw["platforms"]),
            risk_class=raw["risk_class"], script_tier=raw["script_tier"],
            maturity=raw["maturity"], owner=raw["owner"],
            last_verified=raw["last_verified"], sources=tuple(raw["sources"]),
            keywords=tuple(raw["keywords"]),
        ))
    return skills
