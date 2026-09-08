# Unit tests

One command runs everything in this folder, from the repository root:

```bash
flutter test
```

That is the single entry point. There is no aggregator file to keep in step —
`flutter test` finds every `*_test.dart` under `test/` on its own, so a new file
joins the run the moment it is saved.

Useful variants:

```bash
flutter test test/core/api                 # one folder
flutter test --name "refresh coordinator"  # one test by name
flutter test --coverage                    # writes coverage/lcov.info
```

## Layout

`test/` mirrors `lib/` one directory at a time, and each file keeps the name of
the unit it covers plus `_test`:

```
lib/core/api/token_refresh_coordinator.dart
test/core/api/token_refresh_coordinator_test.dart
```

Shared fakes and harness code go in `test/helpers/`. Each helper is written when
the first test actually needs it, so the folder never fills with scaffolding
nobody calls. What is there now:

| Helper | What it stands in for |
|--------|-----------------------|
| `network_harness.dart` | dotenv test values, a `Dio` whose transport is scripted, and the `FakePrefs` the network layer reads |
| `session_prefs.dart` | the stored session — four tokens, four refresh tokens, three identities and the flags |
| `hydrated_storage_harness.dart` | an in-memory `HydratedStorage`, without which no hydrated bloc can be built |
| `secure_storage_harness.dart` | the keychain, answered at the method channel so the real `FlutterSecureStorage` runs |
| `auth_flow_harness.dart` | the real `AuthBloc` over the real use cases and repository, with the four blocs it talks to recorded |
| `home_flow_harness.dart` | the same for `HomeBloc` and its 54 use cases |
| `auth_fixtures.dart`, `home_fixtures.dart` | the response bodies, so a test shows only the field it is about |

### Two things about the harnesses that are easy to get wrong

**The interceptor is not scenery.** Both flow harnesses install the real
`LoggerInterceptor`. Without it every non-2xx status collapses to 400 before a
handler can branch on it: Dio raises an exception, `PostClient`'s `catchError`
returns that exception where a `Response` belongs, the resulting `ArgumentError`
lands in the generic catch in `handlingExceptionRequest`, and out comes
`ServerFailure(400)` whatever the server said. The interceptor resolves the error
back into a `Response` carrying the real status. A harness without it would go
green against a code path the app never runs.

**Assert the sequence, not just the end.** Both harnesses record every state the
bloc passed through, and `transitionsOf` collapses the repeats. Checking only the
final state cannot tell "went loading, then succeeded" from "jumped straight to
success", and a handler that stops emitting `loading` leaves every spinner in the
app running forever. Where the loading emit is part of the contract, assert the
whole list.

**Two servers can share a path.** `ChatEndPoints.loginEP` and
`StoriesEndPoints.loginEP` are both `api/v1/users/login`, and the chat refresh
borrows `MarketEndPoints.refreshTokenEP`. Route those through `AuthRoutes`, which
names the host as well — see `auth_flow_harness.dart`.

## What belongs here, and what does not

This folder is for **unit tests** — one behaviour, no device, no real network.
Widget-level and end-to-end scenarios live in `integration_test/`, which needs a
running device and is not part of `flutter test`.

## The plan

Every test here comes from a scenario in the test ledger:

- open `docs/test-ledger.html` in a browser (works offline, straight from disk)
- 366 scenarios, in 8 waves, ordered so nothing depends on work not done yet
- tick a scenario once its test is written **and green**

Each test file names the ledger wave and unit it belongs to in a comment at the
top, so a reader can go from a test back to the reason it exists.

## Writing a test that is worth keeping

A test that cannot fail is not protection, it is decoration. Before ticking a
scenario, break the code it covers on purpose and confirm the test goes red —
then undo the break. Every test in this folder has been checked that way.

Three kinds of hole showed up while checking that, and all three are easy to
repeat:

- A **test that proves the wrong thing.** `expect(AuthBloc, isNot(HydratedBloc))`
  compares two `Type` objects, which is true for any two distinct classes — it
  would have stayed green if `AuthBloc` had started extending `HydratedBloc`. Ask
  the built instance, not the type: `isNot(isA<HydratedBloc<…>>())`.
- A **helper tested away from its caller.** The OTP resend window was checked by
  driving `throttleDroppable` over a bare stream. That proves the transformer
  works, not that `AuthBloc` uses it — deleting `transformer:` from
  `on<SendOtpEvent>` left the suite green. It now also asks the bloc for two taps
  and counts the requests that left.
- Two mutations that **survived**, both the test's fault rather than the code's:
  - The hydration test asserted that the OTP id token is missing from the
    persisted payload — but built its user *without* a token, so the assertion
    held whether or not the scrub ran. Fixed by giving the user a token and
    asserting the in-memory state still has it.
  - The inbox test tried to prove that a first load replaces the list, by making
    the success branch always append. It stayed green because the handler guarded
    that **twice**: the model was reset to `PaginationModel.init` at the top of
    the handler for a non-pagination call, *and* the success branch had a ternary
    that replaced rather than appended. Neither guard alone changed the
    behaviour, so no single edit could. The redundant ternary has since been
    removed, the reset is now the only guard, and breaking it does turn the test
    red.

## Status

| Wave | Unit | Scenarios | Mutations caught | State |
|------|------|-----------|------------------|-------|
| 01 Core runtime | Refresh coordinator | 6 | 3 / 3 | green |
| 01 Core runtime | 401 refresh and replay | 8 | 4 / 4 | green |
| 01 Core runtime | Exception mapping | 5 | 3 / 3 | green |
| 01 Core runtime | Retry policy | 4 | 2 / 2 | green |
| 01 Core runtime | Status codes | 1 | 1 / 1 | green |
| 01 Core runtime | Media urls | 4 | 2 / 2 | green |
| 01 Core runtime | Form validators | 5 | 2 / 2 | green |
| 01 Core runtime | Server and token resolution | 4 | 3 / 3 | green |
| 01 Core runtime | Request headers | 5 | 3 / 3 | green |
| 01 Core runtime | Upload pipeline | 4 | 2 / 2 | green |
| 02 Account and session | Continue as guest | 3 | 2 / 2 | green |
| 02 Account and session | Request an OTP | 3 | 3 / 3 | green |
| 02 Account and session | Verify the OTP | 4 | 2 / 2 | green |
| 02 Account and session | The four-server login | 6 | 1 / 1 | green |
| 02 Account and session | Staying in | 4 | 1 / 1 | green |
| 02 Account and session | Logging out | 5 | 2 / 2 | green |
| 02 Account and session | Edit the profile | 4 | 2 / 2 | green |
| 02 Account and session | Change the display name everywhere | 2 | 2 / 2 | green |
| 02 Account and session | Country and currency | 5 | 1 / 1 | green |
| 02 Account and session | Notification settings | 6 | 2 / 2 | green |
| 02 Account and session | The notification inbox | 2 | 3 / 3 | green |
| 02 Account and session | AuthBloc contract | 3 | 2 / 2 | green |

**Wave 01 is complete: 46 / 46. Wave 02 is complete: 47 / 47.** 100 of 366
overall, counting the wave 00 setup already in place (`bloc_test`, `fake_async`,
dotenv test values, `GetIt` reset between tests, and now the in-memory
`HydratedStorage` and the bloc harness that hands back the emitted state list).

The bloc-harness scenario asks for "mocked use cases". The flow harnesses build
the bloc over the **real** use cases and repository with only the transport
mocked, which is what the wave-02 tier asks for in turn — "a mocked `Dio` at the
bottom, the real repository / use case / bloc chain above it". The part that
scenario is really about, a harness that hands back the states the bloc passed
through, is there: `emitted` and `transitionsOf`.

Wave 00 is still deliberately unfinished. The CI job and the `needs:` line on the
deploy workflow are not written yet, and two helpers — a fixture loader and the
non-JSON / timeout replies on `ScriptedAdapter` — wait for the first test that
needs them, per the rule above.

## Defects

Three wave-02 defects were fixed, under **Fixed here** below — two in
`home_bloc.dart`, one in `auth_bloc.dart` — and every one of them is
mutation-checked. Everything else in this section is *pinned*: held in place by a
test that says so in a comment, and written so it fails the moment the defect is
fixed — which is what stops any of them being fixed quietly.

### Found in wave 01

- `base_api_test.dart` — the shared Dio keeps the previous request's bearer, so a
  public server carries a token it should never see.
- `handling_exception_test.dart` — `TryAgainException` has no branch and loses
  its retry count.
- `validator_test.dart` — `RequiredValidator` accepts `null`.

### Found in wave 02

- **`DeleteFcmTokenEvent` has no handler — and cannot get one yet.** It is
  declared in `auth_event.dart:86` and that is all: `AuthBloc`'s constructor
  registers no `on<DeleteFcmTokenEvent>`, so it falls through to the catch-all
  `on<AuthEvent>((event, emit) {})`, and nothing in `lib/` dispatches it either.
  The market device token is therefore never removed on logout, and the phone
  keeps receiving market push for an account nobody is signed into.

  It was left unfixed on purpose. The market side has **no endpoint to delete a
  device token**: `MarketEndPoints` has `storeFcmOfMarketEP`
  (`POST api/v1/firebase_device_tokens`) and
  `sendAcceptOfNotificationMarketEP` (`.../validate_token`), and nothing else —
  the chat server's `remove-token` has no market twin anywhere in the app. Adding
  a handler would mean calling a path nobody has confirmed exists, which ships a
  404 dressed as a fix. **This needs a backend endpoint first.** Pinned by
  `test/features/authentication/logging_out_test.dart`.
### Fixed here

- **`SendAcceptOfNotificationMarketEvent` had no dedupe.** The handler kept no
  record of which ids it had confirmed and the event is registered with no
  transformer, so the same greeting arriving twice confirmed twice. It now holds
  the confirmed ids in an in-memory set — in memory, not in `HomeState`, because
  persisting them would change the hydrated payload shape and need a migration of
  its own. A refused confirmation releases its id again, so the retry the handler
  already had still goes out. Covered by
  `test/features/home/notification_inbox_test.dart`.
- **A failed chat-name update retried the wrong flow.**
  `_onUpdateChatUserNameEvent` re-added `UpdateStoriesUserEvent` in all three of
  its failure branches, so a chat-name update that failed started the
  stories-first chain instead — running the stories update a second time and
  never retrying the chat name at all. It now re-adds its own event. Covered by
  `test/features/authentication/display_name_test.dart`, which counts the calls,
  because that is the only place the difference shows.

  Worth knowing: the re-added event is registered with `throttleDroppable(2min)`,
  so an immediate retry is dropped by the throttle anyway. The same is true of
  `UpdateStoriesUserEvent`. The retry is decorative in both — correcting which
  flow it names is the fix here; making retries actually run is a separate
  question.
- **The inbox guarded "replace, do not append" twice.** The redundant ternary in
  the success branch is gone; the reset at the top of the handler is now the one
  guard, and it is mutation-checked.

### Ledger wording that is not a defect

- **`VerifyOtpInProfileEvent` ignores the phone it was sent.** The response
  carries `phone` next to `id_token`, and the ledger expects the event to store
  it. It must not. `profile_personal_info_page.dart:443` dispatches
  `UpdateProfileEvent` the moment this verification succeeds, and
  `_onUpdateProfileEvent` stores the phone from the **server's** answer. Storing
  it at verification time would record a number the account does not have yet —
  and if the profile update then failed, the app would hold a phone the backend
  never accepted, which also flips `marketGO` host routing. The test in
  `test/features/authentication/verify_otp_test.dart` pins the correct
  behaviour; the ledger line is the thing that is wrong.

## Reported, not pinned

These have no test yet, for the reason given.

- **A rejected refresh token costs a 20-second hang.** When the market refresh
  endpoint itself answers 401, the 401 goes back through `LoggerInterceptor`,
  which asks `TokenRefreshCoordinator` for a market refresh. The coordinator sees
  one already running and hands back its pending future — the future that the
  waiting handler is itself supposed to complete. The two only come apart when the
  coordinator's own 20-second timeout fires, and only then does the guest-session
  recovery start. Pinning it costs twenty real seconds per suite run, so it is
  written up here instead; see the note in
  `test/features/authentication/staying_in_test.dart`.
- **`Country.fromJson` casts `phonecode` straight into an `int?`.** A server that
  sent it as a string would throw inside the list build and take the whole
  allowed-countries answer down, leaving the country picker empty with no error
  the user can act on. No test, because inventing a server shape that has not been
  observed would pin a guess rather than a behaviour.

## Where the ledger and the code disagree

Three wave-02 scenarios describe something the code does not do. Each is covered
by a test of what the code *actually* does, with the divergence written into the
test file:

| Ledger says | The code does |
|-------------|---------------|
| "`SendOtpEvent` sets the timer flag so the resend button locks" | The flag is written by the OTP screen (`verify_otp.dart:74`) and only drives the countdown label. What stops a second request is the bloc's `throttleDroppable(10s)` on `SendOtpEvent`. |
| "`CreateUserEvent` creates the market account" | It creates the **chat** account — its use case is the only one in `AuthBloc` that takes a `ChatRepository`. The market account is created by the sign-up endpoint. |
| "hydrated `toJson`/`fromJson` round-trips" under **AuthBloc contract** | `AuthBloc` is a plain `Bloc` and persists nothing. The round-trip is written against `HomeBloc`, which is the bloc that does — `test/features/home/home_state_hydration_test.dart`. |
