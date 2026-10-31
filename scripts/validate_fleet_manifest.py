#!/usr/bin/env python3
from __future__ import annotations
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REQUIRED_ROOT={"schema_version","manifest_id","environment","tenant","approved_by","expires_at","max_hosts","targets"}
REQUIRED_AUTHORITY={"owner","approver","change_window","status"}
REQUIRED_TARGET={"hostname","device_id","owner","site","platform","management_plane","risk_tier","maintenance_window"}
# Characters that turn one hostname into a pattern, list, range or CIDR block.
AMBIGUOUS_HOSTNAME=re.compile(r"[\s*?,;/\\\[\]{}<>|]")

def parse_instant(text):
    """Return an aware UTC datetime, or None when text is not a zoned ISO-8601 instant."""
    try:
        value=datetime.fromisoformat(text.strip().replace("Z","+00:00"))
        if value.tzinfo is None:return None
        return value.astimezone(timezone.utc)
    except (ValueError,OverflowError):return None

def parse_window(text):
    """Return (start, end) for '<instant>/<instant>' with end after start, else None."""
    if not isinstance(text,str) or text.count("/")!=1:return None
    start,end=(parse_instant(part) for part in text.split("/"))
    if start is None or end is None or end<=start:return None
    return start,end

def validate_data(data, now=None)->list[str]:
    if not isinstance(data,dict):return ["manifest must be an object"]
    errors=[]
    missing=REQUIRED_ROOT-data.keys()
    if missing:errors.append(f"missing root fields: {sorted(missing)}")
    authority=data.get("authority")
    if not isinstance(authority,dict):
        errors.append("authority must be an object")
    else:
        absent=REQUIRED_AUTHORITY-authority.keys()
        if absent:errors.append(f"authority missing fields: {sorted(absent)}")
        invalid=[field for field in REQUIRED_AUTHORITY if not isinstance(authority.get(field),str) or not authority[field].strip()]
        if invalid:errors.append(f"authority requires non-empty text: {sorted(invalid)}")
        if authority.get("status") not in {"synthetic-test-only","approved","revoked"}:
            errors.append("authority.status must be synthetic-test-only, approved, or revoked")
        elif authority["status"]=="revoked":errors.append("authority is revoked")
        if isinstance(authority.get("change_window"),str) and authority["change_window"].strip() and parse_window(authority["change_window"]) is None:
            errors.append("authority.change_window must be <start>/<end> ISO-8601 instants with a time zone and end after start")
    if data.get("schema_version")!="1.0":errors.append("schema_version must be 1.0")
    for field in ("manifest_id","environment","approved_by"):
        if not isinstance(data.get(field),str) or not data[field].strip():
            errors.append(f"{field} must be non-empty text")
    if isinstance(data.get("manifest_id"),str) and len(data["manifest_id"])<8:
        errors.append("manifest_id must contain at least eight characters")
    if data.get("tenant") is not None and (not isinstance(data["tenant"],str) or not data["tenant"].strip()):
        errors.append("tenant must be null or non-empty text")
    targets=data.get("targets",[])
    if not isinstance(targets,list) or not targets:errors.append("targets must be a non-empty list");targets=[]
    if type(data.get("max_hosts")) is not int or data["max_hosts"]<1:
        errors.append("max_hosts must be a positive integer")
    elif len(targets)>data["max_hosts"]:errors.append("target count exceeds max_hosts")
    change_window=parse_window(authority.get("change_window")) if isinstance(authority,dict) else None
    needs_independent_approver=(isinstance(authority,dict) and authority.get("status")=="approved"
        and isinstance(authority.get("owner"),str) and isinstance(authority.get("approver"),str)
        and authority["owner"].strip().casefold()==authority["approver"].strip().casefold())
    seen_hosts=set();seen_devices=set()
    for index,target in enumerate(targets):
        if not isinstance(target,dict):errors.append(f"targets[{index}] must be an object");continue
        absent=REQUIRED_TARGET-target.keys()
        if absent:errors.append(f"targets[{index}] missing {sorted(absent)}")
        invalid=[field for field in REQUIRED_TARGET if not isinstance(target.get(field),str) or not target[field].strip()]
        if invalid:
            errors.append(f"targets[{index}] requires non-empty text: {sorted(invalid)}")
            continue
        if target["risk_tier"] not in {"R0","R1","R2","R3","R4","R5"}:
            errors.append(f"targets[{index}] has invalid risk_tier")
        elif target["risk_tier"] in {"R4","R5"} and needs_independent_approver:
            errors.append(f"targets[{index}] is {target['risk_tier']}: an independent approver is required (authority.owner equals authority.approver)")
        window=parse_window(target["maintenance_window"])
        if window is None:
            errors.append(f"targets[{index}].maintenance_window must be <start>/<end> ISO-8601 instants with a time zone and end after start")
        elif change_window is not None and not (change_window[0]<=window[0] and window[1]<=change_window[1]):
            errors.append(f"targets[{index}].maintenance_window is outside authority.change_window")
        host=target["hostname"].strip().rstrip('.').casefold()
        if not host:errors.append(f"targets[{index}] has empty canonical hostname")
        if AMBIGUOUS_HOSTNAME.search(target["hostname"].strip()):
            errors.append(f"targets[{index}] hostname must name exactly one host (no wildcard, list, range, path or whitespace)")
        device=target["device_id"].strip().casefold()
        if host in seen_hosts or device in seen_devices:errors.append(f"duplicate target identity at index {index}")
        seen_hosts.add(host);seen_devices.add(device)
    try:
        if not isinstance(data.get("expires_at"),str):raise ValueError("expiry must be text")
        expiry=datetime.fromisoformat(data["expires_at"].replace("Z","+00:00"))
        if expiry.tzinfo is None:errors.append("expires_at must include timezone")
        elif expiry.astimezone(timezone.utc)<=(now or datetime.now(timezone.utc)):errors.append("manifest is expired")
    except (ValueError,OverflowError):errors.append("expires_at is not a representable ISO-8601 UTC instant")
    return errors

def main(argv:list[str])->int:
    if len(argv)!=1:
        print("usage: validate_fleet_manifest.py <manifest.json>",file=sys.stderr);return 2
    path=Path(argv[0])
    try:data=json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError,UnicodeError,json.JSONDecodeError) as exc:print(f"ERROR: {exc}",file=sys.stderr);return 1
    errors=validate_data(data)
    targets=data.get("targets",[]) if isinstance(data,dict) else []
    if not isinstance(targets,list):targets=[]
    for error in errors:print("ERROR: "+error)
    print(f"fleet_targets={len(targets)} findings={len(errors)} contact_attempted=false")
    print("scope=manifest-shape-windows-named-hosts-approver-separation-and-expiry approval-authenticity-and-fleet-readiness=NOT_ASSESSED")
    return 1 if errors else 0

if __name__=="__main__":raise SystemExit(main(sys.argv[1:]))
