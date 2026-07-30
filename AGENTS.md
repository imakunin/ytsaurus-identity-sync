# Repository Guidelines

## Project Structure & Module Organization
This repository is a single Go module (`go.mod`) with most application code in the root package (`package main`).

- Core sync logic: `app.go`, `diff.go`, `ytsaurus.go`, `azure_real.go`, `ldap.go`, `keycloak.go`
- Entrypoint and config: `main.go`, `config.go`, `util.go`
- Tests: `*_test.go` in repo root (`app_*_test.go`, `config_test.go`, `ytsaurus_test.go`)
- Helm chart: `ytsaurus-identity-sync-chart/` (templates + `values.yaml`)
- Example values: `examples/*.values.yaml`
- Example app configs: `*_config.example.yaml`

## Build, Test, and Development Commands
- `go build -v ./...`: compile all packages (mirrors CI build step).
- `make test` or `go test ./...`: run the default test suite (includes testcontainers-based tests).
- `make test-fast`: run tests with `REUSE_YT_CONTAINER=yes` to reuse YTsaurus test container between suite runs.
- `go test -tags integration ./...`: run integration-tagged tests (requires local secrets/config).
- `make lint`: run `golangci-lint`.
- `make lint-fix`: auto-fix supported lint issues.
- `make format`: run `go fmt`.
- `go run . --config ./azure_config.example.yaml`: run app with explicit config path.

## Coding Style & Naming Conventions
Use standard Go formatting and imports (`gofmt` + `goimports`, enforced by lint). Keep files and identifiers idiomatic Go:

- Exported names: `CamelCase`; internal helpers: `camelCase`
- Test files: `*_test.go`; integration tests are additionally tagged with `//go:build integration`
- Keep line length reasonable (lint allows up to 240 chars, but prefer readability)

## Testing Guidelines
Primary framework is Go `testing` with `stretchr/testify` (`require`, `suite`). Prefer table-driven tests for behavior coverage. Keep unit tests runnable via `go test ./...`.

Many tests use Docker/testcontainers; ensure a working local Docker daemon before running `go test ./...`.
Integration-tagged tests also require local config (`config.local.yaml`, ignored by `*.local.yaml`) and secrets via env vars (for example `AZURE_CLIENT_SECRET`, `YT_TOKEN`).

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects (e.g., `Refactor keycloak logs`, `Increase keycloak page limit`) with optional issue references like `(#4)`. Conventional style is acceptable when useful (e.g., `feat(keycloak): ...`).

For PRs: include a clear scope summary, linked issue(s), config/chart impact, and test evidence (`go test`, `make lint`). Ensure GitHub Actions checks pass on `main` PRs.
