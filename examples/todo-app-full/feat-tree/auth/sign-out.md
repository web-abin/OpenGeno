---
type: og-feature
kind: logic
feature: sign-out
module: auth
schema: 1
code:
  - lib/features/auth/sign_out_action.dart
  - lib/state/auth_state.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Sign out

Clear the local session and route the user back to the landing screen.

> **Full-mode init draft.** Generated from a read of `sign_out_action.dart`
> and `auth_state.dart`. Sections below are best-effort; review before
> bumping `last_synced_commit`.

## Triggers

- User taps "Sign out" in the profile menu *(inferred — the action is
  imported by `profile_menu.dart`)*
- 待补充 — session expiry / forced sign-out path: a `forceSignOut()`
  function exists in `auth_state.dart` but its callers were not all
  traced during init

## Inputs

- None directly. Reads `auth_state` to determine current token for the
  optional server-side revocation call.

## Outputs

- Side effects:
  - Clears `auth_state` (in-memory)
  - Removes tokens from secure storage *(inferred — call to
    `SecureStorage.delete()` visible in `signOut()`)*
  - Best-effort POST to `/auth/revoke` — fire-and-forget, doesn't block
    UI on failure *(inferred from `try/catch` swallowing errors)*
- Returns: `void` (or a `Future<void>` — confirm during review)

## Flow

1. Snapshot the current refresh token (if any) for the revoke call.
2. Clear `auth_state` immediately so the UI updates.
3. Delete tokens from secure storage.
4. Fire the revoke request in the background; ignore failures.
5. Navigate to the landing route.

*(Order of steps 2–4 is the rough shape from the code; exact order may
differ. Verify during review.)*

## Failure modes

- Revoke endpoint unreachable / 5xx — intentionally swallowed; user is
  still signed out locally. *(Confirm this is the desired product
  behavior, not just what the code currently does.)*
- Secure storage delete fails — TODO: not handled visibly in the code;
  flag for product/security review

## Invariants

- After this action returns, `auth_state.isSignedIn == false`.
- Local tokens are gone regardless of network outcome.
- 待补充 — any other invariants (e.g. clearing user-scoped caches,
  closing websockets) are not visible in the scanned files; confirm
  during review.

## Cross-feature links

- ← Profile menu — caller *(not in this demo tree)*
- → Landing page — post-sign-out destination

## Related code

- `lib/features/auth/sign_out_action.dart` — the action implementation
- `lib/state/auth_state.dart` — `clear()` and `forceSignOut()`
