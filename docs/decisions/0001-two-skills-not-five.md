# ADR 0001 — Two skills, not five

**Status:** Accepted
**Date:** 2026-05-06

## Context

The original design had five skills:

- `/geno-init` — bootstrap
- `/geno-find` — locate the right L3 doc for a task
- `/geno-add` — create a new L3 doc when adding a feature
- `/geno-update` — update an L3 doc after a code change
- `/geno-sync` — drift detection and reconciliation

Each had its own SKILL.md with a step-by-step procedure for the AI.

The five-skill design was structurally clean — every operation in the
workflow had a corresponding command. But it had two problems:

1. **Most of these aren't user-scheduled events.** `find`, `add`, and
   `update` are things the AI does *continuously* during normal work,
   not when the user types `/geno-find`. Wrapping continuous behavior
   in slash commands creates the wrong shape — users have to remember
   to invoke them, and forgetting means the workflow breaks.
2. **Surface area pollution.** Five new slash commands is a lot to ask
   a user to learn for what is, conceptually, a documentation system.
   The mental model "two operations: bootstrap and audit" is much
   easier to communicate than "five operations covering different
   stages of a workflow."

## Decision

Keep two user-invocable skills:

- `/geno-init` — one-time bootstrap (intentional act)
- `/geno-sync` — on-demand drift audit (intentional act)

Move the workflow rules previously embedded in `find`, `add`, and
`update` skills into the **CLAUDE.md injection text** that
`/geno-init` appends to the host project. The AI reads these rules
on every session and follows them as continuous behavior.

## Alternatives considered

### A. Keep all five skills

- **Pro:** explicit, visible, every workflow step has a name
- **Con:** users have to remember to invoke them; if they forget,
  drift accumulates silently; users have to learn five commands

### B. Two skills + slash command shortcuts (`/geno-find`, etc.)

- **Pro:** AI behavior is the same as putting rules in CLAUDE.md;
  user can also invoke explicitly
- **Con:** doubles the surface area without adding value; users
  who type `/geno-find` get the same outcome as the AI doing it
  on its own; we'd be optimizing for a workflow that doesn't need
  optimization

### C. One skill (`/geno`) with subcommands

- **Pro:** minimal surface
- **Con:** Claude Code doesn't have a native subcommand convention
  for slash commands; sub-skill namespacing exists but isn't
  marketplace-standard; init and sync are different enough that
  combining them obscures both

## Consequences

### Positive

- Smaller, more memorable user-facing API
- Continuous behaviors live in CLAUDE.md where they belong (the
  AI reads them every session, can't "forget" to invoke them)
- Hooks remain the enforcement layer; the sync skill is the
  reconciliation layer

### Negative

- Workflow logic is now spread across two locations:
  `claude-md-injection.md` (rules text) and skill SKILL.md files
  (operational steps for init/sync). Contributors have to know to
  look in both.
- A user who *wants* to explicitly invoke "find this doc for me"
  can't — they have to phrase it as a request and let the AI
  follow CLAUDE.md rules. Marginal loss of discoverability.

### Neutral

- The tree's behavior at the file level is identical; this is
  purely about API surface.
