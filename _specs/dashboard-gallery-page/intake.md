---
ticket: dashboard-gallery-page
stage: intake
mode: standard          # single workflow form — no other modes (ADR-009)
status: in_progress     # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-22
links:
  clickup:
  github:
---

# Intake — dashboard-gallery-page

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

dashboard-gallery-page — no ClickUp task or GitHub issue linked. The request came
directly from the Workflow Owner in the session.

## Ticket Summary

The dashboard page (`lib/features/dashBoard/presentation/pages/dashboard_page.dart`)
has a gallery button. The request is to make that button open a new screen. The new
screen has two sections: one section to upload files or folders, and one section to
show images that were uploaded before. The screen must look like the reference design
image at `assets/images/galleryD.jpeg`.

## Reference Design — what the image shows

The image is one screen with a rounded white card, split into two stacked areas:

**Top area — the upload box.** A wide box with a dashed grey border and a very light
grey fill. Inside it, centered:

- an outline "upload" icon (arrow pointing up out of a tray);
- a title line: **"Drop images here"**;
- a smaller, lighter helper line: *"or choose files / folder"*;
- two buttons side by side:
  - **"Select Files"** — filled dark grey / near-black button, white text, with a small
    upload icon before the text;
  - **"Select Folder"** — outlined button, blue border and blue text, white fill.

**Bottom area — the uploaded images list, in its empty state.** Centered in a large
open space:

- a light grey circle holding a grey "picture" placeholder icon;
- a title line: **"No images found"**;
- a smaller, lighter helper line: *"Uploaded product images will appear here."*

The whole design is light-themed, centered, and uses plain grey text on white. The
image shows only the **empty** state — it does not show what the list looks like once
images exist.

## Ticket Metadata

- id / slug: dashboard-gallery-page
- title: Gallery page with upload and uploaded-images sections from the dashboard gallery button
- owner: developer
- created: 2026-08-22
- links: none

## User Story

> As a dashboard user, I want the gallery button to open a gallery screen where I can
> upload files or folders and see the images I uploaded before, so that I can manage my
> gallery content in one place.

## Acceptance Criteria Presence Check

- Present? no
- Notes: The request describes the wanted result and gives a design image, but gives no
  testable criteria. Open points that must become criteria later: what file types are
  allowed; where the files are sent (which API / server) or if this is UI only for now;
  what happens on upload success, failure, and while uploading; how the previously
  uploaded images are read (API list, local storage, or mock); how the image list looks
  when it is **not** empty (the design only shows the empty state); paging or a fixed
  count; and RTL / multi-language behaviour (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`).

## Test Cases Presence Check

- Present? no
- Notes: No test cases were given. They must be written at the `spec` stage, and they
  must cover at least: tapping the gallery button opens the new screen; "Select Files"
  opens a file picker and the picked file reaches the right state; "Select Folder"
  behaves as decided below; the images section shows the empty state exactly as in the
  design; the images section shows images when there are some; and the screen renders
  correctly in RTL.

## Resolved Decisions (answered by the owner, 2026-08-22)

- **D-1 — "Select Folder" on mobile.** Keep the design as drawn. "Drop images here"
  stays as plain text only (there is no drag and drop on a phone). "Select Folder"
  opens a **multi-image picker** (pick many images at once). It is **not** a real
  directory pick.
- **D-2 — Uploads go to a backend.** Use the existing **media server** path:
  `ServerName.mediaServer`. Two steps: `GET /gated/ticket` to get a short ticket
  (lives 120 seconds, one use only), then `POST /gated/upload/bulk` with the ticket in
  the `X-Upload-Ticket` header. A retry needs a **new** ticket.
- **D-3 — The images section shows session uploads only.** There is no API to list
  images that were uploaded before. The bottom section shows only the images uploaded
  in the current session, taken from the upload response. Every fresh open of the
  screen starts at the empty state. No new backend work is needed for this ticket.
- **D-4 — General gallery.** The screen is not tied to a product. The helper line
  changes to "Uploaded images will appear here."

## Missing Information

- The exact response shape of `POST /gated/upload/bulk` (what field holds the returned
  image URLs, and what an error looks like). To be confirmed at `research`/`spec`.
- Allowed file types and any size limit for the picker.
- Whether the four on-screen texts need translation keys in `assets/languages/**`
  (protected runtime path), or stay as literals for this ticket.
- Whether adding the route for the new screen touches `lib/routes/**` (protected runtime
  path) — to be confirmed at `research`.
- The design shows only the empty state. The non-empty look of the image list (grid
  shape, thumbnail size, tap and delete behaviour) still needs a decision at `spec`.

## Readiness Status

`READY`

- Justification: The request is clear, the reference design at `assets/images/galleryD.jpeg`
  is present and readable, and the four blocking questions are answered (D-1..D-4). The
  items still under **Missing Information** are details that `research` and `spec` can
  settle; none of them stops investigation from starting.
