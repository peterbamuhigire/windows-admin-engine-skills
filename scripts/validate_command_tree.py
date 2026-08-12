#!/usr/bin/env python3
from __future__ import annotations
import json
import re
from pathlib import Path

REPO=Path(__file__).resolve().parents[1]
FORBIDDEN={
    'invoke-expression':re.compile(r'(?i)\bInvoke-Expression\b|\biex\b'),
    'remote-pipe-execution':re.compile(r'(?i)(Invoke-WebRequest|curl|wget).{0,120}\|.{0,40}(powershell|cmd|iex)'),
    'plain-secret-conversion':re.compile(r'(?i)ConvertTo-SecureString.{0,120}-AsPlainText'),
    'implicit-reboot':re.compile(r'(?i)\b(Restart-Computer|shutdown\.exe\s+/(r|g))\b'),
}

def main()->int:
    findings=[];commands=[]
    for path in sorted((REPO/'commands').rglob('*')):
        if not path.is_file() or path.suffix.casefold() not in {'.ps1','.cmd'}:continue
        text=path.read_text(encoding='utf-8-sig',errors='replace');rel=path.relative_to(REPO).as_posix()
        for label,pattern in FORBIDDEN.items():
            if pattern.search(text):findings.append(f'{label}: {rel}')
        if path.name.startswith('wsa-') and path.suffix.casefold()=='.ps1':
            commands.append(path.stem)
            if not path.with_suffix('.cmd').is_file():findings.append(f'missing-cmd-launcher: {rel}')
    if len(commands)<40:findings.append(f'command-count below 40: {len(commands)}')
    generated=json.dumps(__import__('generate_command_catalog').build(),indent=2,sort_keys=False)+'\n'
    target=REPO/'engine'/'command-catalog.json'
    if not target.is_file() or target.read_text(encoding='utf-8-sig')!=generated:findings.append('stale-command-catalog: run scripts/generate_command_catalog.py')
    for finding in findings:print('ERROR: '+finding)
    print(f'direct_commands={len(commands)} findings={len(findings)}')
    return 1 if findings else 0

if __name__=='__main__':raise SystemExit(main())
