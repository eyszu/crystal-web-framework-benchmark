
### GET / - 32 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Crystal stdlib (baseline) | 142,916 | 140,619-164,625 | 0.16 ms | 0.75 ms | 1.13x |
| Spectre | 126,783 | 126,733-139,388 | 0.17 ms | 0.91 ms | 1.00x |
| Grip | 126,158 | 115,799-130,384 | 0.20 ms | 0.96 ms | 1.00x |
| Amber | 115,090 | 114,445-131,656 | 0.22 ms | 1.06 ms | 0.91x |
| Kemal | 113,712 | 92,962-116,973 | 0.24 ms | 1.15 ms | 0.90x |
| Lucky (cookies off) | 108,414 | 104,599-113,131 | 0.25 ms | 1.24 ms | 0.86x |
| Lucky (defaults) | 34,261 | 34,092-35,103 | 0.94 ms | 2.41 ms | 0.27x |

### GET /users/:id (JSON) - 32 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Crystal stdlib (baseline) | 128,231 | 124,559-130,272 | 0.20 ms | 1.11 ms | 1.08x |
| Spectre | 119,177 | 114,633-128,221 | 0.21 ms | 0.99 ms | 1.00x |
| Grip | 115,292 | 103,365-135,791 | 0.20 ms | 1.02 ms | 0.97x |
| Amber | 96,268 | 81,619-97,753 | 0.29 ms | 1.41 ms | 0.81x |
| Lucky (cookies off) | 81,956 | 80,331-84,482 | 0.37 ms | 1.44 ms | 0.69x |
| Kemal | 81,587 | 79,252-82,507 | 0.37 ms | 1.49 ms | 0.68x |
| Lucky (defaults) | 32,585 | 29,873-33,510 | 0.99 ms | 2.40 ms | 0.27x |

### POST /people (typed JSON in/out) - 32 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Spectre | 89,560 | 82,945-91,980 | 0.33 ms | 1.27 ms | 1.00x |
| Grip | 79,595 | 73,362-83,268 | 0.38 ms | 1.35 ms | 0.89x |
| Crystal stdlib (baseline) | 76,916 | 73,424-82,653 | 0.40 ms | 1.37 ms | 0.86x |
| Kemal | 71,411 | 68,214-72,416 | 0.42 ms | 1.53 ms | 0.80x |
| Amber | 71,050 | 66,000-72,637 | 0.42 ms | 1.55 ms | 0.79x |
| Lucky (cookies off) | 57,373 | 55,123-59,404 | 0.54 ms | 1.70 ms | 0.64x |
| Lucky (defaults) | 29,117 | 29,046-29,178 | 1.11 ms | 2.94 ms | 0.33x |

### GET / - 256 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Spectre | 140,539 | 132,515-143,769 | 1.48 ms | 4.71 ms | 1.00x |
| Crystal stdlib (baseline) | 136,313 | 126,535-147,694 | 1.54 ms | 4.42 ms | 0.97x |
| Grip | 133,479 | 112,085-136,541 | 1.58 ms | 4.86 ms | 0.95x |
| Amber | 107,328 | 106,949-121,211 | 2.13 ms | 6.54 ms | 0.76x |
| Kemal | 104,122 | 97,797-110,038 | 2.25 ms | 6.78 ms | 0.74x |
| Lucky (cookies off) | 100,191 | 98,528-101,990 | 2.39 ms | 6.60 ms | 0.71x |
| Lucky (defaults) | 31,578 | 30,221-31,732 | 7.90 ms | 15.80 ms | 0.22x |

### GET /users/:id (JSON) - 256 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Spectre | 118,715 | 114,002-120,644 | 1.94 ms | 6.46 ms | 1.00x |
| Grip | 113,622 | 110,084-122,081 | 2.08 ms | 6.35 ms | 0.96x |
| Crystal stdlib (baseline) | 108,993 | 104,383-121,259 | 2.08 ms | 7.04 ms | 0.92x |
| Amber | 89,608 | 79,685-89,946 | 2.67 ms | 8.16 ms | 0.75x |
| Kemal | 73,660 | 72,522-76,507 | 3.08 ms | 8.94 ms | 0.62x |
| Lucky (cookies off) | 72,803 | 71,899-84,701 | 3.34 ms | 8.67 ms | 0.61x |
| Lucky (defaults) | 30,530 | 29,387-30,614 | 8.28 ms | 15.92 ms | 0.26x |

### POST /people (typed JSON in/out) - 256 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Spectre | 76,561 | 73,023-80,669 | 3.06 ms | 8.90 ms | 1.00x |
| Crystal stdlib (baseline) | 68,858 | 64,090-69,531 | 3.48 ms | 9.35 ms | 0.90x |
| Grip | 64,268 | 57,417-69,540 | 3.77 ms | 9.78 ms | 0.84x |
| Kemal | 62,922 | 61,054-68,391 | 3.78 ms | 9.79 ms | 0.82x |
| Amber | 60,504 | 59,389-62,235 | 3.95 ms | 9.35 ms | 0.79x |
| Lucky (cookies off) | 48,825 | 47,235-51,231 | 4.94 ms | 11.57 ms | 0.64x |
| Lucky (defaults) | 26,737 | 26,703-27,654 | 9.41 ms | 17.97 ms | 0.35x |

### Memory and startup (single process, after the full load run)

| Framework | idle RSS | peak RSS | time to first response |
|---|---:|---:|---:|
| Crystal stdlib (baseline) | 6.8 MB | 54.6 MB | 9 ms |
| Spectre | 6.8 MB | 59.8 MB | 10 ms |
| Kemal | 8.0 MB | 75.2 MB | 24 ms |
| Grip | 7.7 MB | 107.7 MB | 10 ms |
| Amber | 8.3 MB | 58.2 MB | 25 ms |
| Lucky (cookies off) | 8.4 MB | 58.2 MB | 28 ms |
| Lucky (defaults) | 10.8 MB | 66.4 MB | 29 ms |

No non-2xx responses or socket errors in any run.
