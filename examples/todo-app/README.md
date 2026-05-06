# Example — TodoApp (`gen_mode: "stub"`-shaped)

A complete (if small) feature tree for a fictional todo app. Use this as a
reference when starting your own tree.

For the contrast — what `/geno-init` produces when the user picks
**one-shot full docs** instead — see the sibling [`todo-app-full/`](../todo-app-full/)
example.

## What's here

```
todo-app/
├── .feat-tree.json
└── feat-tree/
    ├── index.md                 # L1 — module list
    ├── auth/
    │   ├── index.md             # L2 — auth module
    │   ├── sign-in.md           # L3 — UI feature
    │   ├── sign-up.md           # L3 — UI feature
    │   └── sign-out.md          # L3 — logic feature
    ├── tasks/
    │   ├── index.md             # L2 — tasks module
    │   └── list-view.md         # L3 — UI feature (the others are stubs)
    └── lists/
        ├── index.md             # L2 — lists module
        └── manage.md            # L3 — UI feature
```

There's no actual source code — the `code:` paths in each frontmatter
are imaginary. The example is purely about documentation shape.

## What to learn from this

- **L1** is a small module table, nothing more.
- **L2** lists features within a module, plus cross-module dependencies
  and module-level invariants.
- **L3 UI** features have a wireframe at the top, then layered sections
  (entry points → layout → interactions → logic → state → animation →
  cross-links → edge cases → related code).
- **L3 Logic** features (like `sign-out`) have triggers/inputs/outputs/
  flow/failure-modes/invariants instead of UI sections.
- Cross-feature links use **relative paths** and are documented from
  both sides (the linker and the linked-to).
- Stubs / not-yet-documented features still show up in L2 tables with a
  marker — they're discoverable, just unfilled.
