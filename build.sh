#!/usr/bin/env bash
# Builds all benchmark servers into ./bin using Crystal (tested with 1.21.0).
set -euo pipefail
cd "$(dirname "$0")"; B=$PWD; mkdir -p bin lucky_nc
for fw in spectre kemal grip amber lucky; do (cd $fw && shards install); done
(cd stdlib  && crystal build --release --no-debug -o $B/bin/stdlib  src/server.cr)
(cd spectre && crystal build --release --no-debug -o $B/bin/spectre src/server.cr)
(cd kemal   && crystal build --release --no-debug -o $B/bin/kemal   src/server.cr)
(cd grip    && crystal build --release --no-debug -o $B/bin/grip    src/server.cr)
(cd amber   && AMBER_ENV=production crystal build --release --no-debug -o $B/bin/amber src/server.cr)
(cd lucky   && crystal build --release --no-debug            -o $B/bin/lucky    src/server.cr)
(cd lucky   && crystal build --release --no-debug -Dnocookies -o $B/bin/lucky_nc src/server.cr)
echo "built: $(ls bin | tr '\n' ' ')"
