---
ticket: connect-shop-info-widget-to-shop-info-api
stage: spec
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-24
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Spec — connect-shop-info-widget-to-shop-info-api

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Shop Info — read and edit the shop's public profile from the seller dashboard.

## Business Goal

A shop member can correct their own public profile — name, contact number,
address, logo, banner — from inside the app. Today the screen shows invented
values and its save button does nothing, so the only way to fix a wrong shop
profile is the website or a support request. Buyers see this profile, so a wrong
value costs the seller real business.

## User Story

> As a shop member inside my own shop (shop owner, or a team member holding the
> shop-info permissions), I want to see my shop's real name, contact number,
> address, logo and banner and save my changes, so that my public shop profile
> stays correct for buyers without asking support or using the website.

## Functional Requirements

- **FR-1 — Load.** Opening the screen fetches the shop's profile once and shows a
  loading state until it resolves.
- **FR-2 — Display.** The fetched values fill the five fields on screen. The
  record is read defensively: any field may be missing or empty without breaking
  the screen.
- **FR-3 — Permission-aware read.** The read happens only when the member is
  known to hold the read permission. A known denial skips the request entirely; an
  unknown permission state still sends it.
- **FR-4 — Permission-aware write.** The save and image controls are available
  only to a member known to hold the update permission, and a refusal from the
  backend is still surfaced when it happens anyway.
- **FR-5 — Image replacement.** The member can pick a new logo or banner, and the
  picked file is uploaded to the shop-media store before it can be saved.
- **FR-6 — Save.** Saving writes the whole profile — all five fields together, in
  one request.
- **FR-7 — Validation.** The three text fields are checked before anything is
  sent.
- **FR-8 — Outcome reporting.** Success and failure are decided by the response
  body's own success flag, and the message it carries is what the member sees.
- **FR-9 — Shop scoping.** Everything read and written belongs to the shop the
  member is currently viewing, and only that shop.
- **FR-10 — Shared values.** The currency and the new-product approval flag that
  come back with the profile are kept for the rest of the dashboard to use.
- **FR-11 — Language.** Every piece of text the member can see on this screen is
  available in the four languages the app ships, and reads correctly right to
  left.
- **FR-12 — Traceability.** Each outcome of a load, a save, or an upload leaves a
  record that a developer can find later, carrying no credential.

## Non-Functional Requirements

- One load request per screen opening — no polling, no repeated fetch on rebuild.
- A save cannot be started twice from one press; the control reports that it is
  busy.
- No perceived freeze: loading, saving and uploading each show progress.
- A member who lacks permission waits for nothing — no spinner that cannot end.
- Nothing on this screen writes which shop is selected; it only reads it.

## Constraints

- The profile is written whole. There is no partial update, so an unchanged field
  is re-sent as it was received.
- Image values are stored as a plain file name, not a path or a URL. Whatever form
  the profile returns them in, the saved form is the plain name.
- Client-side validation is deliberately weak and matches the web client: three
  fields must be non-empty and the contact must be digits with an optional leading
  plus. The backend's own rules are the authority, and its message is shown as it
  is.
- An HTTP 200 that carries a false success flag is a failure.
- This screen changes exactly five values. Currency, approval standing, boutique
  banners and shop locations belong to other screens.
- The change must not alter which shop is selected, nor how the shop identity is
  attached to requests.

## Edge Cases

- The profile returns an image as a bare file name, as a relative path, or as a
  full URL — all three must display.
- The profile has no logo and no banner at all.
- The member replaces only the banner; the logo must survive the save unchanged.
- The upload succeeds but the member leaves without saving — nothing changes.
- The upload fails — the previously shown image stays, and the value that would be
  saved is untouched.
- The permission list failed to load, so permissions are unknown rather than
  denied.
- The member holds the read permission but not the update permission.
- The member is a super admin, which satisfies both permissions.
- The save returns HTTP 200 with a false success flag and a message.
- The member switches to a different shop while the screen holds a loaded profile.
- The approval flag is absent from the response entirely.
- A returned image value came from a folder other than the shop-media folder — the
  plain-name rule loses that folder. Known, accepted, and recorded as a limit
  rather than solved here.

## Research Questions Resolved

> Required (SP-9). One row per `OQ-n` in `research.md` — none may be skipped.

| OQ | Answer | Lands in |
|------|--------|----------|
| OQ-1 | Do not block. Ship the client-side rules the web client uses and show whatever message the backend returns; the backend stays the authority on its own rules. The unverified rules are recorded as a constraint, not as a blocker. | Constraints; AC-19, AC-21 |
| OQ-2 | **Gate inside the screen only.** The tab stays visible to everyone; opening it without the read permission shows a message instead of calling the API. The shared tab list and its visibility rules are not touched. | AC-6; Out of Scope |
| OQ-3 | The two shop-info permission names are added to the dashboard's permission list so the gate names them rather than comparing loose text. This follows from OQ-2's answer — the gate is in the screen, but it still names real permissions. | AC-6, AC-9 |
| OQ-4 | **In scope.** Every visible string on the screen gets a translation key in all four shipped languages, and the screen is checked right-to-left. | FR-11; AC-26 |
| OQ-5 | **Store both.** The currency and the approval flag are parsed and kept in dashboard state, with "missing or null means not gated" for the flag. Neither is shown on this screen. | FR-10; AC-24, AC-25 |
| OQ-6 | The loaded profile is bound to the shop it was loaded for. When the screen is shown and the selected shop is not the one the held profile belongs to, the held profile is cleared and re-fetched before anything is displayed. | FR-9; AC-22, AC-23 |
| OQ-7 | **Deferred to `/plan`** (PL-12). Whether the existing upload path returns a plain name or a path, and what it needs to target the shop-media folder, is an approach question about existing code. The spec fixes only the observable outcome: after a successful upload the saved value is a plain file name. | Open Questions; AC-11, AC-15 |
| OQ-8 | **A manual run on a device against the dev market server, plus static analysis.** Each `AC-n` is evidenced by an observation from that run. No new test infrastructure is added. | Non-Functional; Out of Scope |

## Open Questions

- **OQ-7** — deferred to `/plan`: what the existing shop-media upload path
  returns, and what it needs in order to store into the shop-media folder. The
  observable requirement is already fixed by AC-11 and AC-15; only the approach
  is open.

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | Opening the screen fetches the profile exactly once and shows a loading state until it resolves. | FR-1 |
| AC-2 | On success the five fields show the fetched values, and none of the previous invented defaults appears anywhere. | FR-2 |
| AC-3 | A response missing any field, or carrying null for it, renders without an error and without an empty-looking crash. | FR-2 |
| AC-4 | An image value that already contains a full web address is displayed as it is; any other form is displayed against the media image base, with exactly one separator between them. | FR-2 |
| AC-5 | A failed load shows the message the backend returned and a way to retry; no partial profile is displayed. | FR-1, FR-8 |
| AC-6 | When the permission list loaded and does not grant reading shop info, no request is sent, and the screen states that the permission is missing — with no loading indicator and no retry control. | FR-3 |
| AC-7 | When the permission list itself failed to load, the request is sent anyway and the backend decides the outcome. | FR-3 |
| AC-8 | A member holding super admin passes both the read gate and the write gate. | FR-3, FR-4 |
| AC-9 | When the permission list loaded and does not grant updating shop info, the save control and both image controls are unavailable, with the reason stated. When the permission list is **unknown**, the write controls stay unavailable too — the write gate fails **closed**, unlike the read gate in AC-7, because the save replaces the whole profile. *(amended — see Amendments)* | FR-4 |
| AC-10 | A refusal that still comes back from the backend is shown to the member with its message, rather than being swallowed by the client-side gate. | FR-4, FR-8 |
| AC-11 | Picking a logo or a banner uploads that file to the shop-media store, and each upload obtains its own fresh authorization rather than reusing an earlier one. | FR-5 |
| AC-12 | A successfully uploaded image is shown in its box straight away, and is written to the profile only when the member saves. | FR-5, FR-6 |
| AC-13 | A failed upload shows the error, leaves the previously shown image in place, and leaves the value that would be saved unchanged. | FR-5 |
| AC-14 | A save sends all five values together, every time, including the ones the member did not change. | FR-6 |
| AC-15 | Both image values are sent as a plain file name, with any folder or address stripped. | FR-6 |
| AC-16 | When the member picked no new file, the value received at load is what is re-sent, reduced to a plain file name in the same way. | FR-6 |
| AC-17 | When there is no image at all, an explicit empty value is sent for it rather than an empty string. | FR-6 |
| AC-18 | While a save is in flight the control reports it is busy and cannot start a second save. | FR-6 |
| AC-19 | A save is refused before any request when the name, contact or address is empty, or when the contact is not digits with an optional leading plus; the failing field says why. | FR-7 |
| AC-20 | A save whose response reports success shows a success message, and the screen keeps showing the values that were just saved. | FR-8 |
| AC-21 | A save whose response reports failure — including one that arrives with a success HTTP status — is treated as a failure: the returned message is shown and the member's edits are kept. | FR-8 |
| AC-22 | Every request this screen makes is attributed to the shop the member is currently viewing, and never to a shop chosen anywhere else or held from an earlier visit. | FR-9 |
| AC-23 | When the selected shop differs from the shop the held profile belongs to, the held profile is cleared and re-fetched; no value from the previous shop is displayed or saved under the new one. | FR-9 |
| AC-24 | The currency that arrives with the profile is available to the rest of the dashboard after a successful load. | FR-10 |
| AC-25 | The new-product approval flag is available to the rest of the dashboard after a successful load, and a flag that is absent or null counts as "not gated". | FR-10 |
| AC-26 | Every visible string on the screen — labels, hints, buttons, validation messages, permission messages — appears in each of the four shipped languages, and the layout reads correctly right to left. | FR-11 |
| AC-27 | Each load, save and upload leaves a record of its outcome that a developer can find afterwards. No credential or authorization value appears in it, **and no request body field value** — shop name, contact number, address — either: field names, status and shop id only. *(amended — see Amendments)* | FR-12 |
| AC-28 | The save control stays unavailable until a load has completed successfully for the currently selected shop. An empty image value is sent only when the loaded record genuinely carried none — never because a load failed or returned nothing. *(added — see Amendments)* | FR-6, FR-9 |
| AC-29 | The shop the profile was loaded for is captured at load time and compared with the currently selected shop immediately before a save is dispatched. On a mismatch the save is abandoned, nothing is written, and the screen reloads for the newly selected shop. *(added — see Amendments)* | FR-9 |
| AC-30 | A picked logo or banner is constrained at pick time to a stated maximum dimension and byte size. A file above the limit is refused with a message before any upload request is made. *(added — see Amendments)* | FR-5 |

## Out of Scope

- Editing the currency, the approval standing, boutique banners, or shop
  locations — each belongs to a different screen.
- Hiding or reordering the Shop Info entry in the dashboard's tab list, and any
  change to the shared tab-visibility rules (OQ-2).
- The shop switcher itself, and anything that decides which shop is selected.
- Orders, products, gallery, team, stories, and Excel — untouched.
- New automated test infrastructure: no widget tests and no bloc tests are added
  by this ticket (OQ-8).
- Fixing the folder loss described in the last edge case. It is recorded as a
  known limit; solving it needs a backend answer.
- Cropping beyond what the existing image picking already offers.

---

## Amendments

> Added after this spec first reached `plan`. The review gate on 2026-08-24
> recorded `CHANGES_REQUESTED` and its follow-up brief required criteria that did
> not exist here. The `development` lifecycle has no transition from `plan` back
> to `spec`, so the amendment is made in place and recorded here — the change is
> visible rather than silent.

| Change | Why | Source |
|--------|-----|--------|
| **AC-28 added** | Nothing blocked a save built on a failed or partial load, so a save could null out a live logo and banner. `plan.md > Rollback` already admitted this is the one failure a revert cannot undo. | `review.md` panel finding, security lens, `major`; follow-up 3 |
| **AC-29 added** | `X-Seller-ID` is resolved at request-build time from prefs, so a shop switch between dispatching a save and the request being sent could write shop A's profile under shop B's id. AC-22 and AC-23 covered only the displayed profile, not the write path. | `review.md` panel finding, security lens, `major`; follow-up 3 |
| **AC-30 added** | No cap existed on a picked image. A full-resolution photo would be uploaded raw over mobile data and decoded into memory for a 100×100 preview. "Cropping is out of scope" did not cover size. | `review.md` panel finding, performance lens, `major`; follow-up 4 |
| **AC-9 amended** | FR-4 required the write gate to fail **closed** on an unknown permission state while AC-9 read as fail-**open**. For a full-replace write the two must agree; AC-9 now states the closed rule and names AC-7 as the deliberate difference for the read path. | `review.md` panel finding, security lens, `minor`; follow-up 6 |
| **AC-27 amended** | The criterion excluded credentials from the log record but said nothing about the payload, which carries the shop's contact number and address. | `review.md` panel finding, security lens, `minor`; follow-up 12 |

The requirement count is now **12 FR / 30 AC**. No existing `AC-n` id was reused
or renumbered.
