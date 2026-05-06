# Contributing to OpenGeno

Thanks for considering a contribution. OpenGeno is small and
opinionated — the contribution model is correspondingly simple.

## Before you start

Read [`docs/`](docs/) — especially [motivation.md](docs/motivation.md)
and the [decisions/](docs/decisions/) ADRs. Many things are explicitly
out of scope and won't be merged regardless of how cleanly they're
implemented:

- Auto-generation of L3 docs from code
- Mandatory cross-link reciprocity checks
- A GUI / dashboard
- More than two skills (find / add / update etc. — see [ADR 0001](docs/decisions/0001-two-skills-not-five.md))

If you're not sure whether your idea is in scope, open an issue first.

## Reporting bugs

Open a GitHub issue with:

1. What you ran (the slash command, exact prompt, files involved)
2. What you expected
3. What happened
4. The relevant section of `feat-tree/` or `CLAUDE.md` if applicable
5. Claude Code version and OS

For drift-detection bugs, include a minimal repro: which `code:`
paths, what `last_synced_commit` SHA, what `git log` shows.

## Proposing changes

For non-trivial changes (anything beyond typo fixes / doc clarifications):

1. Open an issue first describing the change and rationale.
2. If accepted, open a PR.
3. PRs should be small and focused — one logical change per PR.
4. If the change affects schema (frontmatter fields) or workflow
   rules, also write an ADR in `docs/decisions/` explaining the
   trade-off.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<optional body>

<optional footer>
```

Types we use:

- `feat` — new functionality
- `fix` — bug fix
- `docs` — documentation only
- `refactor` — no behavior change
- `chore` — tooling, deps, repo hygiene
- `test` — tests only

Scope is optional. Examples:

- `feat(geno-sync): add yellow/red separation in drift report`
- `fix(drift-check): handle code paths with spaces`
- `docs: clarify update-after rule for partial updates`
- `chore: bump plugin version to 0.2.0`

Subject is imperative, lowercase, no trailing period, ≤72 chars.

If a commit changes user-visible behavior of a skill, the related
SKILL.md and any L3 docs that mention the skill must also be updated
in the same commit.

## Code style

- Bash scripts: POSIX-compatible where possible; explicit `bash`
  shebang + `set -u` at minimum
- Markdown: 80-col wrap for prose; longer is fine for tables
- Frontmatter: YAML, two-space indent, double quotes for strings that
  could be ambiguous

## Testing

This is a markdown + bash project; there's no formal test suite.
Manual verification before opening a PR:

1. Run `bash skills/geno-init/scripts/drift-check.sh` from
   `examples/todo-app/` — should report stubs as expected
2. Run `bash skills/geno-init/scripts/stop-check.sh` from the same
   — should produce a summary in warn mode

If your change adds new behavior, describe in the PR body how to
verify it manually.

## Adding a translation

OpenGeno currently supports English and Chinese feature trees. Adding
another language requires:

1. Variants of all four template files
   (`root-index.<lang>.md`, `module-index.<lang>.md`,
   `feature-ui.<lang>.md`, `feature-logic.<lang>.md`)
2. A variant of `claude-md-injection.<lang>.md`
3. Updates to `geno-init/SKILL.md` to handle the new language choice
4. Updates to the `/geno-sync` language detection logic

Open an issue first to coordinate.

## Licensing

By contributing, you agree your work is licensed under the MIT
License (see [LICENSE](LICENSE)).
