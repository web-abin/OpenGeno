# ADR 0006 — Documentation language as one-time init choice

**Status:** Accepted
**Date:** 2026-05-06

## Context

The user picks a language for the feature tree's content (English or
Chinese). Several places this could be configured:

- Per session (ask every time)
- Per project (ask once at init, persist)
- Per file (each doc declares its own)
- Globally (user setting, applies to all projects)

We also need to decide **how the choice propagates** — what mechanism
ensures the AI maintains the language consistently across sessions
and across docs.

## Decision

**Init-time choice, project-scoped, propagated via CLAUDE.md
injection.**

Specifically:

1. `/geno-init` asks once: English or Chinese, default English
2. The choice fixes the templates used (`*.md` vs `*.zh.md`)
3. The choice fixes the injection text appended to `CLAUDE.md`
   (`claude-md-injection.md` vs `.zh.md`)
4. Every L3 doc thereafter is written in the chosen language
5. The injection text in `CLAUDE.md` *names* the chosen language
   explicitly so future sessions see the rule and comply

## Alternatives considered

### A. Per session (ask every time)

- **Pro:** maximum flexibility per work session
- **Con:** users want consistency, not flexibility, on this
  dimension. Asking every session is a tax. Worse, if a user picks
  Chinese in session 1 and English in session 2, the tree becomes
  bilingual in unpredictable ways.

### B. Per file (each doc declares)

- **Pro:** technically possible, lets users mix
- **Con:** mixing within a tree is anti-feature. Cross-feature links
  would jump between languages. AI maintenance gets harder.

### C. Globally (user-level setting)

- **Pro:** one setting per user
- **Con:** users may work on different projects with different
  language requirements (work project English, hobby project
  Chinese). Per-project is the right scope.

### D. Auto-detect from project context

- **Pro:** zero configuration
- **Con:** unreliable. A codebase could be majority English
  comments but the user wants Chinese docs (or vice versa). Project
  language conventions don't always match documentation language
  preferences.

## Why CLAUDE.md is the propagation mechanism

The chosen language has to *stay* consistent across sessions. Several
mechanisms could achieve this:

- **A flag in `.feat-tree.json`**: the AI would have to read it on
  every session. CLAUDE.md is also read on every session, so this
  doesn't add unique value.
- **A frontmatter field on every doc**: every doc would carry the
  language. AI would read each doc's frontmatter to know.
  Maintenance overhead per doc.
- **The injection text in `CLAUDE.md`**: the rules text *itself* says
  "the language is X." The AI reads the rules, follows them.

The CLAUDE.md mechanism wins because:

1. It piggybacks on the existing rule-propagation channel (the
   workflow rules are already there)
2. Zero extra reads per session
3. Self-documenting — any human or AI reading CLAUDE.md sees the
   language declared explicitly
4. Removing OpenGeno from a project is one operation: delete the
   marked block in CLAUDE.md

## Why monolingual, not bilingual

Discussed in detail in
[language-strategy.md](../language-strategy.md#why-monolingual-not-bilingual).
Summary: bilingual repos have one authoritative language and one
that drifts. Avoid the trap.

## What about switching languages later?

Currently: re-running `/geno-init` aborts if `feat-tree/` exists.
Switching languages requires either:

- Manually editing each doc (or AI-assisted bulk translation)
- Deleting the tree and re-running init (loses content)

This is intentional friction. Mid-life language switches should be
deliberate, not accidental. We don't smooth the path because we
don't want users wandering into bilingual chaos.

A future `/geno-translate` skill could do bulk translation cleanly
(see [extensibility.md](../extensibility.md)). Not in v0.1.

## Consequences

### Positive

- Trees stay monolingual without per-doc enforcement
- Users pick once, no ongoing decision tax
- Language rule lives in the same channel as workflow rules

### Negative

- Switching languages is non-trivial (tree-wide manual edit)
- New users have to make the choice at init time without yet
  knowing the system; we mitigate by defaulting to English

### Neutral

- The set of supported languages (currently English + Chinese) is
  fixed by which template files exist. Adding more is a content
  task (write the template variants), not an architecture change.
