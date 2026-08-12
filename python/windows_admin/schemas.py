"""Dependency-free checks for operation and evidence contracts."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any


OPERATION_FIELDS = {
    "SchemaVersion", "OperationId", "Command", "Target", "IdentityContext",
    "Status", "Changed", "RebootRequired", "DisconnectRisk", "StartedAt",
    "FinishedAt", "Before", "After", "Verification", "RollbackArtifact",
    "EvidencePath", "Errors", "Warnings",
}
STATUSES = {"NoChange", "Succeeded", "Failed", "PendingReboot", "PartiallySucceeded", "Aborted"}


def validate_operation(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    missing = OPERATION_FIELDS - data.keys()
    if missing:
        errors.append(f"missing fields: {sorted(missing)}")
    if data.get("SchemaVersion") != "1.0":
        errors.append("SchemaVersion must be 1.0")
    if data.get("Status") not in STATUSES:
        errors.append("Status is invalid")
    for field in ("Changed", "RebootRequired", "DisconnectRisk"):
        if field in data and not isinstance(data[field], bool):
            errors.append(f"{field} must be boolean")
    target = data.get("Target")
    if not isinstance(target, dict) or not target.get("Kind") or not target.get("Name"):
        errors.append("Target must contain Kind and Name")
    return errors


def validate_evidence_pack(path: Path) -> list[str]:
    errors: list[str] = []
    manifest_path = path / "manifest.json"
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"invalid manifest: {exc}"]
    for entry in manifest.get("files", []):
        file_path = path / entry.get("path", "")
        if not file_path.is_file():
            errors.append(f"missing evidence file: {file_path.name}")
            continue
        digest = hashlib.sha256(file_path.read_bytes()).hexdigest()
        if digest.casefold() != str(entry.get("sha256", "")).casefold():
            errors.append(f"hash mismatch: {file_path.name}")
    return errors
