---
type: og-module
module: {{MODULE_SLUG}}
schema: 1
last_synced_commit: ""
---

# {{MODULE_NAME}}

<!-- One paragraph: what this module covers, what it does NOT cover. -->

## Features

<!--
  One row per feature. Sort by user-flow order when possible (entry points first),
  not alphabetically. Sub-modules link to their own index.md.
-->

| Feature | Kind | Path |
|---------|------|------|
| {{FEATURE_NAME}} | UI | [{{FEATURE_SLUG}}.md]({{FEATURE_SLUG}}.md) |
|  | Logic |  |

## Cross-module dependencies

<!--
  Where does this module read state from / write state to / depend on other modules?
  Be specific about the direction. Examples:
  - Profile reads user from AuthState (written by Login).
  - Notifications triggers password-reset deep link.
  Keep it under 5 bullets — if there are more, that may indicate the module
  boundary is wrong.
-->

- TODO

## Module-level invariants

<!--
  Optional. Properties that must hold across all features in this module.
  Examples:
  - All features here require an authenticated session.
  - All write operations go through `AuthService`, never raw HTTP.
-->

- TODO
