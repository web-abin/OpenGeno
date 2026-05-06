# Example — TodoApp (`gen_mode: "full"`)

What `/geno-init` produces when the user picks the **one-shot full
docs** mode at Step 3. Compare with the sibling [`todo-app/`](../todo-app/)
example, which is shaped like a `gen_mode: "stub"` tree (placeholders
in section bodies, to be filled incrementally).

## What's here

```
todo-app-full/
├── .feat-tree.json            # gen_mode: "full"
└── feat-tree/
    ├── index.md               # L1
    └── auth/
        ├── index.md           # L2
        ├── sign-in.md         # L3 UI feature — full-mode draft
        └── sign-out.md        # L3 logic feature — full-mode draft
```

Only the `auth/` module is included — the demo is about the *shape* of
full-mode output, not about being a complete app.

## What to look for

Compared with the curated `todo-app/` example, this tree shows what you
realistically get from a one-shot init pass:

1. **Hedged tone.** Sections that the AI inferred from code use phrases
   like "inferred from", "based on", or "*(seen in the controller's
   `canSubmit` getter)*". Sections it couldn't infer are left as `TODO`
   or `待补充`.

2. **Empty `last_synced_commit:`.** Even though prose exists, the SHA
   stays empty. Full-mode init does **not** verify against code — that's
   a human review pass. The empty SHA is what tells `/geno-sync` (and
   the user) the doc still needs that pass.

3. **Mode recorded in `.feat-tree.json`.** The `gen_mode: "full"` field
   is what lets `/geno-sync` distinguish "stub waiting to be written"
   from "full-mode prose waiting to be verified" — same empty SHA,
   different reconciliation action.

4. **Honest gaps.** Sections like `Wireframe`, `Animation`, `Edge
   cases`, and design-system-driven details are explicitly marked as
   things init can't produce. The skill is told (in `SKILL.md` Step 8)
   to leave placeholders rather than guess.

## Workflow after this output exists

1. Open each L3 doc, read it against the actual code.
2. Correct anything wrong. Fill in the placeholder sections.
3. When you're confident a doc matches the code, bump
   `last_synced_commit` to current `git rev-parse HEAD`. **Don't** bump
   it just because prose exists — the SHA means *verified*, not
   *written*.
4. `/geno-sync` will keep listing unverified full-mode docs in its
   "Stubs" / "review" category until the SHA is set.

## Why have this mode at all?

`stub` mode is the default because deeper code reading is expensive
and hallucination-prone. `full` mode is useful when:

- The codebase is small and stable enough that an init-time read can
  cover most of it.
- The user wants a complete first-pass tree to review wholesale, rather
  than filling docs one at a time as features change.
- The team prefers reviewing AI-generated drafts to writing prose from
  scratch.

The trade-off is exactly the one shown above: more content up front,
but every line of it needs human verification before it can carry the
SHA that grants drift-detection's trust.
