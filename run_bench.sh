#!/usr/bin/env bash
# Usage: run_bench.sh <outdir>   (env: REPS=3 DUR=8 WARM=2 CONNS="32 256")
# Each server is pinned to CPU 0 (single thread), wrk to CPU 1.
set -uo pipefail
B=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?outdir}; REPS=${REPS:-3}; DUR=${DUR:-8}; WARM=${WARM:-2}; CONNS=${CONNS:-"32 256"}
PORT=3999; BINDIR=${BINDIR:-$B/bin}; ONLY=${ONLY:-"root user post"}
mkdir -p "$OUT/raw"
FRAMEWORKS=(stdlib spectre kemal grip amber lucky lucky_nc)
SCENARIOS=("root|/|" "user|/users/42|" "post|/people|-s $B/post.lua")
echo "framework,rep,conns,scenario,startup_ms,idle_rss_kb" > "$OUT/meta.csv"
echo "framework,rep,peak_rss_kb,end_rss_kb" > "$OUT/mem.csv"

for rep in $(seq 1 "$REPS"); do
  # rotate framework order each rep to spread drift / position bias
  n=${#FRAMEWORKS[@]}; shift_by=$(( (rep-1) % n ))
  order=("${FRAMEWORKS[@]:shift_by}" "${FRAMEWORKS[@]:0:shift_by}")
  for fw in "${order[@]}"; do
    cd "$B/$fw"
    t0=$(date +%s%N)
    AMBER_ENV=production PORT=$PORT taskset -c 0 "$BINDIR/$fw" >/dev/null 2>&1 &
    pid=$!
    until curl -s -o /dev/null http://127.0.0.1:$PORT/ ; do sleep 0.01; done
    startup_ms=$(( ($(date +%s%N) - t0) / 1000000 ))
    sleep 0.5
    idle_rss=$(awk '/VmRSS/{print $2}' /proc/$pid/status)
    echo "$fw,$rep,-,-,$startup_ms,$idle_rss" >> "$OUT/meta.csv"
    for c in $CONNS; do
      for sc in "${SCENARIOS[@]}"; do
        IFS='|' read -r name path extra <<<"$sc"
        case " $ONLY " in *" $name "*) ;; *) continue;; esac
        url="http://127.0.0.1:$PORT$path"
        taskset -c 1 wrk -t1 -c"$c" -d"${WARM}s" $extra "$url" >/dev/null 2>&1
        taskset -c 1 wrk -t1 -c"$c" -d"${DUR}s" --latency $extra "$url" > "$OUT/raw/${fw}__${name}__c${c}__r${rep}.txt" 2>&1
        rps=$(awk '/Requests\/sec/{print $2}' "$OUT/raw/${fw}__${name}__c${c}__r${rep}.txt")
        echo "  rep$rep $fw $name c=$c -> $rps req/s"
      done
    done
    peak=$(awk '/VmHWM/{print $2}' /proc/$pid/status); endrss=$(awk '/VmRSS/{print $2}' /proc/$pid/status)
    echo "$fw,$rep,$peak,$endrss" >> "$OUT/mem.csv"
    kill $pid 2>/dev/null; wait $pid 2>/dev/null
    sleep 1
  done
done
echo DONE
