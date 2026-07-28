/// مدخل سجلّ وسائط الدردشة المحفوظ في التفضيلات بصيغة `<url> <localPath>`.
///
/// الفصل يقع عند **أول** مسافة فقط — لا عند كل مسافة. الرابط لا يحوي مسافات
/// إطلاقاً (تُرمَّز `%20`)، أما المسار المحلي فقد يحويها: مجلّدات واتساب مثلاً
/// (`.../WhatsApp/Media/WhatsApp Images/IMG-….jpg`).
///
/// الفصل بكل المسافات كان يقتطع المسار عند أول فراغ، فيصير
/// `/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp`
/// ويشير إلى ملف غير موجود — ومن هنا جاء `PathNotFoundException`.
class MediaRegistryEntry {
  final String url;
  final String path;

  const MediaRegistryEntry({required this.url, required this.path});

  /// يرجع `null` إذا كان المدخل مشوّهاً (بلا مسافة، أو بلا مسار بعدها).
  static MediaRegistryEntry? tryParse(String raw) {
    final int separator = raw.indexOf(' ');
    if (separator <= 0 || separator == raw.length - 1) return null;
    return MediaRegistryEntry(
      url: raw.substring(0, separator),
      path: raw.substring(separator + 1),
    );
  }
}
