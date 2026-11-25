/// شعارُ شاشات الدخول وطبقتُه — نقلٌ لـ`AuthLogoSlot.tsx` و`AuthLogoLayer.tsx`
/// و`NewLoginLogo.tsx` في `web_design/NewLoginDesign/`.
///
/// > الشعارُ 150 × 150 في كلّ شاشةٍ تُظهره، وله **موضعان لا ثالثَ لهما**:
/// >
/// >   - **116** — الهاتفُ والطريقةُ والرمزُ وشاشاتُ النتيجة الأربع: سبعُ
/// >     شاشاتٍ برقمٍ واحد، فيبقى ساكناً تماماً بينما ينزلق المحتوى تحته.
/// >   - **390** — «ابدأ» و«الشروط»: منخفضٌ والأزرارُ تحته. وكلتاهما تقرأ
/// >     الرقمَ نفسَه، فلا ينزلق بينهما.
/// >
/// > وهو **عنصرٌ واحدٌ لا يُعاد بناؤه**، يعيش في طبقةٍ فوق الشاشات، فيسافر
/// > بين الموضعين كجسمٍ واحد.
///
/// ## اللون
///
/// الملفُّ يُعيد تلوين الحلقة والنقطتين وحدَهما، وحروفُ «try» تبقى `#1d1d1d`.
/// والبنفسجيُّ لونُ المسار، ولشاشات النتيجة ألوانُها. وثلاثُ حالاتٍ لا غير،
/// فهي ثلاثةُ ملفّاتٍ مولَّدةٍ من `QuickPreviewBottomLogo.svg` بتبديل اللون —
/// أدقُّ من مِرشَحِ لونٍ يطلي الشعارَ كلَّه، وأسرعُ من تبديلِ نصّ SVG عند كلّ
/// رسم.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';

import 'auth_design.dart';
import 'auth_logo_motion.dart';

/// مجلّد أصول شاشات الدخول تحت `assets/svg/`.
const String kAuthSvg = 'auth_v2';

/// حالاتُ لون الشعار الثلاث — `STEP_LOGO_COLOR`.
enum AuthBadgeTone {
  /// المسارُ كلُّه، ونجاحُ الدخول: الحلقةُ والنقطتان `#402CDD`.
  purple,

  /// «غيرُ مسجَّل»: النقطتان `#FAAA2E` **والحلقةُ تبقى بنفسجيّة** — هكذا
  /// يلوّنها الملفّ، لا الاثنتان معاً.
  amber,

  /// «الاسم» ونجاحُ التسجيل: الحلقةُ والنقطتان `#28C452`.
  green,
}

/// موضعا استقرار الشعار — `AUTH_LOGO_STOP`.
enum AuthLogoStop {
  /// y 116 من أعلى الشاشة.
  top,

  /// y 390 على اللوح، محفوظةً مسافتُه من **أسفل** الشاشة: فعلى هاتفٍ أقصرَ
  /// من اللوح يصعد هو والأزرارُ تحته، ويقصر الفراغُ فوقه — `fromBottom`.
  centre,
}

/// الشعارُ نفسُه، بلونِ حاله وحركةِ مكانه.
///
/// والحركةُ في [AuthLogoMark]: الحلقةُ والكلمةُ والنقطتان تتحرّك كلُّها،
/// وما تعرضه كلُّ شاشةٍ في [LogoSlots].
class AuthBadge extends StatelessWidget {
  const AuthBadge({
    super.key,
    this.tone = AuthBadgeTone.purple,
    this.size = AuthXd.logoSize,
    this.slot = LogoSlots.inner,
  });

  final AuthBadgeTone tone;

  /// ضلعُه ببكسل التصميم.
  final double size;

  /// ما تعرضه هذه الشاشة. وافتراضُها «المناوبة» — ما تعرضه الشاشاتُ الداخليّة
  /// كلُّها من الشروط إلى النجاح.
  final LogoSlotConfig slot;

  @override
  Widget build(BuildContext context) {
    return AuthLogoMark(
      variant: LogoVariant.badgeRing,
      slot: slot,
      size: size.w,
      tone: tone,
    );
  }
}

/// طبقةُ الشعار: تُوضع في `Stack` **فوق** الشاشات، فيسافر بينها ولا يُعاد
/// بناؤه — `AuthLogoLayer`.
class AuthLogoLayer extends StatelessWidget {
  const AuthLogoLayer({
    super.key,
    required this.stop,
    this.tone = AuthBadgeTone.purple,
    this.visible = true,
    this.slot = LogoSlots.inner,
  });

  final AuthLogoStop stop;
  final AuthBadgeTone tone;

  /// ما تعرضه شاشةُ الخطوة — «ابدأ» تبني مرّةً ثمّ تُناوب، وسائرُها تُناوب.
  final LogoSlotConfig slot;

  /// شاشةٌ لا تُظهره (المعاينةُ السريعة ترسم شعارَها في عمودها).
  final bool visible;

  /// أعلى الشعار على شاشةٍ طولُها [height].
  static double topFor(AuthLogoStop stop, double height) => switch (stop) {
    AuthLogoStop.top => AuthXd.logoTop.h,
    // المسافةُ من أسفل الشاشة إلى أعلى الشعار: 932 − 390.
    AuthLogoStop.centre => height - (Xd.designH - AuthXd.logoCentre).h,
  };

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            return Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: AuthSlide.duration,
                  curve: AuthSlide.ease,
                  top: topFor(stop, box.maxHeight),
                  left: 0,
                  right: 0,
                  child: Center(child: AuthBadge(tone: tone, slot: slot)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
