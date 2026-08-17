---
ticket: refresh-token-stories-server
stage: plan
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-16
links:
  clickup:
  github:
---

# Plan — refresh-token-stories-server

> Decide the approach before changing code. Plan only — no implementation here.

## Approach

Copy the chat refresh path onto stories, piece for piece. Chat already has every
part this ticket needs — a stored refresh token in secure storage, a refresh use
case, an `AuthBloc` event and handler, a `RefreshScope` value, and a `401` branch
in the interceptor that waits for the refresh and then replays the request. So
the work is to add a third scope beside `market` and `chat`, not to invent a new
mechanism. This keeps the change small, keeps one shape for all three servers,
and satisfies the spec's constraint to follow the existing pattern.

The one alternative — a stories-only refresh helper outside the coordinator — was
rejected. It would give stories a second way to do the same thing, would not
collapse concurrent refreshes (AC-4), and would leave the interceptor with two
different retry paths.

**OQ-8 is answered here.** Yes, the stories branch in the shared `401` handler
gets an early `return`, exactly like the chat branch already has. This is safe
for NFR-1: the branches are selected by matching the failing request's path
against a different `.env` base URL each, so a request that enters the stories
branch could never have reached the market branch with a useful result — today it
only falls through and gets rejected by every later `isFrom(...)` test. The
branches for market, marketGO, media, chat, wallet and comment are not touched,
and their order relative to each other does not change.

One value is still unconfirmed: the exact path of the stories refresh endpoint.
The market and chat servers both use `auth/refresh-token` under `api/v1`, so the
plan assumes the same path on the stories server. **Step 1 confirms it with the
backend before any code is written.** If it differs, only the endpoint constant
changes — no other step is affected.

## Steps

1. **Confirm the endpoint contract** (read-only, no code). Confirm with the
   backend: the refresh path on the stories server, the request field name for
   the refresh token, and the response shape. The assumption is that it mirrors
   market and chat — `POST api/v1/auth/refresh-token`, body `{"refresh_token":
   "..."}`, and the same envelope the stories login already returns, with
   `data.access_token` and `data.refresh_token`. If the real contract differs,
   adjust step 2 and step 5 and note it in `implement.md`.
2. **Declare the endpoint.** Add an `auth` scope helper and a `refreshTokenEP`
   constant to the stories route file, beside the login endpoint that is already
   there.
3. **Add storage for the stories refresh token.** Add the storage key, then the
   abstract getter/setter pair on the prefs repository and its implementation.
   It goes into secure storage, the same place the market and chat refresh tokens
   live — not into normal prefs, where the access tokens live. (AC-8)
4. **Read the refresh token from the login response.** Add a `refreshToken`
   field to the stories login response model, parsed from `refresh_token`. The
   model is hand written, so no generator is involved for this file.
5. **Add the data path.** Add a `refreshStoriesToken` call to the auth remote
   data source (stories server, the new endpoint, reusing the stories login
   response model for the answer — the chat refresh reuses its login model the
   same way), then the matching method on the auth repository interface and its
   implementation.
6. **Add the use case.** A new `@injectable` refresh use case for stories, built
   exactly like the chat one, with a params class carrying `refresh_token`.
7. **Add the event.** A new `RefreshStoriesTokenEvent` beside the market and chat
   refresh events.
8. **Add the scope.** Add `stories` to the `RefreshScope` enum in the refresh
   coordinator. Nothing else in that file changes — the wait, the sharing of one
   refresh (AC-4) and the bounded timeout (AC-12) already work per scope.
9. **Add the bloc handler.** Register the new event with the same throttling the
   chat and market refresh events use, and write the handler as a copy of the
   chat one: read the stored stories refresh token; if there is none, fall back
   to a new guest session and report failure to the coordinator; otherwise call
   the use case; on success store **both** returned tokens and report success; on
   a `401` fall back to a new guest session; always report the outcome to the
   coordinator so no caller waits for nothing. (AC-1, AC-2, AC-6, AC-12)
10. **Store the refresh token at login.** In the existing stories login handler,
    store the returned refresh token next to the access token it already stores.
    (AC-7)
11. **Wire the `401` branch.** In the shared error interceptor, replace the
    stories branch body: instead of clearing the stories token and falling
    through, wait for a stories refresh through the coordinator and return the
    new access token, then `return`. Clearing the stored access token up front is
    dropped, because a cleared token would make every other in-flight stories
    request build itself without a bearer token; the refresh replaces it instead,
    and the failure path clears it. The existing replay helper then sends the
    request again — it already rebuilds a multipart body, which covers the story
    upload. (AC-1, AC-3, AC-5, AC-9, AC-10)
12. **Clear on logout.** Add the stories refresh token to both places that clear
    the session today — the logout routine in the composition root and the
    sign-out handler in the bloc — so a logged-out user keeps no usable token.
    (AC-8)
13. **Regenerate.** Run the project's generator so the DI config picks up the new
    use case and the changed bloc constructor. The generated file is never edited
    by hand.
14. **Validate** per the Validation strategy below.

## Files to change

- `lib/common/constant/configuration/stories_url_routes.dart` — add an `auth`
  scope helper and the `refreshTokenEP` constant. (step 2)
- `lib/common/constant/configuration/prefs_key.dart` — add the
  `storiesRefreshToken` key, beside `marketRefreshToken` and `chatRefreshToken`.
  (step 3)
- `lib/core/domin/repositories/prefs_repository.dart` — declare
  `setStoriesRefreshToken` / `getStoriesRefreshToken`. (step 3)
- `lib/core/data/repository/prefs_repository_impl.dart` — implement both against
  secure storage, copying the chat pair. (step 3)
- `lib/features/authentication/data/models/login_to_stories_response_model.dart`
  — add the `refreshToken` field to `Data`, parsed from and written to
  `refresh_token`. (step 4)
- `lib/features/authentication/data/data_sources/auth_remote_datasource.dart` —
  add `refreshStoriesToken`, using `ServerName.stories` and the new endpoint.
  (step 5)
- `lib/features/authentication/domain/repositories/auth_repository.dart` —
  declare `refreshStoriesToken`. (step 5)
- `lib/features/authentication/data/repositories/auth_repository_impl.dart` —
  implement it, copying the chat method. (step 5)
- `lib/features/authentication/domain/use_cases/refresh_stories_token_usecase.dart`
  — **new file**; `@injectable` use case plus its params class. (step 6)
- `lib/features/authentication/presentation/manager/auth_event.dart` — add
  `RefreshStoriesTokenEvent`. (step 7)
- `lib/core/api/token_refresh_coordinator.dart` — add `stories` to
  `RefreshScope`. (step 8)
- `lib/features/authentication/presentation/manager/auth_bloc.dart` — add the use
  case field and constructor parameter, register the event handler with the same
  throttling as the other two refresh events, add the handler, store the refresh
  token in the existing stories login handler, and clear it in the sign-out
  handler. (steps 9, 10, 12)
- `lib/core/api/log_interceptor.dart` — replace the body of the `STORY_URL`
  branch in the unauthorized handler and give it an early `return`. (step 11)
- `lib/base_page.dart` — clear the stories refresh token in the logout routine
  that already clears the stories access token. (step 12)
- `lib/core/di/di_container.config.dart` — **regenerated, never hand-edited.**
  (step 13)

Every one of these except the new use-case file is a **protected runtime path**
under `CLAUDE.md`. This listing is what makes editing them legal at
`/implement`, and only inside an approved implement stage.

## Integration surface

> Required (PL-11, ADR-012). What this change touches **beyond its own files** —
> the source of the mandatory integration question at `/review` (CG-5).
> `none — self-contained` is valid only with the reason stated.

- **Components / shared config touched:**
  - The shared Dio error interceptor. It is the single `401` path for **every**
    server in the app: market, marketGO, media, chat, stories, wallet, comment,
    dashboard, elastic, cloudinary.
  - `TokenRefreshCoordinator` and its `RefreshScope` enum — shared by the market
    and chat refresh flows and by their bloc handlers.
  - `AuthBloc` — an app-wide singleton registered in DI and provided through
    `ServiceProvider`. Its constructor signature changes, so the generated DI
    config changes with it.
  - `PrefsRepository` — the app-wide token store, read by every feature.
  - The generated DI config, which is shared by the whole app.
  - The stories server itself, through a new endpoint call.
  - The `.env` value `STORY_URL` is **read** (it selects the branch); it is not
    changed.
- **Who else depends on them:**
  - The market and chat refresh flows depend on the interceptor and the
    coordinator. Their behaviour must not change (NFR-1, AC-11).
  - `_fallBackToNewGuestSession` is shared with the market and chat handlers, and
    it drives the "session expired" dialog that `base_page` listens for. A stories
    failure now reaches that same code — this is the owner's decision on OQ-4.
  - Every feature bloc resolves `AuthBloc` from DI, so a wrong constructor order
    after regeneration breaks app start-up, not just stories.
  - The story upload flow depends on the interceptor's separate rule that marks an
    upload as failed on error; a replayed upload must not be marked failed
    (AC-9).
- **Overlapping flows:**
  - The stories `401` branch sits in the same method as the market branch and
    currently falls through into it. Step 11 stops that fall-through (OQ-8).
  - A stories `401` and a market `401` can happen at the same moment. They are
    separate scopes and must stay independent (EC-7).
  - The stories access token is also written by the QR-login path and the user
    info page, which set a stories token from outside the login handler. Those
    paths will store no refresh token, so a later refresh there takes the
    "nothing stored" path (EC-1) and falls back to a new guest session.
  - Logout clears tokens in two separate places (composition root and bloc). Both
    must clear the new key, or a logged-out user keeps a working refresh token.
- **Ordering / lockstep dependencies:**
  - The backend endpoint must exist before this ships. Step 1 confirms it.
  - The bloc constructor change and the DI regeneration are lockstep: the app
    will not start if the generated config is stale. Regenerate in the same
    commit.
  - Storing the refresh token at login (step 10) must ship together with the
    refresh handler (step 9). A refresh handler with nothing stored would send
    every user down the guest-session fallback.
- **What breaks if this is wrong:**
  - Wrong branch order or a missing `return` in the interceptor: a market `401`
    takes the stories path, the market token is never refreshed, and the whole
    marketplace silently loses its session. It would show as products and cart
    failing after about a token lifetime, not as a stories bug.
  - A stale generated DI config: the app crashes at start-up for everyone.
  - The refresh token not cleared at logout: the next user of the device can
    renew the previous user's stories session. A security problem, not a
    functional one.
  - The fallback firing too eagerly: an expired stories token resets the market
    session and shows "session expired" to a user who was only watching stories.

## Validation strategy

- Validation profile: `codegen-change`
- Why this profile: the change adds an `@injectable` use case and changes the
  `AuthBloc` constructor, so the generated DI config must stay in sync; the
  profile also runs static analysis.
- Manual evidence, because the repository has no test that can reach this path
  (OQ-10 in `spec.md`):
  - Force an invalid stories access token on a device, open stories, and confirm
    the list loads with no visible error and no extra loading state (AC-1, AC-3,
    AC-10).
  - Confirm from the debug logs that exactly one refresh runs when several
    stories requests fail together (AC-4), and that a request is replayed at most
    once (AC-5).
  - Repeat with an invalid **refresh** token and confirm the guest-session
    fallback runs and a verified user is not logged out (AC-6).
  - Force the same on a story upload and confirm the replayed upload carries the
    file and is not marked as failed (AC-9).
  - Log out and confirm no stories refresh token remains stored (AC-8).
  - Confirm a market `401` still behaves exactly as before (AC-11).
  - Confirm a release build prints no token value (AC-13).

## Rollback

- The whole change is one branch and one commit. `git revert` of that commit
  returns every listed file to its current behaviour, and the generated DI config
  reverts with it.
- No stored data migration is involved. The change only **adds** a secure-storage
  key; after a revert the key is simply never read again, and no hydrated bloc
  state shape changes, so old stored payloads still deserialize.
- If the problem shows up only in the interceptor, the smaller rollback is to
  restore the old body of the stories `401` branch (clear the token, fall
  through). Stories then behave as they do today while the rest of the change
  stays in place.

## Out of scope

- Refresh-token support for the wallet and comment servers.
- Any backend change on the stories server.
- Refactoring the shared `401` handler beyond the stories branch and its
  `return`.
- A silent re-login as the renewal mechanism (rejected in `spec.md`, OQ-3).
- Proactive renewal before a token expires.
- Adding a test framework or unit tests for the network layer.
- Changing how the stories access token is obtained the first time, apart from
  storing the refresh token that response already carries.
