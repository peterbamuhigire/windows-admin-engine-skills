#!/usr/bin/env python3
"""Fail when an operator-facing command or script is absent from the manual."""

from __future__ import annotations

import json
import re
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
MANUAL = REPO / "docs" / "operations" / "commands-and-scripts-manual.md"


def main() -> int:
    text = MANUAL.read_text(encoding="utf-8-sig")
    catalog = json.loads((REPO / "engine" / "command-catalog.json").read_text(encoding="utf-8-sig"))

    required: dict[str, list[str]] = {
        "command": [record["command"] for record in catalog["commands"]],
        "dispatcher": ["commands\\bin\\wsa.ps1", "commands\\bin\\wsa.cmd"],
        "script": [
            f"scripts\\{path.name}"
            for path in sorted((REPO / "scripts").iterdir())
            if path.is_file() and path.suffix.lower() in {".py", ".ps1", ".cmd"}
        ],
    }

    manifest = (REPO / "powershell" / "WindowsSkills.Engine" / "WindowsSkills.Engine.psd1").read_text(
        encoding="utf-8-sig"
    )
    required["module function"] = sorted(
        set(re.findall(r"'((?:Get|Test|Invoke|Write)-Wse[A-Za-z0-9]+)'", manifest))
    )

    findings: list[str] = []
    for kind, values in required.items():
        for value in values:
            if f"`{value}`" not in text:
                findings.append(f"missing {kind}: {value}")

    expected_sections = [
        "## 4. Engine discovery and validation",
        "## 5. Inventory and system health",
        "## 6. Networking and time",
        "## 7. Identity and Active Directory",
        "## 8. Group Policy",
        "## 9. Security posture",
        "## 10. Patching and reboot discovery",
        "## 11. Storage, services, shares, and tasks",
        "## 12. IIS",
        "## 13. Virtualization, WSL, and containers",
        "## 14. Observability and troubleshooting",
        "## 15. Backup and recovery observations",
        "## 16. Development workstation",
        "## 17. Fleet manifest safety",
        "## 21. Repository maintenance scripts",
    ]
    for heading in expected_sections:
        if heading not in text:
            findings.append(f"missing category heading: {heading}")

    for finding in findings:
        print(f"ERROR: {finding}")
    print(
        "manual_commands={} manual_scripts={} manual_functions={} findings={}".format(
            len(required["command"]),
            len(required["script"]),
            len(required["module function"]),
            len(findings),
        )
    )
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
