---
ticket: dashboard-gallery-page
stage: spec
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-22
links:
  clickup:
  github:
---

# Spec — dashboard-gallery-page

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

Dashboard Gallery — upload images and see what was uploaded.

## Business Goal

The dashboard already offers a "Gallery" entry, but opening it shows an empty
placeholder. A seller who wants to prepare images for products has no place to do it
inside the app. This ticket turns that dead entry into a working screen: pick images,
send them to the media server, and see them right after. It removes a visible broken
promise in the dashboard and gives sellers a single place to upload product images.

## User Story

> As a seller using the dashboard, I want to open Gallery and upload images from my
> phone and then see them, so that I can prepare my product images without leaving the
> app.

## Functional Requirements

- **FR-1 — The gallery entry opens a working screen.** Choosing "Gallery" in the
  dashboard opens a screen with two areas: an upload area at the top and an uploaded
  images area below it. The current placeholder text is gone.
- **FR-2 — The upload area matches the reference design.** It shows a box with a dashed
  border and a light fill, holding: an upload icon, the line "Drop images here", a
  smaller line "or choose files / folder", and two buttons side by side — "Select Files"
  (filled, dark) and "Select Folder" (outlined, blue).
- **FR-3 — "Drop images here" is text only.** There is no drag-and-drop on a phone. The
  line is shown because the design shows it; nothing is dropped and nothing responds to
  a drag.
- **FR-4 — "Select Files" picks images.** It opens the device file picker limited to
  image types. Documents and other file types cannot be chosen.
- **FR-5 — "Select Folder" picks many images at once.** It opens a multi-selection
  image picker so the user can choose more than one image in one go. It does **not** open
  a real device folder.
- **FR-6 — Picked images are uploaded to the media server.** Every picked image is sent
  to the existing gated media-server upload flow. The user does not have to press a
  separate "upload" button.
- **FR-7 — Each file shows its own progress.** While a batch is uploading, every file
  shows its own progress state, not one shared spinner for the whole batch.
- **FR-8 — A failed upload can be retried.** A file that fails stays visible, clearly
  marked as failed, with a Retry action. Retry starts a fresh upload for that file alone.
- **FR-9 — Uploaded images are shown in a grid.** The images area shows three square
  thumbnails per row with rounded corners and a small gap.
- **FR-10 — Tapping a thumbnail opens a full preview.** The image opens full screen and
  can be closed to return to the gallery.
- **FR-11 — The empty state matches the design.** When there are no images, the area
  shows a light circle holding a picture icon, the line "No images found", and the
  smaller line "Uploaded images will appear here."
- **FR-12 — The list survives leaving the screen.** Closing the gallery and opening it
  again while the app is still running shows the images uploaded earlier in the same app
  run. After the app is fully closed and started again, the list is empty.
- **FR-13 — The user is told the list is temporary.** A short note in the images area
  explains that it shows only images uploaded during the current app run.
- **FR-14 — All text is translated.** Every text on the screen is shown in the user's
  language for all four supported languages (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`).

## Non-Functional Requirements

- **NFR-1 — Correct in right-to-left.** The screen is laid out correctly in Arabic and
  Kurdish: the two buttons, the grid, the icons and the text all read in the right
  direction and nothing is mirrored wrongly.
- **NFR-2 — No overflow.** The upload box and its two buttons fit on a narrow phone and
  do not overflow when translated words are longer than the English ones.
- **NFR-3 — The screen stays responsive.** Picking and uploading several images does not
  freeze the interface; the user can still scroll and leave the screen.
- **NFR-4 — Nothing else in the dashboard changes.** The other dashboard entries
  (products, boutiques, orders, permissions, users, stories, excel, shop information,
  locations, comments) behave exactly as before.
- **NFR-5 — No new permission prompts beyond what picking media needs.** The screen asks
  only for the media permission it needs, and refusing it is handled with a clear message
  instead of a crash.

## Constraints

- **C-1 — Reuse the existing gated upload flow.** Uploads use the media server flow the
  app already has (short-lived, single-use upload ticket, then the upload). A retry needs
  a new ticket; the old one cannot be reused.
- **C-2 — There is no API that lists previously uploaded images.** Nothing may be
  invented for it. The images area shows only what this app run uploaded.
- **C-3 — No backend change is part of this ticket.** No new endpoint may be requested
  or assumed.
- **C-4 — Protected runtime.** Adding translations touches protected runtime
  configuration, so it must be listed in the approved plan before it is done. Anything
  else the approach needs from protected runtime must also be listed there first.
- **C-5 — The reference design is the source of truth for the empty screen.** Where the
  design and this spec disagree about the empty screen, the design wins.
- **C-6 — Smallest change.** The gallery must be added without restructuring the
  dashboard or changing how its other entries open.

## Edge Cases

- **E-1** — The user opens the picker and cancels: the screen is unchanged and no error
  is shown.
- **E-2** — The user refuses the media permission: a clear message is shown, and the app
  does not crash.
- **E-3** — The user picks many images at once (for example 20): all of them upload, each
  with its own progress, and the interface stays usable.
- **E-4** — The network drops in the middle of a batch: the finished files stay in the
  grid, the failed ones are marked failed and can be retried.
- **E-5** — The upload ticket expires before the upload finishes: this is treated as a
  normal failure with a working Retry.
- **E-6** — The user leaves the screen while uploads are still running: leaving does not
  crash the app.
- **E-7** — The user picks the same image twice: it is uploaded and shown as its own
  entry; removing duplicates is not required.
- **E-8** — The device returns an image the server rejects (too large or wrong type):
  the file is marked failed with a message, and the rest of the batch continues.
- **E-9** — A very long translated word in Arabic, Kurdish or Turkish still fits inside
  the two buttons.

## Research Questions Resolved

> Required (SP-9). One row per `OQ-n` in `research.md` — none may be skipped.
> **Answered:** write the answer and where it lands (a requirement, an `AC-n`, a
> constraint, or Out of Scope). **Deferred:** the answer needs the approach, so
> `/plan` answers it (PL-12) — repeat it under Open Questions with the same ID.

| OQ | Answer | Lands in |
|------|--------|----------|
| OQ-1 | **Deferred to `/plan`.** At spec level the requirement is only that picking many images uploads all of them (FR-5, FR-6). Whether that is done with the bulk upload call or by repeating the single-file call is an approach decision, and it decides whether protected runtime is touched. | Open Questions (deferred); requirement is FR-5 / FR-6 |
| OQ-2 | **Deferred to `/plan`.** The spec only requires that more than one image can be picked in one action (FR-5) and that existing screens keep working (NFR-4). How the shared picker is extended or avoided is an approach decision. | Open Questions (deferred); requirement is FR-5 / NFR-4 |
| OQ-3 | **Deferred to `/plan`,** with a fixed requirement it must satisfy: the uploaded list must survive closing and reopening the screen within one app run, and must be empty after a restart (FR-12). The plan decides where that state lives and must avoid protected runtime unless it lists it. | Open Questions (deferred); requirement is FR-12, bounded by C-4 |
| OQ-4 | **Deferred to `/plan`.** Where the new screen's code is declared has no user-visible effect, so it is not a spec decision. | Open Questions (deferred) |
| OQ-5 | **Answered: in scope.** All text on the screen is translated into the four supported languages, and the screen is correct in right-to-left. This touches protected runtime configuration, so the plan must list it. | FR-14, NFR-1, C-4, AC-16, AC-17 |
| OQ-6 | **Answered.** The images area is a grid of three square thumbnails per row with rounded corners and a small gap. Tapping a thumbnail opens the image full screen; it can be closed to come back. Deleting an image is **not** part of this ticket. | FR-9, FR-10, AC-11, AC-12; deletion is Out of Scope |
| OQ-7 | **Answered.** Only image types may be picked, by both buttons. No document or other file type can enter the gallery. No app-side size limit is set in this ticket; a file the server rejects is treated as a failed upload. | FR-4, E-8, AC-5 |
| OQ-8 | **Answered.** Every file shows its own progress. A failed file stays visible, marked as failed, with a Retry action that starts a fresh upload for that file (a new ticket is needed because the ticket is single-use). | FR-7, FR-8, E-4, E-5, AC-9, AC-10 |
| OQ-9 | **Answered.** The list survives closing and reopening the screen while the app runs, and is empty after the app restarts. A short note tells the user the list is temporary. | FR-12, FR-13, AC-13, AC-14, AC-15 |

## Open Questions

- **OQ-1** *(deferred to `/plan`)* — Send many images with the bulk upload call, or repeat
  the existing single-image call once per file? This decides whether protected runtime
  (the API layer) is touched, so the plan must state the choice and list any protected
  path it needs.
- **OQ-2** *(deferred to `/plan`)* — Extend the shared multi-select picker so it can
  return more than one image, or use a separate picker call for this screen only? The
  shared one is used by other screens, so the plan must show that they keep working.
- **OQ-3** *(deferred to `/plan`)* — Where does the uploaded-image list live so that it
  survives closing and reopening the screen (FR-12) without putting new fields into
  protected runtime state?
- **OQ-4** *(deferred to `/plan`)* — Is the new screen declared as its own unit or beside
  the existing dashboard screens? No user-visible effect; the plan decides.

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | Choosing "Gallery" in the dashboard opens a screen showing an upload area at the top and an uploaded-images area below. The old placeholder text is no longer shown anywhere. | FR-1 |
| AC-2 | The upload area shows a dashed-border box with a light fill, containing an upload icon, "Drop images here", "or choose files / folder", and two buttons: "Select Files" filled dark, and "Select Folder" outlined blue. | FR-2 |
| AC-3 | With no images uploaded, the lower area shows a light circle with a picture icon, "No images found", and "Uploaded images will appear here." | FR-11 |
| AC-4 | Dragging a finger over the "Drop images here" area does nothing and causes no error. | FR-3 |
| AC-5 | "Select Files" opens a picker that offers only image files; a document such as a PDF cannot be selected. | FR-4 |
| AC-6 | "Select Folder" opens a picker in which more than one image can be selected and confirmed in one action. | FR-5 |
| AC-7 | Cancelling either picker leaves the screen exactly as it was, with no error message. | E-1 |
| AC-8 | Every image chosen in a picker starts uploading on its own, without the user pressing any extra button. | FR-6 |
| AC-9 | While a batch uploads, each file shows its own progress state, and each finished image appears in the grid as it completes. | FR-7, FR-9 |
| AC-10 | A file whose upload fails stays visible, is clearly marked as failed, and offers Retry. Pressing Retry uploads that file again, and on success it moves into the grid. | FR-8, E-4, E-5 |
| AC-11 | Uploaded images are shown three per row, as squares with rounded corners and a small gap between them. | FR-9 |
| AC-12 | Tapping a thumbnail opens that image full screen, and closing it returns to the gallery with the grid unchanged. | FR-10 |
| AC-13 | After uploading images, leaving the gallery and opening it again — with the app still running — shows the same images. | FR-12 |
| AC-14 | After fully closing and restarting the app, opening the gallery shows the empty state. | FR-12 |
| AC-15 | A short note in the images area tells the user the list shows only images uploaded during the current app run. | FR-13 |
| AC-16 | Every text on the screen is shown translated in all four supported languages; no English text appears when the app language is Arabic, Kurdish or Turkish. | FR-14 |
| AC-17 | In Arabic and Kurdish the screen reads right-to-left: the buttons, the grid order, the icons and the text are all placed correctly. | NFR-1 |
| AC-18 | On a narrow phone, and with the longest translated words, the upload box and its two buttons fit with no overflow warning. | NFR-2, E-9 |
| AC-19 | Refusing the media permission shows a clear message and the app keeps working. | NFR-5, E-2 |
| AC-20 | All other dashboard entries — products, boutiques, orders, permissions, users, stories, excel, shop information, locations, comments — open and behave exactly as before this change. | NFR-4 |
| AC-21 | Selecting about 20 images at once uploads all of them, each with its own progress, and the screen can still be scrolled while they upload. | E-3, NFR-3 |
| AC-22 | Leaving the screen while uploads are still running does not crash the app. | E-6 |

## Out of Scope

- Deleting or reordering an image from the gallery.
- Reading images that were uploaded in an earlier app run, or any list-images endpoint —
  no such API exists (C-2), and no backend work is part of this ticket (C-3).
- Real folder browsing on the device. "Select Folder" means selecting many images.
- Drag and drop of files onto the screen.
- Attaching gallery images to a product, or reusing them anywhere else in the app.
- Uploading videos or documents.
- Editing images (crop, rotate, compress) before upload.
- Any change to how the other dashboard entries work.
- Automated tests for the dashboard; the repository has no widget-test setup for it, so
  this ticket is checked by hand.
