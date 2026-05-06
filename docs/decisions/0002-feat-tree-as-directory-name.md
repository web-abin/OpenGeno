# ADR 0002 — `feat-tree/` as the doc tree directory name

**Status:** Accepted
**Date:** 2026-05-06

## Context

The host project gets a new directory at the project root that
contains the L1/L2/L3 tree. We need a name for it. Candidates:

- `docs/feat/`
- `docs/features/`
- `geno/`
- `wiki/`
- `specs/`
- `feat-tree/`

The choice has significant downstream effects: it appears in URLs,
in `code:` frontmatter (sort of), in CI configs, in IDE workspace
listings. Renaming later is costly.

## Decision

`feat-tree/` at the project root.

## Alternatives considered

### `docs/feat/` or `docs/features/`

- **Pro:** lives under existing `docs/` convention, doesn't add a
  new top-level directory
- **Con:** many projects already have a `docs/` directory used for
  user manuals / API docs / contributor guides. Mixing OpenGeno's
  feature tree under there creates conflict and ambiguity
  ("is `docs/auth.md` an OpenGeno feature doc or a user manual?").
  Also, OpenGeno's tree isn't really "documentation" in the
  end-user sense; it's the project's *internal* spec.

### `geno/`

- **Pro:** matches the brand (OpenGeno), short
- **Con:** opaque to a contributor who doesn't know OpenGeno —
  they see `geno/` and don't know what's inside. Breaks the
  "self-explanatory" property.

### `wiki/`

- **Pro:** familiar concept (project wiki)
- **Con:** wiki implies free-form, browsing-oriented, no formal
  schema. OpenGeno's tree has a formal schema (frontmatter, drift
  contract). Calling it a wiki sets the wrong expectation.

### `specs/`

- **Pro:** familiar to spec-driven workflows
- **Con:** confusing precisely *because* it's familiar to
  change-driven workflows. OpenGeno isn't change-spec; calling its
  tree `specs/` invites misreading the design.

### `feat-tree/`

- **Pro:** descriptive (it's a tree of features), self-explanatory
  to a new reader, doesn't collide with conventional names
- **Con:** marginally less compact than `geno/`

## The tradeoff

We picked descriptiveness over brevity. A new contributor seeing
`feat-tree/` in a project directory listing has a clear mental
model immediately: "tree of features." `geno/` would require them
to look it up.

The brand is `OpenGeno`. The methodology / data structure is
"feature tree." The directory name reflects the data structure, not
the brand. This is intentional separation — if the brand changes
later, the directory name doesn't have to.

## Consequences

### Positive

- Self-documenting directory name
- Doesn't conflict with conventional `docs/`, `wiki/`, `specs/`
- Survives a brand change

### Negative

- Slightly longer than alternatives
- Contains a hyphen (some legacy file systems / tools dislike;
  none we encounter in the AI / web / mobile dev space)

### Neutral

- The `tree_path` field in `.feat-tree.json` allows users to override
  if they really need a different name — escape hatch, not encouraged
