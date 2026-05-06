---
type: og-feature
kind: ui
feature: sign-up
module: auth
schema: 1
code:
  - lib/features/auth/sign_up_page.dart
  - lib/features/auth/sign_up_controller.dart
  - lib/api/auth_service.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Sign up

Email + password account creation. Lands on the empty default task list
on success.

## Wireframe

```
┌──────────────────────────────┐
│ ←                            │
│                              │
│        TodoApp               │
│                              │
│   Create your account        │
│                              │
│   ┌──────────────────────┐   │
│   │ email                │   │
│   └──────────────────────┘   │
│   ┌──────────────────────┐   │
│   │ password         👁  │   │
│   └──────────────────────┘   │
│   [strength: ███░░]          │
│                              │
│   [    Create account    ]   │
│                              │
│   already have an account?   │
│   Sign in                    │
└──────────────────────────────┘
```

## Entry points

- Tap "Sign up" on landing
- Tap "no account? Sign up" on [Sign in](sign-in.md)

## Layout

Same skeleton as Sign in, plus a password-strength meter under the
password field. No "remember me" checkbox.

## Interactions

1. **Email field** — same validation rules as Sign in
2. **Password field** with visibility toggle
3. **Password strength meter** — recomputed on every keystroke
   - Levels: weak (red), medium (yellow), strong (green)
   - "Create account" button disabled if level is weak
4. **Create account button**
   - Disabled until email valid + password ≥ medium
   - On tap: spinner, fields disabled
   - On 200: auto sign-in (token stored same as Sign in success), navigate
     to default task list
   - On 409 (email taken): error toast "Email already in use",
     suggest [Sign in](sign-in.md)
   - On other errors: same as Sign in
5. **"Sign in" link** — navigate to [Sign in](sign-in.md)

## Logic

- Calls `AuthService.signUp(email, password)`
- Server returns `{ access_token, refresh_token, user }` directly on success
  (no separate sign-in step needed)
- Emits `auth.signed_up` event, then `auth.signed_in`

## State

Same shape as Sign in, with one extra state:

| State | Trigger | UI effect |
|-------|---------|-----------|
| email-taken | API 409 | error toast with "Sign in instead" CTA |

## Animation

Same as Sign in.

## Cross-feature links

- → [Sign in](sign-in.md) ("already have an account?" link, and 409 CTA)
- → [Default task list](../tasks/list-view.md) (post-success)
- ← [Landing](../onboarding/landing.md) *(not in this example)*

## Edge cases

- Server-side blocked domain: API 422 with reason → inline error
- Disposable-email domain detected: warn but allow (server's call)
- Weak password but user pastes (skipping keystroke validation): meter
  still recomputes on any change event including paste

## Related code

- `lib/features/auth/sign_up_page.dart`
- `lib/features/auth/sign_up_controller.dart`
- `lib/api/auth_service.dart` — `signUp()`
