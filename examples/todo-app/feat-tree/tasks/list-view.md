---
type: og-feature
kind: ui
feature: list-view
module: tasks
schema: 1
code:
  - lib/features/tasks/list_view_page.dart
  - lib/features/tasks/task_tile.dart
  - lib/state/tasks_store.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Task list view

Default screen after sign-in. Shows tasks for the active list, ordered
by user-defined position. Supports inline complete, swipe-to-delete,
and pull-to-refresh.

## Wireframe

```
┌──────────────────────────────┐
│ ☰  Inbox          ⊕  👤      │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ ◯  Pay rent              │ │
│ │ ◯  Call dentist          │ │
│ │ ●  Buy milk              │ │ ← completed (struck-through)
│ │ ◯  Email mom             │ │
│ └──────────────────────────┘ │
│                              │
│             ⊕                │ ← floating add (sticky)
└──────────────────────────────┘
```

## Entry points

- Default landing after Sign in
- Tap a list in the drawer (changes active list, then this view shows)
- Deep link `todoapp://tasks?list=<id>`

## Layout

Top → bottom:

1. App bar: drawer toggle (☰), current list name, add button (⊕),
   profile avatar
2. Scrollable task list
   - Each row = circle checkbox + title + (subtitle if due date set)
3. Floating add button (bottom-right, sticky)

## Interactions

1. **Drawer toggle (☰)** — opens lists drawer (see [Lists/manage](../lists/manage.md))
2. **List title** — non-interactive
3. **Add button (⊕ in app bar AND floating)** — opens Create task (not
   documented in this example)
4. **Profile avatar (👤)** — opens profile menu, includes sign-out
   (triggers [Sign out](../auth/sign-out.md))
5. **Task row tap** — opens Edit task (not documented in this example)
6. **Task row checkbox** — toggles completion in-place
   - Optimistic UI: immediate strike-through
   - On API failure: revert + error toast
7. **Swipe-left on row** — reveals red "Delete" action
   - Tap delete → confirm dialog → hard delete via API
   - Cancel → row springs back
8. **Pull-to-refresh** — re-fetches from server, replaces store

## Logic

- Reads from `tasks_store` (selector: tasks where `list_id == active_list_id`,
  ordered by `position`)
- On mount: triggers a fresh fetch if cache age > 30s
- Optimistic toggle: write to store immediately, send `PATCH /tasks/:id`,
  on failure revert
- Listens to `auth.signed_out` and clears the store

## State

| State | Trigger | UI effect |
|-------|---------|-----------|
| loading-initial | first mount with empty cache | full-screen spinner |
| loaded | data present | list shown |
| refreshing | pull-to-refresh | spinner under app bar |
| empty | loaded with 0 tasks | empty-state placeholder |
| error | refresh fails | toast + previous data still shown |

## Animation

- Checkbox toggle: 150ms scale 1.0 → 1.2 → 1.0 with color cross-fade
- Strike-through: 200ms width animation
- Swipe action reveal: track finger 1:1, snap back 200ms ease-out
- Row deletion: 250ms slide-up + height collapse

## Cross-feature links

- → Create task (not in this example) — via add buttons
- → Edit task (not in this example) — via row tap
- → [Sign out](../auth/sign-out.md) — via profile menu
- → [Lists/manage](../lists/manage.md) — via drawer
- ← [Sign in](../auth/sign-in.md) — post-success target
- ← [Sign up](../auth/sign-up.md) — post-success target

## Edge cases

- Active list deleted while viewing: redirect to Inbox, show toast
- Optimistic toggle while offline: queue locally, retry on reconnect
- Cache populated but list deleted server-side: 404 on refresh →
  redirect to Inbox
- Very long task title: ellipsize at 2 lines, full text on row tap

## Related code

- `lib/features/tasks/list_view_page.dart` — UI tree
- `lib/features/tasks/task_tile.dart` — single row component
- `lib/state/tasks_store.dart` — cache + selectors
