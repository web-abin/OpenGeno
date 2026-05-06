---
type: og-feature
kind: logic
feature: sign-out
module: auth
schema: 1
code:
  - lib/features/auth/sign_out.dart
  - lib/api/auth_service.dart
last_synced_commit: ""
last_reviewed: 2026-05-06
---

# Sign out

Clear local session and return to the landing screen. No dedicated UI —
triggered from the profile menu.

## Triggers

- Tap "Sign out" in the profile drawer
- 401 response on any authenticated API call (forced sign-out)
- Receipt of `auth-expired` event from token-refresh failure

## Inputs

- Current `auth_state` (token + user)

## Outputs

- `auth_state` cleared
- Keychain entry deleted (if present)
- Local task / list caches cleared
- Navigate to [Landing](../onboarding/landing.md) *(not in this example)*

## Logic flow

1. Best-effort POST `/auth/sign-out` (server-side token revocation)
   - Do NOT block on this; if it times out, continue local cleanup
2. Clear `auth_state`
3. Delete keychain entry
4. Emit `auth.signed_out` event — Tasks and Lists modules listen and
   clear their caches in response
5. Navigate root to landing

## State

No local state machine.

## Failure modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Server-side sign-out 5xx | API error | Continue local cleanup; user is still signed out client-side |
| Server-side sign-out timeout | 5s timeout | Same as above |
| Keychain delete fails | OS error | Log; continue (best effort) |

## Invariants

- After this runs, no authenticated request can succeed because the
  in-memory token is gone, regardless of whether the server-side
  revocation succeeded.

## Cross-feature links

- ← Profile menu *(not in this example)* — primary trigger
- → [Landing](../onboarding/landing.md) — post-cleanup target
- Listened to by: [Tasks/list-view](../tasks/list-view.md), [Lists/manage](../lists/manage.md) — they clear caches on `auth.signed_out`

## Related code

- `lib/features/auth/sign_out.dart`
- `lib/api/auth_service.dart` — `signOut()` HTTP call
