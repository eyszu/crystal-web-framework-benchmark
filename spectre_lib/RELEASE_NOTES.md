# Spectre 0.1.0

First release. An Express-style web microframework for Crystal, built on `HTTP::Server`.

## Highlights

- **Express-style API.** `app.get "/users/:id" do |req, res| ... end`, with `use` middleware, groups, mountable routers and `res.json`.
- **Typed JSON bodies.** `req.json(User)` reads straight into a `JSON::Serializable` type. Bad JSON answers 400, missing fields answer 422.
- **Fast routing.** Routes without params are one hash lookup. Param routes use a trie compared in place. Middleware chains are built once at startup.
- **Sensible defaults.** Automatic 404, 405 with `Allow`, HEAD and OPTIONS. Errors never leak exception messages.
- **Built in.** Logger, CORS, and static files with ETag/304 that block dotfiles, traversal and escaping symlinks.
- **Easy to test.** `app.request("GET", "/path")` runs the whole stack in memory.

## Performance

One core, shared 2-vCPU VM, release build, against Go 1.24.7 `net/http`:

| Route | Spectre | Go |
|---|---|---|
| `GET /` | 138–159k req/s | 65–67k |
| `GET /users/:id` (JSON) | 117–118k | 50–54k |
| `POST /people` (typed JSON) | 77–96k | 45–46k |

Overhead over plain `HTTP::Server` was not measurable. Numbers vary 10–20% between runs. Multi-core throughput was not benchmarked.

## Differences from Express

- Middleware calls `nxt.call` (`next` is a Crystal keyword).
- A middleware applies to routes registered after it.
- Exact static routes beat `:param` routes, and explicit routes beat `app.static`.

## Not included yet

Sessions, templates, multipart uploads, WebSocket routing, response compression, HTTP/2.

## Requirements

Crystal 1.10 or newer (developed and tested on 1.11.2). No other dependencies. 34 specs pass.
