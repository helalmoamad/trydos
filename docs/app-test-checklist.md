# Trydos — App Test Checklist

Full app checklist. For the Chat tab use the separate file
[chat-test-scenarios.md](chat-test-scenarios.md).

**Before you start**

- Use a **real device** (not only an emulator), Android and iOS.
- Test with a **new account** and with an **old account** that already has data.
- Repeat the main flows in **Arabic (RTL)** and **English (LTR)**.
- Tick the box only when the step works. If it fails, write a bug (format at the end).

---

## 1. First launch

- [ ] Fresh install → the app opens with no crash.
- [ ] Country selection screen shows available and coming-soon countries.
- [ ] Choose a country and save → the app continues.
- [ ] Ask for permissions (camera, microphone, notifications, contacts) at the right time.
- [ ] Deny a permission → the app still works and shows a clear message.
- [ ] Close the app and reopen → it does not ask for the country again.

## 2. Login and register

- [ ] Login with phone number → code arrives → login works.
- [ ] Wrong code → clear error message.
- [ ] New number → register flow → profile completed.
- [ ] Number already registered → the right screen is shown.
- [ ] **QR login**: scan the QR from another device → the account is imported.
- [ ] Invalid QR code → clear error message.
- [ ] "Skip for now" → the app opens in guest mode.
- [ ] Guest tries to buy / open cart → it asks to login first.
- [ ] Logout → the session is cleared, no old data is shown.
- [ ] Login again → the data comes back (orders, chats, cart).

## 3. Home

- [ ] Home loads: categories, featured products, flash deals, recommended products.
- [ ] Stories row at the top loads.
- [ ] Pull to refresh works.
- [ ] Scroll down → more products load (pagination).
- [ ] "See all" opens the full list page for each section.
- [ ] Open a category → the products of that category are shown.
- [ ] Flash deal timer counts down correctly.
- [ ] Weak or no internet → an error screen with a retry button, not a crash.

## 4. Search

- [ ] Search for a product by name → correct results.
- [ ] Search in Arabic and in English.
- [ ] No result → a clear empty message.
- [ ] Filters and sorting work.
- [ ] Recent searches are saved.

## 5. Product details

- [ ] Open a product → images, price, discount, description, seller.
- [ ] Swipe the images and open them full screen.
- [ ] Choose color / size → the price and stock update.
- [ ] Out of stock product → the buy button is disabled with a clear message.
- [ ] Add to cart → the cart counter goes up.
- [ ] Share the product to a chat.
- [ ] Open a chat with the seller from the product page.
- [ ] Compare products.

## 6. Cart and checkout

- [ ] Cart shows the products, quantity and total.
- [ ] Change the quantity → the total updates.
- [ ] Delete a product from the cart.
- [ ] Unavailable product in the cart → the app asks to delete it before ordering.
- [ ] Empty cart → a clear empty message.
- [ ] Add a new shipping address (name, phone, district, map location).
- [ ] Choose an address from the list and change it.
- [ ] Delete an address.
- [ ] Address outside the covered area → a clear message.
- [ ] Apply a valid discount coupon → the total goes down.
- [ ] Invalid coupon → a clear error message.
- [ ] Shipping cost and expected delivery date are shown.
- [ ] Agree to the terms before placing the order.

## 7. Payment

Test every method that is enabled for your account:

- [ ] Cash on delivery.
- [ ] Trydos wallet → the balance goes down by the right amount.
- [ ] Wallet with a balance that is too low → a clear message, no order created.
- [ ] **RDB payment (new)** → the payment page opens, the QR / short code works.
- [ ] RDB: leave the page in the middle → the pending payment banner is shown.
- [ ] RDB: come back and finish the payment → the order is completed.
- [ ] Card.
- [ ] Crypto.
- [ ] Cancel the payment → no order is created and no money is taken.
- [ ] After a successful order → the success screen and the invoice are correct.
- [ ] The order total on the invoice is exactly the same as in the cart.

## 8. Orders

- [ ] My orders list loads.
- [ ] Open an order → details, products, total, status.
- [ ] Order status changes are shown correctly.
- [ ] Cancel an order (if allowed).
- [ ] Hide an order → it moves to hidden orders.
- [ ] Hidden orders page → show the order again.
- [ ] No orders → a clear empty message.
- [ ] Open the invoice.

## 9. Wallet

- [ ] Create a wallet for a new account.
- [ ] Login to the wallet.
- [ ] The balance is correct and in the right currency.
- [ ] Change the currency → the numbers change correctly.
- [ ] The wallet history matches the orders.

## 10. Profile and settings

- [ ] Open my profile → name, photo, verified mark.
- [ ] Edit the profile and the photo → the change is saved.
- [ ] Change the language (Arabic, English, Kurdish, Turkish) → the whole app changes.
- [ ] Share my account with QR.
- [ ] Share the app.
- [ ] About us, terms and conditions, legal information open.
- [ ] Become a seller → the form and the map location work.
- [ ] Go to the seller dashboard.

## 11. Seller dashboard

- [ ] Select a shop.
- [ ] Orders list of the shop loads.
- [ ] Open an order → details and status change.

## 12. Calls

- [ ] Voice call from a chat → the other side rings.
- [ ] Video call from a chat → video and sound work on both sides.
- [ ] Answer a call when the app is in **background**.
- [ ] Answer a call when the app is **killed**.
- [ ] Reject a call → the other side sees it.
- [ ] Missed call → it is shown in the Calls tab with the right counter.
- [ ] Mute, speaker and camera switch work during the call.
- [ ] End the call → the call duration is saved in the chat.
- [ ] Call while the internet is weak → a clear message, no freeze.

## 13. Stories

- [ ] The stories list loads.
- [ ] Add a story (photo and video).
- [ ] Open a story → it plays and moves to the next one.
- [ ] Hold to pause, swipe to skip.
- [ ] Viewers list of my story.
- [ ] Delete my story.

## 14. Notifications

- [ ] Notification arrives when the app is in background.
- [ ] Notification arrives when the app is killed.
- [ ] Tap a notification → it opens the right screen (chat, order, call).
- [ ] The notifications page shows the list.
- [ ] Order status change gives a notification.

## 15. Language and layout

- [ ] Arabic and Kurdish: the whole app mirrors correctly (RTL).
- [ ] No cut text and no text outside the screen in any language.
- [ ] Numbers, prices and dates are correct in every language.
- [ ] Small screen and big screen both look correct.

## 16. Stability

- [ ] Use the app for 15 minutes without a crash.
- [ ] Turn the internet off and on many times → the app recovers.
- [ ] Move between the tabs fast → no freeze.
- [ ] The app goes to background and comes back → the state is kept.
- [ ] Battery and heat are normal after a call or a long session.

---

## How to report a bug

For each bug write:

1. Device + OS version
2. App language
3. Account / phone number used
4. Steps (1, 2, 3 …)
5. What happened vs what you expected
6. Screenshot or screen recording
7. Time of the test (to find it in the logs)

Mark the level: **Blocker** (cannot continue) / **Major** (important) / **Minor** (small).
