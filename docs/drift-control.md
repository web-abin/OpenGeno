# Drift control

The single most important property of OpenGeno is that **the doc and
the code stay in sync over time**. Everything else (format, tree
structure, language strategy) is downstream of this.

If drift goes silent, the docs become a liability — they look
authoritative, they get read, they make wrong decisions confident.
The whole system is then worse than no docs at all.

So drift control is treated as a hard component, with two layers.

## Two-layer architecture

| Layer | Mechanism | Mode |
|-------|-----------|------|
| Layer 1 | Hooks (PostToolUse + Stop) | Automatic, non-interactive |
| Layer 2 | `/geno-sync` skill | On-demand, interactive |

These are not redundant — they handle different failure modes.

### Layer 1 — Hooks

Hooks run automatically. The user doesn't invoke them. They're the
**enforcement layer**.

**`PostToolUse` on `Write|Edit`** — runs `post-edit-warn.sh`:
- Fires after every code edit
- Greps L3 docs for the edited file path in their `code:` lists
- If the file is referenced by an L3 doc, prints a soft reminder:
  *"You edited X. It's referenced by Y.md. If your edit changed
  user-visible behavior, update the doc."*
- Never blocks. Always exits 0.

**`Stop`** — runs `stop-check.sh`:
- Fires when the session is about to end
- Runs `drift-check.sh` over the whole tree
- If no drift: exits 0 silently
- If drift detected:
  - In `warn` mode: prints summary, exits 0 (session ends)
  - In `block` mode: prints summary, exits 1 (session blocked from
    ending until drift resolved)

**Why hooks specifically:**

Without hooks, drift gating depends on the AI remembering to check.
The AI sometimes forgets — under context pressure, mid-long-session,
or because the user asked it to do something unrelated. Hooks turn
"the AI should run drift-check" into "drift-check runs, period."

### Layer 2 — `/geno-sync`

`/geno-sync` is the interactive complement. The user invokes it
explicitly when they suspect drift or want a periodic audit.

It does what `drift-check.sh` does, **plus**:

- Categorizes results into red / yellow / gray / broken / stale
- Presents a structured human-readable report
- Asks the user what to reconcile
- Walks reds together with the user, reading diffs, editing docs,
  bumping SHAs

The hook layer is non-interactive: it can detect, it can warn, it can
block. It can't fix. `/geno-sync` is what fixes.

## Why two layers, not one

You could imagine designs that collapse to one layer:

**Hooks-only**: drift detection runs automatically, but there's no
interactive reconciliation. The user gets warnings forever and never
catches up. Drift accumulates as a permanent state. Useless after
the first 5 unfixed drifts.

**Skill-only**: drift detection only runs when invoked. The user
forgets to invoke it. Drift accumulates silently between invocations.
Same end state as no system at all.

**Two-layer**: hooks catch drift the moment it appears (or shortly
after, at session-end). Skill provides the path back to clean state.
Hooks pressure users to use the skill regularly.

This is why both layers are necessary.

## Drift detection contract

A doc is considered **in drift** if:

1. Any file in `code:` has been modified since `last_synced_commit`, AND
2. The modification was not classified as a non-behavior change

The detector runs `git log <SHA>..HEAD -- <code-path>` for each code
path. If output is non-empty, the doc is at least a *candidate* for
drift. The detector reports candidates; humans/AI confirm whether
each is actual drift or noise (refactor, formatting, etc.).

### Five status categories

The drift checker emits one of:

- `DRIFT <doc> <code> <count>` — code modified since SHA, may need
  doc update
- `STUB <doc>` — `last_synced_commit` is empty (never synced)
- `BROKEN <doc> <code>` — referenced code file no longer exists
- `STALE_SHA <doc> <sha>` — recorded SHA isn't in current git history
  (likely after a force-push or rebase)
- (no line) — in sync

`/geno-sync` further splits `DRIFT` into red (likely drift) and yellow
(suspicious but possibly benign) using heuristics on commit messages
and diff size. The hook layer doesn't make this distinction — it
treats any DRIFT as a flag.

## Why `last_synced_commit` is the right anchor

Alternatives considered:

- **Time-based** (`last_synced_at: 2026-05-06`): doesn't tell you
  whether code changed; only how long since the last review. Pressure
  to bump just because time passed.
- **File-hash-based** (hash of each `code:` file at sync time): more
  precise but doesn't show *what* changed (just that something did).
  No native git integration. Renames break it.
- **Diff-stored** (store the diff at sync time and replay): too much
  state, too brittle.

Commit-based wins because:

- Native git integration (`git log <SHA>..HEAD`)
- Survives renames if `git log --follow` is used (the checker doesn't
  yet, but could)
- Tells you exactly which commits to look at when reconciling
- One field per doc, low storage overhead

## What the hook layer can't do

Be honest: hooks have failure modes.

- **Hooks don't fire if Claude Code isn't running.** If a developer
  edits in their IDE without an active Claude session, no PostToolUse
  fires. Drift goes undetected until the next Stop in a Claude
  session, *or* the next `/geno-sync`.
- **Hooks fire late.** PostToolUse runs *after* the edit, not before.
  The user can't be prevented from editing; they can only be warned.
- **Hooks can be disabled.** A user with `drift_mode: warn` who
  ignores warnings is not blocked. Block mode helps; honesty about
  this design choice is in
  [decisions/0003](decisions/0003-hooks-as-enforcement-layer.md).
- **Hooks rely on env vars** (`CLAUDE_SKILL_DIR`,
  `CLAUDE_PLUGIN_ROOT`) which may not be set in all installation
  modes. The wrapper scripts have fallback path resolution but it's
  not bulletproof.

The mitigation is: `/geno-sync` is always available as a manual
audit. Run it weekly on active projects.

## What we gave up to make this work

- **Speed.** Drift-check runs over every L3 doc on every Stop. For a
  project with 200 features, that's a non-trivial number of `git log`
  calls. Currently acceptable; if it becomes a problem we'll add
  caching or incremental detection.
- **Cross-language code references.** The `code:` field is plain
  paths. We don't try to track function-level granularity, identifier
  references, or symbol-level changes. A whole-file change is the
  unit of drift detection.

These are conscious trade-offs. The system is built to make drift
*detectable*, not perfectly so — perfect detection would require
tooling complexity that exceeds what a markdown-based system should
have.
