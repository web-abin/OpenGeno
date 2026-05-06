<!-- BEGIN OpenGeno -->
## Feature documentation (OpenGeno)

This project uses [OpenGeno](https://github.com/web-abin/OpenGeno) to
maintain a hierarchical living-doc tree under `feat-tree/`. The tree is
the source of truth for user-visible behavior of every feature.

**Doc language: English.** When you create or update any file under
`feat-tree/`, write all prose, headings, comments, and frontmatter values
in English. Do not mix languages within the tree.

### Read before changing

Before changing **user-visible behavior** of an existing feature:

1. Read `feat-tree/index.md` to find the relevant module.
2. Read `feat-tree/<module>/index.md` (L2) to find the specific feature.
3. Read the feature's L3 doc (`feat-tree/<module>/<feature>.md`) before
   editing any code.
4. If you can't locate the feature in the tree but you're changing its
   behavior, **stop and create the L3 doc first** (see "Add a new
   feature" below). Modifying an undocumented feature creates permanent
   doc debt.
5. Default cross-link depth is **one hop**. Don't recurse through cross
   references unless you have a specific reason.

### Update after changing

In the **same session** that you change feature behavior:

1. Re-read the L3 doc for that feature.
2. Walk it section by section, edit only the sections that diverged.
3. If you added/removed an outgoing cross-feature link, also update the
   linked-to doc's "Cross-feature links" section to reflect the new
   incoming reference.
4. Set `last_synced_commit:` to current `git rev-parse HEAD`. Set
   `last_reviewed:` to today.
5. **Critical:** only bump `last_synced_commit` if you actually re-read
   the touched code in this session. Bumping the SHA without verification
   destroys the entire system. If unsure, leave it stale and let
   `/geno-sync` flag it later.

### What changes trigger a doc update?

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

Rule of thumb: would a user notice? If yes → update.

### Add a new feature

When implementing a brand-new feature:

1. Decide its module (existing or new).
2. Pick the right template from your installed OpenGeno skill:
   - UI feature → `templates/feature-ui.md`
   - Logic feature → `templates/feature-logic.md`
3. Create `feat-tree/<module>/<feature>.md` from the template, fill in
   real content (wireframe, interactions / triggers, logic, state, edge
   cases, cross-links). Do NOT leave `TODO` placeholders.
4. Append a row to `feat-tree/<module>/index.md` under "Features".
5. If reachable from existing features, update those features' L3 docs
   to add the new outgoing cross-link.
6. Leave `last_synced_commit: ""` empty until the implementation lands —
   then update it as part of the normal "update after changing" flow.

### Suspect drift

If you suspect the tree is out of sync with code (after merging a
branch, after a vibe-coding session, after manual edits outside this
workflow), invoke `/geno-sync`.

### What does NOT belong in the tree

The following are infrastructure, not features. They belong in code
comments, ADRs, or this CLAUDE.md — not in `feat-tree/`:

- i18n / translations
- Analytics / telemetry
- Build tooling, CI/CD
- Error reporting (Sentry, etc.)
- Logging
- Pure utility helpers
- Theme primitives (color tokens, typography scales)
<!-- END OpenGeno -->
