# Trydos — Chat Test Scenarios

Scope: the **Chat** tab only. Calls and Stories tabs are separate.
Test on 2 real devices (A and B), 2 different accounts.
Repeat the key flows in **Arabic (RTL)** and **English (LTR)**.

---

## 1. Chat list

- [ ] Chat list loads and shows last message + time + unread badge.
- [ ] Scroll to the bottom → older chats load (pagination).
- [ ] Search field finds a chat by name (full search is in section 14).
- [ ] Swipe a chat row → Archive / Un-archive (section 11).
- [ ] Swipe a chat row → Mute / Un-mute.
- [ ] Swipe a chat row → Pin / Un-pin (pinned stays on top).
- [ ] Swipe a chat row → Mark as unread (section 12).
- [ ] Swipe a chat row → Delete chat.
- [ ] Counter on the Chat tab icon is correct (it counts **chats**, not
      messages — section 12).

## 2. Start a new chat

- [ ] Open Contacts → the list of contacts loads.
- [ ] Search for a contact by name / number.
- [ ] Open a contact and send the first message → a new chat is created.
- [ ] Open a chat from a product page / order page → it opens the right chat.

## 3. Send messages

- [ ] Text message.
- [ ] Emoji and long text.
- [ ] Photo from **gallery**.
- [ ] Photo from **camera**.
- [ ] Video (check the size and length limit messages).
- [ ] Document / file.
- [ ] Voice message: record, listen before sending, cancel, send.
- [ ] Share a **product** into a chat.
- [ ] Reply to a message (text, image, voice, product).
- [ ] Forward a message to another chat.
- [ ] Copy a text message.
- [ ] Edit a sent message (full checks in section 9).
- [ ] Delete a message → **Only me**.
- [ ] Delete a message → **Everyone** (B sees "This message has been deleted").

## 4. Receive and real time

- [ ] A sends → B receives it **without** re-opening the app.
- [ ] Typing indicator appears on the other side.
- [ ] Online / last seen status is shown.
- [ ] Message status: sent → delivered → read.
- [ ] Open a chat → unread count resets to 0 for that chat.
- [ ] Push notification arrives when the app is in background and killed.
- [ ] Tapping the notification opens the correct chat.
- [ ] A muted chat gives **no** notification sound.

## 5. Media

- [ ] Open an image full screen, zoom.
- [ ] Play a video inside the chat.
- [ ] Play a voice message (waves + duration).
- [ ] Open a document.
- [ ] Save an image / video to the gallery.
- [ ] Profile → **Media & Files** shows all shared media of that chat.

## 6. Contact profile (inside a chat)

- [ ] Open the contact profile from the chat header.
- [ ] Search inside the chat for a text → results are correct and jump to the message.
- [ ] Voice call / video call buttons from the chat.
- [ ] Block the user → then Un-block.
- [ ] Delete the whole chat from the profile.

## 7. Network and errors

- [ ] Turn the internet off → send a message → it shows as failed.
- [ ] Turn the internet back on → resend the failed message.
- [ ] Kill the app and reopen → messages are still there, nothing is lost.
- [ ] Weak network → no duplicated messages.

## 8. Language and layout

- [ ] Arabic / Kurdish: the whole chat mirrors correctly (RTL), no cut text.
- [ ] English / Turkish: layout is correct (LTR).
- [ ] Switch the language while the app is open → chat still looks correct.

---

# New features

The sections below cover what was added recently. The long-press strip on a
message holds most of them: Forward, Copy, **Tag**, Delete, **Edit**,
**Remind**. Open it in two ways every time — **tap** the icon, and **press and
drag** across the strip then release. The two ways run different code, so a
button can work one way and fail the other.

## 9. Edit a message

- [ ] Long-press your own text message → Edit opens a dialog with the old text.
- [ ] The **Save** button is disabled until you change the text.
- [ ] Change the text, then put the old text back → Save is disabled again.
- [ ] Press Save → the button shows a shimmer while it waits.
- [ ] On success → the dialog closes and the chat shows the new text.
- [ ] A small **pencil** icon appears next to the time of the edited message.
- [ ] Edit is **not** offered on a photo, video, file, voice or product message.
- [ ] Edit is **not** offered on a message you received.
- [ ] Send a message and edit it before the server confirms it → nothing breaks.
- [ ] No internet → press Save → a clear error, the dialog stays open.

**On device B (the other side)**

- [ ] B sees the new text without re-opening the app, and sees the pencil icon.
- [ ] B gets **no** sound and **no** banner for the edit — it is silent.
- [ ] Edit a message with a lot of content (long text, many members) → B still
      shows it right. The server sends a short payload in this case and the app
      fetches the message itself.
- [ ] B has the app killed → open the app → the edited text is correct.

## 10. Message reminders

- [ ] Long-press any message → Remind opens the reminder dialog.
- [ ] Quick options: after 20 minutes, after an hour, after 3 hours, tomorrow
      morning.
- [ ] Press a quick option → a shimmer replaces it until the server answers.
- [ ] After success the dialog **stays open** and shows the chosen time.
- [ ] Pick a custom date and time → it is saved. Numbers in the picker are not
      cut.
- [ ] A past time is refused.
- [ ] A **bell** icon appears next to the time of that message.
- [ ] Change the time of an existing reminder → the bell stays, the time changes.
- [ ] Cancel the reminder → a small round loader replaces the cancel button.
- [ ] After cancel → the bell disappears and the row leaves the reminders list.
- [ ] Reminders work on every message type, sent and received.

**Reminders list**

- [ ] The chat list shows a **Reminders** row with the number of reminders.
- [ ] Tap it → a separate page replaces the chat list (not a drop-down).
- [ ] The icon and the design match the chat list rows.
- [ ] Tap a reminder → it opens the right chat at the right message.
- [ ] The count is correct after you add and cancel reminders.

**Notification**

- [ ] Set a reminder for 2 minutes later, keep the app in the **foreground** →
      the notification appears at the right time.
- [ ] Repeat with the app in the **background**.
- [ ] Repeat with the app **killed**.
- [ ] Tap the notification → the right chat opens.
- [ ] The reminder reaches **all** your devices if you are logged in on two.

## 11. Archive

- [ ] Archive a chat → it leaves the main list at once, with no need to scroll
      or tap the screen first.
- [ ] An **Archived** row appears with the number of archived chats.
- [ ] Tap it → a separate page replaces the chat list.
- [ ] Un-archive from inside that page → the chat returns to the main list.
- [ ] Un-archive the last archived chat → the Archived row disappears and the
      page closes itself.
- [ ] Archiving is personal: B does **not** see any change.

**Archived chats still work**

- [ ] A sends to an archived chat → B still gets the push notification.
- [ ] The unread count shows next to the archived chat name.
- [ ] The chat icon count on the main page **includes** archived chats.
- [ ] Open an archived chat → it reads and sends normally.
- [ ] Search for an archived chat by name → it is **found** (it is hidden from
      the list, not from search).

## 12. Mark as unread and the unread counter

- [ ] Open a chat (unread becomes 0) → go back → Mark as unread → the badge
      shows again at once.
- [ ] The Chat tab icon count goes up at the same moment, with no refresh.
- [ ] Open that chat again → it becomes read everywhere at once.

**The counter counts chats, not messages**

- [ ] Receive **two** messages from the same chat → the Chat tab icon shows
      **1**, not 2.
- [ ] Receive messages from **two different** chats → it shows **2**.
- [ ] Open one of them → it goes down to 1.
- [ ] The badge on the chat row itself still shows the number of **messages**
      in that chat — this one did not change.
- [ ] B reads your message → **your** counter does not change (it is not your
      unread).
- [ ] Read a chat from another device → your counter goes down by one.
- [ ] Repeat the steps above many times → the counter never shows a wrong number
      and never disappears. If the badge is gone while a chat is unread, report
      it with the time of the test.
- [ ] Kill the app and reopen → the counter is still correct.

## 13. Message tags

- [ ] Long-press any message → Tag opens the **Message tag** dialog.
- [ ] It works on messages you sent **and** on messages you received.
- [ ] It works on every type: text, photo, video, file, voice, product, reply.
- [ ] The **Add** button is off while the field is empty.
- [ ] Type a tag → Add turns on → press it → a small loader replaces the word
      Add until the server answers.
- [ ] After success the tag appears in the list with the number **1** and a blue
      arrow at the end of the row.
- [ ] Add a second tag → both rows show.
- [ ] The dialog **stays open** after each change. It closes only with Close.
- [ ] Press the blue arrow → a small loader replaces it → the tag is removed.
- [ ] Arabic, English and emoji all work as a tag.
- [ ] A very long tag is cut at 30 letters and is accepted.

**Suggestions**

- [ ] Open the tag dialog on **another message in the same chat** → the tags you
      used before are listed, with no number and no arrow.
- [ ] Tap a suggestion → it is applied to this message too.
- [ ] Open the tag dialog in a **different chat** → suggestions from the first
      chat do **not** show (suggestions come from the open chat only).

**The icon on the message**

- [ ] A tagged message shows a small tag icon next to the time.
- [ ] Tap it → a dark panel lists the tag names.
- [ ] Tap anywhere else → the panel closes.
- [ ] Check the icon on all types: text, photo, video, file, voice, product and
      a reply message.
- [ ] Remove all tags → the icon disappears.

**On device B**

- [ ] B sees the tag icon appear without re-opening the app, with no sound.
- [ ] **Important:** after A adds a tag, check that B's **own** tags on that
      message are still there. If they disappear, report it at once.

## 14. Search

**In the chat list**

- [ ] Search by chat name → the chat is found.
- [ ] Search by a name that is **not** in your chats but **is** in your contacts
      → the contact is listed under the chats.
- [ ] A contact who does **not** have the app shows an **Invite** button.
- [ ] Press Invite → the share sheet opens with a copy-link option.
- [ ] Tap a found contact who has a chat → the chat opens.
- [ ] Tap a found contact with **no** chat yet → nothing crashes.
- [ ] Clear the field → contacts disappear and the full chat list returns.
- [ ] Search by number saved as `0999…` when the server has `+963999…` → found.
- [ ] Search the same number the other way round → also found.
- [ ] Search `احمد` → finds `أحمد`. Search `فاطمه` → finds `فاطمة`.
- [ ] **While a search is on the screen, receive a new message** → the results
      stay. They must not jump back to the full list.
- [ ] Leave the Chat tab and come back → the field is empty and the full list
      shows.

**Inside a chat**

- [ ] Open search inside a chat → a **magnifier** icon shows next to the word
      Search.
- [ ] Type fast → the app waits a moment before it searches (no request per
      letter).
- [ ] Results are correct and the up / down arrows jump between them.
- [ ] Press **✕** → the search closes and the chat returns to normal.
- [ ] ✕ works while results are still loading.

## 15. Contacts

- [ ] Open the Contacts page → names show as they are saved in **your phone
      book**, not the name the person chose in the app.
- [ ] A contact with no name in the phone book still shows (number or Unknown).
- [ ] Search in this page by the phone-book name → found.
- [ ] Deny the contacts permission → the page still opens and shows app names.
- [ ] Names inside **chats** did **not** change — only the Contacts page.
- [ ] Log in with the same account on a **second phone** → the contacts of the
      second phone show, not the ones from the first phone.
- [ ] No contact shows with a country that is not yours.
- [ ] Contacts page → Invite → the sheet opens.
- [ ] Press **Copy invite link** → a message says the link was copied, and the
      link pastes correctly.

## 16. Files and network messages

- [ ] Try to send an **AVI** video → the app stops and says the format is not
      supported, try another one.
- [ ] The same message shows for a file named `.avi` and `.AVI`.
- [ ] The message is translated in all four languages.
- [ ] Turn the internet off → send a message → the same "no internet" message
      that the app shows elsewhere appears.
- [ ] The message is translated in all four languages.
- [ ] Turn the internet back on → the message sends.

---

## How to report a bug

For each bug write:

1. Device + OS version
2. App language
3. Steps (1, 2, 3 …)
4. What happened vs what you expected
5. Screenshot or screen recording
6. Time of the test (to find it in the logs)
