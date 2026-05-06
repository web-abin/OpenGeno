# Comparison

OpenGeno vs the change-driven school. Side-by-side comparison with
two representative tools: GitHub spec-kit and openspec.

## Quick reference matrix

| Dimension | spec-kit | openspec | OpenGeno |
|-----------|----------|----------|----------|
| **Organizing axis** | Per-change | Per-change | **Per-feature** |
| **Spec lifecycle** | Created → implemented → archived | Proposed → reviewed → archived | Mutated forever (no archive) |
| **Source of truth (current state)** | Synthesized by reader | Synthesized by reader | The tree itself |
| **Workflow stages** | `/specify` → `/plan` → `/tasks` → `/implement` | Free-form change proposal | None — read/update is the workflow |
| **Drift detection** | None native | None native | Built-in (`drift-check.sh`) |
| **Token cost per task** | Read all relevant specs (often many) | Read all relevant proposals | Read 1–2 L3 docs |
| **Bootstrap on existing project** | Add change-specs going forward | Add change proposals going forward | One-time scan + `feat-tree/` generation |
| **Languages supported** | English (templates) | English (templates) | English + Chinese (selectable) |
| **Hooks / enforcement** | Slash commands only | CLI commands only | Hooks + skills + injection |
| **Distribution** | `npx` / templates / Claude Code skill | `openspec` CLI | Claude Code plugin |

## Key conceptual differences

### Source of truth

**spec-kit / openspec**: the source of truth is the union of all
historical specs/proposals. To know "what does feature X do today,"
you read all specs that mention X and synthesize.

**OpenGeno**: the source of truth is the L3 doc for X. To know what X
does today, you read X's doc. No synthesis required.

This is the most-important difference. It propagates into everything
else.

### Drift handling

**spec-kit / openspec**: implicit. There's no built-in concept of
drift between an archived spec and current code. Specs are
historical artifacts; they're not expected to "match" current state.

**OpenGeno**: explicit. Every L3 doc carries `last_synced_commit`. The
drift checker computes whether code has moved past the SHA. Drift is
a first-class system state.

### Workflow stages

**spec-kit**: rich four-stage workflow (specify → plan → tasks →
implement). Each stage has a slash command and a structured template.
This is *good for novel features* where the planning needs ceremony.
It's *overhead for changes to existing features*.

**openspec**: lighter than spec-kit but still per-change.

**OpenGeno**: no workflow stages. The "workflow" is just
read-before-change and update-after-change. New features pick a
template and start writing. The shape of the change is captured by
the L3 doc itself, not by ceremony around it.

This is a real philosophical difference, not a feature-set
difference. Spec-kit's value is the ceremony; removing it isn't an
upgrade for users who want it.

### Targeted use case

| User wants to... | Use |
|------------------|-----|
| Plan a major new feature with stakeholder review | spec-kit |
| Capture a change proposal for a regulated/audited team | openspec |
| Maintain understanding of an evolving codebase across many sessions | **OpenGeno** |
| Onboard a new contributor to "what does this app do" | **OpenGeno** |
| Have an audit trail of every change | spec-kit / openspec (via archived specs) or git log on OpenGeno tree |
| Make sure the AI doesn't break invariants when changing existing features | **OpenGeno** |

## Where the four failure modes land

Recall the four failures of change-driven from
[motivation.md](motivation.md):

| Failure | spec-kit | openspec | OpenGeno |
|---------|----------|----------|----------|
| Duplication / conflict | Present | Present | Solved by per-feature uniqueness |
| Discovery cost | Present | Present | Solved by tree structure |
| Merging / archiving | Manual or skipped | Manual or skipped | N/A (no archives) |
| Drift | Silent | Silent | Detected and gated |

We're not claiming OpenGeno is universally better — we're claiming it
solves a set of failures that the change-driven approach doesn't.
The right choice depends on what you value.

## Where OpenGeno is *worse*

Be honest:

- **No native change history.** spec-kit's archived specs are a built-in
  audit trail. OpenGeno's audit trail is `git log feat-tree/`.
  Functionally equivalent for most purposes; not as polished.
- **Heavier bootstrap.** spec-kit starts working when you write your
  first spec. OpenGeno needs an initial pass over the project.
- **Less opinionated about new-feature planning.** If you want
  structured "specify → plan → tasks" stages for major features,
  spec-kit gives that out of the box. OpenGeno gives a feature
  template; everything else is up to you.
- **Younger.** spec-kit and openspec have more eyes on them.

If your project is greenfield, has a small feature count, and benefits
from heavy structure on each change, spec-kit is probably the better
fit. OpenGeno wins on long-lived projects, projects with many features,
and projects where drift is a known pain point.

## Could you use both?

Yes. They operate on different artifacts:

- spec-kit produces specs (per change)
- OpenGeno maintains a tree (current state)

A project could use spec-kit for the ceremony of new feature
planning, then *also* maintain an OpenGeno tree as the
current-state source of truth. The spec is the change; the L3 doc is
the result of the change.

In practice few teams will run both — the overlap is large enough
that one tends to dominate. But the architectures don't conflict.

## Sources of confusion to avoid

Two patterns OpenGeno is *not* but is sometimes confused with:

**Auto-generated docs** (Sphinx, JSDoc, etc.) — those generate docs
*from* the code. OpenGeno's docs are independent of code; they
describe intent, not implementation. The drift detector verifies
they stay related, not that one is derived from the other.

**Wikis** (Notion, Confluence, project README sections) — those are
prose documents that drift silently. OpenGeno is closer to a wiki in
shape than to specs, but with the drift contract added on top. You
could think of it as "a wiki with `git log` integration."
