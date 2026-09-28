---
ticket: manage-shop-locations-in-seller-dashboard
stage: spec
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-31
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Spec — manage-shop-locations-in-seller-dashboard

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Shop Locations in the Seller Dashboard

## Business Goal

A shop's warehouses and pickup points decide where buyers collect what they buy.
Today the app shows an invented location that belongs to no shop, so a seller who
opens the Locations tab is reading a lie, and the only place to fix a real
location is the website. Showing the shop's real locations, and letting the
seller correct them in the app, removes that trip to the website and removes a
screen that cannot be trusted.

## User Story

> As a shop member with location permissions inside my own shop, I want to see,
> add, and edit my shop's locations from the Locations tab of the seller
> dashboard, so that my warehouses and pickup points are correct in the app and I
> no longer have to open the website to change them.

## Functional Requirements

- **FR-1** The Locations tab shows the locations that belong to the shop the
  dashboard is currently open on, loaded when the tab opens.
- **FR-2** Each location shows its name, its address, its country, and whether it
  is active.
- **FR-3** The number of locations the shop has is shown in the screen's own header, beside the "Locations" heading. The dashboard tab card's count is a different thing and is not changed.
- **FR-4** The status filter narrows the locations already shown, without asking
  the backend again.
- **FR-5** A member with the right permission can add a location by giving its
  name and its country. An address may be given and may be left out.
- **FR-6** A member with the right permission can change those same values on a
  location that already exists.
- **FR-7** *(`OQ-6` answered — see Amendment A-6.)* A member with the right
  permission can take a location out of service and put it back, without losing
  the record. The backend offers **only** this: there is no delete call at all, so
  a location can never be removed. Turning one off does not detach it from
  products that already point at it.
- **FR-8** *(`OQ-3` answered — see Amendment A-7.)* Map coordinates are
  **optional**: the backend saves a location with no map point. This screen
  therefore adds no map or GPS picker, and a location created here may carry no
  coordinates. Coordinates that already exist on a record are preserved, not
  discarded, when that record is edited.
- **FR-9** Every control on the screen is shown only to a member whose
  permissions allow the action behind it, and a screen the member may not read
  makes no request at all.
- **FR-10** Everything shown and everything saved belongs to the shop that is
  open. Changing shops replaces what is shown, and no save may land on a shop the
  member was not looking at.
- **FR-11** A save either closes the form and refreshes what is shown, or leaves
  the form open with the member's input intact and the reason visible.
- **FR-12** Required values are checked before a save is sent, and any reason the
  backend gives for refusing is shown to the member as it was written.
- **FR-13** The screen has a visible state for loading, for having nothing to
  show, and for having failed — and failing never throws away what was already
  loaded.
- **FR-14** Every word **this screen itself writes** is available in all four
  shipped languages, and the screen reads correctly right-to-left. Values that
  come from the backend are shown as received and are not translated.
- **FR-15** Every call this screen makes is traceable afterwards, and no
  credential ever appears in that trace.

## Non-Functional Requirements

- The screen reuses the dashboard's existing data, domain, and state layers. No
  new app-wide state holder is introduced, and no existing one changes how it is
  registered.
- This screen keeps no location data on the device after the session, and adds
  no storage of its own. The shared request log described in `AC-24` is the one
  recorded exception, and it is pre-existing.
- Loading the list must not block the rest of the dashboard: the tab renders and
  reports its own state.
- Acceptance is evidenced by a manual run on a device against the development
  market server, together with the project's static analysis. No new automated
  test infrastructure is added (`OQ-10`).

## Constraints

- The backend re-enforces every permission. Hiding a control is a courtesy to the
  member, never the security boundary.
- Files on the project's protected runtime list may change only inside an
  approved `implement` stage, and only when the approved plan names them.
- No new environment key may be introduced; everything this feature needs already
  exists in configuration.
- **The intake condition still holds, and is now satisfiable.** No criterion here
  is fixed against an endpoint, a stored field name, or a permission string that
  nobody has confirmed. The plan inherits that condition — but the confirmation
  now exists: `.claude/docs/mobile-seller-dashboard-locations-api-guide.md` is
  this work item's contract source of record. The main dashboard guide,
  `.claude/docs/mobile-seller-dashboard-api-guide.md`, is **not** the Locations
  reference and says nothing about them; it stays the source only for the shared
  parts the Locations guide points back to — the base URL, the auth headers, the
  response envelope, and the permissions call.
- Anything the Locations guide does not state is still unconfirmed. The guide
  ends by saying the full backend field limits are not published, so a limit it
  does not name may not be assumed.
- Deleting a location for good is **impossible**, not merely excluded — the
  backend offers no delete call.

## Edge Cases

- The member switches shops while a save is in flight. The save must not land on
  the newly selected shop.
- The permission list itself failed to load. The screen cannot tell that apart
  from "grants nothing" — both arrive as an empty list — so **read fails closed**
  and no request is sent, per the amended `AC-18`. This is the recorded
  limitation, not the preferred behaviour.
- The shop has no locations at all.
- The backend refuses a save and returns several reasons at once.
- The connection fails during a reload while locations are already on screen
  (for example the refresh after a save). Those locations stay, with an error and
  a retry over them.
- A location the shop got when it was first registered (through the become-seller
  flow) appears in this list. Editing it here changes that same record — see
  `OQ-11`.
- The member types a name longer than 255 characters. The limit is now known
  (`OQ-5`), so the screen stops it before sending (`AC-8`).
- The member reuses a name that already exists for the shop **in that same
  country**. The screen cannot know this — it does not hold the shop's locations
  in other countries — so the backend refuses it and the reason is shown against
  the name field (`AC-16`). Changing either the name or the country clears it.
- The country list for the add form fails, or is refused because the member may
  read but not create. That failure stays inside the form (`AC-33`); the list
  behind it keeps working.
- The member opens a location for editing that another member deactivated, or
  that no longer exists. The backend answers the same way in both cases, on
  purpose, so the screen closes the form and reloads rather than guessing which
  happened.
- Two rapid taps on save must not create two locations.

## Research Questions Resolved

> Required (SP-9). One row per `OQ-n` in `research.md` — none may be skipped.

| OQ | Answer | Lands in |
|------|--------|----------|
| OQ-1 | **Answered (2026-08-31, Locations guide).** Six calls exist: list, the create form's country list, create, load-for-edit, update, change status. They are still implementation detail (SP-4), so no criterion here names one — but the plan may now name them, because they are confirmed rather than assumed. | Constraints; Open Questions |
| OQ-2 | **Answered (2026-08-31, Locations guide).** Four permission strings, one per action, plus an admin value that satisfies all four. The criteria still specify what the member may do, not the constant that expresses it. | AC-17..AC-21, AC-31; Open Questions |
| OQ-3 | **Answered: coordinates are optional.** The backend saves a location with no map point, so "add a location" stays a form with no map screen. `FR-8` and `AC-34` now say so, and the map picker stays out of scope. | FR-8, AC-34; Amendment A-7 |
| OQ-4 | **Answered.** The country is picked from a list, never typed. It is stored as the code the backend keeps, and shown to the member as a readable country name — the two are not the same value. Which list feeds the picker is approach, deferred to `/plan`. | AC-4, AC-8; Open Questions |
| OQ-5 | **Answered: 255 characters**, and the name must additionally be unique per shop per country. `AC-8` now checks the length before sending. The uniqueness rule cannot be checked on the device — the screen does not know the shop's other locations in other countries — so its refusal is `AC-16`'s to show, against the field the backend names. | AC-8, AC-16; Amendment A-7, A-9 |
| OQ-6 | **Answered: deactivate only — there is no delete call at all.** `FR-7` gains `AC-30` and `AC-32`, and `AC-31` gates the control. Deleting is now impossible rather than merely excluded, and taking a location out of service does not detach it from products already pointing at it. | FR-7, AC-30..AC-32; Amendment A-6 |
| OQ-7 | **Answered: the list pages, and the page size is a shop setting the request cannot influence.** This screen still issues **one** request and shows what it returns (`AC-1`). Because a shop can hold more than one page, `AC-1`'s own branch has fired: reaching the rest is **a separate work item, and that ticket must be opened**. `AC-5` stands unchanged — the response carries a total, so the header badge can show the number the shop has. | AC-1, AC-5, FR-3; Amendment A-8 |
| OQ-8 | **Answered: the gate lives inside the screen only.** The tab stays visible to everyone; opening it without the read permission shows a message instead of calling the backend. The shared tab list and its visibility rules are not touched. This follows the sibling work item's decision for Shop Info. | AC-28; Out of Scope |
| OQ-9 | **Answered: in scope, for the screen's own words.** Every string **this screen itself writes** — labels, buttons, states, messages, and the tab's own subtitle — gets a translation in all four shipped languages, and the screen is checked right-to-left. Values the backend returns (a country name, a location name, a refusal message) are shown as received and are **not** translated (amended `AC-26` / `FR-14`). | AC-26, FR-14 |
| OQ-10 | **Answered: a manual run on a device against the development market server, plus static analysis.** Each `AC-n` is evidenced by an observation from that run. No new test infrastructure is added. | Non-Functional; Out of Scope |
| OQ-11 | **Deferred to `/plan`** — it needs the same backend answer as `OQ-1`. Recorded as an edge case: if the two are one record, this ticket's "no other flow is affected" claim is false and Out of Scope must be corrected. | Edge Cases; Open Questions |
| OQ-12 | **Answered: yes, the guard is required.** A save must carry the shop it was started for, and must not be applied if the open shop changed in between. | AC-23 |

## Open Questions

> Seven of these closed on 2026-08-31, when the Locations contract arrived at
> `.claude/docs/mobile-seller-dashboard-locations-api-guide.md`. **That file, not
> `mobile-seller-dashboard-api-guide.md`, is this work item's contract source.**
> The closures are recorded as Amendments A-5 … A-9 below.

- **OQ-1** — **closed.** Six calls exist. The approach names them; no criterion
  here does (SP-4).
- **OQ-2** — **closed.** Four permission strings, plus the admin bypass that
  satisfies all four.
- **OQ-3** — **closed: coordinates are optional.** `FR-8` and `AC-34` say so, and
  the map picker stays out of scope. This was the largest risk in the work item
  and it resolved the cheap way.
- **OQ-5** — **closed: 255 characters**, and the name must be unique per shop per
  country. `AC-8` carries the length; the uniqueness refusal is `AC-16`'s to show.
- **OQ-6** — **closed: deactivate only.** `FR-7` now has `AC-30` and `AC-32`.
- **OQ-7** — **closed: the list pages**, and the page size is a shop setting the
  request cannot influence. `AC-5` stands unchanged because the response carries a
  total. `AC-1`'s own branch has fired: reaching past the first page is a separate
  work item (Amendment A-8).
- **OQ-16** — **open**: what the backend's **top-level** `message` says for a 422
  on these endpoints. `AC-16`'s residual usability depends on it — the per-field
  list never reaches the screen, so the single message is all the member gets. If
  it is generic, `AC-16` is recorded as not met rather than argued into met.
- **OQ-15** — **open**: what the backend stores as the shop's own country, and
  whether a location in a different country is accepted at all. It decides only
  whether the picker may default; the member chooses today, from the backend's
  own list, so no answer is needed for the screen to be correct. **This question
  had no id of its own until now** — `plan.md` revision 7 filed it under `OQ-10`,
  which `research.md` and this spec already use for the acceptance-evidence
  question, so one id named two things (`SR7-7`). `OQ-15` is the next free id.
- **OQ-13** — **raised here, not by `research.md`, and open**: whether a country
  name follows the request's language header. `AC-4` is written so that either
  answer satisfies it, so this blocks nothing.
- **OQ-14** — **raised here, not by `research.md`, and open**: whether creating
  the same location twice is refused server-side by anything beyond the
  per-country name uniqueness. `AC-10` does not depend on the answer — the screen
  prevents the second send — so this blocks nothing either.

> `OQ-13` and `OQ-14` take the next free ids. They are **not** rows in *Research
> Questions Resolved* above, which carries one row per `OQ-n` that `research.md`
> raised (SP-9); these two came from reading the contract.
- **OQ-11** — **still open**: whether the become-seller location and a dashboard
  location are the same record. The contract does not say. Until it is answered,
  `Out of Scope`'s "no other flow is affected" claim is **unproven, not proven**,
  and the edge case that covers it stands.

> Every one of these must be answered or explicitly accepted at the `/review`
> gate. None of the three that remain changes what gets built; `OQ-11` changes
> only what this work item may claim about other flows.

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | Opening the Locations tab shows the locations that belong to the open shop. **Every location returned by one request is shown.** If the backend pages this list and a shop can hold more than one page, reaching the rest is **out of scope for this work item** and becomes its own ticket — this criterion is then read as "every location on the first page". Step 0 confirms which case applies before `implement` begins. | FR-1 |
| AC-2 | While the first load is running, a loading state is shown in place of the list. | FR-13 |
| AC-3 | Each location on screen shows its name, its address, its country, and an active or inactive marker. | FR-2 |
| AC-4 | The country is shown as a readable country name, not as the code the backend stores. **In the list, that name comes on the record itself** — each location carries its own country object — so no device-cached data is read to draw a row, and a row whose country is absent shows no country rather than a wrong one. **In the add and edit forms, the country is chosen from the list the backend returns for that form**, not from the app's marketplace country data: the two are different sets, and offering a country the backend does not accept would produce a refusal the member cannot act on. Whether either name follows the request's language header is unconfirmed (`OQ-9`); the name is shown as received either way. | FR-2 |
| AC-5 | The count in the screen's **own header**, beside the "Locations" heading, equals the number of locations the shop has — not the number currently drawn on screen. The dashboard tab card's count is a different thing, is not this criterion, and is not changed. | FR-3 |
| AC-6 | When the shop has no locations, an empty state is shown and the control for adding a location is still usable. | FR-13 |
| AC-7 | Choosing a status in the filter narrows the locations already shown, and sends no request. | FR-4 |
| AC-8 | The add form refuses to save while the **name** or the **country** is missing, or while the name is longer than 255 characters. **The address is optional and its absence never blocks a save** — the backend accepts a location without one. The country can only be chosen from a list. | FR-5, FR-12 |
| AC-9 | Text values are trimmed of leading and trailing spaces before they are sent. | FR-12 |
| AC-10 | The save control is disabled while a save is in flight, and two rapid taps create only one location. | FR-11 |
| AC-11 | After a successful add, the form closes, a success message is shown, what is on screen is refreshed, and the new location is among it. | FR-11 |
| AC-12 | The edit form opens already filled with that location's current name, address, and country. | FR-6 |
| AC-13 | After a successful edit, the location on screen shows the new values. | FR-6 |
| AC-14 | After a failed save, the form stays open, the member's input is still there, and **the form shows this screen's own translated failure text**. The backend's own words reach the member **only when the failure is a 400 or a 422**, through the app's shared error toast — outside this form. **On a permission refusal there is no backend text at all.** This is a **recorded limitation, not the preferred behaviour**: the shared client turns every failure into a response whose body has no `message` key **and flattens every status to 400**, so neither the reason nor the kind of failure reaches this screen's layer. Changing that means editing a protected shared file used by every API call in the app, which this work item does not do. | FR-11, FR-12 |
| AC-15 | A save is treated as successful only by the rule Step 0 confirms for that call. **If the write body carries a success flag, that flag decides and the HTTP status alone never does.** If Step 0 confirms the body carries no such flag, the HTTP status decides, and that is a **recorded limitation, not the preferred behaviour** — the shared clients (`PutClient`/`PostClient`) resolve success from the status code, and the dashboard's existing write model carries only a message. In both cases the backend's own message is shown. | FR-11 |
| AC-16 | When the backend refuses a save with several reasons at once, the member sees the backend's message **through the shared error toast**, as the backend wrote it, **for a 422**. **Binding each reason to the field that caused it is not done**, and this is a **recorded limitation**: the per-field list never reaches this screen — the shared client keeps it inside its own layer — so the form has nothing to bind. **Whether the toast's single message is specific enough to act on is unverified** (`OQ-16`): the field name lives in the per-field list, and what the top-level message says for a 422 is not specified by the contract. If it turns out to be generic, this criterion is **not met** and is recorded as such rather than argued into met. | FR-12 |
| AC-17 | A member without permission to read locations sees a message saying so: no request is sent, no loading state appears, and no retry control is offered. | FR-9 |
| AC-18 | When the member's permissions could not be loaded, the screen treats that as *not permitted* and sends no request — the same outcome as AC-17. This is a **recorded limitation, not the preferred behaviour**: the permission list reaches the screen as an empty list whether it failed to load or genuinely grants nothing, so the two cannot be told apart. Read fails closed. | FR-9 |
| AC-19 | The control for adding a location is not shown to a member without permission to create one. | FR-9 |
| AC-20 | The control for editing a location is not shown to a member without permission to change one. | FR-9 |
| AC-21 | When the backend refuses an action as not permitted, **nothing on screen changes** and the member is told the action failed **in this screen's own translated words**. **No backend text is shown**, and this is a **recorded limitation**: a permission refusal is a 403, the shared toast fires only for 400 and 422, and the status is flattened to 400 before this screen sees it — so the screen can neither show the backend's reason nor tell a permission refusal apart from any other failure. | FR-9 |
| AC-22 | Only the open shop's locations are ever on screen. Switching shops clears what is shown before anything new appears, and loads the new shop's locations. | FR-10 |
| AC-23 | A save carries the shop it was started for **on the request itself**, so a shop switch between starting the save and sending it cannot make it land on another shop. A comparison made before the request is built does not, on its own, satisfy this criterion. | FR-10 |
| AC-24 | This screen writes no location data to device storage of its own, and keeps nothing that survives an app restart. **The shared request log is a recorded exception:** the shared HTTP clients write every request and response — url, headers, query, body — into plain shared preferences on every call, capped at the newest 20 entries, and that copy does survive a restart. **This applies to all six of this screen's calls, not only the list** — so every country lookup and every edit-form open stores another copy of a record. Auth material is redacted there; **location names, addresses, coordinates and the shop id are not** — the tenant id is not among the log's redacted keys. This screen neither adds to that behaviour nor changes it. **The rule that drops a response belonging to another shop cannot keep that shop's data out of this log**, because the log is written by the shared client before the screen ever sees the response. | FR-10 |
| AC-25 | When loading fails with locations already on screen, those locations stay, an error is shown, and a retry control is offered. | FR-13 |
| AC-26 | Every word **this screen itself writes** — its labels, buttons, states, messages, and the tab's own subtitle — is available in all four shipped languages, and the screen reads correctly right-to-left. Values that come from the backend (a country name, a location name, a refusal message) are shown as the backend returns them and are **not** translated by the app. | FR-14 |
| AC-27 | Every call this screen makes leaves a trace of what was called and how it ended: **a local trace while developing**, and no more. **This screen sends no failure report of its own.** That trace carries **no request body and no headers** — only the action, the outcome and the shop id. No access token, api key, or authorization header value appears in any trace this screen adds. **Two pre-existing shared behaviours are recorded, not changed:** the shared request log stores every request and response (see `AC-24`), and the shared error interceptor reports every failed request to the backend with a payload that includes the member's stored service tokens. Neither is caused by this screen and neither is modified here. | FR-15 |
| AC-28 | The Locations tab entry stays visible to every member; the permission gate lives inside the screen. | FR-9 |
| AC-29 | Text that comes from the backend is shown **by this screen** as plain text only — never as markup, a tappable link, or a web view — with its displayed length capped and direction-control characters stripped, so a hostile message cannot reshape the screen or spoof it right-to-left. This covers the screen's own rendering: list rows, error banners, and the form. **The length cap applies to read-only rendering.** In an **editable** field the value keeps its full length — capping there would truncate a real name and write the truncation back on the next save — but direction-control characters are still stripped on the way in, and the value is never treated as markup. **This criterion covers what this screen renders** — list rows, the error banner and the form's prefills — all of which carry backend-controlled names and addresses. That is testable at the manual run. | FR-12 |
| AC-35 | **Recorded residual, not a criterion this work item meets.** The shared message overlay shows the raw backend message in release, **uncapped and unstripped**, before this screen sees the response — and it is a full-width `Overlay` with no line limit, not an OS toast, so an unbounded string is an unbounded-height overlay over the current route. This work item newly routes **member-controlled** text through it: a location name typed by one member is echoed back inside a duplicate-name refusal and shown to another member of the same shop. Changing that is app-wide and is not done here; it has its own follow-up ticket. `/verify` records this residual and does **not** treat it as part of `AC-29`. | FR-12 |

| AC-30 | A member with permission to change a location's status can take an active location out of service and put an inactive one back. The record is kept — nothing is removed — and the row's active or inactive marker afterwards shows **the value the backend returned for that call**, not the value the screen asked for. | FR-7 |
| AC-31 | The control for changing a location's status is not shown to a member without permission to change it. | FR-9 |
| AC-32 | No control anywhere on this screen deletes a location, because the backend offers no way to. Taking a location out of service does **not** detach it from products that already point at it, and the screen does not claim otherwise. | FR-7 |
| AC-33 | The add form asks the backend for its country list **only when the form opens**, never while the list is being shown. A member who may read locations but not create one still sees the list, and the failure of that call is confined to the form. | FR-5, FR-9 |
| AC-34 | Map coordinates are never required to save. When a location that already has coordinates is edited, those coordinates survive the save unchanged. | FR-8 |

## Out of Scope

- Deleting a location for good — **now impossible, not merely excluded.** The
  backend has no delete call at all (Amendment A-6), so this is a property of the
  contract rather than a choice this work item made.
- A map or GPS picker. `OQ-3` is answered — coordinates are optional (Amendment
  A-7) — so this line stands as written and needs no correction.
- Reaching past the first page of the list (Amendment A-8) — its own work item.
- Any change to the shared tab list or its visibility rules (`OQ-8`) — **except the single hardcoded English `subtitle:` line of the Locations entry**, which `AC-26` requires to be translated. That one line changes no visibility rule, no ordering, and not the tab card's count.
- The shop switcher itself, and anything that decides which shop is selected.
- Linking a location to a boutique, to stock, or to shipping.
- Orders, products, gallery, team, stories, Excel, and Shop Info — untouched.
- The website.
- New automated test infrastructure: no widget tests and no bloc tests are added
  by this work item (`OQ-10`).

---

## Amendments

> Added after this spec first reached `plan`. The review gate on 2026-08-27
> recorded `CHANGES_REQUESTED`, and two of its follow-ups are criteria defects
> rather than plan defects. The `development` lifecycle has no transition from
> `plan` back to `spec`, so the amendment is made in place and recorded here —
> the change is visible rather than silent.

| Change | Why | Source |
|--------|-----|--------|
| **AC-5 amended** | "The count next to the tab title" read two ways. The dashboard tab card's count lives in the shared tab list, which the plan puts out of scope and never named in Files to change — so one reading of AC-5 could not be satisfied by the plan under review. AC-5 now names the screen's own header badge, and says the tab card is explicitly not it. | `review.md` panel finding, senior lens, `major`; follow-up 2 |
| **AC-18 amended** | The criterion asked the screen to tell "permissions unknown" from "permissions deny". Permissions reach the screen as an empty list in both cases, so no implementation could satisfy it. AC-18 now states the real behaviour — read fails closed — and marks it as a recorded limitation rather than the preferred design. The API guide's own rule (an unknown must not lock out a seller) is knowingly not met; changing that needs a nullable permission list across all eleven tabs, which this work item does not do. | `review.md` panel findings, senior lens `major` + security lens `minor`; follow-up 1 |
| **AC-23 amended** | The criterion claimed a window was closed that was not. The shop id header is read when the request is built, not when the save is dispatched, so a pre-flight comparison leaves a real gap — and here the write is a create, which cannot be deleted. AC-23 now requires the shop id to travel **on the request**. | `review.md` panel finding, security lens, `major`; follow-up 6 |
| **AC-27 amended** | "Leaves a trace" reduced to a debug-only print under the pattern the plan copies, so a release build would keep no record of a wrong write. AC-27 now names both halves and forbids body and headers in either. | `review.md` panel finding, security lens, `minor` |
| **AC-29 added** | Backend-controlled text was shown verbatim in three places with no limit on length or content. In a right-to-left app, direction-control characters in a hostile message can reshape the screen around it. | `review.md` panel finding, security lens, `minor` |

### Second round — the contract arrived (2026-08-31)

> `BLK-STEP0-CONTRACT-01` closed when the Locations contract was written to
> `.claude/docs/mobile-seller-dashboard-locations-api-guide.md`. The `implement`
> stage read it, found that its answers contradict criteria written here, and
> blocked under `IM-10` rather than improvising (`implement.md`). These amendments
> are that contradiction being fixed at its source. As with the first round, the
> `development` lifecycle has no `plan → spec` transition, so the change is made
> in place and recorded — visible rather than silent.

| ID | Change | Why | Source |
|----|--------|-----|--------|
| **A-5** | **`AC-4` amended** | It said the country name comes from the marketplace's allowed-countries data, cached on the device, and accepted a stale-language caveat as the cost. The contract shows each location carrying its **own** country, so the list needs no cached data and the caveat does not apply to it. It also shows the **form's** country list to be a different, smaller set — the countries with an active shipping method — so filling the picker from the app's country data would offer countries the backend refuses. | Locations guide §1, §2, §4; `implement.md > Why this stage blocked` |
| **A-6** | **`FR-7` resolved; `AC-30`, `AC-31`, `AC-32` added** | `OQ-6` is answered: the backend can deactivate and **cannot** delete. `FR-7` had no criterion pending exactly this. `AC-30` also fixes a trap the contract names — the new marker must come from the response, not from what the screen asked for. `AC-32` records that turning a location off does not detach it from products already pointing at it, so the screen does not imply a cleanup it never performs. | Locations guide §6, "The six endpoints"; `spec.md > FR-7` ("it lands here by amendment") |
| **A-7** | **`FR-8` resolved; `AC-34` added; `AC-8` amended** | `OQ-3` is answered: coordinates are optional, so no map screen. Separately, `AC-8` required an **address** before saving, but the contract makes `address` optional and only `name` and `country_id` required — the screen would have refused a save the backend accepts. `AC-8` now also carries the 255 limit that closed `OQ-5`. `AC-34` keeps an existing record's coordinates through an edit, since this form never shows them. | Locations guide §3, §5; `implement.md > Why this stage blocked` |
| **A-8** | **`AC-1` branch fired; Out of Scope line added** | `OQ-7` is answered: the list pages, and the page size comes from the shop's own setting rather than the request, so the screen cannot ask for everything in one call. `AC-1` already provided for this and needs no rewording — but its consequence does: **reaching past the first page becomes its own work item, and that ticket must be opened.** `AC-5` stands unchanged because the response carries a total. | Locations guide §1 (`meta`); `AC-1` as amended in round one |
| **A-12** | **`AC-14`, `AC-16`, `AC-21` re-amended; `AC-29` split with `AC-35` added; `AC-24` extended; `OQ-16` added** | `A-10` was right that the message never reaches this screen and wrong about what follows. The round-8 gate found the trace stopped one field short: `handling_exception.dart:79` flattens **every** status to `400`, so a 403, a 404 and a 422 are indistinguishable here — and `log_interceptor.dart:92-105` fires its toast **only for 400 and 422**. So `A-10`'s `AC-21`, which promised the backend's words on a permission refusal, described a path that does not exist. `AC-14` now says the form shows the screen's own text and the backend's words appear only on 400/422; `AC-21` says no backend text appears at all; `AC-16` drops the claim that the backend's text names the field and defers to new `OQ-16`. `AC-29` is **split**: it had mixed a testable requirement with an instruction to the gate, so no evidence could make it met — it now covers this screen's rendering, and the shared overlay becomes `AC-35`, a recorded residual with its own follow-up ticket. `AC-24` extends from the list call to **all six** calls and records that the shop id is stored unredacted. | `review.md > Panel Findings > SR8-1`, `SR8-2`, `SR8-5`, `SR8-7`, `SEC8-3`, `SEC8-8`, `SEC8-9`; `lib/core/api/handling_exception.dart:66-79`; `log_interceptor.dart:92-105`; `lib/core/error/failures.dart:8-11` |
| **A-10** | **`AC-14`, `AC-16`, `AC-21` amended; `AC-29` reworded** *(superseded by `A-12`)* | The round-7 gate traced the error path and found `A-9`'s premise false. `log_interceptor.dart:208-227` resolves every failure into a *successful* `Response` whose body has no `message` key, so the branch of `handling_exception.dart` that reads the backend's message is unreachable, and `Failure` carries only a message and a status code anyway. **The backend's reason therefore never reaches this screen's own layer**, and the per-field binding `A-9` promised cannot be built without changing a protected shared file used by every API call in the app. The three criteria now describe what actually happens — the reason reaches the member through the shared toast — and are marked recorded limitations alongside `AC-15` and `AC-18`. `AC-29`'s "recorded gap" wording is corrected for the same reason: the toast is the **primary** path for backend text, not a secondary one. `plan.md > Steps 3a` carries the full trace and the decision not to widen the change. | `review.md > Panel Findings > SR7-1`, `SEC7-2`; `lib/core/api/log_interceptor.dart:208-227`, `methods/post.dart:113-124`, `handling_exception.dart:66-79`, `lib/core/error/failures.dart` |
| **A-11** | **`OQ-15` added to Open Questions** | The shop's-own-country question had no id of its own; revision 7 filed it under `OQ-10`, already in use here for the acceptance-evidence question. One id naming two questions makes `PL-12`'s "leave no `OQ-n` open" uncheckable. | `review.md > Panel Findings > SR7-7` |
| **A-9** | **`AC-16` amended; `AC-33` added** | The contract returns a refusal with the **field name** attached, which is better than `AC-16` assumed — a reason can be shown against the field that caused it instead of in a flat list. `AC-33` exists because the form's country list is behind the **create** permission: calling it while merely showing the list would give a read-only member a refusal on a screen they are entitled to see. | Locations guide "Errors", §2 ("Do not use this to build a filter list") |

> **Round 2 amendments.** The review gate on 2026-08-30 recorded a second
> `CHANGES_REQUESTED`. Its panel found four criteria that no implementation could
> satisfy, because each described behaviour the app's shared layers already
> contradict. They are corrected in place here, for the same reason as round 1:
> the `development` lifecycle has no transition from `plan` back to `spec`, so the
> change is made visible rather than silent. None of these reduces scope — each
> replaces a criterion that would have to be failed at `/verify` with one that
> states what is actually true.

| Change | Why | Source |
|--------|-----|--------|
| **AC-24 amended**, and the matching Non-Functional line | The criterion said no location data reaches device storage and nothing survives a restart. Both are already false: the shared HTTP clients call `saveRequestsData` on **every** request, writing url, headers, query, body and response into plain shared preferences (newest 20 entries, 8000-char cap), and that survives a restart. Auth material is redacted; location names and addresses are not. This screen neither causes that behaviour nor can fix it without changing a shared client every feature uses. AC-24 now states the screen's own obligation and records the shared log as a pre-existing exception. | `review.md` round 2, senior `major` `SR-1` + security `minor` `SEC-4` (found independently by two lenses); follow-up 1 |
| **AC-15 amended** | The criterion said the response **body** decides success and the HTTP status never does. But `PutClient` and `PostClient` resolve success from `statusCode == 200 or 201`, and the dashboard's existing write model (`ReadOnlyMessageFromApiModel`) carries only `message` and `response` — there is no success flag to read. As written the criterion could not be met by any implementation that reuses the existing model. AC-15 now defers the rule to what Step 0 confirms, and names the status-decides case as a recorded limitation rather than a silent one. | `review.md` round 2, senior `major` `SR-2`; follow-up 2 |
| **AC-29 amended** | The criterion asked for capped, stripped, plain-text rendering of backend text, but the create path is a POST and the shared client and interceptor already show the raw backend `message` as a global toast with `showInRelease: true` **before** this screen ever sees it — uncapped and unstripped. Sanitising inside the form cannot close a window that opens earlier and outside the screen. AC-29 now scopes the requirement to this screen's own rendering and records the shared toast as a known gap, including that one refusal can produce two messages. Capping at the shared display helper is an app-wide change and is not made by this work item. | `review.md` round 2, security `major` `SEC-2`; follow-up 3 |
| **AC-4 and AC-26 amended** | Revision 2 picked `lib/common/constant/countries.dart` as the country source. That file is the **phone dial-code** table: its entries carry `dialCode`, `minLength` and `maxLength`, its `name` is English only, and it lists ~250 countries the marketplace does not serve. It could not satisfy a readable country name in four languages. The source now becomes the marketplace's allowed-countries data, whose `Country` carries `iso` and `name` and is returned by the backend under the request's `lang` header. AC-26 is also corrected on a point it always got wrong: the app translates **its own** words, not values the backend returns. A location's name, a country's name, and a refusal message are shown as received. This rules out adding ~250 country keys to four app-wide language bundles. | `review.md` round 2, senior `major` `SR-3` + performance `info` `P-7`; follow-ups 4 and 5 |

> **Not amended, and why.** `AC-22` stands as written: the plan now re-checks the
> shop id when the list response arrives and drops a result that belongs to
> another shop, so "only the open shop's locations are ever on screen" is met
> without changing the shared `GET` client. `AC-1` also stands, on the condition
> that Step 0 confirms one page at the maximum page size holds every location a
> shop can have; if it does not, `AC-1` is amended before `implement` rather than
> satisfied by a fetch-all loop.

> **Round 3 amendments.** The review gate on 2026-08-30 recorded a third
> `CHANGES_REQUESTED`. Its panel found that the report channel the plan had
> named for a failed write sends four auth tokens to the backend, which made
> `AC-27` impossible to satisfy while that channel was used. Removing the report
> is the fix, and `AC-27` has to move with it — otherwise the plan would satisfy
> the spec by ignoring half of a criterion. Two smaller corrections join it.

| Change | Why | Source |
|--------|-----|--------|
| **AC-27 amended** | The criterion required an outcome-only report for every failed write. The only reporting channel the app has (`SendErrorToMobileErrorLogEvent`) builds a payload carrying `userMarketToken`, `userChatToken`, `userStoriesToken`, `userWalletToken`, `userMarketPhone` and `lastApiRequest`, JSON-encodes it and **POSTs it to the backend** — so satisfying the first half of AC-27 broke the second half ("no access token … in any trace or report"). Building a second, token-free reporting path is app-wide work this ticket should not do, and it is unnecessary: the shared interceptor already reports every failed request by itself. AC-27 now requires the local development trace only and states plainly that this screen sends no report of its own. | `review.md` round 3, `SEC3-1` — raised independently by all three lenses; follow-up 1 |
| **AC-4 amended** | The round-2 amendment justified the country name with "the backend returns it under the request's `lang` header". That is only half true: the allowed-countries data is held in a **hydrated** bloc state, persisted to disk and refreshed only at app start, so the names carry the language of the last refresh. A member who changes app language mid-session sees the previous language until the next start. The alternative — refetching the country list on every language change — is an app-wide effect for a warehouse form. AC-4 now states the real behaviour and accepts it. | `review.md` round 3, senior `major` `SR3-3`; follow-up 3 |
| **AC-24 amended** | The criterion already recorded the shared request log as an exception, but not the interaction with the new drop rule. A response belonging to another shop is written to that log by the shared client **before** the screen can drop it, so the drop rule cannot keep other-tenant data out of the log. One sentence, so the limit is visible rather than implied. | `review.md` round 3, security `minor` `SEC3-7`; follow-up 10 |

> **Still not amended at round 3.** `AC-22` stands: the read guard was challenged
> and **held** — the shop cannot change while the Locations tab is on screen,
> because the shop switcher sits below the tab route and reaching it pops the tab
> first. `AC-1` was left standing at round 3 **and was amended at round 4
> instead**, when the owner dropped paging from this work item; see the round 4
> table above.

> **Round 4 amendments.** The review gate on 2026-08-30 recorded a fourth
> `CHANGES_REQUESTED`. Two of these amendments follow the owner's decision to
> **defer paging to its own work item**; the other two are a **consistency pass**
> that four rounds of in-place amendment had made necessary — `FR-3` and
> `Out of Scope` were left behind when `AC-5` and `AC-26` moved, so the spec
> contradicted itself.

| Change | Why | Source |
|--------|-----|--------|
| **AC-1 amended** | Revision 4 tried to keep "every location the shop has is reachable" true in every case by adding a conditional `load more` control. That control turned out to be a second read path with its own state, event, tenant guard, filter interaction and cache rule — it was named in the plan and funded nowhere, and it accounted for three of the round's five `major` findings. The owner chose to drop it and make paging a separate work item. AC-1 now states what this ticket actually delivers, and Step 0 still confirms which case applies before `implement`. This is a **deliberate, recorded scope reduction**, not a silent one. | `review.md` round 4, `SR4-3` (all three lenses), `P4-4`; owner's scope decision; follow-up 1 |
| **AC-27 amended** | The round-3 rewrite removed the report channel correctly but dropped a control with it: "no request body and no headers" disappeared, so the local development trace could have printed real addresses and the `X-Seller-ID` header during a manual run — while the round-1 amendment row still claimed the control was there. The control is restored, which also makes that older row true again. The criterion now also names what the shared interceptor really sends, instead of describing it only as "reports every failed request". | `review.md` round 4, security `minor` `SEC4-5`, `SEC4-4`; follow-up 5 |
| **FR-3 amended** | `AC-5` was amended in round 1 to name the screen's own header badge and to say the dashboard tab card's count is explicitly not it. `FR-3` was never moved with it and still said "next to the tab title", so the requirement and its own criterion disagreed and the plan could not satisfy both. | `review.md` round 4, senior `minor` `SR4-9`; follow-up 7 |
| **FR-14 amended** | Found by the consistency pass, not by the panel. `AC-26` was amended in round 2 to say the app translates **its own** words and shows backend values as received. `FR-14` still said "every word the member reads on this screen", which includes a country name, a location name and a refusal message — so the requirement demanded translation that its own criterion forbids. `FR-14` now matches `AC-26`. | Revision 5 consistency pass; follow-up 7 |
| **Out of Scope amended** | The list still excluded "any change to the shared tab list", while `AC-26` requires the Locations subtitle — a hardcoded English string that lives inside that list — to be translated. The plan had re-worded the exclusion for itself, but the spec never was, so the two documents disagreed. The exclusion now names the single allowed line and keeps everything else out, including the tab card's count. | `review.md` round 4, senior `minor` `SR4-8`; follow-up 7 |

> **A note on the process, recorded once.** Four rounds of amending criteria in
> place is what created `SR4-8` and `SR4-9`: a criterion moved and the requirement
> above it did not. Revision 5's consistency pass checked **every** `FR-n` against
> its amended `AC-n` and found **one more drift the panel had not reported** —
> `FR-14`, amended above. `FR-15` was checked and left as it stands: "traceable
> afterwards" is still true through the shared request log, which `AC-24` and
> `AC-27` both record.

> **Round 5 amendments — a full read, not a targeted pass.** Round 4's pass
> checked every `FR-n` against its amended `AC-n` and stopped there, and the
> review gate found four rows elsewhere still describing the paging scope the
> owner had dropped. This round every section was read: User Story, all fifteen
> `FR-n`, Non-Functional, Constraints, all eight Edge Cases, all twelve
> `Research Questions Resolved` rows, Open Questions, all twenty-nine `AC-n`, and
> Out of Scope. **Seven rows needed correcting — four the gate named, and three it
> did not.**

| Change | Why | Source |
|--------|-----|--------|
| **`OQ-7` row, `OQ-7` open question, and the round-3 "not amended" note** | All three still described the paging scope dropped at round 4. The `OQ-7` row still said "every location the shop has must be reachable on the screen, and the count must match"; the open question still said `AC-1` and `AC-5` were written so either answer satisfies them; the round-3 note still said `AC-1` stands, without recording that round 4 amended it. A `/verify` run reading any of them would test a requirement this ticket deliberately dropped. | `review.md` round 5, senior `major` `SR5-3`; follow-up 3 |
| **Edge case: connection fails mid-load** | It described a failure "while **more** locations are being loaded" — the paging language again. Rewritten as the case that can actually happen now: a reload failing while rows are on screen, which is what `AC-25` covers. | `review.md` round 5, `SR5-3`; follow-up 3 |
| **Edge case: permission list failed to load** | **Found by this read, not by the panel.** It still said the member's rights are "*unknown* rather than *denied*" and that "reading must still be attempted; the backend decides" — the exact behaviour `AC-18` was amended away from in round 1. The spec was telling `/verify` to expect a request that the criteria forbid. | Revision 6 full read; follow-up 3 |
| **`OQ-9` row** | **Found by this read, not by the panel.** It still promised a translation for "every visible string on this screen", while `AC-26` and `FR-14` were amended to translate only the words this screen writes and to show backend values as received. The same drift as `FR-14`, one section further down. | Revision 6 full read; follow-up 3 |
| **`AC-29` amended** | **Found by this read.** `AC-29` requires a capped displayed length across "list rows, error banners, and the form", but the agreed text pipeline keeps **editable** fields at full length on purpose — capping there is what caused the truncation write-back (`P4-1`). Without this amendment the plan and the criterion contradict each other at the form. Editable fields now keep full length, still stripped of direction-control characters and never treated as markup. | `review.md` round 5, security `major` `SEC5-2`; revision 6 full read; follow-up 1 |

> **Checked and deliberately left as they are.** `FR-15` ("every call is traceable
> afterwards") still holds under the amended `AC-27`: this screen adds only a
> development trace, but the shared request log records every call in every build,
> and `AC-24` and `AC-27` both name it. `AC-5` keeps its wording; its dependency on
> `meta.total` is recorded in the `OQ-7` row and moves `FR-3` with it if the field
> is absent. Every other `FR-n`, `AC-n`, constraint and edge case was read and
> needed no change.
