import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../features/app/my_text_widget.dart';
import '../../generated/locale_keys.g.dart';
import '../../service/language_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import '../constant/design/assets_provider.dart';

final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

class HelperFunctions {
  static changeAppStatus(ThemeMode theme) {
    final color = theme == ThemeMode.dark
        ? const Color(0xFF191C1D)
        : const Color(0xFFFBFDFD);
    final brightness =
        theme == ThemeMode.light ? Brightness.dark : Brightness.light;

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
            enableDomStorage: false, enableJavaScript: false),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static Future<File> urlToFile(String imageUrl) async {
    // تحميل الصورة من الإنترنت
    final response = await http.get(Uri.parse(imageUrl));

    // الحصول على مسار التخزين المؤقت
    final documentDirectory = await getTemporaryDirectory();

    // إنشاء ملف مؤقت باسم فريد
    final file = File('${documentDirectory.path}/${imageUrl.split("/").last}');

    // كتابة بيانات الصورة إلى الملف
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  static Future<bool> urlLauncherBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
            enableDomStorage: true, enableJavaScript: true),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static Locale getInitLocale() {
    final devicelang = WidgetsBinding.instance.window.locale.languageCode;
    return _prefsRepository.language == null
        ? mpaLanguageCodeToLocale[devicelang] ?? defaultLocal
        : mpaLanguageCodeToLocale[_prefsRepository.language] ?? defaultLocal;
  }

  static Country getDefaultCountry() {
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

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getContactsFromDevice() async {
    final PermissionStatus permissionStatus =
        await Permission.contacts.request();
    List<Contact> contacts = [];

    if (permissionStatus == PermissionStatus.granted) {
      contacts = await FlutterContacts.getContacts(
          withThumbnail: false, withProperties: true);
    }

    print("🔍 إجمالي جهات الاتصال: ${contacts.length}");

    List<Contact> myContacts = [];
    for (Contact contact in contacts) {
      if (contact.phones.isNotEmpty) {
        print("📞 ${contact.displayName}: ${contact.phones.length} رقم");
        contact.phones.forEach((element) {
          print("   - ${element.number}");
          myContacts.add(
              Contact(phones: [element], displayName: contact.displayName));
        });
      } else {
        print("❌ ${contact.displayName}: بدون أرقام هواتف");
      }
    }

    print("📱 جهات الاتصال مع أرقام: ${myContacts.length}");

    String myPhoneNumber = '${GetIt.I<PrefsRepository>().myPhoneNumber ?? ""}';
    if (!(myPhoneNumber.startsWith("+"))) {
      myPhoneNumber = "+" + myPhoneNumber;
    }
    print("📞 رقم المستخدم: $myPhoneNumber");
    print("📏 طول رقم المستخدم: ${myPhoneNumber.length}");

    String dialCode = countries
        .firstWhere((element) => myPhoneNumber.startsWith(element.dialCode),
            orElse: () => defaultCountry)
        .dialCode;

    print("🏳️ رمز الدولة: $dialCode");
    print("📏 طول رمز الدولة: ${dialCode.length}");

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

    print("📱 رقم المستخدم بدون رمز: $myPhoneNumberWithoutDial");

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

      print("🧹 تنظيف الرقم: ${e.phones.first.number} -> $cleanNumber");

      if (!cleanNumber.contains('+')) {
        int countryIndex = countries.indexWhere((element) =>
            element.dialCode.length > 1 &&
            cleanNumber.startsWith(element.dialCode.substring(1)));
        if (countryIndex == -1) {
          formattedNumber = dialCode + cleanNumber;
          print("➕ إضافة رمز الدولة: $cleanNumber -> $formattedNumber");
        } else {
          formattedNumber = '+$cleanNumber';
          print("✅ رقم مع رمز: $cleanNumber -> $formattedNumber");
        }
      } else {
        formattedNumber = cleanNumber;
        print("✅ رقم موجود: $formattedNumber");
      }

      return {
        "mobile_phone": formattedNumber,
        "name": e.displayName,
      };
    }).toList();

    print("📋 قبل الاستبعاد: ${result.length}");

    result.removeWhere((element) {
      bool shouldRemove =
          element['mobile_phone']?.endsWith(myPhoneNumberWithoutDial) ?? false;
      if (shouldRemove) {
        print("🚫 استبعاد: ${element['name']} - ${element['mobile_phone']}");
      }
      return shouldRemove;
    });

    print("✅ النتيجة النهائية: ${result.length}");
    return result;
  }

  static Future<AssetEntity?> getAssetFromGallery(BuildContext context) async {
    final List<AssetEntity>? assets = await myMultiAssetPicker(context);
    return assets?[0];
  }

  static Future<List<AssetEntity>?> myMultiAssetPicker(
      BuildContext context) async {
    return AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        themeColor: const Color(0xff137AC9),
      ),
    );
  }

  static DateTime parseToUtc(String dateTimeString) {
    // نقسم النص إلى تاريخ ووقت
    final parts = dateTimeString.split(' ');
    if (parts.length != 2) {
      throw FormatException('صيغة التاريخ غير صحيحة');
    }

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 3 || timeParts.length != 3) {
      throw FormatException('صيغة التاريخ أو الوقت غير صحيحة');
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
    String? hours =
        duration.inHours > 0 ? twoDigits(duration.inHours.remainder(60)) : null;
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
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = LocaleKeys.new_update_available.tr();
        String message = LocaleKeys.newer_version_available_message.tr();
        String btnLabel1 = LocaleKeys.update_now.tr();
        String btnLabel2 = LocaleKeys.not_now.tr();

        return WillPopScope(
          onWillPop: () => Future.value(true),
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Column(
                    children: [
                      Icon(
                        Icons.system_update_rounded,
                        size: 40,
                        color: Color(0xFF007AFF),
                      ),
                      SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: TextStyle(
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
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
                              style: TextStyle(
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
                              _openWhatsAppGroup(); // فتح الواتساب
                            },
                            child: Text(
                              btnLabel1,
                              style: TextStyle(
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF007AFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.system_update_rounded,
                          size: 40,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: TextStyle(
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
                        style: TextStyle(
                          color: Color(0xFF6E6E73),
                          height: 1.4,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              btnLabel2,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E6E73),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق الحوار
                              _openWhatsAppGroup(); // فتح الواتساب
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              btnLabel1,
                              style: TextStyle(
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
  /*static _getFileFromGoogleDrive() {
    urlLauncherBrowser(
        'https://drive.google.com/file/d/1im1-7Bmx5Qi9cTsVIvGnZIvNY7vSKQLj/view?usp=drivesdk');
  }*/

  static _openWhatsAppGroup() async {
    try {
      // رابط مجموعة واتساب - يمكنك تغييره برابط مجموعة الواتساب الخاصة بك
      String whatsappGroupUrl =
          'https://chat.whatsapp.com/JVCvHFxKQBM9fQiTAPOsyf?mode=ac_t';

      // محاولة فتح تطبيق واتساب مباشرة مع رابط المجموعة
      // هذا سيفتح المجموعة مباشرة في التطبيق

      bool launched = await urlLauncherApplication(whatsappGroupUrl);

      // إذا فشل فتح التطبيق، افتح المتصفح
      if (!launched) {
        await urlLauncherBrowser(whatsappGroupUrl);
      }
    } catch (e) {
      // في حالة حدوث خطأ، افتح المتصفح مباشرة
      String whatsappGroupUrl =
          'https://chat.whatsapp.com/JVCvHFxKQBM9fQiTAPOsyf?mode=ac_t';
      await urlLauncherBrowser(whatsappGroupUrl);
    }
  }

  _openStoreUrl() {
    StoreRedirect.redirect(
      androidAppId: 'ae.clearance.app',
      iOSAppId: '1637100307',
    );
  }

  static slidingNavigation(
    BuildContext context,
    Widget page,
  ) {
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

  static void showDescriptionForProductDetails(
      {required BuildContext context, bool withIcon = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xffF4F4F4),
      barrierColor: Color(0xff1D1D1D).withOpacity(0.75),
      builder: (ctx) {
        return Container(
          height: 250,
          margin: EdgeInsets.all(20)..copyWith(bottom: 0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [
              DottedBorder(
                radius: Radius.circular(15),
                borderType: BorderType.RRect,
                padding: const EdgeInsets.all(10.0)..copyWith(top: 15),
                strokeCap: StrokeCap.round,
                strokeWidth: 0.5,
                color: Color(0xff707070),
                dashPattern: [3, 3],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.partyCozSvg,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        MyTextWidget(
                          'Suitable Occasions',
                          style: context.textTheme.displayMedium?.mq.copyWith(
                              color: Color(0xff8D8D8D),
                              fontSize: 15.sp,
                              height: 1.26),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyTextWidget(
                          'According To The Opinions Of Our Fashion Team, The Appropriate Occasions For This Product Have Been Identified Based On Long Experience. We Provide An Opinion Only And Opinions May Differ From One Person To Another. So It Is Suitable For',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                              height: 1.23,
                              color: Color(0xff8D8D8D),
                              fontSize: 13.sp),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                                              color: Color(0xff505050),
                                              fontSize: 13.sp),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
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
                                            color: Color(0xff8D8D8D),
                                            fontSize: 13.sp),
                                  )
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                width: 1,
                                decoration: BoxDecoration(
                                    color: Color(0xff8D8D8D),
                                    borderRadius: BorderRadius.circular(2)),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Spacer()
            ],
          ),
        );
      },
    );
  }

  static String formatNumber({required double number}) {
    /*  String iso = (_prefsRepository.userCountryIsAvailable == 1
            ? _prefsRepository.userChoosedCountryIso
            : _prefsRepository.countryIso) ??
        "";
    iso = iso.toUpperCase();*/

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
            : 'الف';
    String million =
        (LanguageService.languageCode != "ar" || LanguageService.isKurdish)
            ? 'M'
            : 'مليون';
    //if (iso == 'SY') {
    if (number >= 1e5 && number < 1e6) {
      String result = (((number + 999) ~/ 1000)).toStringAsFixed(
          GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2);

      return '$result$thousand';
    } else if (number == 0) {
      return '0.0';
    } else if (number < 1e5) {
      return number.toStringAsFixed(
          GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2);

      //'1$thousand';
    } else {
      String result = (((number + 999) ~/ 1000) / 1000).toStringAsFixed(
          (GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ??
                  2) +
              3);

      if ((result.lastIndexOf(RegExp(r'.000'))) != -1) {
        result = result.substring(0, (result.lastIndexOf(RegExp(r'.000'))));
      }
      return '$result$million';
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
    final isToday = dTime.year == now.year &&
        dTime.month == now.month &&
        dTime.day == now.day;

    final timeFormatted = DateFormat('HH:mm:ss').format(dTime);

    return '${isToday ? '${LocaleKeys.today.tr()}' : DateFormat('yyyy-MM-dd').format(dTime)} | $timeFormatted';
  }
}
