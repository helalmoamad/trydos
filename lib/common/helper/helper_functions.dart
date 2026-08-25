import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';

import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../features/app/my_text_widget.dart';
import '../../generated/locale_keys.g.dart';
import '../../service/language_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant/design/assets_provider.dart';
import 'show_message.dart';
import 'package:trydos/common/helper/dev_log.dart';

final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

class HelperFunctions {
  static bool _versionDialogShown = false;

  /// نوع الوسائط مستنتجاً من امتداد الملف المحلي: `image` أو `video` أو
  /// `audio` أو `file`.
  ///
  /// الفحوص السابقة كانت تبحث عن المقطعين `image`/`video` داخل الرابط، وهو
  /// شكل روابط Cloudinary وحدها (`/image/upload/`). بعد التحويل إلى S3 صارت
  /// المقاطع بصيغة الجمع (`/images/test/`) فلم يطابقها شيء واختفت الوسائط.
  /// الامتداد المحلي لا يتأثّر بمصدر الرفع.
  static String mediaTypeOfPath(String localPath) {
    final String type = (lookupMimeType(localPath) ?? '').split('/').first;
    if (type == 'image' || type == 'video' || type == 'audio') return type;
    return 'file';
  }

  /// مدّة فيديو من ملف محلي، أو `null` إن تعذّرت قراءتها.
  ///
  /// `AssetEntity` القادم من المعرض يحمل `duration` جاهزة، أما منتقي الملفات
  /// فيرجع `File` مجرّداً بلا بيانات وصفية — فالسبيل الوحيد تهيئة مشغّل
  /// مؤقّتاً وقراءة مدّته ثم التخلّص منه فوراً.
  ///
  /// السقف الزمني ثانيتان: لا نحبس الواجهة على ملف عصيّ. وعند التعذّر نرجع
  /// `null` فيُسمح بالإرسال — أهون من منع فيديو صالح بسبب فشل قياس.
  static Future<Duration?> videoDurationOf(File file) async {
    final VideoPlayerController controller = VideoPlayerController.file(file);
    try {
      await controller.initialize().timeout(const Duration(seconds: 2));
      final Duration duration = controller.value.duration;
      return duration > Duration.zero ? duration : null;
    } catch (e) {
      devLog('failed to read video duration: $e');
      return null;
    } finally {
      await controller.dispose();
    }
  }
  static changeAppStatus(ThemeMode theme) {
    final color = theme == ThemeMode.dark
        ? const Color(0xFF191C1D)
        : const Color(0xFFFBFDFD);
    final brightness = theme == ThemeMode.light
        ? Brightness.dark
        : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: brightness,
      ),
    );
  }

  static Future<String> changeSvgColor(String svgPath, String newColor) async {
    String svgCode = await rootBundle.loadString(svgPath);

    svgCode = svgCode.replaceAll("CC3333", newColor.toUpperCase());
    return svgCode;
  }

  static Future<bool> urlLauncherApplication(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableDomStorage: false,
          enableJavaScript: false,
        ),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  /// Turns any string into a name that is safe to use as a file name.
  ///
  /// Every character outside `A-Z a-z 0-9 . _ -` becomes `_`, so a path
  /// separator can never survive. A name made only of dots (`.` or `..`) points
  /// at a directory instead of a file, so it is replaced too.
  static String safeFileName(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.isEmpty || RegExp(r'^\.+$').hasMatch(cleaned)) return 'file';
    return cleaned.length <= 120
        ? cleaned
        : cleaned.substring(cleaned.length - 120);
  }

  static Future<File> urlToFile(String imageUrl) async {
    // تحميل الصورة من الإنترنت
    final response = await http.get(Uri.parse(imageUrl));

    // الحصول على مسار التخزين المؤقت
    final documentDirectory = await getTemporaryDirectory();

    // إنشاء ملف مؤقت باسم فريد.
    // اسم الملف يأتي من رابط خارجي، لذلك يُنظَّف قبل الاستخدام حتى لا يخرج
    // المسار من مجلد التطبيق.
    final safeName = safeFileName(imageUrl.split('/').last);
    // nosemgrep: trydos-sec-path-from-interpolation -- safeFileName() strips separators and rejects dot-only names
    final file = File('${documentDirectory.path}/$safeName');

    // كتابة بيانات الصورة إلى الملف
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  static Future<bool> urlLauncherBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static String replaceDashAfterFirst(String input) {
    int firstDashIndex = input.indexOf('-');
    if (firstDashIndex == -1) {
      // لا يوجد "-"
      return input;
    }

    // البحث عن الظهور الثاني للمحرف "-"
    int secondDashIndex = input.indexOf('-', firstDashIndex + 1);
    if (secondDashIndex == -1) {
      // لا يوجد إلا "-" واحد
      return input;
    }

    // استبدال كل "-" بعد الظهور الأول بـ "_"
    StringBuffer result = StringBuffer();
    bool replacedSecondAndAfter = false;

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '-') {
        if (!replacedSecondAndAfter && i > firstDashIndex) {
          replacedSecondAndAfter = true;
        }
        if (replacedSecondAndAfter) {
          result.write('_');
        } else {
          result.write('-');
        }
      } else {
        result.write(input[i]);
      }
    }

    return result.toString();
  }

  static Locale getInitLocale() {
    // ignore: deprecated_member_use
    final devicelang = WidgetsBinding.instance.window.locale.languageCode;
    return _prefsRepository.language == null
        ? mpaLanguageCodeToLocale[devicelang] ?? defaultLocal
        : mpaLanguageCodeToLocale[_prefsRepository.language] ?? defaultLocal;
  }

  static Country getDefaultCountry() {
    // ignore: deprecated_member_use
    final deviceCountryCode = WidgetsBinding.instance.window.locale.countryCode;
    return countries.singleWhere(
      (element) => element.code == deviceCountryCode,
      orElse: () => defaultCountry,
    );
  }

  static Route createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getContactsFromDevice() async {
    final PermissionStatus permissionStatus = await Permission.contacts
        .request();
    List<Contact> contacts = [];

    if (permissionStatus == PermissionStatus.granted) {
      contacts = await FastContacts.getAllContacts();
    }

    devLog("🔍 إجمالي جهات الاتصال: ${contacts.length}");
    int i = 0;
    List<Contact> myContacts = [];
    for (Contact contact in contacts) {
      i = i + 1;

      if (contact.phones.isNotEmpty) {
        devLog("📞 ${contact.displayName}: ${contact.phones.length} رقم");
        contact.phones.forEach((element) {
          devLog("   - ${element.number}");
          myContacts.add(contact);
        });
      } else {
        devLog("❌ ${contact.displayName}: بدون أرقام هواتف");
      }
    }

    devLog(
      "📱 جهات الاتصال مع أرقام: ${myContacts.length}   ${contacts.length}",
    );

    String myPhoneNumber = '${GetIt.I<PrefsRepository>().myPhoneNumber ?? ""}';
    if (!(myPhoneNumber.startsWith("+"))) {
      myPhoneNumber = "+" + myPhoneNumber;
    }
    devLog("📞 رقم المستخدم: $myPhoneNumber");
    devLog("📏 طول رقم المستخدم: ${myPhoneNumber.length}");

    String dialCode = countries
        .firstWhere(
          (element) => myPhoneNumber.startsWith(element.dialCode),
          orElse: () => defaultCountry,
        )
        .dialCode;

    devLog("🏳️ رمز الدولة: $dialCode");
    devLog("📏 طول رمز الدولة: ${dialCode.length}");

    String myPhoneNumberWithoutDial;
    if (myPhoneNumber.contains('+') && myPhoneNumber.length > dialCode.length) {
      myPhoneNumberWithoutDial = myPhoneNumber.substring(dialCode.length);
    } else {
      myPhoneNumberWithoutDial = myPhoneNumber;
    }

    // إزالة الأصفار من بداية رقم المستخدم أيضاً
    while (myPhoneNumberWithoutDial.startsWith('0')) {
      myPhoneNumberWithoutDial = myPhoneNumberWithoutDial.substring(1);
    }

    // إزالة الرموز من رقم المستخدم أيضاً
    myPhoneNumberWithoutDial = myPhoneNumberWithoutDial
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('.', '');

    devLog("📱 رقم المستخدم بدون رمز: $myPhoneNumberWithoutDial");

    var result = myContacts.map((e) {
      String formattedNumber;
      String cleanNumber = e.phones.first.number;

      // إزالة جميع الرموز والمسافات من الرقم
      cleanNumber = cleanNumber
          .replaceAll('-', '')
          .replaceAll(' ', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('+', '')
          .replaceAll('.', '');

      // إذا كان الرقم يبدأ بـ 00 (رمز الاتصال الدولي)، أضف +
      if (cleanNumber.startsWith('00')) {
        cleanNumber = '+' + cleanNumber.substring(2);
      }
      // إزالة الأصفار من بداية الرقم (بعد معالجة 00)
      else if (cleanNumber.startsWith('0')) {
        while (cleanNumber.startsWith('0')) {
          cleanNumber = cleanNumber.substring(1);
        }
        cleanNumber = dialCode + cleanNumber;
      }

      devLog("🧹 تنظيف الرقم: ${e.phones.first.number} -> $cleanNumber");

      if (!cleanNumber.contains('+')) {
        int countryIndex = countries.indexWhere(
          (element) =>
              element.dialCode.length > 1 &&
              cleanNumber.startsWith(element.dialCode.substring(1)),
        );
        if (countryIndex == -1) {
          formattedNumber = dialCode + cleanNumber;
          devLog("➕ إضافة رمز الدولة: $cleanNumber -> $formattedNumber");
        } else {
          formattedNumber = '+$cleanNumber';
          devLog("✅ رقم مع رمز: $cleanNumber -> $formattedNumber");
        }
      } else {
        formattedNumber = cleanNumber;
        devLog("✅ رقم موجود: $formattedNumber");
      }

      return {
        "mobile_phone": formattedNumber,
        "name": e.displayName != "" ? e.displayName : "No Number",
      };
    }).toList();

    devLog("📋 قبل الاستبعاد: ${result.length}");

    result.removeWhere((element) {
      bool shouldRemove =
          element['mobile_phone']?.endsWith(myPhoneNumberWithoutDial) ?? false;
      if (shouldRemove) {
        devLog("🚫 استبعاد: ${element['name']} - ${element['mobile_phone']}");
      }
      return shouldRemove;
    });
    String contactDetails =
        "🔍 إجمالي جهات الاتصال: ${contacts.length}  ✅ النتيجة النهائية: ${result.length} 📱 جهات الاتصال مع أرقام: ${myContacts.length}";
    devLog("✅ النتيجة النهائية: ${result.length}");
    GetIt.I<PrefsRepository>().setContactDetails(contactDetails);
    return result;
  }

  static Future<AssetEntity?> getAssetFromGallery(BuildContext context) async {
    final List<AssetEntity>? assets = await myMultiAssetPicker(context);
    // المنتقي قد يرجع قائمة فارغة وليس null، و [0] عليها يرمي RangeError.
    if (assets == null || assets.isEmpty) return null;
    return assets.first;
  }

  static Future<List<AssetEntity>?> myMultiAssetPicker(
    BuildContext context,
  ) async {
    // نطلب إذن الوسائط بأنفسنا أولاً: AssetPicker.pickAssets يستدعي
    // permissionCheck داخلياً وهو يرمي StateError عند الرفض بدل إرجاع null،
    // فلا تُفتح أي شاشة ولا يعلم المستخدم بالسبب.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps != PermissionState.authorized && ps != PermissionState.limited) {
      if (context.mounted) {
        showWarningMessage(context, LocaleKeys.permission_denied.tr());
      }
      return null;
    }
    try {
      return await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          themeColor: Color(0xff137AC9),
        ),
      );
    } catch (e) {
      devLog('AssetPicker.pickAssets failed: $e');
      if (context.mounted) {
        showWarningMessage(context, LocaleKeys.error_picking_file.tr());
      }
      return null;
    }
  }

  static DateTime parseToUtc(String dateTimeString) {
    // نقسم النص إلى تاريخ ووقت
    final parts = dateTimeString.split(' ');
    if (parts.length != 2) {
      throw const FormatException('صيغة التاريخ غير صحيحة');
    }

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 3 || timeParts.length != 3) {
      throw const FormatException('صيغة التاريخ أو الوقت غير صحيحة');
    }

    return DateTime.utc(
      int.parse(dateParts[0]), // السنة
      int.parse(dateParts[1]), // الشهر
      int.parse(dateParts[2]), // اليوم
      int.parse(timeParts[0]), // الساعة
      int.parse(timeParts[1]), // الدقيقة
      int.parse(timeParts[2]), // الثانية
    );
  }

  static String getTheFirstTwoLettersOfName(String name) {
    return name.split(' ').length == 2
        ? name.split(' ')[0][0] + name.split(' ')[1][0]
        : name.split(' ').first.length > 1
        ? (name.split(' ')[0][0] + name.split(' ')[0][1])
        : name.split(' ').first;
  }

  static Future<File?> pickDocumentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  static String getDatesInFormat(DateTime date) {
    String formattedDate = DateFormat('MMMMd').format(date.toLocal());
    return formattedDate;
  }

  static String getDateInFormatForShippingDays(int shippingDays) {
    DateTime date = DateTime.now().add(Duration(days: shippingDays));
    String formattedDate = DateFormat('EEEE, d MMM yy', 'ar').format(date);

    return formattedDate;
  }

  static String gettimesInFormat(DateTime time) {
    String formattedDate = DateFormat("jm").format(time.toLocal());
    return formattedDate;
  }

  static String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  static String getZonedDateInFormat(DateTime date) {
    String formattedTime = DateFormat.Hm().format(date.toLocal());
    return formattedTime;
  }

  static String getDateInFormat(DateTime date) {
    String formattedTime = DateFormat.Hm().format(date);
    return formattedTime;
  }

  static DateTime getZonedDate(DateTime date) {
    return date.toLocal();
  }

  static DateTime getZonedDateWithoutUtcForm(String date) {
    return parseToUtc(date).toLocal();
  }

  static String getTimeInFormat(Duration duration) {
    String? hours = duration.inHours > 0
        ? twoDigits(duration.inHours.remainder(60))
        : null;
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${hours ?? ''}$minutes:$seconds';
  }

  static String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  static Future<String?> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id.toString() + '_' + androidInfo.model.toString();
    }
    return 'other_os';
  }

  static showVersionDialog(context) async {
    if (_versionDialogShown) return;
    _versionDialogShown = true;
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = LocaleKeys.new_update_available.tr();
        String message = LocaleKeys.newer_version_available_message.tr();
        String btnLabel1 = LocaleKeys.update_now.tr();
        String btnLabel2 = LocaleKeys.not_now.tr();
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () => Future.value(true),
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Column(
                    children: [
                      const Icon(
                        Icons.system_update_rounded,
                        size: 40,
                        color: Color(0xFF007AFF),
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    children: [
                      MyTextWidget(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              btnLabel2,
                              style: const TextStyle(
                                color: Color(0xFF6E6E73),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق الحوار
                              // كان يفتح مجموعة واتساب — لا صلة لها بالتحديث.
                              _openStorePage();
                            },
                            child: Text(
                              btnLabel1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: const Color(0xFF007AFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 40,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    children: [
                      MyTextWidget(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF6E6E73),
                          height: 1.4,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              btnLabel2,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E6E73),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق الحوار
                              _openStorePage();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              btnLabel1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  static const String _androidPackageId = 'com.trydos.www';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageId';

  /// وجهة تحديث iOS.
  ///
  /// التطبيق لم يُنشر على App Store بعد، فآيفون يذهب مؤقّتاً إلى نفس رابط
  /// Google Play. عند النشر: استبدل القيمة برابط App Store الحقيقي — ولا شيء
  /// آخر يحتاج تعديلاً، فالتفريع بحسب المنصّة قائم في [_openStorePage].
  static const String _appStoreUrl = _playStoreUrl;

  /// يفتح صفحة المتجر المناسبة للمنصّة (المتجر أولاً، والمتصفّح احتياطاً).
  static Future<void> _openStorePage() async {
    final String storeUrl = Platform.isIOS ? _appStoreUrl : _playStoreUrl;
    try {
      final bool launched = await urlLauncherApplication(storeUrl);
      if (!launched) {
        await urlLauncherBrowser(storeUrl);
      }
    } catch (e) {
      await urlLauncherBrowser(storeUrl);
    }
  }

  static slidingNavigation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, __, ___, child) => child, // بدون أي حركة
        transitionDuration: Duration.zero, // انتقال فوري
        reverseTransitionDuration: Duration.zero, // عودة فورية
      ),
    );
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    /*  Navigator.of(context).push(new PageRouteBuilder(
      opaque: false,
      transitionDuration: Duration(milliseconds: milliseconds),
      pageBuilder: (BuildContext context, _, __) {
        return DragToPop(child: page);
      },*/
    /*transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return new SlideTransition(
            child: child,
            position: new Tween<Offset>(
              begin: const Offset(1, 0), //// navigation from right
              end: Offset.zero,
            ).animate(animation),
          );
        }*/
    // ));
  }

  static void showDescriptionForProductDetails({
    required BuildContext context,
    bool withIcon = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffF4F4F4),
      // ignore: deprecated_member_use
      barrierColor: const Color(0xff1D1D1D).withOpacity(0.75),
      builder: (ctx) {
        return Container(
          height: 250,
          margin: const EdgeInsets.all(20)..copyWith(bottom: 0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [
              DottedBorder(
                radius: const Radius.circular(15),
                borderType: BorderType.RRect,
                padding: const EdgeInsets.all(10.0)..copyWith(top: 15),
                strokeCap: StrokeCap.round,
                strokeWidth: 0.5,
                color: const Color(0xff707070),
                dashPattern: const [3, 3],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.partyCozSvg,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 5),
                        MyTextWidget(
                          'Suitable Occasions',
                          style: context.textTheme.displayMedium?.mq.copyWith(
                            color: const Color(0xff8D8D8D),
                            fontSize: 15.sp,
                            height: 1.26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        MyTextWidget(
                          'According To The Opinions Of Our Fashion Team, The Appropriate Occasions For This Product Have Been Identified Based On Long Experience. We Provide An Opinion Only And Opinions May Differ From One Person To Another. So It Is Suitable For',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 1.23,
                            color: const Color(0xff8D8D8D),
                            fontSize: 13.sp,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 16,
                          child: ListView.separated(
                            itemCount: 3,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (withIcon) ...{
                                    MyTextWidget(
                                      '97%',
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                            height: 1.23,
                                            color: const Color(0xff505050),
                                            fontSize: 13.sp,
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: SvgPicture.asset(
                                        AppAssets.polyesterSvg,
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  },
                                  MyTextWidget(
                                    'Casual',
                                    style: context.textTheme.titleLarge?.rq
                                        .copyWith(
                                          height: 1.23,
                                          color: const Color(0xff8D8D8D),
                                          fontSize: 13.sp,
                                        ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                width: 1,
                                decoration: BoxDecoration(
                                  color: const Color(0xff8D8D8D),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  static double truncateToDecimalPlaces(double number, int decimalPlaces) {
    double mod = pow(10.0, decimalPlaces).toDouble();
    return (number * mod).ceilToDouble() / mod;
  }

  static String formatNumber({
    required double numberToFormate,
    bool isNeedRounding = true,
  }) {
    double number = numberToFormate;
    // Check if decimal part has more than 5 zeros
    String numberStr = number.toString();
    if (numberStr.contains('.')) {
      String decimalPart = numberStr.split('.')[1];
      // Count leading zeros in decimal part
      int leadingZeros = 0;
      for (int i = 0; i < decimalPart.length; i++) {
        if (decimalPart[i] == '0') {
          leadingZeros++;
        } else {
          break;
        }
      }
      // If more than 5 leading zeros, return integer part only
      if (leadingZeros > 5) {
        number = number.truncate().toDouble();
      }
    }

    var formate = NumberFormat("0.######", "en_US");
    String iso =
        (_prefsRepository.userCountryIsAvailable == 1
            ? _prefsRepository.userChoosedCountryIso
            : _prefsRepository.countryIso) ??
        "";

    iso = iso.toUpperCase();
    if (!isNeedRounding) {
      if (iso == 'SY') {
        return number.ceil().toString();
      } else {
        return formate.format(number).toString();
      }
    }

    // if (number >= 1e9) {
    //   String bilion = LanguageService.languageCode != "ar" ? 'B' : 'بليون';
    //   String result = (number / 1e9).toStringAsFixed(1);
    //   if (result.endsWith('.0')) {
    //     result = result.substring(0, result.length - 2);
    //   }
    //   return '$result$bilion';
    // } else if (number >= 1e6) {
    //   String milion = LanguageService.languageCode != "ar" ? 'M' : 'مليون';
    //   String result = (number / 1e6).toStringAsFixed(1);
    //   if (result.endsWith('.0')) {
    //     result = result.substring(0, result.length - 2);
    //   }
    //   return '$result$milion';
    // } else

    //if (iso == 'SY' || iso == 'LB') {

    String thousand =
        (LanguageService.languageCode != "ar" || LanguageService.isKurdish)
        ? 'K'
        : 'أ';
    String million =
        (LanguageService.languageCode != "ar" || LanguageService.isKurdish)
        ? 'M'
        : 'م';
    //if (iso == 'SY') {
    if (number >= 1e5 && number < 1e6) {
      String? result;
      if (iso == 'SY') {
        result = ((((number.ceil()) / 1000).ceil())).toString();
      } else {
        result = (((number) / 1000).ceil()).toStringAsFixed(
          (GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)
              .round(),
        );
      }

      return '${formate.format(double.tryParse(result))}$thousand';
    } else if (number == 0) {
      return '0.0';
    } else if (number < 1e5) {
      if (iso == 'SY') {
        return number.ceil().toString();
      }
      return number.toStringAsFixed(
        (GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)
            .round(),
      );

      //'1$thousand';
    } else {
      String? result;
      if (iso == 'SY') {
        result = (((((number.ceil())) / 1000).ceil()) / 1000).toStringAsFixed(
          3,
        );
      } else {
        result = (((((number.ceil())) / 1000).ceil()) / 1000).toStringAsFixed(
          (GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2)
                  .round() +
              3,
        );
      }

      if ((result.lastIndexOf(RegExp(r'.000'))) != -1) {
        result = result.substring(0, (result.lastIndexOf(RegExp(r'.000'))));
      }

      return '${formate.format(double.tryParse(result))}$million';
    }
    // }
    /*else if (iso == 'LB') {
        if (number >= 1e4 && number < 1e6) {
          String result = (((number + 9999) ~/ 10000) * 10).toStringAsFixed(
              GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ??
                  2);
          ;

          return '$result$thousand';
        } else if (number == 0) {
          return '0.0';
        } else if (number < 1e4) {
          return '10$thousand';
        } else {
          String result = (((((number + 9999) ~/ 10000) * 10)) / 1000)
              .toStringAsFixed((GetIt.I<HomeBloc>()
                          .state
                          .startingSetting
                          ?.decimalPointSettings ??
                      2) +
                  3);
          if ((result.lastIndexOf(RegExp(r'.000'))) != -1) {
            result = result.substring(0, (result.lastIndexOf(RegExp(r'.000'))));
          }
          return '$result$million';
        }
      } else {
        String result = number.toStringAsFixed(
            GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ??
                2);

        return result;
      }*/
    //}
    /*else {
      String result = number.toStringAsFixed(
          GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2);

      return result;
    }*/
  }

  static String orderFormatDate(DateTime dateTime) {
    DateTime dTime = dateTime.isUtc ? dateTime : dateTime.toLocal();

    final now = DateTime.now();
    final isToday =
        dTime.year == now.year &&
        dTime.month == now.month &&
        dTime.day == now.day;

    final timeFormatted = DateFormat('HH:mm:ss', "en_US").format(dTime);

    return '${isToday ? '${LocaleKeys.today.tr()}' : DateFormat('yyyy-MM-dd', "en_US").format(dTime)} | $timeFormatted';
  }
}
