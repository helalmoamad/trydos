---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: spec
mode: standard
status: complete
owner: developer
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Spec — add-and-edit-boutiques-in-seller-dashboard

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Add and Edit Boutiques in Seller Dashboard

## Business Goal

Sellers can manage their boutiques (small storefronts inside a shop) only from
the website today. The mobile seller dashboard lists boutiques but cannot create
or change them. This feature brings create, view, edit and activate / deactivate
to the mobile app, with the same rules and the same stored result as the
website, so a seller can run their storefronts from the phone.

## User Story

> As a shop member with boutique permissions inside my own shop, I want to
> create a boutique, open an existing boutique, edit its content in every
> language, and set it active or inactive from the Boutiques tab of the seller
> dashboard, so that I can manage my shop's storefronts from the mobile app with
> the same rules and result as the website.

## Functional Requirements

- **FR-1 Tenant safety.** Every boutique request is made for the shop open in
  the dashboard, and only that shop's boutiques are ever read, shown or written.
- **FR-2 Permissions.** Each action is offered only to a user who holds its
  permission (or `SUPER_ADMIN`). Controls the user may not use are hidden.
- **FR-3 Tab access.** The Boutiques tab is reachable with any boutique
  permission, as on the website.
- **FR-4 Create.** A "New Boutique" page collects all required content and
  creates an inactive boutique, then opens it.
- **FR-5 View and edit.** Tapping a boutique opens it in a locked view mode;
  **Edit** unlocks it; **Cancel** restores the last saved values; **Save
  Changes** stores all edits.
- **FR-6 Status.** In edit mode the user can mark the boutique active or
  inactive; the change is applied after a successful save, and a refusal keeps
  the other edits.
- **FR-7 Per-language content.** Name, icon, description, bio and banners are
  entered for every language, one tab per language. A field can be copied from
  another language.
- **FR-8 Rich description.** Description is edited with Bold, Italic, Underline
  and Heading, and stored as HTML, like the website.
- **FR-9 Images.** Icon and banner images are checked, uploaded, shown at once,
  and stored by file name only. Banners can be added (several at a time),
  reordered and removed.
- **FR-10 Availability and countries.** The user chooses where the boutique is
  available (Web, Mobile, Web + Mobile) and may limit it to selected countries.
- **FR-11 Validation and errors.** Missing content is caught before any request
  is sent; backend errors are shown in a readable form.
- **FR-12 List stays current.** After a create, update or status change, the
  Boutiques list reflects it when the user returns.
- **FR-13 Same payload as the website.** What the app sends is the same shape
  the website sends, so a boutique saved on mobile reads correctly on the web
  and the other way round.

## Non-Functional Requirements

- **Localization:** every text written by the new screens exists in `ar-SY`,
  `en-US`, `ku-IQ` and `tr-TR`; layout is correct in RTL, except the banner row,
  which is always left-to-right (as on the website).
- **Responsiveness:** a save cannot be sent twice by tapping twice; loading
  states are shown during page load, upload and save.
- **Privacy in logs:** diagnostic logs hold the action, shop id, boutique id,
  result and HTTP code only — no form content, file names, tokens or tickets.
- **Design fidelity:** the screens follow the website's "New Boutique" and
  "Boutique" screens in section order, labels and visual style (white rounded
  cards, section header with icon, title and subtitle, pill language tabs, 16:9
  banner tiles with a dashed "Add Banner" tile, country chips).

## Constraints

- **C-1** The API contract is the one in the seller dashboard boutiques dev
  guide (checked against the web code on 2026-10-04). Where this spec and the
  guide disagree on the wire format, the guide wins.
- **C-2 [ASSUMED] contract.** The shapes of *create* (per-language key
  `boutique_custom_data`; new id read from `data.boutique_id`, then
  `data.boutique.id`, then `data.id`) and *lookups* (the lookups object directly
  under `data`, or under `data.lookups`) come from the working web code, not
  from the backend contract. They are accepted as assumptions. **Confirming them
  with the backend owner is a condition that must be met before `implement`
  starts.** Every AC that depends on them is marked **[ASSUMED]**.
- **C-3** The list call, its paging and its card layout are not changed, except
  that the list is reloaded after a save (AC-37) and the Add control follows its
  permission (AC-6).
- **C-4** No product can be attached in this feature. Attached product ids are
  sent back unchanged.
- **C-5** No test-runner check exists in the project configuration. By the
  owner's decision (OQ-5) this ticket declares no automated tests; verification
  uses the project's validation profiles plus a manual device run.

## Edge Cases

- The shop is switched in the dashboard while a boutique page is open, or while
  a request is in flight.
- The language list call fails or returns an empty or unreadable answer.
- A language from the list has no translation yet on an existing boutique.
- There is no English language; the global boutique values come from the first
  language.
- A boutique id belongs to another shop (backend answers `404`).
- Permissions were removed after the list loaded (backend answers `403`).
- Activation is refused (`422`) with one or more messages, after the edits were
  saved.
- The create answer carries no boutique id.
- A banner file whose size cannot be read.
- Several banner files are chosen at once and one of them needs a warning.
- An upload fails in the middle of a banner queue.
- The description editor is cleared — empty, not an empty paragraph.
- A copied banner set is saved for a second language.
- The stored availability is not 1, 2 or 3.

## Research Questions Resolved

| OQ | Answer | Lands in |
|----|--------|----------|
| OQ-1 | **Rich-text editor** (owner, 2026-10-04): Description is edited with a Bold / Italic / Underline / Heading toolbar and stored as HTML, like the website. Which package provides it is an approach choice for `plan`. | FR-8, AC-25, AC-26, Open Questions (OQ-1a) |
| OQ-2 | **Recorded as assumption** (owner, 2026-10-04). The create and lookups shapes from the dev guide are used and marked **[ASSUMED]**. Backend-owner confirmation is required before `implement`. | C-2, AC-13, AC-14, AC-32, AC-33 |
| OQ-3 | **No up-front note, same as the website.** A boutique created on mobile starts inactive. Activation is attempted from its page; when refused, the backend messages are listed (AC-35). Attaching products stays out of scope. | AC-34, AC-35, Out of Scope |
| OQ-4 | **One ticket** (owner, 2026-10-04): create, view, edit and status stay together. | Business Goal, FR-4..FR-6 |
| OQ-5 | **No automated tests in this ticket** (owner, 2026-10-04). Every `AC-n` will be `none — <reason>` in `plan.md > Tests`; verification is by validation profiles and a manual device run. | C-5 |
| OQ-6 | **`GET /languages` with fallback** (owner, 2026-10-04): tabs come from the language list; on failure or empty answer the tabs are English, العربية, Türkçe, کوردی. Which server answers it is decided in `plan`. | AC-11, AC-12, Open Questions (OQ-6a) |
| OQ-7 | **Backend name from lookups** (owner, 2026-10-04), as Locations does. Country names are not translated by the app. | AC-29, Out of Scope |
| OQ-8 | **Any of the five boutique permissions** shows the tab (owner, 2026-10-04), as on the website. | FR-3, AC-5 |
| OQ-9 | **Deferred to `plan`** — where the page state lives is an approach choice. The spec only requires the behaviour in AC-3, AC-4 and AC-37. | Open Questions |
| OQ-10 | **Deferred to `plan`** — how files are uploaded is an approach choice. The spec requires one-at-a-time banner processing with a waiting warning (AC-23) and file-name-only storage (AC-27). | Open Questions |
| OQ-11 | **Reload the list from the first page** when the user returns after any successful create, update or status change. HTML in card text and other list changes are out of scope. | AC-37, Out of Scope |
| OQ-12 | **View mode, then Edit** (owner, 2026-10-04), as on the website. | FR-5, AC-15..AC-18 |

## Open Questions

- **OQ-9** (deferred to `/plan`) — where the boutique page state lives: the
  app-wide dashboard bloc, or a bloc owned by the boutique pages.
- **OQ-10** (deferred to `/plan`) — banner upload mechanism: one single-file
  upload per banner, or a bulk upload use case.
- **OQ-1a** (new, for `/plan`) — which rich-text editor package, and how its
  HTML output is cleaned before sending.
- **OQ-6a** (new, for `/plan`) — which server answers `GET /languages`, and how
  its answer is parsed.

## Acceptance Criteria Mapping

### Scope & tenant safety

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-1 | Every boutique request (list, lookups, create, load for edit, update, change status) carries `X-Seller-ID` equal to the shop open in the dashboard; every write carries the shop id captured when its page was opened. | FR-1 |
| AC-2 | No boutique write is sent when the shop id is empty; the page shows an error instead. | FR-1 |
| AC-3 | When the dashboard shop changes, no boutique list, form or lookups from the previous shop is shown, and an answer that arrives for the previous shop is not applied. | FR-1 |
| AC-4 | When load-for-edit answers `404`, the page shows *"Boutique not found."*, no form data and no save control. | FR-1 |

### Authorization

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-5 | The Boutiques tab is shown when the user has any of `READ_BUTIKS`, `READ_BOUTIQUES`, `CREATE_BUTIKS`, `UPDATE_BUTIKS`, `CHANGE_BOUTIQUE_STATUS`, `DELETE_BUTIKS`, or `SUPER_ADMIN`; otherwise it is hidden. | FR-3 |
| AC-6 | **+ Add Boutique** and the empty-state **Add your first boutique** are shown only with `CREATE_BUTIKS` or `SUPER_ADMIN`. | FR-2 |
| AC-7 | A boutique card opens the boutique page only with `UPDATE_BUTIKS` or `SUPER_ADMIN`; otherwise the card does nothing on tap. | FR-2 |
| AC-8 | **Edit** and **Save Changes** are shown only with `UPDATE_BUTIKS` or `SUPER_ADMIN`. | FR-2 |
| AC-9 | **Set active / Set inactive** is shown only with `CHANGE_BOUTIQUE_STATUS` or `SUPER_ADMIN`, only in edit mode, and never on the New Boutique page. | FR-2, FR-6 |
| AC-10 | When the backend answers `403` on load, the page shows *"You don't have permission to view or edit this boutique."* and no form. | FR-2 |

### Loading, view and edit

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-11 | The translation tabs are the languages from `GET /languages`, labelled with each language's own name; duplicates appear once. | FR-7 |
| AC-12 | When `GET /languages` fails, or returns an empty or unreadable list, the tabs are English, العربية, Türkçe, کوردی. | FR-7 |
| AC-13 | **[ASSUMED]** Opening **Add** loads the lookups; the availability options and country chips come from them. If lookups give no availabilities, the three values Web, Mobile, Web + Mobile are offered. | FR-4, FR-10 |
| AC-14 | **[ASSUMED]** The New Boutique page is always editable, has **Cancel** and **Create Boutique** in the header and in a bar fixed at the bottom, and starts with availability Web + Mobile and no country selected. | FR-4 |
| AC-15 | Tapping a card opens the boutique page in view mode: every field locked; upload, remove, reorder and copy controls hidden. | FR-5 |
| AC-16 | The page header shows the icon, the name, a green **Active** or grey **Inactive** pill, and `ID: {boutique id}`. | FR-5 |
| AC-17 | **Edit** unlocks the form and shows **Cancel** and **Save Changes** in the header and in a bar fixed at the bottom. | FR-5 |
| AC-18 | **Cancel** restores the last saved values in every language and the saved status, returns to view mode, and sends no request. | FR-5 |
| AC-19 | The form has three sections in this order: Availability, Translations, Restricted Countries. A language with no stored translation opens with empty fields. A stored availability other than 1, 2 or 3 shows as Web + Mobile. | FR-5, FR-10 |
| AC-20 | A load error other than `403` / `404` shows an error box with **Retry**, and **Retry** loads the page again. | FR-11 |

### Translations and images

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-21 | Each of Name, Icon, Description, Bio and Banners has a **Copy from…** menu listing only the other languages where that field is filled; choosing one copies the value into the active tab. The menu is hidden in view mode and when no other language has the field. | FR-7 |
| AC-22 | Copied banners are new banners for the receiving language: saving them does not move or remove the source language's banners. | FR-7, FR-13 |
| AC-23 | **Add banner** accepts several files; they are processed one at a time, and when one needs a warning the rest wait for the user's answer. | FR-9 |
| AC-24 | A non-image file is blocked with *"Please choose an image file."*; an icon or banner larger than 10 MB is blocked with *"…must be 10 MB or smaller."*; a banner narrower than 600 px or with width ÷ height outside 1.5–1.8 shows *"This banner may not display well"* with the recommended size 1280 × 750, the real size, **Cancel** and **Ignore & upload**. A file whose size cannot be read is accepted. | FR-9 |
| AC-25 | The Description field has a Bold, Italic, Underline and Heading toolbar, and the stored description keeps that formatting as HTML. | FR-8 |
| AC-26 | A description that was formatted on the website opens with its formatting, and saving it from mobile without changes keeps the same formatting. | FR-8, FR-13 |
| AC-27 | A chosen image appears in the form at once; the saved value of every icon and banner — new or existing — is the file name only, never a folder path or full URL. | FR-9, FR-13 |
| AC-28 | Each banner tile has move-left, move-right and delete controls in edit mode; banners keep their order on save; a deleted banner is gone after save; banner tiles run left-to-right in every language. | FR-9 |
| AC-29 | Restricted Countries shows one chip per country from the lookups, labelled with the name the backend gives; tapping toggles selection; an empty selection means every country. | FR-10 |

### Saving

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-30 | Before any create or update request, every language must have a name, a description (an empty editor counts as empty), a bio, an icon and at least one banner; missing fields show *Name is required.*, *Description is required.*, *Bio is required.*, *Icon is required.*, *At least one banner is required.* | FR-11 |
| AC-31 | When validation fails, the page switches to the first language tab with an error, marks the bad fields, shows *"Please fix the highlighted fields before saving."*, and sends no request. | FR-11 |
| AC-32 | **[ASSUMED]** Create sends the per-language list under the create key, no `status`, an empty attached-product list, the boutique-level values taken from English (or the first language), and no ids. On success the New Boutique page is replaced by the new boutique's page in view mode with **Inactive**. | FR-4, FR-13 |
| AC-33 | **[ASSUMED]** When the create answer carries no boutique id, the user is returned to the Boutiques list. | FR-4 |
| AC-34 | Update sends the per-language list under the update key, with the id of every existing translation and existing banner, no id on new or copied ones, every language's full banner list in order, the loaded attached-product ids unchanged, and no `status`. On success the page returns to view mode and shows *"Boutique updated successfully."* | FR-5, FR-13 |
| AC-35 | When the status was moved in edit mode, the status change is sent only after a successful update. If it is refused, the edits stay saved, the status goes back to its old value, a red box *"Status could not be changed:"* lists every backend message, and *"Your changes were saved, but the status could not be updated."* is shown. If it succeeds, the pill shows the new status. | FR-6 |
| AC-36 | A failed create or update shows the backend messages joined with " • " (or the backend message, or *"Failed to create boutique."* / *"Failed to update boutique."* when there is none) and keeps the page in edit mode with the user's input. | FR-11 |
| AC-37 | After a successful create, update or status change, returning to the Boutiques list shows it reloaded from the first page. | FR-12 |
| AC-38 | While a save is in progress the save buttons cannot trigger a second request, and a loading state is shown. | NFR Responsiveness |

### Language, logging

| ID | Acceptance criterion | Maps to requirement |
|----|----------------------|---------------------|
| AC-39 | Every text the new screens write is translated in all four app languages, and the screens lay out correctly in Arabic and Kurdish (RTL), except the banner row. | NFR Localization |
| AC-40 | Each create, update, status change and load writes one diagnostic log line with the action, shop id, boutique id (when known), result and HTTP code; a refused status change logs each backend message; no log line contains form content, file names, tokens or upload tickets. | NFR Privacy in logs |

## Out of Scope

- Deleting a boutique (switched off on the website).
- Attaching, detaching or listing products of a boutique.
- Changing `position` or `request_status`.
- Translating country names in the app (OQ-7).
- Any other change to the Boutiques list: its paging, its card layout, and
  stripping HTML from card text (OQ-11).
- Any change to the website or the backend.
- Automated tests (OQ-5).
