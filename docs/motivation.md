# Motivation

OpenGeno exists because the dominant pattern for AI-assisted
documentation — **change-driven specs** — fails at the time scale
projects actually live in.

## What the change-driven school looks like

Tools like [GitHub spec-kit](https://github.com/github/spec-kit) and
[openspec](https://github.com/Fission-AI/OpenSpec) organize work
**around changes**:

1. A new requirement enters the system.
2. A spec / change proposal is written for that requirement.
3. The AI implements against the spec.
4. The change is shipped; the spec is archived.

This is good *at the moment of change*. The user gets a structured
artifact to review, the AI gets a clear target to hit, and there's a
paper trail.

The problem is what happens to the specs **afterward**.

## Four failure modes

### 1. Duplication and conflict

Six months in, the auth flow has been touched by 11 change-specs:
"add OAuth", "fix password reset bug", "add MFA", "deprecate username
login", and so on. Each describes the auth flow from its own angle, at
its own moment. None describes "what auth currently does." Reading
them later is a triangulation problem — you have to merge 11
viewpoints in your head to know the present state.

Real specs also routinely contradict each other. The "add MFA" spec
assumed username login still existed; the "deprecate username login"
spec didn't update it. Now both specs are in the archive.

### 2. Discovery cost

You're about to change the password-reset flow. Before you start, you
need to know: has any prior spec touched this? If yes, where? If you
miss one, you'll either redo work or break invariants the prior spec
established.

`grep -r "password reset" specs/` is a real workflow people resort to.
That's a tell.

### 3. Merging and archiving

When you eventually do consolidate three specs about the same feature
into a clean view, who's responsible? Into what artifact? Most
projects don't consolidate. The specs accumulate forever or get bulk
deleted, neither of which serves future readers.

### 4. Drift

The killer.

Change-specs assume *all changes go through the change workflow*. In
reality, code changes happen via:

- Manual edits when an engineer notices a typo
- "Vibe coding" sessions where the AI is asked to fix something quickly
- Merges from feature branches that didn't go through the spec process
- Dependency upgrades that bump a behavior subtly

When any of these happen, the spec is silently wrong. Worse: the spec
*looks* authoritative because nobody noticed it drifted. The next AI
session reads the stale spec, takes its claims as ground truth, and
makes confident decisions based on outdated information.

## The shift

OpenGeno picks a different organizing axis: **per-feature, not
per-change**.

The tree is the *current state* of the project, not its change
history. There is exactly one document per user-visible feature.
Changes mutate that document; they don't accumulate beside it.

This solves the four failures by inversion:

| Change-driven failure | Per-feature inversion |
|----------------------|----------------------|
| Duplication / conflict | One doc per feature → no triangulation |
| Discovery cost | Tree structure is browseable; doc location is predictable |
| Merging / archiving | Nothing to merge; mutations happen in place |
| Drift | Doc and code share `last_synced_commit`; drift is detectable |

## What we give up

This isn't free. Two trade-offs to be honest about:

**1. No change history out of the box.** A change-driven system gives
you "here's everything that touched feature X" for free — it's the
shape of the data. OpenGeno's tree is current-state-only. To recover
change history, you fall back to `git log feat-tree/<feature>.md`.
For most use cases that's enough; for compliance-heavy contexts where
you need a per-change audit, the change-driven model is still right.

**2. Bootstrap cost on existing projects.** A change-driven system
starts working as soon as you write your first change-spec. OpenGeno
needs an initial pass over the project to identify modules and stub
out features. `/geno-init` automates the proposal step but the user
still has to review.

## What this implies for design

The rest of the design follows from the per-feature commitment:

- **Hierarchical tree** instead of flat — because feature counts at
  scale exceed flat-readability (see [architecture.md](architecture.md))
- **Lazy three-tier loading** — because per-task token budget matters
  (see [decisions/0004](decisions/0004-three-tier-lazy-loading.md))
- **Bidirectional code-doc linking** — because drift only becomes
  detectable when the doc knows which files it owns (see
  [decisions/0005](decisions/0005-bidirectional-code-doc-link.md))
- **Workflow rules in CLAUDE.md, not in skills** — because the
  workflow is continuous behavior, not on-demand invocation (see
  [decisions/0007](decisions/0007-claude-md-as-rule-carrier.md))
- **Drift detection as a hard component** — because if drift goes
  silent, the whole system loses trust

See [comparison.md](comparison.md) for a side-by-side with spec-kit and
openspec.
