---
ticket: manage-shop-locations-in-seller-dashboard
stage: research
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: ai_agent
updated: 2026-08-27
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Research — manage-shop-locations-in-seller-dashboard

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Replace the mocked `LocationsWidget` in the seller dashboard with the real shop
locations from `{MARKET_API}` — list, add, edit, and activate/deactivate — wired
through the dashboard's existing data → domain → bloc layers and gated by the
existing permission checker.

## Headline finding — the backend already has a location record

Intake recorded that the API guide has no Locations section, so the endpoints
were assumed. That is still true of the **endpoints**, but the **record itself is
not unknown**. The become-seller flow already sends one:

- `lib/features/dashBoard/domain/useCase/submit_vendor_request_usecase.dart:75-77`
  and `update_vendor_request_usecase.dart:81-83` post
  `location_country_iso`, `location_name`, `location_address`.
- `lib/features/dashBoard/data/models/get_vendor_request_model.dart:60-62`,
  `:100-102` reads those three back, plus `latitude` and `longitude` (`:63-64`).
- The form that fills them is
  `lib/features/home/presentation/pages/become_seller/become_seller_page.dart:857-905`
  — location name (**`maxLength: 10`**, `:872-882`), location address
  (multiline, `:888-899`), then a Google Maps picker
  (`become_seller/location_picker_page.dart`) that produces the coordinates.

So the field names in the backlog ticket are wrong in three ways, and the
correction is evidence-backed rather than a guess:

| Backlog ticket said | The app already sends |
|---|---|
| `name` | `location_name`, capped at 10 characters |
| `address` | `location_address` |
| `country` (display name, "Syrian Arab Republic") | `location_country_iso` (an ISO code) |
| — (no such field) | `latitude`, `longitude` from a map picker |

This does not produce the endpoint paths, the paging shape, or the permission
strings — those still need Mohamad Hassan (`OQ-1`, `OQ-2`). It does mean the
form in the ticket is under-specified: see `OQ-3`, `OQ-4`, `OQ-5`.

## Relevant directories

- `lib/features/dashBoard/presentation/pages/dashboard_page.dart` — holds
  `LocationsWidget` (`:3015`–`:3372`). A plain `StatefulWidget` with **no bloc
  access at all**: one hardcoded `LocationModel` in `_locations` (`:3024`–`:3033`),
  a local `_statusFilter` (`:3035`–`:3040`), `_onAddLocation` and `_onEdit` empty
  `TODO` bodies (`:3047`–`:3053`), and `_onDeactivate` flipping the flag with
  `setState` only (`:3055`–`:3070`). Mounted as tab `case 8` in
  `_buildTabContent()` (`:1926`); its tab entry is `_FilterItem(index: 8, …
  visible: true)` (`:1694`–`:1701`).
- **The precedent to copy is in the same file.** `ShopInfoWidget`
  (`:3376` onward) was mocked in exactly this way and is now fully wired by the
  sibling work item `_specs/connect-shop-info-widget-to-shop-info-api/`. It
  shows every pattern this ticket needs: permissions passed down the constructor
  (`:3379`), `DashboardPermissionChecker` for `_canRead` / `_canUpdate`
  (`:3411`–`:3413`), `_sellerIdAtOpen` captured in `initState` (`:3419`), a
  `ClearShopInfoEvent` when the loaded record belongs to another shop
  (`:3424`–`:3429`), and the load dispatched once from a
  `addPostFrameCallback` rather than from `build` (`:3420`).
- `lib/features/dashBoard/data/data_source/dashBoard_remote_data_source_model.dart`
  — one method per endpoint built from `GetClient` / `PostClient` / `PutClient`
  with `serverName: ServerName.dashBoard`. `getShopInfo()` (`:549`) and
  `getGalleryImages({page, perPage, search})` are the two closest models.
- `lib/features/dashBoard/data/repositories/dashBoard_repository_impl.dart` and
  `.../domain/repositories/dashBoard_repository.dart` — every method returns
  `Either<Failure, T>`; the impl wraps the data source in
  `handlingExceptionRequest`. `getShopInfo` is at `dashBoard_repository.dart:93`.
- `lib/features/dashBoard/domain/useCase/` — one `@injectable` file per use
  case. `GetShopInfoUseCase.dart` / `UpdateShopInfoUseCase.dart` are the pattern.
- `lib/features/dashBoard/presentation/bloc/` — `dashBoard_bloc.dart`,
  `dashBoard_event.dart`, `dashBoard_state.dart`. `DashboardBloc` is a plain
  `Bloc`, **not** a `HydratedBloc`. `DashBoardState` carries one
  `<Feature>Status` enum per call; shop info added a fifth value,
  `permissionDenied` (`dashBoard_state.dart:53`), which this ticket needs too.
- `lib/features/dashBoard/presentation/widgets/` —
  `dashboard_permission_checker.dart` (eight `canSee*` / `can*` methods, `:11`–`:77`),
  `permission_enum.dart` (`DashBoardPermission`), `pagination_widget.dart`.
- `lib/features/app/` — `country_dropdown.dart` (`CountryDropdown`, takes
  `List<Country>`) and `available_countries_list.dart`. The country model is
  `lib/features/home/data/models/get_allowed_country_model.dart`; a static list
  also exists at `lib/common/constant/countries.dart`.
- `lib/core/api/base_api.dart` — builds headers for every request. For
  `ServerName.dashBoard` it sets `X-Seller-ID` from
  `GetIt.I<PrefsRepository>().getXSellerId` (`:34`), plus `country` (`:25`) and
  `lang` (`:37`). **No per-call code adds these headers** — several of the
  ticket's Scope & Tenant Safety criteria are therefore already satisfied by
  infrastructure, and the real risk is the one the sibling found: the header is
  resolved at request-build time, so a shop switch mid-flight can retarget a
  write.
- `assets/languages/` — `ar-SY.json`, `en-US.json`, `ku-IQ.json`, `tr-TR.json`
  (945 keys in `en-US.json`).

## Relevant config files

- `lib/common/constant/configuration/dashBoard_url_routes.dart` —
  `DashBoardEndPoints` plus the `shopScope()` / `usersScope()` extensions;
  `DashBoardUrls.baseUrl` reads `dotenv.env['MARKET_URL']`. **There is no
  locations entry, and no `location` string anywhere under
  `lib/common/constant/configuration/` or `lib/core/api/`.** Protected runtime
  path (`*_url_routes.dart`).
- `lib/features/dashBoard/presentation/widgets/permission_enum.dart` —
  `DashBoardPermission` holds `SUPER_ADMIN` (`:56`), the four `*_BUTIKS` values
  (`:19`, `:28`, `:37`, `:46`) and `READ_SHOP_INFO` / `UPDATE_SHOP_INFO`
  (`:75`–`:76`). **No locations value of any kind.**
- `assets/languages/*.json` — already present in all four bundles:
  `locations`, `location_name`, `location_address`,
  `location_name_is_required`, `location_address_is_required`, `edit`, `add`,
  `save`, `all`. **Absent:** `active`, `inactive`, `country`, `status`,
  `retry`, and anything for "Add Location", "Deactivate", "All statuses", "No
  locations found". Protected runtime path.
- `lib/core/di/di_container.config.dart` — generated. `DashboardBloc` is a
  `lazySingleton` (`:1108`) and is provided app-wide in
  `lib/service/service_provider.dart:30`. Adding events and state to that
  existing bloc is normal work; **changing its registration is not** — CLAUDE.md
  lists app-wide BLoC registration as protected runtime.
- `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` — matches the
  protected pattern `**/*_state.dart`, so `plan.md` must name it even though the
  bloc is not hydrated.
- `.env` — `MARKET_URL` already exists. **No new key is needed.**
- `.claude/project-config.yaml` — the validation checks and profiles this ticket
  can name in `plan.md > Validation strategy`.

## Possibly affected services

- **Market/dashboard backend** (`MARKET_URL`, `ServerName.dashBoard`) — three or
  four new calls (list, create, update, status change). Create and update are
  writes that change what buyers see as the shop's pickup and warehouse points.
- **Vendor-request flow** — the same three location fields are written by
  `POST/PUT /api/v1/shop/vendor-requests`. If the dashboard list and the vendor
  request point at one record, editing here changes what that flow submitted
  (`OQ-11`).
- **Permissions call** `GET /shop/auth/permissions` — already dispatched by
  `GetUserPermissionEvent` in `dashBoard_bloc.dart`. This ticket reads its
  result; it adds no call.
- **`PrefsRepository`** — read-only use of `getXSellerId`. It is written in
  `DashboardContentPage.initState` (`dashboard_page.dart:1560`) and in
  `SelectShopForOrderPage`. This ticket must not write it.
- **Media server** — **not involved.** A location has no image in any evidence
  found, so no upload path is touched.

## Test / validation commands available

- `flutter analyze` — check id `flutter-analyze`, profile `flutter-standard`.
- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code`
  — check id `build-runner-clean`, profile `codegen-change`. Required here: a new
  `@injectable` use case and any new model change the generated DI and `*.g.dart`.
- `flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart && git diff --exit-code`
  — check id `locale-keys-clean`, part of profile `localization-change`.
- `py .claude/scripts/check_locale_parity.py` — check id `locale-bundles-in-sync`,
  the four bundles must declare the same keys.
- `flutter test` — the whole suite is **one file**,
  `test/core/json_size_cap_test.dart`. There is no widget test and no bloc test
  in the repository.
- A manual run on a device against the dev market server — the only way to
  exercise create, update, and the status change end to end.

*Listed, not run — research is read-only.*

## Risks and unknowns

- **The endpoints are still unwritten.** Everything about the request line — path,
  verb, body key names, paging parameters, the status-change shape — rests on one
  person's answer. A spec written before that answer fixes AC-n ids against
  guesses, and the intake condition forbids exactly that. Impact: high;
  likelihood: certain until asked.
- **`latitude` / `longitude` are the quiet risk.** The become-seller flow makes a
  location with coordinates from a map. If the backend requires them, this
  ticket's form cannot create a valid location at all, and "add a location" grows
  a Google Maps screen — a much larger change than the ticket describes.
  Impact: high; likelihood: medium.
- **Protected runtime paths are unavoidable.** `dashBoard_url_routes.dart` must
  gain the locations entries, `permission_enum.dart` must gain the permission
  names, `dashBoard_state.dart` matches `**/*_state.dart`, and new strings touch
  `assets/languages/**`. All are on the CLAUDE.md protected list, so they may
  change only inside an approved `implement` stage with `plan.md` naming them.
- **Deactivate may not exist.** The ticket scopes deactivate and explicitly rules
  out delete. If the backend offers only delete, the ticket's central safety
  choice is not implementable as written. Impact: medium; likelihood: medium.
- **Paging may be imaginary.** A shop plausibly has a handful of locations. If
  the endpoint returns them all, the infinite-scroll criterion and the
  `meta.total` count badge describe a response shape that does not exist.
  Impact: low; likelihood: medium.
- **Shop switch mid-write.** The sibling work item found that `X-Seller-ID` is
  resolved when the request is built, not when the event is dispatched, and
  added `AC-29` for it. The same hole exists here for create, update, and the
  status change. Impact: high; likelihood: low.
- **No automated evidence path.** With one test file in the repo, every
  acceptance criterion will be evidenced by a manual run unless this ticket adds
  test infrastructure the sibling explicitly declined to add.
- **The screen is not localized and not RTL-checked.** Ten hardcoded English
  strings sit in `LocationsWidget` today: `'Locations'` (`:3089`), `'Add
  Location'` (`:3116`), the three filter options `'All statuses'` / `'Active'` /
  `'Inactive'` (`:3036`–`:3040`), `'No locations found'` (`:3172`), the
  `'Active'` / `'Inactive'` badge (`:3237`–`:3241`), `'Edit'` (`:3305`), and
  `'Deactivate'` / `'Activate'` (`:3337`–`:3339`). The tab subtitle
  `'Warehouses and pickup points for this shop'` (`:1699`) is hardcoded too.

## Open questions

> Give each question a stable ID (`OQ-1`, `OQ-2`, …). `spec.md` must record an
> answer for every one of them (SP-9) — an answer given only in chat does not
> count.

| ID | Question | Why it matters |
|------|----------|----------------|
| OQ-1 | What are the real Locations endpoints on `{MARKET_API}` — paths, verbs, request bodies, response envelope, and paging parameters? Nothing exists in `.claude/docs/mobile-seller-dashboard-api-guide.md`, and no `location` route exists under `lib/common/constant/configuration/`. Ask **Mohamad Hassan**. | Intake recorded a condition that no AC-n may be fixed against an assumed endpoint. Until this is answered the spec cannot state a single testable request. |
| OQ-2 | What are the real permission strings for locations? `DashBoardPermission` has none, and the guide's permission table has no locations row. They must come from `GET /shop/auth/permissions` on a shop that has locations. | Six of the ticket's Authorization criteria name guessed constants. A wrong string fails open or fails closed silently — the UI hides a control the user is entitled to, or shows one the backend rejects. |
| OQ-3 | Does a location record require `latitude` / `longitude`? The become-seller flow collects them through `LocationPickerPage` (Google Maps) and sends them with the same three location fields. | If they are required, "Add Location" needs a map picker and the ticket's three-field form cannot create a valid record. This is the single largest scope risk in the ticket. |
| OQ-4 | Is country sent as `location_country_iso` (an ISO code, as the vendor request sends) and, if so, which list feeds the picker — `GetAllowedCountryModel` from the allowed-countries call, `CountryDropdown`, or the static `lib/common/constant/countries.dart`? The mock card renders a display name ("Syrian Arab Republic"). | Decides the form control, the value sent, and how the card renders a stored ISO back as a readable name. |
| OQ-5 | Does the 10-character cap on the location name (`become_seller_page.dart:872-882`, with `field_must_not_exceed_10_characters`) also apply to this screen? | The ticket's Validation section says only "not empty". If the backend enforces 10, a name typed here is rejected after the request instead of before it. |
| OQ-6 | Does the backend support deactivating a location, or only deleting one? | The ticket scopes deactivate in and delete out. If only delete exists, that choice is not implementable and the AC must change rather than be quietly reinterpreted. |
| OQ-7 | Does the list endpoint page, and does it return a `meta.total`? | Three criteria depend on it: the count badge, the "load more while `current_page < last_page`" rule, and the paging error case. If the endpoint returns a flat array, all three are unwritable. |
| OQ-8 | Is the Locations **tab entry** hidden when the read permission is missing (`dashboard_page.dart:1700` is hardcoded `visible: true`), or does the gate live only inside the screen body? | Changes which files the plan touches. The sibling answered the same question for Shop Info with "gate inside the screen only" — following it keeps the shared tab list untouched. |
| OQ-9 | Are the ten hardcoded English strings plus the tab subtitle in scope — new keys in all four bundles plus `./keys.sh` — or does this ticket ship them as they are? | `assets/languages/**` is protected and the app is RTL-aware. The sibling put localization in scope for Shop Info; excluding it here would ship an untranslated tab next to a translated one. |
| OQ-10 | How does `verify` evidence the acceptance criteria — a manual run on a device against the dev market server plus `flutter analyze`, or new widget/bloc tests? | The suite is one file. The sibling chose the manual route (its `OQ-8`); agreeing the method now avoids failing the verify gate at the end. |
| OQ-11 | Are the vendor-request location fields and the dashboard Locations list the same backend record? | If the shop's first location comes from the become-seller submission, editing it here changes that record, and the ticket's Out of Scope line ("no change to any other flow") is not true. |
| OQ-12 | Does a create or update need the same mid-flight shop-switch guard the sibling added as its `AC-29` (`expectedSellerId` compared before the write is dispatched)? | `X-Seller-ID` is resolved at request-build time in `base_api.dart:34`, so a shop switch between dispatch and send retargets the write to the wrong shop. |

## Notes

- No code was changed during research.
- No observability runtime configs were modified (this project owns none —
  `features.observability: false` in `.claude/project-config.yaml`).
- The sibling work item `_specs/connect-shop-info-widget-to-shop-info-api/` is
  the closest reference in the repository. Its `research.md` answers the
  `sellerId` question that intake raised as item 4, and its `spec.md` records
  decisions on tab gating, localization scope, and the verification method that
  `OQ-8`, `OQ-9`, and `OQ-10` here should follow unless there is a reason not to.
  It is at `verify` and `blocked` on `BLK-NO-DEVICE-RUN-01` — the same device
  dependency will apply to this ticket's verification.
