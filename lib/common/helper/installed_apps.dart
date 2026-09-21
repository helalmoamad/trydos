import 'dart:io';

import 'package:flutter/services.dart';
import 'package:trydos/common/helper/dev_log.dart';

/// هل تطبيق ما مثبّت على الجهاز؟
///
/// على أندرويد نسأل مدير الحزم عبر قناة في [MainActivity]، وهي تحتاج إلى إدراج
/// الحزمة في `<queries>` في AndroidManifest وإلا حجبها النظام منذ أندرويد 11.
///
/// على iOS لا سبيل إلى ذلك مع الروابط العامة (Universal Links): الفحص الوحيد
/// المتاح هو `canOpenURL` لسكيم خاص، ولا سكيم لدينا من RDB بعد. لذلك نعيد
/// `false` هناك، فلا نعرض زرّاً قد لا يفتح شيئاً.
class InstalledApps {
  InstalledApps._();

  static const MethodChannel _channel = MethodChannel(
    'com.trydos.apps/installed',
  );

  /// حزمة تطبيق Ramaaz Digital Bank على أندرويد.
  static const String rdbWalletPackageId = 'com.rdb.www';

  /// يُسأل مدير الحزم في كل مرّة بلا تخزين مؤقّت.
  ///
  /// المستخدم قد يثبّت المحفظة أو يحذفها بين طلب دفع وآخر، بل أثناء طلب الدفع
  /// نفسه. السؤال رخيص (استدعاء محلّي بلا شبكة)، فالإجابة الصحيحة أولى من
  /// توفير أجزاء من الملّي ثانية.
  static Future<bool> isInstalled(String packageId) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'isAppInstalled',
            <String, dynamic>{'packageId': packageId},
          ) ??
          false;
    } catch (e) {
      devLog('installed_apps.dart: check failed for $packageId', e);
      return false;
    }
  }
}
