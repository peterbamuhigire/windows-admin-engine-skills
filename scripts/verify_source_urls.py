#!/usr/bin/env python3
"""Check source URL identity/liveness; this does not certify claim support."""
from __future__ import annotations
import argparse
import json
import ssl
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path

REPO=Path(__file__).resolve().parents[1]

def check(item:dict)->dict:
    url=item['url'];result={'id':item['id'],'url':url,'reachable':False,'status':None,'final_url':None,'error':None}
    headers={'User-Agent':'WindowsAdminEngineSourceVerifier/0.1 (+https://techguypeter.com)'}
    for method in ('HEAD','GET'):
        try:
            request=urllib.request.Request(url,headers=headers,method=method)
            with urllib.request.urlopen(request,timeout=20,context=ssl.create_default_context()) as response:
                result.update(reachable=200<=response.status<400,status=response.status,final_url=response.geturl(),error=None)
                return result
        except urllib.error.HTTPError as exc:
            result.update(status=exc.code,final_url=exc.geturl(),error=str(exc))
            if method=='GET':return result
        except Exception as exc:
            result['error']=f'{type(exc).__name__}: {exc}'
            if method=='GET':return result
    return result

def main()->int:
    parser=argparse.ArgumentParser();parser.add_argument('--out',type=Path);args=parser.parse_args()
    register=json.loads((REPO/'engine/source-register.yaml').read_text(encoding='utf-8-sig'))
    items=[item for item in register['sources'] if item.get('url')]
    with ThreadPoolExecutor(max_workers=6) as pool:results=list(pool.map(check,items))
    report={'checked_at':datetime.now(timezone.utc).isoformat(),'scope':'URL identity and liveness only; semantic claim support remains manual','total':len(results),'reachable':sum(1 for r in results if r['reachable']),'results':results}
    rendered=json.dumps(report,indent=2)+'\n'
    if args.out:args.out.write_text(rendered,encoding='utf-8')
    else:print(rendered,end='')
    failures=[r for r in results if not r['reachable']]
    for failure in failures:print(f"UNREACHABLE {failure['id']} {failure['status']} {failure['error']}")
    print(f"source_urls={len(results)} reachable={report['reachable']} failures={len(failures)}")
    return 1 if failures else 0

if __name__=='__main__':raise SystemExit(main())
