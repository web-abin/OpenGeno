---
type: og-feature
kind: ui
feature: manage
module: lists
schema: 1
code:
  - lib/features/lists/lists_drawer.dart
  - lib/features/lists/list_form_sheet.dart
  - lib/state/lists_store.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Manage lists

Drawer-based list management. Drawer shows all of the user's lists; tap
to switch active list; long-press to edit / delete; "+ New list" at the
bottom opens a creation sheet.

## Wireframe

```
┌──────────────────────────┐
│ User Avatar              │
│ user@example.com         │
├──────────────────────────┤
│  ★  Inbox            (4) │ ← currently active
│  ☑  Work             (12)│
│  ☑  Personal         (3) │
│  ☑  Shopping         (1) │
│                          │
├──────────────────────────┤
│  + New list              │
└──────────────────────────┘
```

Long-press row reveals action sheet:

```
┌──────────────────────────┐
│  Edit name               │
│  Delete                  │ ← disabled for Inbox
│  Cancel                  │
└──────────────────────────┘
```

Creation / edit sheet:

```
┌──────────────────────────┐
│ New list                 │
│ ┌──────────────────────┐ │
│ │ List name            │ │
│ └──────────────────────┘ │
│           [ Save ]       │
└──────────────────────────┘
```

## Entry points

- Tap drawer toggle (☰) on [Tasks/list-view](../tasks/list-view.md)
- Edge-swipe from screen left

## Layout

1. Header: user avatar + email (read-only)
2. List of lists, each row = icon + name + task count
3. "+ New list" CTA at bottom

## Interactions

1. **List row tap**
   - Sets `active_list_id` to that list
   - Closes drawer
   - Tasks/list-view re-renders with the new filter
2. **List row long-press**
   - Opens action sheet
   - "Edit name": opens edit sheet (pre-filled)
   - "Delete": opens confirm dialog; on confirm, DELETE `/lists/:id`
     - If active list: switch to Inbox first
     - Inbox: option disabled
3. **+ New list**
   - Opens creation sheet
   - Save → POST `/lists`, append to store, close sheet
   - Empty name: Save disabled

## Logic

- Reads from `lists_store`
- On mount: fetch if cache age > 30s
- Optimistic create / rename / delete; revert on API failure
- Listens to `auth.signed_out` and clears store

## State

| State | Trigger | UI effect |
|-------|---------|-----------|
| loaded | data present | list shown |
| creating | sheet open + Save tapped | sheet button → spinner |
| editing | edit sheet open + Save tapped | same |
| deleting | confirm tapped | row → spinner |
| error | API failure | toast, revert optimistic change |

## Animation

- Drawer slide: 280ms ease-out
- Row long-press lift: 100ms scale 1.0 → 1.02
- Sheet slide-up: 250ms ease-out
- Optimistic insert: fade-in 200ms

## Cross-feature links

- ← [Tasks/list-view](../tasks/list-view.md) (entry point via drawer toggle)
- → [Tasks/list-view](../tasks/list-view.md) (after list switch / delete)
- Listens: `auth.signed_out` from [Sign out](../auth/sign-out.md)

## Edge cases

- Delete the currently-active list: switch active to Inbox before delete
- Two creates in flight: both optimistic; rollback only failing one
- Server returns a list whose name conflicts with a local optimistic
  one: keep server, reconcile silently

## Related code

- `lib/features/lists/lists_drawer.dart`
- `lib/features/lists/list_form_sheet.dart`
- `lib/state/lists_store.dart`
