#!/usr/bin/env python3
"""Fail on content defects that the structural validator does not see.

Reference check, over tracked Markdown: a local link that does not resolve, and
a windows-* skill identifier that is not in the catalogue.

Portability check, over every tracked text file: a machine-specific absolute
path (a personal Windows profile, a development-drive checkout or a Unix home
directory), which would not resolve on another device.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "python"))

from windows_admin.catalog import load_catalog  # noqa: E402

WALK_EXCLUDED = {".git", "__pycache__", ".pytest_cache", ".cache", ".venv", "venv", "node_modules"}

# Markdown subtrees that name planned or historical artefacts, not active skills.
IDENTIFIER_EXEMPT_PREFIXES = ("docs/plans/", "docs/kaizen/")

# windows-* tokens that are real but are not catalogue skills.
NON_SKILL_IDENTIFIERS = {
    "windows-sysadmin": "hub skill, outside the specialist catalogue",
    "windows-admin": "plugin, marketplace and command-line name",
    "windows-admin-engine-skills": "repository name",
    "windows-client": "platform identifier in engine/catalog.yaml",
    "windows-server": "platform identifier in engine/catalog.yaml",
    "windows-latest": "CI runner label used by the desktop test skill",
    "windows-desktop-e2e": "log prefix inside a quoted code sample",
}

# Tracked files that hold such a path on purpose.
PORTABILITY_EXEMPT = {
    "tests/python/test_marketplace.py": "asserts the router machine-binding detector",
    "tests/python/test_content_hygiene.py": "fixtures for the portability check",
}

MACHINE_PATH = re.compile(
    r"(?<![A-Za-z0-9])[A-Za-z]:\\(?:wamp64\b|Users\\(?!Public\b|Default\b|All Users\b)[^\\\s`'\"]+)"
    r"|/home/[A-Za-z0-9._-]+/|/Users/[A-Za-z0-9._-]+/"
)

FENCE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE = re.compile(r"`[^`\n]*`")
LINK = re.compile(r"\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")
SKILL_IDENTIFIER = re.compile(r"(?<![\w/.-])windows-[a-z0-9]+(?:-[a-z0-9]+)*(?![\w/-])")


def tracked_files(repo: Path) -> list[str]:
    """Return repository-relative POSIX paths: Git's tracked set, else a pruned walk."""
    try:
        listing = subprocess.run(
            ["git", "-C", str(repo), "ls-files", "-z"],
            check=True, capture_output=True,
        ).stdout.decode("utf-8")
        files = [name for name in listing.split("\0") if name]
        if files:
            return sorted(files)
    except (OSError, subprocess.CalledProcessError):
        pass
    found: list[str] = []
    for path in repo.rglob("*"):
        parts = path.relative_to(repo).parts
        if path.is_file() and not WALK_EXCLUDED.intersection(parts):
            found.append("/".join(parts))
    return sorted(found)


def read_text(repo: Path, name: str) -> str | None:
    try:
        return (repo / name).read_text(encoding="utf-8-sig")
    except (OSError, UnicodeDecodeError):
        return None


def link_findings(repo: Path, name: str, text: str) -> list[str]:
    findings: list[str] = []
    in_fence = False
    for number, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for target in LINK.findall(INLINE_CODE.sub("", line)):
            path_part = re.split(r"[#?]", target, maxsplit=1)[0]
            if not path_part or "://" in target or target.startswith(("#", "mailto:")):
                continue
            if not (repo / name).parent.joinpath(path_part).resolve().exists():
                findings.append(f"{name}:{number}: link does not resolve: {target}")
    return findings


def identifier_findings(name: str, text: str, known: set[str]) -> list[str]:
    findings: list[str] = []
    for number, line in enumerate(text.splitlines(), 1):
        for token in SKILL_IDENTIFIER.findall(line):
            if token not in known:
                findings.append(f"{name}:{number}: unknown skill identifier {token}")
    return findings


def audit_references(repo: Path, files: list[str] | None = None) -> list[str]:
    repo = repo.resolve()
    known = {skill.id for skill in load_catalog(repo)} | set(NON_SKILL_IDENTIFIERS)
    findings: list[str] = []
    for name in files if files is not None else tracked_files(repo):
        if not name.endswith(".md"):
            continue
        text = read_text(repo, name)
        if text is None:
            continue
        findings.extend(link_findings(repo, name, text))
        if not name.startswith(IDENTIFIER_EXEMPT_PREFIXES):
            findings.extend(identifier_findings(name, text, known))
    return findings


def audit_portability(repo: Path, files: list[str] | None = None) -> list[str]:
    repo = repo.resolve()
    findings: list[str] = []
    for name in files if files is not None else tracked_files(repo):
        if name in PORTABILITY_EXEMPT:
            continue
        text = read_text(repo, name)
        if text is None:
            continue
        for number, line in enumerate(text.splitlines(), 1):
            match = MACHINE_PATH.search(line)
            if match:
                findings.append(f"{name}:{number}: machine-specific path {match.group(0)}")
    return findings


def audit_content(repo: Path, files: list[str] | None = None) -> list[str]:
    names = files if files is not None else tracked_files(repo.resolve())
    return audit_references(repo, names) + audit_portability(repo, names)


def main() -> int:
    findings = audit_content(REPO)
    for finding in findings:
        print(f"ERROR: {finding}")
    print(f"content_hygiene_findings={len(findings)}")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
