# App Version Update — Full Implementation Guide

This file describes the "a new version is available" feature of the Trydos app,
so that it can be added to **another Flutter project that has none of it**.

**To the agent reading this:** you have everything you need here. Do not ask
the user any question. Every choice has a decision below. When the project in
front of you is different from what this file expects, follow the "if the
project has X / if not" rules. At the end, report what you did (see §12).

---

## 1. What the feature does

1. While the **splash screen** is showing, the app calls the backend endpoint
   `startingSettings`.
2. The response gives the **minimum app version** the backend accepts, one
   value for Android and one for iOS.
3. The app compares that number with its own version number, a constant in
   `main.dart`.
4. If the app's version is lower, a dialog opens **right away, above
   everything**. There are two kinds of dialog:
   - **Optional update:** the user can press "Not now" and keep using the app.
   - **Mandatory update:** no "Not now" button, the back button does nothing,
     and tapping outside does nothing. The user can only go to the store.
5. "Update now" opens **Google Play on Android** and the **App Store on iOS**.

---

## 2. The app's own version number — `main.dart`

Add this top-level constant to `lib/main.dart`, outside any class:

```dart
/// The version number the backend compares with `android_min_version` /
/// `ios_min_version` from `startingSettings`.
///
/// This is NOT read from pubspec.yaml or the build number. Change it by hand
/// in every release:
///   - normal release (the user may skip it):      +1         (100 -> 101)
///   - breaking release (old builds must stop):    next hundred (1xx -> 200)
int applicationVersion = 100;
```

- In Trydos the value is `150`. It has nothing to do with `pubspec.yaml`
  (Trydos's pubspec says `version: 1.0.0+7`).
- **In the new project, use `100`.** This is the first release that has the
  feature. If the project already has a constant with this role (search for
  `applicationVersion`, `appVersion`, `minVersion`), reuse it and keep its
  value.
- The hundreds digit has a meaning (see §4). Keep this numbering scheme.

---

## 3. The backend contract

### 3.1 Request

| | |
|---|---|
| Method | `GET` |
| Path | `api/v1/mobile/home/startingSettings` |
| Query params | none |
| Body | none |
| Auth | not needed. Send the project's normal default headers. If the user is logged in and the client adds a token on its own, that is fine too. |

**Only the path is given here.** Join it to **this project's own base URL**, in
the same way the project's other requests are built. Use the project's
existing HTTP client, interceptors and error handling. If the project has an
endpoints/routes constants file, add the path there.

### 3.2 Response

```json
{
  "isSuccessful": true,
  "hasContent": true,
  "code": 200,
  "message": "",
  "detailed_error": null,
  "data": {
    "starting-setting": {
      "android_min_version": 150,
      "ios_min_version": 150,

      "decimal_point_settings": "...",
      "shipping_cost": "...",
      "shipping_duration_days": "...",
      "notificationTypes": [],
      "languages": [],
      "order_group_statuses": [],
      "order_statuses": []
    }
  }
}
```

**Read only these two fields:**

| Field | Path | Type |
|---|---|---|
| Android minimum | `data["starting-setting"]["android_min_version"]` | int (can be null) |
| iOS minimum | `data["starting-setting"]["ios_min_version"]` | int (can be null) |

Notes:
- The key is `starting-setting`, **with a hyphen**.
- The other fields exist but have nothing to do with this feature. If the
  project already has a model for this response, add the two fields to it.
  Otherwise, don't build a full model. Read the two fields as shown in §7.1.
- Accept the number as `int`, `double` or numeric `String`, and turn it into
  `int`. Anything else counts as `null`.
- The request counts as failed when: the HTTP status is not 2xx,
  `isSuccessful == false`, the network fails, or JSON parsing fails.
  **A failed request never blocks the app. It shows no dialog.**
- Do **not** cache the result for this check. Only a fresh response decides.

---

## 4. Deciding: no update, optional, or mandatory

### 4.1 Which minimum to use

Use **the field of the platform the app is running on**:
- Android → `android_min_version`
- iOS → `ios_min_version`

### 4.2 The rule

```
min      = the platform's field from §4.1
current  = applicationVersion

if min == null           -> NO UPDATE (skip the check fully)
if current >= min        -> NO UPDATE
if min ~/ 100 > current ~/ 100  -> MANDATORY
else                     -> OPTIONAL
```

In words: **only the hundreds digit decides whether the user can skip.** If the
backend asks for a higher hundreds digit than the app has, the installed
version "no longer works", so the update is mandatory. If only the last two
digits are higher, the update is optional.

### 4.3 Examples

| `applicationVersion` | min from backend | Result |
|---|---|---|
| 150 | null | no update |
| 150 | 150 | no update |
| 150 | 120 | no update |
| 150 | 151 | optional |
| 150 | 199 | optional |
| 55 | 76 | optional |
| 150 | 200 | **mandatory** |
| 55 | 120 | **mandatory** |
| 250 | 300 | **mandatory** |
| 100 | 301 | **mandatory** |

How the backend team uses it:
- Suggest an update: set the min to a higher number **in the same hundred**.
- Force an update: set the min to **the next hundred or more**.

### 4.4 One on-purpose difference from Trydos

Trydos compares with `max(android_min_version, ios_min_version)` and skips when
**either** field is null. That means an Android user can be asked to update
only because the iOS number went up. **Do not copy that.** Use the current
platform's field only (§4.1). Everything else in the rule is the same.

---

## 5. When and where the dialog is shown

### 5.1 Trydos today (for context only — do not copy the placement)

In Trydos, the request is sent late: after the home categories load. The dialog
is opened from `base_page.dart` in two places: a `BlocListener` that fires when
the settings status changes to `success`, and a check right after the page
mounts. A small future chain (`_enqueueStartupDialog`) makes sure two startup
dialogs never open on top of each other.

### 5.2 What you build: request during splash, dialog on top of everything

1. **Global navigator key.** If the project has none, create one and pass it to
   the app's root navigator:
   - `MaterialApp(navigatorKey: rootNavigatorKey, ...)`
   - GoRouter: `GoRouter(navigatorKey: rootNavigatorKey, ...)`
   - GetX: use `Get.key` (it already exists).
   - auto_route: use `appRouter.navigatorKey`.
   If a global key already exists, use it. Don't create a second one.
2. **Send the request as the splash screen starts** (in `initState` or the
   splash bloc/controller's start event), **at the same time as** the splash's
   other work. Do not wait for the other work to finish first.
3. **The splash waits for the update check before it leaves**, but at most
   **6 seconds** for the network:
   - request fails → leave splash normally;
   - no update → leave splash normally;
   - **optional** → show the dialog on splash. Leave splash **after the user
     closes the dialog** ("Not now" or "Update now");
   - **mandatory** → show the dialog on splash and **never leave splash**. The
     app stays blocked behind the dialog;
   - **6 seconds pass with no answer** → leave splash normally. If the answer
     comes later, show the dialog **over whatever screen is open by then**,
     using the root navigator key.
4. Always open the dialog with the **root navigator**
   (`rootNavigatorKey.currentContext`, `useRootNavigator: true`). Then it sits
   above every page, bottom sheet and nested navigator.
5. **Show it at most once per app run.** Use a static `bool` guard.
6. The update dialog comes **before any other startup dialog** (login expired,
   permissions, onboarding, rating). Splash waits for it, so dialogs that
   appear after splash naturally come after it. If the project opens startup
   dialogs **on** the splash screen, move them after
   `VersionUpdate.checkOnSplash()` completes.

Why the splash must wait: if the splash calls `pushReplacement` while the
dialog is open, it replaces the dialog route, not the splash. The dialog would
disappear. Waiting avoids this.

---

## 6. The dialog design

Two designs: `CupertinoAlertDialog` on iOS, `AlertDialog` on Android. Pick with
`Platform.isIOS`. Both are opened with `barrierDismissible: false`.

Shared colors:

| Name | Value | Used for |
|---|---|---|
| Blue | `0xFF007AFF` | icon, Android "Update now" background |
| Title | `0xFF1D1D1F` | title text |
| Grey | `0xFF6E6E73` | message text, "Not now" text |

Icon: `Icons.system_update_rounded`.

Text widget: if the project has its own text wrapper (for the app font or text
scaling), use it for the title and message. Otherwise use `Text`.

### 6.1 iOS — `CupertinoAlertDialog`

- **title**: `Column`
  - `Icon(Icons.system_update_rounded, size: 40, color: Blue)`
  - `SizedBox(height: 12)`
  - title text: `fontSize 17`, `FontWeight.w600`, color Title
- **content**: `Column`
  - message text: `fontSize 13`, color Grey, `height 1.3`,
    `textAlign: TextAlign.center`
  - `SizedBox(height: 8)`
- **actions**: one `Row`
  - only if **optional**: `Expanded(CupertinoButton)` "Not now", text
    `fontSize 16`, color Grey. It closes the dialog.
  - always: `Expanded(CupertinoButton.filled)` "Update now", text
    `fontSize 16`, `FontWeight.w600`.

### 6.2 Android — `AlertDialog`

- **shape**: `RoundedRectangleBorder(borderRadius: 16)`
- **title**: `Column`
  - `Container` with `padding: EdgeInsets.all(12)`,
    `BoxDecoration(color: Blue with opacity 0.12, shape: BoxShape.circle)`,
    holding `Icon(Icons.system_update_rounded, size: 40, color: Blue)`
  - `SizedBox(height: 12)`
  - title text: `fontSize 18`, `FontWeight.w600`, color Title
- **content**: `Column`
  - message text: `fontSize 14`, color Grey, `height 1.4`,
    `textAlign: TextAlign.center`
  - `SizedBox(height: 4)`
- **actions**: one `Row`
  - only if **optional**:
    - `Expanded(TextButton)` "Not now". Style: `padding vertical 16`, radius 8.
      Text `fontSize 16`, `FontWeight.w500`, color Grey. It closes the dialog.
    - `SizedBox(width: 12)`. Don't leave this gap when mandatory.
  - always: `Expanded(ElevatedButton)` "Update now". Style: `padding vertical
    16`, `backgroundColor` Blue, `foregroundColor` white, radius 8,
    `elevation 2`. Text `fontSize 16`, `FontWeight.w600`.

### 6.3 Behavior (both platforms)

| | Optional | Mandatory |
|---|---|---|
| Title | `new_update_available` | `new_update_available` |
| Message | `newer_version_available_message` | `current_version_no_longer_works_message` |
| "Not now" button | shown, closes dialog | **not built** |
| Tap outside | nothing (`barrierDismissible: false`) | nothing |
| Android back button | closes dialog | **blocked** |
| "Update now" | closes dialog, then opens the store | opens the store, **dialog stays open** |

The mandatory dialog stays open behind the store. When the user comes back
without updating, they still see it and cannot use the old version.

Block the back button with `PopScope(canPop: !isMandatory, child: dialog)`. If
the project's Flutter is older than 3.12 (no `PopScope`), use
`WillPopScope(onWillPop: () async => !isMandatory, child: dialog)`.

In RTL languages (Arabic, Kurdish) the `Row` flips on its own, which is
correct. Don't force a direction.

---

## 7. Reference implementation

Put it in one feature file, for example
`lib/core/version_update/version_update.dart`. Match the project's folder
layout if it has a clear one (for example `lib/features/...`). Change the
imports and the translation call (`.tr()`) to match the project (§8).

### 7.1 Code

```dart
import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:<app>/main.dart' show applicationVersion;
// import 'package:<app>/.../navigator_key.dart' show rootNavigatorKey;
// import 'package:<app>/generated/locale_keys.g.dart';

enum UpdateKind { none, optional, mandatory }

class VersionUpdate {
  VersionUpdate._();

  static const String androidPackageId = '<applicationId from android/app/build.gradle>';

  /// Numeric App Store id ("id1234567890" -> "1234567890"). Empty = unknown (§9.2).
  static const String appStoreId = '';

  /// iOS bundle id, used only when [appStoreId] is empty.
  static const String iosBundleId = '<PRODUCT_BUNDLE_IDENTIFIER of the Runner target>';

  static bool _dialogShown = false;

  // ---------------------------------------------------------------- decision

  /// Pure. Only the hundreds digit decides if the user may skip:
  /// 150 -> 151..199 optional, 150 -> 200+ mandatory, null -> none.
  static UpdateKind decide({required int current, required int? minVersion}) {
    if (minVersion == null || current >= minVersion) return UpdateKind.none;
    return minVersion ~/ 100 > current ~/ 100
        ? UpdateKind.mandatory
        : UpdateKind.optional;
  }

  /// Pure. Reads this platform's minimum from the `startingSettings` body.
  static int? readMinVersion(Object? body, {required bool isIOS}) {
    if (body is! Map) return null;
    if (body['isSuccessful'] == false) return null;
    final data = body['data'];
    if (data is! Map) return null;
    final setting = data['starting-setting'];
    if (setting is! Map) return null;
    final raw = setting[isIOS ? 'ios_min_version' : 'android_min_version'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  // ----------------------------------------------------------------- network

  /// Never throws. Any failure means "no update".
  static Future<UpdateKind> _fetchUpdateKind() async {
    try {
      // Use the project's own client + base URL. Path only:
      //   GET api/v1/mobile/home/startingSettings
      final Object? body = await /* projectApiClient.get(
          'api/v1/mobile/home/startingSettings') -> decoded JSON body */ null;
      final int? min = readMinVersion(body, isIOS: Platform.isIOS);
      return decide(current: applicationVersion, minVersion: min);
    } catch (_) {
      return UpdateKind.none;
    }
  }

  // ------------------------------------------------------------------ splash

  /// Call once when splash starts, together with splash's other work. Leave
  /// splash only after this completes.
  ///  - none / failed:   completes right away.
  ///  - optional:        completes when the user closes the dialog.
  ///  - mandatory:       never completes, so the app stays behind the dialog.
  ///  - no answer after [waitAtMost]: completes; a late answer still shows the
  ///    dialog over whatever screen is open by then.
  static Future<void> checkOnSplash({
    Duration waitAtMost = const Duration(seconds: 6),
  }) async {
    final Future<UpdateKind> request = _fetchUpdateKind();
    final UpdateKind kind;
    try {
      kind = await request.timeout(waitAtMost);
    } on TimeoutException {
      unawaited(request.then((late) {
        if (late != UpdateKind.none) showUpdateDialog(late);
      }));
      return;
    }
    if (kind == UpdateKind.none) return;
    await showUpdateDialog(kind);
  }

  // ------------------------------------------------------------------ dialog

  static Future<void> showUpdateDialog(UpdateKind kind) async {
    if (kind == UpdateKind.none || _dialogShown) return;
    // Wait for a frame so the root navigator is surely mounted.
    if (rootNavigatorKey.currentContext == null) {
      await WidgetsBinding.instance.endOfFrame;
    }
    final BuildContext? rootContext = rootNavigatorKey.currentContext;
    if (rootContext == null) return;
    _dialogShown = true;

    final bool isMandatory = kind == UpdateKind.mandatory;
    await showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) {
        final String title = LocaleKeys.new_update_available.tr();
        final String message = isMandatory
            ? LocaleKeys.current_version_no_longer_works_message.tr()
            : LocaleKeys.newer_version_available_message.tr();
        final String updateLabel = LocaleKeys.update_now.tr();
        final String notNowLabel = LocaleKeys.not_now.tr();

        void onUpdate() {
          // Mandatory: keep the dialog open behind the store page.
          if (!isMandatory) Navigator.of(dialogContext).pop();
          openStore();
        }

        void onNotNow() => Navigator.of(dialogContext).pop();

        return PopScope(
          canPop: !isMandatory,
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Column(
                    children: [
                      const Icon(Icons.system_update_rounded,
                          size: 40, color: Color(0xFF007AFF)),
                      const SizedBox(height: 12),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F))),
                    ],
                  ),
                  content: Column(
                    children: [
                      Text(message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6E6E73),
                              height: 1.3)),
                      const SizedBox(height: 8),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        if (!isMandatory)
                          Expanded(
                            child: CupertinoButton(
                              onPressed: onNotNow,
                              child: Text(notNowLabel,
                                  style: const TextStyle(
                                      color: Color(0xFF6E6E73), fontSize: 16)),
                            ),
                          ),
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: onUpdate,
                            child: Text(updateLabel,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.system_update_rounded,
                            size: 40, color: Color(0xFF007AFF)),
                      ),
                      const SizedBox(height: 12),
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFF1D1D1F))),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFF6E6E73),
                              height: 1.4,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        if (!isMandatory) ...[
                          Expanded(
                            child: TextButton(
                              onPressed: onNotNow,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(notNowLabel,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6E6E73))),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onUpdate,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            child: Text(updateLabel,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ------------------------------------------------------------------- store

  /// Google Play on Android, App Store on iOS. Tries the store app first,
  /// then the web page. Never throws.
  static Future<void> openStore() async {
    final List<Uri> candidates = Platform.isIOS
        ? [await _appStoreUri()]
        : [
            Uri.parse('market://details?id=$androidPackageId'),
            Uri.parse(
                'https://play.google.com/store/apps/details?id=$androidPackageId'),
          ];
    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } catch (_) {}
    }
    try {
      await launchUrl(candidates.last, mode: LaunchMode.platformDefault);
    } catch (_) {}
  }

  static Future<Uri> _appStoreUri() async {
    if (appStoreId.isNotEmpty) {
      return Uri.parse('https://apps.apple.com/app/id$appStoreId');
    }
    // No id in the code: ask Apple by bundle id (public, no key needed).
    //   GET https://itunes.apple.com/lookup?bundleId=<iosBundleId>
    //   -> results[0].trackViewUrl
    // Use the project's HTTP client WITHOUT its base URL or auth headers.
    // If it fails or returns no results, fall back to the Play Store link
    // (this is what Trydos does today while it is not on the App Store).
    return Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidPackageId');
  }
}
```

In `_fetchUpdateKind`, replace the placeholder `null` with the project's real
request. In `_appStoreUri`, write the real lookup call if `appStoreId` is empty.
If the project uses `withValues(alpha: 0.12)` instead of `withOpacity` (newer
Flutter marks `withOpacity` as deprecated), follow the project.

### 7.2 Splash integration

```dart
@override
void initState() {
  super.initState();
  _start();
}

Future<void> _start() async {
  await Future.wait([
    _existingSplashWork(),          // whatever splash already did
    VersionUpdate.checkOnSplash(),  // never completes when mandatory
  ]);
  if (!mounted) return;
  _navigateNext();                   // the splash's existing navigation
}
```

- If the splash already navigates at the end of its own work, move that
  navigation to after `Future.wait`, as shown above.
- If splash logic lives in a bloc/cubit/controller, do the same there: start
  `checkOnSplash()` in the start event, and emit the "go next" state only
  after both futures complete.
- If the project has **no splash screen**, call
  `await VersionUpdate.checkOnSplash()` in the first screen's `initState`,
  before its first navigation or startup dialog.

---

## 8. Translations

Five keys. Add them to **every language the project supports**. The languages
below are Trydos's four: `en`, `ar`, `ku` (Sorani Kurdish, `ku-IQ`), `tr`. If
the project supports a language not in this list, use the English text for
it. If the project lacks one of these languages, don't add that language.

| Key | en | ar | ku | tr |
|---|---|---|---|---|
| `new_update_available` | New Update Available | تحديث جديد متاح | نوێکردنەوەی نوێ بەردەستە | Yeni Güncelleme Mevcut |
| `newer_version_available_message` *(optional update)* | There is a newer version of app available please update it now. | هناك إصدار أحدث من التطبيق متاح، يرجى تحديثه الآن. | وەشانێکی نوێتری بەرنامە بەردەستە، تکایە ئێستا نوێی بکەوە. | Uygulamanın daha yeni bir sürümü mevcut, lütfen şimdi güncelleyin. |
| `current_version_no_longer_works_message` *(mandatory update)* | The version you have no longer works. Please update. | النسخة التي لديكم لم تعد تعمل، يرجى التحديث. | ئەو وەشانەی لەلای ئێوەیە چیتر کار ناکات، تکایە نوێی بکەنەوە. | Kullandığınız sürüm artık çalışmıyor, lütfen güncelleyin. |
| `update_now` | Update Now | حدث الآن | ئێستا نوێ بکەوە | Şimdi Güncelle |
| `not_now` | Not Now | ليس الآن | نا ئەمڕۆ | Şimdi Değil |

Copy-ready JSON, one block per language file:

```json
"new_update_available": "New Update Available",
"newer_version_available_message": "There is a newer version of app available please update it now.",
"current_version_no_longer_works_message": "The version you have no longer works. Please update.",
"update_now": "Update Now",
"not_now": "Not Now"
```

```json
"new_update_available": "تحديث جديد متاح",
"newer_version_available_message": "هناك إصدار أحدث من التطبيق متاح، يرجى تحديثه الآن.",
"current_version_no_longer_works_message": "النسخة التي لديكم لم تعد تعمل، يرجى التحديث.",
"update_now": "حدث الآن",
"not_now": "ليس الآن"
```

```json
"new_update_available": "نوێکردنەوەی نوێ بەردەستە",
"newer_version_available_message": "وەشانێکی نوێتری بەرنامە بەردەستە، تکایە ئێستا نوێی بکەوە.",
"current_version_no_longer_works_message": "ئەو وەشانەی لەلای ئێوەیە چیتر کار ناکات، تکایە نوێی بکەنەوە.",
"update_now": "ئێستا نوێ بکەوە",
"not_now": "نا ئەمڕۆ"
```

```json
"new_update_available": "Yeni Güncelleme Mevcut",
"newer_version_available_message": "Uygulamanın daha yeni bir sürümü mevcut, lütfen şimdi güncelleyin.",
"current_version_no_longer_works_message": "Kullandığınız sürüm artık çalışmıyor, lütfen güncelleyin.",
"update_now": "Şimdi Güncelle",
"not_now": "Şimdi Değil"
```

How to add them depends on the project's localization system:

- **easy_localization** (Trydos uses it): add the keys to each JSON file in
  the translations folder (find it under `EasyLocalization(path: ...)`). If
  the project has a generated `locale_keys.g.dart`, **regenerate** it with the
  project's own script (look for `keys.sh`, `gen.sh`, a Makefile or README).
  If there is no script, run
  `dart run easy_localization:generate -S <translations folder> -f keys -O lib/generated -o locale_keys.g.dart`.
  Never edit the generated file by hand. If there are no generated keys, use
  plain strings: `'update_now'.tr()`.
- **flutter gen-l10n (ARB files)**: add the keys to each `.arb` file in
  camelCase (`newUpdateAvailable`, `newerVersionAvailableMessage`,
  `currentVersionNoLongerWorksMessage`, `updateNow`, `notNow`), run
  `flutter gen-l10n`, and use `AppLocalizations.of(dialogContext)!.updateNow`.
- **GetX translations**: add the keys to each language map and use
  `'update_now'.tr`.
- **No localization system**: put a
  `Map<String, Map<String, String>>` with the four languages inside
  `version_update.dart`. Pick by
  `Localizations.localeOf(context).languageCode`, and fall back to `en`.

Name clashes: if a key with the same name already exists **with the same
English meaning**, reuse it. If it exists with a different meaning, add ours
with the prefix `version_update_` (for example `version_update_not_now`).

---

## 9. Platform setup

### 9.1 Packages

- `url_launcher` — required. If it is missing, add the newest version that
  works with the project's Dart SDK (`flutter pub add url_launcher`).
- Do **not** add `store_redirect` or `package_info_plus`. They are not needed.

### 9.2 Store identifiers

- **Android package id:** read `applicationId` from
  `android/app/build.gradle` or `android/app/build.gradle.kts`, inside
  `defaultConfig`. If there are flavors, use the production flavor's
  `applicationId` (with any `applicationIdSuffix` added to it). Trydos uses
  `com.trydos.www`.
- **iOS App Store id:** search the repository for `apps.apple.com`,
  `itunes.apple.com`, `appStoreId`, `app_store_id`, `iosAppId`. If you find a
  numeric id, put it in `appStoreId`. If you don't, leave it empty: the code
  then uses the bundle-id lookup, and after that the Play link (§7.1).
- **iOS bundle id:** `PRODUCT_BUNDLE_IDENTIFIER` of the **Runner** target
  (Release configuration) in `ios/Runner.xcodeproj/project.pbxproj`. Not
  `RunnerTests`.

### 9.3 AndroidManifest

Add this inside `<manifest>` (next to `<application>`, not inside it) in
`android/app/src/main/AndroidManifest.xml`. If a `<queries>` block already
exists, add only the missing `<intent>` entries to it:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="market" />
    </intent>
</queries>
```

### 9.4 iOS

Nothing needed. `https://apps.apple.com/...` opens the App Store app. The code
never calls `canLaunchUrl`, so `LSApplicationQueriesSchemes` is not needed.

### 9.5 Things Trydos does that you should NOT copy

- Trydos wraps each launch in `canLaunchUrl(...)` and throws when it returns
  false. On Android 11+ without `<queries>`, that returns false, and the
  fallback inside `catch` throws again. The code in §7.1 calls `launchUrl`
  directly and catches everything.
- Trydos sends the request only after the home categories load. You send it
  during splash (§5.2).
- Trydos uses `max(android, ios)`. You use the current platform's field (§4.4).

---

## 10. Tests

Add unit tests for the two pure functions, for example in
`test/core/version_update/version_update_test.dart`:

- `decide`: every row of the table in §4.3. Also `current == min` → none.
- `readMinVersion`:
  - a normal body → the right field for `isIOS: true` and for `isIOS: false`;
  - the value as `int`, `double` (`150.0`), `String` (`"150"`) → `150`;
  - `"abc"`, `null`, a missing `data`, a missing `starting-setting`, a body
    that is not a `Map` → `null`;
  - `isSuccessful: false` → `null`.

Run `flutter analyze` and `flutter test`. Both must pass.

---

## 11. Manual check (for the report, not required to run)

Set `applicationVersion` by hand for a moment. Don't commit this change.

| `applicationVersion` | backend min | Expected |
|---|---|---|
| 100 | 100 | splash goes on, no dialog |
| 99 (with min 100) | 100 | hundreds 1 > 0 → **mandatory**: no "Not now", back does nothing, app stays on splash, "Update now" opens the store and the dialog stays |
| 100 | 101 | **optional**: "Not now" closes the dialog and the app goes on |
| any | airplane mode | splash goes on after ≤ 6 s, no dialog |

Also check the dialog in Arabic (RTL) and on both platforms.

---

## 12. Acceptance checklist and final report

Done means all of these are true:

- [ ] `int applicationVersion = 100;` exists at the top level of `lib/main.dart`
      (or an existing constant with this role is reused).
- [ ] `GET api/v1/mobile/home/startingSettings` is sent with the project's own
      base URL and client, when splash starts.
- [ ] Only `data["starting-setting"]["android_min_version"]` /
      `["ios_min_version"]` are read, for the current platform.
- [ ] The rule in §4.2 is implemented and unit-tested.
- [ ] Failure, null, or timeout never blocks the app and never shows a dialog
      (a late success still shows it).
- [ ] The dialog opens on the root navigator, above everything, at most once
      per run.
- [ ] The iOS and Android designs match §6 exactly. Mandatory has no
      "Not now", no back, no outside tap, and stays open after "Update now".
- [ ] Optional: the splash goes on after the dialog closes. Mandatory: the
      splash never goes on.
- [ ] "Update now" opens Google Play on Android and the App Store on iOS.
- [ ] All 5 keys exist in every supported language, and generated keys are
      regenerated, not hand-edited.
- [ ] `<queries>` added to the AndroidManifest.
- [ ] `flutter analyze` and `flutter test` pass.

At the end, tell the user in a short report:
1. the files you changed or created;
2. the Android package id and the iOS App Store id (or "lookup by bundle id")
   you used;
3. the `applicationVersion` value, and a reminder: **the backend must not set
   a min above this value** until the build is on the store, or users will
   see a mandatory update they cannot finish;
4. anything in this file you could not follow, and what you did instead.
