---
type: og-module
module: lists
schema: 1
last_synced_commit: ""
---

# Lists

Named groupings of tasks. Each user has at least one list ("Inbox") that
cannot be deleted. Lists can be created, renamed, deleted, reordered,
and (eventually) shared.

## Features

| Feature | Kind | Path |
|---------|------|------|
| Manage lists (drawer + CRUD) | UI | [manage.md](manage.md) |

## Cross-module dependencies

- The active list ID drives [Tasks/list-view](../tasks/list-view.md)'s
  filter; reading `active_list_id` from `lists_store`.
- Deleting a list reassigns its tasks to Inbox (server-side); the UI
  must refresh task views after a list deletion.
- All operations require an active session (see `Auth`).
