import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/service/language_service.dart';

/// سجلّ تشخيص حقل رقم الهاتف.
///
/// عطلٌ يظهر على جهاز واحد لا يمكن تتبّعه بالقراءة: نحتاج ما يصل **من لوحة
/// مفاتيح ذلك الجهاز بالذات**. فنكتب كل خطوة هنا، ويعرضها زرّ في صفحة
/// `SharedPreferencePage` لينسخها المستخدم ويرسلها.
///
/// يكتب في `SharedPreferences` مباشرةً لا عبر `PrefsRepository`: هذا سجلّ
/// مؤقّت للتشخيص، ولا ينبغي أن يدخل عقد التخزين الدائم.
class PhoneInputDiagnostics {
  PhoneInputDiagnostics._();

  static const String _key = 'phone_input_diagnostics';

  /// سقف الأسطر. السجلّ يُكتب مع **كل ضغطة حرف**، فبلا سقف يتضخّم بلا حدّ
  /// ويُبطئ التخزين.
  static const int _maxLines = 300;

  static SharedPreferences? get _prefs =>
      GetIt.I.isRegistered<SharedPreferences>()
      ? GetIt.I<SharedPreferences>()
      : null;

  /// يصف النصّ بمحارفه ورموزها.
  ///
  /// هذا جوهر التشخيص: محرف خفيّ (علامة اتجاه، مسافة غير فاصلة، رقم
  /// عربي-هندي) لا يظهر في أي لقطة شاشة، لكنه يظهر هنا برمزه.
  static String describe(String? text) {
    if (text == null) return 'null';
    if (text.isEmpty) return '""(فارغ)';
    final List<String> codes = text.runes
        .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
        .toList();
    return '"$text" [${codes.join(' ')}]';
  }

  /// يكتب ترويسة الجلسة: الجهاز واللغة ودولة الحساب.
  ///
  /// العطل يخصّ جهازاً واحداً، فبلا هذه البيانات لا نعرف ما يميّزه — ونضطرّ
  /// لإعادة التجربة لسؤاله عنها.
  static Future<void> startSession() async {
    log('================ جلسة جديدة ================');
    try {
      final DeviceInfoPlugin info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo android = await info.androidInfo;
        log(
          'DEVICE  Android ${android.version.release} (SDK ${android.version.sdkInt})  '
          '${android.manufacturer} ${android.model}',
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await info.iosInfo;
        log('DEVICE  iOS ${ios.systemVersion}  ${ios.utsname.machine}');
      }
    } catch (e) {
      log('DEVICE  تعذّرت قراءة بيانات الجهاز: $e');
    }
    try {
      log(
        'LOCALE  platform=${Platform.localeName}  '
        'app=${LanguageService.languageCode}',
      );
    } catch (e) {
      log('LOCALE  تعذّرت القراءة: $e');
    }
    try {
      final PrefsRepository prefs = GetIt.I<PrefsRepository>();
      log(
        'ACCOUNT countryIso=${prefs.countryIso}  '
        'chosenIso=${prefs.userChoosedCountryIso}  '
        'available=${prefs.userCountryIsAvailable}',
      );
    } catch (e) {
      log('ACCOUNT تعذّرت القراءة: $e');
    }
  }

  /// هل رُكّب التقاط أخطاء الإطار؟ `FlutterError.onError` حقل ساكن واحد،
  /// فالتركيب مرّتين يمحو ما قبله.
  static bool _errorHookInstalled = false;

  /// يلتقط أخطاء بناء الودجتات ويكتبها في السجلّ.
  ///
  /// استثناءٌ داخل `build` لا يُسقط التطبيق: الإطار يستبدل الودجت بمربّع رمادي
  /// ويتابع. فالعطل الذي يُظهر «مربّعاً فارغاً مكان العلم» قد يكون استثناءً
  /// صامتاً — ولا سبيل لرؤيته على جهاز الزبون إلّا بهذا.
  ///
  /// يُسلسَل إلى المعالج السابق ولا يستبدله، فلا تنقطع تقارير Sentry.
  static void installErrorHook() {
    if (_errorHookInstalled) return;
    _errorHookInstalled = true;
    final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      log(
        'FLUTTER-ERROR  ${details.exceptionAsString()}'
        '${details.library != null ? '  [${details.library}]' : ''}',
      );
      final String stack = details.stack?.toString() ?? '';
      if (stack.isNotEmpty) {
        // أوّل ثلاثة أسطر تكفي لتحديد الموضع، والسجلّ محدود السعة.
        log('  ${stack.split('\n').take(3).join(' | ')}');
      }
      previous?.call(details);
    };

    // `FlutterError.onError` لا يرى الأخطاء غير المتزامنة: فشل تحميل أصل،
    // استثناء في `Future` بلا `catch`. وهذه بالضبط نوع ما قد يفشل عند تحميل
    // صورة علم. نُعيد `false` فلا نبتلع الخطأ عن بقية المعالجات.
    final bool Function(Object, StackTrace)? previousPlatform =
        PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      log('ASYNC-ERROR  $error');
      log('  ${stack.toString().split('\n').take(2).join(' | ')}');
      return previousPlatform?.call(error, stack) ?? false;
    };
  }

  static void log(String line) {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) return;
    final List<String> lines = prefs.getStringList(_key) ?? <String>[];
    final String stamp = DateTime.now().toIso8601String().substring(11, 23);
    lines.add('$stamp  $line');
    if (lines.length > _maxLines) {
      lines.removeRange(0, lines.length - _maxLines);
    }
    prefs.setStringList(_key, lines);
  }

  static String read() {
    final List<String> lines = _prefs?.getStringList(_key) ?? <String>[];
    if (lines.isEmpty) return 'لا يوجد سجلّ بعد.';
    return lines.join('\n');
  }

  static void clear() => _prefs?.remove(_key);
}
