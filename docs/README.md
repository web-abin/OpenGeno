# OpenGeno — Design Documentation

> Design rationale and architecture documentation for OpenGeno itself.
> If you're looking for "how do I use this?", read the
> [project README](../README.md) first.

This directory exists to answer **why is OpenGeno shaped the way it is**,
not what it does. It's for contributors, future-me, and anyone trying to
understand the trade-offs behind the public API surface.

## Reading paths

### If you want to understand the project quickly

1. [Motivation](motivation.md) — why this exists and what it replaces
2. [Architecture](architecture.md) — the four moving parts and how they
   compose
3. [Comparison](comparison.md) — vs spec-kit, openspec, and the
   change-driven school in general

### If you're contributing or extending

1. [Architecture](architecture.md)
2. [Doc format](doc-format.md) — schema, drift contract
3. [Workflow](workflow.md) — read-before-change / update-after-change
   and the change classification table
4. [Drift control](drift-control.md) — how the two-layer enforcement
   works (hooks + sync)
5. [Language strategy](language-strategy.md) — how the doc language
   choice perpetuates
6. [Decisions/](decisions/) — every non-obvious choice has its own ADR
7. [Extensibility](extensibility.md) — schema v2 sketch, possible new
   skills, CI integration

### If you're researching this approach

1. [Motivation](motivation.md)
2. [Comparison](comparison.md)
3. [Decisions/0001](decisions/0001-two-skills-not-five.md) and
   [Decisions/0007](decisions/0007-claude-md-as-rule-carrier.md) —
   the two most defining choices

## Index

| Document | Topic |
|----------|-------|
| [motivation.md](motivation.md) | Why OpenGeno exists; what change-driven workflows fail at |
| [architecture.md](architecture.md) | The 4 components: skills, hooks, templates, CLAUDE.md injection |
| [doc-format.md](doc-format.md) | Schema, frontmatter, drift contract — pointer to canonical reference |
| [workflow.md](workflow.md) | Read-before / update-after, change classification |
| [drift-control.md](drift-control.md) | Why two layers (hooks + sync); their roles |
| [language-strategy.md](language-strategy.md) | One-time choice that propagates via CLAUDE.md |
| [comparison.md](comparison.md) | Side-by-side with spec-kit and openspec |
| [extensibility.md](extensibility.md) | Schema versioning, possible future skills, CI patterns |
| [decisions/](decisions/) | ADRs for individual non-obvious choices |

## Conventions for docs in this directory

- **English.** The project's user-facing entry has both English and
  Chinese READMEs. These design docs are English-only because they
  target contributors and the global open-source audience.
- **"Why" over "what".** If a doc reads like it could replace the
  user-facing README, it's in the wrong directory.
- **Don't duplicate.** Schema details live in
  [`skills/geno-init/reference.md`](../skills/geno-init/reference.md).
  Operational steps live in each skill's `SKILL.md`. These docs link
  there rather than restating.
- **ADRs are atomic.** One decision per file, in
  [`decisions/`](decisions/), numbered and immutable once accepted.
  Superseding an ADR means writing a new one that links back.
