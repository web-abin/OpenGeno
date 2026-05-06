# Doc format

The canonical schema for L1, L2, and L3 docs lives in
[`skills/geno-init/reference.md`](../skills/geno-init/reference.md). This
document explains the *why* behind the choices in that schema. If you
want field definitions or copy-paste templates, go to reference.md.

## Why three tiers, not one or two

A flat tree (one folder, one doc per feature) starts breaking around
20–30 features:

- The directory listing becomes hard to scan
- Module-level invariants (e.g. "all features in this module require
  auth") have nowhere to live
- Cross-module dependency reasoning happens at the wrong granularity
- AI loading "the index" of the project has to load every feature's
  metadata to know what's there

A two-tier (module folder + feature files) handles 100+ features but
loses one thing: a *quickly-readable* project map that fits in
attention. So we mount the L1 root index as a small index that's
always-loaded, with L2/L3 lazy-loaded.

The three-tier design is therefore:

- **L1 (root)** — fits in ~500 tokens, always-loaded. Module list,
  out-of-scope, conventions.
- **L2 (module)** — feature list within a module, plus
  cross-module dependencies and module invariants.
- **L3 (feature)** — the actual spec.

See [decisions/0004](decisions/0004-three-tier-lazy-loading.md) for
the token-budget reasoning.

## Why frontmatter

Frontmatter exists to give the drift checker something machine-readable
to work with. Specifically, every L3 doc needs:

- `code:` — the list of source files this doc describes
- `last_synced_commit:` — the SHA at which doc and code last agreed

Without these two fields, drift detection is impossible. We could
have used a parallel sidecar file (`<feature>.meta.json`) but that
splits state across two files and invites the two to drift relative
to each other. Inline frontmatter keeps state in one place.

`type:` (`og-root` / `og-module` / `og-feature`) lets the drift
checker filter L3 docs from the rest. We use `og-` (OpenGeno) prefix
to avoid clashing with other markdown frontmatter conventions.

## Why `last_synced_commit` instead of `last_synced_at`

Time-based sync ("last synced 2 weeks ago") is wrong:

- It says nothing about whether code changed
- It pressures users to bump it just because time passed
- It can't distinguish "doc is current" from "doc was reviewed but
  nothing has changed since"

Commit-based sync answers the right question: "have any of the files
this doc claims to describe changed since the doc said it agreed
with them?" The drift checker uses `git log <SHA>..HEAD -- <code-path>`
to answer this directly.

`last_reviewed:` is a separate, time-based field that *is* about
"how recently did a human look at this". It's optional and
informational. Drift detection ignores it.

## Why the section structure for L3

The L3 templates fix a section order:

For UI features:
1. Wireframe
2. Entry points
3. Layout
4. Interactions
5. Logic
6. State
7. Animation
8. Cross-feature links
9. Edge cases
10. Related code

For logic features:
1. Triggers
2. Inputs
3. Outputs
4. Logic flow
5. State
6. Failure modes
7. Invariants
8. Cross-feature links
9. Related code

The order is **not** alphabetical. It mirrors the sequence in which a
reader needs each piece to understand the feature:

- Wireframe / Triggers anchor *what kind of thing this is*
- Entry points / Inputs answer *how do we get to it*
- Layout / Logic flow describe *the body*
- State / Failure modes describe *what can go wrong*
- Cross-links and Related code are reference material at the end

A standardized order means readers know where to skim to. AI agents
also learn the structure and consistently fill it in correctly.

## Why wireframes are required for UI features

A wireframe is the cheapest way to get the doc and the AI on the
same page about *what this thing looks like*. ASCII art or mermaid is
fine; it doesn't have to be pretty.

We make it required because UI specs without a visual anchor tend to
contradict themselves silently. The "Interactions" section says "tap
the X button"; if there's no wireframe showing X exists, drift
between UI and doc becomes invisible.

For non-UI features ("logic" kind), there's no equivalent — the
trigger/inputs/outputs block plays the same role.

## Why cross-links are one-hop, by default

A doc graph naturally invites recursive reading: "feature A links to
B; let me read B; B links to C; let me read C; ..." Without a
boundary, AI agents can spiral and consume tens of thousands of
tokens before getting to work.

The default is **one hop** — read the docs you directly need, follow
a link only when you need to understand the dependency. Multi-hop is
allowed but requires explicit AI judgment.

This rule is in the workflow contract injected into CLAUDE.md so the
AI sees it on every session.

## Why we don't enforce link reciprocity at check time

If A links to B, ideally B should also link to A in its
"Cross-feature links" section. We could enforce this with a script.

We don't, for two reasons:

1. **Asymmetric links are valid.** A might depend on B without B
   depending on A. The reciprocal link in B's doc is informational
   ("things that reach me"), not structural.
2. **Enforcement at check time creates noise.** A reciprocity-checker
   would flag every legitimate asymmetric link, training users to
   ignore the noise — which then masks real problems.

Instead, the workflow rules in CLAUDE.md instruct the AI to update
both sides when adding a cross-link. This pushes consistency to the
write moment, not the check moment.

## Why filenames are kebab-case English even in Chinese trees

In a Chinese tree, all *content* is Chinese. But the file paths stay
kebab-case English (`sign-in.md`, not `登录.md`).

Reasons:

- File system encoding issues with non-ASCII paths
- Cross-platform reliability (Windows/macOS handle non-ASCII paths
  inconsistently)
- AI stability — agents are more reliable at handling
  ASCII-only paths
- Slugs are *identifiers*, not human-facing prose. They're safe to be
  technical English.

The user's chosen language only governs the *content* of files,
not their names.

## Out of scope — what doesn't belong in the tree

Listed in
[`templates/root-index.md`](../skills/geno-init/templates/root-index.md)
and the README. The principle behind the list:

> **A feature is something a user can observe behaving differently
> after a change. Anything else is infrastructure.**

i18n changes the *language* of strings but not what the feature does.
A theme change re-skins existing structure but doesn't add an
interaction. Logging is invisible to the user. By this rule:

- ✅ "Add OAuth login" → feature change
- ❌ "Translate to Spanish" → not a feature change
- ❌ "Switch logging library" → not a feature change
- ✅ "Add 'Forgot password' button to login screen" → feature change
- ❌ "Refactor button component for reuse" → not a feature change
  (unless the visual design also changed, which would be one)

When in doubt, ask: would a user interacting with the product notice?
If yes → feature, into the tree. If no → infrastructure, not in the
tree.

See [decisions/0008](decisions/0008-out-of-scope-items.md) for the
extended reasoning.
