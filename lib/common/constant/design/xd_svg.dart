import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'xd_design.dart';

/// أيقونةٌ مقطوعةٌ من ملفّ XD — `XdIcon` في
/// `web_design/components/DemoApp/XdIcon.tsx`.
///
/// تُرسم بالمقاس الذي رسمها به المصمّم، أو بالعرض الذي يُطلب (فيتبعه
/// الارتفاع). والبعدان كلاهما بـ`.w`: هذه حلقاتٌ ومربّعاتٌ وشعارات، وتمديد
/// أحد بعديها بنسبةٍ مختلفة عن الآخر يُرى. أمّا **مواضعها** الرأسيّة فتبقى
/// بـ`.h` كبقيّة الارتفاعات في النقل.
///
/// و[folder] هو مجلّد الشاشة تحت `assets/svg/`، فتحفظ كلّ شاشةٍ أيقوناتها
/// عندها كما يحفظها الويب في `public/assets/demo/xd/`.
class XdSvg extends StatelessWidget {
  const XdSvg(
    this.name, {
    super.key,
    required this.folder,
    required this.w,
    this.h,
    this.size,
    this.color,
    this.flipRtl = false,
  });

  final String name;
  final String folder;

  /// عرض الأيقونة في الملفّ، بوحدة اللوح — `XD_ICON_SIZE[name].w`.
  final double w;

  /// ارتفاعها في الملفّ. غيابه يعني مربّعاً.
  final double? h;

  /// عرضٌ آخر تُرسم به، فيتبعه الارتفاع بنسبة الملفّ — `size` في الويب.
  final double? size;

  final Color? color;

  /// ينقلب **رسمُها** أفقياً في العربيّة.
  ///
  /// انقلابُ الصفحة يُبدّل مواضعَ الأيقونات ولا يُبدّل رسمَها، فيبقى السهمُ
  /// مشيراً كما رُسم في الإنجليزيّة. وهذه خانةٌ لكلّ أيقونةٍ لها جهةٌ — سهمٌ
  /// أو مائلٌ — فتنقلب مع صفحتها.
  final bool flipRtl;

  @override
  Widget build(BuildContext context) {
    final double width = size ?? w;
    final double height = size != null ? size! * (h ?? w) / w : (h ?? w);
    final Widget picture = SvgPicture.asset(
      'assets/svg/$folder/$name.svg',
      width: width.w,
      height: height.w,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
    if (!flipRtl || Directionality.of(context) != TextDirection.rtl) {
      return picture;
    }
    return Transform.flip(flipX: true, child: picture);
  }
}

/// نصّ Quicksand بخطّ أساسٍ مضبوط كما في الويب — `Txt` في `DemoApp/ui.tsx`.
///
/// `leadingDistribution: even` يضع النصّ في وسط صندوق السطر كما تفعل CSS —
/// وبدونه ينزلق خطّ الأساس وتفشل المطابقة مهما ضُبط الهامش.
class XdText extends StatelessWidget {
  const XdText(
    this.text, {
    super.key,
    required this.size,
    this.weight = XdWeight.regular,
    this.color = XdColors.ink,
    this.maxLines = 1,
    this.overflow,
    this.align,
    this.height,
  });

  final String text;
  final double size;
  final XdWeight weight;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? align;

  /// ارتفاع سطرٍ غير صندوق الخطّ، لفقرةٍ متعدّدة الأسطر.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      softWrap: maxLines != 1,
      overflow: overflow,
      textAlign: align,
      style: xdTextStyle(
        size: size,
        weight: weight,
        color: color,
        height: height,
      ),
    );
  }
}

/// أوزان Quicksand الموجودة في `pubspec.yaml`.
enum XdWeight { light, regular, medium, bold }

const Map<XdWeight, String> kXdFamily = <XdWeight, String>{
  XdWeight.light: 'Quicksand-Light',
  XdWeight.regular: 'Quicksand-Regular',
  XdWeight.medium: 'Quicksand-Medium',
  XdWeight.bold: 'Quicksand-Bold',
};

/// نمطُ نصٍّ بخطّ أساس الملفّ، لاستعماله في `TextSpan` حيث لا يكفي [XdText].
TextStyle xdTextStyle({
  required double size,
  XdWeight weight = XdWeight.regular,
  Color color = XdColors.ink,
  double? height,
}) {
  final double line = height ?? Xd.lineBox(size);
  return TextStyle(
    fontFamily: kXdFamily[weight],
    fontSize: size.sp,
    height: line / size,
    leadingDistribution: TextLeadingDistribution.even,
    color: color,
  );
}
