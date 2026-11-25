/// مسرحُ شاشات الدخول — نقلٌ لما يفعله `NewLoginWidget.tsx` في
/// `web_design/NewLoginDesign/`.
///
/// > الشاشاتُ تنزلق داخلَ صندوقٍ واحد، **وطبقةُ الشعار فوقها**: فهو عنصرٌ
/// > واحدٌ لا يُعاد بناؤه، يسافر بين موضعيه ولا يدخل في الانزلاق.
/// >
/// > والانزلاق: الجديدةُ تدخل من اليمين والقديمةُ تخرج يساراً، وكلتاهما تخبو
/// > — ويُعكس الاتّجاهُ عند الرجوع خطوةً.
library;

import 'package:flutter/material.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_logo_motion.dart';

/// خطواتُ المسار — `AuthStep`.
enum AuthStep {
  quickPreview,
  countryPicker,
  getStarted,
  terms,
  enterPhone,
  selectMethod,
  enterPin,
  alreadyRegistered,
  notRegistered,
  inputName,
  loginSuccess,
  signupSuccess,
  qrLogin,
}

/// أين يستقرّ الشعارُ في كلّ خطوة، وبأيّ لون.
///
/// سبعُ خطواتٍ تقرأ 116 فيسكن بينها، و«ابدأ» و«الشروط» تقرآن 390. والمعاينةُ
/// السريعةُ ومنتقي الدولة ترسمان شعارَهما في عمودهما، فلا تُظهران هذا.
({AuthLogoStop stop, AuthBadgeTone tone, bool visible, LogoSlotConfig slot})
authLogoFor(AuthStep step) => switch (step) {
  AuthStep.quickPreview || AuthStep.countryPicker || AuthStep.qrLogin => (
    stop: AuthLogoStop.top,
    tone: AuthBadgeTone.purple,
    visible: false,
    slot: LogoSlots.quickPreviewBadge,
  ),
  // و«ابدأ» وحدَها سلسلةٌ: تبني مرّةً ثمّ تُناوب إلى الأبد. والشروطُ تُناوب.
  AuthStep.getStarted => (
    stop: AuthLogoStop.centre,
    tone: AuthBadgeTone.purple,
    visible: true,
    slot: LogoSlots.getStarted,
  ),
  AuthStep.terms => (
    stop: AuthLogoStop.centre,
    tone: AuthBadgeTone.purple,
    visible: true,
    slot: LogoSlots.inner,
  ),
  // XD يُعيد تلوين الحلقة والنقطتين وحدَه. وفي «غيرُ مسجَّل» تتحوّل
  // **النقطتان** فقط إلى الكهرمانيّ — والحلقةُ تبقى بنفسجيّةَ المسار.
  AuthStep.notRegistered => (
    stop: AuthLogoStop.top,
    tone: AuthBadgeTone.amber,
    visible: true,
    slot: LogoSlots.inner,
  ),
  AuthStep.inputName || AuthStep.signupSuccess => (
    stop: AuthLogoStop.top,
    tone: AuthBadgeTone.green,
    visible: true,
    slot: LogoSlots.inner,
  ),
  _ => (
    stop: AuthLogoStop.top,
    tone: AuthBadgeTone.purple,
    visible: true,
    slot: LogoSlots.inner,
  ),
};

class AuthStageV2 extends StatelessWidget {
  const AuthStageV2({
    super.key,
    required this.step,
    required this.child,
    this.forward = true,
  });

  final AuthStep step;

  /// شاشةُ الخطوة الحاليّة.
  final Widget child;

  /// إلى الأمام: الجديدةُ من اليمين. وإلى الوراء: من اليسار.
  final bool forward;

  @override
  Widget build(BuildContext context) {
    final double from = forward ? 1 : -1;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: AuthSlide.duration,
              switchInCurve: AuthSlide.ease,
              switchOutCurve: AuthSlide.ease,
              // الداخلةُ فوق الخارجة، وكلتاهما تشغل الصندوق كلَّه.
              layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
                children: <Widget>[
                  ...previous.map((Widget w) => Positioned.fill(child: w)),
                  if (current != null) Positioned.fill(child: current),
                ],
              ),
              transitionBuilder: (Widget screen, Animation<double> t) {
                // `t` يمضي من 0 إلى 1 للداخلة، ويرجع من 1 إلى 0 للخارجة —
                // فإزاحةٌ واحدةٌ تخدم الحالين: الداخلةُ تأتي من `from`
                // والخارجةُ تذهب إلى ضدِّه.
                return FadeTransition(
                  opacity: t,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(from, 0),
                      end: Offset.zero,
                    ).animate(t),
                    child: screen,
                  ),
                );
              },
              child: KeyedSubtree(key: ValueKey<AuthStep>(step), child: child),
            ),
          ),
        ),
        Builder(
          builder: (BuildContext context) {
            final ({
              AuthLogoStop stop,
              AuthBadgeTone tone,
              bool visible,
              LogoSlotConfig slot,
            })
            logo = authLogoFor(step);
            return AuthLogoLayer(
              stop: logo.stop,
              tone: logo.tone,
              visible: logo.visible,
              slot: logo.slot,
            );
          },
        ),
      ],
    );
  }
}
