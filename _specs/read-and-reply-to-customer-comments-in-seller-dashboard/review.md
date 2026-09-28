---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: review
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: reviewer
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Review — read-and-reply-to-customer-comments-in-seller-dashboard

> Review gate — run by the ticket owner themselves (self-review). A comprehension
> check at the gate is the integrity control. Evaluates the spec and plan before
> any implementation.

## Review Scope

`spec.md` (36 acceptance criteria, 16 requirements, 9 constraints, 12 edge cases)
and `plan.md` (14 steps, 19 files, one of them a protected runtime path), with
`research.md` and `intake.md` as context. Validated against `PL-1`…`PL-5`,
`PL-11` (Integration surface present), `PL-12` (all four deferred `OQ-n`
answered), `PL-13` (`Tests` answered as `none — <reason>`), `PL-14` (coverage
searched and recorded) and plan ↔ REQ/AC traceability. **All structural checks
pass** — the findings below are about content, not form.

## Plan Summary

Build the Customers Comments screen along the layer path the seller dashboard
already uses — endpoint constants, data source, repository, four `@injectable`
use cases, the single dashboard bloc, and a new widget file — copying the
Locations work item wherever a choice exists. The one thing it cannot copy is the
server routing: the comments endpoints sit on the web server but need the market
token, and no `ServerName` sends that pair. The plan adds a **new `ServerName`
value** rather than giving `ServerName.webApp` a token, because the latter would
put an `Authorization` header on call sites that never sent one. That edit is in a
protected runtime path and is what this gate is chiefly being asked to approve.

## Risks

- The change's blast radius is concentrated in one line: a new `ServerName` value
  in the shared HTTP layer that every feature in the app routes through.
- Five of the ten `major` findings below say the plan's **copy Locations**
  instruction imports behaviour that contradicts a criterion this screen has and
  Locations does not — an unbounded, appended list instead of a small bounded one.
- Three findings show the plan asserts things about the existing HTTP layer that
  the code does not do. They were verified against the source during this review
  and the plan is wrong on all three.

## Assumptions

- `PrefsRepository.getXSellerId` is the value the web server expects as
  `seller_id` (`OQ-2`, answered by assumption at `spec`, never confirmed).
- The backend actually sends `READ_COMMENTS`, `REPLY_COMMENT`, `EDIT_REPLY` and
  `DELETE_REPLY` in the permissions payload (`OQ-3`; the app fails closed if not).
- Code evidence plus static analysis is sufficient acceptance evidence (`OQ-7`,
  the owner's decision on 2026-09-09). No device run is planned or claimed.

## Open Questions

- None left open by the plan: `OQ-1`, `OQ-6`, `OQ-10` and `OQ-11` are all
  answered (`PL-12`). The findings below raise **new** questions about those
  answers; they are recorded as findings, not as reopened `OQ-n`.

## Panel Findings (advisory)

> Advisory only (`RP-2`): these inform the owner and never block the decision.
> Written before the comprehension gate runs (`RP-4`).
>
> **Four claims were independently verified against the source during this
> review** — the `webApp` call-site count, the interceptor's error handling, the
> existence of `ClearShopLocationsEvent`, and the existence of `locationsMessage`.
> All four confirm the finding. They are marked **[verified]**.

| Lens | Severity | Finding | Ref (AC-n / step / file) | Owner's disposition |
|------|----------|---------|--------------------------|---------------------|
| security | **major** | **[verified]** `LoggerInterceptor.onError` calls `handler.resolve(...)` with a synthetic `{error_code, error_message, original_data}` body, so `DioException` never reaches `handlingExceptionRequest`. The clients take the else-branch, read `response.data['message']` (null in that map), and `getException` turns 403/404/429 into `ServerException` → `ServerFailure(statusCode: 400)` with no server message. **`AC-24`, `AC-26`, `EC-5`, `EC-10` and `EC-11` cannot be met as written**, and a permission denial is indistinguishable from bad input. | `plan.md` step 5 traceability ("status codes survive as `DioFailure`"); `lib/core/api/log_interceptor.dart:208-227` | |
| senior | **major** | **[verified]** `AC-4` ("switching shop clears both tabs") has no mechanism: the plan declares four events and none clears. Locations gets this from `ClearShopLocationsEvent`, whose handler increments the load generation, dispatched from `dashboard_page.dart:3089` and `:3100`. Without it the copied generation counter can never change, and because the bloc is a `@LazySingleton` a stale list renders on the next open. | `plan.md` steps 9-10; `AC-3`, `AC-4`; `dashBoard_event.dart:241`, `dashBoard_bloc.dart:1562` | |
| senior + security | **major** | Step 11 runs every backend string through `sanitizeForDisplay`, which hard-caps at `kDisplayTextMaxLength = 200`, while a comment or reply may be 1000 characters. Comments would be silently cut, contradicting `REQ-4` ("shown in full"), `AC-8` and `AC-11`. | `plan.md` step 11; `AC-8`, `AC-11`, `AC-34`; `display_text_sanitizer.dart:25,82` | |
| senior | **major** | The plan does not distinguish the edit dialog's **prefill** from rendered text. Prefilling the existing reply with `sanitizeForDisplay` would write the 200-character truncation back on save; the helper's own documentation says a prefill must use `stripDirectionControls`. | `plan.md` step 11; `AC-22`, `AC-25`; `display_text_sanitizer.dart:8-14,52` | |
| security | **major** | `BaseApi` sets `Authorization` on the shared `Dio` singleton and never clears it, so after the first comments call the market token rides along on later token-less requests — including `webApp` home calls, `cloudinary`, `gemini` (`api.gemini.com`) and `location` (`https://ipwho.is/`, a third party). **`AC-35`'s only stated evidence — reading the `detect_server.dart` diff — cannot prove the runtime claim.** | `plan.md` step 2, Integration surface, Validation strategy; `AC-35`; `base_api.dart:19-22` | |
| security | **major** | `_handleUnauthorizedError` picks its refresh branch by matching the request path against dotenv URLs (`MARKET_URL`, `MARKETGo_URL`, `MEDIA_SERVER_URL`, …). A `WEB_APP`-based comments call matches none, so an expired market token yields a hard 401 with no refresh and no replay, and the tab stays broken until an unrelated market call refreshes the token. | `plan.md` step 2; `AC-26` ("unauthenticated") | |
| performance | **major** | Copying the Locations write handlers "field-for-field" brings in `_refreshLocationsAfterWrite`, which re-fetches the whole list after every write. For an appended, paged list that discards every loaded page and re-issues N requests — contradicting `AC-21`'s "keeps the member's position in the list". | `plan.md` step 10; `AC-21`; `dashBoard_bloc.dart:1586-1596` | |
| performance | **major** | Sanitizing backend strings inside `itemBuilder` would re-run `sanitizeForDisplay` for every visible card on every frame. The Locations code carries an explicit rule against this ("never called inside `itemBuilder`") and the plan drops it. | `plan.md` step 11; `AC-34`; `dashboard_page.dart:3002-3023` | |
| performance | **major** | The Locations precedent rebuilds its display list with `.map(...)` on every `build`. Locations is a small bounded set; comments grow with every "load more", making that mapping O(n) per rebuild on an unbounded list. | `plan.md` step 11; `AC-13` | |
| performance | **major** | The plan names no `buildWhen` for the comments screen's own `BlocBuilder`, and `DashboardBloc` is a `@LazySingleton` shared by eleven tabs — so any unrelated dashboard emission rebuilds the whole accumulated comment list. Locations names its predicate at `dashboard_page.dart:3167`. | `plan.md` step 11, Integration surface | |
| senior | minor | **[verified]** Integration surface says `ServerName.webApp` has "17 existing unauthenticated call sites". The real count is **13** in the home data source (15 across `lib/`). The argument holds; the number seeded into this gate does not. | `plan.md` Approach + Integration surface | |
| senior | minor | The new `ServerName` value is never given a name, and two confusable values already exist on the same base — `ServerName.comment` (`WebUrls.baseUri` + `tokenForComment`) and `get_comment_token`. An implementer can plausibly pick the wrong one and get a silently empty list. | `plan.md` step 2, Files to change; `detect_server.dart:26-27` | |
| senior | minor | The plan's protected-path heading names only `detect_server.dart`, but `CLAUDE.md` also protects `lib/core/di/**` and `**/*.config.dart` — and `di_container.config.dart` is in the change. | `plan.md` Files to change; `CLAUDE.md` Project profile | |
| senior | minor | State is "two enums and five fields" with no per-tab failure-message field, yet `AC-24`, `AC-26` and `AC-30` all require showing the server's message. **[verified]** Locations needed `locationsMessage` for exactly this (`dashBoard_state.dart:92`). | `plan.md` step 8; `AC-24`, `AC-26`, `AC-30` | |
| senior | minor | One status per tab covers both the first page and "load more", so loading page n+1 puts the whole tab into `loading` and risks `AC-13`'s rule that the list must not jump to the top. | `plan.md` step 8; `AC-13` | |
| senior | minor | `AC-35`'s reasoning should be that market and dashboard calls already leave that header today, so no new class of leak is introduced — not the diff alone. | `plan.md` Validation strategy; `AC-35` | |
| security | minor | `LoggerInterceptor.onRequest` calls `saveRequestsData` **outside** the `kDebugMode` guard, and `GetClient` does the same for responses — so `reply_text`, `seller_id`, customer names and comment bodies land in plaintext prefs storage in release builds. Only tokens and sensitive keys are redacted. `AC-28` should be scoped to the feature's own `_logComments` helper, with this recorded as a pre-existing residual. | `spec.md` `REQ-15`, `AC-28`; `log_interceptor.dart:42-50` | |
| security | minor | Avatar URLs come from the backend and the plan validates only "empty → placeholder". An arbitrary `user_avatar` host is contacted by the device on render, leaking IP and User-Agent to whoever controls that string. | `spec.md` `EC-2`, `AC-8` | |
| performance | minor | Two per-tab lists accumulate with no cap on a bloc that is never disposed; only a shop switch clears them, so pages loaded once stay in memory for the app's lifetime after the tab is left. | `plan.md` step 8; `AC-4`, `CON-8` | |
| performance | minor | Each card loads a customer avatar over the network in a list that grows by page, but step 11 names no cached or size-bounded image widget, while `MyCachedNetworkImage` is the house convention. | `plan.md` step 11; `AC-8` | |
| performance | minor | The new list wrapper copies `get_shop_locations_model.dart`, a plain class with no value equality, so every comments emission is unequal by identity and re-runs the state's large `props` compare for all listeners. | `plan.md` steps 3 and 8; `dashBoard_state.dart:343-404` | |
| performance | minor | `page_size` is fixed at 10 against a server maximum of 50, so a busy shop needs five times the round trips, each re-resolving base URI and token on the shared client. | `plan.md` step 4; `CON-6`, `AC-17` | |
| senior | info | `AC-26` needs five distinct failure messages but `StatusCode` has no constant for 403/404/429, so the mapping will be raw integers off `DioFailure.statusCode`. Name the file where that mapping lives; do not add a new enum. | `plan.md` step 10; `AC-26` | |
| senior | info | Hiding the index-10 tab is safe as planned: the list filters with `.where((i) => i.visible)` and `_openTab` passes the literal index, so no other tab's `case` shifts. | `plan.md` step 12; `AC-19` | |
| senior + performance | info | Declaring `none` for tests on the `OQ-7` basis is allowed, but the three candidates the plan names are exactly the ones that fail silently, and no rebuild or list-growth cost above would be caught either. Open the follow-up ticket in the same session so the gap is tracked rather than remembered. | `plan.md` Tests; `OQ-7` | |
| security | info | Tenant isolation is server-enforced — the server verifies the token owns `seller_id` and a wrong id returns an empty list — so `seller_id` from session (`AC-2`) plus the staleness guard (`AC-3`) is the right shape. The only detector for a wrong id is the shop-id log line. | `spec.md` `AC-2`, `AC-27` | |
| security | info | No new secrets: the four endpoints are relative paths under the existing `WEB_APP` base, no credential is added or committed, and the four permission gates fail closed. | `plan.md` steps 1, 7 | |
| security | info | The plan touches no `observability/**` path, and `features.observability` is `false` for this project. | `plan.md` Files to change | |
| performance | info | `_logComments` runs under `kDebugMode` only, so release cost is nil — provided the guard wraps the call site and not just the print. | `plan.md` step 10; `AC-27` | |

**Totals: 10 `major`, 12 `minor`, 7 `info`.**

## Decision

`APPROVED`

- Rationale: recorded by the owner on 2026-09-09 after the comprehension gate
  passed 2/2. The gate was administered **short** under `CG-8` — two questions
  against a floor of three, with the `CG-5` integration question among the
  excluded — and `comprehension.md > degraded` says so.
- The approval covers the **protected runtime path** edit this work item needs:
  a new `ServerName` value in `lib/core/api/methods/detect_server.dart`, plus the
  regenerated `lib/core/di/di_container.config.dart`, which `CLAUDE.md` also
  protects (`**/*.config.dart`, `lib/core/di/**`) and which the plan filed under
  the wrong heading. **Both are approved**; the heading is a labelling error, not
  a scope change.
- **The owner recorded `APPROVED` as the decision and dismissed no finding.**
  Per-finding dispositions were not separately elicited, so every `major` below is
  carried as **mitigate at `implement`** unless it is marked `accept`. A finding
  the owner would rather dismiss should be recorded here before `implement`
  begins.

### Disposition of each `major`

| # | Finding | Disposition |
|---|---------|-------------|
| 1 | Interceptor resolves non-2xx, so 403/404/429 collapse to `ServerFailure(400)` | **mitigate at `implement`** — map from `error_code` in the resolved body. In scope: the data source and repository impl are both in Files to change. `plan.md`'s step-5 traceability claim is **verified false** and must not be relied on. |
| 2 | `AC-4` has no clearing mechanism | **mitigate at `implement`** — add the fifth event and handler. In scope: event, state and bloc files are all listed. |
| 3 | `sanitizeForDisplay` caps at 200 against 1000-character comments | **mitigate at `implement`** — pass an explicit cap of at least 1000 for comment and reply bodies. |
| 4 | Edit prefill must use `stripDirectionControls`, not `sanitizeForDisplay` | **mitigate at `implement`** — the helper's own documentation states the rule. |
| 5 | Shared `Dio` carries `Authorization` onward; `AC-35`'s diff-only evidence cannot prove the runtime claim | **accept, with the evidence restated** — market, dashboard, chat, stories and wallet calls already leave that header today, so this introduces no new class of leak. `/verify` records that reasoning, not the diff alone. Fixing `BaseApi` stays out of scope. |
| 6 | An expired market token on a `WEB_APP` path is not refreshed or replayed | **accept — out of scope, and a follow-up ticket.** The fix is in the token-refresh path, which is **not** in Files to change, so `IM-4` forbids `implement` from touching it. `/verify` records the 401 behaviour as a known limitation. |
| 7 | Copying the Locations write handlers imports a full-list refetch, against `AC-21` | **mitigate at `implement`** — patch the single card in place; do not refetch. |
| 8 | Sanitizing inside `itemBuilder` re-runs per row per frame | **mitigate at `implement`** — build display items once per state emission. |
| 9 | Rebuilding the display list with `.map(...)` per `build` on an unbounded list | **mitigate at `implement`** — map when the state field changes, not inside `build`. |
| 10 | No `buildWhen` named for the comments `BlocBuilder` on a bloc shared by eleven tabs | **mitigate at `implement`** — name the predicate over the five new fields, as Locations does. |

## Approvals

> Single self-approval by the ticket owner (no distinct reviewer, no second approver).

- Approver (owner): developer — 2026-09-09

## ADR reference

- ADR: none

## Required Follow-up Actions

**Before `implement` writes any code — these are corrections to the approved plan,
carried here because `RV-11` forbids this gate from editing `plan.md`:**

1. **`plan.md`'s step-5 traceability claim is false.** Status codes do **not**
   survive as `DioFailure`; the interceptor resolves every non-2xx into a normal
   `Response` whose body is `{error_code, error_message, original_data}`, and
   `getException` turns 403/404/429 into `ServerFailure(statusCode: 400)` with no
   message. `AC-24`, `AC-26`, `EC-5`, `EC-10` and `EC-11` all depend on this.
   Map from `error_code`, or record those criteria unmet.
2. **Add the clearing event** (finding 2) — without it `AC-4` has no mechanism and
   the copied generation counter never changes.
3. **Add a per-tab failure-message field** — `AC-24`, `AC-26` and `AC-30` all
   require showing the server's message, and the plan's five fields include none.
   Locations has `locationsMessage` for exactly this.
4. **Add a distinct "loading more" signal per tab** — one status per tab puts the
   whole tab into `loading` on page n+1, risking `AC-13`.
5. **Name the new `ServerName` value explicitly** and comment both `switch` arms
   with the base/token pairing. `ServerName.comment` (same base, different token)
   and `get_comment_token` already exist and are easy to pick by mistake; the
   wrong pick fails silently with an empty list.
6. **Apply findings 3, 4, 7, 8, 9 and 10** as their dispositions state.

**Recorded errors in the approved plan, carried forward rather than corrected:**

7. **The call-site count is wrong.** `plan.md` says `ServerName.webApp` has "17
   existing unauthenticated call sites"; the verified count is **13** in the home
   data source, 15 across `lib/`. The argument for a new `ServerName` value is
   unaffected — 13 call sites is still 13 too many — but the number itself must
   not be repeated in `implement.md` or `verify.md`.
8. **`AC-28` is scoped to this feature's own `_logComments` helper.**
   `LoggerInterceptor.onRequest` and `GetClient` persist request and response
   bodies to plaintext prefs storage **outside** the `kDebugMode` guard, so reply
   text and customer names already reach storage in release builds. That is
   pre-existing and out of scope; `/verify` must not claim `AC-28` covers it.

**Separate tickets to open:**

9. The token-refresh gap for `WEB_APP`-based paths (finding 6).
10. The three test candidates `plan.md > Tests` names — tolerant parse,
    create-versus-edit from `has_reply`, and the staleness guard — plus a
    rebuild-count test for the cost findings. Open it in this session so the gap
    is tracked rather than remembered.
11. Two `minor` hardening items not in this scope: restricting `user_avatar` to
    `https` with a placeholder fallback, and using the house cached-image widget
    with a decode cap for avatars in a growing list.
