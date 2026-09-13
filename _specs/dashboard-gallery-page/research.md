---
ticket: dashboard-gallery-page
stage: research
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: ai_agent
updated: 2026-08-22
links:
  clickup:
  github:
---

# Research — dashboard-gallery-page

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Make the dashboard "Gallery" entry open a screen that has an upload area (files or many
images) and an area that lists the uploaded images, drawn like
`assets/images/galleryD.jpeg`.

## Main finding — the screen already has a place to live

The gallery entry is **not** a normal route. It is item `index: 9` in the dashboard list
(`dashboard_page.dart:1697-1704`, icon `Icons.image_outlined`, title
`LocaleKeys.gallery.tr()`, subtitle "Upload and reuse product images").

Tapping any item calls `_openTab(index, title)` (`dashboard_page.dart:1576`), which
pushes a `DashboardContentPage` carrying that index. That page picks its body in a
switch (`dashboard_page.dart:1901-1929`):

```dart
case 6: return const UploadExcelWidget();
case 7: return const ShopInfoWidget();
case 8: return const LocationsWidget();
case 9: return Center(child: Text(LocaleKeys.gallery.tr()));  // <- placeholder
```

So `case 9` is a placeholder waiting to be filled. The smallest change that meets the
request is: build a gallery widget and return it from `case 9`, exactly like tabs 6, 7
and 8 do. **This means `lib/routes/**` is not touched at all** — the protected route
files stay untouched, because navigation already works.

`_loadDataFor(index)` (`dashboard_page.dart:1560-1574`) fires a load event per tab.
Index 9 has no branch there. Whether it needs one depends on the state decision in OQ-3;
with session-only images (intake D-3) it likely needs none.

## Relevant directories

- `lib/features/dashBoard/presentation/pages/` — holds `dashboard_page.dart` (3649
  lines). It contains the item list, `_openTab`, the tab switch, and the sibling tab
  widgets `UploadExcelWidget` (line 2398), `LocationsWidget` (3009) and `ShopInfoWidget`
  (3366), which are all declared **inside this one file**.
- `lib/features/dashBoard/presentation/widgets/` — the other dashboard widgets live in
  their own files here (`seller_stories_widget.dart`, `empty_state_widget.dart`, …).
  This is the natural home for a new gallery widget file.
- `lib/features/dashBoard/presentation/bloc/` — `dashBoard_bloc.dart`. `DashboardBloc`
  is a plain `Bloc` (line 62), not a `HydratedBloc`.
- `lib/core/domin/usecases/` — holds `upload_file_media_server_usecase.dart`, the
  ready-made upload flow (see below).
- `lib/core/data/model/` — holds `upload_file_media_server_response.dart`, the upload
  response model.
- `lib/common/helper/` — `helper_functions.dart` holds the existing pickers.
- `assets/languages/` — the four locale files (`ar-SY`, `en-US`, `ku-IQ`, `tr-TR`).

## Reusable code already in the repo

- **Upload is already solved.** `uploadToMediaServer(...)` and
  `UploadFileMediaServerUseCase`
  (`lib/core/domin/usecases/upload_file_media_server_usecase.dart`) do the whole two-step
  gated flow in one call: mint a ticket (`POST /gated/ticket`, `count: 1`) then upload
  (`POST /gated/upload`) with the `X-Upload-Ticket` header. The use case is
  `@injectable` and already registered in DI. `DashboardBloc` already imports the
  media-server path, so the wiring pattern exists in this feature.
- **Response shape is known** — `UploadFileMediaServerResponseModel` has `key`, `size`,
  `type`, `url`, plus a `subPath` getter. `url` is the field that feeds the image list.
  This answers most of the intake "unknown response shape" item for the single-file
  endpoint.
- **Pickers exist** — in `lib/common/helper/helper_functions.dart`:
  - `pickDocumentFile()` (line 417) — `FilePicker.platform.pickFiles()`, returns one
    `File`. Fits the "Select Files" button.
  - `myMultiAssetPicker(context)` (line 355) — asks for the photo permission itself
    (because `AssetPicker.pickAssets` throws instead of returning null when refused),
    shows a warning on refusal, and catches picker errors. Fits the "Select Folder"
    (multi-select) button — **but see the risk below: it is capped at `maxAssets: 1`.**
  - Packages are already in `pubspec.yaml`: `file_picker: ^8.0.6`,
    `wechat_assets_picker: ^9.8.0`.
- `empty_state_widget.dart` — an existing empty-state widget; worth checking at plan time
  whether it can carry the "No images found" block or whether the design needs its own.

## Relevant config files

- `pubspec.yaml` — declares `file_picker`, `wechat_assets_picker`, and the asset folders.
- `lib/common/constant/configuration/media_server_url_routes.dart` — `/gated/ticket`,
  `/gated/upload`, `/gated/upload/bulk`, ticket header `X-Upload-Ticket`, ticket TTL 120
  seconds, one use only. **Protected runtime path** (`*_url_routes.dart`).
- `lib/core/api/methods/detect_server.dart` — `ServerName.mediaServer` exists (line 29).
  No new server entry is needed. **Protected runtime path** (`lib/core/api/**`).
- `assets/languages/*.json` — only `"gallery"` exists today (`en-US.json:23`). The four
  new strings in the design have no keys yet. **Protected runtime path.**
- `lib/generated/locale_keys.g.dart` — generated; never hand-edited (`keys.sh`).
- `analysis_options.yaml` — lint rules for the analyzer.

## Possibly affected services

- **Media server** (`ServerName.mediaServer`) — receives the uploads. Load goes up by one
  ticket + one upload per picked file. The ticket is one-use, so a retry needs a fresh
  ticket.
- **Dashboard flow** — `DashboardContentPage` is shared by all 11 tabs. A mistake in the
  switch or in `_loadDataFor` would hit other tabs (products, orders, stories, excel),
  not just gallery.
- **`DashboardBloc`** — registered as a `lazySingleton` in DI
  (`di_container.config.dart:1040`) and provided app-wide in
  `lib/service/service_provider.dart:30`. It is shared, not per-screen.
- No effect on auth, wallet, calls, push, or stories.

## Test / validation commands available

Listed only — none were run.

- `flutter analyze` — static analysis and lints.
- `flutter test` — runs the test suite. Note: the suite is nearly empty; the only test is
  `test/core/json_size_cap_test.dart`. There are no widget tests for the dashboard, so
  this ticket will most likely be verified by hand on a device.
- `./gen.sh` — `dart run build_runner build --delete-conflicting-outputs` (regenerates
  `*.g.dart` / `*.config.dart`, including DI). Needed if a new `@injectable` class is
  added.
- `./keys.sh` — `flutter pub run easy_localization:generate -S assets/languages -f keys -o
  locale_keys.g.dart`. Needed if new locale keys are added.
- `flutter build apk --debug` / `flutter run` — manual check on a device.

## Risks and unknowns

- **`myMultiAssetPicker` is capped at one asset.** Despite the name, its config is
  `maxAssets: 1` (`helper_functions.dart:371`). "Select Folder" needs many. Changing that
  constant would change behaviour for **every existing caller** of the helper. Safer: add
  a `maxAssets` parameter with default `1`, or call `AssetPicker.pickAssets` directly in
  the new widget. Medium likelihood, medium impact.
- **The bulk endpoint is declared but appears unused.** `bulkUploadEP`
  (`/gated/upload/bulk`) exists in the route file, but the only implemented use case is
  the **single**-file flow (`count: 1`). Intake D-2 chose bulk. So either a new bulk path
  must be written (new repository method, data source, model — more work, touches
  `lib/core/api/**`), or many files are uploaded by looping the existing single-file use
  case (no protected-path change). This is the biggest open decision — see OQ-1.
- **Touching `DashBoardState` hits a protected path.** The rule `**/*_state.dart` covers
  `DashBoardState`. Adding gallery fields there is a protected-runtime change on an
  app-wide singleton bloc. A feature-local Cubit for the gallery is normal work and
  avoids this. See OQ-3. Medium likelihood, high impact on the plan's approval scope.
- **`dashboard_page.dart` is 3649 lines.** Putting the gallery widget inside it follows
  the local habit for tabs 6/7/8 but makes the file worse. A separate file under
  `presentation/widgets/` is cleaner but differs from the neighbours. Low risk, needs a
  decision.
- **New locale keys touch `assets/languages/**` (protected).** The design has strings
  with no keys. Hardcoding English text avoids the protected path but breaks the app's
  multilingual rule and RTL correctness.
- **The design is a desktop web layout.** "Drop images here" has no meaning on a phone
  (kept as plain text per intake D-1). The two side-by-side buttons may overflow on
  narrow phones and in Arabic, Kurdish and Turkish, where the words are longer.
- **Empty state only.** The design does not show the list with images in it, so the
  non-empty layout is not specified by any reference.
- **No safety net.** With almost no tests, a regression in the shared
  `DashboardContentPage` switch would not be caught automatically.

## Open questions

> Give each question a stable ID (`OQ-1`, `OQ-2`, …). `spec.md` must record an
> answer for every one of them (SP-9) — an answer given only in chat does not
> count. A question about touching `observability/**` is answered by putting the
> path in scope (then `plan.md > Files to change`) or by putting it Out of Scope.

| ID   | Question | Why it matters |
|------|----------|----------------|
| OQ-1 | Use the real bulk endpoint `/gated/upload/bulk` (new repository method + data source + model, touching `lib/core/api/**`), or upload many files by looping the existing single-file `UploadFileMediaServerUseCase`? | Decides the size of the ticket and whether a protected runtime path is touched. The loop reuses tested code and keeps the change small; bulk matches intake D-2 literally but has no client code yet. |
| OQ-2 | How should many images be picked — add a `maxAssets` parameter to `myMultiAssetPicker` (default `1`, so existing callers keep working), or call `AssetPicker.pickAssets` directly inside the new gallery widget? | The helper is shared. Changing its fixed `maxAssets: 1` would silently change every other caller. |
| OQ-3 | Should gallery state live in the shared app-wide `DashboardBloc` (touching `DashBoardState`, a protected `**/*_state.dart` path on a singleton), or in a new feature-local Cubit / `StatefulWidget` state? | A feature-local holder is normal work and keeps the ticket outside protected runtime. Extending `DashBoardState` needs explicit plan approval. |
| OQ-4 | Should the new widget be a new file under `lib/features/dashBoard/presentation/widgets/`, or declared inside `dashboard_page.dart` like `UploadExcelWidget`, `LocationsWidget` and `ShopInfoWidget`? | Consistency with neighbours versus not growing a 3649-line file further. |
| OQ-5 | Do the design strings ("Drop images here", "or choose files / folder", "Select Files", "Select Folder", "No images found", "Uploaded images will appear here.") get locale keys in all four languages (touching `assets/languages/**`, a protected path, and needing `./keys.sh`), or stay as English literals for now? | Decides whether the ticket touches a protected path and whether RTL and the other three languages are correct. |
| OQ-6 | What does the images area look like when it is **not** empty — grid or list, how many per row, thumbnail shape, and what happens on tap (preview? delete? copy URL?)? | The reference image only shows the empty state, so this cannot be traced to the design. `spec` needs it to write acceptance criteria. |
| OQ-7 | What file types and size limit are allowed for "Select Files" — images only, or any document as `pickDocumentFile()` currently does with no filter? | The section is called a gallery and lists images, but the design says "choose files". An unfiltered picker lets a user send a PDF into an image gallery. |
| OQ-8 | What must the user see while uploading and when an upload fails (per-file progress, a retry button, a snackbar)? The upload ticket lives only 120 seconds and is single-use, so a retry must mint a new ticket. | The design shows no loading or error state at all, and the ticket TTL makes a naive retry fail. |
| OQ-9 | Since images are session-only (intake D-3), should the list be cleared when the screen is closed and re-opened, and is that acceptable to show the user (for example a short note), or should it survive for the app session via the shared bloc? | Affects OQ-3 and what the user experiences after leaving the tab. |

## Notes

- No code was changed during research.
- No observability runtime configs were modified.
