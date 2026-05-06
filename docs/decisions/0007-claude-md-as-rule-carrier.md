# ADR 0007 — `CLAUDE.md` as the workflow rule carrier

**Status:** Accepted
**Date:** 2026-05-06

## Context

The OpenGeno workflow has rules that the AI must follow on every
session:

- Read the L3 doc before changing a feature
- Update the L3 doc after changing a feature
- Maintain cross-link consistency
- Keep the tree's language consistent
- Apply the change-classification table when deciding whether to
  update

Where do these rules live? Several options:

1. In each skill's `SKILL.md`
2. In a central `RULES.md` somewhere
3. Injected into the host project's `CLAUDE.md` at init time
4. In a Claude Code "system prompt" extension

## Decision

Inject the rules into the host project's `CLAUDE.md` (and `AGENTS.md`
if present) at `/geno-init` time, wrapped in
`<!-- BEGIN OpenGeno -->` / `<!-- END OpenGeno -->` markers.

The injection text is in
[`templates/claude-md-injection.md`](../../skills/geno-init/templates/claude-md-injection.md)
(or `.zh.md` for Chinese trees).

## Alternatives considered

### A. Rules in each skill's SKILL.md

- **Pro:** rules live with the skill that uses them
- **Con:** skills are *invoked*, not continuously read. Rules in
  SKILL.md only fire when the user runs that command. The rules
  we need are *continuous* — apply on every code change, not just
  when a slash command is typed. Wrong shape.

### B. A central `RULES.md` in the project

- **Pro:** centralized, easy to find
- **Con:** AI doesn't read arbitrary `RULES.md` files automatically.
  We'd have to either (a) reference it from `CLAUDE.md` (which
  reduces this option to option C with extra steps), or (b) hope the
  AI finds it (unreliable).

### C. Inject into `CLAUDE.md`

- **Pro:** Claude Code reads `CLAUDE.md` on every session as part
  of its standard prompt assembly. Rules placed there are seen
  every time, no command needed. Zero ongoing maintenance.
- **Con:** "owns" a section of the user's `CLAUDE.md`. We mark our
  block with `<!-- BEGIN OpenGeno -->` so the user can edit
  freely, but it's still our footprint in their file.

### D. Claude Code system prompt extension

- **Pro:** doesn't pollute user files
- **Con:** Claude Code doesn't expose a stable mechanism for skills
  to inject system-prompt content (other than via SKILL.md which is
  per-invocation). Hooks fire as enforcement, not as constant
  context.

## Why option C wins

The fundamental observation: **OpenGeno needs the AI to apply rules
on every session, regardless of whether a slash command is invoked.**
That requirement narrows the choices to "things the AI reads on
every session," and `CLAUDE.md` is the canonical such thing.

This is the same reason `CLAUDE.md` is where projects already put
team conventions, code style rules, architecture guidelines, etc. We
fit into the existing convention.

## What we inject

The injection text (in the chosen language) covers:

- Language declaration ("Doc language: English / 中文")
- Read-before-change rule with steps
- Update-after-change rule with critical SHA-bump warning
- Change classification table
- New-feature creation rule (template path, real content required)
- Drift suspect → run `/geno-sync`
- What does NOT belong in the tree (out-of-scope list)

This is the bulk of OpenGeno's "operating manual" for the AI. It's
~150 lines.

## Markers and idempotency

The block is wrapped:

```markdown
<!-- BEGIN OpenGeno -->
... rules content ...
<!-- END OpenGeno -->
```

`/geno-init` checks for `BEGIN OpenGeno` before injecting. If found,
it aborts that file's injection (already done) and warns the user.
This makes re-runs safe.

Removing OpenGeno from a project is: delete the marked block.

## Consequences

### Positive

- Rules apply on every session automatically
- Zero command-invocation overhead
- Self-documenting — any reader of CLAUDE.md sees the rules in
  context
- Same channel as workflow language declaration (unified
  propagation)

### Negative

- We "own" a section of the user's CLAUDE.md
- The injection is text — if we change the rules in a future
  OpenGeno version, existing projects don't auto-update. They have
  to either re-run `/geno-init` after deleting the block, or apply
  the diff manually.

### Neutral

- Rules can be edited by the user. We don't try to enforce
  identity to the canonical text. If a team wants to soften "must"
  to "should" in their own deployment, that's their call.
