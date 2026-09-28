---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: spec
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Spec — read-and-reply-to-customer-comments-in-seller-dashboard

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Customer Comments — read and reply, in the seller dashboard.

## Business Goal

A seller's product pages carry customer questions that nobody answers, because
answering them means leaving the app and opening the website. The dashboard
already advertises a "Customers Comments" tab, and the tab opens onto nothing.
This work item makes that tab real, so a shop member can read what customers
asked, answer it, correct an answer, and remove one — inside the app, on their own
shop only.

## User Story

> As a shop member with comment permissions inside my own shop, I want to read the
> questions and reviews customers left on my products and answer the questions
> from the "Customers Comments" tab, so that I can answer buyers without leaving
> the app and questions stop sitting unanswered on my product pages.

## Functional Requirements

- **REQ-1 — The tab opens a real screen.** Selecting "Customers Comments" in the
  seller dashboard shows the comments screen instead of a placeholder.
- **REQ-2 — Two independent tabs.** The screen offers **FAQ** (customer questions)
  and **Reviewing** (purchase reviews). Each keeps its own list, its own page
  position, and its own loading / empty / error state; the screen opens on FAQ.
- **REQ-3 — Paged reading.** Each tab reads one page at a time and can extend the
  list with the next page while the server says more pages exist.
- **REQ-4 — A comment is shown in full.** Each card shows the customer's avatar
  (a placeholder when none is set), the customer name, the comment text, its date
  when the server sends one, and the number of hearts on it.
- **REQ-5 — Reviews carry a rating and no reply controls.** A review card shows a
  fixed row of five stars filled up to the rounded rating. It offers no reply,
  edit or delete action, because the server has no reply call for reviews.
- **REQ-6 — Create a reply.** A member with the reply permission can answer a FAQ
  comment that has no reply yet.
- **REQ-7 — Edit a reply.** A member with the edit permission can change an
  existing reply. The screen decides create-versus-edit from the comment's own
  "has a reply" flag, never from anything the member chooses.
- **REQ-8 — Delete a reply.** A member with the delete permission can remove a
  reply after confirming. The comment itself stays and returns to its unanswered
  form.
- **REQ-9 — Empty state.** A tab with no comments shows a round speech-bubble
  icon, the title "No comments found." and the line "Check back later for comments
  from customers.", with the tab controls still visible and usable.
- **REQ-10 — Permission gating.** The whole tab is hidden without the read
  permission. Each write action appears only with its own permission.
- **REQ-11 — Tenant safety.** Every request carries the shop the member is
  currently working in, taken from the session and never from input. A response
  that arrives after the member switched shops is discarded.
- **REQ-12 — Reply validation.** A reply must not be empty and must not exceed
  1000 characters, enforced before any request is sent.
- **REQ-13 — Defined behaviour per failure.** Each failure the server can return
  has one defined, observable outcome on screen.
- **REQ-14 — Multilingual and RTL.** Every visible string is translated in all
  four supported languages, and the screen lays out correctly right-to-left.
- **REQ-15 — Diagnostic logging.** Each comments action records what happened, in
  the form the seller dashboard already uses, without leaking secrets or customer
  content.
- **REQ-16 — Reactions are read-only.** Heart counts are shown and cannot be
  changed from this screen.

## Non-Functional Requirements

- **NFR-1 — No regression elsewhere.** No screen outside the seller dashboard
  changes behaviour, and no request the app already sends gains or loses a header
  because of this work item.
- **NFR-2 — Bounded reads.** A page never asks for more rows than the server
  allows, so a large shop cannot make the screen request an unbounded list.
- **NFR-3 — Bounded rendering.** Backend text is rendered as read-only display
  text and cannot reshape the row it is drawn in.
- **NFR-4 — One action at a time.** A reply, edit or delete in flight cannot be
  submitted twice.
- **NFR-5 — Static analysis stays clean.** The package analyses with no new
  errors, generated code stays in sync with its sources, and the four language
  bundles stay in sync for every key this work item adds.

## Constraints

- **CON-1** — The comments endpoints live on the web server, not the market
  server, and are authorised with the **market** token. No server identity in the
  app currently sends that pair, so the shared HTTP layer's server routing has to
  gain one. That is a protected runtime area and needs explicit approval at the
  review gate.
- **CON-2** — Only the POST verb in the shared HTTP layer supports a per-request
  header; GET, PUT and DELETE do not. Any approach that relies on adding a header
  per request is therefore unavailable to this feature.
- **CON-3** — The four comment permissions are not known to the app today and
  must be added to its permission list before any gate can read them.
- **CON-4** — The permission list cannot say "unknown": a list that failed to load
  and one that grants nothing look the same. Every gate therefore fails closed.
- **CON-5** — A reply is capped at 1000 characters and the server strips markup;
  the client sends plain text.
- **CON-6** — A page holds at most 50 rows by server rule; the screen asks for 10.
- **CON-7** — Reviews are display-only. There is no create, edit or delete for a
  review reply at any level.
- **CON-8** — The seller dashboard uses one bloc for the whole dashboard and a
  non-persisted state, so no stored-state migration is involved.
- **CON-9** — Everything written for this work item is in English.

## Edge Cases

- **EC-1** — A comment arrives with no date. The card shows no date rather than a
  substitute date.
- **EC-2** — A comment arrives with no avatar. A placeholder image is shown.
- **EC-3** — A FAQ comment has no rating (the server sends none). No stars are
  drawn on the FAQ tab.
- **EC-4** — The member switches shop while a page is loading, or while the reply
  dialog is open. The in-flight response is discarded and no comment from the
  previous shop stays on screen.
- **EC-5** — The member submits a reply for a comment that was deleted meanwhile.
  The screen says the comment no longer exists and removes the card.
- **EC-6** — The server returns an empty list for a shop id the token does not
  own. The screen shows the ordinary empty state; no other shop's data appears.
- **EC-7** — The last page arrives and the server says there are no more pages.
  The "load more" control disappears.
- **EC-8** — The member pastes text longer than 1000 characters. Only the first
  1000 characters are kept and the counter shows the limit.
- **EC-9** — The member has the read permission but none of the three write
  permissions. Every comment is readable and no write control is drawn.
- **EC-10** — The member holds the reply permission but the server still refuses
  with a permission error. The screen shows the permission message and changes
  nothing on the card.
- **EC-11** — The server rate-limits the request. The screen says to try again
  shortly and keeps what is already loaded.
- **EC-12** — A reply is edited. The reply's original creation time does not
  change.

## Research Questions Resolved

> Required (SP-9). One row per `OQ-n` in `research.md` — none may be skipped.

| OQ | Answer | Lands in |
|------|--------|----------|
| OQ-1 | **Deferred to `/plan` (PL-12).** Research ruled out the per-request-header option (`CON-2`), leaving two: give the existing web-server identity a token, or add a new server identity for seller comments. Which one is an approach decision, and it changes which files are touched. What the spec fixes is the boundary: whichever is chosen must not change the headers of any request the app already sends (`NFR-1`), and it edits a protected runtime area, so the review gate must approve it as such (`CON-1`). | `CON-1`, `CON-2`, `NFR-1`; repeated under Open Questions |
| OQ-2 | **Answered by assumption, recorded.** The shop identifier the dashboard already holds for the current session is the value sent as `seller_id`. No second identifier exists in the app, and the ticket's tenant rule requires the value to come from the session rather than from input. If the web server expects a different id, every call returns an empty list rather than an error — so `AC-27` requires the diagnostic log to carry the shop id, which is what makes that failure recognisable. | `REQ-11`, `AC-2`, `AC-27` |
| OQ-3 | **Answered: the app must not assume they arrive.** The four permission names are added to the app's permission list so they *can* be read, and every gate fails closed (`CON-3`, `CON-4`). If the backend never sends them, the tab stays hidden and no request is made — a defined outcome, not a crash. Confirming the backend really sends them is a backend question and is out of this work item's control. | `CON-3`, `CON-4`, `AC-19`, `AC-24` |
| OQ-4 | **Answered by the owner on 2026-09-09: hide the tab entirely.** Without the read permission the "Customers Comments" entry does not appear in the dashboard at all. This follows the ticket rather than the Locations precedent, and it means the change touches the dashboard's tab list, not only the screen. | `REQ-10`, `AC-19` |
| OQ-5 | **Answered by the owner on 2026-09-09: a fixed row of five stars, filled up to the rounded rating, no half stars.** | `REQ-5`, `AC-9` |
| OQ-6 | **Deferred to `/plan` (PL-12).** Whether the empty state reuses the dashboard's existing empty-state component or gets its own is an approach decision. The spec fixes only what the member sees (`AC-15`, `AC-16`). | `AC-15`, `AC-16`; repeated under Open Questions |
| OQ-7 | **Answered by the owner on 2026-09-09: code evidence plus static analysis.** Each `AC-n` is proven by reading the implementation together with the validation profile's checks. No manual device run is required for completion, and none is claimed as evidence. This is the same basis the sibling work item completed on, and it is recorded here rather than discovered at `/verify`. | `NFR-5`, and the evidence basis for every `AC-n` |
| OQ-8 | **Answered by the owner on 2026-09-09: follow the dashboard convention.** A private per-feature diagnostic log that records the action, its outcome and the shop id, and prints in debug builds only. It carries no token, no request body and no customer content. This work item does **not** call Sentry, and the ticket's Sentry wording is superseded. | `REQ-15`, `AC-27`, `AC-28` |
| OQ-9 | **Answered: "load more", appending.** `AC-13` and `AC-14` fix the behaviour — one growing list per tab, a control that appears only while the server says more pages exist. The dashboard's existing previous/next pager is a different interaction and does not satisfy `AC-13`. | `REQ-3`, `AC-13`, `AC-14` |
| OQ-10 | **Deferred to `/plan` (PL-12).** Where the screen's code lives is an approach decision and belongs in the files-to-change list, not here. | Open Questions |
| OQ-11 | **Deferred to `/plan` (PL-12).** How the two tabs' lists are held in state is an approach decision. The spec fixes the requirement it must satisfy: each tab keeps its own list, page and status, and switching tabs does not disturb the other (`AC-5`, `AC-6`). | `AC-5`, `AC-6`; repeated under Open Questions |
| OQ-12 | **Answered: four endpoints, not five.** The screen reads a page of comments and creates, edits and deletes a reply. The batch per-product counter call is not used — nothing on this screen shows per-product totals. | Out of Scope |

## Open Questions

- **OQ-1** — Which of the two remaining routes gives the comments calls the market
  token on the web server: extending the existing web-server identity, or adding a
  new identity for seller comments. `/plan` decides, names every file it touches,
  and the review gate approves it as a protected-runtime change.
- **OQ-6** — Whether the empty state reuses the dashboard's existing empty-state
  component or is drawn on its own. `/plan` decides.
- **OQ-10** — Whether the screen lives with the other dashboard screens or in its
  own file. `/plan` decides.
- **OQ-11** — How the two tabs' lists, pages and statuses are held in the
  dashboard's state. `/plan` decides.

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | Opening the "Customers Comments" tab shows the comments screen; no placeholder remains anywhere in the flow. | REQ-1 |
| AC-2 | Every comments request carries the shop identifier of the session's active shop; no code path lets a member supply, type or select it. | REQ-11 |
| AC-3 | A response that arrives after the active shop changed is discarded: it is not rendered, not written into state, and does not clear a loading state set by the new shop. | REQ-11, EC-4 |
| AC-4 | Switching the active shop clears both tabs' lists so no comment from the previous shop stays on screen. | REQ-11, EC-4 |
| AC-5 | The screen opens on the FAQ tab and offers exactly two tabs, FAQ and Reviewing. | REQ-2 |
| AC-6 | Each tab holds its own list, its own current page and its own loading / empty / error state; switching tabs leaves the other tab's list and page untouched. | REQ-2 |
| AC-7 | The FAQ tab reads only customer questions and the Reviewing tab reads only purchase reviews. | REQ-2 |
| AC-8 | A comment card shows the avatar (a placeholder when none is set), the customer name, the comment text, the date when one is sent, and the heart count. | REQ-4, EC-1, EC-2 |
| AC-9 | A review card shows a row of five stars filled up to the rounded rating; the FAQ tab draws no stars. | REQ-5, EC-3 |
| AC-10 | A FAQ comment with no reply shows the "waiting for a seller reply" hint together with the reply action. | REQ-6 |
| AC-11 | A FAQ comment with a reply shows the reply text, who replied, when, the reply's heart count, and the edit and delete actions in place of the reply action. | REQ-7, REQ-8 |
| AC-12 | A review card offers no reply, edit or delete action under any permission combination. | REQ-5, CON-7 |
| AC-13 | Loading more appends the next page below the existing rows in the same list; no row is duplicated and the list does not jump to the top. | REQ-3 |
| AC-14 | The "load more" control is shown only while the server reports that more pages exist, and disappears when it does not. | REQ-3, EC-7 |
| AC-15 | A tab whose read returns no comments shows the round speech-bubble icon, the title "No comments found." and the line "Check back later for comments from customers." | REQ-9, EC-6 |
| AC-16 | In the empty state the tab controls stay visible and the member can still switch tabs. | REQ-9 |
| AC-17 | A page request never asks for more than the server's maximum page size. | NFR-2, CON-6 |
| AC-18 | The four comment permissions are known to the app's permission list and are read through the dashboard's permission checker, never as a loose string comparison at a call site. | REQ-10, CON-3 |
| AC-19 | Without the read permission the "Customers Comments" entry does not appear in the dashboard, and no comments request is sent. | REQ-10, OQ-4 |
| AC-20 | The reply action appears only with the reply permission; the edit action only with the edit permission; the delete action only with the delete permission. | REQ-10 |
| AC-21 | Creating a reply sends the shop, the comment and the reply text; on success the dialog closes, a success message is shown, and the card shows the new reply in place, keeping the member's position in the list. | REQ-6 |
| AC-22 | Whether a submission creates or edits is decided from the comment's "has a reply" flag alone. | REQ-7 |
| AC-23 | Deleting a reply asks for confirmation first; on success the reply is gone and the card is back to its unanswered form, with the comment still listed. | REQ-8 |
| AC-24 | A permission failure from the server shows a permission message and changes nothing on the card. | REQ-13, CON-4, EC-10 |
| AC-25 | A reply that is empty or only whitespace cannot be submitted and produces no request; text longer than 1000 characters is cut to 1000 with the limit shown. | REQ-12, CON-5, EC-8 |
| AC-26 | Each of the server's failure kinds — unauthenticated, forbidden, rate-limited, invalid input, comment not found — produces its own defined message; on "comment not found" the card is removed and the rest of the list is untouched. | REQ-13, EC-5, EC-11 |
| AC-27 | Each comments action writes one diagnostic log line naming the action, its outcome and the shop id, in debug builds only. | REQ-15 |
| AC-28 | No log line contains a token, a request body, a reply text, a customer name, or an avatar address. | REQ-15 |
| AC-29 | While a reply, edit or delete is in flight the submit control shows a loading state and cannot be triggered again. | NFR-4 |
| AC-30 | A failed write leaves the dialog open with the typed text still in the field, and shows the server's message. | REQ-13 |
| AC-31 | Every string the member can see comes from the translation keys and is present in all four language bundles. | REQ-14 |
| AC-32 | The screen — tabs, cards, dialog and empty state — lays out correctly right-to-left. | REQ-14 |
| AC-33 | Heart counts are shown as a number and cannot be changed from this screen. | REQ-16 |
| AC-34 | Backend text is rendered as read-only display text that cannot reshape the row it is drawn in. | NFR-3 |
| AC-35 | No request the app already sends gains or loses a header, and no screen outside the seller dashboard changes behaviour. | NFR-1, CON-1 |
| AC-36 | Static analysis reports no new errors, generated code is in sync with its sources, and every translation key this work item adds is present in all four bundles. | NFR-5 |

## Out of Scope

- The batch per-product counter call (reactions, question totals, review totals,
  share totals for a list of products). Nothing on this screen shows those numbers
  (OQ-12).
- Liking or un-liking a comment or a reply. The server treats reactions as
  display-only.
- Replying to a review, in any form. The server offers no such call (CON-7).
- The buyer-side product screens that show the same comments to customers.
- Fixing the shared HTTP layer's habit of carrying headers across requests on one
  shared client. It is a real weakness, it is pre-existing, and changing it is a
  protected-runtime change with a blast radius far wider than this screen. This
  work item must not depend on that behaviour, which is what `AC-35` enforces.
- Adding a per-request header facility to the GET, PUT and DELETE verbs (CON-2).
- Bringing the four language bundles back into parity. They are already out of
  parity before this work item starts; that debt belongs to the sibling work
  item's open `BUG-1`. `AC-36` covers only the keys this work item adds.
- Any Sentry reporting (OQ-8).
