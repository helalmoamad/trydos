---
ticket: manage-shop-locations-in-seller-dashboard
stage: plan
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-01
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Plan — manage-shop-locations-in-seller-dashboard

> Decide the approach before changing code. Plan only — no implementation here.
>
> **Revision 12 — filling the three holes that stopped `implement`.**
> Round 11 recorded **APPROVED** with nine `major` findings standing, and
> `implement` then blocked twice: once on the `IM-3` base (`BLK-IM3-BASE-02`,
> still unresolved — see *Validation strategy*), and once on three findings
> `review.md` had already dispositioned as expected `IM-10` blockers. **Those
> three are places this plan had no instruction at all, not a wrong one**, so an
> implementer bound by `IM-4` had nothing to follow. This revision writes them.
>
> The approach is untouched for the eighth round running and no finding has ever
> disputed it.
>
> **Five things this revision changes.** The first three are the blockers; the last
> two are owner answers that close findings which were open questions, not defects:
>
> 1. **`AC-12` is funded again** (`SR11-2`). Revision 11's own `SEC10-7` edit
>    deleted Step 10's prefill bullets and never replaced them, so no step said the
>    edit form is filled from the loaded record — while traceability still mapped
>    `AC-12` to Step 10. **Content destroyed inside a corrective edit**, the same
>    shape as round 9's `P9-3`. The bullet is back, and it now also carries the
>    prefill-strip rule the owner settled.
> 2. **The write-status enum is reset on every exit path, and by the clear**
>    (`P11-1`, `SEC11-4`). Withdrawing `_statusChangesInFlight` moved its failure
>    mode onto the enum that replaced it: nothing said the clear resets it, or that
>    the two request-not-sent paths write a terminal value, so one value left
>    in-flight would disable every row's status control for the app's lifetime on a
>    never-disposed singleton — **the exact failure the withdrawal was meant to
>    remove**.
> 3. **The change-status handler gets the same arrival guard the load has**
>    (`SEC11-5`). `_locationsLoadGeneration` was captured and compared only by the
>    load handler, so a toggle response landing after the dispose-clear still
>    rebuilt the wrapper and emitted. That re-opened on the toggle path the hole
>    `SR9-5` closed for the load.
> 4. **The editable-field strip is on the prefill only, never the controller**
>    (`SEC11-3`, owner-answered). Step 10a said "on the way in", which did not
>    distinguish them, and the difference decides whether the `AC-29` check can be
>    performed at all. It can: keystrokes are not filtered, so a member can type a
>    hostile name and save it, and **no seeding path outside the app is needed**.
> 5. **A member-typed direction-control character can leave this app, and that is
>    accepted explicitly** (`SEC11-10`, owner-answered). It is now an `Out of scope`
>    line rather than an unnamed gap.
>
> Also actioned, each named at round 11: the `AC-29` check's observation 3 is
> achievable (`SR11-3`/`SEC11-8` — the prefill strips the override, so the form
> shows the full stored value, not "all 255 characters"); the redaction command
> diffs what it claims to and fails on a PCRE error (`SEC11-1`, `SEC11-2`); the
> shared enum's coupling of all three writes is described rather than left implicit
> (`SR11-1`, `P11-6`); the transformer count and the clear handler's missing table
> row are fixed (`SR11-4`); the toggle allocates a new list and the `props` compare
> is per builder (`P11-2`, `P11-3`); the lever is scoped to the sanitize pass and
> its collision with Step 10a is named (`P11-4`); the country list is recorded as a
> second unbounded N (`P11-5`); the log-write cost covers all six calls (`P11-7`);
> the `HomeBloc` payload's PII is named (`SEC11-6`); the `AC-15` instruction to
> `/verify` is narrowed to its message clause (`SEC11-7`); the redaction scope gains
> the third artifact path (`SEC11-9`); and `spec.md`'s "three that remain" joins the
> correction list (`SR11-5`).
>
> **No line-count figure is stated anywhere in this document** (`SR11-6`).
> Revision 11 claimed a measured 1,527 and the file was 1,529 — the count was taken
> before two later edits. A number that must be re-measured on every edit will go
> stale on every edit, so it is not stated at all.
>
> **Still not fixed here, because this stage cannot fix them:** eight `spec.md`
> defects, now including `SR11-5`. `development.plan` produces `plan.md` only.
> They are in *Follow-up work this plan creates*, with the lifecycle gap they
> expose — a gap this work item has now hit **twice** at `implement` as well.

## Approach

Unchanged in shape since revision 2, and still the smallest change that satisfies
the criteria: follow the path the sibling Shop Info work item already cut, in the
same files. Add the calls to the dashboard's existing data source, repository and
use case layers; add one status enum, one list field and one set of events to the
dashboard's existing state and bloc; then replace `_LocationsWidgetState`'s local
mock list with that state, gated by the existing permission checker. Nothing new
is registered app-wide, and no other tab is re-pointed. The add/edit form goes in
its **own new file** rather than into `dashboard_page.dart`, which is already
past 3,600 lines.

The alternative — a self-contained Locations feature folder with its own bloc —
stays rejected: it needs a new app-wide registration (a protected runtime change)
and would sit beside eleven tabs that all read one shared state, for no gain the
criteria ask for.

**Three decisions this plan makes, settled across revisions 3 to 5 and not
reopened since.**

1. **The tenant guard is split by direction, and it costs no shared file.**
   Writes carry the captured shop id **on the request** through
   `RequestConfig.extraHeaders`. **Every write in this work item is a `POST`** —
   create, update and change-status alike, which the contract states outright
   ("Note the method: **POST**, not PUT") — and `post.dart:72-73` already honours
   `extraHeaders`. So **`put.dart` is not touched, `patch.dart` and `delete.dart`
   are not touched, and this plan changes no shared HTTP client at all.** `AC-23`
   is met with the client exactly as it stands today.

   The list **read** does *not* carry the header. Instead the bloc re-checks the
   shop id when the response arrives and **drops a result whose captured shop
   selection has changed since the request was built**. Say it that way and not
   "drops a result that belongs to another shop": the contract confirms the list
   body carries **no** seller id, so the compare is the captured value against a
   second read of the same prefs key — not tenant evidence from the response. It
   closes the window where a shop switch lands one shop's rows on another shop's
   screen, and it proves nothing about who the rows belong to. **`AC-22` rests on
   three things together:** the navigation shape (the switcher sits below the tab
   route, so switching pops this screen), the backend scoping every call by
   `X-Seller-ID`, and this guard as defence in depth.

   This was chosen over adding the merge to `get.dart`: that file is the shared
   `GET` client every screen in the app uses, and the arrival check satisfies
   `AC-22` without touching it. The reason the read needs a guard at all is that
   only `post.dart` honours `extraHeaders` today — `get.dart`, `put.dart`,
   `patch.dart` and `delete.dart` all accept the field and silently discard it,
   so writing `extraHeaders:` on a read would compile, look correct, and do
   nothing.

   **Two of the six calls are reads that carry no shop id of their own**, the
   create form's country list and the load-for-edit. Neither writes anything and
   neither is rendered into the list, so neither gets an arrival guard; the
   contract's own answer for the second is stronger than a client check — another
   shop's id returns the same `404` as a deleted one, on purpose, so no
   cross-shop record can arrive at all.

2. **The country picker is fed by the backend, per form.** Revisions 2 to 6 built
   it from the marketplace's allowed-countries data on `HomeBloc`. **That source
   is wrong**, and it fails in the direction hardest to see: it is a *superset*.
   The contract says the create form's list is "the active countries that have an
   **active shipping method**", so the app's list would show countries the backend
   refuses — the member picks one, fills the form, and only the save tells them.
   The picker reads whichever list the backend returned for **that form**:
   - **the add form** calls the create-form lookup when it opens, and only then.
     That call is behind the **create** permission, so calling it any earlier
     would hand a read-only member a refusal on a screen they are entitled to see
     (`AC-33`);
   - **the edit form** uses the country list that comes back **with the record**
     in the load-for-edit call. The contract designed it that way precisely so a
     member who may update but not create never has to touch the create-gated
     lookup. One call, no permission problem;
   - **the status filter is built from neither, and needs no country data at
     all.** It offers active / inactive / all and runs over the locations already
     loaded, sending no request (`AC-7`). The contract's *country* filter — built
     from the `country` objects on the loaded records — is not built at all
     (Out of scope). Its own trap still stands and is why it would be built that
     way if it were ever built: feeding it from the create lookup would 403 for
     exactly the read-only members a filter is for.
   - **`status = 0` is a real value.** The filter tests for "not set", never for
     falsy, or choosing "inactive" silently does nothing.

   **The picker requires an explicit choice and does not default.** Revision 4's
   "the shop's own market country" is a value the client does not hold: the shop
   info model has no country field, and the become-seller flow builds
   `locationCountryIso` from the **app user's** prefs
   (`userCountryIsAvailable == 1 ? userChoosedCountryIso : countryIso`, with a
   literal `'USD'` fallback) — the device's chosen market, not a property of the
   shop, and the same mutable value the shared dropdown writes. `OQ-15` is open,
   so the member chooses. **This is cheap to live with:** the list the member
   chooses from is the backend's own, so a wrong pick is a wrong pick from a valid
   set rather than a value the backend never accepts.

   The shared `CountryDropdown` is excluded — its `onChanged` writes
   `setUserChoosedCountryIso` / `setUserCountryIsAvailable` into prefs, and
   `base_api.dart:25-27` builds the `country` header of **every** request from
   exactly those values. `lib/common/constant/countries.dart` is excluded too: it
   is the phone dial-code table.

   **The `HomeBloc` *read* leaves this plan; `HomeBloc` itself does not.** The
   screen no longer reads `getAllowedCountriesModel`, so `AC-4`'s stale-language
   caveat — a property of that cached data — no longer applies, and
   `spec.md > Amendment A-5` records the criterion change. But the app-wide home
   singleton stays on the integration surface, because the shared interceptor
   dispatches into it on every failed request and this work item adds six new call
   sites that reach it. **Integration surface states in full what travels that
   path**, and revision 11 corrects it: it is not only tokens.

3. **The list reloads on every entry to the tab, and is cleared on dispose.**
   Revision 2 asked for both a clear-on-dispose and a skip-the-refetch, which
   cancel each other exactly out. One is kept. Reloading costs one request per
   tab entry — the same as the other dashboard tabs — and buys always-fresh data,
   a bounded memory footprint in a never-disposed singleton, and no stale cache
   when the same shop is edited on the website. The unasked-for refresh control
   goes with it.
   **The clear's stronger effect is CPU, not memory** (`P11-8`): it drives N to
   zero, so every *other* dashboard tab's emissions stop paying the O(N) `props`
   compare on the shared state while this screen is closed. That is this plan's
   best answer to the unbounded N of Step 7, and it was going unstated.

**What this plan can decide, and what it cannot.** `OQ-1`, `OQ-2`, `OQ-3`,
`OQ-4`, `OQ-5`, `OQ-6` and `OQ-7` are **answered** — the contract closed them, and
`spec.md` records the amendments. The intake condition is satisfied rather than
waived: this plan names endpoints, field names and permission strings **because a
documented contract confirms them**, not because it assumed them.

**The open questions are counted in exactly one place — Step 0's table below.**
No other section states a number (`SR10-1`). Revisions 7 to 10 wrote the count
into five places and it disagreed in four of them; a number written five times
will disagree again, so it is now written once and every other section refers to
the table instead.

## Steps

0. **The contract — what it says, and what it still does not.**
   Source: `.claude/docs/mobile-seller-dashboard-locations-api-guide.md`. Read it
   next to the main dashboard guide, which holds the shared halves it points back
   to: the base URL, `Authorization` + `X-Seller-ID`, the `country` and `lang`
   headers, the `{ success, message, data }` envelope, and the permissions call.
   The main guide has **no** Locations section and is not the reference for this
   screen.

   **The six calls, with the permission each needs:**

   | # | Call | Permission | Used by |
   |---|------|-----------|---------|
   | 1 | list locations | read | the tab's one request (Step 8) |
   | 2 | the create form's country list | **create** | the add form only, on open (Step 10) |
   | 3 | create | create | save on the add form |
   | 4 | load one record for editing, **with its country list** | read *or* update | the edit form, on open |
   | 5 | update | update | save on the edit form |
   | 6 | change status | change-status | the row's activate / deactivate control |

   **There is no delete call.** Deactivating does not detach the location from
   products that already point at it, and the screen must not suggest it does
   (`AC-32`).

   **Facts that shape the code, each landing in a named step:**
   - **Every write is a `POST`**, update included. → Approach decision 1; no
     shared HTTP client is touched.
   - **Coordinates are optional**, and come back as **strings** while they must be
     sent as **numbers**. → Step 2 parses them; Step 10 preserves them untouched
     through an edit (`AC-34`).
   - **`name` is `max 255` and unique per shop per country.** → Step 10 checks the
     length before sending; the uniqueness refusal is the backend's to report,
     because the screen never holds the shop's locations in other countries.
   - **A `422` carries the field name with each reason.** → Step 3a traces why
     that list cannot reach this screen, and Step 10 shows the one message that
     does (`AC-16`).
   - **The list pages**, and the page size is a shop setting the request cannot
     influence. → `AC-1` stands: one request, and reaching the rest is a separate
     ticket. `meta` carries a total, so `AC-5`'s header badge shows the number the
     shop has.
   - **`status=0` is a real filter value.** → Step 11 tests the filter for "not
     set", never for falsy, or the "inactive" choice silently does nothing.
   - **A `404` on the edit load means deleted *or* another shop's** — the same
     answer on purpose. **The screen never sees that `404`:** Step 3a shows it
     arriving as a `400` like every other failure, so Step 10 closes the form and
     reloads on **any** failed load. The contract's distinction is real; this
     client cannot act on it.

   **The questions the contract does not answer, and why each is safe to carry.**
   The contract's own closing line says the full field limits are unpublished, so
   nothing beyond what it states is assumed. **This table is the only statement of
   which questions remain open** (`SR10-1`):

   | Open | What it would change | Why it does not block |
   |------|----------------------|-----------------------|
   | `OQ-11` — is a become-seller location the same record? | `spec.md > Out of Scope`'s "no other flow is affected" | It changes what this work item may **claim**, not what it builds. Recorded as unproven in `spec.md`, and the edge case stands |
   | `OQ-13` — is a country name localized by the `lang` header? | nothing | `AC-4` is written so either answer satisfies it: the name is shown as received |
   | `OQ-14` — is create idempotent server-side? | how hard Rollback has to work | The screen prevents the second send two ways (`AC-10`), and the per-country name uniqueness refuses a same-value twin. **Nothing else compensates** — `Rollback` builds no confirmation and no criterion covers one, so the test-shop rule is the only other mitigation (`SR10-2`; revisions 7 to 10 claimed a confirm step here that `Rollback` had already withdrawn) |
   | `OQ-15` — what does the backend store as the shop's own country? | whether the picker may default | The picker does not default (Approach 2). The member chooses from the backend's own list, so no answer is needed to be correct — only to be more convenient |
   | `OQ-16` — is the `422` toast message specific enough to act on? | **whether `AC-16` can be met at all** | Added by `spec.md > Amendment A-12`. It changes nothing that is *built*: the per-field list never reaches this screen, so the form has nothing to bind whatever the answer is. It decides an **outcome** — if the top-level `422` message is generic, `AC-16` is recorded **not met** rather than argued into met, and the fix is a shared-handler change in its own ticket. Answerable only by observing a real duplicate-name refusal, which the manual run at `/verify` does |

   **Ask Mohamad Hassan for the questions in the table above when convenient.
   None is a precondition for `implement`** — each row says what the answer would
   move, and for every one of them the answer moves nothing that is built here.
   **`OQ-16` is the one to ask first**: it does not block the build, but it
   decides whether `AC-16` can be recorded met.

1. Add the locations endpoints: **one base constant** for the collection (list
   and create share it — they differ only by verb), **one constant for the create
   form's country list**, and **one function per per-record path**, taking the id.
   Three per-record paths exist (load-for-edit, update, change status), so three
   functions, not one constant per verb on a single path. All built from the
   existing `shopScope()` extension so the base URL and the `/api/v1/shop/` prefix
   stay in one place.

   **Each takes `int id`, not `String`.** The existing `deleteUserEP(String
   userId)` is the *shape* to copy, not the *signature*: a `String` parameter here
   would undo Step 2's typing at the exact boundary that builds the URL, since
   anything at all can be interpolated into a string path. Typing the parameter is
   what makes Step 2's rule hold end to end. **The id is interpolated, never
   concatenated by a caller**, so no call site can build a path from a blank id.

2. Add a location model that reads the record tolerantly — fields nullable, the
   list read from the wrapper the backend returns, and **both `meta.total` and
   `meta.per_page`** carried, which Step 0 confirms exist. `meta.total` backs
   `AC-5`'s header count; `meta.per_page` is what Step 7's `/verify` observation
   reads to record the real N.

   **Three parsing rules the contract makes explicit, all easy to get silently
   wrong:**
   - **`latitude` and `longitude` arrive as strings** (they are decimal columns)
     and must be **sent back as numbers**. The model parses on the way in and
     emits numbers on the way out. A string sent back is the kind of mistake that
     passes review and fails at the backend.
   - **The country is on the record**, as an object carrying the readable name.
     The list draws its country from there and from nowhere else, so no cached
     device data is read to render a row (`AC-4`, `spec.md > Amendment A-5`).
   - **`address`, the coordinates and the country can each be absent.** A row
     missing any of them renders without it — never with a placeholder that could
     be mistaken for a value.

   The change-status call gets **its own small response model**, because `AC-30`
   requires the row to take the status the backend returned rather than the one
   the screen asked for. The other writes reuse the dashboard's existing
   `ReadOnlyMessageFromApiModel`.

   **Two `copyWith`s are funded, not one** (`P9-2`, extended by `SEC10-9`). Step
   8's handler writes the toggled row in place from the change-status response
   instead of refetching, and that needs a `copyWith` on the **record**. It also
   has to rebuild the **list wrapper** that holds the rows — and that wrapper
   carries the `loadedForSellerId` stamp, so the wrapper needs one too. **The
   wrapper's `copyWith` preserves the existing stamp verbatim; it never re-reads
   prefs.** Both failure modes were live in revision 10: re-reading would re-stamp
   a stale list with the current shop id and let Step 11's first-frame gate pass
   for the wrong shop, and dropping the stamp would make it null — which counts as
   a mismatch, so every toggle would flip the screen back to loading.

   **The list result carries a `loadedForSellerId` stamp — on the model, and
   nowhere else.** This mirrors `GetShopInfoModel`, and the bloc writes it when
   the response arrives. `_ShopInfoWidgetState` reads the identical field
   (`bloc.state.shopInfo.loadedForSellerId`, `dashboard_page.dart:3424`), and Step
   11's compare-at-open reads this one. **Do not remove it as unused** — its
   reader is a widget, not the list rendering. **Every write of the list writes
   the stamp**, and a list whose stamp is null counts as a mismatch, not a pass.

   **The record id is required by every per-record call — editing, loading for
   edit, and changing status alike.** **The id is typed as `int` and must be
   positive**; a record whose id is missing, non-numeric or non-positive is
   rendered, but **neither its edit control nor its status control is offered**,
   so it can never become a path segment. Step 11 states the same rule where the
   controls are actually built (`SEC10-11`). "Non-blank" was the old rule and it
   was too weak: three endpoints interpolate this value into a URL while the rest
   of the record is parsed tolerantly, so a crafted or non-numeric id would have
   been interpolated as-is. Typing it is a one-line structural fix, not a
   defensive check.

   **Success is read from the body's success flag, never from the HTTP status**
   (`AC-15`, Step 0).

3. Add one data source method per call, following `getShopInfo()` and
   `getGalleryImages(...)`:
   - **each write** passes the captured shop id through
     `RequestConfig.extraHeaders`, so it travels on the request (`AC-23`). The key
     is spelled exactly as `base_api.dart:34` spells it — `X-Seller-ID` — because
     a typo silently sends a second, wrong header rather than failing. It is built
     from a single `const` at the one call site, never from a variable or a
     caller-supplied map, so this work item cannot exercise `post.dart`'s
     override door;
   - **the read passes no `extraHeaders`**, because `GetClient` would discard it.
     The read is guarded on arrival instead (Step 8);
   - **a null or empty captured shop id means the request is not sent at all**,
     for reads and writes alike. `getXSellerId` is nullable, so a null would
     compare equal to a null on arrival — a check that passes having verified
     nothing — and a write would send an empty header and fall back to whatever
     the shared map holds;
   - no method sets `country` or `lang` — the shared header builder already does;
   - **no method reads `detailed_error[]`, because it cannot reach one.** See
     Step 3a for the trace and why this plan does not change it.

3a. **The error path — what the screen can show when a write is refused, and why
    this plan does not widen it.**

    **What actually happens today, traced end to end and verified in the source:**

    1. `log_interceptor.dart:208-227` catches every `DioException`, wraps it as
       `{error_code, error_message, error_type, original_data}` and calls
       **`handler.resolve(errorResponse)`** — converting the failure into a
       *successful* `Response`. **No `DioException` ever reaches a client.**
    2. `post.dart:113-124` sees a non-2xx status and throws
       `getException(statusCode:, message: response.data['message'])`. That body
       has no `message` key — only `error_message` — so **the message is null**.
       (`post.dart`'s own `.catchError` at `:98-111` never fires either, for the
       same reason: nothing threw.)
    3. `handling_exception.dart:66-79` catches `ServerException`. Its 422 branch
       is guarded by `e.hashCode == 422`, which can never be true for an exception
       object, so it falls through to
       `ServerFailure("ServerException", statusCode: 400)`. Its `DioException`
       branch, which *does* read `response.data['message']`, is unreachable.
    4. **`Failure.message` is the literal `"ServerFailure"`, not
       `"ServerException"`.** `failures.dart:9-10` is
       `ServerFailure(String s, {String? message, ...}) : super(message ?? "ServerFailure", ...)`
       — the **positional argument is discarded**.
    5. **`Failure` carries only `message` and `statusCode`**, so even a parsed
       field list would have no channel to the form.
    6. **The status code is flattened to `400` for every failure this screen can
       act on — but not literally for everything.**
       `handling_exception.dart:79` returns `statusCode: 400` on every path but
       the dead 422 branch, and `StatusCode` names only 200, 201, 400, 401 and
       500 — so a **403, a 404 and a 422 all arrive as 400**. Two do **not**
       collapse: `getException` still maps **401 → `Unauth`** and **500 →
       `ServerExceptionForCode500`** (`handling_exception.dart:32-47, 55-65`).
       What follows for this screen: it cannot tell a permission refusal from a
       deleted record from a validation failure, because those three are the ones
       that collapse.

    **The raw body never leaves `lib/core/api/`, and neither does the real status
    code.** Per-field binding is impossible without changing a protected shared
    file, and so is any rule that branches on which failure occurred.

    **What follows, written out so no step assumes otherwise:**
    - Step 10 closes the edit form and reloads on **any** failed load, not on a
      `404` — it cannot see one.
    - `AC-33` cannot distinguish "the create lookup was refused because the member
      may not create" from any other failure of that call; it shows the form's
      empty-picker state either way.
    - `spec.md`'s edge case about opening a location another member deactivated is
      amended to the same effect: the screen closes and reloads, without claiming
      to know which happened.

    **The decision: do not change `lib/core/api/`. Record the limitation
    instead.** The alternative — adding `detailed_error` extraction and a richer
    `Failure` to the shared handler — would fix this properly and for every
    feature, but it is a protected-path change on the single funnel every API call
    in the app passes through, made to serve one screen, in a work item whose
    largest achievement is touching no such path. `CLAUDE.md`'s small-change rule
    and "every change must be reversible and individually verifiable" both point
    the other way. **If the owner wants the shared fix, this is the decision to
    refuse.**

    **What the member actually sees.** `log_interceptor.dart:92-105` shows the
    backend's real `message` in release (`showInRelease: true`) **only when the
    status is 400 or 422**. So:

    | Failure | What the member sees |
    |---------|----------------------|
    | 422 — validation, including the duplicate-name refusal | the backend's own message, through the shared toast |
    | 400 — anything the backend returns as 400 | the backend's own message, through the shared toast |
    | **403 — permission refused** | **no backend text at all**; only this screen's own translated text |
    | **404 — record gone or another shop's** | **no backend text at all**; the form closes and the list reloads |

    The in-screen form shows this screen's own translated failure text in every
    case; `Failure.message` — the literal `"ServerFailure"` — is never displayed.

    **The criteria amended in `spec.md` to say exactly this:** `AC-14` (narrowed
    to what the form does, with the toast noted for 400/422 only), `AC-16` (no
    per-field binding, and no claim that the backend's text names the field),
    `AC-21` (the screen's own text, no backend words on a 403), and `AC-29`
    (split). They join `AC-15` and `AC-18` as recorded limitations: the honest
    description of behaviour, not the preferred design.

    **What the toast actually is.** It is not an OS toast. `show_message.dart`
    renders the raw message in a full-width `Overlay` through `MyTextWidget` with
    **no `maxLines`**, so an unbounded string is an unbounded-height overlay over
    the current route. This work item newly routes **member-controlled** text
    through it: a location name typed by one member comes back inside the
    duplicate-name 422 and is shown to another member of the same shop. **Capping
    and stripping at `show_message.dart` is a follow-up ticket** — it is app-wide
    and not done here. `spec.md > AC-35` records it as a residual.

4. Add the matching repository interface methods and their implementations,
   returning `Either<Failure, T>` through `handlingExceptionRequest`.

5. Add one `@injectable` use case per call, each with its own small `Params`
   class, following `GetShopInfoUseCase` / `UpdateShopInfoUseCase`. **Six calls,
   six use cases** — list, create-form country list, create, load-for-edit,
   update, change status.

6. Add the four permission names to the dashboard permission enum, and add
   `canReadLocations()`, `canCreateLocation()`, `canUpdateLocation()` and
   `canChangeLocationStatus()` to the permission checker, each
   `SUPER_ADMIN`-or-the-named-permission, like the existing methods.
   **`canCreateLocation()` also gates the create form's country list call**, which
   the contract puts behind the create permission — that is the whole reason
   `AC-33` exists. **The read gate fails closed** — an empty permission list is
   treated as denied, per the amended `AC-18`. No attempt is made to distinguish
   "unknown".

7. Add to the dashboard state: a `GetLocationsStatus` enum including a
   `permissionDenied` value, the list, the total, an error message field, and
   **one** status enum for the write calls. **Each new field is added in three
   places together — the class field, `copyWith`, and the Equatable `props`
   list.** A field missing from `props` makes the state compare equal, so the
   screen never rebuilds and nothing fails at compile time. Nothing is added to
   any other feature's state.

   **No separate shop-id field is added to the state** — the stamp lives on the
   list model (Step 2), exactly as `GetShopInfoModel` carries its own, so there is
   only ever one stamp and no way for two to disagree.

   **The write-status enum is one shared value, not one per row, and Step 8's
   transformer is chosen to match it** (`P10-2`). Revision 10 funded a single
   shared enum here while Step 8 justified `concurrent()` by "two different rows
   may toggle at once" — a case this field makes unreachable, because a single
   shared enum disables **every** row's status control while any one write is in
   flight. Revision 11 does not add a per-row map to make the justification true;
   it keeps the one field and Step 8 guards for the state that exists. **The
   consequence, stated rather than hidden:** during a status change no other row's
   status control is usable. For a screen showing one page of a shop's locations
   that is acceptable, and it is one field instead of a map in `copyWith` and
   `props`.

   **One field means all three writes share it, and that is the whole of the
   coupling** (`SR11-1`, `P11-6`). `create`, `update` and `change status` each
   carry their own `droppable()`, and a `bloc_concurrency` transformer is keyed on
   the **event type** — so it guards a second event *of the same kind*, never a
   second kind. A save and a status toggle can therefore be in flight together and
   both write this one field, with the last completion winning. **Why that is
   accepted rather than fixed:** the add/edit form is a sheet over the list, so
   while a save is in flight the row controls are not reachable, and the reverse —
   toggling a row, then opening a form before the toggle returns — costs at worst a
   stale disabled state that the next emission clears. Splitting the field into one
   per write family would add a second enum to `copyWith` and `props` for a case
   the UI shape already prevents. **What is not acceptable is leaving it
   undescribed**, which is what revision 11 did.

   **The enum is reset on every path that leaves a write, and by the clear**
   (`P11-1`, `SEC11-4`). This is the rule revision 11 omitted, and the omission was
   serious: withdrawing `_statusChangesInFlight` was justified by this field
   covering the same case, but nothing said this field is ever cleared. **Every one
   of these writes a terminal value — success or failure — before the handler
   returns:**
   - the call succeeded, and the row (or the list) was written;
   - the call failed, at any layer;
   - **the permission was absent**, so no request was sent (Step 8);
   - **the captured shop id was null or empty**, so no request was sent (Step 3);
   - the arrival guard dropped the response (Step 8).

   **And the clear event resets it to its initial value**, alongside the list and
   the counter, so a dispose can never leave it in flight. Without both rules one
   value stuck in flight disables **every** row's status control for the lifetime
   of the app, with no error and no state change — which is precisely the silent
   permanent-disable failure this plan cited to reject `throttleDroppable` and then
   to withdraw the in-flight id set. Getting it wrong a third time by leaving it
   unstated is the reason it is written out here as a list rather than as a
   sentence.

   **No changed-row signal is added, and that is a decision, not an omission**
   (`P9-1`). Revision 9's Step 8 promised the widget a single-item replacement on
   a status toggle, which needs a field here saying *which* row changed; this step
   never added one, so the promise could not be carried out. Step 8 withdraws the
   promise rather than this step funding the field: a toggle emits a replaced list
   like any other write, the widget rebuilds the display copy for it, and what the
   no-refetch decision buys is the network round trip and the parse. One less
   field in `copyWith` and `props`, and no second way for the list and the signal
   to disagree.

   **The list holds one page, and the size of that page is not this client's to
   know.** The contract sets it from the shop's own `pagination_limit` setting,
   which the request cannot read or cap — so the `props` comparison, the
   display-copy build, the sanitize pass and the client-side filter all scale with
   an **N this plan cannot bound**, on a singleton every dashboard tab reads. The
   earlier claim that the bound is "simply true, not conditional" is withdrawn.

   **The lever, and it is one `AC-1` permits — but it is narrower than revision 11
   claimed** (`P10-1`, corrected by `P11-4`). Revision 10 named "capping the
   display copy's **item count**", which `AC-1` forbids outright: every location
   returned by one request must be shown. **The available lever is per-row work,
   not fewer rows:** sanitize each display item on first render of that row and
   cache the result on the item, so the sanitize becomes O(visible) against the
   lazy `ListView` that is already there.

   **What it does not cover, stated so the lever is not oversold.** Of the four
   O(N) passes above it reaches **one**: the sanitize. The `props` comparison and
   the client-side filter stay O(N) and have no lever at all, and the display-item
   list must still be allocated eagerly for a per-item cache to have somewhere to
   live. Revision 11 said "the eager O(N) pass becomes O(visible)" as though it
   covered the lot; it covers a quarter of it.

   **And adopting it means rewriting Step 10a's build-once rule**, which forbids
   exactly this: sanitizing on first render *is* `itemBuilder` work. That is not a
   contradiction in this plan — the lever is **not** done here — but the follow-up
   that takes it up must change Step 10a rather than sit beside it, and *Out of
   scope* says so. Building once is the simpler thing to get right first, and it is
   what this work item does.

   **The observed N is recorded at `/verify`** from `meta.per_page` and
   `meta.total`, as a resource observation rather than an assumption. **So is a
   second N nobody has sized** (`P11-5`): the create form's country list is also a
   backend-sized collection, fetched, parsed **and sanitized** on every add-form
   open, and the load-for-edit carries its own copy sanitized on every edit tap.
   Ten edit opens is ten country-list sanitizes. `/verify` records the returned
   country count alongside `per_page` and `total`.

   **The state holds raw text only** — see Step 10a.

8. Add the events — load, clear, create, update, change status — and their
   handlers in the dashboard bloc:
   - each handler skips the call and emits `permissionDenied` when the permission
     is absent;
   - **each write** carries the shop id captured before the request as a
     per-request header (Step 3), so a shop switch mid-flight cannot retarget it;
   - **the load captures the shop id before the request and re-checks it when the
     response arrives.** If the open shop changed in between, the result is
     **dropped** — not stored, not rendered — and the state returns to a clean
     state for the new shop. This is what satisfies `AC-22` without changing the
     shared `GET` client;
   - **a load result is also dropped if the list was cleared after the request
     started**, not only on a shop-id mismatch (`SR9-5`). Without this, a response
     landing after the screen is disposed stores a full list in a singleton
     nothing will dispose, and the shop-id check does not catch it because the
     shop did not change.

     **Where the counter lives, because "or equivalently the fact that a clear
     ran" is not something `IM-4` can carry out** (`SR10-3`): the bloc holds
     `int _locationsLoadGeneration = 0` — **a plain field on the bloc, not on
     `DashBoardState`**, because nothing renders from it and every mutation of a
     state field emits to all eleven tabs. The clear handler increments it, and so
     does a shop mismatch. It is named in **Files to change** under
     `dashBoard_bloc.dart` (`SR10-7`);
   - **both handlers that write the list capture and compare it — the load *and*
     change-status** (`SEC11-5`). Revision 11 gave the guard to the load handler
     only, which left the toggle path open: change-status also writes the list, so
     a status response landing after the dispose-clear — or after a shop-mismatch
     clear, which increments the same counter — would still rebuild the wrapper and
     **emit into the never-disposed singleton** that `become_seller_page.dart`
     listens to with no `listenWhen`. That is the same hole `SR9-5` closed for the
     load, re-opened on the other write path.

     **The rule, stated once for both:** capture the shop id and
     `_locationsLoadGeneration` **before** the request; when the response arrives,
     compare both; if either changed, **drop the response** — do not write the row,
     do not emit — and write the terminal write-status value (Step 7) so the
     controls do not stay disabled. The create and update handlers need no such
     guard: they refetch rather than write the list, and that refetch is itself a
     load, which carries the guard;
   - **refresh after a save has two paths, and the split is the contract's, not a
     convenience.** **Create and update** refetch the list: neither response
     carries enough to rebuild the row in place, saving is rare, and the second
     request is cheap. **Change-status does not refetch.** The contract says
     outright that the new value comes from the response and there is no need to
     reload after a toggle, and `AC-30` requires the row's marker to be **the
     value the backend returned** — so the handler writes that one row in place
     from the change-status response model (Step 2) and issues no request.

     **The bloc owns that write, and only the bloc** (`P8-1`, `SR10-4`). It
     builds **a new list** — a fresh `List` with the toggled element replaced via
     the record `copyWith`, **never a mutation of the list it already holds**
     (`P11-2`) — rebuilds the wrapper with its **existing stamp preserved
     verbatim** using the wrapper `copyWith` (Step 2, `SEC10-9`), and emits. Step
     11's widget renders the result and writes nothing.

     **Why "a new list" is a rule and not an implementation detail:** mutating in
     place would leave the old and new state holding the **same instance**, so the
     `props` comparison returns equal and **the emit is silently dropped** — the
     screen would never show the toggle, with no error and nothing to debug. That
     is the identical silent-equality failure Step 7 warns about for a field missing
     from `props`, arriving by a different door;

     **A toggle's real cost** (`P10-3`, corrected by `P11-2` and `P11-3`).
     Revision 10 called it "the display rebuild", which named one pass of several;
     revision 11 said four and undercounted twice. Emitting a replaced list costs
     the new-list allocation above, then the display-copy build **and** sanitize
     (one traversal — Step 10a does both in the same pass), the filtered-list
     recompute Step 11 owns, and **one `props` elementwise compare per builder
     keyed on the list**, not one in total: Step 11 requires a `buildWhen` on every
     new builder, so the list, the header badge and the error banner each pay their
     own compare if each is keyed on the list. **Key the badge and the banner on
     scalar fields — `meta.total` and the error message — so only the list builder
     pays O(N).** That instruction is the useful half of this paragraph.

     **What not refetching buys is the network round trip and the parse, and that
     is the whole of the saving.** It is still worth having: the refetch would have
     cost the round trip *and* every pass above;

     **A failed refresh does not turn a successful save into a failure:** the save
     is still reported as successful, and the refresh error is shown separately,
     so the member is never told their save failed when it did not;
   - **the load runs on every entry to the tab**, and a clear event fires on the
     screen's dispose. There is no skip rule and no cache to go stale;
   - a clear also fires on a shop mismatch, so a never-disposed singleton does not
     hold one shop's list while another is open;
   - **the table below covers every handler this step defines**, and the two
     transformers it uses both come straight from `bloc_concurrency` (`^0.2.2`,
     `pubspec.yaml:119`) — `droppable()` and `restartable()`. **Revision 11 said
     "all three", a residue of the withdrawn `concurrent()`, and left the clear
     handler out of the table while claiming every handler had a row** (`SR11-4`).
     Both are fixed here. **`throttleDroppable` is not used**: it is not a shared
     helper but a local definition copied into six files, and **every copy pairs it
     with `const throttleDuration = Duration(minutes: 2)`**. An implementer
     following repo convention would silently drop a member's second save or status
     toggle for two minutes, with no error and no state change.

     | Handler | Transformer | Why |
     |---------|-------------|-----|
     | load list | `restartable()` | a tab entry and a post-save refresh must not land out of order for the same shop |
     | create-form country list | `restartable()` | the form can be closed and reopened; only the newest fetch matters |
     | create | `droppable()` | backs `AC-10` at the bloc level rather than relying only on a disabled button |
     | load-for-edit | `restartable()` | opening a second row supersedes the first |
     | update | `droppable()` | same double-tap guard as create |
     | change status | `droppable()` | one status change at a time — which is the only thing Step 7's single shared write-status enum can represent |
     | clear | **none — the package default** | it issues no request and awaits nothing; it increments `_locationsLoadGeneration` and resets the list, the error field and the write-status enum synchronously. Sequential handling is what it needs, and adding a transformer here could reorder a clear against the load whose result it is meant to invalidate |

     **The change-status guard is `droppable()`, and the in-flight id set is
     gone** (`P10-2`, `SR10-3`, `SEC10-10`). Revision 9 wrote "`droppable()`,
     keyed per row", which a `bloc_concurrency` transformer cannot express — it
     sees the event type, not the payload. Revision 10 replaced it with
     `concurrent()` plus `final Set<int> _statusChangesInFlight` on the bloc, and
     that created two new problems: the two-different-rows case it was funded for
     **cannot occur**, because Step 7's single shared write-status enum disables
     every row's control while any write is in flight; and the set was cleared
     only in the handler's `finally`, so on a never-disposed singleton one id left
     behind by any path that skipped it would disable that row's toggle for the
     app's lifetime — **the identical silent failure used to reject
     `throttleDroppable`.**

     **What replaces both: nothing.** `droppable()` drops a second status event
     while one is in flight, which is exactly what the shared enum already tells
     the screen. There is no set to leak, nothing to clear on dispose, and no
     mechanism whose justification has to be kept true. The double-tap this guards
     is the one that outruns a rebuild; the different-row case is unreachable
     through the UI, and if a later ticket makes the write-status per row, the
     transformer is what changes with it.

     **`dashBoard_bloc.dart` uses no transformer today** and imports
     `bloc_concurrency` nowhere, so the import joins Files to change. Nothing else
     is added: `droppable` and `restartable` come straight from the package, so no
     local helper is copied and no throttle duration exists to get wrong.
   - **`restartable()` cancels the handler, not the request** — no `CancelToken` is
     introduced. A superseded form-open still puts its request on the wire; only
     its emission is discarded. The `/verify` observation therefore counts
     **requests**, not renders.

9. Add the log helper for this screen — **a local development trace, and nothing
   else**. This screen sends **no failure report of its own**, and the plan names
   no reporting channel. **"While developing" is a property of the code, not of
   intent:** the helper is gated on `kDebugMode` (or the repo's existing
   debug-only logger), so a release build writes nothing to device logs.
   - **The trace carries no request body and no headers** — only the action, the
     outcome and the shop id.
   - `SendErrorToMobileErrorLogEvent` is **not** used as a channel here. It POSTs
     the member's stored service tokens to the backend, so using it deliberately
     would have made `AC-27` impossible.
   - It is also unnecessary, and this is the part that matters: **the shared error
     interceptor already dispatches that event on every failed request**,
     including the ones this screen makes. A failed save here still causes that
     report to be sent; this screen neither adds to it nor can prevent it.
     **Integration surface states in full what that report carries** — it is more
     than tokens (`SEC10-3`).
   - Both the interceptor and the shared request log are **pre-existing and
     unchanged here**, recorded the same way the amended `AC-24` and `AC-27`
     record shared behaviour.

10. Create the add/edit form as a new widget file:
    - **Two required fields and one optional one:** name and country are required,
      the address is not (`AC-8`, `spec.md > Amendment A-7`).
    - **The country list comes from the backend, and which call provides it
      depends on which form is open:**
      - **add form** — calls the create-form country list **when the form opens**,
        never before (`AC-33`). That call is behind the create permission, so
        calling it while merely showing the list would 403 for a read-only member
        on a screen they may see;
      - **edit form** — takes the country list that arrives **with the record** in
        the load-for-edit call. The contract designed that call to carry both for
        exactly this reason: a member who may update but not create never touches
        the create-gated call.
    - **`HomeBloc`'s allowed-countries data is not read at all.** That removes the
      *country* dependency on the app-wide home singleton — but **not** every
      dependency on it; Integration surface says which ones remain and why. The
      shared `CountryDropdown` stays excluded (its `onChanged` writes prefs that
      the `country` header of every request is built from), and
      `lib/common/constant/countries.dart` stays excluded too: it is the phone
      dial-code table;
    - **the list is fetched once when the form opens**, held in the form's own
      state, and not re-fetched while the member types. If that fetch fails or is
      refused, the form shows an empty picker with **this screen's own translated
      text** and **offers no save** — a create with no country cannot succeed, so
      letting the member fill the rest first would waste their work. **The form
      shows no backend text of its own**, on any failure: Step 3a's table is the
      whole rule, and a refusal of this call is a `403`, which carries no backend
      text at all. Where the failure is a `400` or a `422` the shared toast shows
      the backend's words **outside this form**, which the form neither controls
      nor suppresses;
    - **the item list is built once, when the response arrives** — in the single
      `setState` that stores the fetched list — and never in `build` and never in
      `itemBuilder`. Sanitizing (Step 10a) happens in that same place. A lazy list
      in a sheet is used rather than a plain dropdown over the whole set, because
      the form rebuilds while the member types;
    - **the per-open request cost is accepted and recorded, not cached.** Opening
      the add form costs one country-list request; opening the edit form costs one
      load-for-edit. Opening ten rows in a row is ten requests, each returning an
      almost identical country list. **No cache is added**, for three reasons,
      each scoped to the call it actually covers:
      - **the add form's country list** — opening a form is a deliberate,
        low-frequency action, not a scroll or a rebuild;
      - **either call** — a cache held across form opens would need its own
        invalidation on shop switch and on dispose, which is the second read path
        the owner already dropped once at revision 4;
      - **the load-for-edit only** — it is not merely a country list. Re-fetching
        is how the screen learns the row is gone or refused, and a cache would
        hide exactly that.

      **The cost is a disk cost as well as a network one** (`P10-4`). The shared
      clients write every request and response into plain shared preferences on
      every call, so ten form opens is also ten read-modify-write cycles over that
      log. **This is recorded as an expected observation at `/verify`**, counting
      **requests, not renders** — `restartable()` discards a superseded emission
      but its request is already on the wire;
    - **the stored footprint grows with it, and `AC-24` records it.** Ten form
      opens is ten more copies of location records at rest. `AC-24` covers **all
      six** calls, and records that `X-Seller-ID` is **not** among the log's
      redacted keys, so the tenant id is stored in plaintext beside the names and
      addresses. Nothing here changes that behaviour — the criterion stops
      understating it;
    - **the picker has no default — the member chooses** (Approach 2). Defaulting
      to the app user's prefs country would quietly create a location in the wrong
      country, on a record that can never be deleted;
    - **the name is checked against 255 characters before sending** (`AC-8`), and
      the per-country uniqueness is **not** checked on the device: the screen never
      holds the shop's locations in other countries, so guessing would produce a
      wrong refusal;
    - **a refusal is not bound to a field, and the form does not show the
      backend's words.** The form stays open with the member's input intact and
      shows **this screen's own translated failure text**; the backend's own
      message — when the status is 400 or 422 — reaches the member through the
      shared toast, outside this form. On a **403** there is no backend text at
      all. `AC-14`, `AC-16` and `AC-21` are amended to say exactly this;
    - **coordinates are never edited here and never dropped.** The form shows no
      map and no coordinate fields (`OQ-3` answered; the map picker stays out of
      scope), and an edit re-sends whatever the record already carried, parsed back
      to numbers (`AC-34`, Step 2). Silently sending null would erase a map point
      the website set;
    - **a failed load-for-edit closes the form and reloads the list — on any
      failure, not on a `404`.** Step 3a shows every failure arrives as status
      `400`, so `404`, `403` and `422` are indistinguishable here. **A reload after
      a failed open is not an error state** — the list simply comes back current.
      **One failed open triggers at most one reload, and no retry loop** (`P10-5`):
      a row that fails repeatedly costs two requests and one rebuild per tap, which
      is the member's own repeated action, not the screen retrying on its own;
    - **the edit form opens already filled from the record the load-for-edit call
      returned** — its name, its address and its country (`AC-12`). **This bullet
      was deleted by revision 11's own `SEC10-7` edit and is restored here**
      (`SR11-2`): between revisions 11 and 12 no step said the form was prefilled
      at all, while the traceability table still mapped `AC-12` to this step, so an
      implementer bound by `IM-4` had nothing to build. The values are filled from
      the **raw** record with direction-control characters stripped on the way in
      per Step 10a, and the save sends what the fields then hold, trimmed only.
      **The coordinates are not shown and not editable**, and travel through
      untouched (below, `AC-34`);
    - save is disabled while in flight, and values are validated and trimmed
      before send;
    - backend text on this screen follows the **one text rule in Step 10a**.

10a. **The text rule — stated once, for every place backend text appears.**
    Five review findings came from this rule being implied instead of located, so
    it is written here in full and the other steps only refer to it.
    - **The helper.** One function, in its own file beside the other dashboard
      presentation helpers — **not** in the form widget, because the widget layer
      and the form both call it and a form file is the wrong home for a shared
      string helper. Its pattern is a `static final`, compiled once. It does two
      things: forbids markup (plain text only) and strips direction-control
      characters.
    - **The code points it strips — twelve of them, and this is the only place
      the list or its count appears** (`SEC10-6`): `U+202A`–`U+202E` (the
      LRE/RLE/PDF/LRO/RLO embedding and override set, five), `U+2066`–`U+2069`
      (the isolates, four), `U+200E` and `U+200F` (the LRM/RLM marks), and
      `U+061C` (the Arabic letter mark). That is exactly the Unicode
      `Bidi_Control` set. Revision 10 stated the list here and called it "nine" in
      a follow-up table; the table is deleted and the count is stated once, with
      the list it counts.

      **What this set does not cover, recorded rather than implied.** `AC-29`
      names two harms — reshaping the screen, and spoofing right-to-left. This
      list closes the spoofing half completely. It does **not** close the
      reshaping half: `\n`, `U+2028`, `U+2029` and combining marks
      (`U+0300`–`U+036F`) still expand a row's height, and `U+200B`–`U+200D` /
      `U+FEFF` still allow invisible text — none of which a 200-**character** cap
      bounds. Widening the set is a one-line change to this helper, but it changes
      what `AC-29` is verified against, and `AC-29` lives in `spec.md`. **It is
      recorded in Follow-up work with the other `spec.md` items** rather than
      decided here.
    - **The display cap is 200 characters**, and that number is part of the rule,
      not an implementer's choice. **Why 200, stated correctly this time**
      (`SEC10-8`): it bounds the text the list has to measure and shape, which is
      the actual cost. Revision 10 argued that "a capped row means the value is
      already outside what the create form would accept" — **that is wrong**, and
      it mattered: the create form accepts up to 255, so a legitimate 201–255
      character name *is* truncated in the list. That is accepted, not denied —
      the row shows a truncated name with the usual overflow marker, and **the
      full value is always in the edit form**, which never truncates.
    - **State holds raw text, always.** Location names, addresses, and the error
      message alike — one rule, no exceptions. Nothing sanitized and nothing
      capped is ever stored, because the edit form reads stored values and a capped
      value would be written back to the backend on the next save (this is exactly
      the defect `P4-1` found).
    - **The display copy is built once, in the widget.** When the list in state is
      replaced, the widget builds a list of display items into **one named
      field** — not in `build`, not in `itemBuilder`, and not in the bloc. It is
      dropped on dispose, so the never-disposed singleton holds one copy of the
      text, not two.
    - **Each display item carries its raw record.** The status filter runs over
      display items, and the edit tap reads the raw record off the item it already
      holds. There is no lookup by id per row, and no second list to keep in step.
    - **The length cap belongs to the display copy**, at the 200 characters named
      above. That copy is a fresh allocation, so capping there costs nothing and
      never touches stored text. `maxLines` / `overflow` on the `Text` widget stay
      as a *visual* guard only — they do not bound work, because the text engine
      still measures and shapes the whole string.
    - **Editable fields keep the full length, and are stripped exactly once — on
      the prefill, never on the controller** (`SEC10-7`, and `SEC11-3` which the
      owner answered on 2026-09-01). Revision 11 said "on the way in", which does
      not distinguish the two, and the difference decides what this whole screen can
      be tested for. **The rule, in the words that settle it:**
      - **the prefill is stripped** — when the load-for-edit record is written into
        the form's fields (Step 10), direction-control characters are removed;
      - **the controller is not filtered** — what the member types or pastes stands,
        keystroke by keystroke. There is no `TextInputFormatter` doing this work and
        none is added;
      - **the save sends what the fields hold**, trimmed only.

      **Two consequences follow, and both are accepted rather than engineered
      around.**

      **First, an edit still normalizes the stored name, and prefill-only stripping
      does not change that** — the controller is *seeded* with the stripped value,
      so the save writes the stripped value back. A name legitimately containing
      `U+200F` or `U+200E` — ordinary in `ar-SY` and `ku-IQ` text — loses those
      marks the next time anyone saves that record. The alternative is holding two
      copies of every field, the raw value for the save and a stripped one for
      display, which is a mechanism this screen would carry forever to protect
      marks that affect only rendering, in fields the member can retype. Recorded
      here, observed at `/verify`, and asked of the backend team in Follow-up work.

      **Second, a member can type a direction-control character and save it**,
      because the controller is not filtered — so this screen is an **outbound**
      source of such text, and consumers with no sanitizer of their own will render
      it. **That is accepted explicitly, and it is in *Out of scope*** (`SEC11-10`,
      owner-answered): validating what it stores is the backend's job, and this
      screen is not the only writer of location names — the become-seller flow
      writes them too. `AC-29` stays scoped to what **this screen renders**, which
      is what it already says.

      **What the unfiltered controller buys** is the reason the trade is worth
      taking: it makes the `AC-29` manual check performable through the app at all.
      A member can enter a hostile name, save it, and reopen the tab to observe the
      display sanitizer working — **so no seeding path outside the app has to be
      funded**, which was the expensive half of the alternative.

      **Length is never capped in an editable field**, which is the half `P4-1` was
      actually about.
    - **The error banner follows the same rule**: raw in state, sanitized and
      capped in the same display-side field when the message arrives.

11. Rewrite `_LocationsWidgetState` to read the bloc: delete the hardcoded
    `_locations` list and the three `TODO` handlers, take `permissions` through
    the constructor as `ShopInfoWidget` does, and render the loading, empty, error
    and permission-denied states.
    - **The load is dispatched from a post-frame callback registered in
      `initState`** — never in `build`. `_ShopInfoWidgetState` does exactly this
      and its own comment at `:3420` warns why: in `build` the event fires on every
      rebuild, and with no skip rule nothing would stop the loop.
    - **The bloc is captured in `initState`** and that reference is used in
      `dispose`; reading it from the context during dispose is fragile and is not
      this file's pattern.
    - **The shop id is captured at open and compared with the list's shop before
      dispatching**, clearing first on a mismatch — the same belt-and-braces
      `_ShopInfoWidgetState` uses (`:3418-3430`).
    - **Every new builder carries a `buildWhen`** keyed on the new fields only, so
      the other tabs' emissions do not rebuild this screen.
    - The filtered list is **recomputed only when the list or the filter changes**
      and held in a field — not rebuilt on every frame.
    - **No ISO→name map is built.** **Each row reads its country name from
      `country.nicename` on its own record** (Step 2, `AC-4`), so there is nothing
      to index and nothing to cache.
    - **The permission booleans are read once per build and passed down**, never
      called inside `itemBuilder` — each checker method is a list scan and
      `isSuperAdmin` adds a second, so calling them per row is rows × permissions
      scans per frame.
    - **Backend text follows Step 10a.** The rows render from the display copy
      built there — never from a helper call inside `itemBuilder`, and never from
      raw state. The filter runs over those display items, and the edit tap reads
      the raw record each item carries.
    - The row stays inside the lazy `ListView.separated` under `Expanded`. It is
      **not** changed to a `Column` or a `shrinkWrap: true` list.
    - **`AC-25`'s retry keeps the rows.** When a load fails **with rows already on
      screen**, those rows stay and an error banner with a retry is shown **over**
      them — the list is not replaced. The full error state is only for a failure
      with nothing loaded.
    - **The screen's own header badge is built here** — the count beside the
      "Locations" heading that `AC-5` and `FR-3` name. It reads **`meta.total`**.
      **Recorded, and expected at `/verify`:** the badge shows the shop's total
      while the list below it shows one page, and nothing on screen says more
      exist. Likewise `AC-7`'s filter narrows only the loaded page, so choosing
      "inactive" can show an empty list while inactive rows sit on page 2. Both are
      consequences of paging being a separate work item; they are observations to
      record, not defects to fix here.
    - **The first frame is gated on the stamp.** The list builder renders the
      loading state until the model's `loadedForSellerId` matches the shop id
      captured at open. Clearing in a post-frame callback alone lets one frame draw
      the previous shop's rows, and `AC-22` says nothing of another shop is *ever*
      on screen. `permissionDenied`, failure and empty are evaluated **before** the
      stamp gate, so a failed first load reaches `AC-25`'s retry instead of a
      permanent spinner.
    - **The row's edit and status controls, and the two conditions that gate each
      of them** (`SR10-4`, `SEC10-11`, `P10-6`). Step 2 diagnosed this in words
      and revision 10 never carried it into the step that builds the controls:
      - **the status control is shown only when `canChangeLocationStatus()`
        allows it *and* the record's id is a positive `int`**;
      - **the edit control is shown only when `canUpdateLocation()` allows it
        *and* the record's id is a positive `int`**.

      A record with a missing, non-numeric or non-positive id is **rendered**, and
      simply offers neither control — so an unusable id can never become a path
      segment (Step 1, Step 2). Permission alone was the old rule and it left
      change-status as the one path that could still interpolate an absent id.

      **Tapping the status control dispatches an event; the bloc writes the row**
      (Step 8). Revision 10 said the tap "writes the row's new marker", which reads
      as widget-owned and is the wording that produced the two-owner defect
      `P8-1` fixed. **The widget renders and writes nothing.** The new marker is
      the value the backend returned, never the value the screen asked for
      (`AC-30`), and no list reload is issued.

      **While any status change is in flight, every row's status control is
      disabled** — the consequence of Step 7's single shared write-status enum,
      stated here because this is where the member sees it.

      **No delete control exists anywhere**, because the backend has no delete
      call, and the screen does not imply that deactivating detaches the location
      from products already pointing at it (`AC-32`). The existing `_onDeactivate`
      `TODO` handler at `dashboard_page.dart:3055-3070` is replaced by this, not
      deleted.
    - Update the one-line `case 8` call site to pass the permissions.

12. Replace every hardcoded English string on the screen with translation keys,
    adding the missing ones to all four language bundles. Reuse the keys that
    already exist rather than adding near-duplicates: `locations`,
    `location_name`, `location_address`, `location_name_is_required`, `edit`,
    `add`, `save`, `all`. **`location_address_is_required` is deliberately not
    reused** — `A-7`/`AC-8` made the address optional, so that key has no call site
    on this screen.

    **This includes exactly one line inside the shared tab list** — the hardcoded
    English `subtitle:` of the Locations `_FilterItem` at
    `dashboard_page.dart:1698`. That single line is explicitly allowed: it changes
    no visibility rule, no ordering, and no count, and `AC-26` requires it. **The
    tab card's `count:` at `:1699` is not touched.** No country name is
    translated — the amended `AC-26` scopes translation to the words this screen
    writes, not to values the backend returns.

13. Regenerate: `sh gen.sh` for the DI container and the model serializers, then
    `sh keys.sh` for the localization keys. Neither generated file is hand-edited,
    and the generated DI diff is reviewed so no unrelated registration rides
    along. `sh gen.sh` regenerates `**/*.g.dart` repo-wide — a protected pattern —
    so the review covers any other regenerated `.g.dart`, not only the DI diff.

14. Run the validation profile, the two extra locale checks, and the manual device
    run described under Validation strategy.

## Files to change

**Protected runtime paths** — listed in `CLAUDE.md` and changed only inside this
approved plan:

- `lib/common/constant/configuration/dashBoard_url_routes.dart` — **protected**
  (`*_url_routes.dart`). **Two constants** — the collection, and the create form's
  country list — **plus three per-record functions taking `int id`**:
  load-for-edit, update, change status (Step 1). Additive.
- `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` — **protected**
  (`**/*_state.dart`). New status enums, list, total and error field, added to the
  class, `copyWith`, **and `props`** (Step 7). `DashboardBloc` is a plain `Bloc`,
  not a `HydratedBloc`, so there is nothing on disk to migrate — but the path is
  protected regardless and is named here for that reason.
- `assets/languages/ar-SY.json`, `en-US.json`, `ku-IQ.json`, `tr-TR.json` —
  **protected**. Add the missing keys to all four, never to one (Step 12).
- `lib/generated/locale_keys.g.dart` — **protected and generated**. Regenerated by
  `sh keys.sh`; never hand-edited (Step 13).
- `lib/core/di/di_container.config.dart` — **generated**. Regenerated by
  `sh gen.sh`; never hand-edited; the diff is reviewed before merge (Step 13).

> **Nothing in `lib/core/api/**` is touched.** `put.dart` was on this list in every
> revision from the second to the sixth, to add an `extraHeaders` merge an update
> would need. The contract answers that the update is a **`POST`**, and
> `post.dart:72-73` already honours `extraHeaders` — so the merge is not needed and
> the file is not touched. `patch.dart` and `delete.dart` never join either: the
> status call is also a `POST`, and there is no delete call to build. `AC-23` is met
> with the shared clients exactly as they stand. **This is the single largest
> reduction any revision has made to this plan's blast radius**, and the protected
> list above is final — every path on it is one this plan names outright.

**Ordinary paths:**

- `lib/features/dashBoard/data/models/get_shop_locations_model.dart` — **new.**
  The record and the list wrapper; **`meta.total` and `meta.per_page`** (`SR10-5`
  — revision 10 funded both in Step 2 and named only `total` here); the
  `loadedForSellerId` stamp, which lives here and **nowhere else**; a **`copyWith`
  on the record**, which Step 8's in-place toggle uses; and a **`copyWith` on the
  list wrapper**, which that same write needs in order to rebuild the wrapper
  while preserving the stamp (`SEC10-9`). Both are named here so `IM-4` permits
  writing them (Step 2).
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — one method per call; each **write** passes `extraHeaders`, the read does not
  (Step 3).
- `lib/features/dashBoard/domain/repositories/dashBoard_repository.dart` and
  `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` — the
  matching interface methods and implementations (Step 4).
- `lib/features/dashBoard/domain/useCase/get_shop_locations_usecase.dart`,
  `get_location_form_countries_usecase.dart`, `create_shop_location_usecase.dart`,
  `get_shop_location_for_edit_usecase.dart`, `update_shop_location_usecase.dart`,
  `change_shop_location_status_usecase.dart` — **new**, one per call (Step 5).
- `lib/features/dashBoard/presentation/widgets/permission_enum.dart` — the
  locations permission values (Step 6).
- `lib/features/dashBoard/presentation/widgets/dashboard_permission_checker.dart`
  — the locations methods (Step 6).
- `lib/features/dashBoard/presentation/bloc/dashBoard_event.dart` and
  `dashBoard_bloc.dart` — the events, the handlers, the arrival-time shop check,
  and the log helper (Steps 8, 9). Also, named explicitly because they are class
  members rather than handler code (`SR10-7`): **`int _locationsLoadGeneration`**,
  the clear counter Step 8 captures and compares, and **an import of
  `bloc_concurrency`** — the file uses no event transformer today. The package is
  already a dependency (`pubspec.yaml:119`); `droppable` and `restartable` come
  straight from it, so **no local helper is copied into this file** and no throttle
  duration is introduced. **No in-flight id set is added** — revision 10's
  `_statusChangesInFlight` is withdrawn with the `concurrent()` transformer that
  needed it (Step 8).
- `lib/features/dashBoard/presentation/widgets/location_form_sheet.dart` —
  **new.** The add/edit form (Step 10).
- `lib/features/dashBoard/presentation/widgets/display_text_sanitizer.dart` —
  **new.** The one `AC-29` sanitize helper (Step 10a). It sits beside the other
  dashboard presentation helpers rather than inside the form widget, because both
  the list widget and the form call it.
- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — rewrite
  `_LocationsWidgetState` (`:3022`–`:3372`), delete the mock `LocationModel`
  (`:2999`–`:3013`), update the `case 8` call site (`:1926`), and translate the tab
  subtitle at **`:1698`** (Steps 11, 12). **One line inside the shared tab list is
  changed — the subtitle, and nothing else.** The tab card's `count:` at `:1699`
  stays as it is.

> **No documentation file is changed by this work item.** The contract arrived as
> its own file — `.claude/docs/mobile-seller-dashboard-locations-api-guide.md` —
> and is already written. The main dashboard guide keeps no Locations section and
> is not the reference for this screen; the redaction check in Validation strategy
> points at the Locations guide.

## Integration surface

- **Components / shared config touched:**
  `DashboardBloc` — a `lazySingleton` in the generated DI container, provided
  app-wide in `lib/service/service_provider.dart:30`, shared by all eleven
  dashboard tabs, and **never disposed**. `DashBoardState` — one object every tab
  reads. The dashboard route file — every dashboard call resolves through it. The
  permission enum and checker — read by the tab bar and by six other tabs. The four
  language bundles and the generated key file — read by the whole app. The DI
  container — regenerating it rewrites registrations for every feature. **The
  Locations `_FilterItem` subtitle** — one line inside the shared tab list.

  **`HomeBloc`** — the app-wide home singleton. **This work item never *reads*
  it**: the country lists come from the backend per form (Approach 2), so the
  allowed-countries dependency is genuinely gone. But it **writes** to it,
  indirectly and on a path no step here can switch off, and revision 11 states
  what that path actually carries, because revision 10 understated it in two
  separate ways:

  1. **The dispatch.** The shared error interceptor dispatches
     `SendErrorToMobileErrorLogEvent` into `HomeBloc` on **every failed request**
     (`log_interceptor.dart:170-182`), and its handler mutates
     `HomeState.listOfErrorSendedToMobileErrorLog` (`home_bloc.dart:250,
     2678-2699`). This work item adds **six new call sites** that feed it.
  2. **What the report carries is more than tokens, and more than revision 11 said**
     (`SEC10-3`, extended by `SEC11-6`). The payload includes the four stored
     service tokens **and `lastApiRequest`** (`home_bloc.dart:2706-2750`) — the
     newest entry of the shared request log: url, body, and non-auth headers
     **including `X-Seller-ID`**, which is not among the log's redacted markers
     (`prefs_repository_impl.dart:266-313`) and is saved in release
     (`post.dart:82-93`). **So a failed request on this screen POSTs a location
     record and the tenant id to the error-log endpoint.**
     **And alongside those it carries plain PII, not only credentials**: the same
     body includes `deviceInfo`, `clientIp`, `userMarketPhone`, the market / chat /
     stories ids and names, the profile photo and `userVerifiedPhone`. Revision 11
     described the payload as "the four service tokens and `lastApiRequest`", which
     was accurate and incomplete — the completion matters because `AC-27` is the
     criterion that records what leaves the device.
  3. **`HomeBloc` is a `HydratedBloc`, so that list is also on disk**
     (`SEC10-2`). `home_bloc.dart:123` extends `HydratedBloc`, and
     `listOfErrorSendedToMobileErrorLog` is serialized (`home_state.g.dart:706-707`)
     with entries carrying `messageFromeBackend` (`home_bloc.dart:2685-2700`) — the
     backend's own 422 text, which for a duplicate-name refusal **contains a
     location name a member typed**. The list is never pruned. **This is a second
     on-disk persistence path for this screen's data**, beside the shared request
     log that `AC-24` already records as "the one recorded exception".

  > **Read all three together with `AC-24` and `AC-27`.** This screen neither
  > causes this behaviour nor can prevent it, and does not change it — but "outside
  > this work item" was never true, and `AC-24`'s "one recorded exception" is now
  > two. Both criteria live in `spec.md` and the amendment is recorded in
  > *Follow-up work this plan creates*, because `development.plan` cannot make it.

- **Deliberately *not* touched, and why it matters:**
  **`lib/core/api/methods/get.dart`.** Adding the `extraHeaders` merge there would
  let the read carry its own shop id, but `get.dart` is the shared `GET` client for
  every screen in the app — a much larger regression surface than `put.dart`, since
  every feature issues reads. The arrival-time check in Step 8 satisfies `AC-22`
  without it. **The shared request logger and the shared error toast** are likewise
  untouched; both are pre-existing behaviour that the amended `AC-24` and `AC-29`
  record rather than silently contradict.
- **A trap worth naming once:** `RequestConfig.extraHeaders` is declared on
  `client_config.dart:8` and honoured **only** by `post.dart:72-73`. `get.dart`,
  `put.dart`, `patch.dart` and `delete.dart` all take the field and silently drop
  it. Passing it to any of them compiles, reads correctly, and does nothing —
  which is exactly how a tenant guard fails without a single error.
- **A second trap on the same file:** `post.dart:69-75` builds
  `{...?options.headers, ..._extraHeaders}` with the caller's map **last**, and Dio
  normalises keys case-insensitively — so a caller-supplied `authorization`,
  `country` or `lang` key would replace auth material. **This work item cannot
  exercise it**: Step 3 builds the map from a single `const` key at one call site.
  Hardening `post.dart` is a `lib/core/api/**` change and is a follow-up ticket.
- **Who else depends on them:** every other dashboard tab, through the shared bloc
  and state — **and code outside the dashboard feature entirely.**
  `become_seller_page.dart` holds a `BlocListener<DashboardBloc, DashBoardState>`
  with **no `listenWhen`**, so it reacts to every emission this screen causes, and
  `profile_page.dart` builds from the same state. These two are the only
  `DashBoardState` consumers outside `lib/features/dashBoard/`. Also the whole app,
  through the language bundles and the DI container; and the become-seller /
  vendor-request flow, which writes the same three location values when a shop is
  first registered.
- **Overlapping flows:** two.
  **(a)** The **become-seller flow** creates a shop's first location. If that row
  and a dashboard location are the same record (`OQ-11`), editing here changes what
  that flow submitted — and the two forms validate the same field differently,
  since the become-seller form caps the name at 10 characters while this one checks
  255. That flow's params also carry nullable `latitude` and `longitude`, which is
  the repo's own partial answer to `OQ-3`.
  **(b)** The **shop switch.** `X-Seller-ID` is written into prefs by
  `_DashboardPageState.initState` (`dashboard_page.dart:1560` — one page **above**
  the tab, which is where the clear-on-switch comparison has to reason from) and by
  `SelectShopForOrderPage` (`:308`), and is read when each request is built
  (`base_api.dart:34`). This screen adds a second consumer of the clear-on-switch
  pattern, is the first to override the header per request on a write, and the
  first to re-check the shop id when a read returns.
  **Why the read guard is enough, stated once so it is not re-litigated:**
  `setXSellerId` has exactly two real call sites, and `_openTab`
  (`:1582-1599`) pushes each tab **on top of** the dashboard page. So the shop
  switcher sits below this screen, and reaching it pops the tab first, firing the
  dispose-clear. The shop cannot change while the Locations tab is on screen. This
  guarantee comes from the navigation shape, not from the bloc — **if an in-page
  shop switcher is ever added, this reasoning stops holding** and the read needs
  its own header.
- **Shared mutable header state:** `base_api.dart:12-51` writes `X-Seller-ID`,
  `Authorization`, `country` and `lang` into the **one shared** `Dio` header map on
  every client construction, and `post.dart:54-58` empties that map for media
  uploads. So "the id was correct when we captured it" is **not** a safe argument
  for any request that does not override per request. That is why writes override
  and the read re-checks on arrival.
- **The pattern for new dashboard writes, stated once:** carry the shop id on the
  request. ShopInfo compares `expectedSellerId` inside the bloc instead
  (`dashBoard_bloc.dart:1246`); both are sound, but new dashboard writes should
  follow the per-request header so the next ticket does not have to choose.
  ShopInfo is **not** re-pointed by this work item.
- **Not a risk, recorded so it is not re-raised:** revision 3 warned that this
  screen's emissions rebuild the orders builder at `dashboard_page.dart:2056`,
  which has no `buildWhen`. That is **not reachable** — every tab is its own pushed
  route, so Orders and Locations are never mounted together. The exit emission
  costs one `props` compare.
- **Ordering / lockstep dependencies:** the model and use cases before
  `sh gen.sh`, or DI will not resolve them; the language keys before `sh keys.sh`;
  all four bundles in the same commit, or parity fails. Nothing has to land first
  in `lib/core/api/**`, because nothing there is touched.
- **What breaks if this is wrong:**
  A malformed addition to the shared state breaks **every** dashboard tab, not just
  this one, because they all rebuild from the same object — it shows as unrelated
  tabs going blank or throwing on `copyWith`.
  **A new field added to the class and `copyWith` but missing from `props` fails
  silently**: the state compares equal, the screen never rebuilds, and nothing
  errors at compile time.
  **A header key typo** in `extraHeaders` sends a second, wrong header rather than
  failing, so the write silently targets whatever the shared map holds.
  A missing DI regeneration crashes at app start, not at the Locations tab.
  A key added to one bundle only shows a raw key string in the other three
  languages and fails `locale-bundles-in-sync`.
  A wrong permission string fails in the worst direction: the control is hidden
  from a member who is entitled to it, and nobody sees an error.
  **A bad `copyWith` or `props` change does not stop at the dashboard.**
  `become_seller_page.dart` listens to this state with **no `listenWhen`** and
  `profile_page.dart` builds from it, so seller registration and the profile page
  break too — not only the eleven tabs.
  **A wrapper `copyWith` that re-reads the shop id instead of preserving the
  stamp** re-stamps a stale list with the current shop id, and Step 11's
  first-frame gate then passes for the wrong shop — which is `AC-22` failing in the
  one place the guard exists to cover.

## Validation strategy

- Validation profile: `codegen-change`
- **Gap, stated rather than hidden:** a ticket may name only one profile, and none
  covers codegen *and* localization together. `codegen-change` gives
  `build-runner-clean` + `flutter-analyze`; this change also needs
  `locale-bundles-in-sync` and `locale-keys-clean` from `localization-change`. Both
  extra check-ids are run at `/verify` in addition to the profile. Their commands
  stay in `.claude/project-config.yaml > validation_checks` (VP-4) — none is
  written here. A combined profile would be a governance change and is not made by
  this ticket. This is the second work item to hit the same gap.
- Manual device run against the development market server, per `OQ-10`: one
  recorded observation per `AC-n`. The run must cover a shop with full permissions,
  a member without the create permission, a member without the read permission, a
  failed permission load, a shop with no locations, a save refused by the backend,
  and a connection failure with locations already on screen.
  **The tenant case is written as something the app can actually produce:** start a
  load, pop the tab, switch shop, and re-enter — the list must show the new shop's
  locations and never the old shop's. "A shop switch with the screen open" cannot
  occur: the switcher sits below the tab route, so switching always pops this
  screen first.
- **The `PUT` regression pass is gone entirely**, because this work item changes no
  shared HTTP client. One grep is kept as evidence for the claim: no `PutClient`,
  `PatchClient` or `DeleteClient` call site passes `extraHeaders` — all seven
  existing call sites are `PostClient` — which is why writing `extraHeaders:` on
  anything but a `POST` would silently do nothing. Recorded at `/verify`.

- **Four checks the contract adds, all cheap and all easy to skip:**
  - **the coordinate round-trip** — open a location that has a map point, save it
    with no other change, and confirm the point is still there (`AC-34`). The
    values arrive as strings and must go back as numbers, so a wrong parse shows up
    here and nowhere else;
  - **the "inactive" filter** — choose it and confirm the list narrows. The status
    value for inactive is `0`, so a falsy test drops the choice with no error and
    the screen looks like it simply has no inactive locations;
  - **the create form as a read-only member** — confirm the list still works and
    the add control is absent (`AC-33`). The form's country list is behind the
    create permission, so a call made too early refuses on a screen the member is
    entitled to see;
  - **a hostile name, saved and then read back** — the only check that exercises
    `AC-29` at all. **Re-scoped in revision 11 so it can actually be run**
    (`SEC10-1`): save one location whose name is **255 characters** — the backend's
    own limit, which `AC-8` also enforces client-side — and which **begins with a
    right-to-left override (`U+202E`)**. Revision 10 asked for a 5,000-character
    name, which both sides refuse, so the check could never have been performed and
    `AC-29` would have fallen back to code reading. 255 still exceeds Step 10a's
    200-character display cap, so it proves the cap; and the `U+202E` proves the
    strip.

    **The check is performable because the controller is not filtered**
    (Step 10a, `SEC11-3`): the member types or pastes this name and saves it
    through the app, so **no seeding path outside the app is needed**.

    Reopen the tab and observe three things:
    1. the row renders left-to-right with the surrounding layout intact;
    2. the displayed text is cut at 200 characters;
    3. **the edit form shows the full stored value, uncapped** — no truncation at
       200 or anywhere else. **Do not expect a count of 255** (`SR11-3`,
       `SEC11-8`): the prefill strips the leading `U+202E`, so the field holds
       **254** characters. Revision 11 wrote "all 255 characters", which the
       prefill rule makes impossible — and an implementer trying to make that
       number appear would have to delete the editable-field strip, removing the
       `AC-29` control this plan just accepted the cost of. **What is being
       observed here is the absence of a cap, not a character count.**

    **Also observe, and record, the mutation Step 10a accepts** (`SEC10-7`): save a
    name containing a legitimate `U+200F`, reopen the edit form, save again with no
    other change, and confirm the mark is gone from the stored value. That is the
    planned behaviour, not a defect — the point of observing it is that it is
    written down before anyone is surprised by it.

    Record every outcome by shape, per the redaction rule below.
- **One redaction check before merge.** Grep for **values, not header names** —
  grepping for `Authorization` / `Bearer` / `X-Seller-ID` matches the contract
  file's own header table, where those words are legitimate placeholder text, so it
  fired on every run and taught the reader to ignore it. Run it with the **PCRE2**
  engine (`grep -P` or `rg -P`): ripgrep's default engine **rejects a negative
  lookahead outright**, and a check that errors reads exactly like a check that
  passed.
  - `Bearer\s+(?!<)[A-Za-z0-9._-]{20,}` — a bearer token, but not `<MARKET_TOKEN>`
  - `eyJ[A-Za-z0-9._-]{10,}` — a JWT
  - `X-Seller-ID:\s*[0-9]+` — a real shop id, but not `<sellerId>`
  - an email pattern, and a run of nine or more digits

  **The literal command, corrected twice.** Revision 10 gave a pipeline with no
  `pipefail` and no base check (`SEC10-5`). Revision 11 added those and then
  **re-introduced the silent pass by a different door** (`SEC11-1`, `SEC11-2`): its
  trailing `|| true` collapsed grep's exit **2** — a PCRE error, a backtracking
  limit, unreadable input — into success, so only the base and engine probes still
  failed loudly; and it diffed **commits** while its own paragraph said to run it
  after *staging*, which would have scanned nothing and read as a pass. Both are
  fixed. Run from the repository root, on a `bash` shell — **`set -o pipefail` is
  not POSIX `sh`**, and the block is tagged accordingly:

  ```bash
  set -euo pipefail
  git rev-parse --verify origin/dev_new >/dev/null   # fails if the base is absent
  printf 'x' | grep -qP 'x'                          # fails if PCRE2 is unavailable

  if git diff --cached --unified=0 origin/dev_new -- \
        .claude/docs/mobile-seller-dashboard-locations-api-guide.md \
        .claude/_specs/manage-shop-locations-in-seller-dashboard.md \
        _specs/manage-shop-locations-in-seller-dashboard/ \
      | grep '^+' \
      | grep -aP 'Bearer\s+(?!<)[A-Za-z0-9._-]{20,}|eyJ[A-Za-z0-9._-]{10,}|X-Seller-ID:\s*[0-9]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|[0-9]{9,}'
  then
      echo 'REDACTION HIT — read the lines above before merging'; exit 1
  fi
  echo 'redaction check clean'
  ```

  **Four things about this command are deliberate, and each replaces a way the
  earlier versions could pass without checking anything:**
  - **`--cached` against `origin/dev_new`** scans what is **staged**, which is what
    the surrounding instruction always said. The `...HEAD` range scanned commits
    only, so a staged-but-uncommitted `_specs/` — its state today — contributed
    nothing (`SEC11-1`);
  - **`if … then` instead of `|| true`** distinguishes grep's three exits: 0 is a
    hit and fails the check, 1 is clean, and **2 — an engine error — propagates and
    stops the script** under `set -e` rather than being read as clean (`SEC11-2`);
  - **`-a`** forces text mode. Without it, a NUL byte anywhere in the input makes
    grep print "Binary file (standard input) matches" and **suppress the matching
    line**, hiding the very hit it found;
  - **it prints on success.** "No output" is not evidence a check ran; `redaction
    check clean` is.

  **A hit is read by a human**, because a placeholder can look like a value. This
  command is deliberately **not** added to `.claude/project-config.yaml`: it is a
  one-off pre-merge read, not a check the `/verify` profile runs, and putting it in
  the profile would imply an automated gate that nobody maintains.

  **What this check does and does not cover.** It catches **credentials and long
  identifiers only**. **No pattern matches a location name, a street address, or a
  latitude/longitude pair** — which are exactly the values `verify.md` will carry.
  A short seller id is the one qualification: `X-Seller-ID:\s*[0-9]+` matches one
  in header form, so the honest statement is that a bare short number **outside**
  that header form is not matched. The grep is **not** the control for that
  content.

  **The control for PII in `_specs/` is a rule about what `verify.md` records.**
  **`verify.md` records the *shape* of each observation, not the captured value**:
  `name: <loc-1>`, `address: <present>`, `lat: <present>`, `country: <iso>`,
  `shop: <test-shop>`. Every `AC-n` in this work item is satisfied by shape — the
  criteria are about *whether* a value is shown, trimmed, capped or dropped, never
  about which value — so nothing is lost, and pasting a real name becomes a
  deliberate act rather than the default. **`/verify` states this rule as the first
  line of its Observations section** (`SEC10-12`), so a violation is visible in the
  same file that breaks it. The manual run uses **a test shop, never a live
  seller's**.

  **Scope: three paths, not two** (`SEC11-9`). The contract file — clean as it
  stands, placeholders only — **`_specs/manage-shop-locations-in-seller-dashboard/*.md`**,
  because `OQ-10` makes a live device run the sole acceptance evidence, **and
  `.claude/_specs/manage-shop-locations-in-seller-dashboard.md`**, the backlog
  ticket this work item started from, which carries the same observation shapes and
  which revisions 7 to 11 all missed. **None of the three is git-ignored**, so a
  leak in any of them outlives a branch revert. All three are in the command above.
- **What `/verify` must do about the broken `spec.md` acceptance table**
  (`SEC10-4`). A blank line after `AC-35` breaks the table, so `AC-30` … `AC-34`
  render as plain text — five criteria, including `AC-30` and `AC-33`, that anyone
  enumerating the rendered table would silently drop. Until the `spec.md`
  correction pass runs (Follow-up work), **`/verify` enumerates the criteria from
  the raw source, not the rendered table**, and records an outcome for all of
  `AC-1` … `AC-35`.

  **Three further instructions, and the second is narrower than revision 11 made
  it** (`SEC11-7`):
  - **`FR-12` and the duplicate-name edge case are read as superseded by `A-12`
    and Step 3a** — the backend's own message is not bound to a field.
  - **`AC-15` is superseded only in its message clause** — "in both cases the
    backend's own message is shown". **Its success-flag rule is live and must be
    verified**: Step 2 still mandates that success is read from the body's success
    flag and never from the HTTP status. Revision 11 said `AC-15` was superseded
    outright, which would let a `200` carrying `success: false` be recorded as a
    successful save — the exact defect the criterion exists to catch.
  - **`AC-35` is recorded as a residual, not passed or failed**, because it
    declares itself not a criterion while holding an `AC-n` id.
  - **`spec.md`'s closing note says "the three that remain" where five open
    questions are listed** (`SR11-5`). `/verify` reads the count from Step 0's
    table in this plan, which is the single statement of it, and the note joins the
    `spec.md` correction list in Follow-up work.
- **Before `implement` begins, confirm one external dependency: device access for
  the manual run.** `OQ-10` makes that run the acceptance evidence for every
  `AC-n`, so discovering it missing at `verify` would waste the whole
  implementation — the sibling work item is blocked on exactly this today
  (`BLK-NO-DEVICE-RUN-01`). **The backend engineer's availability is not a
  precondition**: Step 0's table says each open question moves nothing that is
  built here.
- **Also before `implement`: clear the `IM-3` base. This is no longer a
  prediction — `implement` blocked on it on 2026-09-01** (`BLK-IM3-BASE-02`,
  recorded in `implement.md` and in `ticket.md > State History`). The checkout is
  on `ali_dev`; there is no local `dev_new`, only `origin/dev_new`; and **two**
  unrelated files are modified and uncommitted — `CLAUDE.md` (110 changed lines,
  the repository's governance contract) and `profile_personal_info_page.dart`.
  Neither is in **Files to change**, so `IM-4` forbids touching them and `IM-3`
  forbids carrying them onto the ticket branch. **The blocker is still open**: the
  owner-authorized move back to `plan` on 2026-09-01 did not resolve it, and
  `implement` will meet it again. `implement.md > Recommended next action` lists
  the three routes; each is the owner's to choose, because each relocates their
  uncommitted work.
- **Confirm during the run** that a member who is entitled but whose permission
  list failed to load can recover by reopening the dashboard — `AC-17` forbids a
  retry control, so recovery has to come from somewhere.
- No automated widget or bloc test is added (Out of scope, per `OQ-10`).

## Rollback

- One branch, `ticket/manage-shop-locations-in-seller-dashboard`. Almost every edit
  is additive: new files, new enum values, new state fields, new endpoint
  constants. **No shared HTTP client is modified**, so a revert cannot affect
  another feature's requests. The only rewrites are `_LocationsWidgetState`, the
  mock `LocationModel`, the one-line `case 8` call site, and the one-line tab
  subtitle. Reverting the merge restores the mock screen and changes no other tab,
  because nothing existing is re-pointed.
- The two generated files rebuild from sources: revert, then `sh gen.sh` and
  `sh keys.sh`.
- No database, no server-side migration, and no client state of this screen's
  own — `DashboardBloc` is not hydrated, so a revert leaves nothing of this
  feature's on disk to clean up. **Two shared stores are exceptions, and both are
  pre-existing:** the shared request log keeps a capped, token-redacted copy of
  recent requests and ages out on its own; and `HomeBloc`'s hydrated error list
  keeps backend messages **without pruning** (Integration surface). A revert
  removes neither.
- **What a revert does not undo:** a location already created or edited through
  this screen stays created or edited on the backend. **The contract confirms there
  is no delete call at all** — so a bad row cannot be removed, only deactivated,
  and a deactivated row still appears in the list and still stays attached to any
  product pointing at it. `AC-23` closes the wrong-shop window for writes rather
  than narrowing it, but it does not make a write reversible.

  **The mitigation is one thing, and it is the manual run using a test shop, never
  a live seller's.** There is **no confirmation step**: no step builds one and no
  criterion covers one (`AC-10` is only the double-tap guard), so under
  `IM-4`/`IM-11` one would never be implemented. Revisions 7 to 10 claimed a
  confirm step here in two other places while this section said it was withdrawn;
  Step 0's `OQ-14` row and the `PL-12` table now agree with this one (`SR10-2`).
  Adding a confirm dialog is a real option, but it needs its own `AC-n` and is not
  smuggled in here. `OQ-14` is still open, and the per-country name uniqueness only
  catches a twin with the *same* name in the *same* country.
- **A leak into the contract file is not undone by reverting the branch.**
  `.claude/` is not git-ignored, so a real seller id, address or bearer token
  committed into
  `.claude/docs/mobile-seller-dashboard-locations-api-guide.md` survives the revert
  and lives in git history. That is why the redaction grep in Validation strategy
  is a merge gate rather than a suggestion.

## Deferred questions answered (PL-12)

Every `OQ-n` raised by `research.md` or `spec.md` is either answered here or
carried in **Step 0's table**, which is the single statement of what remains open.

| OQ | Answer at plan altitude |
|------|-------------------------|
| OQ-1 | **Answered by the contract.** Six calls, in `.claude/docs/mobile-seller-dashboard-locations-api-guide.md`. They land as one base collection constant, one constant for the create form's country list, and three per-record functions taking `int id`, in the dashboard route file, all built from the existing `shopScope()` extension (Step 1). **The intake condition is satisfied rather than waived** — every path this plan names is documented, none is invented. |
| OQ-2 | **Answered: four permission strings**, one per action. They become values on the existing dashboard permission enum, read through four new methods on the existing permission checker — never a loose string compare at the call site. Each is `SUPER_ADMIN`-or-the-named-permission (Step 6). |
| OQ-3 | **Answered: coordinates are optional.** The map picker stays out of scope; an edit preserves whatever the record already carried (`AC-34`, Step 10). |
| OQ-4 | **Answered: the country is picked from a list the backend returns, per form** — the add form from the create-form lookup on open, the edit form from the record's own load call — and the **list's** displayed country comes on each record. The two wrong sources are recorded so they are not re-proposed: `countries.dart` (the phone dial-code table) and `HomeBloc`'s allowed-countries data (a **superset** of what the backend accepts, so the picker would have offered countries the save then refused). The picker **has no default**: no shop-country value exists on the client, and `OQ-15` is open. Fallback when the fetch fails: an empty picker with **this screen's own translated text** and no save offered — never backend text, per Step 3a. |
| OQ-5 | **Answered: 255 characters**, plus uniqueness per shop per country. Step 10 checks the length; the uniqueness refusal is the backend's to report. |
| OQ-6 | **Answered: deactivate only, and it is a `POST`.** So the concern five revisions carried — that a `PATCH` or `DELETE` client would discard `extraHeaders` and make `AC-23` fail silently — does not arise. |
| OQ-7 | **Answered: the list pages, and the page size is the shop's own setting** the request cannot influence. `AC-1`'s own branch has fired: reaching the rest is a separate work item, now due. `meta.total` backs `AC-5`. |
| OQ-8 | **Answered: the gate lives inside the screen only.** The tab stays visible to everyone; opening it without the read permission shows a message instead of calling the backend. |
| OQ-9 | **Answered: in scope, for the screen's own words** (Step 12). Values the backend returns are shown as received and are not translated. |
| OQ-10 | **Answered: a manual device run against the development market server**, plus static analysis, is the acceptance evidence for every `AC-n`. This is what makes the **Tests** answer `none` below. |
| OQ-12 | **Answered: yes, the guard is required**, and it is split by direction — writes carry the id on the request, the read is checked on arrival (Approach 1, `AC-23`, `AC-22`). |
| OQ-11, OQ-13, OQ-14, OQ-15, OQ-16 | **Carried open, in Step 0's table**, which says for each what it would change and why it does not block. `OQ-16` is the only one that decides an **outcome** rather than a design: it determines whether `AC-16` can be recorded met at `/verify`. |

## Follow-ups from review (PL-7)

**Round 11 recorded APPROVED with nine `major` findings standing**, plus fourteen
minor and eight info. `implement` then blocked twice — on `BLK-IM3-BASE-02`, and
on the three majors `review.md` had dispositioned as expected `IM-10` blockers.
This is the only follow-up table in this document; the tables for rounds 5 to 9
were deleted in revision 11 and round 10's is replaced by this one, on the same
rule: a follow-up table that outlives the revision it briefed becomes a place for
stale claims to live.

| # | Follow-up | How revision 12 addresses it |
|---|-----------|------------------------------|
| 1 | `SR11-2` — `AC-12` funded by no step, after revision 11's own `SEC10-7` edit deleted Step 10's prefill bullets | **Step 10 has a prefill bullet again**, and it now carries the strip rule too. This was content destroyed inside a corrective edit — the same shape as round 9's `P9-3` — and it is why revision 12 re-read every bullet the `SEC10-7` edit touched rather than only the sentences the finding quoted. |
| 2 | `P11-1` / `SEC11-4` — nothing resets the shared write-status enum | **Step 7 lists the five paths that write a terminal value** — success, failure, permission absent, shop id null or empty, response dropped by the arrival guard — **and states that the clear resets it** alongside the list and the counter. Written as a list, not a sentence, because this is the third time this failure mode has been introduced by removing the mechanism that previously covered it. |
| 3 | `SEC11-5` — the change-status write has no arrival guard | **Step 8 gives both list-writing handlers the same rule**: capture the shop id and `_locationsLoadGeneration` before the request, compare both on arrival, drop the response and write the terminal status if either changed. Create and update need none — they refetch, and the refetch is a load, which carries the guard. |
| 4 | `SEC11-3` — where the editable-field strip is applied (owner-answered) | **Step 10a states it three ways**: the prefill is stripped, the controller is not filtered, the save sends what the fields hold. Both consequences are written out — the edit still normalizes a stored name, and a member can save a hostile one. |
| 5 | `SEC11-10` — outbound direction-control text (owner-answered) | **An `Out of scope` entry accepting it**, with the owner's reasoning: the backend validates what it stores, and this screen is not the only writer. Cross-referenced from Step 10a. **No new `AC-n`** — that would be a `spec.md` change with no route. |
| 6 | `SR11-3` / `SEC11-8` — the `AC-29` check's observation 3 is unachievable | **Observation 3 now reads "the full stored value, uncapped"** and says explicitly not to expect 255, because the prefill strips the override and the field holds 254. It also says why the number mattered: an implementer chasing 255 would have deleted the strip. |
| 7 | `SEC11-1` / `SEC11-2` — the redaction command's two silent passes | **Rewritten**: `--cached` against `origin/dev_new` so it scans what is staged, `if … then` instead of `\|\| true` so a PCRE error propagates rather than reading as clean, `-a` so a NUL byte cannot suppress a matching line, a success message so "no output" is never the evidence, and the block tagged `bash` because `pipefail` is not POSIX. |
| 8 | `SR11-1` / `P11-6` — the shared enum couples all three writes | **Accepted and described** in Step 7: `droppable()` is keyed on event type, so a save and a toggle can be in flight together on one field. The UI shape makes it largely unreachable; splitting the field would cost a second enum in `copyWith` and `props`. What was not acceptable was leaving it undescribed. |
| 9 | `SR11-4` — "all three" transformers, and the clear handler missing from the table | Both fixed: **two** transformers, and **a clear row** stating it takes the package default and why a transformer there could reorder a clear against the load it invalidates. |
| 10 | `P11-2` / `P11-3` — the toggle's list allocation and pass count | **Step 8 requires a new list** and says why mutating in place would make `props` compare equal and silently drop the emit. The pass count is corrected: build and sanitize are one traversal, and the `props` compare is **per builder** — with the instruction to key the badge and banner on scalar fields so only the list builder pays O(N). |
| 11 | `P11-4` — the lever is narrower than claimed, and collides with Step 10a | **Step 7 scopes it to the sanitize** — one of four passes, not all of them — and says the follow-up must rewrite Step 10a's build-once rule rather than sit beside it. *Out of scope* repeats it. |
| 12 | `P11-5` / `P11-7` — a second unbounded N, and the log-write cost | The **country list** is recorded as a second backend-sized collection sanitized on every form open, and `/verify` records its count. The shared log's read-modify-write is stated as a **disk** cost per call. |
| 13 | `SEC11-6` — the `HomeBloc` payload description is incomplete | Integration surface now names `deviceInfo`, `clientIp`, `userMarketPhone`, the market/chat/stories ids and names, the profile photo and `userVerifiedPhone` — PII, not only credentials — and carries it into the `AC-27` follow-up. |
| 14 | `SEC11-7` — the `AC-15` instruction to `/verify` is too broad | **Narrowed to its message clause.** `AC-15`'s success-flag rule stays live and verifiable; blanket supersession would have let a `200` with `success: false` be recorded as a successful save. |
| 15 | `SEC11-9` — the redaction scope misses a third artifact path | `.claude/_specs/manage-shop-locations-in-seller-dashboard.md` joins the pathspec. Revisions 7 to 11 all missed it. |
| 16 | `SR11-5` — `spec.md` says "the three that remain" where five are listed | Added to the `spec.md` correction list **and** to `/verify`'s instructions, which read the count from Step 0's table. |
| 17 | `SR11-6` — the line-count claim was wrong again | **No line-count figure is stated anywhere in this document.** A number that must be re-measured on every edit goes stale on every edit. |
| — | Carried, not actioned | `SR11-7` (the rounds 5–9 record lives in git history only) — accepted; `SR11-8` (the four-pass count was conservative) — superseded by item 10; `P11-8` (clear-on-dispose's CPU effect) — added to Approach 3 as half a sentence; `SR11-9`, `SEC11-11`, `SEC11-12`, `SEC11-13` are `info` and need no action. |

## Tests (PL-13 / PL-14)

| AC | Existing coverage found | Test file | Case | Disposition |
|----|-------------------------|-----------|------|-------------|
| every `AC-n` (`AC-1` … `AC-35`) | `none — searched test/, which holds only core/json_size_cap_test.dart` | — | — | `none — OQ-10 makes a manual run on a device against the development market server, plus static analysis, the acceptance evidence for every criterion. No widget or bloc test is added by this work item.` |

**Searched first, as `PL-14` requires.** There is no existing test for any dashboard
widget, bloc, model or data source — `test/` holds `core/json_size_cap_test.dart`
and nothing that covers this feature — so there is no file to `extend` and no
`existing` coverage to confirm. Every row would have been `new`.

**Why `none` rather than `new`.** Not "no test infrastructure" — `flutter_test`
and `mockito` are already dev dependencies. The reason is `OQ-10`: the owner chose
a manual device run as the acceptance evidence, and every `AC-n` is written to be
observed that way. **Two candidates a follow-up ticket could take up**, both pure
functions with no device needed:

- **the model's tolerant parse** — `latitude` and `longitude` arrive as strings
  and must go back as numbers, `address` / `country` / the coordinates can each be
  absent, and `meta` may be missing. A wrong parse here is invisible until a save
  fails at the backend;
- **the arrival-time drop** (`AC-22`) — the stamp compare, including the rule that
  a **null** stamp counts as a mismatch rather than a pass, and that the wrapper
  `copyWith` preserves the stamp rather than re-reading it.

Neither is written here. `IM-11` means `implement` writes exactly the rows above
and no others; a test this table does not declare is scope creep under `IM-4`.

## Plan ↔ REQ / AC traceability

| Step | Requirements / criteria it serves |
|------|-----------------------------------|
| 0 | The contract behind all of them: FR-7, FR-8 — AC-1, AC-5, AC-15, AC-23, AC-30, AC-32, AC-34, and the open questions Step 0's table carries |
| 1–5 | FR-1, FR-5, FR-6, FR-7 — AC-1, AC-11, AC-13, AC-23, AC-30, AC-34 |
| 3a | **The error path — the deciding step for FR-11, FR-12 — AC-14, AC-16, AC-21, AC-29, and the failure branch of AC-33** |
| 6 | FR-9 — AC-17, AC-18, AC-28, AC-31, AC-33 *(the permission values and checker methods)* |
| 6 + 11 | FR-9 — AC-19, AC-20 *(Step 6 supplies the check, Step 11 does the hiding)* |
| 7 | FR-1, FR-10, FR-13 — AC-2, AC-22, AC-24, AC-25 |
| 8 | FR-9, FR-10, FR-11 — AC-11, AC-13, AC-15, AC-17, AC-18, AC-21, AC-22, AC-23, AC-30 |
| 9 | FR-15 — AC-27 |
| 10 | FR-5, FR-6, FR-8, FR-11, FR-12 — AC-4, AC-8, AC-9, AC-10, AC-12, AC-14, AC-16, AC-29, AC-33, AC-34 |
| 10a | FR-12 — AC-29 (the one text rule, for every place backend text appears) |
| 11 | FR-1, FR-2, FR-3, FR-4, FR-7, FR-13 — AC-1, AC-3, AC-4, AC-5, AC-6, AC-7, AC-22, AC-25, AC-29, AC-30, AC-31, AC-32 |
| 12 | FR-14 — AC-26 |
| 13–14 | Non-functional; the evidence for every `AC-n` |

> **`AC-35` is deliberately absent from this table.** It declares itself a recorded
> residual rather than a criterion this work item meets, while holding an `AC-n`
> id — so no step serves it. Validation strategy tells `/verify` to record it as a
> residual, and the `spec.md` correction pass below is what would remove the id.

## Follow-up work this plan creates

- **A paging ticket, and it is due rather than conditional.** The contract
  confirms the list pages and that the page size is the shop's own
  `pagination_limit`, which the request cannot raise. So a shop with more locations
  than that setting **cannot see them all on this screen**, and that limitation
  ships knowingly. **Open the ticket; do not widen this one.** The list endpoint
  also accepts a country filter this screen does not use, which is natural scope
  for the same follow-up — as is the per-row lazy sanitize named in Step 7, the
  only lever against an unbounded N that `AC-1` permits.
- **A `spec.md` correction pass, and it needs a lifecycle route this workflow does
  not have.** Six findings across rounds 9 and 10 are `spec.md` defects the `plan`
  stage may not touch:
  - `SEC9-5` / `SR10-8` — `FR-12`, `AC-15` and the duplicate-name edge case still
    promise the per-field binding `A-12` removed;
  - `SEC9-6` — `AC-35` carries an `AC-n` id while declaring itself not a
    criterion, and `AC-16` embeds the gate instruction "if it turns out to be
    generic, this criterion is **not met**";
  - `SR9-9` / `SEC10-4` — a blank line after `AC-35` breaks the acceptance table,
    so `AC-30` … `AC-34` render as plain text, and `AC-35` sits out of numeric
    order;
  - `SEC10-2` / `SEC10-3` — `AC-24` says the shared request log is "the one
    recorded exception" when `HomeBloc`'s hydrated error list is a second one, and
    `AC-27` describes the error report as carrying tokens when it also carries
    `lastApiRequest`;
  - `SEC10-6` — `AC-29` names two harms and Step 10a's set closes one; widening
    the sanitizer to line separators, combining marks and zero-widths changes what
    `AC-29` is verified against.

  **Why these are follow-ups and not edits:** `development.plan` produces
  `plan.md`; `spec.md` belongs to the `spec` stage, and `workflow.yaml` declares no
  transition from `plan` or `review` back to `spec`. Editing it from here would be
  a stage rewriting evidence it does not own — the same defect `RV-11` names for
  gates. **Report to the Workflow Owner:** `development` needs a route back to
  `spec` — the way `review` has `changes_requested` — or the `spec` stage needs a
  declared revision entry path. The same shape of gap was recorded at `implement`
  on 2026-08-31 (`BLK-PLAN-REVISION-01`), where the Workflow Owner had to
  authorize an off-definition move. **This is now the second consecutive round
  where real corrections are blocked by the definition rather than by the work.**
  Until then, Validation strategy tells `/verify` how to read the spec as it
  stands.
- **Cap and strip the shared message overlay.** `show_message.dart` renders the raw
  backend message in a full-width `Overlay` through `MyTextWidget` with **no
  `maxLines`**, in release. It is app-wide, so it is not fixed here — but this work
  item newly routes **member-controlled** text through it (a location name echoed
  back inside a duplicate-name 422, shown to another member of the same shop).
- **Reject reserved keys in `post.dart`'s `extraHeaders` merge.** The caller's map
  wins over the base headers, and Dio normalises keys case-insensitively, so a
  lowercase `authorization` would replace the bearer. This work item cannot
  exercise it — Step 3 builds the map from one `const` key — but the door is open
  for every future dashboard write.
- **Prune `HomeBloc`'s hydrated error list.** It grows without bound on disk and
  now carries backend 422 text containing member-typed location names
  (`SEC10-2`). App-wide, pre-existing, and not this work item's to fix — but this
  work item adds six call sites that feed it.
- **Ask the backend team whether the contract file's sample address and Damascus
  coordinates are real.** The file is clean of auth material, but no grep pattern
  matches an address or a coordinate pair, and `.claude/` is committed. If they are
  real, replace them with obviously fake values.
- **Ask whether a location name may legitimately contain direction marks.** Step
  10a strips `U+200E`/`U+200F` from editable fields per `AC-29`, and Step 10 sends
  what the field holds — so an edit normalizes such a name (`SEC10-7`). Accepted
  and recorded here; if the answer is that they matter, the fix is to hold the raw
  value beside the stripped one, and it needs its own `AC-n`.
- **The open questions in Step 0's table** go to Mohamad Hassan when convenient.
  None blocks this work item. **`OQ-16` is the one to ask first**: it does not block
  the build, but it decides whether `AC-16` can be recorded met at `/verify`, and
  the answer costs one duplicate-name refusal against the development server.

## Out of scope

- Deleting a location for good — **impossible, not excluded.** The backend has no
  delete call, so this is a property of the contract rather than a choice.
- **Paging.** This screen issues one request and shows what it returns — no `load
  more` control, no page cursor, and no fetch-all loop. `AC-1` already says so.
- **The list's country filter.** The endpoint accepts one; this screen filters by
  status only, over the locations already loaded, without asking the backend again
  (`AC-7`).
- **The per-row lazy sanitize** named as the lever in Step 7. It is what would be
  done against a large N, and it belongs to the paging follow-up — not here.
  **That follow-up must rewrite Step 10a's build-once rule rather than sit beside
  it** (`P11-4`): sanitizing on first render *is* `itemBuilder` work, which Step
  10a forbids outright. Two rules, one of which has to give — and building once is
  the one this work item keeps.
- **Filtering what a member types into the form.** The controller is not
  filtered (Step 10a, `SEC11-3`), so a location name carrying direction-control
  characters — `U+202E` among them — **can be saved through this screen and will
  be rendered by consumers that have no sanitizer of their own**: the website,
  other clients, any future screen. **This is accepted, not overlooked**
  (`SEC11-10`, the owner's decision on 2026-09-01).

  **Why.** Validating what it stores is the backend's job, and this screen is not
  the only writer of location names — the become-seller flow writes them too, so a
  client-side filter here would close one door of two and create the false
  impression that stored values are clean. It is the same treatment this plan gives
  every other shared behaviour it does not own: `show_message.dart`'s uncapped
  overlay, `post.dart`'s caller-last `extraHeaders` merge, and `HomeBloc`'s
  unpruned hydrated list are each recorded and each left to their own ticket.

  **`AC-29` is unchanged and stays scoped to what this screen renders**, which is
  what it already says. **No new `AC-n` is added** — widening the criterion would
  be a `spec.md` change this workflow still has no route to make, and it would turn
  an accepted residual into an unmet criterion at `/verify`.
- A map or GPS picker. `OQ-3` is answered — coordinates are optional. The form
  neither shows nor edits coordinates; an edit preserves the ones a record already
  has (`AC-34`).
- **Any change to a shared HTTP client at all.** `get.dart`, `put.dart`,
  `patch.dart` and `delete.dart` are all untouched: every write here is a `POST`,
  and `post.dart` already honours `extraHeaders`. No existing request in any
  feature changes behaviour, and no `extraHeaders` support is added to the clients
  that discard it.
- Any change to the shared tab list **other than the single Locations subtitle line
  at `:1698`** — no visibility rule, no ordering, and not the tab card's count.
- Any change to the shared request logger, or to the shared error toast. Both are
  pre-existing behaviour that the amended `AC-24` and `AC-29` record.
- **Any change to `HomeBloc`, including pruning its hydrated error list.** This
  work item feeds that list through the shared interceptor and records the fact; it
  does not change it.
- Distinguishing an unknown permission state from a denied one — the amended
  `AC-18` records this as a limitation, and fixing it would touch how permissions
  reach all eleven tabs.
- Adding `buildWhen` to builders this ticket did not write, including the orders
  builder at `dashboard_page.dart:2056`.
- Translating values that come from the backend, including country names.
- The shop switcher itself, and anything that decides which shop is selected.
- A new app-wide state holder, or any change to how `DashboardBloc` is registered.
- A second reporting channel for failed writes. The shared interceptor already
  reports every failed request, and the only existing channel carries auth tokens.
- Linking a location to a boutique, to stock, or to shipping.
- Orders, products, gallery, team, stories, Excel, and Shop Info.
- New automated test infrastructure (`OQ-10`).
- A combined codegen + localization validation profile — a governance change, noted
  under Validation strategy, not made here.
