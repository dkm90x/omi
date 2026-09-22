#!/usr/bin/env python3
import json, pathlib, sys
root=pathlib.Path(sys.argv[1] if len(sys.argv)>1 else ".").resolve()
req=["AGENTS.md",".build/manifest.json",".build/CONSTITUTION.md",".build/STATE.md",".build/EVIDENCE.md"]
allowed={"WEB_PRODUCT","DESKTOP_LOCAL_CONTROL","MOBILE_APP","AGENT_AUTOMATION","INFRASTRUCTURE_REMOTE_ACCESS","AI_DATA_RESEARCH","DIGITAL_PRODUCT_CREATIVE","HARDWARE_PHYSICAL"}
errors=[]
for rel in req:
    p=root/rel
    if not p.is_file() or p.stat().st_size==0: errors.append(f"missing/empty: {rel}")
mp=root/".build/manifest.json"
if mp.is_file():
    try: m=json.loads(mp.read_text())
    except Exception as e: errors.append(f"invalid manifest JSON: {e}"); m={}
    if m.get("buildSystemVersion")!="1.0": errors.append("buildSystemVersion must be 1.0")
    if m.get("canonicalRepository")!="https://github.com/dkm90x/builder-guide": errors.append("wrong canonicalRepository")
    ps=m.get("constitutions",[])
    if not ps: errors.append("at least one constitution required")
    bad=set(ps)-allowed
    if bad: errors.append("unknown constitutions: "+", ".join(sorted(bad)))
    if not isinstance(m.get("qualityGates"),dict): errors.append("qualityGates required")
if errors:
    print("BUILD SYSTEM CHECK: FAIL"); [print("- "+e) for e in errors]; sys.exit(1)
print("BUILD SYSTEM CHECK: PASS")
