---
ticket: refresh-token-stories-server
stage: implement
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-16
links:
  clickup:
  github:
---

# Implement — refresh-token-stories-server

> Record of what was actually built, following `plan.md`.

## Gate note

This implement stage ran **without a recorded `/review` decision**. The
comprehension gate failed twice (`comprehension.md`, `decision: none`), so the
`review` stage never reached `APPROVED`. The owner directed the work to proceed
anyway, outside the `wf` plugin. The change follows the approved-in-content
`plan.md` step for step; only the gate record is missing. The `/review` gate
still has to be re-run and recorded before this ticket is delivered.

## Changes prepared (uncommitted)

> `/implement` creates **no commit** (IM-9 / ADR-008); there are no SHAs to
> record here.

- `lib/common/constant/configuration/stories_url_routes.dart` — added an
  `authScope()` helper to the `ScopeApi` extension and a stories-owned
  `StoriesEndPoints.refreshTokenEP` (`/api/v1/auth/refresh-token`). (step 2)
- `lib/common/constant/configuration/prefs_key.dart` — added
  `storiesRefreshToken`, beside `marketRefreshToken` and `chatRefreshToken`.
  (step 3)
- `lib/core/domin/repositories/prefs_repository.dart` — declared
  `setStoriesRefreshToken` / `getStoriesRefreshToken`. (step 3)
- `lib/core/data/repository/prefs_repository_impl.dart` — implemented both
  against secure storage, copying the chat pair. (step 3)
- `lib/features/authentication/data/models/login_to_stories_response_model.dart`
  — added `refreshToken` to `Data`, parsed from and written to `refresh_token`
  (constructor, `copyWith`, `fromJson`, `toJson`). Hand-written model, so no
  generator runs for this file. (step 4)
- `lib/features/authentication/data/data_sources/auth_remote_datasource.dart` —
  added `refreshStoriesToken`, posting to `ServerName.stories` with the new
  endpoint and reusing `LoginToStoriesResponseModel` for the answer. (step 5)
- `lib/features/authentication/domain/repositories/auth_repository.dart` —
  declared `refreshStoriesToken`. (step 5)
- `lib/features/authentication/data/repositories/auth_repository_impl.dart` —
  implemented it through `handlingExceptionRequest`, copying the chat method.
  (step 5)
- `lib/features/authentication/domain/use_cases/refresh_stories_token_usecase.dart`
  — **new file**; `@injectable RefreshStoriesTokenUseCase` plus
  `RefreshStoriesTokenParams`, which carries `refresh_token`. (step 6)
- `lib/features/authentication/presentation/manager/auth_event.dart` — added
  `RefreshStoriesTokenEvent`. (step 7)
- `lib/core/api/token_refresh_coordinator.dart` — added `stories` to
  `RefreshScope`. Nothing else in that file changed. (step 8)
- `lib/features/authentication/presentation/manager/auth_bloc.dart` — added the
  use-case import, field and constructor parameter; registered
  `RefreshStoriesTokenEvent` with `throttleDroppable(Duration(seconds: 10))`;
  added `_onRefreshStoriesTokenEvent`; and stored the returned refresh token in
  the stories login handler next to the access token. (steps 9, 10, 12)
- `lib/core/api/log_interceptor.dart` — replaced the `STORY_URL` branch body in
  `_handleUnauthorizedError`: it now waits for a stories refresh through
  `TokenRefreshCoordinator` and returns the new access token, with an early
  `return`. `setStoriesToken("")` is gone from that branch. (step 11)
- `lib/base_page.dart` — clears the stories refresh token in the logout routine
  that already clears the stories access token. (step 12)
- `lib/features/app/app_widgets/app_bottom_navigation_bar.dart` — same clear in
  the second live logout path. (step 12)
- `lib/core/di/di_container.config.dart` — **regenerated, never hand-edited.**
  Registers `RefreshStoriesTokenUseCase` and passes it to `AuthBloc`. (step 13)

## Deviations from plan

- **Step 1 (confirm the endpoint contract) — partly confirmed.** The owner
  supplied a Postman screenshot of the live call. It confirms the request half
  exactly: `POST {{story_base_url}}/api/v1/auth/refresh-token` with body
  `{"refresh_token": "..."}`, answering `200 OK`. Both match what the code
  builds. The response half is **not** fully confirmed: the screenshot shows
  only lines 20–25, where a nested object carries `accessToken` / `refreshToken`
  and an enclosing level carries `access_token` / `refresh_token`. Whether that
  enclosing level is `data` — which is what `LoginToStoriesResponseModel` parses
  — cannot be read from the visible part. Confirm at `/verify`.
- **Hardening added on top of the chat pattern.** The chat handler writes
  `r.data!.accessToken!`. Because the stories response envelope is not fully
  confirmed (above), the stories handler reads `r.data?.accessToken` and treats
  a missing or empty value as a failed refresh instead. Force-unwrapping would
  throw inside the `fold` callback, so
  `TokenRefreshCoordinator.complete(RefreshScope.stories, ...)` would never run
  and every waiting stories request would hang for the full 20s timeout. This
  keeps AC-8 (a non-401 failure leaves both stored tokens untouched) and AC-12
  (bounded wait) true even if the envelope differs.
- **Step 12, second location.** The plan named "the sign-out handler in the
  bloc" as the second place that clears the session. That handler
  (`logOutUser`) is **commented out** in `auth_bloc.dart` and never runs, so
  editing it would change nothing. The live second logout path is the one in
  `app_bottom_navigation_bar.dart`, and it was changed instead. Both live
  logout paths now clear the new key.
- **Path shape of the endpoint.** The stories route file builds paths with a
  leading slash (`/api/v1/...`), unlike the market file. `authScope()` follows
  the stories file's own style, so the result is `/api/v1/auth/refresh-token`
  and matches how `StoriesEndPoints.loginEP` is already built.
- `clearUser()` and `clear()` in `prefs_repository_impl.dart` were left alone.
  Neither deletes the market or chat refresh token today, so adding only the
  stories key there would break the "one shape for all three servers" rule the
  plan is built on. This is a pre-existing gap shared by all three tokens, not
  something this ticket introduces.

## Validation run during implementation

- `dart run build_runner build --delete-conflicting-outputs` — success, wrote 61
  outputs; `lib/core/di/di_container.config.dart` regenerated.
- `flutter analyze` — `No issues found!` (AC-14 / the plan's `codegen-change`
  profile).
- Manual on-device evidence listed in `plan.md > Validation strategy` — **not
  run**. It belongs to `/verify`.
