/// شرائحُ المعاينة — نقلٌ لـ`web_design/NewLoginDesign/previewSlides.tsx`.
///
/// > «أيقونةٌ وعنوانٌ وسطرٌ عن وجهٍ من وجوه ترايدوس. وموضعان يعرضانها
/// > سلايدراً واحداً: المعاينةُ السريعةُ في أوّل الدخول، وبطاقةُ طلب الدخول
/// > في الديمو. فتغييرٌ هنا يظهر في الاثنين.»
///
/// والأيقوناتُ خطوطٌ `#402CDD` بسماكة 1.75 على صندوق 24 — كُتبت ملفّاتُ SVG
/// من بيانات مسارها في الويب حرفاً بحرف.
library;

import 'package:trydos/generated/locale_keys.g.dart';

class PreviewSlide {
  const PreviewSlide({
    required this.icon,
    required this.titleKey,
    required this.lineKey,
  });

  /// اسمُ ملفّ الأيقونة في `assets/svg/demo_v2/`.
  final String icon;

  final String titleKey;
  final String lineKey;
}

const List<PreviewSlide> kPreviewSlides = <PreviewSlide>[
  PreviewSlide(
    icon: 'slide1',
    titleKey: LocaleKeys.preview_shopping_title,
    lineKey: LocaleKeys.preview_shopping_line,
  ),
  PreviewSlide(
    icon: 'slide2',
    titleKey: LocaleKeys.preview_social_title,
    lineKey: LocaleKeys.preview_social_line,
  ),
  PreviewSlide(
    icon: 'slide3',
    titleKey: LocaleKeys.preview_smart_title,
    lineKey: LocaleKeys.preview_smart_line,
  ),
];
