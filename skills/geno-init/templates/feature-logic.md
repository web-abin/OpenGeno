---
type: og-feature
kind: logic
feature: {{FEATURE_SLUG}}
module: {{MODULE_SLUG}}
schema: 1
code:
  - {{CODE_PATH_1}}
last_synced_commit: ""
last_reviewed: {{TODAY}}
---

# {{FEATURE_NAME}}

<!-- One paragraph: what this logic does, what it produces, who triggers it. -->

## Triggers

<!-- When does this run? Event-based, time-based, manually invoked, etc. -->

- TODO

## Inputs

<!-- What data does it consume? Sources and shape. -->

- TODO

## Outputs

<!-- What does it produce / mutate / emit? -->

- TODO

## Logic flow

<!--
  Numbered steps OR mermaid flowchart for branching logic.
  Describe behavior, not implementation. No pseudo-code mirroring the actual code.
-->

1. TODO

## State

<!--
  Optional. If this logic owns a state machine, describe transitions.
-->

- TODO

## Failure modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| TODO | TODO | TODO |

## Invariants

<!--
  Optional. Properties that must always hold. Useful for catching regressions.
  Examples:
  - "Token is never written to disk in plaintext."
  - "Refresh is never invoked while another refresh is in flight."
-->

- TODO

## Cross-feature links

- TODO

## Related code

- {{CODE_PATH_1}}
