#!/usr/bin/env python3
from __future__ import annotations
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

REQUIRED_ROOT={"schema_version","manifest_id","environment","tenant","approved_by","expires_at","max_hosts","targets"}
REQUIRED_TARGET={"hostname","device_id","owner","site","platform","management_plane","risk_tier","maintenance_window"}

def main(argv:list[str])->int:
    if len(argv)!=1:
        print("usage: validate_fleet_manifest.py <manifest.json>",file=sys.stderr);return 2
    path=Path(argv[0])
    try:data=json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError,json.JSONDecodeError) as exc:print(f"ERROR: {exc}",file=sys.stderr);return 1
    errors=[]
    missing=REQUIRED_ROOT-data.keys()
    if missing:errors.append(f"missing root fields: {sorted(missing)}")
    targets=data.get("targets",[])
    if not isinstance(targets,list):errors.append("targets must be a list");targets=[]
    if isinstance(data.get("max_hosts"),int) and len(targets)>data["max_hosts"]:errors.append("target count exceeds max_hosts")
    seen=set()
    for index,target in enumerate(targets):
        if not isinstance(target,dict):errors.append(f"targets[{index}] must be an object");continue
        absent=REQUIRED_TARGET-target.keys()
        if absent:errors.append(f"targets[{index}] missing {sorted(absent)}")
        key=(str(target.get("hostname","")).casefold(),str(target.get("device_id","")))
        if key in seen:errors.append(f"duplicate target at index {index}: {key}")
        seen.add(key)
    try:
        expiry=datetime.fromisoformat(str(data.get("expires_at","")).replace("Z","+00:00"))
        if expiry.tzinfo is None:errors.append("expires_at must include timezone")
        elif expiry.astimezone(timezone.utc)<=datetime.now(timezone.utc):errors.append("manifest is expired")
    except ValueError:errors.append("expires_at is not ISO-8601")
    for error in errors:print("ERROR: "+error)
    print(f"fleet_targets={len(targets)} findings={len(errors)} contact_attempted=false")
    return 1 if errors else 0

if __name__=="__main__":raise SystemExit(main(sys.argv[1:]))
