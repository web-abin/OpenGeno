---
type: og-root
schema: 1
last_synced_commit: ""
---

# {{PROJECT_NAME}} Feature Tree

> Maintained by [OpenGeno](https://github.com/web-abin/OpenGeno).
> AI agents must read this index before changing user-visible behavior, and
> must update the relevant feature doc whenever they change behavior.

## Modules

<!--
  One row per top-level module. Keep description to one line.
  When you add a module, also create feat-tree/<module>/index.md from
  templates/module-index.md.
-->

| Module | Description | Path |
|--------|-------------|------|
| {{MODULE_NAME}} | {{ONE_LINE_DESCRIPTION}} | [{{MODULE_SLUG}}/]({{MODULE_SLUG}}/index.md) |

## Out of scope

The following are NOT documented in this tree — they are cross-cutting
infrastructure rather than user-observable features. They have a place in
code comments and CLAUDE.md, but not here.

- Internationalization / translations
- Analytics, telemetry, A/B testing instrumentation
- Build tooling, CI/CD, release scripts
- Error reporting (Sentry, Crashlytics, etc.)
- Logging
- Pure utility helpers and shared widgets without behavior of their own
- Theming primitives (colors, typography tokens)

## Conventions

- Module and feature slugs are `kebab-case`.
- Sub-features that share a parent flow live in a sub-directory with their
  own `index.md`.
- Cross-feature dependencies are documented in the **Cross-feature links**
  section of each L3 doc, with relative-path links.
