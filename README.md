# Crystal web framework benchmark: Spectre vs Kemal vs Grip vs Amber vs Lucky

Same three endpoints implemented in each framework, driven by `wrk`, one pinned CPU core per server.

| Framework | Version | Notes |
|---|---|---|
| Spectre | 0.1.0 (the attached zip, in `spectre_lib/`) | |
| Kemal | 1.15.0 | |
| Grip | 5.1.1 | |
| Amber | 1.5.0 | latest stable; 2.0 is still beta and was not tested |
| Lucky | 1.5.0 | measured twice: out-of-the-box, and with `disable_cookies` (see below) |
| Crystal `HTTP::Server` | stdlib | hand-written routing, no framework: the ceiling |

Crystal 1.21.0 (LLVM 20.1.8), `--release --no-debug`, single-threaded (no `-Dpreview_mt`).

## Endpoints (identical responses in every app, verified with `smoke.sh`)

1. `GET /` returns `Hello, World!` (text/plain)
2. `GET /users/:id` returns `{"id":"42","name":"user42"}` (route param + JSON)
3. `POST /people` takes `{"name":"Ann","age":41}` as a typed `Person` and returns `{"name":"Ann","age":42}`

Request logging is off in every framework. POST parsing uses a `JSON::Serializable` struct everywhere; Spectre via its own `req.json(Person)`, the rest via `Person.from_json(body_string)`, which is exactly what Spectre does internally.

## Method

- Server pinned to CPU 0, `wrk -t1` pinned to CPU 1, loopback, keep-alive.
- 2 s warm-up then 8 s measured, per scenario, at 32 and 256 connections.
- 3 repetitions, framework order rotated each repetition; the **median** is reported (min-max in `results/*/results.md`).
- Every run was checked for non-2xx responses and socket errors: none occurred.
- Hardware: shared 2-vCPU cloud VM, so absolute numbers are modest and noisy. **Differences under about 10% are within run-to-run noise** (spreads of 5-15% between repetitions were common).

## Results: median requests/second (higher is better)

| Framework | GET / c32 | GET /users/:id c32 | POST c32 | GET / c256 | GET /users/:id c256 | POST c256 |
|---|---:|---:|---:|---:|---:|---:|
| Crystal stdlib (baseline) | 143k | 128k | 90k | 136k | 109k | 76k |
| Spectre | 127k | 119k | 87k | 141k | 119k | 75k |
| Grip | 126k | 115k | 84k | 133k | 114k | 72k |
| Kemal | 114k | 82k | 79k | 104k | 74k | 69k |
| Amber | 115k | 96k | 77k | 107k | 90k | 64k |
| Lucky (cookies off) | 108k | 82k | 61k | 100k | 73k | 51k |
| Lucky (defaults) | 34k | 33k | 30k | 32k | 31k | 28k |

Relative to Spectre (1.00): Grip 0.95-1.00, Amber 0.75-0.91, Kemal 0.62-0.92, Lucky (cookies off) 0.61-0.86, Lucky (defaults) 0.22-0.37.

p50 latency at 32 connections is 0.17-0.24 ms for stdlib/Spectre/Grip/Kemal/Amber on `GET /`, and about 0.94 ms for Lucky with defaults.

| Framework | Idle RSS | Release binary | Clean release compile |
|---|---:|---:|---:|
| Crystal stdlib | 6.6 MB | 1.6 MB | 42 s |
| Spectre | 6.6-6.8 MB | 1.7 MB | 43 s |
| Grip | 7.6-7.7 MB | 2.1 MB | 50 s |
| Kemal | 7.8-8.0 MB | 2.3 MB | 55 s |
| Amber | 8.2-8.3 MB | 2.5 MB | 73 s |
| Lucky | 8.4-10.8 MB | 2.3 MB | 57 s |

Peak RSS under load is not reported as a comparison: it ranged from 43 to 112 MB across repetitions for every framework with no pattern (Boehm GC timing).

## What the numbers say

- **Spectre and Grip are effectively tied** and both sit within roughly 0-13% of bare `HTTP::Server`. With 3 repetitions their gap is inside the noise.
- **Kemal** is on par for hello-world and POST (0.9x) but clearly slower on the JSON GET (0.62-0.68x). The cause was not profiled.
- **Amber** (with only its `Error` pipe plugged) lands between: 0.75-0.91x.
- **Lucky with defaults is 3-4x slower than the others.** Its response path (`TextResponse#print`) writes flash and session cookies on every response, encrypting with AES-256-CBC + HMAC, so every reply carries a `Set-Cookie`. For stateless API endpoints Lucky provides `disable_cookies`; with it Lucky recovers to 0.61-0.86x of Spectre. Both variants are reported because the defaults are what you get from `lucky init`.

## Caveats

- These are minimal apps. Lucky and Amber are full-stack frameworks (ORM, templates, sessions, CLI); this benchmark measures only the request path for tiny handlers, not what you give up for the extra features.
- Lucky runs a lean handler chain: `ErrorHandler`, `RouteHandler`, `RouteNotFoundHandler` (no log/session/flash/static handlers). Amber plugs only `Amber::Pipe::Error`. Adding the usual extras would lower both.
- Single core, loopback, closed-loop `wrk`: no multi-core scaling, no TLS, no network, no coordinated-omission correction on the latency percentiles.
- Spectre enforces a 1 MB body limit and Grip, with only `Grip::Handlers::HTTP` plugged, answers 500 (not 404) for unknown routes. Neither affects the measured paths.
- Spectre declares Crystal >= 1.10; it built and passed these checks on 1.21.0.
- An earlier run parsed POST bodies straight from the request IO in the non-Spectre servers. Crystal's JSON parser is slower from an IO than from a String, which made Spectre look ~12% faster than stdlib on POST. That was an artifact of the benchmark, not of Spectre. The IO-parse numbers remain in `results/final/` for reference; the POST column above is from `results/post_string/` where all servers parse from a String.

## Reproduce

```bash
./build.sh                          # shards install + release builds into ./bin
./smoke.sh bin/spectre              # verify responses (also works for each other binary; amber: run from ./amber with AMBER_ENV=production)
REPS=3 DUR=8 WARM=2 CONNS="32 256" ./run_bench.sh results/mine     # needs wrk, taskset, 2+ cores
ONLY=post ./run_bench.sh results/mine_post                         # one scenario only
python3 analyze.py results/mine     # medians, tables, results.json / results.md
```

Environment notes: the Amber build vendors micrate (`amber/vendor/micrate`, via `shard.override.yml`) with its development-dependency stanza removed, only because the sandbox could not reach GitLab to fetch that dev dependency. It is unrelated to request handling.
