# ADR 0003 — Hooks as the enforcement layer

**Status:** Accepted
**Date:** 2026-05-06

## Context

Once we commit to "the AI must update docs when it changes feature
behavior," we need a mechanism to enforce that. Several options:

1. Trust the AI to remember (rules in CLAUDE.md, no machinery)
2. Linting / CI checks (runs out-of-band)
3. Claude Code hooks (runs in-session, automatic)
4. Some combination

The risk with option 1 alone: AI sometimes forgets, especially under
context pressure or in long sessions. Forgotten doc updates are the
exact scenario that produces silent drift, which is the failure mode
this whole system tries to prevent.

The risk with option 2 alone: CI runs after the work is done. The
developer's mental context is gone. Fixing drift becomes a separate
task instead of part of the change.

## Decision

Use Claude Code hooks as the **primary enforcement layer**:

- `PostToolUse` on `Write|Edit` — soft reminder when a tracked file
  is edited, fires immediately so the AI sees it during the session
- `Stop` — drift check at session-end, in `warn` or `block` mode

Combine with CLAUDE.md rules (the "trust the AI" path) as the
*continuous behavior layer*. CLAUDE.md tells the AI *what* to do; the
hooks make sure the AI doesn't get away with not doing it.

CI integration is left as a future option (see
[extensibility.md](../extensibility.md)).

## Alternatives considered

### A. Trust the AI alone, no hooks

- **Pro:** simpler, fewer moving parts, no shell scripts to maintain
- **Con:** drift goes silent the moment the AI forgets. The whole
  system becomes "AI's good intentions" — which has been
  empirically inadequate in this exact failure mode

### B. Hooks for everything (no CLAUDE.md rules)

- **Pro:** maximum enforcement; nothing depends on AI compliance
- **Con:** hooks can detect, warn, and block, but they can't *guide
  behavior*. Without CLAUDE.md rules, the AI knows it's been blocked
  but doesn't know what the right action would have been.
  CLAUDE.md is what makes the AI proactive instead of reactive.

### C. CI-only enforcement

- **Pro:** language-agnostic, runs in a controlled environment,
  catches everything
- **Con:** out-of-band feedback; user has to context-switch back
  to fix later; doesn't help during the session when fixing is
  cheap

## The two-layer split

| Layer | What it does | Failure mode protected against |
|-------|--------------|-------------------------------|
| CLAUDE.md rules | Tells AI to read-before / update-after | AI doing the wrong thing through ignorance |
| Hooks | Detect drift, warn, optionally block | AI doing the wrong thing through forgetfulness |

Both layers are necessary. Removing either creates a class of failures
the other can't catch.

## What hooks specifically can't do

Honest about limitations:

- Hooks don't fire if Claude Code isn't running (manual edits in an
  IDE without a Claude session bypass the layer entirely)
- Hooks fire after the action, not before — they warn but don't
  prevent
- Hooks run shell scripts, which depend on bash / git being
  available. We assume modern Unix-like or WSL.
- Block mode is the strongest enforcement we have, but the user can
  always edit `.feat-tree.json` to switch to warn mode and bypass

These gaps are why `/geno-sync` exists as a manual audit. It's the
recovery path when the automatic layer misses.

## Consequences

### Positive

- Drift gating is real, not aspirational
- Failure mode "AI forgets to update docs" is structurally addressed
- User can dial enforcement strength via `drift_mode` (warn/block)

### Negative

- Hook scripts are platform-dependent (bash); Windows users without
  WSL may struggle. PowerShell variants are an acceptable future
  addition but not in v0.1.
- Hook commands in SKILL.md frontmatter are inline shell strings,
  which are hard to read and maintain. Worth it for discoverability
  (the hook config is colocated with the skill).
- Adds a runtime dependency on git for `git log` calls in
  drift-check.sh. Acceptable given the target audience (AI-assisted
  development).

### Neutral

- The user can opt out by setting `drift_mode: warn` and ignoring
  warnings. We don't try to prevent this.
