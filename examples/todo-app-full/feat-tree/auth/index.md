---
type: og-module
module: auth
schema: 1
last_synced_commit: ""
---

# Auth

Sign-in, sign-up, and sign-out flows. Inferred from the `lib/features/auth/`
directory and the routes referenced in `lib/router.dart`.

> **Full-mode init note**: feature descriptions below were generated
> from a one-shot scan and are unverified. Treat them as a starting
> point; correct anything wrong before bumping any L3 doc's SHA.

## Features

| Feature | Kind | Description | Status |
|---------|------|-------------|--------|
| [sign-in](sign-in.md) | UI | Email + password sign-in screen | unverified (full-mode draft) |
| [sign-out](sign-out.md) | logic | Clear session and route to landing | unverified (full-mode draft) |

## Module-level invariants

- A user is either signed in (has a non-expired access token) or signed
  out — no partial states. *(Inferred from `auth_state.dart`'s sealed
  state class; please confirm.)*
- All authenticated routes are guarded by `AuthGuard` declared in
  `lib/router.dart`. *(Could not determine whether the guard handles
  token refresh or only checks presence — TODO during review.)*

## Cross-module dependencies

- `tasks/` — post-sign-in target route (default task list). Inferred
  from `_redirectAfterSignIn()` in `sign_in_controller.dart`.
- `lib/api/auth_service.dart` — backend client used by all features in
  this module.
