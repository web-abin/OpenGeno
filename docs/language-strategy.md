# Language strategy

OpenGeno's host project gets a **monolingual** feature tree —
either fully English or fully Chinese, picked once at init time.

This document explains why "monolingual, init-time choice, propagated
via CLAUDE.md" is the design, and why the alternatives lose.

## The contract

When the user runs `/geno-init`:

1. They're asked: English or 中文?
2. The choice (call it `LANG`) determines:
   - Which template variants get used (`*.md` vs `*.zh.md`)
   - Which `claude-md-injection.{md,zh.md}` text gets appended to
     `CLAUDE.md`
   - Every section heading, every prose line, every TODO placeholder
     in the generated tree

After init, the choice **perpetuates** because:

- The injection text in `CLAUDE.md` instructs the AI to keep writing
  in `LANG` on subsequent sessions
- `/geno-sync` auto-detects `LANG` from the existing tree's content
  before reporting

The user picks once; the AI maintains the choice forever.

## Why init-time, not per-session

Alternative considered: ask the user "which language?" at the start
of every session.

Why we don't:

- **Friction.** Most users want consistency, not choice every
  session. Asking every time is a tax.
- **Mid-tree language drift.** If the user picks Chinese in session
  one and English in session two, the tree ends up bilingual in
  unpredictable ways. A doc updated in session two is English; the
  module index it lives under is Chinese; the cross-link target is
  English again. Unreadable.
- **Cross-session consistency is more valuable than flexibility.**
  Being able to switch languages at will is a niche use case (mostly
  "I made a mistake, want to redo"). Init-time choice with manual
  override (re-run init? edit the injection text?) covers it.

## Why monolingual, not bilingual

Alternative considered: every doc has both English and Chinese
sections, like the bilingual READMEs.

Why we don't:

- **Maintenance cost doubles.** Every behavioral change requires
  updating two language versions. The drift surface doubles. The
  AI's update-after-change time doubles.
- **One side rots.** Bilingual repos in practice have one
  authoritative language and one partially-translated version that
  drifts. The "second" language becomes a lie.
- **Cross-feature cognition is worse.** Reading a feature requires
  picking a side. AI reading two features that picked different
  sides has to switch languages mid-task.
- **No marginal value over picking one.** Monolingual covers each
  individual user. Bilingual covers the case "two users on the same
  project want different languages" — rare in practice, and they can
  agree on one.

## Why separate template files, not single template with translation

Alternative considered: one set of templates with `{{HEADING}}`
placeholders that get translated based on `LANG`.

Why we don't:

- **Different languages have different idioms.** A literal translation
  of an English template heading often reads awkwardly in Chinese, and
  vice versa. ("Cross-feature links" → "跨功能链路" works; "Edge cases"
  → "边界情况" works; but more nuanced section names need rephrasing,
  not translation.)
- **Examples and inline guidance need to be in-language.** The
  template comments (`<!-- describe layout top-to-bottom -->`)
  guide the AI. If those are in English in a Chinese template, the
  AI's output gets contaminated.
- **Per-language file is simpler to read and maintain.** When we
  refine the Chinese wording, we edit one file directly. With
  placeholder substitution, we'd be editing translation tables and
  template files separately.

## Why CLAUDE.md as the propagation mechanism

The injection text in CLAUDE.md is what makes the language choice
*stick* across sessions. Specifically, the rules text contains:

> **Documentation language: Chinese / English.** When you create or
> update any file under `feat-tree/`, write all prose, headings,
> comments, and frontmatter values in [language]. Do not mix
> languages within the tree.

The AI reads CLAUDE.md every session. The rule is at the top of the
OpenGeno block. Future sessions read it, comply with it, and the tree
stays consistent.

This is the same mechanism by which the *workflow* rules
(read-before, update-after) propagate. Language is just one more
rule riding the same channel.

See [decisions/0007](decisions/0007-claude-md-as-rule-carrier.md) for
the broader argument about CLAUDE.md as a rule carrier.

## Why slugs and identifiers stay English

Even in a Chinese tree:

- File names are `kebab-case` English (`sign-in.md`, not `登录.md`)
- Frontmatter keys are English (`feature:`, not `功能:`)
- Module slugs are English (`auth/`, not `认证/`)
- The directory `feat-tree/` is English

Identifiers are not language. They're keys. Reasons:

- **Cross-platform file system reliability** — non-ASCII paths cause
  issues on Windows, in some CI systems, in some git tooling
- **AI stability** — agents handle ASCII paths more reliably than
  non-ASCII
- **Cross-team accessibility** — even in a Chinese-language project,
  contributors with English-only setups (developer tools, IDE config)
  can read paths

Only *content* (prose, headings, table cells, comments) is in the
chosen language.

## Detection at sync time

`/geno-sync` doesn't ask the user for language; it auto-detects from
the existing tree. The detection logic, in priority order:

1. `.feat-tree.json` `language` field (added by future versions; not
   currently set by `/geno-init` — TODO)
2. `CLAUDE.md` between `<!-- BEGIN OpenGeno -->` markers — look for
   the string "文档语言：中文" or "Doc language: English"
3. `feat-tree/index.md` content — heuristic on whether prose is
   Chinese or English

Once detected, `/geno-sync`'s entire output uses that language.
Reconciliation prompts, drift summaries, and any new doc content
written during reconciliation all match.

## What about partial language switches

The user re-runs `/geno-init` with a different language. What happens?

Currently: `/geno-init` aborts if `feat-tree/` exists. So the only
way to switch is to delete the tree and re-init, which re-generates
stubs in the new language.

This is intentional. Mid-life language switches are an explicit,
deliberate operation. We don't smooth the path because we don't
want users wandering into bilingual chaos by accident.

If a user genuinely wants to translate, the operation is:

1. Manually edit each L3 doc (or have AI translate them in-place,
   keeping the tree consistent)
2. Edit the OpenGeno block in `CLAUDE.md` to swap the injection text
3. Done

We don't provide a `/geno-translate` skill because the demand is
unclear and the implementation is non-trivial (preserving frontmatter,
maintaining cross-links, handling section structure). Could be a
future addition (see [extensibility.md](extensibility.md)).
