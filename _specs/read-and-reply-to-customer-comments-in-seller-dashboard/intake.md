---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: intake
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Intake — read-and-reply-to-customer-comments-in-seller-dashboard

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

- slug: `read-and-reply-to-customer-comments-in-seller-dashboard`
- ClickUp: https://app.clickup.com/t/z8n6b5yctu
- Source ticket file: `.claude/_specs/read-and-reply-to-customer-comments-in-seller-dashboard.md`
- Design images: `.claude/docs/Images/getComments.jpeg`,
  `.claude/docs/Images/replayToComment.jpeg`, `.claude/docs/Images/emptyScreen.jpeg`
- API contract: `.claude/docs/mobile-seller-dashboard-api-guide.md`, section
  **Comments & Reviews**

## Ticket Summary

The seller dashboard already has a "Customers Comments" tab (filter index 10)
whose screen is a `Placeholder()`. This work item builds the real screen: two
tabs (FAQ and Reviewing), a paginated list of customer comments, an empty state,
and a reply dialog that lets a seller create, edit, and delete a reply on FAQ
comments only.

## Ticket Metadata

- id / slug: `read-and-reply-to-customer-comments-in-seller-dashboard`
- title: Read and Reply to Customer Comments
- owner: developer
- created: 2026-09-09
- links: ClickUp `z8n6b5yctu`; no GitHub PR yet

## User Story

> As a shop member with comment permissions inside my own shop, I want to read
> the questions and reviews customers left on my products and answer the
> questions from the "Customers Comments" tab, so that I can answer buyers
> without leaving the app and questions stop sitting unanswered on my product
> pages.

## Acceptance Criteria Presence Check

- Present? **yes**
- Notes: the ClickUp description carries eight named AC groups — Scope & Tenant
  Safety, Authorization, General Behavior, Form Fields, Behavior After Saving,
  Validation & Constraints, UI & API Consistency, Audit & Logging. They are
  numbered and atomic. They are **not yet `AC-n` ids** — assigning stable ids is
  the `spec` stage's job.

## Test Cases Presence Check

- Present? **yes**
- Notes: seven Given/When/Then cases — three happy paths (reply, empty state,
  Load More), one validation error (empty / over-long reply), two authorization
  failures (member without reply permission, comment of another shop), and one
  error-handling case (404 on a deleted comment). They are acceptance scenarios
  written for a human, not automated test declarations; `plan.md > Tests` still
  has to map each `AC-n` to a test file and case, or to `none — <reason>`.

## Workflow Type Check

Confirm this is a Development work item and not another workflow type. This and
`hotfix` are the only types that cut a branch and edit source files, so a wrong
answer here costs the most:

- Is the goal to *understand* something that already exists? **No.** The current
  behaviour is already known and trivial — `CustomerComments.build` returns
  `const Placeholder()`.
- Is the goal to *choose between options*? **No.** One open decision exists (how
  the comments calls get the market token onto the `{WEB_API}` base), but it is a
  single implementation detail inside a change whose outcome is already decided,
  not a direction to be researched. It is carried below as a condition on `plan`.
- Is a *released* artifact failing, with a command that reproduces it? **No.** The
  screen was never built. Nothing regressed, and there is no reproduction command.
- Is the change to make already known, leaving only building it? **Yes.** The
  design is fixed by three images and the server contract is fixed by the API
  guide.

**How the type was resolved** (CU-7):

| | |
|---|---|
| Resolved type | `development` |
| Source | `argument` |
| ClickUp field said | — (the task was pushed without metadata, so `workflow_type` came back `null` with no raw value) |
| Argument said | `development` |

No disagreement: only one side named a type.

> The ClickUp seed also needed a fix worth recording. `clickup_intake.py` reads
> `CLICKUP_API_TOKEN` from the shell environment, and that token is stale — the
> first run returned `CU-2 ERROR: HTTP 401`. Re-running with the token from the
> project `.env` succeeded. The script then failed a second time on printing,
> because the console codepage is `cp1256` and the description holds non-Latin
> characters; `PYTHONIOENCODING=utf-8` fixed that. Title, description and URL all
> came back and match the authored ticket.

## Missing Information

1. **Token routing for `{WEB_API}` (the one real open decision).** The comments
   endpoints sit on the `WEB_APP` base but need the **market** token.
   `getServerToken(ServerName.webApp)` returns `null` today, and
   `ServerName.comment` — the only other value on that base — sends
   `prefsRepository.tokenForComment`, a different token. So no existing
   `ServerName` sends this pair. `lib/core/api/methods/detect_server.dart` is a
   **protected runtime path**, and adding or renaming a `ServerName` entry is
   itself a protected-runtime trigger under `CLAUDE.md`. `research` must map what
   the three options actually cost; `plan` must name one and list its files.
2. **Where `seller_id` comes from on this server.** The dashboard's market calls
   carry the shop in an `X-Seller-ID` header (`_sellerHeader` in
   `dashBoard_remote_data_source_model.dart`); the seller-stories calls carry it
   as a `seller_id` **field**. The comments API wants `seller_id` in the query or
   body. `research` has to confirm that the same shop id the dashboard already
   holds is the value `{WEB_API}` expects.
3. **Permission strings are not in the app yet.** `READ_COMMENTS`,
   `REPLY_COMMENT`, `EDIT_REPLY`, `DELETE_REPLY` appear in the API guide's
   permissions table but are absent from `DashBoardPermission`
   (`lib/features/dashBoard/presentation/widgets/permission_enum.dart`).
   `research` must confirm they really arrive in the `auth/permissions` payload
   for a seller account, since `DashBoardPermission.fromString` silently returns
   `null` for anything it does not know.
4. **Locale keys.** Only `customers_comments` exists in
   `lib/generated/locale_keys.g.dart`. Every other string on this screen — the
   two pills, "Waiting Seller Reply…", the dialog title and labels, the empty
   state, and the five status messages — needs a key in all four bundles
   (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`) and a regeneration with `keys.sh`. The
   existing check `locale-bundles-in-sync` in `.claude/project-config.yaml` will
   catch a bundle left behind.
5. **No design for a review card.** `getComments.jpeg` shows the FAQ tab and
   `emptyScreen.jpeg` shows the Reviewing tab empty. There is no image of a
   review card carrying stars, so the star rendering has no reference. `spec`
   must either find one or state the rendering explicitly.
6. **No ClickUp Epic id** for the "Seller Dashboard (mobile)" parent, so
   `User Story Relation` stays empty. The sibling work item
   `manage-shop-locations-in-seller-dashboard` (ClickUp `z8n6b5xkzd`) is the
   closest pattern to copy and should be referenced by id once the epic exists.
7. **No device credentials recorded.** The sibling work item completed with every
   `AC-n` carrying code evidence only, because no seller account was available to
   run the app against a real shop (its FINDING-2). Nothing says that changed.
   `spec` should decide up front what counts as acceptance evidence here rather
   than discovering the gap at `verify`.

## Readiness Status

`READY`

- Justification: the request names one screen, one existing entry point, and one
  documented set of endpoints. Acceptance criteria and test cases both exist, and
  the design is fixed by three images rather than described in prose. The seven
  items above are real, but every one of them is answerable by reading — the API
  guide, the existing dashboard layers, the permissions payload, and the sibling
  work item — which is exactly what the read-only `research` stage does. Nothing
  here needs a decision from outside the repository before that stage can start.
- **Condition carried forward:** `plan.md` must name the token-routing option
  from item 1 explicitly and list every file it touches. If the chosen option
  edits `lib/core/api/**`, that is a protected runtime path and the `/review`
  gate has to approve it as such — it may not be slipped in as an incidental
  edit. Decided by the developer at intake on 2026-09-09.
