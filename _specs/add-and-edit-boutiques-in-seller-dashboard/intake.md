---
ticket: add-and-edit-boutiques-in-seller-dashboard
stage: intake
mode: standard
status: complete
owner: developer
updated: 2026-10-04
links:
  clickup: "https://app.clickup.com/t/z8n6b60hxc"
  github:
---

# Intake — add-and-edit-boutiques-in-seller-dashboard

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

- Slug: `add-and-edit-boutiques-in-seller-dashboard`
- ClickUp: https://app.clickup.com/t/z8n6b60hxc (Product Backlog list
  `901818662901`, status `draft`)
- Backlog ticket file: `.claude/_specs/add-and-edit-boutiques-in-seller-dashboard.md`
  (the same text as the ClickUp description)

## Ticket Summary

The Boutiques tab of the seller dashboard only lists boutiques today. This work
item lets a shop member create a boutique, open one, edit its content in every
language, and set it active or inactive. The rules and the result must match
the website.

## Ticket Metadata

- id / slug: `add-and-edit-boutiques-in-seller-dashboard`
- title: Add and Edit Boutiques in Seller Dashboard
- owner: developer (assignee in ClickUp: Ali Fouaad)
- created: 2026-10-04
- links: ClickUp https://app.clickup.com/t/z8n6b60hxc; GitHub — none yet
- Backbone: Seller Dashboard · Actor: Account Admin, Normal User (shop member)
- Time estimate: 32h (⚠️ estimate; +6h if a rich-text editor package is added)
- Sources named by the request:
  - API and form rules: `.claude/docs/seller-dashboard-boutiques-dev-guide.md`
  - Design: `.claude/htmlScreens/addBoiutic.html` (web create screen and view
    screen)
  - Entry point: `_buildBoutiquesTab()` in
    `lib/features/dashBoard/presentation/pages/dashboard_page.dart`

## User Story

> As a shop member with boutique permissions inside my own shop, I want to be
> able to create a new boutique, open an existing boutique, edit its content in
> every language, and set it active or inactive from the Boutiques tab of the
> seller dashboard, so that I can manage my shop's storefronts from the mobile
> app, with the same rules and result as the website, and no longer need a
> computer to do it.

## Acceptance Criteria Presence Check

- Present? **yes**
- Notes: grouped under Scope & Tenant Safety, Authorization, General Behavior,
  Form Fields, Behavior After Saving, Validation & Constraints, UI & API
  Consistency, Audit & Logging. They are not numbered as `AC-n` yet; `spec`
  assigns stable ids. Two groups depend on open points below: the description
  field (item 1) and the create / lookups shapes (item 2).

## Test Cases Presence Check

- Present? **yes**
- Notes: 11 Given/When/Then cases — 3 happy path (create, edit with banner
  reorder, set active), 4 validation (missing banner, file size and ratio,
  refused status change, duplicate name), 4 authorization (no create permission,
  no status permission, boutique of another shop, backend 403).

## Workflow Type Check

- Is the goal to *understand* something that already exists? **No** — the
  request is to build missing screens.
- Is the goal to *choose between options*? **No** — the approach follows the
  existing web editor and the dev guide. One sub-choice (description editor) is
  open, but it is a detail inside the build, not the goal.
- Is a *released* artifact failing, with a command that reproduces it? **No** —
  the add / edit controls are unbuilt `TODO`s, not a regression.
- Is the change to make already known, leaving only building it? **Yes** — the
  dev guide gives the full API contract, payload mapping and form rules, and the
  HTML file gives the design.

**How the type was resolved** (CU-7):

| | |
|---|---|
| Resolved type | `development` |
| Source | `argument` |
| ClickUp field said | `—` (no workflow-type field on the task; `workflow_type` and `workflow_type_raw` are both empty) |
| Argument said | `development` |

## Missing Information

Open questions carried into `research`. None of them blocks intake.

1. **Description editor.** The web sends HTML from a rich-text editor (Bold,
   Italic, Underline, H2). `pubspec.yaml` has `flutter_html` for display only
   and no editor package. The owner must choose: add an editor package, or use
   a plain multi-line field and wrap the text in `<p>…</p>`. This changes the
   estimate and possibly `pubspec.yaml`.
2. **Create, lookups and delete are not in the backend repo contract.** The dev
   guide (§10.1) says the shapes of `POST /shop/boutiques` and
   `GET /shop/boutiques/lookups` come from the working web code, not from the
   backend contract. They need confirmation from the backend owner, or an
   explicit recorded assumption, before `spec` fixes an `AC-n` on them.
3. **No product picker.** A new boutique cannot be set active until active
   products are attached some other way (guide §5.4). The ticket keeps this out
   of scope; `spec` must state how a new mobile-created boutique is expected to
   reach "active".
4. **Mobile list pages, web list does not.** The mobile list already uses
   `GetBoutiquesEvent(page)` with `boutiquesMeta`; the web loads the whole list.
   The ticket keeps the list unchanged. `research` should confirm that a
   refresh after save keeps the current page behaviour correct.
5. **Permission checks.** `CREATE_BUTIKS`, `UPDATE_BUTIKS` and
   `CHANGE_BOUTIQUE_STATUS` exist in `DashBoardPermission`
   (`lib/features/dashBoard/presentation/widgets/permission_enum.dart`), but
   `DashboardPermissionChecker` has only `canSeeBoutiques()`. `research` should
   confirm the backend sends these exact strings.
6. **Media upload reuse.** `UploadFileMediaServerUseCase` and
   `MediaServerEndPoints.uploadEP` / `bulkUploadEP` exist (stories use them).
   `research` should confirm they accept a custom folder
   (`boutiques/boutiques/icon`, `boutiques/boutiques`) and how the bulk answer
   is parsed (`bulk_upload_response.dart`).
7. **`GET /languages` in the app.** Is there already a languages call or model
   in the app, or is it new? The guide says its answer shape is not fixed.
8. **Protected runtime paths.** The work will likely touch
   `lib/common/constant/configuration/dashBoard_url_routes.dart`,
   `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart`,
   `assets/languages/**` and `lib/generated/locale_keys.g.dart`. `research`
   should confirm that `DashboardBloc` is not a `HydratedBloc` (a quick check
   found no hydration in `dashBoard_bloc.dart`), and `plan` must list every
   protected file.
9. **Size.** Create, edit, status, per-language form, upload queue and copy-from
   in one ticket is large for "one ticket = one focused outcome". `research` or
   `spec` should decide whether to split (for example: edit + status first,
   create second) or keep one ticket.
10. No ClickUp Epic id exists yet for the Seller Dashboard parent epic, so
    `User Story Relation` is empty.

## Readiness Status

`READY`

- Justification: the request names one dashboard tab and one set of
  operations, the API contract and payload mapping are written in the dev guide,
  the design is given, and both acceptance criteria and test cases exist. The
  open points are real, but `research` is read-only and can turn each one into
  a traceable `OQ-n`. Nothing is built at this stage.
- **Conditions carried forward:** `spec` must not fix an `AC-n` on the create
  or lookups shape (item 2) until it is confirmed or recorded as an explicit
  assumption, and must record the description-editor decision (item 1) before
  `plan`. The size question (item 9) is decided no later than `spec`.
