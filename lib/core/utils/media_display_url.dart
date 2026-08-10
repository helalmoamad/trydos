import 'package:flutter_dotenv/flutter_dotenv.dart';

/// يبني رابط عرض الوسائط من القيمة المخزَّنة في الخلفية.
///
/// بعد الانتقال إلى تدفّق الرفع المُقيَّد صار المرفوع حديثاً يُخزَّن كـ **مسار
/// فرعي** يحمل مجلّده معه (`rating_orders/uuid.jpg`)، بينما السجلات القديمة
/// تحمل **اسم الملف وحده** (`uuid.jpg`) وكانت الواجهة تضيف المجلّد يدوياً.
///
/// هذه الدالة تقبل الشكلين فلا تنكسر الصور القديمة:
///
/// | القيمة | النتيجة |
/// |---|---|
/// | رابط مطلق (`http…`) أو من Cloudinary | تُعاد كما هي |
/// | مسار فرعي (يحوي `/`) | `<base>/<value>` |
/// | اسم ملف مجرّد | `<base>/<legacyFolder>/<value>` |
///
/// [legacyFolder] هو المجلّد الذي كانت الواجهة تضيفه قبل الترحيل. يُحذف هذا
/// المعامل — ومعه فرع التوافق — متى رُحّلت البيانات القديمة في الخلفية.
String mediaDisplayUrl(
  String value, {
  required String legacyFolder,
  String? baseUrl,
}) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;

  // رابط جاهز: لا يُبنى فوقه شيء
  if (trimmed.startsWith('http://') ||
      trimmed.startsWith('https://') ||
      trimmed.contains('cloudinary')) {
    return trimmed;
  }

  final String base = (baseUrl ?? dotenv.env['Media_S3_Server'] ?? '')
      .replaceAll(RegExp(r'/+$'), '');
  final String path = trimmed.replaceAll(RegExp(r'^/+'), '');

  // مسار فرعي: يحمل مجلّده معه
  if (path.contains('/')) return '$base/$path';

  // اسم ملف مجرّد (الشكل القديم): يحتاج مجلّده
  final String folder = legacyFolder.replaceAll(RegExp(r'^/+|/+$'), '');
  return folder.isEmpty ? '$base/$path' : '$base/$folder/$path';
}
