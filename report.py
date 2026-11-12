#!/usr/bin/env python3
"""Merge result sets into the headline table. GET scenarios come from results/final,
POST from results/post_string (String-parse), with results/final POST kept as the IO-parse variant."""
import json
from pathlib import Path
R = Path(__file__).parent / "results"
fin = json.load(open(R / "final/results.json")); pst = json.load(open(R / "post_string/results.json"))
L = fin["labels"]; order = ["stdlib", "spectre", "grip", "kemal", "amber", "lucky_nc", "lucky"]
get = lambda d, fw, sc, c: next(r for r in d["results"] if r["framework"] == fw and r["scenario"] == sc and r["conns"] == c)
def k(v): return f"{v/1000:.0f}k"
out = ["| Framework | GET / c32 | GET /users/:id c32 | POST c32 | GET / c256 | GET /users/:id c256 | POST c256 |", "|---|---:|---:|---:|---:|---:|---:|"]
for fw in order:
    cells = []
    for c in (32, 256):
        for sc in ("root", "user", "post"):
            r = get(pst if sc == "post" else fin, fw, sc, c); cells.append(k(r["rps_median"]))
    out.append(f"| {L[fw]} | " + " | ".join(cells) + " |")
print("\n".join(out))
print("\nrelative to Spectre (median ratio):")
for fw in order:
    row = []
    for c in (32, 256):
        for sc in ("root", "user", "post"):
            d = pst if sc == "post" else fin
            row.append(f"{get(d, fw, sc, c)['rps_median']/get(d,'spectre',sc,c)['rps_median']:.2f}")
    print(f"{L[fw]:28s}", " ".join(row))
print("\nIO-parse POST variant (first run):")
for fw in order:
    print(f"{L[fw]:28s}", k(get(fin, fw, 'post', 32)['rps_median']), k(get(fin, fw, 'post', 256)['rps_median']))
