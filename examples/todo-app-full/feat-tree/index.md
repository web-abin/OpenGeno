---
type: og-root
schema: 1
last_synced_commit: ""
---

# TodoApp Feature Tree

> Example feature tree — **`gen_mode: "full"`** demo. This is what
> `/geno-init` produces when the user picks the one-shot full-docs
> mode. Section bodies are AI-generated from a deeper code read at
> init time and **have not been verified against the source**.
> `last_synced_commit:` is empty everywhere; bumping a SHA requires a
> human review pass against the actual code first.

## Modules

| Module | Description | Path |
|--------|-------------|------|
| Auth | Sign in / sign up / sign out | [auth/](auth/index.md) |

## Out of scope

- i18n (cross-cutting, see `lib/i18n/`)
- Theme tokens (cross-cutting, see `lib/theme/`)
- Telemetry, crash reporting
- Build tooling

## Conventions

- Slugs are kebab-case.
- Sub-features (e.g. multi-step flows) live under their own subdirectory.
- Cross-feature links use relative paths.
