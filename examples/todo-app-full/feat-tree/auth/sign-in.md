---
type: og-feature
kind: ui
feature: sign-in
module: auth
schema: 1
code:
  - lib/features/auth/sign_in_page.dart
  - lib/features/auth/sign_in_controller.dart
  - lib/api/auth_service.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Sign in

Email + password sign-in screen. Entry point for returning users.
Routes to the default task list on success.

> **Full-mode init draft.** Generated from a one-shot read of the page
> and controller files. Section bodies below are best-effort. Each
> section has a confidence note at the bottom; review against current
> code before bumping `last_synced_commit`.

## Wireframe

待补充 — wireframes can't be inferred from code alone. Sketch by hand
or screenshot the running screen during review.

## Entry points

- Tap "Sign in" on the landing screen *(inferred from
  `landing_page.dart`'s navigation call)*
- Auto-redirect from authenticated routes when no valid token *(inferred
  from `AuthGuard` in `lib/router.dart`)*
- Deep link route — TODO: confirm the URL scheme; not visible in the
  files scanned at init

## Layout

Top → bottom, based on the widget tree in `sign_in_page.dart`:

1. Back button (`AppBar.leading`)
2. Logo + welcome heading (`_HeaderWidget`)
3. Email field (`TextFormField` with email keyboard)
4. Password field (`TextFormField` with `obscureText: true`)
5. Remember-me checkbox *(visible in the build method, exact placement
   uncertain — confirm during review)*
6. Sign in button (`FilledButton`, full-width)
7. Forgot-password link (`TextButton`)
8. Sign-up link (`TextButton`)

## Interactions

1. **Email field** — validates on blur. Regex used:
   `^[^@]+@[^@]+\.[^@]+$` *(literal from `sign_in_controller.dart`)*.
2. **Password visibility toggle** — TODO: not seen in scanned files;
   may be in a shared widget. Confirm during review.
3. **Remember-me checkbox** — flips a boolean in the controller; effect
   on token persistence inferred but not verified.
4. **Sign in button**
   - Disabled until both fields are non-empty *(seen in the controller's
     `canSubmit` getter)*
   - On tap: calls `AuthService.signIn(email, password)`
   - Success/failure handling: TODO — error mapping (toast vs inline)
     not fully traced
5. **Forgot password / Sign up links** — navigate to sibling routes;
   exact target routes not confirmed

## Logic

- Calls `AuthService.signIn(email, password)` (file: `lib/api/auth_service.dart`)
- On success: writes `{ access_token, refresh_token, user }` to
  `auth_state` *(inferred from `_onSuccess` handler)*
- 待补充 — keychain / secure-storage behavior is referenced in the
  controller but the exact persistence rules need verification

## State

| State | Trigger | UI effect |
|-------|---------|-----------|
| idle | initial | empty form, button disabled |
| ready | both fields filled | button enabled |
| submitting | tap submit | TODO: confirm spinner / disabled-fields behavior |
| error | API failure | TODO: confirm error display |
| success | API 200 | navigate away |

*(State names taken from the controller's enum; transition triggers and
UI effects are partially inferred.)*

## Animation

待补充 — animation specs (durations, curves) are in the design system,
not in the page file. Fill in during review with reference to the
design source.

## Cross-feature links

- → [Sign up](sign-up.md) — *not in this demo tree, but linked from the
  page*
- → [Default task list](../tasks/list-view.md) — *post-success target;
  module not generated in this demo*
- ← Landing page — *referenced from outside the auth module*

*(Linked-to docs would normally need their incoming-link sections
updated too; skipped here because this is a one-module demo.)*

## Edge cases

- Empty fields + tap Sign in: button is disabled, no-op *(visible in
  `canSubmit` logic)*
- 待补充 — offline behavior, token-but-no-user response, keychain
  unavailable, etc. — these need code reading or product decisions
  the init pass can't make alone

## Related code

- `lib/features/auth/sign_in_page.dart` — UI tree
- `lib/features/auth/sign_in_controller.dart` — state machine and
  submit logic
- `lib/api/auth_service.dart` — `signIn()` HTTP call
