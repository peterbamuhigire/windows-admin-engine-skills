#!/usr/bin/env python3
from __future__ import annotations
import json
import re
from pathlib import Path

REPO=Path(__file__).resolve().parents[1]
PATTERN=re.compile(r"bin\\wsa\.ps1'\)\s+([a-z0-9-]+)")

def build()->dict:
    records=[]
    for path in sorted((REPO/'commands').glob('*/*/wsa-*.ps1')):
        rel=path.relative_to(REPO).as_posix();parts=path.relative_to(REPO/'commands').parts
        match=PATTERN.search(path.read_text(encoding='utf-8-sig'))
        action=match.group(1) if match else 'unknown'
        risk='R2' if action=='service-state' else 'R0'
        records.append({'command':path.stem,'path':rel,'category':parts[0],'subcategory':parts[1],'action':action,'risk_class':risk,'mutation':action=='service-state'})
    return {'schema_version':'1.0','generated_from':'commands/**/*.ps1','commands':records}

def render()->str:
    return json.dumps(build(),indent=2,sort_keys=False)+'\n'

def main()->int:
    target=REPO/'engine'/'command-catalog.json';target.write_text(render(),encoding='utf-8')
    print(f"generated_commands={len(build()['commands'])} path={target.relative_to(REPO).as_posix()}")
    return 0

if __name__=='__main__':raise SystemExit(main())
