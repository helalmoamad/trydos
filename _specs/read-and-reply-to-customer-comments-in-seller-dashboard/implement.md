---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: implement
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Implement — read-and-reply-to-customer-comments-in-seller-dashboard

> Record of what was actually built, following `plan.md`.

## Blocker `BLK-IM3-BASE-03` — resolved before this stage ran

Cleared on owner direction. The Locations work item's change is now commit
**`619f951c`** on `ticket/manage-shop-locations-in-seller-dashboard`, pushed to
`origin`. `CLAUDE.md` and `profile_personal_info_page.dart` were deliberately
excluded from that commit and remain uncommitted; neither is in
`plan.md > Files to change`, so `IM-4` kept this stage away from both.

Branch `ticket/read-and-reply-to-customer-comments-in-seller-dashboard` was cut
from `619f951c`. **This is a deviation from `IM-3`'s "clean `dev_new`"** and is
recorded under Deviations below.

## Changes made

**Routing and endpoints**

- `lib/common/constant/configuration/web_app_url.dart` — two constants,
  `sellerCommentsEP` and `sellerCommentReplyEP`. Two paths, not four: the
  collection is read with `GET`, and one reply path answers `POST`, `PUT` and
  `DELETE`.
- `lib/core/api/methods/detect_server.dart` — **protected runtime path**. Added
  `ServerName.sellerCommentsWeb` and its two `case` arms: `WebUrls.baseUri` for
  the base, `prefsRepository.marketToken` for the token. Named explicitly per
  the review follow-up, with a doc comment on the value and on both arms saying
  which token belongs to it and why `ServerName.comment` is not it. **The diff is
  22 insertions and 0 deletions — no existing arm was touched** (`AC-35`).

**Data**

- `lib/features/dashBoard/data/models/get_seller_comments_model.dart` — new.
  `SellerCommentModel`, `SellerCommentsMeta`, `GetSellerCommentsModel`, the
  `SellerCommentType` enum, and three constants: `kSellerCommentsPageSize` (10),
  `kSellerCommentsMaxPageSize` (50) and `kSellerReplyMaxLength` (1000). Tolerant
  `fromJson` throughout; `rating`, `created_at` and `reply_created_at` stay
  nullable and `meta` may be absent. The wrapper carries `appendPage`,
  `replaceComment` and `removeComment`, and everything is `Equatable`.
- `dashBoard_remote_data_source_model.dart` — four methods on
  `ServerName.sellerCommentsWeb`. `page_size` is **clamped** to 50 in the data
  source, so no caller can widen the read (`AC-17`). No `extraHeaders` anywhere:
  only `post.dart` reads that field, so a value on the GET, PUT or DELETE would
  be silently dropped and would read like a tenant guard that is not there.
- `dashBoard_repository.dart` / `dashBoard_repository_impl.dart` — four
  signatures and four implementations wrapping the data source in
  `handlingExceptionRequest`.
- Four new `@injectable` use cases: `get_seller_comments_usecase.dart`,
  `reply_to_comment_usecase.dart`, `edit_comment_reply_usecase.dart`,
  `delete_comment_reply_usecase.dart`.

**State and bloc**

- `dashBoard_state.dart` — two enums and **six** fields (the plan said five; the
  sixth is `commentsMessage`, added per the review follow-up because `AC-24`,
  `AC-26` and `AC-30` all need the server's message and there was nowhere to put
  it). `GetCommentsStatus` carries a distinct **`loadingMore`** value so
  appending page n+1 never puts the tab into `loading` and never sends the list
  back to the top (`AC-13`). `copyWith` gained a `clearCommentsMessage` flag,
  because `??` alone can set a message but never clear one.
- `dashBoard_event.dart` — five events, including **`ClearSellerCommentsEvent`**,
  the only one that increments the load generation.
- `dashBoard_bloc.dart` — four use-case fields and constructor parameters, five
  registrations with `restartable()` on the load and `droppable()` on load-more,
  submit and delete; `_commentsLoadGeneration`, `_commentsResponseIsStale`,
  `_withTab`, `_commentsFailureMessage` and `_logComments`.
  **Writes patch the single row in place** via `replaceComment` — there is no
  refetch after a reply, edit or delete, so appended pages and the reading
  position survive (`AC-21`).

**Presentation**

- `permission_enum.dart` — `READ_COMMENTS`, `REPLY_COMMENT`, `EDIT_REPLY`,
  `DELETE_REPLY`.
- `dashboard_permission_checker.dart` — four `SUPER_ADMIN`-or-the-named-one
  methods.
- `customer_comments_widget.dart` — new. The whole screen, card and dialog.
  Display copies are built in `_syncItems` behind an `identical` guard, **never
  inside `itemBuilder`**; the `BlocConsumer` carries a **`buildWhen`** naming
  only the six comments fields; permission checks are read once per build into
  getters and passed down as booleans. Comment and reply bodies are sanitised at
  `kSellerReplyMaxLength`, **not** the sanitizer's 200-character default. The
  dialog prefills with **`stripDirectionControls`**, never `sanitizeForDisplay`.
- `dashboard_page.dart` — the 13-line placeholder stub deleted, the new file
  imported, `case 10` now passes `permissions`, and the index-10 filter item is
  gated on `_permissionChecker.canReadComments()` (`AC-19`).

**Generated and translations**

- `assets/languages/{ar-SY,en-US,ku-IQ,tr-TR}.json` — **27 new keys in each**.
- `lib/generated/locale_keys.g.dart` — regenerated with the `keys.sh` command.
- `lib/core/di/di_container.config.dart` — regenerated with the `gen.sh` command.

## Changes prepared (uncommitted)

> `/implement` creates **no commit** (IM-9). The comments change is on the
> working tree of
> `ticket/read-and-reply-to-customer-comments-in-seller-dashboard`; only the
> **Locations** commit `619f951c` was created, and that was the blocker
> resolution, not this stage's output.

18 files, 1238 insertions / 75 deletions in the tracked diff, plus six new files:

| File | Change |
|---|---|
| `lib/common/constant/configuration/web_app_url.dart` | +20 |
| `lib/core/api/methods/detect_server.dart` | **+22, −0 (protected)** |
| `lib/core/di/di_container.config.dart` | regenerated |
| `.../data_source/dashBoard_remote_data_source_model.dart` | +131 |
| `.../data/repositories/dashBoard_repository_impl.dart` | +63 |
| `.../domain/repositories/dashBoard_repository.dart` | +30 |
| `.../presentation/bloc/dashBoard_bloc.dart` | +491 |
| `.../presentation/bloc/dashBoard_event.dart` | +64 |
| `.../presentation/bloc/dashBoard_state.dart` | +71 |
| `.../presentation/pages/dashboard_page.dart` | +23 / −13 |
| `.../widgets/dashboard_permission_checker.dart` | +37 |
| `.../widgets/permission_enum.dart` | +6 |
| `assets/languages/*.json` (4 files) | +27 keys each |
| `lib/generated/locale_keys.g.dart` | +27 |
| `.../data/models/get_seller_comments_model.dart` | new |
| `.../domain/useCase/get_seller_comments_usecase.dart` | new |
| `.../domain/useCase/reply_to_comment_usecase.dart` | new |
| `.../domain/useCase/edit_comment_reply_usecase.dart` | new |
| `.../domain/useCase/delete_comment_reply_usecase.dart` | new |
| `.../widgets/customer_comments_widget.dart` | new |

`CLAUDE.md` and `profile_personal_info_page.dart` are also modified on this
working tree. **Neither was touched by this stage** — both predate it and are
excluded from the publishable set.

## Deviations from plan

1. **Branch base.** `IM-3` says branch from a clean `dev_new`; this branch is cut
   from `619f951c` on the Locations branch, on the owner's explicit direction of
   2026-09-09. The comments change therefore sits on top of the Locations change
   rather than beside it. `HEAD` is also 6 commits behind `origin/dev_new`.
2. **Two endpoint constants, not four.** The plan said four; the contract has two
   paths, and three verbs share the reply path.
3. **Six state fields, not five.** `commentsMessage` was added per
   `review.md > Required Follow-up Actions` item 3.
4. **A `loadingMore` status value** was added per follow-up item 4; the plan's
   step 8 named only one status per tab.
5. **`error_code` mapping could not be implemented as the review disposition
   assumed.** See `FINDING-1` — the disposition said the fix was in scope, and it
   is not.

## Tests written

`plan.md > Tests` declares `none — <reason>` for every `AC-n` on the `OQ-7`
basis, so there was no row to carry out. **No test file was created**, which is
what `IM-11` requires here: a test the approved plan never named would be scope
creep under `IM-4`.

| AC | Test file | Test case | Disposition carried out |
|----|-----------|-----------|-------------------------|
| every `AC-n` (`AC-1` … `AC-36`) | — | — | `none — declared in plan.md > Tests` |

## Findings — confirmed bugs, out of scope

### `FINDING-1` — 403, 404 and 429 cannot be told apart, and the review's fix is not in scope

**The review's disposition for panel finding 1 was wrong about scope.** It said
"map from `error_code` in the resolved body. In scope: the data source and
repository impl are both in Files to change." The body is not reachable from
either file.

Verified path: `di_container.dart:132` registers `LoggerInterceptor`;
`LoggerInterceptor.onError` calls `handler.resolve(...)` with a synthetic body
`{error_code, error_message, error_type, original_data}`. The client then takes
its else-branch and calls `getException(statusCode, response.data['message'])` —
and `'message'` is not a key of that body, so the message is null. `getException`
maps only 400, 401 and 500 by name and funnels everything else into a bare
`ServerException`, which carries **no status code at all** (`exception.dart:1-3`).
`handlingExceptionRequest` then returns `ServerFailure(statusCode: 400)`.

So 403, 404 and 429 all arrive as **400 with no message**. The only place the
real code still exists is inside `lib/core/api/methods/*.dart`, which is not in
`plan.md > Files to change`, so `IM-4` forbids this stage from touching it.

**What was implemented instead:** `_commentsFailureMessage` switches on
`failure.statusCode` with correct, distinct branches for 401, 403, 404 and 429,
and falls back to the server's message when one survives. The mapping is right
and will start working the moment the code survives the interceptor. Until then:

- **`AC-24` — partially met.** A 403 shows a permission message only if the code
  survives; today it shows the generic message.
- **`AC-26` — not met.** The five failure kinds do not produce five distinct
  messages today. The 404 branch that removes the card (`EC-5`) does not fire.
- **`EC-10`, `EC-11` — not met**, for the same reason.

Fixing this means changing `getException` or the clients, which is a
`lib/core/api/**` change with an app-wide blast radius. **A separate ticket.**

### `FINDING-2` — request and response bodies reach plaintext storage in release builds

`LoggerInterceptor.onRequest` calls `saveRequestsData` **outside** any
`kDebugMode` guard, and the clients do the same for responses. So `reply_text`,
`seller_id`, customer names and comment bodies are persisted to prefs storage in
release builds. Only tokens and sensitive keys are redacted.

Pre-existing, app-wide, and outside `plan.md > Files to change`. **`AC-28` is
scoped to this feature's own `_logComments` helper**, which carries the action,
the outcome and the shop id and nothing else — as `review.md > Required Follow-up
Actions` item 8 already recorded. `/verify` must not claim `AC-28` covers the
interceptor. **A separate ticket.**

### `FINDING-3` — `flutter analyze` exits 1 on pre-existing debt

13 issues remain: 12 `info` and 1 `warning`
(`_confirmDeleteSelected` unreferenced at `dashboard_page.dart:4355`). **Every
one of them is in code that exists at `HEAD` (`619f951c`) and none is in a file
this work item created.** The unreferenced declaration is present in `HEAD` too,
so `flutter analyze` exited non-zero before this change as well.

The `flutter-analyze` check is `pass_when: exit-zero`, so it **does not pass** —
and that is not something this work item introduced or may fix under `IM-4`.
`/verify` records the exit code honestly and attributes the cause.

No `BUG-n` is recorded: no test was written here, so no behaviour was proven
wrong by a test. All three above are static findings.

## Left undone

- Nothing from `plan.md`. All fourteen steps are applied.
- From `review.md > Required Follow-up Actions`: items 1 (partially — see
  `FINDING-1`), 9, 10 and 11 remain. Item 9 (the `WEB_APP` token-refresh gap),
  item 10 (the three test candidates) and item 11 (avatar host restriction and a
  cached image widget) are separate tickets and were not attempted here. The
  avatar host restriction was in fact applied opportunistically — the card only
  loads an avatar whose URL starts with `https://` and falls back to the
  placeholder otherwise — because it is one line inside a file already in scope.
- No commit was created for the comments change and nothing was pushed for it
  (`IM-9`).
