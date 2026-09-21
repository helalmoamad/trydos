# Trydos — "My Checklist" Test Scenarios

Feature: add a product to **My Checklist**, see the list, and remove from it.

**Where it is**

- **Add / remove**: Product details → the **"..." (more options)** sheet → the
  row **"Add to my checklist"**.
- **The list**: Profile → **My checklist**.

**Before you start**

- You must be **logged in**. The list lives on the server, not on the phone.
- Prepare **more than 10 products** in the checklist, because one page holds 10.
- Test on Android and iOS, in **Arabic (RTL)** and in **English (LTR)**.

---

## 1. Add a product

- [ ] Open a product → "..." → the row **"Add to my checklist"** is shown.
- [ ] The product is **not** in the checklist → the row is **grey**.
- [ ] Tap the row → it shimmers (loading) → then it turns **green**.
- [ ] Close the sheet and open it again → the row is still **green**.
- [ ] Go out of the product and come back → the row is still **green**.
- [ ] Add 3 different products → all 3 show green on their own pages.

## 2. Remove from the product page

- [ ] Open a product that is already in the checklist → the row opens **green**.
- [ ] Tap the row → it shimmers → then it turns **grey**.
- [ ] Open the product again → the row is still **grey**.

## 3. Double tap and fast tapping

- [ ] Tap the row fast many times → only **one** request runs, no flicker
      between green and grey.
- [ ] While the row is shimmering → tapping does **nothing** (the row is locked).
- [ ] The product ends in the correct state (compare with the list page).

## 4. Open the list

- [ ] Profile → the row **"My checklist"** → it shimmers → the page opens.
- [ ] The page shows the products: image + name + **X** button.
- [ ] The products are the same ones you added.
- [ ] Tap a product image → the product details page opens for the **right** product.
- [ ] Press back → you return to the checklist page with the same data.

## 5. Empty list

- [ ] New account with nothing added → the page shows **"checklist is empty"**.
- [ ] Remove every product → the page shows the empty message, no crash.

## 6. Pagination (needs more than 10 products)

- [ ] With 10 products or less → **no** Previous / Next bar is shown.
- [ ] With more than 10 → the bar shows `1 / 2` (or more).
- [ ] **Next** → page 2 loads, the counter becomes `2 / 2`.
- [ ] **Previous** → page 1 comes back.
- [ ] On the first page → **Previous** is faded and does nothing.
- [ ] On the last page → **Next** is faded and does nothing.
- [ ] Tap Next many times fast → no wrong page and no double load.

## 7. Delete from the list

- [ ] Tap **X** on a product → the row shimmers → the product disappears.
- [ ] The rest of the list stays correct after the delete.
- [ ] Open that product again → the "..." row is **grey**.
- [ ] Delete **the last product on page 2** → the app goes back to page 1 by
      itself. You must **never** be stuck on an empty page with no buttons.
- [ ] Delete many products fast, one after the other → the list stays correct.

## 8. Two devices / two places at the same time

- [ ] Add a product on device A → open the same product on device B → it is green.
- [ ] Delete a product from the list page on device A, then on device B open the
      checklist page again → the product is gone.
- [ ] Delete a product from the product page, then open the list → it is not there.

## 9. Network and errors

- [ ] Internet off → tap the "Add to my checklist" row → an error message is
      shown and the row keeps its old colour (it does **not** turn green).
- [ ] Internet off → Profile → "My checklist" → an error message, the page does
      **not** open empty.
- [ ] Internet off → tap **X** in the list → an error message, the product stays.
- [ ] Internet back on → try again → everything works.
- [ ] Slow network → the shimmer stays until the answer comes, no freeze.

## 10. Account and restart

- [ ] Kill the app and reopen → the checklist is loaded again from the server
      and is correct (no old or wrong green row).
- [ ] Logout then login with **another** account → the checklist is the new
      account's one, not the old one.
- [ ] Login again with the first account → the old checklist comes back.

## 11. Language and layout

- [ ] Arabic / Kurdish: the row and the page are mirrored correctly (RTL).
- [ ] A long product name is cut with "..." on 2 lines, it does not break the row.
- [ ] Previous / Next are in the correct place in RTL.
- [ ] Switch the language while the page is open → the text changes correctly.

---

## How to report a bug

1. Device + OS version
2. App language
3. Account / phone number used
4. Product name or id
5. Steps (1, 2, 3 …)
6. What happened vs what you expected
7. Screenshot or screen recording
8. Time of the test (to find it in the logs)

Mark the level: **Blocker** / **Major** / **Minor**.
