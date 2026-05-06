# ADR 0004 — Three-tier hierarchy with lazy loading

**Status:** Accepted
**Date:** 2026-05-06

## Context

The doc tree organizes feature documentation. We need to choose a
structure that:

- Scales to projects with 50–500 features
- Lets AI find the right doc quickly without reading the whole tree
- Stays browseable for humans
- Keeps token cost per AI task manageable

Possible structures:

1. **Flat** — one folder, one file per feature
2. **Two-tier** — module folders + feature files
3. **Three-tier** — root index + module indexes + feature files
4. **Arbitrary depth** — modules can nest indefinitely

## Decision

Three-tier with lazy loading:

- **L1**: `feat-tree/index.md` — root, lists all modules, ~500 tokens
- **L2**: `feat-tree/<module>/index.md` — module index, lists features
- **L3**: `feat-tree/<module>/<feature>.md` — actual feature spec

AI loads L1 always (it's tiny and gives the project map). L2 and L3
load only when a task narrows to a specific module / feature.

Sub-features can nest one more level (`feat-tree/<module>/<parent>/<child>.md`)
when a feature has multiple sub-flows, but we discourage going deeper.

## Alternatives considered

### Flat (option 1)

- **Pro:** simplest structure, no hierarchy decisions to make
- **Con:**
  - Breaks at scale (~30+ features become hard to scan in a single
    directory)
  - No place for module-level invariants ("all features in this
    module require auth")
  - AI loading "the index" loads every feature's metadata to
    construct a map

### Two-tier (option 2 — module/feature, no L1)

- **Pro:** simpler than three-tier, scales reasonably
- **Con:** no quick "project map" view. AI loading the project must
  read every module's index to know what's there. For large projects,
  this is more tokens than necessary.

### Arbitrary depth (option 4)

- **Pro:** handles deeply nested feature hierarchies
- **Con:**
  - Encourages over-organization (engineers love nesting)
  - Unbounded depth means unbounded read paths for AI
  - Cross-link path lengths grow with depth, adding maintenance cost
  - Most projects don't actually have hierarchical features more
    than 2–3 levels deep

### Three-tier (option 3, chosen)

- **Pro:**
  - L1 always-loaded gives the AI a project map for cheap (~500
    tokens)
  - L2 always-loaded *per module* keeps module-level invariants in
    the right scope
  - L3 lazy-loaded scales to large projects without runaway token
    use
  - Sub-feature nesting (one extra level under a module) handles
    multi-step flows without going arbitrary
- **Con:** mild overhead for tiny projects (10 features). Three
  tiers is more structure than they need. Acceptable: the structure
  doesn't hurt, just isn't fully utilized.

## Token-budget math

Rough numbers, assuming GPT-class agent context limits:

| Project size | Flat | Two-tier | **Three-tier (lazy)** |
|--------------|------|----------|----------------------|
| 10 features | ~5k tokens to load all | ~3k | ~2k |
| 50 features | ~25k | ~10k | **~3k (1 L2 + 1 L3 read)** |
| 200 features | ~100k+ (won't fit) | ~30k | **~3k (same)** |

The three-tier design keeps per-task token cost roughly constant as
project size grows. That's the load-bearing property.

## Why L1 is "always loaded"

`/geno-init` injects a reference to `feat-tree/index.md` into the
host project's `CLAUDE.md`. The AI reads CLAUDE.md every session,
which means it reads the L1 index every session. L1 is small enough
that this doesn't burn budget; it's the entry point for navigating
the rest of the tree.

L2 and L3 load on demand based on which features the task touches.

## Why we cap nesting at one extra level

A feature like "password-reset" might have multiple sub-screens:
"request reset", "confirm token", "set new password". Putting all
three in `feat-tree/auth/password-reset.md` is wrong (one big doc).
Putting them at `feat-tree/auth/password-reset/{request,confirm,set}.md`
is right (one parent, multiple children).

Going deeper —
`feat-tree/auth/password-reset/request/email/format-validation.md` —
is over-organization. The format-validation isn't a feature; it's
implementation detail. The rule "would a user notice" applies:
nesting deeper than 2 levels is rarely justified for user-visible
behavior.

## Consequences

### Positive

- Scales to large projects
- Keeps per-task token cost low
- Module-level reasoning has a natural home (L2)
- Sub-feature flows fit naturally

### Negative

- Tiny projects are slightly over-organized
- Authors have to make L1 / L2 placement decisions early (handled
  by `/geno-init`'s proposal step)
- Sub-feature parent docs (e.g. `password-reset/index.md`) are an
  extra L2-like file — a minor wrinkle; the templates handle it

### Neutral

- The structure is just a directory layout; users can rearrange
  freely, the schema doesn't care about file paths beyond the
  module/feature relationship encoded in frontmatter
