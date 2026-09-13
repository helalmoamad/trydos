import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/helper/dev_log.dart';

class PermissionServices {
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    // PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
    if (status.isGranted) {
      devLog("Permission already granted");
    } else if (status.isDenied) {
      // إذا كان الإذن مرفوضًا، اطلب الإذن من المستخدم
      final result = await Permission.notification.request();

      if (result.isGranted) {
        devLog("Permission granted");
      } else if (result.isPermanentlyDenied) {
        // إذا تم رفض الإذن بشكل دائم، افتح إعدادات التطبيق
        openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      // إذا تم رفض الإذن بشكل دائم، افتح إعدادات التطبيق
      openAppSettings();
    }
  }
}
