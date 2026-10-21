import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/features/chat/presentation/utils/chat_search_match.dart';

/// أسماء جهات الاتصال كما هي في دفتر الهاتف.
///
/// الخادم يعيد في `contact.name` اسمَ المستخدم في التطبيق لمن يملكه، لا الاسم
/// الذي حفظه صاحبُ الجهاز. وصفحة جهات الاتصال تعرض **دفترَك أنت**، فالاسم
/// المتوقَّع فيها هو اسمك للشخص لا اسمه لنفسه.
///
/// تُقرأ مرّةً وتُحفظ في الذاكرة: الدفتر لا يتغيّر أثناء الجلسة عادةً، وقراءته
/// مع كل بناء عملية ثقيلة على دفترٍ كبير.
class DeviceContactNames {
  DeviceContactNames._();

  /// طول الذيل المعتمد مفتاحاً للمطابقة.
  ///
  /// الرقم المحلي في الدفتر (`0999123456`) ورقم الخادم (`+963999123456`) لا
  /// يتطابقان حرفاً بحرف ولا بعد تجريد البادئة، لكنّ آخر تسعة أرقام واحدة في
  /// الاثنين. وتسعة طولٌ يكفي لتمييز مشترك دون أن يجمع اثنين بالمصادفة.
  static const int _tailLength = 9;

  static Map<String, String>? _byTail;

  /// هل قُرئ الدفتر بعد؟ تمييزُ «لم يُقرأ» عن «قُرئ وكان فارغاً» ضروري: في
  /// الأولى ننتظر، وفي الثانية نعرض ما لدينا.
  static bool get isLoaded => _byTail != null;

  static String _tailOf(String? phone) {
    final String digits = ChatSearchMatch.normalizePhone(phone);
    if (digits.length <= _tailLength) return digits;
    return digits.substring(digits.length - _tailLength);
  }

  /// يقرأ الدفتر ويبني الخريطة. آمنٌ للاستدعاء أكثر من مرّة.
  ///
  /// بلا إذنٍ ممنوح لا يُطلب إذنٌ جديد هنا: الصفحة تعرض بيانات الخادم أصلاً،
  /// ونافذةُ إذنٍ تظهر فجأةً لمجرّد تحسين اسمٍ معروض سلوكٌ مفاجئ. فنكتفي
  /// بخريطةٍ فارغة ويبقى اسم الخادم.
  static Future<void> load() async {
    if (_byTail != null) return;
    final Map<String, String> names = {};
    try {
      if (await Permission.contacts.isGranted) {
        for (final Contact contact in await FastContacts.getAllContacts()) {
          final String name = contact.displayName.trim();
          if (name.isEmpty) continue;
          for (final Phone phone in contact.phones) {
            final String tail = _tailOf(phone.number);
            if (tail.isEmpty) continue;
            names[tail] = name;
          }
        }
      }
    } catch (e) {
      devLog('تعذّرت قراءة أسماء دفتر الهاتف: $e');
    }
    _byTail = names;
  }

  /// الاسم المحفوظ لهذا الرقم في الدفتر، أو `null` إن لم يُعرف.
  static String? nameFor(String? phone) {
    final Map<String, String>? names = _byTail;
    if (names == null || names.isEmpty) return null;
    final String tail = _tailOf(phone);
    if (tail.isEmpty) return null;
    return names[tail];
  }
}
