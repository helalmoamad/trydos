# Trydos — Story Test Scenarios

Scope: **Stories** only. Chat is in
[chat-test-scenarios.md](chat-test-scenarios.md), the rest of the app is in
[app-test-checklist.md](app-test-checklist.md).

**Before you start**

- Use **2 real devices** (A and B) with **2 different accounts**.
- Test on Android **and** iOS. Video behaves differently on each.
- Repeat the main flows in **Arabic (RTL)** and **English (LTR)**.
- Stories use their **own server and their own token**, separate from chat. So
  a story can fail while chat still works. If stories stop loading but chat is
  fine, say so in the bug — it points at the stories token.
- Tick the box only when the step works. If it fails, write a bug (format at the
  end).

---

## 1. Stories list

- [ ] Open the Stories area → the list loads with no crash.
- [ ] The first card is **My stories** with "Click to add story".
- [ ] Your photo shows on the card. With no photo, the first letters of your
      name show instead.
- [ ] Other users' stories show after yours.
- [ ] A user with a story you have **not** seen → the ring around the card is
      **green**.
- [ ] After you watch all of that user's stories → the ring turns **grey**.
- [ ] A user with more than one story → the ring is split into parts, one per
      story.
- [ ] Pull to refresh (or re-open the tab) → the list is up to date.
- [ ] A user with no stories does not show in the list.
- [ ] No internet → a clear message with **Try again**, not an empty screen.
- [ ] Press Try again after the internet is back → the list loads.

## 2. Add a story — photo

- [ ] Tap **My stories** → the camera screen opens.
- [ ] Permission is asked the first time. Deny it → a clear message, no crash.
- [ ] Take a photo → the preview shows.
- [ ] Switch between front and back camera.
- [ ] Flash on / off.
- [ ] Pick a photo from the **gallery** instead.
- [ ] **Crop** the photo → the crop is kept in the result.
- [ ] Send → the story uploads and appears in **My stories**.
- [ ] A progress or loading state shows while it uploads — the screen is not
      frozen with no sign.
- [ ] Open your new story → the photo is not stretched and not cut.
- [ ] Send a very tall photo and a very wide photo → both fit the screen.

## 3. Add a story — video

- [ ] Record a video from the camera → the preview plays.
- [ ] Pick a video from the **gallery**.
- [ ] Record for **more than 60 seconds** → the app refuses it and shows the
      video length message. The story is **not** sent.
- [ ] Record a short video (5–10 s) → it sends.
- [ ] Open it → it plays with sound, and the progress bar on top matches the
      video length.
- [ ] A video that does not open must not freeze the viewer — check that the
      story moves on or shows an error.

## 4. Add a link to the story

- [ ] On the camera screen, open **Add link to story**.
- [ ] Type a normal link → Send works.
- [ ] Open the story → the link area shows and opens the right page.
- [ ] Type a link that contains the word **coupon** → a warning shows and the
      story is **not** sent.
- [ ] Send a story with **no** link → nothing about links shows in the viewer.

## 5. Watching stories

- [ ] Tap a user's card → the story opens full screen.
- [ ] The progress bar at the top moves and the story ends by itself.
- [ ] The owner's name, photo and the story **time** show at the top.
- [ ] Tap the **right** side → next story.
- [ ] Tap the **left** side → previous story.
- [ ] Tap next on the last story of a user → it moves to the **next user**.
- [ ] Tap previous on the first story → it goes back to the previous user.
- [ ] After the last story of the last user → the viewer closes.
- [ ] **Press and hold** → the story pauses, and a **video pauses too**.
- [ ] Let go → it continues from where it stopped, it does not restart.
- [ ] Swipe between users (left / right) → the right user opens.
- [ ] Close the viewer and open it again → it starts from the first **unseen**
      story, not from the beginning.
- [ ] Watch a story → go back → the ring for that user turns grey.
- [ ] Watch on device A → the story counts as seen for A only. B still sees it
      as new.

## 6. Your own story

- [ ] Open your own story → a **delete** icon shows at the top.
- [ ] The **report** (flag) icon does **not** show on your own story.
- [ ] Press delete → a loader replaces the icon until the server answers.
- [ ] After success → the story is removed and the viewer moves to the next one
      or closes.
- [ ] Re-open the list → the deleted story is gone and does not come back.
- [ ] Delete your only story → the My stories card goes back to "Click to add
      story".
- [ ] The viewers count of your story goes up after B watches it.

## 7. Report a story

- [ ] Open **another user's** story → the **flag** icon shows.
- [ ] The flag does **not** show if your phone number is not verified.
- [ ] Press it → the story pauses and the report sheet opens.
- [ ] All reasons show: inappropriate content, harassment, spam, intellectual
      property, violence, other.
- [ ] Pick a reason and send → a success message shows.
- [ ] The reported story is removed from the screen and the viewer moves to the
      next story, or closes if there is none.
- [ ] Write something in the **details** field (optional) and send → it works.
- [ ] Send with no details → it also works.
- [ ] Press **Cancel** → the sheet closes and the story continues.
- [ ] No internet → send a report → a clear failure message, the app does not
      hang.

## 8. Product stories

- [ ] Open a product that has stories → the stories show on the product page.
- [ ] Tap one → it opens full screen like a normal story.
- [ ] The **View product** button shows → tap it → the right product opens.
- [ ] **Press here for more** opens what it should.
- [ ] A product with no stories → no empty row and no broken space.

## 9. Seller stories (shop dashboard)

- [ ] Dashboard → Stories → the shop stories load.
- [ ] **Add story** → photo → it is added to this shop.
- [ ] Add story → video → it is added.
- [ ] Link a **product** to the story → the product shows on the story.
- [ ] Delete a shop story → it is removed after a confirm step.
- [ ] A shop with no stories shows "No stories yet" with an add button.
- [ ] Loading fails → "Failed to load stories" with **Try again**.
- [ ] Switch to a **different shop** → you see that shop's stories, not the
      first shop's.

## 10. Stories session and token

Stories have their own login and their own refresh token, and that token can be
used **once**. These steps catch the problems that come from it.

- [ ] Open the app after a long time (a day or more) → stories still load
      without a new login.
- [ ] Open the stories list and the product stories at the **same moment**
      (quickly one after the other) → both load. Neither shows a login error.
- [ ] Log out and log in again → stories load for the new account, and the old
      account's stories are gone.
- [ ] Log in on a second device with the same account → stories work on both.
- [ ] Chat works but stories do not (or the opposite) → report it, and say
      which one failed.
- [ ] No "your session has expired" message appears while you are just browsing
      stories.

## 11. Network and errors

- [ ] Turn the internet off → open the stories list → a clear message with
      **Try again**.
- [ ] Turn the internet off **while a story is uploading** → a failure message,
      and the app does not stay stuck on loading.
- [ ] Turn the internet back on → send the story again → it works.
- [ ] Weak network → the story is **not** uploaded twice (check the list for a
      duplicate).
- [ ] Open a story while the internet is slow → a loader shows, then the story
      or a clear error.
- [ ] Kill the app while a story is uploading → re-open → no half story and no
      crash.
- [ ] Open the app from a push notification straight into a story → the right
      story opens.

## 12. Language and layout

- [ ] Arabic / Kurdish: the viewer mirrors correctly (RTL). The progress bar,
      the name and the icons are in the right place.
- [ ] In Arabic, check that **tap right / tap left** still move the way the
      design wants, and are not reversed by mistake.
- [ ] English / Turkish: layout is correct (LTR).
- [ ] Long names do not break the top bar — they are cut with "…".
- [ ] Change the language while the app is open → stories still look correct.
- [ ] All messages (video too long, coupon link, report sent, report failed) are
      translated in all four languages. No English text in the Arabic app.

## 13. Phone and performance

- [ ] Watch 10 stories one after the other → the app does not slow down.
- [ ] Videos do not keep playing sound after you close the viewer.
- [ ] Open and close the viewer 10 times → no crash and no memory warning.
- [ ] Get a phone call while a story video plays → the video pauses, and the
      screen is correct after the call.
- [ ] Lock the phone during a story → unlock → the app is in a correct state.
- [ ] Test on a **low-end phone**, not only on a fast one.

---

## How to report a bug

For each bug write:

1. Device + OS version
2. App language
3. Steps (1, 2, 3 …)
4. What happened vs what you expected
5. Screenshot or screen recording
6. Time of the test (to find it in the logs)
7. Whether **chat** was working at the same moment (stories use a different
   server, so this tells us where the problem is)
