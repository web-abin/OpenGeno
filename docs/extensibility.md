# Extensibility

OpenGeno is at `schema: 1` and version `0.1.0`. This document covers
where the system can grow, with sketches of likely directions —
**not commitments**. None of these are scheduled.

## Schema versioning

The `schema:` field in every doc's frontmatter is a forward-compat
hook. If we change the field structure in a way that breaks
backward parsing, schema bumps.

Likely v2 additions:

- **`tags:`** — labels for filtering ("public-api", "auth-required",
  "experimental"). Currently absent because the tree itself is the
  primary organizer; tags would only be useful at very large scale.
- **`owner:`** — team or person responsible for the feature. Useful
  in multi-team monorepos.
- **`stability:`** — `stable` / `experimental` / `deprecated`.
  Currently encoded in prose; promoting to a field enables tooling.
- **`code` field richer**: instead of just paths, allow function-level
  granularity (`path/file.ts:functionName`). Enables more precise
  drift detection but adds complexity.

Migration approach: when v2 ships, `/geno-sync` runs the migration on
all v1 docs (mostly defaulting new fields). v1 docs continue to work
indefinitely.

## Possible new skills

The current 2-skill design (`init`, `sync`) is intentional. New
skills are added only when:

- The operation is a *user-scheduled intentional act* (not continuous
  behavior — those go in CLAUDE.md)
- The operation is genuinely complex enough to warrant ceremony
- It can't be reduced to one of the existing skills

Likely candidates if needed:

- **`/geno-translate`** — translate the tree from one language to
  another, preserving structure, frontmatter, and cross-links.
  Currently we tell users to do this manually; the demand profile
  may justify automation eventually.
- **`/geno-archive`** — when a feature is removed entirely,
  cleanly archive its L3 doc to `feat-tree/_archived/` and remove
  cross-links. Currently part of `/geno-sync`'s reconciliation
  flow but could be its own skill if the workflow is more than
  occasional.
- **`/geno-export`** — export the tree as a static site, PDF, or
  printable summary. Useful for stakeholder review or compliance
  audits.
- **`/geno-stats`** — show tree health: feature count, drift count
  over time, average sync staleness. Useful as a project health
  dashboard.

We will resist `/geno-find`, `/geno-add`, `/geno-update` — those are
continuous behaviors that belong in CLAUDE.md, not skills.
See [decisions/0001](decisions/0001-two-skills-not-five.md).

## CI integration

A natural integration point: PR checks.

A CI job could:

1. Check out the PR branch
2. Run `drift-check.sh`
3. Comment on the PR with drift summary
4. Optionally fail the check if drift is unresolved

We don't ship this in v0.1 because:

- Different CI systems have different conventions (GitHub Actions,
  GitLab CI, CircleCI, etc.) — no universal config
- The user's `drift_mode` choice (warn vs block) should govern
  whether CI passes/fails, but `.feat-tree.json` is a local config

A future `examples/ci/` folder could include reference YAML for
common CI systems.

## Multi-language tree?

Currently a tree is monolingual (see
[language-strategy.md](language-strategy.md)). What if a project
needs multilingual?

Possible future approach: allow `feat-tree/` and `feat-tree.zh/` (or
arbitrary language suffixes), with one being authoritative and others
being mirrors. Drift detection would only run against the
authoritative tree; mirrors are translation artifacts.

We don't want this in v1 because the maintenance cost is high and
the demand is low. If real demand surfaces, this is the architecture.

## Cross-repo / monorepo

OpenGeno currently assumes one tree per project root. In a monorepo
with multiple deliverables (multiple apps in one repo), each could
have its own tree:

```
monorepo/
├── apps/web/feat-tree/      # web app's tree
├── apps/mobile/feat-tree/   # mobile app's tree
└── apps/api/feat-tree/      # API's tree
```

`.feat-tree.json` already supports `tree_path` configuration for
this — point it at the right subtree. Run `/geno-init` and
`/geno-sync` from each app's root directory.

This works today. The thing missing is:

- A "meta" command to run sync across all trees in a monorepo
- A canonical place to document monorepo-level cross-app dependencies
  (where the auth service in `apps/api` is consumed by both `web`
  and `mobile`)

Could be a future `/geno-monorepo` command. Or just a CLI helper
script in `examples/`.

## Code reverse-mapping

Currently the tree-to-code direction is explicit (`code:` lists in
each L3 doc). The code-to-tree direction is implicit (grep the tree
for the file path).

Future enhancement: a code annotation convention.

```dart
// @og: feat-tree/auth/login.md
class LoginPage extends StatelessWidget { ... }
```

Or in JS:

```ts
/** @og feat-tree/auth/login.md */
export function loginHandler() { ... }
```

This would let the post-edit-warn hook find the doc faster (read the
file's first 10 lines instead of grepping the tree). It would also
let IDE integrations show "go to doc" actions.

We don't ship this because:

- Adding code annotations is invasive
- Not all languages have a clean comment idiom
- The grep-based approach is fast enough in practice

If demand surfaces (especially from IDE-extension authors), this is
the natural next step.

## What we deliberately won't do

To keep the design stable:

- **No formal validation tooling.** Linting frontmatter, validating
  cross-links, checking section presence — these are tempting but
  push toward a "compliance" mindset. Markdown is markdown; humans
  read it and judge. AI checks happen in `/geno-sync`.
- **No GUI / dashboard.** OpenGeno is markdown + git. If you want a
  GUI, point any markdown viewer at `feat-tree/`.
- **No proprietary format.** Everything is markdown with YAML
  frontmatter. Portable forever.
- **No mandatory cross-link reciprocity check.** Discussed in
  [doc-format.md](doc-format.md#why-we-dont-enforce-link-reciprocity-at-check-time).
- **No auto-generation of L3 docs from code.** The whole point is
  that docs describe *intent*. Generating them from code defeats the
  purpose. (Initial bootstrap stubs are an exception — they're
  deliberately empty placeholders.)

These aren't "we'll do them later" — they're things we've considered
and rejected.
