#!/usr/bin/env python3
"""Parse raw wrk output + meta/mem CSVs from run_bench.sh into results.json and results.md.

Usage: analyze.py <results_dir>
Per (framework, scenario, connections) we take the MEDIAN of the repetitions for
req/s and latency, and keep min/max so run-to-run spread is visible.
"""
import csv, json, re, statistics, sys
from collections import defaultdict
from pathlib import Path

out = Path(sys.argv[1])
raw = out / "raw"

LABELS = {
    "stdlib": "Crystal stdlib (baseline)",
    "spectre": "Spectre",
    "kemal": "Kemal",
    "grip": "Grip",
    "amber": "Amber",
    "lucky": "Lucky (defaults)",
    "lucky_nc": "Lucky (cookies off)",
}
SCEN = {"root": "GET /", "user": "GET /users/:id (JSON)", "post": "POST /people (typed JSON in/out)"}


def to_us(s):
    m = re.match(r"([\d.]+)(us|ms|s)$", s)
    v, u = float(m.group(1)), m.group(2)
    return v * {"us": 1, "ms": 1000, "s": 1_000_000}[u]


def parse(path):
    t = path.read_text()
    d = {}
    d["rps"] = float(re.search(r"Requests/sec:\s+([\d.]+)", t).group(1))
    d["avg_us"] = to_us(re.search(r"Latency\s+([\d.]+(?:us|ms|s))\s", t).group(1))
    d["p50_us"] = to_us(re.search(r"^\s+50%\s+([\d.]+(?:us|ms|s))", t, re.M).group(1))
    d["p99_us"] = to_us(re.search(r"^\s+99%\s+([\d.]+(?:us|ms|s))", t, re.M).group(1))
    m = re.search(r"Non-2xx or 3xx responses:\s+(\d+)", t)
    d["non2xx"] = int(m.group(1)) if m else 0
    m = re.search(r"Socket errors: connect (\d+), read (\d+), write (\d+), timeout (\d+)", t)
    d["sock_err"] = sum(map(int, m.groups())) if m else 0
    return d


cells = defaultdict(list)
for p in sorted(raw.glob("*.txt")):
    fw, sc, c, r = p.stem.split("__")
    cells[(fw, sc, int(c[1:]))].append(parse(p))

results = []
bad = []
for (fw, sc, c), runs in cells.items():
    rps = [r["rps"] for r in runs]
    row = {
        "framework": fw, "label": LABELS[fw], "scenario": sc, "conns": c, "runs": len(runs),
        "rps_median": statistics.median(rps), "rps_min": min(rps), "rps_max": max(rps),
        "avg_us": statistics.median(r["avg_us"] for r in runs),
        "p50_us": statistics.median(r["p50_us"] for r in runs),
        "p99_us": statistics.median(r["p99_us"] for r in runs),
        "non2xx": sum(r["non2xx"] for r in runs), "sock_err": sum(r["sock_err"] for r in runs),
    }
    if row["non2xx"] or row["sock_err"]:
        bad.append(row)
    results.append(row)

mem = defaultdict(lambda: {"peak": [], "end": [], "idle": [], "startup": []})
for r in csv.DictReader(open(out / "mem.csv")):
    mem[r["framework"]]["peak"].append(int(r["peak_rss_kb"]))
    mem[r["framework"]]["end"].append(int(r["end_rss_kb"]))
for r in csv.DictReader(open(out / "meta.csv")):
    mem[r["framework"]]["idle"].append(int(r["idle_rss_kb"]))
    mem[r["framework"]]["startup"].append(int(r["startup_ms"]))
memory = {
    fw: {
        "idle_mb": statistics.median(v["idle"]) / 1024,
        "peak_mb": statistics.median(v["peak"]) / 1024,
        "startup_ms": statistics.median(v["startup"]),
    }
    for fw, v in mem.items()
}

json.dump({"results": results, "memory": memory, "labels": LABELS, "scenarios": SCEN, "anomalies": bad},
          open(out / "results.json", "w"), indent=1)

# ---- markdown ----
order = ["stdlib", "spectre", "kemal", "grip", "amber", "lucky_nc", "lucky"]
lines = []
for c in sorted({r["conns"] for r in results}):
    for sc in [x for x in ["root", "user", "post"] if any(r["scenario"] == x and r["conns"] == c for r in results)]:
        lines.append(f"\n### {SCEN[sc]} - {c} connections\n")
        lines.append("| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |")
        lines.append("|---|---:|---:|---:|---:|---:|")
        rows = {r["framework"]: r for r in results if r["scenario"] == sc and r["conns"] == c}
        base = rows["spectre"]["rps_median"]
        for fw in sorted(rows, key=lambda f: -rows[f]["rps_median"]):
            r = rows[fw]
            lines.append(
                f"| {r['label']} | {r['rps_median']:,.0f} | {r['rps_min']:,.0f}-{r['rps_max']:,.0f} | "
                f"{r['p50_us']/1000:.2f} ms | {r['p99_us']/1000:.2f} ms | {r['rps_median']/base:.2f}x |"
            )
lines.append("\n### Memory and startup (single process, after the full load run)\n")
lines.append("| Framework | idle RSS | peak RSS | time to first response |")
lines.append("|---|---:|---:|---:|")
for fw in order:
    m = memory[fw]
    lines.append(f"| {LABELS[fw]} | {m['idle_mb']:.1f} MB | {m['peak_mb']:.1f} MB | {m['startup_ms']:.0f} ms |")
if bad:
    lines.append("\n**Anomalies (non-2xx / socket errors):**")
    for b in bad:
        lines.append(f"- {b['label']} {b['scenario']} c={b['conns']}: non2xx={b['non2xx']} sock_err={b['sock_err']}")
else:
    lines.append("\nNo non-2xx responses or socket errors in any run.")
(out / "results.md").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
