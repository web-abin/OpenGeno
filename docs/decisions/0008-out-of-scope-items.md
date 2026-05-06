# ADR 0008 — Out-of-scope items list

**Status:** Accepted
**Date:** 2026-05-06

## Context

Not everything in a codebase belongs in the feature tree. The tree
documents *features* — user-observable behavior. Many things in a
typical codebase aren't features:

- Internationalization / translations
- Analytics, telemetry
- Build tooling, CI/CD
- Error reporting (Sentry, etc.)
- Logging
- Pure utility helpers (date formatting, string manipulation)
- Theme primitives (color tokens, typography scales)

We need to communicate this list, *and* communicate the principle
behind it so users can decide for items not on the list.

## Decision

Maintain an explicit out-of-scope list in:

- The L1 root index template (so it appears in every project's
  `feat-tree/index.md`)
- The README (project-level documentation)
- The CLAUDE.md injection text (so the AI sees it every session)

State the underlying principle:

> A feature is something a user can observe behaving differently
> after a change. Anything else is infrastructure.

## Alternatives considered

### A. No list, only principle

- **Pro:** minimalist, forces users to learn the principle
- **Con:** the principle has edge cases. "Theme primitives" — does
  changing them affect behavior? Maybe (a primary color change is
  visible). The list provides concrete answers for common cases,
  saving everyone from re-deriving the boundary.

### B. List only, no principle

- **Pro:** concrete, no interpretation needed for items on the
  list
- **Con:** the list is finite. New categories of infrastructure
  appear over time. Without the principle, users can't extend the
  list themselves; they ask "is X a feature?" and have nowhere to
  look.

### C. List + principle (chosen)

- **Pro:** concrete answers for common cases, plus a tool for
  resolving novel cases
- **Con:** users have to remember both. Acceptable: the list lives
  in the tree (visible) and the principle is in the README and
  CLAUDE.md.

## The principle, expanded

> Would a user interacting with the product notice this change?

Test cases:

- ✅ "Add OAuth login button" — user sees a new button
- ❌ "Translate UI to Spanish" — translation doesn't change *what*
  the feature does; the user notices language but the behavior is
  the same
- ❌ "Switch logging library from log4j to slf4j" — invisible to user
- ✅ "Add 'Forgot password' link to login page" — new affordance
- ❌ "Refactor LoginButton component for reuse" — same UI, same
  behavior
- ✅ "Show password strength meter on signup" — new visual element
  affecting behavior
- ❌ "Add Sentry breadcrumbs to login flow" — invisible
- ❌ "Bump axios from 1.6 to 1.7" — invisible (unless axios behavior
  itself changes the feature, which is rare)

The "would a user notice" rule isn't perfect — there are edge cases
where infrastructure changes leak into UX (a logging change that
slows requests enough to matter). For those, escalate the judgment
call: if a user *does* notice, document it.

## Why these specific categories

Each item on the list earned its spot by being a common confuser:

- **i18n**: looks like a feature change ("we now support Spanish"),
  but the underlying features don't change. The "supports Spanish"
  fact belongs in a project-level README, not in feat-tree.
- **Analytics / telemetry**: invisible side channel; tracking exists
  separate from the feature being tracked.
- **Build / CI**: explicitly developer-facing, not user-facing.
- **Error reporting**: failure-path infrastructure; the *feature*
  failure-mode docs cover what the user sees, error reporting
  covers what the engineer sees.
- **Logging**: invisible.
- **Pure utilities**: helpers with no semantic ownership of behavior.
  If a util has behavior worth documenting, that behavior probably
  belongs to the feature using it.
- **Theme primitives**: tokens (colors, sizes). The *use* of these
  in features is documented in the feature; the tokens themselves
  are infrastructure.

## What about cross-cutting features?

A genuinely cross-cutting feature (like "dark mode") is a borderline
case. Dark mode changes user-visible behavior across many features,
so it's a feature. But it doesn't fit cleanly under any single
module.

The recommendation: create a `theming/` or `appearance/` module with
features like "dark mode toggle," "user theme preference." The
*tokens* are infrastructure (out of scope); the *behavior* of
applying tokens is in scope.

This matches how cross-cutting concerns are typically organized in
codebases.

## Consequences

### Positive

- Clear answer for the common cases
- Principle for novel cases
- Aligned across README, tree, and CLAUDE.md (no contradictions)

### Negative

- The list will need maintenance over time as new infrastructure
  patterns emerge (e.g. AI-specific instrumentation, observability
  tooling, new categories we haven't named)
- Users may still argue boundary cases. That's healthy — the
  boundary should be discussed for the team's specific context

### Neutral

- The list isn't exhaustive. Items not on it aren't automatically
  in scope; they should be tested against the principle.
