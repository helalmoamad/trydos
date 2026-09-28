# Manage Shop Locations in Seller Dashboard

## Metadata

| Property | Value |
|---|---|
| **Title** | Manage Shop Locations in Seller Dashboard |
| **ID** | *(auto — ClickUp)* |
| **Status** | Backlog |
| **Backbone** | Seller Dashboard |
| **Actor** | Account Admin, Normal User (shop member) |
| **Assignee** | Ali Fouaad |
| **Time Estimate (h)** | ⚠️ 20h (estimate — it assumes the Locations endpoints already exist on the backend; add 6h if the mobile side has to wait for, or adapt to, a contract that is still being written) |
| **Sprint** | ⚠️ TBD |
| **User Story Relation** | ⚠️ TBD — parent epic "Seller Dashboard (mobile)" |
| **Estimation per User Story** | — |

> ⚠️ **Blocker to resolve before this ticket leaves `Backlog`.**
> `.claude/docs/mobile-seller-dashboard-api-guide.md` has **no Locations
> section**. Its Shop Info section says the opposite — that "boutique banners and
> shop locations are all other screens/endpoints" — and its permissions table has
> no Locations row. So the endpoints, the field names, and the permission names
> used below are **assumed**, written from the widget that already exists in the
> app. Ask **Mohamad Hassan** (owner of `{MARKET_API}`) to confirm the real
> contract, then update this ticket and the API guide before any code is written.
> Every assumption is marked **[ASSUMED]** in the criteria below.

---

## User Story

As **a shop member with location permissions inside my own shop**,
I want to be able to **see, add, and edit my shop's locations from the Locations
tab of the seller dashboard**,
so that **my warehouses and pickup points are correct in the app, and I no longer
have to open the website to change them**.

Today `LocationsWidget` in
`lib/features/dashBoard/presentation/pages/dashboard_page.dart` (tab index 8) is
a static mock: it holds one hardcoded `LocationModel` in a local list, and
`_onAddLocation`, `_onEdit`, and `_onDeactivate` are empty `TODO` bodies. This
ticket replaces that mock with real `{MARKET_API}` data, following the same
layers the dashboard already uses for Shop Info and Gallery (data source →
repository → use case → BLoC → widget), and the same permission gating through
`DashboardPermissionChecker`.

**In scope:** list locations (with paging), add a location, edit a location,
activate or deactivate a location, permission gating, loading and error states,
and the existing status filter working on real data.

**Out of scope:** deleting a location for good; map or GPS coordinate picking;
linking a location to a boutique, to stock, or to shipping; any change to the
website; any change to the Orders tab.

---

# Acceptance Criteria

## Scope & Tenant Safety
1. Every Locations request is sent to `{MARKET_API}` with
   `Authorization: Bearer <MARKET_TOKEN>` **and** `X-Seller-ID: <sellerId>`,
   where `sellerId` is the shop the dashboard is currently open on.
2. The `sellerId` used is the one passed into the dashboard page. It is never
   read from a global variable and never hardcoded.
3. When the user switches to another shop, the Locations list is cleared and
   fetched again for the new `sellerId`.
4. A location loaded for one shop is never shown while another shop is selected,
   including after a screen rebuild.
5. `country` and `lang` headers are sent on every Locations call, like the other
   `{MARKET_API}` calls in the dashboard.
6. No location field is written to `hydrated_bloc` storage. The list lives only
   in memory for the open session.

## Authorization
1. The Locations tab content is shown when the user holds `READ_LOCATIONS`
   **[ASSUMED]** or `SUPER_ADMIN`.
2. Without that permission the tab shows a clear "you do not have permission"
   message, sends **no** request, and shows **no** spinner and **no** retry
   button — the same rule the API guide states for `GET /shop/info`.
3. If the permission list itself failed to load (unknown, not "no"), the request
   is sent anyway and the backend decides.
4. The **Add Location** button is shown only with `CREATE_LOCATION` **[ASSUMED]**
   or `SUPER_ADMIN`.
5. The **Edit** button on a card is shown only with `UPDATE_LOCATION`
   **[ASSUMED]** or `SUPER_ADMIN`.
6. The **Deactivate / Activate** button is shown only with
   `CHANGE_LOCATION_STATUS` **[ASSUMED]**, `UPDATE_LOCATION` **[ASSUMED]**, or
   `SUPER_ADMIN`.
7. All permission checks go through `DashboardPermissionChecker`, and the new
   permission names are added to `DashBoardPermission` in
   `lib/features/dashBoard/presentation/widgets/permission_enum.dart`.
8. A request that comes back 403 shows the message from the response body and
   changes nothing on screen.

## General Behavior
1. Opening the Locations tab calls
   `GET {MARKET_API}/shop/locations?page=N` **[ASSUMED]** and shows the returned
   locations in the existing card layout.
2. While the first page is loading, a loading state is shown in place of the
   list.
3. When the shop has no locations, the existing "No locations found" empty state
   is shown, and the **Add Location** button stays usable.
4. The count badge in the header shows the total reported by the backend
   (`meta.total`), not the number of items currently loaded.
5. The response is read tolerantly: the list is taken from `data.locations`,
   then `data.data`, then `data`; the paging meta from `data.meta`
   (`current_page`, `last_page`, `total`).
6. Each card shows the name, the address line, the country, and an Active or
   Inactive badge built from the backend `status` value (`1` = Active).
7. The "All statuses" dropdown filters the loaded list into All / Active /
   Inactive without sending a new request.
8. More pages are loaded when the user reaches the end of the list, while
   `current_page < last_page`. The same page is never requested twice.
9. **Add Location** opens a form. On success the list is fetched again and the
   new location appears.
10. **Edit** opens the same form filled with that location's current values. On
    success the list is fetched again and the card shows the new values.
11. **Deactivate** or **Activate** sends the status change and, on success,
    updates that one card. The whole list is not fetched again.
12. A failed request shows an error state with a **Retry** button, and the
    locations already loaded stay on screen.
13. All user-visible text uses `LocaleKeys` (the key `locations` already exists),
    with translations added for `ar-SY`, `en-US`, `ku-IQ`, and `tr-TR`. No new
    hardcoded English string is added to the widget.
14. The screen lays out correctly in RTL.

## Form Fields

### Required Fields
1. **Name** — the location name.
2. **Address** — the address line shown as the card subtitle.
3. **Country** — picked from a list, not typed free-hand.

### Optional Fields
1. **Status** — Active or Inactive. A new location defaults to Active.
2. **Phone** — contact number for the location. **[ASSUMED — keep this field
   only if the confirmed contract has it]**

Rules:
1. Every required field is validated before the request is sent.
2. The Save button is disabled while a save is in flight, so a double tap cannot
   create the same location twice.

## Behavior After Saving
1. On success the form closes, a success message is shown, and the list is
   fetched again for the current `sellerId`.
2. On failure the form stays open, keeps what the user typed, and shows the
   `message` from the response.
3. Success is decided by the `success` field in the response body, not by the
   HTTP status alone.
4. If the response is HTTP 422 with `detailed_error: [{ message }]`, every
   message in that array is shown to the user as a list.

## Validation & Constraints
1. Name, address, and country cannot be empty or only spaces.
2. Name and address are trimmed before they are sent.
3. Any backend validation message is shown as it comes back. The app does not
   rewrite it.
4. The client-side rules are for UX only. The backend rules are the real ones.

## UI & API Consistency
1. A control the user is not allowed to use is hidden, and the matching request
   is never sent from that screen.
2. The status on a card always comes from the backend value of the last
   successful response. The app never keeps a guessed status after a failed call.
3. Errors reach the UI as a structured failure (message plus status), through the
   same `Either` / failure path the other dashboard use cases use.

## Audit & Logging
1. Every Locations request and response is logged through the app's existing
   network logger, at the level already used by the other dashboard calls.
2. A failed create, edit, or status change is reported to Sentry with the
   endpoint, the HTTP status, and the `sellerId`.
3. No token, no `x-api-key`, and no full `Authorization` header value is ever
   written to a log or to Sentry.

---

# Test Cases

## Happy Path — Seller sees the real locations of the open shop
**Given** I am signed in and my shop has 3 locations on the backend
**And** I hold `READ_LOCATIONS`
**When** I open the Locations tab in the seller dashboard
**Then**
- A loading state is shown while the first page loads
- The 3 locations are shown as cards with name, address, country, and status
- The header count badge shows `3`
- The request carried `X-Seller-ID` equal to the open shop's id

---

## Happy Path — Seller adds a location
**Given** I hold `CREATE_LOCATION`
**And** I am on the Locations tab
**When** I tap **Add Location**, fill in name, address, and country, and tap Save
**Then**
- The Save button is disabled while the request is in flight
- A success message is shown and the form closes
- The list is fetched again and the new location is in it
- The count badge goes up by one

---

## Happy Path — Seller edits an existing location
**Given** I hold `UPDATE_LOCATION`
**And** the location "Main Warehouse" is in the list
**When** I tap **Edit** on it, change the name to "Central Warehouse", and save
**Then**
- The form opened already filled with the old values
- A success message is shown
- The card shows "Central Warehouse" after the list is fetched again

---

## Happy Path — Seller deactivates a location
**Given** I hold `CHANGE_LOCATION_STATUS`
**And** the location "Pickup Point A" is Active
**When** I tap **Deactivate** on that card
**Then**
- The status change request is sent for that location id
- Only that card changes to Inactive
- The rest of the list is not fetched again

---

## Validation Error — Saving with an empty name
**Given** I am on the Add Location form
**When** I leave the name empty and tap Save
**Then**
- A validation message is shown under the name field
- No request is sent
- No location is created

---

## Validation Error — Backend rejects the location with 422
**Given** I filled in every required field
**When** I tap Save and the backend answers HTTP 422 with
`detailed_error: [{ message: "Country is not supported" }]`
**Then**
- "Country is not supported" is shown to me
- The form stays open with what I typed
- No location is added to the list

---

## Authorization Failure — Member without read permission
**Given** I am a shop member without `READ_LOCATIONS` and without `SUPER_ADMIN`
**When** I open the Locations tab
**Then**
- A "you do not have permission" message is shown
- No spinner and no retry button are shown
- No request is sent to `{MARKET_API}`

---

## Authorization Failure — Member without create permission
**Given** I hold `READ_LOCATIONS` but not `CREATE_LOCATION`
**When** I open the Locations tab
**Then**
- The list is shown
- The **Add Location** button is not shown
- The **Edit** and **Deactivate** buttons are not shown either, unless I hold
  their own permissions

---

## Tenant Safety — Switching shops clears the list
**Given** I manage two shops, A and B
**And** I am looking at shop A's locations
**When** I switch to shop B
**Then**
- Shop A's locations leave the screen at once
- A new request is sent with `X-Seller-ID` equal to shop B's id
- Only shop B's locations are shown

---

## Error Handling — Network failure with a loaded list
**Given** the first page of locations is already on screen
**When** I scroll to load the next page and the network fails
**Then**
- An error message with a **Retry** button is shown
- The locations already on screen stay on screen
- Tapping **Retry** requests the same page again

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
- [ ] Related tickets referenced by ID — ⚠️ the parent epic id is not known yet
- [ ] ⚠️ **Locations API contract confirmed by Mohamad Hassan and written into
      `.claude/docs/mobile-seller-dashboard-api-guide.md`** — this box must be
      ticked before the ticket leaves `Backlog`
