#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
BLOCKED_EXTENSIONS = {".epub", ".mobi", ".azw", ".azw3"}
BLOCKED_PATTERNS = {
    "source-fulltext-path": re.compile(r"(?i)Documents_markdown|Anna.?s Archive|PDFDrive"),
    "source-fulltext-markers": re.compile(r"(?i)^\s*(copyright page|table of contents)\s*$", re.MULTILINE),
}


def main() -> int:
    findings: list[str] = []
    for path in REPO.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue
        rel = path.relative_to(REPO).as_posix()
        if path.suffix.casefold() in BLOCKED_EXTENSIONS:
            findings.append(f"raw-book-source: {rel}")
        if path.suffix.casefold() not in {".md", ".txt", ".yaml", ".json"}:
            continue
        if path.stat().st_size > 500_000:
            findings.append(f"source-fulltext-size: {rel}")
            continue
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        for label, pattern in BLOCKED_PATTERNS.items():
            if pattern.search(text):
                findings.append(f"{label}: {rel}")
    for finding in findings:
        print("ERROR: " + finding)
    print(f"source_ingestion_findings={len(findings)}")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
