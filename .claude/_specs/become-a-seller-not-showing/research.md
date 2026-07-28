---
ticket: become-a-seller-not-showing
stage: research
mode: standard
status: complete
owner: ai_agent
updated: 2026-07-18
links:
  clickup:
  github:
---

# Research — become-a-seller-not-showing

> Read-only phase. **No implementation is allowed in this command.**

## Goal

Make the "Become a Seller" entry point on the profile page visible to users who
do not yet own a shop, without changing the behaviour for users who already own
one (`isMaster`).

## Findings — current behaviour

`lib/features/home/presentation/pages/profile_page.dart:322-403` renders the
entry point inside a `BlocBuilder<DashboardBloc, DashBoardState>` keyed on
`getUserPermissionStatus`. The nested conditional is:

1. `getUserPermissionStatus == loading` → shimmer placeholder.
2. `getUserPermissionStatus == success` **AND** `shops` is non-empty →
   - `shops.first.isMaster == true` → `SizedBox.shrink()` (hidden — user already
     owns a shop);
   - otherwise → the `InkWell` that opens `BecomeSellerPage` in a modal sheet.
3. **Anything else → `SizedBox.shrink()`.**

Branch 3 is the defect: a user with **no shop** has an empty/null `shops` list,
fails the non-empty guard in branch 2, and falls through to the final
`SizedBox.shrink()`. The entry point is therefore hidden from precisely the
audience it exists for. `isMaster` itself behaves as intended; the non-empty
`shops` guard is what suppresses the shop-less case.

Two secondary paths also render nothing (both end in branch 3):
- `DashboardBloc._onGetUserPermissionEvent`
  (`lib/features/dashBoard/presentation/bloc/dashBoard_bloc.dart:120-127`) emits
  `failure` without calling the API when the stored phone number is shorter than
  3 characters.
- A failed permission request emits `failure` (same file, `:134-140`).

Data flow: `GetUserPermissionEvent` → `getUserPermissionUseCase` →
`state.copyWith(shops: r.shops, status: success)`. It is dispatched after login
(`lib/features/authentication/presentation/manager/auth_bloc.dart:452,989`),
from `dashBoard_bloc.dart:283`, and from the shop-selection pages. The profile
page itself does not dispatch it — it only observes the state.

## Relevant directories

- `lib/features/home/presentation/pages/` — hosts `profile_page.dart`, the
  screen carrying the entry point; the only surface the ticket targets.
- `lib/features/home/presentation/pages/become_seller/` — `BecomeSellerPage`,
  the destination opened by the entry point (unchanged by this ticket).
- `lib/features/dashBoard/presentation/bloc/` — `DashboardBloc`,
  `DashBoardState`, `GetUserPermissionStatus`, and the `shops` list that gates
  visibility.
- `lib/features/dashBoard/data/models/` — `get_user_permission_model.dart`,
  where `Shop.isMaster` is parsed (`is_master == 1`).
- `lib/features/dashBoard/domain/useCase/` — `get_user_permission_usecase.dart.dart`.
- `lib/features/dashBoard/presentation/pages/` — `select_shop_page.dart` /
  `SelectShopForOrderPage.dart`, other consumers of the same `shops` state
  (regression surface if state handling is touched).
- `lib/features/authentication/presentation/manager/` — dispatches
  `GetUserPermissionEvent` after login (high-risk path; read-only here).

## Relevant config files

- `.claude/project-config.yaml` — modes, `high_risk_paths`, `validation_checks`
  / `validation_profiles`. Notably `hydrated_state` globs `**/*_state.dart`,
  which matches `dashBoard_state.dart`.
- `analysis_options.yaml` — lint rules gating `flutter analyze`
  (`prefer_const_constructors`, `avoid_redundant_argument_values`, …), which the
  nested-conditional rewrite must satisfy.
- `assets/languages/{en-US,ar-SY,ku-IQ,tr-TR}.json` +
  `lib/generated/locale_keys.g.dart` — source of
  `LocaleKeys.become_a_seller_at_trydos`. Relevant only if new copy is added;
  the existing key already exists in all bundles.
- `pubspec.yaml` — `flutter_bloc`, `shimmer`, `flutter_screenutil` used by the
  affected widget.

## Possibly affected services

- **DashBoard permission service** (`GET` user permission via the `dashBoard`
  `ServerName`, `X-Seller-ID` header) — the source of `shops`. Read-only in this
  ticket; no request/contract change expected.
- **DashboardBloc (app-wide singleton)** — shared by the profile page and both
  shop-selection pages. A change to state shape or to `_onGetUserPermissionEvent`
  would ripple to those pages. It is a plain `Bloc`, **not** a `HydratedBloc`, so
  no persisted-payload migration is implied.
- **Authentication / OTP** — the entry point's `onTap` checks
  `prefsRepository.isVerifiedPhone` and may dispatch `SendOtpEvent`. Making the
  widget visible to more users increases traffic through this unverified-phone
  branch; the branch itself must not be modified (high-risk path).
- **BecomeSellerPage / vendor-request flow** — receives the newly reachable
  users; behaviour unchanged but now exercised by the shop-less cohort.

## Test / validation commands available

*(listed only — none were run during research)*

- `flutter analyze` — static analysis / lints (check-id `flutter-analyze`;
  profile `flutter-standard`). The expected profile for this ticket.
- `flutter pub get` — dependency resolution before analysis.
- `flutter run` — manual verification on a device/emulator; the acceptance
  criteria are visual and account-shape dependent, so manual runs per account
  type are the primary evidence.
- `flutter test integration_test` — device-backed integration suite. No existing
  test covers the profile page's seller entry point.
- `sh gen.sh` (`build-runner-clean`) — only if a model/DI annotation changes;
  not expected here.
- `sh keys.sh` + `py .claude/scripts/check_locale_parity.py`
  (`localization-change`) — only if a new locale key is introduced; not
  expected, since `become_a_seller_at_trydos` already exists.

## Risks and unknowns

- **Scope creep into a high-risk path** — `dashBoard_state.dart` matches the
  `hydrated_state` glob `**/*_state.dart` in `high_risk_paths`. If the fix adds
  a state field, the ticket must be escalated to `high_risk` (MO-3/GU-2). Keeping
  the change inside `profile_page.dart` keeps it `standard`. Likelihood: low if
  the conditional is restructured in the widget only.
- **Shared-state regression** — `select_shop_page.dart` and
  `SelectShopForOrderPage.dart` read the same `shops`/`getUserPermissionStatus`.
  Impact: medium if bloc logic is touched; none if the widget alone changes.
- **`failure` and `init` states stay hidden** — a user whose permission call
  fails (or whose stored phone number is under 3 characters,
  `dashBoard_bloc.dart:120`) still sees nothing. Whether the entry point should
  appear optimistically in those states is a product decision, not a given.
- **`shops.first` assumption** — visibility is derived from the *first* shop
  only. A user attached to several shops (master of one, not of another) is
  judged by list order. Pre-existing; may surface once the empty case is fixed.
- **Unverified-phone path** — the `onTap` OTP branch touches
  authentication/session behaviour. It must be left untouched to stay in
  `standard` mode.
- **No automated coverage** — the acceptance criteria are visual/state-driven
  and will rest on manual verification per account type; regressions would not
  be caught by CI.
- **Regression history unknown** — nobody has confirmed whether this ever
  worked, so there is no known-good commit to diff against.

## Open questions

- Should a user attached to a shop but **not** its master (an employee) continue
  to see "Become a Seller"? Today they do; the empty-shops fix must state
  whether that stays.
- Should the entry point be shown when `getUserPermissionStatus` is `failure` or
  `init` (fail-open), or remain hidden (fail-closed) as today?
- Should multi-shop users be evaluated by `shops.first` or by "is master of any
  shop"? Changing this widens scope beyond the reported defect.
- Is any analytics/telemetry expected on the newly visible entry point, or is
  this a pure visibility fix?
- Does a user with a pending vendor request (submitted but not approved) need a
  different affordance instead of the plain "Become a Seller" action?

## Notes

- No code was changed during research.
- No auth/session, api/network, composition-root, hydrated-state, calls/push, or
  wallet/order money high-risk paths were modified during research.
