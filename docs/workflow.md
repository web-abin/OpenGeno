# Workflow

The workflow is the *contract* between the AI and OpenGeno. Three
rules, plus a change-classification table.

The full text — written in either English or Chinese based on the
project's language choice — lives in
[`templates/claude-md-injection.md`](../skills/geno-init/templates/claude-md-injection.md)
and is appended to the host project's `CLAUDE.md` by `/geno-init`.

This document explains the **rationale** for the rules. The rules
themselves are in the injection template.

## Rule 1 — Read before changing

Before changing user-visible behavior of an existing feature:

1. Read `feat-tree/index.md` (L1)
2. Narrow to the relevant module via L2
3. Read the L3 doc for the feature
4. *Then* edit code

**Why this order:**

- The doc is the spec. Changing code without reading the spec means
  you're operating on an outdated mental model of intent.
- Cross-links in the doc tell you what *else* depends on this
  feature. Without that, you risk silent breakage upstream.
- The doc's `last_synced_commit` tells you whether to trust it; a
  badly-stale doc is a signal to run `/geno-sync` first rather than
  proceed against it.

**Why we read code only after the doc:**

The doc tells you *what* and *why*. Code tells you *how*. To change
behavior intelligently you need both, but the *what/why* must come
first or your edits won't be informed by intent.

## Rule 2 — Update after changing

In the same session as the code change, update the L3 doc.

**Why same-session:**

Doc updates that are deferred almost never happen. "I'll update the
doc later" is the universal lie of documentation systems. Same-session
is non-negotiable because:

- The change is fresh in the AI's context — accurate description is
  cheap *now*, expensive in the next session
- The hooks fire at session-end; deferring means triggering drift on
  every Stop
- Future sessions will read the now-stale doc and make wrong
  decisions

**Why bumping `last_synced_commit` requires verification:**

The single failure mode that destroys this entire system is **bumping
the SHA without actually verifying**. If the AI bumps SHAs based on
"I think I updated everything," the drift check stops being trustworthy.
Future readers will trust SHAs that don't reflect reality.

The rule: only bump if you actually re-read the touched code in this
session. Spot-checks aren't enough. If you only updated three
sections out of six, leave the SHA stale and let `/geno-sync` flag it
again. A stale SHA is recoverable; a falsely-fresh SHA is poison.

## Rule 3 — Cross-link maintenance

If a change adds or removes an outgoing cross-feature link, also
update the linked-to doc's incoming references.

**Why both sides:**

The doc graph's value comes from being navigable in both directions:

- "What does feature X depend on?" → outgoing links from X's doc
- "What depends on feature Y?" → incoming links in Y's doc

If only one side is maintained, navigation works in only one
direction, and drift between the two sides becomes a constant low-grade
noise.

**Why we don't auto-check reciprocity:**

Discussed in [doc-format.md](doc-format.md#why-we-dont-enforce-link-reciprocity-at-check-time).
TL;DR: enforcing at check-time creates false positives and trains
users to ignore the checker. Pushing consistency to write-time (via
this rule) is more reliable.

## The change classification table

The injection text contains this table:

| Change | Update doc? |
|--------|-------------|
| Add / remove user-visible behavior | **Required** |
| Change interaction flow, layout, animation | **Required** |
| Change business logic branches | **Required** |
| Add / remove cross-module dependency | **Required (both sides)** |
| Bug fix where new code matches existing doc | No |
| Bug fix that changed behavior (even toward "right") | **Required** |
| Refactor / rename — same behavior | No |
| Performance optimization — same behavior | No |
| i18n / copy / theme tweaks | No |

**Rule of thumb**: would a user notice? If yes → update.

### Why a table, not a single rule

A single rule like "update the doc whenever you change code" is too
broad — it triggers unnecessary work for refactors and bug fixes that
don't change behavior, leading to either tedium-induced sloppiness or
formal compliance ("I'll just bump the SHA").

A single rule like "update the doc when behavior changes" is too
fuzzy — different engineers/AIs will draw the line differently,
creating inconsistency.

The table gives concrete cases. The "rule of thumb" is the safety
net for cases the table doesn't cover.

### Why bug fixes have two rows

This trips people up. The distinction:

- **Bug fix where new code matches existing doc**: the doc already
  described the *correct* behavior; the code was wrong; the code is
  now caught up. No doc update needed.
- **Bug fix that changed behavior** (even toward "right"): the doc
  was wrong (it described the buggy behavior, or the "right" behavior
  the engineer is now imposing wasn't documented). Doc needs to
  reflect the new authoritative behavior.

In practice, the second case is more common than people expect.
Bugs often hide in undocumented edge cases; fixing them implicitly
documents new behavior, and the L3 should reflect it.

## What about refactors?

Refactors are explicitly *not* doc changes when behavior is preserved.

This is intentional permission to refactor freely without doc
overhead. If we required doc updates on refactors:

- Refactor PRs would balloon
- The doc would accumulate noise about implementation details
- Engineers would resist refactoring (high friction = less of it)

The exception: if a refactor *also* changes the public API surface
(function signatures, exposed types) that a *cross-module dependency*
relies on, that's a behavior change, even if the renamer only
intended a refactor. Use Rule 3.

## What about adding a new feature?

Covered by a separate section in the injection text. The rule:

- Pick the right template based on language and kind (UI vs logic)
- Create the L3 doc with **real content**, not TODO stubs
- Append a row to the L2 module index
- If reachable from existing features, update those features'
  outgoing cross-links
- Leave `last_synced_commit: ""` until implementation lands

Note there's no `/geno-add` skill. Adding features is just an
application of the workflow rules; it doesn't need a special command.
See [decisions/0001](decisions/0001-two-skills-not-five.md).
