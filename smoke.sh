#!/usr/bin/env bash
# Usage: smoke.sh <binary> [port]  -- starts the server, checks the 3 endpoints, prints status / content-type / body
BIN=$1; PORT=${2:-3999}
PORT=$PORT "$BIN" >/tmp/smoke.log 2>&1 &
PID=$!
for i in $(seq 1 50); do curl -s -o /dev/null http://127.0.0.1:$PORT/ && break; sleep 0.2; done
show() {
  local label=$1; shift
  curl -s -D /tmp/smoke.hdr -o /tmp/smoke.body "$@"
  local status ctype
  status=$(head -1 /tmp/smoke.hdr | awk '{print $2}')
  ctype=$(grep -i '^content-type:' /tmp/smoke.hdr | tr -d '\r' | cut -d' ' -f2- | head -1)
  printf "  %-16s %s  %-34s %.60s\n" "$label" "$status" "[$ctype]" "$(tr '\n' ' ' </tmp/smoke.body)"
}
show "GET /"           http://127.0.0.1:$PORT/
show "GET /users/42"   http://127.0.0.1:$PORT/users/42
show "POST /people"    -X POST -H 'Content-Type: application/json' -d '{"name":"Ann","age":41}' http://127.0.0.1:$PORT/people
show "GET /nope"       http://127.0.0.1:$PORT/nope
kill $PID 2>/dev/null; wait $PID 2>/dev/null
