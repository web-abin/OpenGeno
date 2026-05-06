# OpenGeno

> Project-wide living documentation for AI-assisted codebases.
> One source of truth per feature — not per change.

[简体中文](README.ZH.md)

## Why

Spec-driven workflows like [openspec](https://github.com/Fission-AI/OpenSpec)
and [GitHub spec-kit](https://github.com/github/spec-kit) organize work
**around changes**: each requirement gets its own spec / change proposal
that gets reviewed, implemented, and archived. That works well at the
moment of change, but accumulates four problems over time:

1. **Duplication and conflict.** Multiple change-specs that touch the
   same feature each describe it from a different angle. Reading them
   later is a triangulation problem.
2. **Discovery.** Before changing feature *X*, you have to know whether
   any prior spec mentioned *X*, and where.
3. **Merging and archiving.** When several change-specs cover the same
   feature, who consolidates them, and into what?
4. **Drift.** When code is edited outside the spec workflow (manual
   edits, "vibe coding"), the change-specs go stale silently.

OpenGeno picks a different axis. Instead of one doc per *change*, it
maintains **one doc per user-visible feature**, organized as a hierarchical
tree at the project root. The tree is the current state of the project,
not its change history. Changes mutate the tree; they don't accumulate
beside it.

## How it works

The project grows a `feat-tree/` directory:

```
feat-tree/
├── index.md                # L1 — list of modules (~500 tokens)
├── auth/
│   ├── index.md            # L2 — sub-features of auth
│   ├── sign-in.md          # L3 — full spec for one feature
│   └── sign-up.md
├── tasks/
│   └── ...
└── lists/
    └── ...
```

Three tiers, lazy-loaded:

- **L1** — always read (small).
- **L2** — read when a task touches that module.
- **L3** — read when a task touches that feature.

A typical task reads 1–2 L3 docs, costing well under 5k tokens.

Each L3 doc carries:

- A wireframe (for UI features) or trigger / I/O block (for logic)
- Layout, interactions, logic, state, animation, edge cases
- A `code:` frontmatter list of associated source paths
- A `last_synced_commit` SHA — the contract that the doc and code agreed
  at that commit

When code referenced by a doc changes after that SHA, the
[drift checker](skills/geno-init/scripts/drift-check.sh) flags the doc
for re-verification.

## Two skills, two commands

OpenGeno only adds two slash commands. Everything else — read-before-change,
update-after-change, add-new-feature — happens automatically because
`/geno-init` injects the workflow rules into your `CLAUDE.md` (and
`AGENTS.md` if present), and the hooks installed by the skill enforce
them.

| Command | When |
|---------|------|
| [`/geno-init`](skills/geno-init/SKILL.md) | One-time project setup. Asks for documentation language (English / 中文), drift mode, and generation mode (stub-only by default, or one-shot full docs); scans the codebase, proposes modules, generates L1 + L2 + L3, writes `.feat-tree.json`, injects workflow rules into `CLAUDE.md`. |
| [`/geno-sync`](skills/geno-sync/SKILL.md) | On-demand drift check & reconciliation. Walks the tree, reports drift since last sync, walks you through fixing it. |

## Continuous behavior (no command needed)

After `/geno-init` runs, your `CLAUDE.md` carries the workflow contract.
On every subsequent session, the AI:

- **Before changing feature behavior** — reads the relevant L3 doc by
  walking L1 → L2 → L3.
- **After changing feature behavior** — updates the L3 doc and bumps
  `last_synced_commit` in the same session.
- **When adding a new feature** — creates its L3 doc from the bundled
  templates (in the chosen language), updates the L2 module index,
  cross-links from any feature that reaches it.

Two Claude Code hooks back this up:

- **`PostToolUse` on Edit/Write** — soft reminder when you edit a file
  that's referenced by an L3 doc.
- **`Stop`** — runs the drift checker at session-end. In `warn` mode it
  prints a summary; in `block` mode it refuses to end the session while
  drift exists.

Mode is per-project, set in `.feat-tree.json` (`drift_mode: "warn"` or
`"block"`). Default `warn`.

## Documentation language

`/geno-init` asks once: English or 中文. Whatever you pick, **the entire
tree** is generated in that language — headings, prose, placeholders,
the workflow rules injected into CLAUDE.md, and any future docs created
or edited under the workflow.

The injection in CLAUDE.md instructs the AI to keep writing in the
chosen language on subsequent sessions. So the language choice
perpetuates without you having to repeat yourself.

## What does NOT belong in the tree

- i18n / translations
- Analytics / telemetry
- Build tooling, CI/CD
- Error reporting (Sentry, Crashlytics, etc.)
- Logging
- Pure utility helpers
- Theme primitives (color tokens, typography scales)

These are infrastructure, not features. They belong in CLAUDE.md / ADRs /
code comments, not in the tree.

## What changes trigger a doc update?

| Type of change | Update doc? |
|----------------|-------------|
| Add / remove user-visible behavior | **Required** |
| Change interaction flow, layout, animation | **Required** |
| Change business logic branches | **Required** |
| Add / remove cross-module dependency | **Required (both sides)** |
| Bug fix where new code matches existing doc | No |
| Bug fix where behavior changed (even toward "right" answer) | **Required** |
| Refactor / rename — same behavior | No |
| Performance optimization — same behavior | No |
| i18n / copy / theme tweaks | No |

Rule of thumb: would a user notice? If yes → update.

## Install

OpenGeno is a Claude Code plugin (`.claude-plugin/plugin.json` at repo root,
skills under `skills/`).

### Option A — `skills` CLI (recommended)

```bash
npx skills add web-abin/OpenGeno
```

### Option B — Plugin install

```bash
git clone https://github.com/web-abin/OpenGeno ~/.claude/plugins/marketplaces/opengeno
```

Claude Code auto-loads any plugin under `~/.claude/plugins/marketplaces/`.

### Option C — Global skills install

Copy the two skill folders into your global skills dir:

```bash
mkdir -p ~/.claude/skills
cp -r /path/to/OpenGeno/skills/geno-init ~/.claude/skills/
cp -r /path/to/OpenGeno/skills/geno-sync ~/.claude/skills/
```

### Option D — Project-local skills install

Copy into a single project only:

```bash
cd /path/to/your-project
mkdir -p .claude/skills
cp -r /path/to/OpenGeno/skills/geno-init .claude/skills/
cp -r /path/to/OpenGeno/skills/geno-sync .claude/skills/
```

After any of the above, run `/geno-init` in Claude Code on your project.

## Compatibility

OpenGeno is built for **Claude Code** and uses its hooks system for
drift gating. The methodology and document format work in any AI agent
(Cursor, Copilot, etc.) that can read markdown — but only Claude Code
gets the automatic drift detection. Other agents can run
`/geno-sync` manually as a check-up.

## Design documentation

If you want to understand *why* OpenGeno is shaped this way (rather
than just how to use it), see [`docs/`](docs/) — design rationale,
architecture, and ADRs for each non-obvious choice.

## Status

Active development. Format version `schema: 1`. v1.0 stable API targeted —
breaking schema changes will ship with a migration via `/geno-sync`.

## License

MIT — see [LICENSE](LICENSE).
