# ADR 0005 — Bidirectional code-doc linkage

**Status:** Accepted
**Date:** 2026-05-06

## Context

For drift detection to work, the system needs to know which code
files belong to which doc. Several ways to express this:

1. **Doc → Code** (only): each L3 doc lists its `code:` files
2. **Code → Doc** (only): each code file has a comment / annotation
   pointing to its doc
3. **Bidirectional**: both
4. **Neither / inferred**: tooling computes the mapping from
   directory structure or git blame heuristics

## Decision

**Doc → Code is required**, encoded in L3 frontmatter `code:` field.

**Code → Doc is recommended but optional**, via a comment convention
the user can adopt:

```ts
// @og: feat-tree/auth/login.md
```

The drift checker only relies on the doc → code direction. The
reverse direction is for IDE / human navigation only.

## Alternatives considered

### A. Only Doc → Code

- **Pro:** simpler, one source of truth (the doc), no code pollution
- **Con:** the post-edit-warn hook has to grep the entire tree on
  every edit to find which doc owns the just-touched file. For large
  trees this is slow.

### B. Only Code → Doc

- **Pro:** fast lookups (read the file's own annotation), no
  centralized list to maintain
- **Con:** requires every code file to be annotated, including files
  in languages without clean annotation idioms (e.g. JSON, YAML
  configs that are part of a feature). And: the drift checker would
  need to scan all code files instead of just docs, which is much
  more work.

### C. Bidirectional, both required

- **Pro:** maximum redundancy; consistency check possible
- **Con:** every change requires updating two places (doc's `code:`
  list AND the code file's annotation), doubling the maintenance
  surface. Also: enforcing that a code file is annotated *before* it
  can be in a `code:` list would block adoption in projects that
  can't easily annotate.

### D. Inferred (no explicit mapping)

- **Pro:** zero maintenance
- **Con:** inference is unreliable. Directory layout doesn't always
  match feature decomposition. Git blame doesn't know which feature
  a file belongs to. Heuristic mappings break.

## Why this hybrid

**Doc → Code (required)** is the load-bearing direction:

- The drift checker needs an authoritative list of "what files does
  this doc claim to describe?" Without it, drift detection is
  impossible.
- The list lives with the doc, where the writer is making the
  semantic call ("these files implement this feature"). The writer
  has the right context to make the call.
- Updating the list is part of the same edit as updating the doc —
  no separate workflow.

**Code → Doc (optional)** is for navigation only:

- Some teams want IDE support for "where is this feature documented?"
  An annotation enables that.
- Some teams don't care or can't annotate (languages without clean
  comments, generated files). They lose the navigation but the
  drift checker still works.

By making one required and one optional, we cover the full value
without over-burdening adoption.

## What the doc → code list looks like

In L3 frontmatter:

```yaml
code:
  - lib/features/auth/login_page.dart
  - lib/features/auth/login_controller.dart
  - lib/api/auth_service.dart
```

Each entry is a relative path from the project root. Single-feature
ownership per path is encouraged (one path per L3 doc); shared
infrastructure code shouldn't be listed because it isn't owned by
any single feature.

## Consequences

### Positive

- Drift detection has a reliable input (the `code:` list)
- Doc reflects feature scope explicitly — readers see at a glance
  what the feature touches
- Code navigation (when annotation is adopted) becomes easy

### Negative

- The `code:` list has to be manually maintained. When a new file is
  added to a feature, the doc has to be updated.
- Risk of drift between `code:` list and actual code (e.g. file
  renamed, list not updated). The drift checker reports this as
  `BROKEN`, so it's recoverable.

### Neutral

- Files not in any `code:` list are implicitly "infrastructure" or
  "untracked." This is correct: not every file is feature code, and
  forcing every file into a doc creates the wrong incentive.
