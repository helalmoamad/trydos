/// مطابقة نصّ البحث على اسمٍ أو رقم.
///
/// مشتركة بين بحث قائمة المحادثات وبحث جهات الاتصال: كانا يطبّقان قاعدتين
/// مختلفتين على نفس الشخص، فيظهر في أحدهما ويغيب عن الآخر.
class ChatSearchMatch {
  ChatSearchMatch._();

  /// حروف التشكيل والتطويل — تُحذف قبل المقارنة.
  static final RegExp _diacritics = RegExp(r'[ً-ْـ]');
  static final RegExp _nonDigits = RegExp(r'[^0-9]');
  static final RegExp _spaces = RegExp(r'\s+');

  /// يوحّد النصّ قبل المقارنة.
  ///
  /// `toLowerCase` وحدها لا تكفي: لا أثر لها على العربية. ومن يكتب «احمد»
  /// يقصد «أحمد»، ومن يكتب «فاطمه» يقصد «فاطمة» — فبلا توحيد الهمزات والتاء
  /// المربوطة والألف المقصورة يبحث المستخدم عن جهة يراها أمامه فلا يجدها.
  static String normalizeText(String? value) {
    if (value == null) return '';
    return value
        .toLowerCase()
        .replaceAll(_diacritics, '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(_spaces, ' ')
        .trim();
  }

  /// يردّ الرقم إلى أرقامه المجرّدة بلا بادئة.
  ///
  /// نفس الشخص يُحفظ في الهاتف `0999123456` ويخزّنه الخادم `+963999123456`.
  /// فبحذف `+` و`00` والصفر البادئ يصير أحدهما جزءاً من الآخر، وتكفي
  /// `contains` لتجمعهما. ولولا ذلك لما وجد المستخدمُ جهةً يبحث عنها بالصيغة
  /// التي يحفظها بها.
  static String normalizePhone(String? value) {
    if (value == null) return '';
    String digits = value.replaceAll(_nonDigits, '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// هل يطابق [query] الاسمَ أو الرقم؟
  ///
  /// استعلامٌ فارغ يطابق الجميع — فحقل بحث فارغ لا يُخفي شيئاً. وكلا الحقلين
  /// قد يكون `null` (النموذج يقرؤهما من JSON بلا ضمان)، فلا نفترض وجودهما.
  static bool matches({
    String? name,
    String? phone,
    required String? query,
  }) {
    final String text = normalizeText(query);
    if (text.isEmpty) return true;

    if (normalizeText(name).contains(text)) return true;

    // الرقم يُطابَق بأرقامه وحدها، وبعد تجريد الاستعلام من بادئته أيضاً —
    // وإلّا فشل البحث بـ`+963` عن رقمٍ مخزَّن بلا بادئة.
    final String queryDigits = normalizePhone(query);
    if (queryDigits.isEmpty) return false;
    return normalizePhone(phone).contains(queryDigits);
  }
}
