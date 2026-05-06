---
type: og-module
module: tasks
schema: 1
last_synced_commit: ""
---

# Tasks

Create, view, edit, complete, and delete individual tasks. The unit of
work in the app.

## Features

| Feature | Kind | Path |
|---------|------|------|
| Task list view | UI | [list-view.md](list-view.md) |
| Create task | UI | (not documented in this example) |
| Edit task | UI | (not documented in this example) |
| Complete task | UI | (not documented in this example) |

## Cross-module dependencies

- Task list is scoped to the currently-active list from `Lists`. If no
  list is active, defaults to the user's "Inbox".
- All operations require an active session (see `Auth`); on
  `auth.signed_out` the cache is cleared.
