---
name: geno-init
description: Initialize an OpenGeno feature tree for a project. Asks the user to pick a documentation language (English or Chinese, default English), scans the codebase, proposes a module breakdown, generates the L1 root index, L2 module indexes and L3 feature stubs in the chosen language, writes .feat-tree.json, and injects the OpenGeno workflow rules into CLAUDE.md (and AGENTS.md if present). Use when starting OpenGeno on a new project. Run once per project.
user-invocable: true
allowed-tools: "Read Write Edit Bash Glob Grep AskUserQuestion"
hooks:
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "S=\"\"; for P in \"${CLAUDE_SKILL_DIR:-}/scripts/post-edit-warn.sh\" \"${CLAUDE_PLUGIN_ROOT:-}/skills/geno-init/scripts/post-edit-warn.sh\" \"${CLAUDE_PLUGIN_ROOT:-}/scripts/post-edit-warn.sh\" \"$HOME/.claude/skills/geno-init/scripts/post-edit-warn.sh\" \".claude/skills/geno-init/scripts/post-edit-warn.sh\"; do [ -f \"$P\" ] && S=\"$P\" && break; done; [ -n \"$S\" ] && bash \"$S\" 2>/dev/null || true"
  Stop:
    - hooks:
        - type: command
          command: "S=\"\"; for P in \"${CLAUDE_SKILL_DIR:-}/scripts/stop-check.sh\" \"${CLAUDE_PLUGIN_ROOT:-}/skills/geno-init/scripts/stop-check.sh\" \"${CLAUDE_PLUGIN_ROOT:-}/scripts/stop-check.sh\" \"$HOME/.claude/skills/geno-init/scripts/stop-check.sh\" \".claude/skills/geno-init/scripts/stop-check.sh\"; do [ -f \"$P\" ] && S=\"$P\" && break; done; [ -n \"$S\" ] && bash \"$S\" || true"
metadata:
  version: "0.1.0"
---

# /geno-init

Bootstrap an OpenGeno feature tree for a project. Run **once** per
project. If `feat-tree/` already exists, abort and direct the user to
`/geno-sync` instead.

This skill is the only command needed to set up the tree — and the only
way to introduce the OpenGeno workflow rules into CLAUDE.md / AGENTS.md.

## Pre-flight

```bash
test -d feat-tree && echo "tree exists, abort" || echo "ok to init"
```

If the tree exists, **stop**. Tell the user to use `/geno-sync` for
drift, or to manually add new feature docs from the templates in this
skill's `templates/` directory.

## Workflow

### Step 1 — Pick the documentation language

Use `AskUserQuestion`:

- Question: "Which language should OpenGeno write the feature tree in?"
- Options (English first, marked recommended):
  1. **English** (Recommended)
  2. **中文 (Chinese)**

Store the choice as `LANG = "en"` or `LANG = "zh"`. **Critical**: from
this point on, every file you write under `feat-tree/`, every section
heading, every prose line, every comment, every example value, every
TODO placeholder MUST be in the chosen language. Do not mix languages
within the tree.

If the user picks Chinese, you must write Chinese exclusively for the
rest of this skill's execution. Do not silently fall back to English
even for "small" things like field labels — the user will read every
doc in their chosen language; mixing is jarring.

### Step 2 — Pick the drift mode

Use `AskUserQuestion`, phrased in the chosen language:

- Options:
  1. **Warn** (default): print drift summary at session-end, do not block
  2. **Block**: refuse to end session if drift exists

Store as `DRIFT_MODE`.

### Step 3 — Scan the codebase

Glob for likely feature surfaces. Don't read every file — look at
structure. Useful patterns:

| Stack | Look at |
|-------|---------|
| Flutter | `lib/features/**/`, `lib/pages/**/`, `lib/screens/**/`, route files |
| React/Next.js | `app/**/page.tsx`, `pages/**/*.tsx`, `src/features/**/`, `src/routes/**/` |
| iOS (Swift) | `*ViewController*`, `Scene*`, navigation graph |
| Android | `*Activity*`, `*Fragment*`, navigation graph |
| Backend | route/controller files, top-level service classes |

Identify:

1. **Top-level modules** — major user-facing areas (auth, profile, feed, …)
2. **Sub-features** within each — specific screens, flows, or logic units
3. **Out-of-scope items** — i18n, theming, build tooling, analytics

Keep the scan shallow. The goal is a *proposal*, not a finished tree.

### Step 4 — Propose, in the user's language

Show the user the draft module list with one-line descriptions, **in
the chosen language**. Use `AskUserQuestion` (also in the chosen
language) to ask whether the proposal is acceptable.

Iterate until they accept.

### Step 5 — Generate L1 root index

Pick the right template:

- `LANG=en` → `templates/root-index.md`
- `LANG=zh` → `templates/root-index.zh.md`

Write `feat-tree/index.md` from the template, replacing placeholders:

- `{{PROJECT_NAME}}` — from package.json / pubspec.yaml / go.mod / etc.
- One row per accepted module
- `last_synced_commit:` left empty

All generated prose (module descriptions, etc.) must be in the chosen
language.

### Step 6 — Generate L2 module stubs

For each accepted module, write `feat-tree/<module>/index.md` from
`templates/module-index.md` or `templates/module-index.zh.md`. List the
proposed features as table rows. Module description and any free-form
text in the chosen language.

### Step 7 — Generate L3 feature stubs

For each proposed feature, write a stub L3 doc using:

- UI feature → `templates/feature-ui.md` (en) or `templates/feature-ui.zh.md` (zh)
- Logic feature → `templates/feature-logic.md` (en) or `templates/feature-logic.zh.md` (zh)

The stub keeps:

- Frontmatter filled in (`type`, `kind`, `feature`, `module`,
  `code:` if known from scan, `last_synced_commit: ""`,
  `last_reviewed:` today's date)
- All section headings present (in chosen language)
- Section bodies set to placeholder text in chosen language
  - English: `TODO`
  - Chinese: `待补充`

**Do not** auto-fill L3 details from code-reading. That's expensive,
hallucination-prone, and produces unreviewed docs. L3 details get filled
in incrementally on the first real task that touches each feature
(driven by the workflow rules in CLAUDE.md, not by this skill).

### Step 8 — Write `.feat-tree.json`

Copy `templates/feat-tree.json` to project root, then patch
`drift_mode` to the chosen value:

```json
{
  "version": 1,
  "tree_path": "feat-tree",
  "drift_mode": "warn"
}
```

This file controls hook behavior — `drift_mode` is read by the Stop
hook at session-end.

### Step 9 — Inject workflow rules into CLAUDE.md / AGENTS.md

Read the corresponding injection template:

- `LANG=en` → `templates/claude-md-injection.md`
- `LANG=zh` → `templates/claude-md-injection.zh.md`

Then for each of `CLAUDE.md` and `AGENTS.md` that already exists at
project root: **append** the injection text. Don't overwrite existing
content. Don't insert above existing content.

If neither file exists at project root, create `CLAUDE.md` with just
the injection text (`AGENTS.md` only created if it already exists).

The injection block is wrapped in `<!-- BEGIN OpenGeno -->` /
`<!-- END OpenGeno -->` markers so future re-runs or removals can
target it precisely.

If a `BEGIN OpenGeno` marker already exists in the target file, abort
the injection for that file (it was already injected) and warn the
user.

### Step 10 — Report

Print a summary in the chosen language:

- Documentation language chosen
- Drift mode chosen
- Number of modules created
- Number of L3 stubs created
- Whether `CLAUDE.md` / `AGENTS.md` was created or appended
- Suggested next step: "Fill in L3 details on demand as you work — the
  first task that touches each feature should expand its stub."

## Language enforcement (read this twice)

The user picked a language; they expect the tree to be in that language
end-to-end.

- All headings: chosen language
- All prose, table cells, descriptions: chosen language
- All examples and placeholder text: chosen language
- Code paths, slugs, frontmatter keys: stay as-is (they're identifiers,
  not language)
- File names: kebab-case English slugs even in Chinese projects
  (file-system-friendly, AI-stable)

If you find yourself about to write English in a Chinese tree because
"it's just a placeholder" or "the term is hard to translate" — stop
and translate. The user will notice; they will be annoyed.

The injection text in CLAUDE.md / AGENTS.md tells the AI on **future**
sessions to keep writing in the chosen language. Get it right on this
first pass and the rule perpetuates.

## Anti-patterns

| Don't | Why |
|-------|-----|
| Mix languages within the tree | Defeats the language-selection contract; will be visibly wrong |
| Auto-fill all L3 docs from code | Expensive, hallucination-prone, produces unreviewed docs |
| Silently merge with an existing tree | Risks overwriting hand-written content |
| Use the AI's first-pass module guess without user review | Module boundaries are a project-specific judgment call |
| Treat infra items (i18n, theme tokens, etc.) as features | Pollutes the tree, dilutes the signal |
| Set `last_synced_commit` to current HEAD on a stub | Misleading — stubs aren't synced |
| Forget to inject rules into CLAUDE.md / AGENTS.md | Without these, future sessions have no instruction to follow the workflow |
