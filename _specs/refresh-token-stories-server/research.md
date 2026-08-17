---
ticket: refresh-token-stories-server
stage: research
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: ai_agent
updated: 2026-08-16
links:
  clickup:
  github:
---

# Research — refresh-token-stories-server

> Read-only phase. **No implementation is allowed in this command.**

## Goal

When a request to the stories server fails with `401`, the app should get a new
stories access token by itself and send the request again — the same way the
market and chat servers already do — so the user is never sent back to login.

## What the code does today

This section records the current behaviour, because the ticket asks to "follow
the same way" as chat and market.

**Market and chat (the model to copy).** In
`lib/core/api/log_interceptor.dart:240` (`_handleUnauthorizedError`):

1. A `401` is detected from the HTTP status code, with the response body as a
   fallback for servers that answer `200` with an error envelope.
2. A request that was already replayed once is skipped, using the
   `wf_retried_after_refresh` flag in `RequestOptions.extra`
   (`log_interceptor.dart:24`). This stops an endless refresh loop.
3. The failing path is matched against the server base URLs in `.env`
   (`isFrom('CHAT_URL')`, `isFrom('MARKET_URL')`, …).
4. `TokenRefreshCoordinator.instance.refresh(scope, start)`
   (`lib/core/api/token_refresh_coordinator.dart:38`) dispatches the AuthBloc
   refresh event and **waits** for its result. Requests that fail at the same
   time share one refresh.
5. `AuthBloc._onRefreshTokenEvent` / `_onRefreshChatTokenEvent`
   (`lib/features/authentication/presentation/manager/auth_bloc.dart:1092` and
   `:1139`) read the stored refresh token from secure storage, call
   `POST /api/v1/auth/refresh-token`, store the **new pair** (access + refresh,
   because the refresh token is single use), and then call
   `TokenRefreshCoordinator.instance.complete(scope, refreshed)`.
6. Back in the interceptor, `_retryWithFreshToken`
   (`log_interceptor.dart:321`) puts the new bearer token on the stored request
   options, clones a `FormData` body if there is one, marks the request as
   retried, and sends it again. The caller gets the real answer and never sees
   the `401`.

**Stories (what exists now).** The stories server has **no refresh path at all**:

- `log_interceptor.dart:270` — on a `401` from `STORY_URL` the code only calls
  `_prefsRepository.setStoriesToken("")` and falls through. Nothing asks for a
  new token, and the failing request is not replayed.
- `LoginToStoriesResponseModel.Data`
  (`lib/features/authentication/data/models/login_to_stories_response_model.dart:64`)
  has `access_token` only. **There is no `refresh_token` field.**
- `PrefsKey` (`lib/common/constant/configuration/prefs_key.dart`) has
  `marketRefreshToken` (line 42) and `chatRefreshToken` (line 44). There is no
  stories refresh-token key, and `PrefsRepository`
  (`lib/core/domin/repositories/prefs_repository.dart:137-143`) has no
  stories getter/setter pair.
- `RefreshScope` (`token_refresh_coordinator.dart:7`) has two values only:
  `market` and `chat`.
- The only way the app gets a stories token today is a full login:
  `AuthBloc._onLoginToStoriesEvent` (`auth_bloc.dart:517`) calls
  `StoriesEndPoints.loginEP` (`POST /api/v1/users/login`) with `phone`, `name`,
  `otpIdToken` and `originalUserId`, then stores the access token.

## Relevant directories

- `lib/core/api/` — the network layer. `log_interceptor.dart` owns the whole
  `401` path (detect, refresh, replay). `token_refresh_coordinator.dart` holds
  the `RefreshScope` enum and collapses concurrent refreshes.
  `methods/detect_server.dart` maps `ServerName.stories` to its base URI and to
  `prefsRepository.storiesToken`. `base_api.dart` puts the bearer token on every
  request when it is built.
- `lib/features/authentication/presentation/manager/` — `auth_bloc.dart` holds
  the refresh handlers and the stories login handler; `auth_event.dart` and
  `auth_state.dart` hold the events and the status flags
  (`LoginToStoriesStatus`).
- `lib/features/authentication/domain/use_cases/` — `refresh_token_usecase.dart`
  and `refresh_chat_token_usecase.dart` are the shape a stories refresh use case
  would copy; `login_to_stories_usecase.dart` is the current stories entry point.
- `lib/features/authentication/data/` — `data_sources/auth_remote_datasource.dart`
  (`refreshToken`, `refreshChatToken`, `loginToStories`),
  `repositories/auth_repository_impl.dart`, and the response models.
- `lib/core/data/repository/prefs_repository_impl.dart` +
  `lib/core/domin/repositories/prefs_repository.dart` — token storage. Refresh
  tokens live in `FlutterSecureStorage`, access tokens in normal prefs.
- `lib/features/story/` — the feature that uses the stories token
  (`StoryBloc`, story upload, story lists).

## Relevant config files

- `.env` — `STORY_URL`, `MARKET_URL`, `MARKETGo_URL`, `CHAT_URL`,
  `MEDIA_SERVER_URL`. The interceptor decides which server rejected a request by
  matching the failing path against these values. Protected runtime path.
- `lib/common/constant/configuration/stories_url_routes.dart` — `StoriesUrls`
  (base URI from `STORY_URL`) and `StoriesEndPoints`. A refresh endpoint for
  stories would be declared here.
- `lib/common/constant/configuration/prefs_key.dart` — storage keys; a
  `storiesRefreshToken` key would go here. Protected runtime path.
- `lib/core/di/di_container.dart` and the generated
  `lib/core/di/di_container.config.dart` — every use case is registered here. The
  generated file must be regenerated, never hand-edited.
- `analysis_options.yaml`, `pubspec.yaml` — lints and dependencies.

## Possibly affected services

- **Stories server (`STORY_URL`)** — the target. It would receive a new call
  (a refresh call, or a second login call).
- **Market / marketGO / media server** — they share `_handleUnauthorizedError`
  with stories, and the `STORY_URL` check runs **before** the market branch and
  does not `return`. Any change to the order or to the early exits in that method
  can change what happens on a market `401`.
- **Chat server** — shares the same method and the same
  `TokenRefreshCoordinator`. Adding a value to `RefreshScope` touches a file
  chat depends on.
- **AuthBloc** — an app-wide singleton registered in DI and in
  `ServiceProvider`. A new event and handler is added to a bloc every feature
  uses.
- **Story feature and notifications** — `StoryBloc` and the upload flow read the
  stories token; `_onLoginToStoriesEvent` also triggers `GetStoryEvent` and a FCM
  token update as side effects.
- **Logout / session reset** — `base_page.dart:977` and
  `auth_bloc.dart:1258` clear the stories token. A new stored refresh token must
  be cleared in the same places, or a logged-out user keeps a valid refresh
  token.

## Test / validation commands available

Listed only — none were run.

- `flutter analyze` — static analysis and lints for the whole app.
- `flutter test` — runs the unit tests. The repository has only one test today
  (`test/core/json_size_cap_test.dart`), so this is a weak gate.
- `dart format --output=none --set-exit-if-changed lib` — formatting check.
- `./gen.sh` — `build_runner`; regenerates `*.g.dart` and
  `lib/core/di/di_container.config.dart` after a DI or model change.
- `./keys.sh` — regenerates `lib/generated/locale_keys.g.dart` if a translation
  key is added.
- `flutter run` / `flutter build apk --debug` — manual check on a device. The
  acceptance criterion ("a request that fails with 401 gets a new access token")
  can only be proven end to end this way, or by forcing an expired stories token.

## Risks and unknowns

- **The backend may not support this at all** — high impact, unknown
  likelihood. The stories login response has no `refresh_token` field, and no
  refresh endpoint for stories exists anywhere in the code. If the stories server
  does not expose one, the ticket cannot be built as written and would become a
  silent re-login instead. This decides the whole approach (see OQ-1, OQ-2).
- **Blast radius on the shared 401 handler** — high impact. Stories, market,
  marketGO, media server, chat, wallet and comment all pass through
  `_handleUnauthorizedError`. The stories branch today does not `return`;
  making it wait for a refresh and return a token changes control flow that
  market requests also travel through.
- **Logging the user out because of a stories token** — high impact. The market
  and chat handlers call `_fallBackToNewGuestSession()` when the refresh is
  rejected, which starts a new guest session and can raise the "session expired"
  dialog. Copying that behaviour for stories would let a stories problem reset
  the market session. This needs an explicit decision (OQ-4).
- **Protected runtime paths** — every file this ticket would touch is protected
  by `CLAUDE.md`: `lib/core/api/**`, `lib/features/authentication/**`,
  `prefs_repository*`, `prefs_key.dart`, `.env`, and the generated DI config.
  Nothing may be changed before an approved plan lists it.
- **The baseline is uncommitted work** — medium impact.
  `lib/core/api/token_refresh_coordinator.dart` is untracked, and
  `log_interceptor.dart` plus `auth_bloc.dart` have uncommitted changes on
  `dev_new`. This ticket builds on code that is not merged yet (OQ-6).
- **Retry loops** — medium impact. The `wf_retried_after_refresh` guard is the
  only thing that stops a rejected token from refreshing forever. It must stay,
  and the stories path must respect it.
- **Multipart replay** — medium impact. Story upload
  (`stories/upload_story`) sends `FormData`, which can be read only once.
  `_retryWithFreshToken` clones it, but the interceptor also has a separate rule
  that marks a story upload as failed on any error
  (`log_interceptor.dart:105`). The two rules can disagree on a `401`.
- **Generated code** — low impact, easy to get wrong. A new use case needs
  `./gen.sh`; the `.config.dart` must never be hand-edited.

## Open questions

> Give each question a stable ID (`OQ-1`, `OQ-2`, …). `spec.md` must record an
> answer for every one of them (SP-9) — an answer given only in chat does not
> count. A question about touching `observability/**` is answered by putting the
> path in scope (then `plan.md > Files to change`) or by putting it Out of Scope.

| ID    | Question | Why it matters |
|-------|----------|----------------|
| OQ-1  | Does the stories server expose a refresh-token endpoint? What is its path, request body and response shape? | Without it there is nothing to call. It decides the whole design. |
| OQ-2  | Does the stories login (`POST /api/v1/users/login`) already return a refresh token that the app just ignores, or must the backend change first? | `LoginToStoriesResponseModel` has `access_token` only, so today the app has no refresh token to store for stories. |
| OQ-3  | If there is no refresh endpoint, is a silent re-login (call the stories login again with the stored phone / name / otpIdToken / originalUserId) an accepted answer for this ticket? | It is the only other way to get a new stories token with the code that exists. It changes the spec wording from "refresh" to "renew". |
| OQ-4  | When a stories refresh fails, what should happen? Market and chat call `_fallBackToNewGuestSession()`, which can reset the market session and show "session expired". Should stories do the same, or stay local (clear the stories token, report the error) and never touch the market session? | This is the biggest blast-radius decision in the ticket. |
| OQ-5  | Where should the stories refresh token be stored — secure storage under a new `PrefsKey.storiesRefreshToken`, like market and chat? And which places must clear it (logout at `base_page.dart:977`, `auth_bloc.dart:1258`)? | Adding a stored secret needs the write and the clear paths decided together, or a logged-out user keeps a working token. |
| OQ-6  | Is the uncommitted `token_refresh_coordinator.dart` (plus the uncommitted `log_interceptor.dart` / `auth_bloc.dart` changes) the baseline for this ticket, or must the ticket work without them? | The whole "wait for the refresh, then replay" mechanism lives in that untracked file. |
| OQ-7  | Which stories calls are in scope: only plain requests, or also the seller-stories endpoints and the multipart story upload (`stories/upload_story`)? | The upload path has its own failure handling in the interceptor and a single-use body, so it needs its own decision. |
| OQ-8  | May this ticket change the branch order in `_handleUnauthorizedError` (give stories an early `return` like chat does)? | Today the `STORY_URL` branch falls through into the market branch. Fixing that is a change market requests also feel. |
| OQ-9  | What should the user see while the refresh is running? The user story says "session remains uninterrupted" — does that mean no loading state and no message at all? | It sets the testable part of the acceptance criteria for the UI. |
| OQ-10 | How will this be verified, given the app has almost no tests? Is a manual check on a device with a forced-expired stories token the accepted evidence? | `flutter test` cannot prove the acceptance criterion today. |

## Notes

- No code was changed during research.
- No observability runtime configs were modified.
