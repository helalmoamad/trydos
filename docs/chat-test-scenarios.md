# Trydos — Chat Test Scenarios

Scope: the **Chat** tab only. Calls and Stories tabs are separate.
Test on 2 real devices (A and B), 2 different accounts.
Repeat the key flows in **Arabic (RTL)** and **English (LTR)**.

---

## 1. Chat list

- [ ] Chat list loads and shows last message + time + unread badge.
- [ ] Scroll to the bottom → older chats load (pagination).
- [ ] Search field finds a chat by name.
- [ ] Swipe a chat row → Archive / Un-archive.
- [ ] Swipe a chat row → Mute / Un-mute.
- [ ] Swipe a chat row → Pin / Un-pin (pinned stays on top).
- [ ] Swipe a chat row → Delete chat.
- [ ] Unread counter on the Chat tab icon is correct.

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
- [ ] Edit a sent message.
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

## How to report a bug

For each bug write:

1. Device + OS version
2. App language
3. Steps (1, 2, 3 …)
4. What happened vs what you expected
5. Screenshot or screen recording
6. Time of the test (to find it in the logs)
