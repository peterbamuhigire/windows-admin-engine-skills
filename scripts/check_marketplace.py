#!/usr/bin/env python3
"""Check local plugin discovery, portable routes and the hard file ceiling."""
from __future__ import annotations
import json
import os
import re
from pathlib import Path

LIMIT = 5000
EXCLUDED = {'.git', '__pycache__', '.pytest_cache', '.cache', '.venv', 'venv', 'node_modules'}


def count_files(root: Path, *, package: bool) -> int:
    count = 0
    def fail(error: OSError) -> None:
        raise error
    for current, directories, files in os.walk(root, followlinks=False, onerror=fail):
        kept = []
        for name in directories:
            if package and name in EXCLUDED:
                continue
            if (Path(current) / name).is_symlink():
                count += 1
            else:
                kept.append(name)
        directories[:] = kept
        count += len(files)
    return count


def capacity_findings(full: int, package: int) -> list[str]:
    return [f'{label} file entries {value} exceed hard limit {LIMIT}'
            for label, value in [('checkout', full), ('package', package)] if value > LIMIT]


def audit_repository(root: Path) -> tuple[list[str], dict[str, int]]:
    root = root.resolve(strict=True)
    findings = []
    counts = {'checkout': count_files(root, package=False), 'package': count_files(root, package=True)}
    findings.extend(capacity_findings(**{'full': counts['checkout'], 'package': counts['package']}))
    try:
        plugin = json.loads((root / '.claude-plugin/plugin.json').read_text())
        market = json.loads((root / '.claude-plugin/marketplace.json').read_text())
        if not isinstance(plugin, dict) or not isinstance(market, dict):
            raise ValueError('manifests must be objects')
        entries = [item for item in market['plugins'] if item.get('source') in ('.', './')]
        if len(entries) != 1 or any(entries[0].get(key) != plugin.get(key) for key in ('name', 'version')):
            findings.append('local marketplace identity/version differs from plugin')
        if not plugin.get('name') or not plugin.get('version'):
            findings.append('plugin name/version is empty')
        paths = plugin['skills']
        if not isinstance(paths, list):
            raise ValueError('explicit skill directory list required')
        declared = set()
        for entry in paths:
            if not isinstance(entry, str) or not entry.startswith('./') or '\\' in entry or '..' in entry.split('/'):
                findings.append('invalid relative skill path')
                continue
            candidate = root / entry
            try:
                resolved = candidate.resolve(strict=True)
                resolved.relative_to(root)
                cursor = candidate
                while cursor != root:
                    if cursor.is_symlink():
                        raise ValueError('symlinked skill path')
                    cursor = cursor.parent
                skill = resolved / 'SKILL.md'
                if not skill.is_file() or skill.is_symlink():
                    raise ValueError('regular SKILL.md required')
            except (OSError, ValueError):
                findings.append(f'missing, linked or escaping skill path: {entry}')
                continue
            if resolved in declared:
                findings.append(f'duplicate skill path: {entry}')
            declared.add(resolved)
        actual = {path.parent.resolve() for path in (root / 'skills').rglob('SKILL.md')}
        if declared != actual:
            findings.append('declared skill paths differ from canonical skill paths')
        counts['skills'] = len(actual)
        if any((root / 'commands').rglob('*.md')):
            findings.append('Markdown under commands would expose unintended Claude slash commands')
        # These layouts change Codex precedence; require an explicit tested migration.
        if (root / 'plugin.json').exists() or (root / '.codex-plugin/plugin.json').exists():
            findings.append('new Codex override requires a reviewed discovery contract')
        for filename in ('AGENTS.md', 'README.md'):
            text = (root / filename).read_text()
            if re.search(r'[A-Za-z]:[\\/]wamp64[\\/]www|/home/[^/\s]+/', text):
                findings.append(f'{filename}: machine-specific checkout binding')
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        findings.append(f'cannot validate manifests: {error}')
    return findings, counts


def main() -> int:
    try:
        findings, counts = audit_repository(Path(__file__).resolve().parents[1])
    except (OSError, ValueError) as error:
        print(f'FAIL: inventory unavailable: {error}')
        return 1
    print(json.dumps({'counts': counts, 'hard_limit': LIMIT, 'findings': findings}, indent=2))
    return int(bool(findings))


if __name__ == '__main__':
    raise SystemExit(main())
