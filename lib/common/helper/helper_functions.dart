
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trydos/common/constant/countries.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import '../../service/language_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HelperFunctions {
  static changeAppStatus(ThemeMode theme) {
    final color = theme == ThemeMode.dark ? const Color(0xFF191C1D) : const Color(0xFFFBFDFD);
    final brightness = theme == ThemeMode.light ? Brightness.dark : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: brightness,
      ),
    );
  }
  static Future<String> changeSvgColor(String svgPath , String newColor) async {
    String svgCode =await rootBundle.loadString(svgPath);

    svgCode=svgCode.replaceAll("CC3333", newColor.toUpperCase());
    return svgCode;
  }

  static Future<bool> urlLauncherApplication(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(enableDomStorage: false, enableJavaScript: false),
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
        webViewConfiguration: const WebViewConfiguration(enableDomStorage: true, enableJavaScript: true),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static Locale getInitLocale() {
    final deviceLanguage = WidgetsBinding.instance.window.locale.languageCode;
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

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  static Future<List<Map<String,dynamic>>> getContactsFromDevice() async {
    final PermissionStatus permissionStatus =
    await Permission.contacts.request();
    List<Contact> contacts =[];
    if (permissionStatus == PermissionStatus.granted) {
      contacts =  await ContactsService.getContacts(withThumbnails: false);
    }
    return contacts.map((e) => {
      "mobile_phone":(e.phones?.isNotEmpty ??  false) ?e.phones!.first.value : '',
      "name":e.displayName,
    }).toList();
  }
   static Future<AssetEntity?> getAssetFromCamera(BuildContext context) async{
     final List<AssetEntity>? assets = await myMultiAssetPicker(context);
     return assets?[0];
   }

  static Future<List<AssetEntity>?> myMultiAssetPicker (BuildContext context) {
     const AssetPickerTextDelegate textDelegate = AssetPickerTextDelegate();
     return AssetPicker.pickAssets(
       context,
       pickerConfig: AssetPickerConfig(
         maxAssets: 1,
         textDelegate: LanguageService.languageCode!='ar' ?  const EnglishAssetPickerTextDelegate() : const ArabicAssetPickerTextDelegate(),
         themeColor: const Color(0xff137AC9),
         specialItemPosition: SpecialItemPosition.prepend,
         specialItemBuilder: (
             BuildContext context,
             AssetPathEntity? path,
             int length,
             ) {
           if (path?.isAll != true) {
             return null;
           }
           return Semantics(
             label: textDelegate.sActionUseCameraHint,
             button: true,
             onTapHint: textDelegate.sActionUseCameraHint,
             child: GestureDetector(
               behavior: HitTestBehavior.opaque,
               onTap: () async {
                 final AssetEntity? result = await _pickFromCamera(context);
                 if (result == null) {
                   return;
                 }
                 final AssetPicker<AssetEntity, AssetPathEntity> picker =
                 context.findAncestorWidgetOfExactType()!;
                 final DefaultAssetPickerBuilderDelegate builder =
                 picker.builder as DefaultAssetPickerBuilderDelegate;
                 final DefaultAssetPickerProvider p = builder.provider;
                 await p.switchPath(
                   PathWrapper<AssetPathEntity>(
                     path:
                     await p.currentPath!.path.obtainForNewProperties(),
                   ),
                 );
                 p.selectAsset(result);
               },
               child: const Center(
                 child: Icon(Icons.camera_enhance, size: 42.0),
               ),
             ),
           );
         },
       ),
     );
   }
  static Future<AssetEntity?> _pickFromCamera(BuildContext c) {
    return CameraPicker.pickFromCamera(
      c,
      pickerConfig: const CameraPickerConfig(enableRecording: true),
    );
  }
  String _replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }
  static String getZonedDateInFormat(DateTime date){
    final dateFormatter = DateFormat('yyy-MM-ddTHH:mmZ').parseUTC(date.toIso8601String()).toLocal();
    String formattedTime = DateFormat("HH:mm").format(dateFormatter);
    return formattedTime;
  }

  static String getDateInFormat(DateTime date){
    String formattedTime = DateFormat("HH:mm").format(date);
    return formattedTime;
  }

  static DateTime getZonedDate(DateTime date){
    final dateFormatter = DateFormat('yyy-MM-ddTHH:mmZ').parseUTC(date.toIso8601String()).toLocal();
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateFormatter);
    return DateTime.parse(formattedTime);
  }
  
  static String getTimeInFormat(Duration duration){
    String? hours= duration.inHours > 0 ? twoDigits(duration.inHours.remainder(60)) : null;
    String minutes=twoDigits(duration.inMinutes.remainder(60));
    String seconds=twoDigits(duration.inSeconds.remainder(60));
    return '${hours ?? ''}$minutes:$seconds';
  }
  static String twoDigits(int n){
    return n.toString().padLeft(2,'0');
  }
  
}
