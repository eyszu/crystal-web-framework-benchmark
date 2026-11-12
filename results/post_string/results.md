
### POST /people (typed JSON in/out) - 32 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Crystal stdlib (baseline) | 90,172 | 85,435-92,902 | 0.33 ms | 1.32 ms | 1.04x |
| Spectre | 86,918 | 80,564-90,883 | 0.35 ms | 1.35 ms | 1.00x |
| Grip | 84,118 | 82,519-84,166 | 0.35 ms | 1.48 ms | 0.97x |
| Kemal | 78,886 | 74,313-81,708 | 0.38 ms | 1.53 ms | 0.91x |
| Amber | 76,546 | 70,490-77,367 | 0.40 ms | 1.58 ms | 0.88x |
| Lucky (cookies off) | 60,769 | 57,640-61,494 | 0.49 ms | 1.77 ms | 0.70x |
| Lucky (defaults) | 29,699 | 29,051-30,055 | 1.09 ms | 2.96 ms | 0.34x |

### POST /people (typed JSON in/out) - 256 connections

| Framework | req/s (median) | min-max | p50 | p99 | vs Spectre |
|---|---:|---:|---:|---:|---:|
| Crystal stdlib (baseline) | 76,389 | 75,654-80,896 | 3.16 ms | 8.09 ms | 1.02x |
| Spectre | 74,555 | 71,517-80,024 | 3.24 ms | 8.56 ms | 1.00x |
| Grip | 71,515 | 68,928-74,267 | 3.26 ms | 8.84 ms | 0.96x |
| Kemal | 68,839 | 60,705-70,284 | 3.56 ms | 8.67 ms | 0.92x |
| Amber | 63,963 | 63,273-64,486 | 3.83 ms | 9.24 ms | 0.86x |
| Lucky (cookies off) | 50,585 | 46,511-53,737 | 4.75 ms | 10.84 ms | 0.68x |
| Lucky (defaults) | 27,895 | 27,105-28,610 | 8.93 ms | 17.61 ms | 0.37x |

### Memory and startup (single process, after the full load run)

| Framework | idle RSS | peak RSS | time to first response |
|---|---:|---:|---:|
| Crystal stdlib (baseline) | 6.6 MB | 50.6 MB | 27 ms |
| Spectre | 6.6 MB | 52.3 MB | 8 ms |
| Kemal | 7.8 MB | 52.6 MB | 10 ms |
| Grip | 7.6 MB | 55.6 MB | 10 ms |
| Amber | 8.2 MB | 54.1 MB | 12 ms |
| Lucky (cookies off) | 8.3 MB | 59.3 MB | 26 ms |
| Lucky (defaults) | 10.4 MB | 58.4 MB | 29 ms |

No non-2xx responses or socket errors in any run.
