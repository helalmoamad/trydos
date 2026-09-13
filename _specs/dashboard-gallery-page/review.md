---
ticket: dashboard-gallery-page
stage: review
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: reviewer
updated: 2026-08-22
links:
  clickup:
  github:
---

# Review — dashboard-gallery-page

> Review gate — run by the ticket owner themselves (self-review). A comprehension
> check at the gate is the integrity control. Evaluates the spec and plan before
> any implementation.

**Recorded review round 3**, over `plan.md` **revision 5**. This file replaces the
round-2 record.

Gate history so far:

| Round | Plan | Outcome |
|-------|------|---------|
| 1 | revision 1 | `CHANGES_REQUESTED` — follow-ups F-1..F-13 |
| 2 | revision 3 | `CHANGES_REQUESTED` — follow-ups G-1..G-16 |
| — | revision 4 | **No decision recorded.** The panel returned 8 majors and the comprehension gate failed 5/8 (CG-4), so nothing was written to `ticket.md`. See `comprehension.md`. |
| 3 | revision 5 | **this file** — `CHANGES_REQUESTED`, follow-ups J-1..J-14 |

## Review Scope

Reviewed `spec.md` (AC-1..AC-22) and `plan.md` revision 5 (approach, 12 steps, 11 files to
change, integration surface, validation profile `localization-change`, rollback, risks),
with `research.md`, `intake.md` and `comprehension.md` as context. The full three-lens
panel ran over revision 5 and returned **13 `major`**, 13 `minor` and 6 `info` findings.

Revision 5 was written to answer the 8 majors raised against revision 4 (recorded in the
plan as H-1..H-20). Each lens was asked to verify those fixes against the code rather than
accept them, because revisions 3 and 4 each contained a confidently stated false claim.
**Two of revision 5's own fixes turned out to be defects**, which is the substance of this
round.

No comprehension check was run: CG-1 and CG-4 scope that requirement to recording
`APPROVED`, and this round records `CHANGES_REQUESTED`, which advances nothing.

## Plan Summary

Fill the existing dashboard tab: write `GalleryWidget`, return it from `case 9`, leave
navigation alone. Hold the uploaded list in `DashBoardState` on the existing
`DashboardBloc`. Run one single-flight queue registered with `sequential()`, 2 files in
flight, each with a size-scaled give-up deadline. Stamp every entry with an identity
triple (user, shop, session), filter the grid on values read live from prefs at build, and
re-check the triple before every file so a queued batch cannot be sent into another
seller's session. Refuse a file whose resolved address is not under the configured media
server. Cap the list at 60 and the run at 100 uploads.

## Risks

- **The plan, as written, destroys user data.** Deleting the "resolved temporary copy"
  deletes the origin device file on the asset-picker path. This is not recoverable.
- **The plan, as written, breaks itself on a routine token refresh.** A media-server 401
  rotates the market token for the same seller, which the identity triple reads as a new
  identity — failing the batch, hiding finished tiles and clearing the list.
- Three of the mechanisms revision 5 introduced (lifecycle re-arm, the 3-strike connection
  stop, the untimed asset resolve) are not implementable as described against this
  codebase.
- The "2 in flight" limit does not bound network concurrency, because a given-up request
  keeps running.
- AC-8 is now contradicted by the plan rather than merely untraced.
- Accepted by the owner in an earlier round: no permission gate on the gallery tab.
- The gallery adds fields to a state object shared by ten tabs, and no validation profile
  can catch a `copyWith`/`props` error.

## Assumptions

- The media server accepts the ticket-and-upload rate a multi-file batch produces.
- `folder: 'gallery'` needs no server-side change.
- `MEDIA_SERVER_URL` is present in `.env`, as the stories flow already depends on it.
- Hand verification on a device is acceptable — the repository has no widget-test setup
  for the dashboard.

## Assumptions proven wrong this round

- That a token change implies a session change. It does not: refresh rotates the token for
  the same user.
- That `AssetEntity.file` returns a disposable copy. It can return the origin file.
- That a `Stopwatch` excludes suspended time. It does not.
- That `marketToken` lives in SharedPreferences. It is in secure storage
  (`prefs_repository_impl.dart:74-81`) — a factual error in revision 5's Risks section.

## Open Questions

- **Answered after this gate was recorded: the upload queue is cut.** The owner was asked
  whether to cut the upload queue entirely, keep scope, or split the ticket, and answered
  on 2026-08-22: **cut it**. Revision 6 therefore drops concurrency, the give-up timers,
  the lifecycle re-arm, the 3-strike connection stop, and the temporary-file cleanup, and
  uploads one file at a time relying on Dio's existing 2-minute timeouts
  (`di_container.dart:26-28`). This is recorded here because the decision was made in
  conversation, and the conversation is not an artifact (ADR-003).
  The cut removes the cause of several follow-ups rather than fixing them — see the note
  under Required Follow-up Actions. It does **not** change `spec.md`: the acceptance
  criteria are untouched, and AC-21 (about 20 images) still applies, now served by serial
  uploads.
- **Answered after this gate was recorded: J-4 is resolved by dropping both caps.** The
  owner decided on 2026-08-22 to remove the 30-per-pick trim and the 100-per-run budget.
  AC-8 ("every image chosen in a picker starts uploading") is then satisfied as written,
  and **no spec change is needed** — which matters, because `/wf:plan` cannot write
  `spec.md` and `/wf:spec` cannot be reached from `spec-complete`. This dissolves **J-4**
  and **J-12**. The accepted cost: with no permission gate (accepted in an earlier round)
  and no app-side size limit (spec OQ-7), nothing in the app brakes a user filling shared
  media storage. Revision 6 must state that enlarged risk plainly rather than let it
  disappear with the caps.
- **Answered after this gate was recorded: a failed file does not stop the run.** The
  owner decided on 2026-08-22 that a failure marks that entry `failed` and the run
  continues to the next file, matching spec E-4, E-8 and AC-10. This also confirms J-7's
  removal is correct — the 3-strike stop would have contradicted it.
- All `OQ-n` from `research.md` remain closed (PL-12).
- Does AC-9 accept a four-value status rather than a percentage? Still unconfirmed.
- Three behaviours still map to no `AC-n` — the logout case, the count limits, and the
  batch stopping on an owner change — and AC-8 is now actively contradicted (J-4).

## Panel Findings (advisory)

> Findings from the advisory review panel (senior / security / performance) run
> at Step 1a — read-only lenses over `plan.md` + `spec.md` (ADR-010 / RP-1).
> **Advisory only:** these inform the owner; they never block the decision (RP-2).
> Record each finding and the owner's disposition. If the panel is disabled or
> returned nothing material, write "none".

All three lenses reported. Majors first; minors and info grouped after.

| Lens | Severity | Finding | Ref | Owner's disposition |
|------|----------|---------|-----|---------------------|
| security | major | Deleting the resolved file can delete the user's real photo. The folder path resolves an `AssetEntity`, and this app's own precedent is `assetEntity.originFile` (`stories_list.dart:335`), which on Android is the actual file in the device media store — not a copy. Not reversible. | plan H-11, Step 7 | **Accept — must fix.** J-2. The single most serious finding in the ticket. |
| senior | major | Same defect from the API angle: `.file` / `.originFile` return the origin device file, and the repo already relies on that (`stories_list.dart:333-335`, `add_lint_to_photo.dart:138-140`). | plan H-11, Step 7 | **Accept — must fix.** J-2. |
| performance | major | Same defect from a third angle: `minSdk = 24` (`android/app/build.gradle:27`), and on Android API 24–28 photo_manager's `AssetEntity.file` can return the original media path rather than a sandbox copy. | plan Step 7 (H-11) | **Accept — must fix.** J-2. Three independent routes to the same data loss. |
| performance | major | The temp delete also races: the given-up request may still be streaming that file from disk, and on the "Select Files" path the picked source **is** the temp copy, so deleting it leaves a `failed` entry with no source to retry — breaking AC-10 and E-5. | plan Steps 7 and 9; AC-10, E-5 | **Accept — must fix.** J-2. |
| senior | major | The token-derived session value (H-9) gives a false positive on a normal refresh: a media-server 401 goes down `RefreshTokenEvent` (`log_interceptor.dart:307-318`), which writes a new market token for the **same** seller (`auth_bloc.dart:1152`). The per-file re-check then fails every remaining file, the filter hides every `done` tile, and the open handler clears the list. Breaks AC-10, AC-13, AC-21. | plan H-9, H-4, H-6, Steps 3/5/8 | **Accept — must fix.** J-1. |
| security | major | Same defect, and worse: a rotation and a guest re-registration are **indistinguishable** by (user, shop, token-hash), because the ids are stale in both cases. | plan H-9, Steps 3/5/8 | **Accept — must fix.** J-1. |
| senior | major | The `AppLifecycleState.resumed` re-arm (H-7) has no owner. `DashboardBloc` is a `lazySingleton` with no observer, and an observer inside `GalleryWidget` is gone exactly when the batch needs it (E-6 / AC-22). A permanent app-wide observer would be a new shared surface the Integration surface does not list. Also `Future.timeout` cannot be re-armed — this needs a manual `Timer` plus `Completer`. | plan H-7, Step 8, Integration surface | **Accept — must fix.** J-3. |
| performance | major | Same, plus the premise is wrong: a Dart `Stopwatch` uses the monotonic clock and keeps advancing while suspended, so it does not exclude suspended time unless explicitly stopped on `paused`. The existing observers live in `trydos_application.dart:36,76` and `base_page.dart:714`, neither of which is in Files to change. | plan Step 8 (H-7), Files to change | **Accept — must fix.** J-3. |
| performance | major | Even with a re-arm, Dio's own `connectTimeout` / `receiveTimeout` / `sendTimeout` of 2 minutes each (`di_container.dart:26-28`) still fire together on resume, and changing them is out of scope — so the `/verify` check "healthy uploads are not failed in bulk after a resume" cannot be met by an app-level deadline at all. | plan Validation strategy, Out of scope | **Accept — must fix.** J-6: the check must be reworded to what is actually achievable. |
| performance | major | The give-up frees the slot but the request keeps running, so "2 in flight" is not a bound on the network: on the slow link that causes the timeouts, real concurrent uploads can grow to the whole batch — 20 sockets, 20× the bandwidth and battery — while the UI believes 2 are running. | plan Step 8, Risks | **Accept — must fix.** J-5. |
| performance | major | H-12's "3 consecutive connection-level failures" cannot be distinguished from server rejections: `handling_exception.dart:121-123` maps every response-less `DioException` to `DioFailure(statusCode: 400)`, and the catch-all returns `ServerFailure(400)`. Three server-rejected files would stop the batch, against E-8. | plan Step 8 (H-12); spec E-8, AC-10 | **Accept — must fix.** J-7. |
| performance | major | H-8 moved asset resolution onto the critical path with no bound: on iOS an iCloud-optimised original is downloaded inside `AssetEntity.file`, and the size-based deadline needs the file size, which only exists **after** the resolve — so the resolve is untimed while holding one of two slots. | plan Steps 7 and 8 | **Accept — must fix.** J-8. |
| senior | major | AC-8 ("every image chosen in a picker starts uploading") is now **directly contradicted**, not merely untraced: the 30-per-pick trim and the 100-per-run budget both leave chosen images that never upload. Filing these under "spec gaps" understates it. | plan H-5, H-17, Spec gaps; spec AC-8 | **Accept — must resolve.** J-4. |
| senior | minor | H-2's rule is sufficient **only** if there is no `await` between the re-read and the `emit` — Dart interleaves handlers only at await points. The plan never states that condition, so an implementer can satisfy the written rule and still lose an update. | plan H-2, Step 8 | **Accept.** J-9. |
| senior | minor | Retry is queued by `sequential()` behind the **whole** current batch, so a retried file can wait many minutes with nothing shown — reads badly against AC-10. Step 8 never says the loop re-scans for newly `pending` entries. | plan Steps 8-9; AC-10 | **Accept.** J-10. |
| senior | minor | "Capped at 60" is not a cap: eviction removes only **terminal** entries of the current owner, so 30 + 30 pending plus retries can exceed 60 with nothing evictable, and the behaviour is then undefined. | plan H-14, Step 2 | **Accept.** J-11. |
| senior | minor | The budget is never reset on owner change and the bloc is never closed, so seller B on a shared device can inherit a spent budget and be unable to upload at all until restart, with only a generic message. | plan H-3, Step 3 | **Accept.** J-12. |
| senior | minor | The budget is checked in two places (queue and widget). One rule in two places drifts; the widget copy buys only a slightly earlier message. | plan H-5, Step 6 | **Accept.** J-12 — drop the widget-side check. |
| senior | minor | Steps 7 and 8 are inverted: Step 7 describes work "in the queue handler" that Step 8 then creates. Step 6 never says the pick path dispatches the queue event, which is what makes AC-8's auto-start happen. | plan Steps 6-8 | **Accept.** J-13. |
| security | minor | The per-file check and the send are not atomic: at least two awaits run before the token is read (`upload_file_media_server_usecase.dart:33-39` → `common_use_repo_data_source.dart:60`), and `_logoutUser` does not await `setMarketToken(null)` (`base_page.dart:979`). The plan states H-4 as an absolute guarantee. | plan Approach, Step 8 | **Accept.** J-14 — soften the wording and re-check the triple when the upload resolves. |
| security | minor | `Uri.parse` throws `FormatException` on a malformed server string, and an unguarded throw inside the queue handler kills the shared bloc and all ten dashboard tabs. The check also compares scheme and host only, so a right-host / wrong-port URL passes. `resolve` is also not concatenation, so it can drift from the stories flow if the base ever gains a path. | plan H-10, Step 7 | **Accept.** J-14. |
| security | minor | The gallery clear is still tied to opening the tab, so if the next seller never opens Gallery the previous seller's entries and URLs stay in the shared singleton for the session. Memory-only and never drawn, but should not be implicit. | plan H-16, Step 3 | **Accept.** J-14 — clear at the first identity mismatch the queue sees. |
| security | minor | The hash is unspecified — algorithm, length, and a no-logging rule. "Short non-reversible hash" leaves room for `String.hashCode`, which is not a hash in the security sense, and `AppBlocObserver` prints whole state objects in debug (`bloc_observer.dart:28`). | plan H-9, Steps 3/5 | **Accept.** Folded into J-1 — if any derived value survives, name the algorithm and forbid logging it. |
| security | minor | 100 files per run with no size cap is a large amount of shared storage on a screen with no permission gate and no delete path. | plan Risks; spec E-8 | **Accept.** J-12 — write the worst-case **byte** figure into Risks so the owner accepts a number, not a file count. |
| performance | minor | AC-21 worst case is very long: 20 files, 2 slots, a 15-minute ceiling gives up to ~2.5 hours of "uploading", and the 3-strike stop does not count give-ups. | plan Step 8; AC-21 | **Accept.** J-5 — add a whole-batch ceiling or count give-ups. |
| performance | minor | "The pick path stays cheap" holds only for the asset picker: `FilePicker.pickFiles` copies every chosen file into the app cache **before** it returns, so a 30-file pick writes ~100 MB up front. | plan Step 6, H-8/H-11 | **Accept.** J-13 — state it in Risks. |
| performance | minor | Hashing the token inside `build` could run ~12 times per frame on a grid that rebuilds on every gallery emit. | plan Step 5 | **Accept.** Folded into J-1 / J-9 — compute the live triple once per grid build and pass it down. |
| performance | minor | H-13 counts cache slots but not bytes: eviction is by object count only, so up to 60 full-screen preview objects can add hundreds of MB of shared disk cache. | plan Integration surface item 8, H-13 | **Accept.** J-12 — restate in bytes. |
| performance | minor | Putting a freshly built list first in `props` makes Equatable deep-compare up to 60 entries on every state comparison, for all 11 tabs. | plan Step 2, H-15 | **Accept.** J-9 — keep `GalleryEntry` small and pass the same list instance through `copyWith` when the gallery did not change. |
| performance | minor | The plan never says what a `pending` / `uploading` tile draws. Those entries have no URL and, after H-8, no resolved `File` — exactly where an implementer would add a local preview and collide with the H-11 delete. | plan Step 5; AC-9 | **Accept.** J-2 — non-terminal tiles draw a placeholder only, with no local file read. |
| senior | info | Step 6's "take the first 30" can only apply to the `FilePicker` path; the folder path is capped by `maxAssets: 30` inside the picker. | plan Step 6, H-17 | **Accept.** Folded into J-4. |
| security | info | The 401 replay does not cross identities — `_retryWithFreshToken` only fires when the refresh succeeded, and the guest fallback leaves `refreshed` false. The Risks line about the multipart replay is accurate and is the only real cost. | plan Risks | **Accept.** No action. |
| security | info | Factual correction: `marketToken` is in **secure storage**, not SharedPreferences (`prefs_repository_impl.dart:74-81`), and no debug screen writes it (the QR login page does). The conclusion — privacy filter, not access control — still holds. | plan Risks | **Accept.** J-14 — fix the sentence. |
| security | info | No new secret, endpoint, port or permission, and no `observability/**` touch. Image fetches carry no auth header. Rollback is a one-line revert of `case 9`. | plan Files to change, Rollback | **Accept.** No action. |
| senior | info | Verified true: `sequential()` genuinely removes the H-1 lost wake-up; the registrations really are in the constructor body, so H-18's rewording is right; a plain `int` on the bloc is safe and has precedent (`dashBoard_bloc.dart:147`), and the bloc is never closed, so the budget survives and a long-held `Emitter` will not be cancelled; dropping `ClearDashboardStateEvent` (H-16) is the right call. | plan H-1, H-3, H-16, H-18 | **Accept.** No action — these H-fixes are confirmed good. |
| performance | info | Verified accurate: H-13 (`maxNrOfCacheObjects: 500`), H-14, H-15, H-18, H-20. One nit: the plan cites `my_cached_network_image.dart` without its path (`lib/features/app/`). | plan H-13, H-18, H-20 | **Accept.** Path fixed in J-13. |

## Decision

`CHANGES_REQUESTED`

- Rationale: The owner's instruction was `APPROVED` with the rationale "revision 5
  addresses all findings". The panel then returned thirteen `major` findings, and after
  reading them the owner chose to revise rather than approve. The panel did not force
  this — it is advisory (RP-2), and `APPROVED` was available at the cost of a 16-question
  comprehension gate.
  What decided it is that **revision 5 is worse than revision 4 in two specific ways, and
  both are its own new fixes**. H-11 would delete users' photos: three lenses found three
  independent routes to it — the app's own `originFile` precedent, the `minSdk 24` Android
  behaviour, and the fact that on the file-picker path the temp copy *is* the retry
  source. H-9 would break the feature on a routine token refresh, because a media-server
  401 rotates the token for the same seller and the identity triple cannot tell that apart
  from a new session. Three further mechanisms introduced in revision 5 — the lifecycle
  re-arm, the 3-strike connection stop, and the untimed asset resolve — are not
  implementable as written against this codebase.
  The approach is still not rejected, and several revision-5 fixes were confirmed correct:
  `sequential()`, the budget on the bloc, dropping the dead clear event, and the
  constructor rewording all stand. But a plan that destroys user data cannot be approved,
  and the pattern of each revision fixing the last round while introducing new defects is
  itself a signal — see the scope question left open above.

## Approvals

> Single self-approval by the ticket owner (no distinct reviewer, no second approver).

- Approver (owner): developer — recorded `CHANGES_REQUESTED` on 2026-08-22. No approval is
  granted; implementation may not begin.

## ADR reference

- ADR: none

## Required Follow-up Actions

To be addressed by a `/wf:plan` revision (revision 6) before this ticket returns to
`/review`. J-4 must resolve a plan-versus-AC conflict.

> **Effect of the scope decision (see Open Questions).** Cutting the upload queue
> **dissolves** J-3, J-5, J-6 and J-7 — the mechanisms they were about stop existing — and
> **dissolves J-2**, the data-loss finding, because nothing is deleted when there is no
> temporary-file cleanup. J-8 and J-10 shrink to almost nothing. Revision 6 must say
> plainly that these are removed rather than fixed, and must not leave stale references to
> them. **Still live and unaffected by the cut: J-1, J-4, J-9, J-11, J-12, J-13, J-14.**

- **J-1 (major) — Replace the token-derived session value.** A token rotation is not a
  session change. Use a login epoch bumped only by the login, guest-register and logout
  paths, or a stable subject inside the token — never the whole token, and never
  `String.hashCode`. If any derived value survives, name the algorithm and forbid printing
  it (`AppBlocObserver` prints state in debug). Compute the live triple once per grid
  build, not per tile.
- **J-2 (major) — Never delete a file the app did not create.** Delete only a path
  verified to sit under the app cache or temp directory; never a path resolved from an
  `AssetEntity`. Keep the source for `failed` entries so Retry still works, and do not
  delete while the given-up request may still be streaming it. State that non-terminal
  tiles draw a placeholder only, with no local file read. Prove all of this in the Step 12
  hand checks.
- **J-3 (major) — Own the lifecycle or drop the claim.** Say which observer re-arms the
  deadlines and where it lives (the existing ones are in `trydos_application.dart` and
  `base_page.dart`, neither currently in scope), state that a `Stopwatch` must be stopped
  on `paused` to exclude suspended time, and that this needs a manual `Timer` plus
  `Completer` because `Future.timeout` cannot be re-armed. Add any new observer to the
  Integration surface. Dropping the re-arm entirely is an acceptable answer.
- **J-4 (major) — Resolve the AC-8 conflict.** The 30-per-pick trim and the 100-per-run
  budget leave chosen images that never upload, which AC-8 forbids. Either amend AC-8 at
  spec level (a new ticket), or drop the caps. Also state that the trim applies only to
  the file-picker path.
- **J-5 (major) — Bound real network concurrency.** A given-up request keeps running, so
  freeing its slot lets live requests grow to the whole batch. Either keep the slot
  occupied until the request settles, or cap total live requests separately. Add a
  whole-batch ceiling, or count give-ups toward the stop rule, so AC-21 cannot run for
  hours.
- **J-6 (major) — Reword the resume expectation.** Dio's own 2-minute timeouts fire
  together on resume and are out of scope, so "healthy uploads are not failed in bulk"
  is not achievable. State what H-7 actually buys — fewer extra orphans — and make the
  `/verify` check match.
- **J-7 (major) — Drop or re-base the 3-strike rule.** Connection failures and server
  rejections are both `400` in this codebase, so the rule as written would stop a batch
  on three server rejections, against E-8. Either base it on evidence that can actually be
  observed, or state that typing it needs a `lib/core/api` change and remove the rule.
- **J-8 (major) — Time the asset resolve.** Give it its own fixed timeout before the
  size-based deadline starts, so an iCloud download cannot hold a slot indefinitely.
- **J-9 (minor) — Make the concurrency rule precise.** Word it as "read
  `state.galleryEntries`, merge and emit in one synchronous block — no `await` between
  them". Keep `GalleryEntry` small, and pass the same list instance through `copyWith`
  when the gallery did not change.
- **J-10 (minor) — Let a retry join the running batch.** Define the loop as "while any
  `pending` entry of the current owner exists", and show a retried entry as queued
  meanwhile, so AC-10 is not a multi-minute wait.
- **J-11 (minor) — Define the cap when nothing is evictable.** Say what happens when the
  list is at 60 with no terminal entries to remove; refusing the add with a message is the
  smallest answer.
- **J-12 (minor) — Fix the budget's edges.** Decide whether it resets on owner change (or
  make the message say it is per app run), drop the duplicate widget-side check, and
  record the worst-case **bytes** — for uploads and for the shared image cache — rather
  than only file counts.
- **J-13 (minor) — Fix the step ordering and two factual details.** Swap or merge Steps 7
  and 8, say in Step 6 that the pick dispatches the queue event, note that
  `FilePicker.pickFiles` copies every file into the cache *before* returning (~100 MB for
  a 30-file pick), and cite `my_cached_network_image.dart` with its full path.
- **J-14 (minor) — Correct the security wording.** Soften H-4 from a guarantee to "narrows
  the window", and re-check the triple again when the upload resolves. Guard `Uri.parse`
  with try/catch so a malformed base cannot kill the shared bloc, and compare `scheme`,
  `host` **and** `port`. Clear the gallery at the first identity mismatch the queue sees,
  not only on tab open. Fix the Risks sentence: `marketToken` is in secure storage, not
  SharedPreferences.
