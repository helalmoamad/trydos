# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Trydos is a Flutter (Dart SDK `>=3.8.0 <4.0.0`) mobile app combining a marketplace, real-time chat/calls (Agora via webview + CallKit), and stories. UI text is heavily in Arabic; the app is multilingual and RTL-aware.

## Commands

```bash
flutter pub get                                    # install dependencies
flutter run                                         # run on connected device/emulator
flutter analyze                                     # static analysis (lint rules in analysis_options.yaml)
flutter build apk / flutter build ios               # release builds

# Code generation (json_serializable, injectable, *.g.dart) — run after editing any
# annotated model or DI registration:
sh gen.sh        # == dart run build_runner build --delete-conflicting-outputs

# Regenerate localization keys after editing assets/languages/*.json:
sh keys.sh       # == flutter pub run easy_localization:generate -S assets/languages -f keys -o locale_keys.g.dart

# Integration tests live in integration_test/ and run on a device, not the unit harness:
flutter test integration_test/home/get_home_data_success_test.dart   # single test
flutter test integration_test                                         # all
flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/<file>.dart
```

Note: `.env` (loaded via `flutter_dotenv`) is required at runtime — it holds all server base URLs and API keys (MARKET_URL, CHAT_URL, STORY_URL, WALLET_URL, ELASTIC_URL, MEDIA_SERVER_URL, CLOUDINARY_*, SENTRY_DNS, Gemini key, etc.). Several dependencies are pulled from custom forks on GitHub (see `pubspec.yaml`).

## Architecture

**Clean Architecture + feature-first.** Each feature in `lib/features/<feature>/` is split into `data/` (data_sources, models, repositories), `domain/` (repositories, usecases), and `presentation/` (manager = BLoCs, pages, widgets). Features: `app`, `authentication`, `calls`, `chat`, `dashBoard`, `feed_back`, `home`, `search`, `story`. The `home` feature is by far the largest and holds the entire marketplace (products, cart, orders, addresses, comments).

**Dependency injection** — `get_it` + `injectable`. `configureDependencies()` (in `lib/core/di/di_container.dart`) runs `$initGetIt` generated into `di_container.config.dart`. Register new injectables with annotations and re-run `gen.sh`. `AppModule` provides the shared `Dio`, `Logger`, `SharedPreferences`, and `PrefsRepository`. Resolve anywhere via `GetIt.I<T>()`.

**State management** — `flutter_bloc` with `hydrated_bloc` for persistence. All app-wide BLoCs are registered as singletons in DI and provided once in `lib/service/service_provider.dart` (`ServiceProvider` → `MultiBlocProvider`). BLoC states are serialized (`*_state.g.dart` via json_serializable) for hydration — be careful changing state shape (schema migration). `lib/service/bloc_observer.dart` logs events/transitions.

**Networking** — custom layer over `Dio` in `lib/core/api/`. Multiple backends are modeled by the `ServerName` enum (`detect_server.dart`): chat, market, stories, location, cloudinary, gemini, elastic, dashBoard, webApp, comment, wallet, mediaServer. `getBaseUriForSpecificServer()` maps each to a base URI from the `*_url_routes.dart` config classes (in `lib/common/constant/configuration/`), whose base URLs come from `.env` and can be overridden at runtime via `PrefsRepository` (see `fetchServersUrlsFromSharedPreference()` in `main.dart`). `BaseApi<T>` (base_api.dart) auto-injects per-server headers: Bearer token (per server via `getServerToken`), `country`, `lang`, `User-Agent`, and special headers like `X-Seller-ID` (dashBoard) / `original-user-id` (elastic). Request method classes — `GetClient`, `PostClient`, `PutClient`, `DeleteClient` in `lib/core/api/methods/` — each extend `BaseApi`, take a `RequestConfig<T>` with endpoint + `fromJson`, and return the parsed model. Errors flow through `HandlingExceptionRequest` and `dartz` `Either<Failure, T>` (`lib/core/error/`, `lib/core/use_case/`). `MyHttpOverrides` disables bad-cert checks.

**Models** — `json_serializable`. Every model has a generated `*.g.dart` sibling; edit the source `.dart` then run `gen.sh`. Do not hand-edit `*.g.dart` or `*.config.dart`.

**Routing** — `go_router` in `lib/routes/` (`GRouter.router`, routes defined in `router_config.dart`). A global `navigatorKey` (in `main.dart`) is used for navigation from outside the widget tree (notifications, calls). Navigator observers wire up BotToast, Sentry, and Firebase Analytics. `lib/base_page.dart` is the main shell after splash.

**Localization** — `easy_localization`, JSON files in `assets/languages/` (`en-US`, `ar-SY`, `ku-IQ`, `tr-TR`). Keys are generated into `lib/generated/locale_keys.g.dart`. Kurdish (`ku`) is handled as a special case layered on Arabic — see `LanguageService` (`isKurdish`) and `ku_fallback_localizations.dart`. Keep all four language files in sync when adding keys.

**Notifications & calls** — `firebase_messaging` background handler `_firebaseMessagingBackgroundHandler` in `main.dart` is the entry point for push events; it branches on a `type` field (VideoCallEvent, VoiceCallEvent, RefuseCallEvent, ChannelReceivedEvent, etc.) and drives `CallsBloc`/`ChatBloc` and CallKit (`flutter_callkit_incoming`). This handler runs in a separate isolate, so it re-initializes hydrated storage, dotenv, and DI via the `is*Initialized` guard flags. Calls themselves run through an Agora webview (`features/calls`).

**`main.dart`** is large and does heavy ordered initialization (hydrated storage → dotenv → DI → notifications → Sentry → `runApp`). Order matters; preserve it. Sentry wraps `runApp`; `DevicePreview` is present but disabled.

## Conventions

- Lint rules (analysis_options.yaml) enforce `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `use_key_in_widget_constructors`, `prefer_final_fields`, `avoid_unnecessary_containers`, `avoid_redundant_argument_values`. Run `flutter analyze` before considering changes done.
- The repo root contains many `*_REPORT.md` / analysis markdown files documenting past performance & caching investigations — historical notes, not active specs.
- There is a typo baked into the source tree: the domain layer directory is `lib/core/domin/` (not `domain`). Match existing paths.
- Keep business logic in BLoCs/repositories, not widgets. Always handle loading/success/empty/error states (the `.github/copilot-instructions.md` merge checklist is the de-facto review gate).
- Performance matters: this is an image- and list-heavy app with custom precaching (`PreCachingImageBloc`) and cache management. Avoid expensive work in `build`, prefer const, split widgets to limit rebuilds.
