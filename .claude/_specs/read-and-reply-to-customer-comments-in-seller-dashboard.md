# Read and Reply to Customer Comments in Seller Dashboard

## Metadata

| Property | Value |
|---|---|
| **Title** | Read and Reply to Customer Comments |
| **ID** | *(auto — ClickUp)* |
| **Status** | Backlog |
| **Backbone** | Seller Dashboard |
| **Actor** | Account Admin, Normal User (shop member) |
| **Assignee** | Ali Fouaad (AliFouaad24) |
| **Time Estimate (h)** | ⚠️ 16h (estimate — list + two tabs + reply dialog + edit/delete + 4 language files. Add 3h if the token routing in AC **Scope & Tenant Safety 4** turns out to need a new `ServerName` entry) |
| **Sprint** | ⚠️ TBD |
| **User Story Relation** | ⚠️ TBD — parent epic "Seller Dashboard (mobile)" |
| **Estimation per User Story** | — |

> ⚠️ **One thing to settle before implementation starts.**
> The Comments endpoints live on `{WEB_API}` (`WEB_APP` in `.env`) but are
> authenticated with the **market token**. In the app today,
> `getBaseUriForSpecificServer(ServerName.webApp)` returns the right base URI,
> but `getServerToken(ServerName.webApp)` returns `null`, and
> `ServerName.comment` — which does send a token — sends
> `prefsRepository.tokenForComment`, a different token. So no existing
> `ServerName` value sends *this* pair (WEB_APP base + market token). The file
> that decides this (`lib/core/api/methods/detect_server.dart`) is a
> **protected runtime path** under `CLAUDE.md`, and "adds or renames a
> `ServerName` entry or its base-URI resolution" is itself a protected-runtime
> trigger. The chosen option must be written into `plan.md` and approved at
> `/review` before any code is written. See AC **Scope & Tenant Safety 4**.

---

## User Story

As **a shop member with comment permissions inside my own shop**,
I want to be able to **read the questions and reviews customers left on my
products, and answer the questions, from the "Customers Comments" tab of the
seller dashboard**,
so that **I can answer buyers without leaving the app, and questions stop sitting
unanswered on my product pages**.

Today the entry point already exists and leads nowhere. `dashboard_page.dart`
lists a filter item at index 10 (`LocaleKeys.customers_comments.tr()`, subtitle
"Reply to reviews and FAQ"), and `_buildBody`'s `case 10:` returns
`CustomerComments()` — a `StatefulWidget` at the bottom of the same file whose
`build` returns `const Placeholder()`. This ticket replaces that placeholder with
the real screen: two tabs (**FAQ** and **Reviewing**), a paginated comment list,
an empty state, and a reply dialog for FAQ comments only. The design is fixed by
the three images in `.claude/docs/Images/` (`getComments.jpeg`,
`replayToComment.jpeg`, `emptyScreen.jpeg`). The server contract is fixed by the
**Comments & Reviews** section of
`.claude/docs/mobile-seller-dashboard-api-guide.md`.

**In scope:** list FAQ comments, list reviews, create a reply, edit a reply,
delete a reply, empty state, pagination, the four language files.
**Out of scope:** the batch product-social endpoint
(`POST {WEB_API}/api/seller/comments/social`) — it feeds per-product counters on
other screens, not this one; liking or un-liking a comment (the API guide states
reactions are display-only); replying to a review (the API offers no such call);
and any change to the product screens that show the same comments to buyers.
**Related:** "Manage Shop Locations in Seller Dashboard" — same dashboard, same
`ServerName` and permission plumbing, and the pattern to copy. ⚠️ Link by ID once
that ticket has one.

---

# Acceptance Criteria

## Scope & Tenant Safety

1. Every request sends `seller_id` taken from the **active shop of the current
   session** — the same value the other dashboard tabs already use. The user can
   never type, pick, or otherwise supply a `seller_id`.
2. When the user switches the active shop while the screen is open, the list is
   cleared and refetched for the new shop. No comment from the previous shop
   stays on screen.
3. A response for a `seller_id` the token does not own returns nothing (an empty
   list) or `403`; in both cases the screen shows no other shop's data.
4. The comments calls go to the `{WEB_API}` base (`WEB_APP` in `.env`) and carry
   the **market token** as `Authorization: Bearer <MARKET_TOKEN>`. Because no
   current `ServerName` sends that pair, `plan.md` must state which of these it
   does, and list the files it touches: **(a)** give `ServerName.webApp` a token
   in `getServerToken`, **(b)** add a new `ServerName` entry for seller comments,
   or **(c)** pass the header per request from the data source without touching
   `lib/core/api/**`. Options (a) and (b) change a protected runtime path and
   need explicit `/review` approval; (c) is preferred because it touches nothing
   shared.
5. No file outside the dashboard feature, the four language files, and the files
   named in **(4)** is modified. `lib/generated/locale_keys.g.dart` is
   **regenerated** with `keys.sh`, never hand-edited.

## Authorization

1. The tab and the screen are shown only when the session's permission list
   contains `READ_COMMENTS`. Without it, the dashboard filter item at index 10 is
   hidden, exactly like the other permission-gated tabs.
2. The **Reply** action on a comment is shown only with `REPLY_COMMENT`.
3. The **Edit** action on a reply is shown only with `EDIT_REPLY`.
4. The **Delete** action on a reply is shown only with `DELETE_REPLY`.
5. `READ_COMMENTS`, `REPLY_COMMENT`, `EDIT_REPLY` and `DELETE_REPLY` are added to
   `DashBoardPermission` in
   `lib/features/dashBoard/presentation/widgets/permission_enum.dart`, where they
   do not exist today, and are read through the existing
   `dashboard_permission_checker.dart`.
6. If the server answers `403` on any call, the screen shows a "you do not have
   permission" message and changes no data on screen.

## General Behavior

1. `CustomerComments` replaces its `Placeholder()` with the real screen and keeps
   its current entry point: dashboard filter index 10, `_buildBody` `case 10`.
2. The screen opens on the **FAQ** tab.
3. Two pill tabs sit at the top: **FAQ** (`type=faq`) and **Reviewing**
   (`type=review`), matching `getComments.jpeg`. The selected pill is filled, the
   other is plain.
4. Switching tabs loads that tab's first page. Each tab keeps its own list, its
   own page number, and its own loading / empty / error state.
5. A comment card shows: the customer avatar (a placeholder image when
   `user_avatar` is empty), `Q. <user_name>`, the comment `text`, `created_at` on
   the opposite side of the row, and a heart icon with `total_likes`.
6. On the **Reviewing** tab each card also shows the star `rating`. On the
   **FAQ** tab `rating` is `null` and no stars are shown.
7. When `has_reply` is `false`, the bottom row of the card shows the
   "Waiting Seller Reply…" hint on one side and the **Reply** action on the
   other, as in `getComments.jpeg`.
8. When `has_reply` is `true`, the bottom row shows `seller_reply`, `seller_name`,
   `reply_created_at`, a heart with `reply_total_likes`, and the **Edit** and
   **Delete** actions instead of **Reply**.
9. Review cards (`type=review`) never show **Reply**, **Edit** or **Delete** —
   the API has no reply call for reviews.
10. The list is paginated with `page` and `page_size` (`page_size=10`; the server
    maximum is 50). A **Load More** control is shown while
    `meta.has_more_pages` is `true`, and is hidden when it is `false`.
11. When a tab returns zero comments, the screen shows the empty state from
    `emptyScreen.jpeg`: a round speech-bubble icon, the title
    "No comments found.", and the line
    "Check back later for comments from customers." The tab pills stay visible.
12. Every visible string is a `LocaleKeys` entry translated in all four language
    files (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`), and the whole screen — pills,
    cards, dialog, empty state — lays out correctly in RTL.
13. Reactions are read-only: the heart is an icon plus a number, and tapping it
    does nothing.

## Form Fields

The only form is the reply dialog (`replayToComment.jpeg`). It opens over the
list, is titled "Reply to FQA Comment", carries a close (×) button, and shows the
customer name and the quoted comment text above the field.

### Required Fields

1. **Reply Text** — a multi-line text field labelled "Reply Text" with the
   placeholder "Write a reply…".

Rules:

1. **Submit Reply** is disabled while **Reply Text** is empty or holds only
   whitespace.
2. The dialog has exactly two buttons: **Cancel** and **Submit Reply**.
3. Opening the dialog through the **Edit** action (`has_reply` is `true`)
   pre-fills the field with the existing `seller_reply`.

### Optional Fields

*(none — the dialog has one field)*

## Behavior After Saving

1. Creating a reply (`has_reply` was `false`) sends
   `POST {WEB_API}/api/seller/comments/reply` with
   `{ seller_id, comment_id, reply_text }`.
2. Editing a reply (`has_reply` was `true`) sends the same body to the same path
   with **PUT**. The choice between create and edit is made from `has_reply`,
   never from anything the user picks.
3. Deleting a reply sends
   `DELETE {WEB_API}/api/seller/comments/reply` with `{ seller_id, comment_id }`,
   after a confirmation dialog.
4. On success the dialog closes, a success message is shown, and the affected
   card is updated in place: after create or edit, `has_reply` is `true` and the
   new `seller_reply` is visible; after delete, `has_reply` is `false` and the
   card is back to "Waiting Seller Reply…". The reading position is kept — the
   list does not jump to the top and already-loaded pages are not dropped.
5. While a reply call is in flight, **Submit Reply** shows a loading state and
   cannot be pressed twice.
6. On failure the dialog stays open with the typed text still in the field, and
   the message from the response is shown.

## Validation & Constraints

1. `reply_text` is rejected when empty or whitespace-only — on the client, before
   any request is sent.
2. `reply_text` is capped at **1000 characters**; the field stops input at 1000
   and shows a counter.
3. HTML is stripped by the server; the client sends plain text and adds no markup
   of its own.
4. `page_size` never exceeds **50**.
5. `comment_id`, `product_id` and `user_id` are handled as **strings**, and
   `rating`, `created_at` and `reply_created_at` are handled as nullable.
6. A comment whose `created_at` is `null` shows no date instead of a fallback
   date.

## UI & API Consistency

1. The client enforces the same reply rules as the server: not empty, at most
   1000 characters.
2. The client shows an action only when the session holds the matching
   permission; the server enforces the same permission and returns `403` when it
   does not.
3. Responses are read as `{ success: true, data }` on success and
   `{ success: false, message }` on failure, and that failure `message` is what
   the user is shown.
4. Each status code has one defined behaviour: **401** → the session-expired
   handling the rest of the dashboard already uses; **403** → the permission
   message; **429** → "too many requests, try again shortly"; **400** → the
   returned validation message; **404** → "this comment no longer exists" and the
   card is removed from the list.

## Audit & Logging

1. A failed comments call is reported to Sentry with the endpoint, the HTTP
   status, and the `type` and `page` in scope — never the token and never the
   reply text.
2. A successful create, edit, or delete of a reply is logged locally at debug
   level with `comment_id` and the action name only.
3. No customer name, avatar URL, or comment text is written to any log.

---

# Test Cases

## Happy Path — Seller replies to an unanswered FAQ question

**Given** I am a shop member with `READ_COMMENTS` and `REPLY_COMMENT`
**And** my shop has one FAQ comment with `has_reply = false`
**When** I open the "Customers Comments" tab, press **Reply** on that comment,
type "Yes, it fits with shorts." and press **Submit Reply**
**Then**
- `POST {WEB_API}/api/seller/comments/reply` is sent with my active `seller_id`,
  the card's `comment_id`, and the typed `reply_text`
- the dialog closes and a success message is shown
- the card now shows the reply text with my shop name, and the
  "Waiting Seller Reply…" hint is gone
- the list stays on the page I was reading

---

## Happy Path — Empty tab shows the empty state

**Given** I have `READ_COMMENTS`
**And** my shop has no reviews
**When** I open the tab and select **Reviewing**
**Then**
- the list area shows the speech-bubble icon, "No comments found." and
  "Check back later for comments from customers."
- the **FAQ** and **Reviewing** pills stay visible and stay switchable
- no **Load More** control is shown

---

## Happy Path — Load More appends the next page

**Given** I have `READ_COMMENTS`
**And** the first page of FAQ comments comes back with
`meta.has_more_pages = true`
**When** I press **Load More**
**Then**
- the same request is sent with `page` increased by one and the same `page_size`
- the new comments are appended below the existing ones, and none is duplicated
- when a response comes back with `has_more_pages = false`, the **Load More**
  control disappears

---

## Validation Error — Reply text is empty or too long

**Given** I have `REPLY_COMMENT` and the reply dialog is open
**When** I leave **Reply Text** empty, or paste 1200 characters into it
**Then**
- with an empty field, **Submit Reply** is disabled and no request is sent
- with the long paste, the field keeps only the first 1000 characters and the
  counter shows the limit
- no reply is created and the card is unchanged

---

## Authorization Failure — Member without reply permission

**Given** I am a shop member with `READ_COMMENTS` but without `REPLY_COMMENT`,
`EDIT_REPLY` or `DELETE_REPLY`
**When** I open the "Customers Comments" tab
**Then**
- I can read every FAQ comment and every review
- no **Reply**, **Edit** or **Delete** action is shown on any card
- if the reply call is made anyway, the API returns **403**, the screen shows the
  permission message, and nothing changes

---

## Authorization Failure — Comment belonging to another shop

**Given** I am signed in with shop **A** active
**When** a reply is attempted for a `comment_id` that belongs to shop **B**
**Then**
- the request carries shop **A**'s `seller_id`
- the server answers with no data, or **403**
- shop **B**'s comment never appears on screen and no reply is saved

---

## Error Handling — Comment deleted on the server

**Given** the reply dialog is open on a comment that another user has just
deleted
**When** I press **Submit Reply**
**Then**
- the API returns **404**
- the message "this comment no longer exists" is shown
- the card is removed from the list and the rest of the list is untouched

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
- [ ] Related tickets referenced by ID — ⚠️ the Locations ticket has no ClickUp ID yet
