# Add and Edit Boutiques in Seller Dashboard

## Metadata

| Property | Value |
|---|---|
| **Title** | Add and Edit Boutiques in Seller Dashboard |
| **ID** | *(auto — ClickUp)* |
| **Status** | Backlog |
| **Backbone** | Seller Dashboard |
| **Actor** | Account Admin, Normal User (shop member) |
| **Assignee** | Ali Fouaad (the person running this command) |
| **Time Estimate (h)** | ⚠️ 32h (estimate — form with 4 language tabs, image upload queue, create + edit + status flow. Add 6h if a rich-text editor package must be chosen and added, see the open point below) |
| **Sprint** | ⚠️ TBD |
| **User Story Relation** | ⚠️ TBD — parent epic "Seller Dashboard (mobile)" |
| **Estimation per User Story** | — |

> **Sources for this ticket.**
> - API contract and form rules: `.claude/docs/seller-dashboard-boutiques-dev-guide.md`
>   (checked against the web code on 2026-10-04). When this ticket and the guide
>   disagree, the guide wins.
> - Design: `.claude/htmlScreens/addBoiutic.html` — the web "New Boutique" screen
>   (create mode) and the "Boutique" screen (view mode). The mobile screens follow
>   the same sections, order, labels, and colours.
> - Current mobile code: `_buildBoutiquesTab()` in
>   `lib/features/dashBoard/presentation/pages/dashboard_page.dart` and
>   `BoutiquesGridWidget` / `BoutiqueCard` in
>   `lib/features/dashBoard/presentation/widgets/boutiques_grid_widget.dart`.

> ⚠️ **Open points to resolve before this ticket leaves `Backlog`.**
> 1. **Description editor.** The web uses a rich-text editor (Bold, Italic,
>    Underline, H2) and sends HTML. `pubspec.yaml` has `flutter_html` (display
>    only) but **no rich-text editor package**. The owner must choose: (a) add an
>    editor package with the same four buttons, or (b) use a plain multi-line
>    field and send the text wrapped in `<p>…</p>`. The criteria below accept
>    either; the choice is recorded at `/wf:spec`.
> 2. **Create, lookups and delete are not in the backend repo contract** (guide
>    §10.1). Their shapes come from the working web code. Confirm with the
>    backend owner before implement.
> 3. **No product picker** (guide §5.4, §10.5). A new boutique cannot be set
>    active until products are attached some other way. This ticket does not add
>    a product picker.

> ⚠️ **Protected runtime paths this work will touch** (CLAUDE.md → Project
> profile). They may change only inside an approved `implement` stage, and only
> when `plan.md` lists them:
> - `lib/common/constant/configuration/dashBoard_url_routes.dart` (new endpoints —
>   API and network).
> - `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` (new status
>   fields — matches `**/*_state.dart`; the `DashboardBloc` is not hydrated today,
>   so no stored-payload migration is expected, but the plan must confirm it).
> - `assets/languages/**` and `lib/generated/locale_keys.g.dart` (new user-visible
>   strings; regenerate keys with `keys.sh`, never hand-edit).

---

## User Story

As **a shop member with boutique permissions inside my own shop**,
I want to be able to **create a new boutique, open an existing boutique, edit its
content in every language, and set it active or inactive from the Boutiques tab
of the seller dashboard**,
so that **I can manage my shop's storefronts from the mobile app, with the same
rules and result as the website, and no longer need a computer to do it**.

Today the Boutiques tab only shows a list. The **Add Boutique** button
(`onAddBoutique`), the empty-state action, and the card tap in `BoutiqueCard`
are all empty `TODO`s, and the only boutique endpoint in the app is
`DashBoardEndPoints.getBoutiques`. This ticket adds the create page, the
detail page (view mode + edit mode), and the status change, following the same
layers the dashboard already uses (data source → repository → use case → BLoC →
widget), the existing media-server upload (`UploadFileMediaServerUseCase`,
`MediaServerEndPoints.uploadEP` / `bulkUploadEP`), and the permission gating
through `DashboardPermissionChecker`.

**In scope:** create boutique; load one boutique for edit; view mode and edit
mode; update boutique; set active / inactive; availability; per-language name,
icon, description, bio and banners; copy a field from another language; banner
reorder and remove; restricted countries; client-side validation; permission
gating; loading, error and access-denied states; refreshing the list after a
save.

**Out of scope:** deleting a boutique (switched off on web, `canDelete = false`);
attaching or editing products of a boutique (`related_product_ids` is sent back
unchanged); changing `position` or `request_status`; any change to the list
endpoint or its paging; any change to the website or backend.

---

# Acceptance Criteria

## Scope & Tenant Safety
1. Every `/shop/boutiques…` request (list, lookups, create, edit, update,
   change-status) is sent with the `X-Seller-ID` header equal to the `sellerId`
   of the shop opened in the dashboard.
2. No boutique request is sent when the current `sellerId` is empty; the screen
   shows the error state instead.
3. A boutique id from another shop is never shown. When `GET …/{id}/edit`
   returns `404`, the detail page shows *"Boutique not found."* and no form data.
4. After switching to a different shop in the dashboard, no boutique data
   (list, form, cached lookups) from the previous shop is visible.
5. The create, update and change-status calls only ever target the boutique id
   that was loaded on the current page.

## Authorization
1. The **+ Add Boutique** button and the empty-state **Add your first boutique**
   action are shown only when the user has `CREATE_BUTIKS` or `SUPER_ADMIN`.
2. Tapping a boutique card opens the detail page only when the user has
   `UPDATE_BUTIKS` or `SUPER_ADMIN`; otherwise the card is not tappable.
3. The **Edit** and **Save Changes** buttons are shown only with
   `UPDATE_BUTIKS` or `SUPER_ADMIN`.
4. The **Set active / Set inactive** button is shown only with
   `CHANGE_BOUTIQUE_STATUS` or `SUPER_ADMIN`, and only in edit mode.
5. These checks are read through new methods on `DashboardPermissionChecker`
   (one per action: create, update, change status), never as a loose string
   compare in a widget.
6. Controls the user may not use are **hidden**, not disabled.
7. When the backend answers `403`, the page shows the access-denied state
   *"You don't have permission to view or edit this boutique."* and no form.

## General Behavior
1. **Add** opens a full page "New Boutique" that is always in edit mode and has
   no status button.
2. On opening **Add**, the app calls `GET /languages` and
   `GET /shop/boutiques/lookups`; the language tabs and the country chips come
   from these answers.
3. If `GET /languages` fails or returns an empty list, the tabs fall back to
   `en` English, `ar` العربية, `tr` Türkçe, `ku` کوردی.
4. Tapping a card opens the boutique page; it calls `GET /languages` then
   `GET /shop/boutiques/{id}/edit`, and opens in **view mode**: every field is
   locked, upload / remove / copy controls are hidden.
5. The page header shows the icon, the name, an **Active** (green) or
   **Inactive** (grey) pill, and `ID: {boutiqueId}`.
6. **Edit** unlocks the form. In edit mode a bar fixed at the bottom shows
   **Cancel** and **Save Changes**.
7. **Cancel** restores the last saved values in every language and returns to
   view mode, with no API call.
8. The form has three sections in this order: **Availability**, **Translations**,
   **Restricted Countries** — the same order and labels as
   `addBoiutic.html`.
9. **Set active / Set inactive** only flips the status in the form; no API call
   is made until **Save Changes**.
10. Each translation field has a **Copy from…** menu that lists only the other
    languages where that field is filled; picking one copies the value into the
    active tab. The menu is hidden in view mode and when no other language has
    the field.
11. Copied banners are copied **without** their `id`.
12. Each banner tile has move-left, move-right and delete controls; tiles are
    always laid out left-to-right, also in Arabic and Kurdish.
13. A loading indicator is shown while the page loads and while a save is in
    progress; the save buttons cannot be tapped twice during a save.
14. A load error that is not `403` / `404` shows an error box with **Retry**.

## Form Fields

### Required Fields
1. **Availability** — one of `1` Web, `2` Mobile, `3` Web + Mobile. Default `3`
   on create, and when the stored value is not 1, 2 or 3. The label is the
   app's own translated text, never the backend `label`.
2. **Name** — per language.
3. **Boutique Icon** — per language, one image.
4. **Description** — per language (HTML, see open point 1).
5. **Bio** — per language, plain text, 3-line field.
6. **Banners** — per language, at least one image, ordered.

Rules:
1. All required fields are validated in **every** language before saving.
2. The language tabs are the languages from `GET /languages` (or the fallback);
   the tab label is the language's `native_name`.

### Optional Fields
1. **Restricted Countries** — chips from `lookups.countries`; tap to select,
   tap again to clear. Empty means "available in every country". The chip label
   is the country name in the app language, built from `iso`.

## Behavior After Saving
1. **Create:** on success the app reads the new id (`data.boutique_id`, then
   `data.boutique.id`, then `data.id`) and replaces the "New Boutique" page with
   that boutique's page in view mode, status **Inactive**.
2. **Create:** if no id comes back, the app returns to the Boutiques list.
3. **Update:** on success, the saved values become the new "last saved" values,
   the page returns to view mode, and the toast *"Boutique updated
   successfully."* is shown.
4. **Update + status moved:** change-status is called **after** a successful
   update, and only when the status in the form differs from the saved status.
5. **Status refused (`422`):** the other edits stay saved, the status goes back
   to its old value, a red box *"Status could not be changed:"* lists every
   `detailed_error[].message`, and the toast *"Your changes were saved, but the
   status could not be updated."* is shown.
6. **Update failed:** the error is shown and the page stays in edit mode with
   the user's input kept.
7. After any successful create, update or status change, the Boutiques list
   (`GetBoutiquesEvent`) is refreshed when the user goes back to it.

## Validation & Constraints
1. Empty name → *Name is required.* on `translations.<code>.name`.
2. Empty description → *Description is required.* (an empty editor counts as
   empty, not `<p></p>`).
3. Empty bio → *Bio is required.*
4. No icon → *Icon is required.*
5. No banner → *At least one banner is required.*
6. When validation fails, the page switches to the first language tab with an
   error, marks the bad fields, shows the toast *"Please fix the highlighted
   fields before saving."*, and sends no request.
7. Icon and banner files must be images; a file larger than **10 MB** is
   blocked (*"Banner image must be 10 MB or smaller."* / the same rule for the
   icon). A non-image banner is blocked with *"Please choose an image file."*
8. A banner narrower than **600 px**, or with width ÷ height outside
   **1.5 – 1.8**, shows a warning dialog *"This banner may not display well"*
   with the recommended size (1280 × 750), the real size, and **Cancel** /
   **Ignore & upload**. If the size cannot be read, the file is allowed.
9. **Add banner** accepts several files; they upload one at a time, and the
   queue waits for the user's answer to any warning dialog.
10. Images are uploaded to the media server **before** save. The save body
    carries only the **bare file name** (`abc.webp`), never a folder path —
    also for existing images, whose full URLs from `/edit` are stripped to the
    file name. Icon folder: `boutiques/boutiques/icon`; banner folder:
    `boutiques/boutiques`.
11. The create body uses the key **`boutique_custom_data`**; the update body
    uses **`custom_data`**. The two are never swapped.
12. `boutique_global_data` takes name, description, bio and icon from the
    English (`en`) translation, or from the first language when there is no
    English entry.
13. Existing translations and existing banners are sent **with** their `id`;
    new or copied ones are sent **without** `id`.
14. Every language sends its **full** banner list, with `sequence` = position
    + 1 (1, 2, 3 …). A removed banner is simply left out of the list.
15. `product_resources` is the `related_product_ids` loaded from `/edit`,
    unchanged; on create it is `[]`.
16. `status` is never in the create or update body.

## UI & API Consistency
1. The mobile client enforces the same required fields and file rules as the
   web editor described in the dev guide §6.
2. Backend errors are shown by joining every `detailed_error[].message` with
   `" • "`; if that list is empty, `message` is used; if that is empty too, a
   fixed text (*"Failed to update boutique."* / *"Failed to create boutique."*).
3. Every user-visible text on the new pages is translated in `ar-SY`, `en-US`,
   `ku-IQ`, `tr-TR` through `LocaleKeys`, and the page layout is correct in RTL
   (except the banner row, which stays left-to-right).
4. The new screens follow the `addBoiutic.html` design: white cards with 15 px
   radius, section header with icon + title + subtitle, pill language tabs,
   16:9 banner tiles with a dashed **Add Banner** tile, country chips.

## Audit & Logging
1. On a successful create, update or status change, the app writes a `devLog`
   line with the action, `sellerId` and boutique id — no form content, file
   names or tokens.
2. On a failed request, the app writes a `devLog` line with the action, the
   HTTP code and the backend `message`.
3. A refused status change is logged with each `detailed_error` message.

---

# Test Cases

## Happy Path — Create a boutique in all languages
**Given** a shop member with `CREATE_BUTIKS` in shop `33`
**And** `GET /languages` returns en, ar, tr, ku
**When** they tap **+ Add Boutique**, choose *Web + Mobile*, fill name, icon,
description, bio and one banner in all four tabs, select *Syria*, and tap
**Create Boutique**
**Then**
- the icon and banners are uploaded to the media server first
- `POST /shop/boutiques` is sent with `X-Seller-ID: 33`, `boutique_custom_data`
  with four items, bare file names, `countries_iso: ["SY"]`,
  `product_resources: []`, and no `status`
- the app opens the new boutique's page in view mode with the **Inactive** pill

---

## Happy Path — Edit a boutique and reorder banners
**Given** a shop member with `UPDATE_BUTIKS`
**And** boutique `12` has two English banners (ids 7 and 8)
**When** they open boutique `12`, tap **Edit**, move banner 8 before banner 7,
add one new banner, change the bio, and tap **Save Changes**
**Then**
- `POST /shop/boutiques/12/update` is sent with `custom_data`
- the English banners are `{id 8, seq 1}`, `{id 7, seq 2}`, `{no id, seq 3}`
- the page returns to view mode and shows *"Boutique updated successfully."*

---

## Happy Path — Set a boutique active
**Given** a shop member with `UPDATE_BUTIKS` and `CHANGE_BOUTIQUE_STATUS`
**And** boutique `12` is inactive and approved, with active products
**When** they tap **Edit**, **Set active**, then **Save Changes**
**Then**
- the update call is sent first, then `POST /shop/boutiques/12/change-status`
  with `{ "status": 1 }`
- the header pill shows **Active**

---

## Validation Error — Missing banner in one language
**Given** a shop member creating a boutique
**When** every tab is complete except the Turkish tab, which has no banner, and
they tap **Create Boutique**
**Then**
- the page switches to the Turkish tab and marks the Banners field
- the toast *"Please fix the highlighted fields before saving."* is shown
- no request is sent

---

## Validation Error — Banner too large and banner with a bad ratio
**Given** a shop member in edit mode
**When** they add a 12 MB image, then an 800 × 800 image
**Then**
- the 12 MB file is blocked with *"Banner image must be 10 MB or smaller."* and
  is not uploaded
- the 800 × 800 file shows *"This banner may not display well"*; on **Cancel**
  it is not uploaded

---

## Validation Error — Status change refused
**Given** a shop member with `CHANGE_BOUTIQUE_STATUS`
**And** boutique `12` has no active related products
**When** they edit the name, tap **Set active**, and **Save Changes**
**Then**
- the update succeeds and the new name is kept
- change-status returns `422`; the pill goes back to **Inactive**
- a red box lists *"This Boutique Didn't Have active Related Products."*
- the toast *"Your changes were saved, but the status could not be updated."*
  is shown

---

## Validation Error — Duplicate name from the backend
**Given** another boutique in the shop is already called *"Cars"*
**When** the user saves a boutique with the English name *"Cars"*
**Then**
- the backend `422` message is shown as a toast built from `detailed_error`
- the page stays in edit mode with the input kept

---

## Authorization Failure — No create permission
**Given** a shop member with only `READ_BUTIKS`
**When** they open the Boutiques tab
**Then**
- the list is shown
- the **+ Add Boutique** button and the empty-state action are not shown
- the boutique cards are not tappable

---

## Authorization Failure — No status permission
**Given** a shop member with `UPDATE_BUTIKS` but without
`CHANGE_BOUTIQUE_STATUS`
**When** they open a boutique and tap **Edit**
**Then**
- **Save Changes** is shown
- the **Set active / Set inactive** button is not shown

---

## Authorization Failure — Boutique from another shop
**Given** a shop member of shop `33`
**When** the app requests `GET /shop/boutiques/999/edit` for a boutique owned
by shop `40`
**Then**
- the backend returns `404` and the page shows *"Boutique not found."*
- no form data is shown and no save control is shown

---

## Authorization Failure — Backend refuses with 403
**Given** a shop member whose `UPDATE_BUTIKS` was removed after the list loaded
**When** they open a boutique
**Then**
- the page shows *"You don't have permission to view or edit this boutique."*
- no form is shown

---

## Ticket Quality Checklist

- [x] Title is short and action-oriented (verb + object)
- [x] Status, Backbone, Actor, Assignee, Time Estimate are filled
- [x] Body contains all 3 sections: User Story, Acceptance Criteria, Test Cases
- [x] User Story uses As / I want / so that format with a real benefit
- [x] Summary paragraph includes scope, constraints, in/out of scope
- [x] Acceptance Criteria are grouped into named sub-sections
- [x] Every criterion is atomic and testable (yes/no)
- [x] Tenant safety is explicitly addressed
- [x] Authorization rules are clearly defined
- [x] Validation rules are clearly defined
- [x] Behavior After Saving is defined
- [x] UI & API consistency is defined
- [x] Audit & Logging rules are included
- [x] Test Cases cover: Happy Path, Validation Error, Authorization Failure
- [x] No ambiguous words ("maybe", "etc.", "should probably")
- [ ] Related tickets referenced by ID (if applicable) — ⚠️ parent epic ID is not known yet
