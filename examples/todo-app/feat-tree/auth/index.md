---
type: og-module
module: auth
schema: 1
last_synced_commit: ""
---

# Auth

Sign-in, sign-up, and sign-out for the todo app. Uses email + password
with optional "remember me". Session refresh handled implicitly by the
storage layer; no dedicated refresh feature in this app.

## Features

| Feature | Kind | Path |
|---------|------|------|
| Sign in | UI | [sign-in.md](sign-in.md) |
| Sign up | UI | [sign-up.md](sign-up.md) |
| Sign out | Logic | [sign-out.md](sign-out.md) |

## Cross-module dependencies

- After Sign in, `Tasks` and `Lists` become accessible. The `auth_state`
  store is read by both modules' entry points.
- Sign out clears local task and list caches (writes are by Tasks/Lists,
  reads here).

## Module-level invariants

- All authenticated requests carry `Authorization: Bearer <token>` from
  `auth_state`.
- Tokens are never persisted in plaintext; storage uses platform keychain.
