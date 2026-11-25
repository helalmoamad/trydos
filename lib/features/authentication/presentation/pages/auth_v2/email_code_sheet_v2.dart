/// نافذةُ رمز البريد — نقلٌ لـ`EmailCodeSheet.tsx` في
/// `web_design/components/DemoApp1/screens/`؛ لوح `Home Page – 90`.
///
/// > «تعتم الصفحةُ وتصعد نافذةٌ من 90: «تحقّقُ البريد !» 30 Bold على قاعدة
/// > 318، والسطرُ تحتها 16 Medium على 354، والعنوانُ مع «أعد الإرسال -
/// > 01:58» صفٌّ 15 من 366، وسطرُ الخصوصيّة البنفسجيُّ بدرعه صفٌّ 14 من 389،
/// > وصناديقُ الرمز الستّةُ على 502 — **صناديقُ الدخول نفسُها**، فلا يفترق
/// > المسارانِ. والكلُّ على 40، والصناديقُ على 20.»
///
/// ونافذةٌ واحدةٌ للديمو ولشاشات الملفّ الشخصيّ: المتّصل يُعطي الخطوتين —
/// [EmailCodeSheetV2.send] تطلب رمزاً (عند الفتح وعند «أعد الإرسال»)، و
/// [EmailCodeSheetV2.check] تفحص الأرقامَ الستّة. فلا تعرف هذه الطبقةُ
/// نقطةَ وصلٍ ولا تُنادي واحدة.
library;

import 'dart:async';
// `easy_localization` تُصدِّر `intl` وفيها `TextDirection` أخرى بثابتين
// `LTR`/`RTL` — فيُسمّى اتّجاهُ الرسم باسمه الكامل.
import 'dart:ui' as ui show TextDirection;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/features/wallet/presentation/pages/wallet_pin_boxes.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_logo.dart';
import 'demo_design.dart';

/// جوابُ خطوةٍ — صورةُ `SendEmailCodeResult`/`VerifyEmailCodeResult` نفسُها:
/// إمّا تمّت، وإمّا مشكلةٌ بكلماتها.
class EmailCodeAnswer {
  /// تمّت: ذهب الرمزُ (أو صحَّ)، وهذه مهلةُ الإعادة.
  const EmailCodeAnswer.done({this.resendAfterSeconds = 0})
    : words = null,
      wrongCode = false,
      endsTheCode = false,
      endsTheSheet = false;

  /// لم تتمّ: [words] مترجَمةً عند المتّصل — ولا تُعرض رسالةُ الخادم كما هي.
  const EmailCodeAnswer.problem(
    this.words, {
    this.resendAfterSeconds = 0,
    this.wrongCode = false,
    this.endsTheCode = false,
    this.endsTheSheet = false,
  });

  final String? words;
  final int resendAfterSeconds;

  /// رمزٌ خاطئ: الصناديقُ تهتزّ حمراءَ ثمّ تفرغ للمحاولة التالية.
  final bool wrongCode;

  /// مات الرمزُ (انتهى، أو نفدت المحاولات): لا يُفيد إلّا «أعد الإرسال».
  final bool endsTheCode;

  /// ولا شيءَ في هذه النافذة يُفيد (البريدُ مأخوذ، أو حسابُ زائر).
  final bool endsTheSheet;

  bool get ok => words == null;
}

class EmailCodeSheetV2 extends StatefulWidget {
  const EmailCodeSheetV2({
    super.key,
    required this.email,
    required this.send,
    required this.check,
    required this.onClose,
    required this.onVerified,
  });

  /// العنوانُ المطلوبُ تحقّقُه. والنافذةُ مفتوحةٌ ما لم يكن `null`.
  final String? email;

  final Future<EmailCodeAnswer> Function(String email) send;
  final Future<EmailCodeAnswer> Function(String email, String code) check;

  final VoidCallback onClose;

  /// رمزٌ صحيح.
  final ValueChanged<String> onVerified;

  @override
  State<EmailCodeSheetV2> createState() => _EmailCodeSheetV2State();
}

class _EmailCodeSheetV2State extends State<EmailCodeSheetV2> {
  /// ما بقي من مهلة الإعادة بالثواني.
  int _left = 0;
  Timer? _clock;

  /// طلبٌ في الطريق: الصناديقُ تنتظر.
  bool _busy = false;

  /// الكلماتُ تحت الصناديق.
  String? _problem;

  bool _dead = false;
  bool _ended = false;
  WalletPinState _state = WalletPinState.typing;

  /// أيُّ فتحةٍ للنافذة ينتمي هذا الجواب: جوابٌ يرجع بعد الإغلاق، أو بعد
  /// فتحةٍ لعنوانٍ آخر، يُطرَح.
  int _round = 0;

  /// الصناديقُ تملك كتابتَها، فتُركَّب من جديدٍ لتفرغ — وهو ما يفعله الويب
  /// بتبديل `key`.
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) _open(widget.email!);
  }

  @override
  void didUpdateWidget(EmailCodeSheetV2 old) {
    super.didUpdateWidget(old);
    if (widget.email == old.email) return;
    if (widget.email != null) {
      _open(widget.email!);
    } else {
      _clock?.cancel();
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _open(String email) {
    _round += 1;
    setState(() {
      _problem = null;
      _dead = false;
      _ended = false;
      _left = 0;
      _state = WalletPinState.typing;
      _attempt += 1;
    });
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      if (mounted && _left > 0) setState(() => _left -= 1);
    });
    _ask(email);
  }

  Future<void> _ask(String email) async {
    final int mine = _round;
    setState(() => _busy = true);
    final EmailCodeAnswer answer = await widget.send(email);
    if (!mounted || mine != _round) return;
    setState(() {
      _busy = false;
      _left = answer.resendAfterSeconds;
      if (answer.ok) {
        _problem = null;
        _dead = false;
        _state = WalletPinState.typing;
        _attempt += 1;
        return;
      }
      _problem = answer.words;
      // ولا رمزَ ذهب: الصناديقُ تُغلق حتّى تنجح الإعادة.
      _ended = answer.endsTheSheet;
      _dead = !answer.endsTheSheet;
    });
  }

  Future<void> _submit(String code) async {
    final String? email = widget.email;
    if (email == null) return;
    final int mine = _round;
    setState(() => _busy = true);
    final EmailCodeAnswer answer = await widget.check(email, code);
    if (!mounted || mine != _round) return;
    if (answer.ok) {
      setState(() {
        _busy = false;
        _problem = null;
        _state = WalletPinState.valid;
      });
      // لحظةٌ على الصناديق الخضراء ثمّ تُسلّم — 600 كما في الويب.
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted && mine == _round) widget.onVerified(email);
      });
      return;
    }
    setState(() {
      _busy = false;
      _problem = answer.words;
      _state = answer.wrongCode
          ? WalletPinState.invalid
          : WalletPinState.typing;
      if (answer.endsTheCode) _dead = true;
      if (answer.endsTheSheet) _ended = true;
    });
    if (answer.wrongCode) {
      // تهتزّ حمراءَ ثمّ تفرغ — 700 كما في الويب.
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted && mine == _round) setState(() => _attempt += 1);
      });
    }
  }

  bool get _canResend =>
      _left == 0 && !_busy && !_ended && _state != WalletPinState.valid;

  bool get _closed => _dead || _ended;

  String get _clockText {
    final String m = (_left ~/ 60).toString().padLeft(2, '0');
    final String s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// طرفُ مقبض النافذة على اللوح: 90 + 13.
  static double get _childTop => EmailCodeXd.top + XdSheet.handleEnd;

  @override
  Widget build(BuildContext context) {
    return XdSheetLayer(
      open: widget.email != null,
      y: EmailCodeXd.top,
      onClose: widget.onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: Xd.gapTo(_childTop, EmailCodeXd.title, 30).h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: EmailCodeXd.textLeft.w),
            child: XdText(
              LocaleKeys.verification_email_excl.tr(),
              size: 30,
              weight: XdWeight.bold,
            ),
          ),
          SizedBox(
            height: Xd.gapTo(
              Xd.textBottom(EmailCodeXd.title, 30),
              EmailCodeXd.line,
              16,
            ).h,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: EmailCodeXd.textLeft.w),
            child: SizedBox(
              width: Xd.fill(EmailCodeXd.textLeft, EmailCodeXd.boxesLeft),
              child: XdText(
                LocaleKeys.enter_verification_code_sent_to_your_email.tr(),
                size: 16,
                weight: XdWeight.medium,
                maxLines: 2,
              ),
            ),
          ),
          SizedBox(
            height:
                (EmailCodeXd.rowTop - Xd.textBottom(EmailCodeXd.line, 16)).h,
          ),
          _addressRow(),
          SizedBox(
            height:
                (EmailCodeXd.privacyTop -
                        (EmailCodeXd.rowTop + EmailCodeXd.rowHeight))
                    .h,
          ),
          _privacyRow(),
          SizedBox(
            height:
                (EmailCodeXd.boxesTop -
                        (EmailCodeXd.privacyTop + EmailCodeXd.privacyHeight))
                    .h,
          ),
          // الصناديقُ كتلةٌ ثابتةٌ 390، والملفُّ يُوسّطها على 20 من الحافّتين.
          Center(
            child: Stack(
              // الرسالةُ تخرج من أسفل الصناديق ولا تُقصّ — انظر [_message].
              clipBehavior: Clip.none,
              children: <Widget>[
                WalletPinBoxes(
                  key: ValueKey<int>(_attempt),
                  state: _closed ? WalletPinState.expired : _state,
                  autoFocus: !_closed,
                  onComplete: _submit,
                ),
                if (_problem != null && _problem!.isNotEmpty)
                  _message(_problem!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// صفُّ العنوان: البريدُ 12 Medium (دائماً من اليسار إلى اليمين)، ثمّ 5،
  /// ثمّ «أعد الإرسال - 01:58»، ثمّ 3.5، ثمّ علامةُ الاستفهام.
  Widget _addressRow() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: EmailCodeXd.textLeft.w),
      child: SizedBox(
        height: EmailCodeXd.rowHeight.h,
        child: Row(
          children: <Widget>[
            Flexible(
              child: Directionality(
                // العنوانُ لا يُقلب مع اللغة.
                textDirection: ui.TextDirection.ltr,
                child: XdText(
                  widget.email ?? '',
                  size: 12,
                  weight: XdWeight.medium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (!_ended) ...<Widget>[
              SizedBox(width: EmailCodeXd.resendGap.w),
              XdTap(
                scale: 1,
                onTap: _canResend && widget.email != null
                    ? () => _ask(widget.email!)
                    : null,
                child: _left > 0
                    ? Row(
                        children: <Widget>[
                          XdText(
                            '${LocaleKeys.resend_after.tr()} -',
                            size: 12,
                            color: XdColors.hint,
                          ),
                          SizedBox(width: 4.w),
                          XdText(
                            _clockText,
                            size: 12,
                            weight: XdWeight.medium,
                            color: XdColors.blue,
                          ),
                        ],
                      )
                    : XdText(
                        LocaleKeys.resend_code.tr(),
                        size: 12,
                        weight: XdWeight.medium,
                        color: XdColors.blue,
                      ),
              ),
            ],
            SizedBox(width: EmailCodeXd.helpGap.w),
            SvgPicture.asset(
              'assets/svg/$kDemoSvg/otpHelp.svg',
              width: 16.w,
              height: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  /// سطرُ الخصوصيّة: 11 بنفسجيٌّ ثمّ 6 ثمّ الدرع.
  Widget _privacyRow() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: EmailCodeXd.textLeft.w),
      child: SizedBox(
        height: EmailCodeXd.privacyHeight.h,
        child: Row(
          children: <Widget>[
            XdText(
              LocaleKeys.your_privacy_is_completely_safe.tr(),
              size: 11,
              color: XdColors.purple,
            ),
            SizedBox(width: EmailCodeXd.shieldGap.w),
            SvgPicture.asset(
              'assets/svg/$kAuthSvg/shield.svg',
              width: 14.w,
              height: 14.w,
            ),
          ],
        ),
      ),
    );
  }

  /// الكلماتُ تحت الصناديق. واللوحُ لا يُعطيها y؛ فهي على بُعد لوح الدخول
  /// نفسِه: صناديقُه على 503 ورسالتُه على 561 — **58 تحت أعلاها**، أي أنّها
  /// تعلو حافّتها السفلى بـ2 (فالصناديقُ 60). فهي موضوعةٌ وضعاً مطلقاً كما
  /// في لوح الدخول، لا بهامشٍ في عمود — ولا هامشَ سالبٌ في Flutter.
  Widget _message(String text) {
    return Positioned(
      top: 58.h,
      left: 0,
      right: 0,
      child: XdText(
        text,
        size: 11,
        weight: XdWeight.medium,
        color: XdColors.red,
        align: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}
