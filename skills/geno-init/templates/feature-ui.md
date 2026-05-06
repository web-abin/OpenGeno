---
type: og-feature
kind: ui
feature: {{FEATURE_SLUG}}
module: {{MODULE_SLUG}}
schema: 1
code:
  - {{CODE_PATH_1}}
last_synced_commit: ""
last_reviewed: {{TODAY}}
---

# {{FEATURE_NAME}}

<!-- One paragraph: what this feature is, who uses it, why it exists. -->

## Wireframe

<!--
  ASCII or mermaid. Required for every UI feature.
  - For static layouts, use box-drawing ASCII.
  - For flows / navigation, use mermaid flowchart.
  Wireframes don't need to be pretty — they need to anchor the rest of the doc.
-->

```
┌────────────────────────────┐
│                            │
│                            │
└────────────────────────────┘
```

## Entry points

<!-- How does the user arrive here? Direct nav, deep link, redirect, modal trigger... -->

- TODO

## Layout

<!--
  Top-to-bottom structural composition. Name each section/region.
  Keep this short — wireframe already shows visual structure; this names the parts.
-->

- TODO

## Interactions

<!--
  Numbered. For each interactive element:
  - Trigger (tap, type, swipe, long-press, hover, ...)
  - Validation (if any)
  - Visible feedback
  - Resulting state change or navigation
-->

1. **{{ELEMENT}}**: TODO

## Logic

<!--
  Business logic that's not visible in the UI:
  - API calls (path + payload shape, not full schema)
  - Storage writes (what + how long)
  - Side effects (events emitted, other features notified)
-->

- TODO

## State

| State | Trigger | UI effect |
|-------|---------|-----------|
| idle | initial | TODO |
|  |  |  |

## Animation

<!-- Motion, transitions, micro-interactions. Skip section if none. -->

- TODO

## Cross-feature links

<!--
  → outgoing: features this one navigates to / triggers
  ← incoming: features that navigate to / trigger this one
  Use relative paths. Keep one-hop only.
-->

- TODO

## Edge cases

<!--
  Network offline, empty states, permission denied, race conditions,
  any "what happens when X goes wrong."
-->

- TODO

## Related code

- {{CODE_PATH_1}}
