# Add refresh-token support for the stories server

| Field | Value |
|---|---|
| **Slug** | `refresh-token-for-stories-server` |
| **Stage** | `intake` (not started) |
| **Owner** | helalmoamad |
| **Created** | 2026-08-15 |
| **ClickUp** | _(fill in after the task is created)_ |
| **GitHub** | _(fill in at delivery)_ |

---

## Goal

When the stories server rejects a request with 401, the app must exchange the
stored stories refresh token for a new token pair, the same way the market and
chat servers already do. Today the stories token is only cleared, so the user
silently loses access to stories until something else logs them in again.

---

## Context

### What happens today

`lib/core/api/log_interceptor.dart:242-244` handles a stories 401 like this:

```dart
if (isFrom('STORY_URL')) {
  _prefsRepository.setStoriesToken("");
}
```

It clears the token and stops. Nothing re-authenticates. Compare with the two
servers that do it properly:

| Server | On 401 | Handler |
|---|---|---|
| market | `RefreshTokenEvent` | `auth_bloc.dart:1091` |
| chat | `RefreshChatTokenEvent` | `auth_bloc.dart:1130` |
| **stories** | **clears the token only** | **none** |

### The endpoint exists and works

Confirmed by hand in Postman:

```
POST {{story_base_url}}/api/v1/auth/refresh-token
Content-Type: application/json

{ "refresh_token": "<stored refresh token>" }
```

`200 OK` returns a new pair. The body carries both a nested object
(`accessToken` / `refreshToken`) and top-level snake_case fields
(`access_token` / `refresh_token`). The existing stories model already reads the
top-level snake_case form, so the response shape is compatible.

The path `api/v1/auth/refresh-token` is exactly what
`MarketEndPoints.refreshTokenEP` builds (`'refresh-token'.authScope()` in
`lib/common/constant/configuration/market_url_routes.dart:13,142`). The chat
refresh already reuses that same constant against `ServerName.chat`.

### What is missing

1. **No storage key.** `lib/common/constant/configuration/prefs_key.dart:46` has
   `storiesToken` but no `storiesRefreshToken`. The market and chat keys are at
   lines 42 and 44.
2. **The model drops the field.** `LoginToStoriesResponseModel` parses only
   `json["access_token"]`
   (`lib/features/authentication/data/models/login_to_stories_response_model.dart:119`).
   The refresh token in the login response is thrown away.
3. **No refresh path.** There is no `RefreshStoriesTokenEvent`, no handler, no
   use case, and no data-source method.
4. **The interceptor clears instead of refreshing** (see above).

### Reference implementation

The chat path is the closest model to copy:

- event + throttle — `auth_bloc.dart:101-104` (`throttleDroppable(10s)`)
- handler — `auth_bloc.dart:1130-1167`
- use case — `lib/features/authentication/domain/use_cases/refresh_chat_token_usecase.dart`
- data source — `auth_remote_datasource.dart:318-334`
- token lookup per server — `lib/core/api/methods/detect_server.dart:84-85`

---

## Protected runtime paths

This ticket touches protected runtime paths, so `plan.md` must list every one of
them before `/wf:implement` may run:

- `lib/features/authentication/**` — auth and session
- `lib/core/api/log_interceptor.dart` — API and network
- `lib/core/data/repository/prefs_repository_impl.dart`
- `lib/core/domin/repositories/prefs_repository.dart`
- `lib/common/constant/configuration/prefs_key.dart`
- `**/*.g.dart` — generated code (regenerate with `sh gen.sh`, never hand-edit)

---

## Acceptance criteria

- **AC-1** — A new secure-storage key `PrefsKey.storiesRefreshToken` exists, with
  `setStoriesRefreshToken` / `getStoriesRefreshToken` on `PrefsRepository` and its
  implementation, following the chat pair exactly
  (`prefs_repository_impl.dart:92-102`).
- **AC-2** — `LoginToStoriesResponseModel` exposes a `refreshToken` field parsed
  from `refresh_token`, and the generated serializer is in sync (no git diff after
  `sh gen.sh`).
- **AC-3** — A successful stories login stores the returned refresh token, next to
  the access token already stored at `auth_bloc.dart:559`.
- **AC-4** — A 401 from the stories server dispatches a stories refresh instead of
  clearing the token. `setStoriesToken("")` is no longer the response to a stories
  401 in `log_interceptor.dart`.
- **AC-5** — The refresh sends `POST api/v1/auth/refresh-token` to
  `ServerName.stories` with body `{"refresh_token": "<stored token>"}`.
- **AC-6** — On success, both stored values are replaced with the returned pair
  (single-use rotation): the new access token and the new refresh token.
- **AC-7** — When no refresh token is stored, or the refresh is rejected with 401,
  the app falls back to `LoginToStoriesEvent` (re-login to stories). It must **not**
  fall back to a new guest session — stories access is derived from the market
  session, which is untouched by a stories failure.
- **AC-8** — A failure that is not 401 (500, timeout, no network) leaves both
  stored tokens untouched and does not log the user out.
- **AC-9** — Concurrent 401s from the stories server produce at most one refresh
  request, using the same `throttleDroppable(Duration(seconds: 10))` as the market
  and chat refresh events.
- **AC-10** — `flutter analyze` passes with no new findings.

---

## Test cases

| # | Covers | Precondition | Action | Expected result |
|---|---|---|---|---|
| TC-1 | AC-1 | App installed, user logged in to stories | Read secure storage for `PrefsKey.storiesRefreshToken` | The key exists and holds a non-empty value |
| TC-2 | AC-2 | Clean working tree | Run `sh gen.sh`, then `git diff --exit-code` | Exit code 0 — the generated file matches the source |
| TC-3 | AC-3 | Logged out of stories | Trigger `LoginToStoriesEvent` and let it succeed | Both the access token and the refresh token are stored |
| TC-4 | AC-4, AC-5 | A valid stories refresh token is stored | Corrupt the stored stories **access** token, then open the stories screen | The request gets 401, and one `POST api/v1/auth/refresh-token` is sent to the stories base URL with the stored refresh token in the body |
| TC-5 | AC-6 | Same as TC-4 | Let the refresh return 200 | Stored access token and refresh token both differ from the previous values, and the retried stories request succeeds |
| TC-6 | AC-7 | Clear the stored stories refresh token | Corrupt the access token and open the stories screen | The app dispatches `LoginToStoriesEvent`; the market session and the market tokens are unchanged |
| TC-7 | AC-7 | A stale (already rotated) refresh token is stored | Open the stories screen so the refresh is rejected with 401 | The app dispatches `LoginToStoriesEvent`; no guest session is registered |
| TC-8 | AC-8 | A valid refresh token is stored, stories server unreachable | Turn off the network, open the stories screen | Both stored tokens are unchanged, the user stays logged in, and no crash or logout occurs |
| TC-9 | AC-9 | A valid refresh token is stored, access token corrupted | Open a screen that fires five stories requests at once | Exactly one refresh request is sent |
| TC-10 | AC-10 | Changes applied | Run `flutter analyze` | Exit code 0 |

---

## Validation strategy

Use the `codegen-change` profile from `.claude/project-config.yaml` — the model
change regenerates `*.g.dart`, so `build-runner-clean` must pass before
`flutter-analyze`.

---

## Risks and unknowns

- **Blast radius of the fallback.** AC-7 deliberately differs from the chat path.
  A chat refresh failure drops the whole session and registers a new guest
  (`_fallBackToNewGuestSession`, `auth_bloc.dart:1187`). That is too wide for
  stories. Confirm this choice at the review gate.
- **Endpoint constant.** The chat refresh reuses `MarketEndPoints.refreshTokenEP`.
  Reusing it again for stories keeps the code short but ties the stories path to
  the market's `_api` / `_currentVersion` values — if the market version is
  bumped, the stories refresh path changes silently. The plan should decide
  between reusing it and adding a stories-owned constant.
- **Does the stories login always return a refresh token?** The Postman check
  covered the refresh endpoint. Confirm during `/wf:research` that the
  login-to-stories response carries `refresh_token` too; if it does not, AC-3
  needs a different source for the first token.
- **QR login and manual token writes.** `lib/features/app/user_info_page.dart:63`
  and `lib/features/authentication/presentation/pages/qr_login_scanner_page.dart`
  set the stories token outside the normal login flow. Check whether they must
  also carry a refresh token.

---

## Out of scope

- The market and chat refresh paths — their behaviour is unchanged.
- The existing silent handling of non-401 failures in the market and chat refresh
  handlers.
- The wallet and comment servers, which still only clear their tokens on 401.
