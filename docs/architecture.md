# Architecture

OpenGeno is composed of four moving parts. None of them is sufficient
on its own; the design is in how they compose.

## The four parts

```
┌────────────────────────────────────────────────────────────────┐
│  OpenGeno plugin (this repo)                                    │
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐                        │
│  │   /geno-init   │    │   /geno-sync   │   ◄── (1) Skills       │
│  │   (one-shot)   │    │   (on-demand)  │       (commands)       │
│  └────────┬───────┘    └────────┬───────┘                        │
│           │                     │                                 │
│  ┌────────▼─────────────────────▼─────────┐                      │
│  │  scripts/                                │                     │
│  │   - drift-check.sh                       │                     │
│  │   - stop-check.sh                        │  ◄── (2) Hooks      │
│  │   - post-edit-warn.sh                    │      (auto-fire)    │
│  └──────────────────────────────────────────┘                    │
│                                                                  │
│  ┌────────────────────────────────────────┐                      │
│  │  templates/                              │                     │
│  │   - root-index.{md,zh.md}                │                     │
│  │   - module-index.{md,zh.md}              │  ◄── (3) Templates  │
│  │   - feature-{ui,logic}.{md,zh.md}        │      (generation)   │
│  │   - claude-md-injection.{md,zh.md}       │                     │
│  └────────────────────────────────────────┘                      │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼ /geno-init writes
                  ┌───────────────────────────┐
                  │  Host project root        │
                  │  ─ feat-tree/             │
                  │  ─ .feat-tree.json        │
                  │  ─ CLAUDE.md (injected)   │  ◄── (4) Per-project
                  │                           │      runtime state
                  └───────────────────────────┘
```

### (1) Skills — explicit commands

Two slash commands, both user-invocable:

- **`/geno-init`** — one-shot bootstrap. Asks for language, drift mode,
  and generation mode (stub-only by default, or one-shot full docs);
  scans, proposes, generates the tree, writes `.feat-tree.json`,
  injects rules into `CLAUDE.md`.
- **`/geno-sync`** — on-demand drift reconciliation. Walks the tree,
  reports drift, walks the user through fixes interactively.

Skills exist because some operations are intentional acts the user
schedules ("init this project", "audit drift now"). They're the wrong
shape for continuous behavior.

### (2) Hooks — automatic enforcement

Two hooks, defined in `geno-init/SKILL.md` frontmatter so they activate
when the skill is loaded:

- **`PostToolUse`** on `Write|Edit` → runs `post-edit-warn.sh`
  - Fires after any code edit
  - Checks if the edited file is referenced by an L3 doc
  - If yes, prints a soft reminder
  - Never blocks
- **`Stop`** → runs `stop-check.sh`
  - Fires at session end
  - Runs the full drift checker
  - In `warn` mode (default): prints a summary, exits 0
  - In `block` mode: exits non-zero, refusing to end session until
    drift is resolved

Hooks exist because **you can't trust the AI to remember on its own**
to update docs when it changes behavior. The hook is what makes drift
gating real instead of aspirational.

### (3) Templates — content generation

Templates serve two audiences:

- **The AI**, when it generates new docs (root index, module index,
  feature docs). Templates fix the section structure so all docs in a
  tree look alike.
- **`/geno-init`**, which copies the right template based on the
  user's language choice and the feature kind (UI vs logic).

Each template exists in two language variants (`*.md` for English,
`*.zh.md` for Chinese). The user picks once at init time;
`/geno-init` and the AI always pull from the matching set thereafter.

A special template — `claude-md-injection.md` / `.zh.md` — is the
*workflow rules text* that gets appended to the host project's
`CLAUDE.md`. This is how the workflow propagates across sessions.

### (4) Per-project runtime state

After init, the host project carries:

- `feat-tree/` — the tree itself
- `.feat-tree.json` — config (`drift_mode`, `tree_path`)
- `CLAUDE.md` — appended with workflow rules in the chosen language

These three files are how OpenGeno persists its presence in the host
project. The skills and hooks read this state on every invocation;
the AI (on every session) reads the `CLAUDE.md` rules and follows the
workflow.

## How they compose — the four flows

### Flow A: Init

```
User: /geno-init
  ├─► geno-init asks language (en/zh)
  ├─► geno-init asks drift mode (warn/block)
  ├─► geno-init asks generation mode (stub/full)
  ├─► geno-init scans codebase (depth depends on mode)
  ├─► geno-init proposes modules
  ├─► User reviews
  ├─► geno-init writes feat-tree/index.md from template
  ├─► geno-init writes feat-tree/<module>/index.md per module
  ├─► geno-init writes feat-tree/<module>/<feature>.md per feature
  │    ├─► stub mode: section bodies are TODO / 待补充 placeholders
  │    └─► full mode: best-effort prose from a deeper code read,
  │                   last_synced_commit still empty (unverified)
  ├─► geno-init writes .feat-tree.json
  └─► geno-init appends claude-md-injection.{md,zh.md} to CLAUDE.md
```

### Flow B: Normal feature change (no command needed)

```
User: change feature X
  ├─► AI reads CLAUDE.md (it has the rules from injection)
  ├─► AI reads feat-tree/index.md (L1)
  ├─► AI reads feat-tree/<module>/index.md (L2)
  ├─► AI reads feat-tree/<module>/<X>.md (L3) — the spec
  ├─► AI edits code
  │    └─► PostToolUse hook fires after each Edit, prints reminder
  ├─► AI updates feat-tree/<module>/<X>.md to reflect new behavior
  ├─► AI bumps last_synced_commit to current HEAD
  └─► Stop hook fires at session end
       └─► drift-check.sh confirms no drift, exits 0 silently
```

The AI's behavior in this flow is **not** scripted by a skill. It's
guided entirely by the rules in CLAUDE.md (which `/geno-init` put
there). The hooks are the safety net.

### Flow C: Drift discovered out of band

```
User runs vibe-coding session, manually edits code, forgets workflow
  ├─► Stop hook fires at session end
  │    └─► drift-check.sh detects file modified since last_synced_commit
  │         ├─► warn mode: prints summary, exits 0 (session ends)
  │         └─► block mode: exits 1 (session blocked)

(Later)
User: /geno-sync
  ├─► geno-sync auto-detects tree language from CLAUDE.md
  ├─► geno-sync runs drift-check.sh
  ├─► geno-sync presents structured report (red/yellow/gray/broken/stale)
  ├─► geno-sync asks user what to reconcile
  ├─► User and AI walk reds together
  ├─► AI reads each diff, updates each doc, bumps SHAs
  └─► Final report
```

### Flow D: Adding a brand-new feature

```
User: implement feature Y (new)
  ├─► AI reads CLAUDE.md → sees "Add a new feature" section
  ├─► AI picks the right template (feature-ui.md / .zh.md based on tree)
  ├─► AI creates feat-tree/<module>/<Y>.md with real content
  ├─► AI updates feat-tree/<module>/index.md (adds row)
  ├─► AI cross-links from any feature that reaches Y
  ├─► AI implements code
  ├─► AI bumps last_synced_commit on Y's doc
  └─► Hooks fire as in Flow B
```

The AI uses the templates directly (reads them from the installed
skill location, e.g.
`~/.claude/skills/geno-init/templates/feature-ui.md`). No skill
invocation needed for "add a feature" — that's why there's no
`/geno-add` command.

## Why this composition

You could imagine alternative architectures:

- **Just hooks** — but hooks can't ask the user what they want at init
  time, can't propose modules interactively. No skills means no
  bootstrap UX.
- **Just skills** — but skills are commands; they need to be invoked.
  Without hooks, drift goes silent the moment the user forgets to run
  `/geno-sync`.
- **Just CLAUDE.md** — but rules in CLAUDE.md are soft. The AI
  sometimes "forgets," especially across long sessions or under
  context pressure. Without hooks, the system depends on the AI's
  memory.
- **Five separate skills** (init/find/add/update/sync) — original
  design. Simplified because find/add/update are continuous behaviors,
  not user-scheduled events. Putting them in CLAUDE.md (so the AI
  follows them on every session) is the right shape. See
  [decisions/0001](decisions/0001-two-skills-not-five.md).

The composition we landed on:

- **Skills** carry the *intentional* acts (init, sync)
- **Hooks** carry the *automatic enforcement* (drift gating)
- **Templates** carry the *content shape*
- **CLAUDE.md injection** carries the *continuous behavior rules*

Each part does what it's best at. Removing any one breaks the whole.

## Per-project files vs plugin files

Be careful not to conflate:

| In the OpenGeno repo | In a host project using OpenGeno |
|----------------------|----------------------------------|
| `skills/geno-init/` | (none — comes from plugin install) |
| `skills/geno-init/templates/` | (referenced via `${CLAUDE_SKILL_DIR}`) |
| `examples/todo-app/feat-tree/` (a demo) | `feat-tree/` (the real tree) |
| `docs/` (you're reading this) | (none) |

The host project never gets `skills/`, `templates/`, or `docs/` from
OpenGeno. It gets `feat-tree/`, `.feat-tree.json`, and an appended
section in its `CLAUDE.md`. That's it.
