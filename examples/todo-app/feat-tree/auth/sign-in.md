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
Successful sign-in lands the user on their default task list.

## Wireframe

```
┌──────────────────────────────┐
│ ←                            │
│                              │
│        TodoApp               │
│                              │
│   Welcome back               │
│                              │
│   ┌──────────────────────┐   │
│   │ email                │   │
│   └──────────────────────┘   │
│   ┌──────────────────────┐   │
│   │ password         👁  │   │
│   └──────────────────────┘   │
│   [ ] remember me            │
│                              │
│   [      Sign in       ]     │
│                              │
│   forgot password?           │
│   no account? Sign up        │
└──────────────────────────────┘
```

## Entry points

- Tap "Sign in" on the landing screen
- Auto-redirect from any authenticated route when no valid token
- Deep link `todoapp://auth/sign-in?redirect=<path>`

## Layout

Top → bottom:

1. Back button (top-left)
2. Logo + welcome heading
3. Email field
4. Password field with visibility toggle
5. Remember-me checkbox (left-aligned, below password)
6. Sign in button (full-width, primary)
7. Forgot-password link
8. Sign-up link

## Interactions

1. **Email field**
   - Validates on blur with regex `^[^@]+@[^@]+\.[^@]+$`
   - Inline error below field on invalid
2. **Password visibility toggle (👁)**
   - Tap toggles plaintext / masked
   - Resets to masked on focus loss
3. **Remember-me checkbox**
   - When checked, token persists across app restart
   - Default off
4. **Sign in button**
   - Disabled until both email and password are non-empty AND email valid
   - On tap: spinner replaces label, fields disabled
   - On 200 response: navigate to `redirect` query param if present, else
     default task list
   - On 401: error toast "Email or password incorrect", fields re-enabled
   - On network error: offline banner shown above the form
5. **Forgot password link**
   - Navigates to [Password reset](password-reset/index.md) — *(not
     documented in this example)*
6. **Sign up link**
   - Navigates to [Sign up](sign-up.md)

## Logic

- Calls `AuthService.signIn(email, password)`
- On success: writes `{ access_token, refresh_token, user }` to
  `auth_state`. If "remember me" is on, also writes to platform keychain.
- Emits `auth.signed_in` event on the app event bus.

## State

| State | Trigger | UI effect |
|-------|---------|-----------|
| idle | initial | empty form, button disabled |
| validating | typing | inline error if invalid email |
| ready | both fields valid + non-empty | button enabled |
| submitting | tap submit | spinner, fields disabled |
| error | API 401 | error toast; revert to ready |
| offline | network error | offline banner; revert to ready when online |
| success | API 200 | navigate away |

## Animation

- Button scale 1.0 → 0.95 on press, 100ms ease-out
- Error toast slides down from top, 200ms ease-out, auto-dismiss after 3s
- Page transition: standard platform push from landing

## Cross-feature links

- → [Sign up](sign-up.md) (sign-up link)
- ← [Landing](../onboarding/landing.md) *(not in this example)*
- → [Default task list](../tasks/list-view.md) *(post-success target)*

## Edge cases

- Both fields empty + tap Sign in: button is disabled, no-op
- Network offline at submit time: do not retry automatically; banner
  invites user to retry
- Token returned but `user` payload missing: treat as 5xx, retry once
- "Remember me" without keychain support (older platform): hide the
  checkbox entirely

## Related code

- `lib/features/auth/sign_in_page.dart` — UI tree, validation
- `lib/features/auth/sign_in_controller.dart` — state machine
- `lib/api/auth_service.dart` — `signIn()` HTTP call
