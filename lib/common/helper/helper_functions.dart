import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../features/app/my_text_widget.dart';
import '../../service/language_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

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
    final deviceLanguage = WidgetsBinding.instance.window.locale.languageCode;
    debugPrint(deviceLanguage);
    return mpaLanguageCodeToLocale[deviceLanguage] ?? defaultLocal;
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
      contacts = await ContactsService.getContacts(withThumbnails: false);
    }
    List<Contact> myContacts = [];
    for (Contact contact in contacts) {
      if (contact.phones?.isNotEmpty ?? false) {
        contact.phones?.forEach((element) {
          myContacts.add(
              Contact(phones: [element], displayName: contact.displayName));
        });
      }
    }
    return myContacts
        .map((e) => {
              "mobile_phone": e.phones!.first.value,
              "name": e.displayName ?? 'No Name',
            })
        .toList();
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
        String title = 'New Update Available';
        String message =
            'There is a newer version of app available please update it now.';
        String btnLabel = 'Update Now';
        return WillPopScope(
            onWillPop: () => Future.value(true),
            child: Platform.isIOS
                ? CupertinoAlertDialog(
                    title: MyTextWidget(title,
                        textDirection: ui.TextDirection.ltr),
                    content: MyTextWidget(message,
                        textDirection: ui.TextDirection.ltr),
                    actions: <Widget>[
                        Row(
                          children: [
                            AppElevatedButton(
                              onPressed: () => _getFileFromGoogleDrive(),
                              text: btnLabel,
                            ),
                            AppElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              text: 'Not Now',
                            ),
                          ],
                        )
                      ])
                : AlertDialog(
                    title: MyTextWidget(title,
                        textDirection: ui.TextDirection.ltr),
                    content: MyTextWidget(message,
                        textDirection: ui.TextDirection.ltr),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppElevatedButton(
                            onPressed: () => _getFileFromGoogleDrive(),
                            text: btnLabel,
                          ),
                          AppElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Not Now',
                          ),
                        ],
                      ),
                    ],
                  ));
      },
    );
  }

  static _getFileFromGoogleDrive() {
    urlLauncherBrowser(
        'https://drive.google.com/file/d/1im1-7Bmx5Qi9cTsVIvGnZIvNY7vSKQLj/view?usp=drivesdk');
  }

  _openStoreUrl() {
    StoreRedirect.redirect(
      androidAppId: 'ae.clearance.app',
      iOSAppId: '1637100307',
    );
  }

  static slidingNavigation(BuildContext context, Widget page , {int milliseconds = 200 }) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_)=> page));
    // Navigator.of(context).push(new PageRouteBuilder(
    //     opaque: false,
    //     transitionDuration:  Duration(milliseconds: milliseconds),
    //     pageBuilder: (BuildContext context, _, __) {
    //       return DragToPop(
    //           xValueToStartPoping: 70,
    //           child: page);
    //     },
    //     transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
    //       return new SlideTransition(
    //         child: child,
    //         position: new Tween<Offset>(
    //           begin: const Offset(1, 0), //// navigation from right
    //           end: Offset.zero,
    //         ).animate(animation),
    //       );
    //     }
    //     ));
  }
}
