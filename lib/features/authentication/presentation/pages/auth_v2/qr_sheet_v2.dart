/// نافذةُ QR — نقلٌ لـ`web_design/NewLoginDesign/QrBottomSheet.tsx`
/// (لوح `Registration - 1`).
///
/// > **والفرقُ الوحيد: الجهةُ.** الويبُ يولّد الرمزَ ويعرضه وينتظر، والتطبيقُ
/// > يصوّره. فشبكةُ اللوح تُنقل كما هي — رأسُ النافذة على 90، ونصفُ قطرها 30،
/// > ومقبضُها 40×2 على 102، وصندوقٌ 250×250 على (90، 171.5)، والنصُّ بعده
/// > بـ70 — ويبقى في الصندوق **كاميرا** بدل الرمز.
/// >
/// > وحالاتُ الويب الأربعُ تُنقل بمعناها على جهتنا، لا تُخترع:
/// >   - `loading` دوّارةٌ 32 بسماكة 3 `#388CFF` — كما هي: الويبُ ينتظر جلسةً
/// >     والتطبيقُ ينتظر الكاميرا؛
/// >   - `pending` خطُّ المسح يمضي ويعود في 2.4ث. والويبُ يُظهره عند `scanned`
/// >     لأنّه خبرُ أنّ هاتفاً قرأ؛ وهنا القراءةُ هي عملُنا نحن، فالخطُّ هو
/// >     دليلُ المسح؛
/// >   - `scanned` قرأنا رمزاً ونتحقّق: المنظرُ يخبو إلى 0.3 في 300مث —
/// >     خبوُّ الويب نفسُه بالقيمة والمدّة؛
/// >   - `rejected`/`error` بطاقةٌ بيضاءُ فوق الإطار: 14 Medium ثمّ رابطٌ 13
/// >     مسطورٌ `#388CFF` — بطاقةُ «أظهر رمزاً جديداً» نفسُها، وكلمتُها عندنا
/// >     «حاول مرّةً أخرى».
/// >
/// > والأركانُ الأربعةُ وحدَها ليست في الويب: فلا إطارَ مسحٍ في صفحةٍ تعرض
/// > رمزاً. فأُخذ لها نصفُ قطر صناديق الملفّ (20) وأزرقُه (`#388CFF`).
///
/// والمنطقُ ليس هنا: النافذةُ تُسلّم ما قرأته إلى [onPayload]، وحفظُ الحساب
/// وأحداثُ `AuthBloc` تبقى حيث هي في `qr_login_scanner_page.dart`.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_parts.dart';

/// حالاتُ النافذة — `QrStatus` في الويب، بأسمائها.
enum QrSheetStatus { loading, pending, scanned, rejected, error }

class QrSheetV2 extends StatefulWidget {
  const QrSheetV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.onPayload,
    this.declined = false,
  });

  final bool open;
  final VoidCallback onClose;

  /// ما قرأته الكاميرا، خاماً كما كُتب في الرمز. و`false` تعني «لم يُقبل»،
  /// فتُظهر النافذةُ بطاقةَ المحاولة.
  final Future<bool> Function(String raw) onPayload;

  /// رُفض الدخولُ على الجهة الأخرى. والويبُ يعرفه بسؤالٍ كلَّ ثانية
  /// (`getQrStatus`)؛ وهنا يأتي من فوق، فلا سؤالَ في طبقة التصميم.
  final bool declined;

  @override
  State<QrSheetV2> createState() => _QrSheetV2State();
}

class _QrSheetV2State extends State<QrSheetV2>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _camera;

  QrSheetStatus _status = QrSheetStatus.loading;
  bool _denied = false;

  /// نصُّ بطاقة المحاولة، مترجَماً عند وضعه.
  String? _problem;

  /// خطُّ المسح: ذهابٌ وعودةٌ في [AuthXd.qrLaserPeriod]، فنصفُها لكلّ شوط.
  late final AnimationController _laser = AnimationController(
    duration: AuthXd.qrLaserPeriod ~/ 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    if (widget.open) _start();
  }

  @override
  void didUpdateWidget(QrSheetV2 old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) {
      _start();
    } else if (!widget.open && old.open) {
      _stop();
    }
    if (widget.declined && !old.declined) {
      _fail(
        QrSheetStatus.rejected,
        LocaleKeys.login_was_declined_on_your_phone.tr(),
      );
    }
  }

  @override
  void dispose() {
    _laser.dispose();
    _camera?.dispose();
    super.dispose();
  }

  /// الإذنُ ثمّ الكاميرا — المنطقُ نفسُه الذي في `qr_login_scanner_page.dart`.
  Future<bool> _ensureCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _start() async {
    setState(() {
      _status = QrSheetStatus.loading;
      _problem = null;
      _denied = false;
    });
    final bool granted = await _ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      _denied = true;
      _fail(
        QrSheetStatus.error,
        LocaleKeys.camera_permission_required_message.tr(),
      );
      return;
    }
    final MobileScannerController camera = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _camera = camera;
    await camera.start();
    if (!mounted) return;
    setState(() => _status = QrSheetStatus.pending);
    _laser.repeat(reverse: true);
  }

  Future<void> _stop() async {
    _laser.stop();
    final MobileScannerController? camera = _camera;
    _camera = null;
    await camera?.dispose();
  }

  void _fail(QrSheetStatus status, String message) {
    _laser.stop();
    if (!mounted) return;
    setState(() {
      _status = status;
      _problem = message;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_status != QrSheetStatus.pending) return;
    String? raw;
    for (final Barcode code in capture.barcodes) {
      final String? value = code.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    setState(() => _status = QrSheetStatus.scanned);
    final bool accepted = await widget.onPayload(raw);
    if (!mounted || accepted) return;
    _fail(QrSheetStatus.error, LocaleKeys.qr_invalid_code_message.tr());
  }

  /// مواضعُ اللوح تُقرأ من رأس اللوح، وطفلُ النافذة يبدأ تحت المقبض — فيُطرح
  /// رأسُها وطرفُ مقبضها.
  double _below(double boardY) =>
      boardY - AuthXd.qrSheetTop - XdSheet.handleEnd;

  @override
  Widget build(BuildContext context) {
    return XdSheetLayer(
      open: widget.open,
      y: AuthXd.qrSheetTop,
      // ونصفُ قطرها [AuthXd.qrSheetRadius] — وهو 30 نفسُه الذي تأخذه
      // النافذةُ افتراضاً من الملفّ، فلا يُكرَّر.
      onClose: widget.onClose,
      child: Stack(
        children: <Widget>[
          // الصندوقُ على 90 من اليسار، و(430 − 250) ÷ 2 = 90 — فهو في
          // المنتصف، ولا يتبدّل بالاتّجاه.
          Positioned(
            left: AuthXd.qrCodeLeft.w,
            top: _below(AuthXd.qrCodeTop).h,
            child: _viewfinder(),
          ),
          Positioned.fill(child: _words(context)),
        ],
      ),
    );
  }

  // ── الكلماتُ تحت الصندوق ───────────────────────────────────────────────

  Widget _words(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AuthXd.qrPadX.w,
        right: AuthXd.qrPadX.w,
        bottom: AuthXd.qrPadBottom.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: (AuthXd.qrTextTop - XdSheet.handleEnd).h),
          XdText(
            LocaleKeys.switch_to_the_web.tr(),
            size: 30,
            weight: XdWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AuthXd.qrBlockGap.h),
          SizedBox(
            width: AuthXd.qrParagraphWidth.w,
            child: XdText(
              '“${LocaleKeys.use_your_account_on_the_web_securely.tr()}”',
              size: 13,
              color: AuthColors.dash,
              height: 13 * AuthXd.qrParagraphLineHeight,
              maxLines: 3,
            ),
          ),
          SizedBox(height: AuthXd.qrBlockGap.h),
          _bullet(LocaleKeys.open_trydos_on_the_web.tr()),
          SizedBox(height: AuthXd.qrBulletGap.h),
          _bullet(LocaleKeys.choose_switch_from_your_app.tr()),
          SizedBox(height: AuthXd.qrBulletGap.h),
          _bullet(LocaleKeys.point_your_camera_at_the_code.tr()),
          const Spacer(),
          _privacy(context),
        ],
      ),
    );
  }

  Widget _bullet(String text) => XdText('- $text', size: 14, maxLines: 2);

  /// سطرُ الخصوصيّة: درعٌ 14 ثمّ 4 ثمّ كلماتُه 11، في المنتصف — ثمّ 30
  /// فراغاً، وتُزاد الحافّةُ الآمنة لأنّ النافذةَ تُضيفها إلى طولها.
  Widget _privacy(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Icon(
            Icons.verified_user,
            size: AuthXd.qrShieldSize.w,
            color: AuthColors.termsLink,
          ),
          SizedBox(height: AuthXd.qrShieldGap.h),
          XdText(
            LocaleKeys.your_privacy_is_completely_safe.tr(),
            size: 11,
            color: AuthColors.termsLink,
            align: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(
            height:
                AuthXd.qrBottomSpace.h + MediaQuery.paddingOf(context).bottom,
          ),
        ],
      ),
    );
  }

  // ── الصندوق: كاميرا، وخطُّ مسحٍ، وأركان ────────────────────────────────

  Widget _viewfinder() {
    final bool dim = _status == QrSheetStatus.scanned;
    final bool broken =
        _status == QrSheetStatus.error || _status == QrSheetStatus.rejected;

    return SizedBox(
      width: AuthXd.qrCodeSize.w,
      height: AuthXd.qrCodeSize.w,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: ColoredBox(color: Colors.black)),
                  if (_camera != null)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: dim ? 0.3 : 1,
                        duration: const Duration(milliseconds: 300),
                        // والمنظرُ يُقتصّ لا يُضغط — `BoxFit.cover`، وهو
                        // ما يأخذه الماسحُ افتراضاً، فالصندوقُ مربّعٌ
                        // والكاميرا ليست مربّعة.
                        child: MobileScanner(
                          controller: _camera,
                          onDetect: _onDetect,
                        ),
                      ),
                    ),
                  if (_status == QrSheetStatus.pending) _laserLine(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _QrFramePainter(
                  radius: AuthXd.boxRadius.r,
                  arm: AuthXd.qrFrameArm.w,
                  stroke: AuthXd.qrFrameStroke.w,
                  color: AuthColors.termsLink,
                ),
              ),
            ),
          ),
          if (_status == QrSheetStatus.loading || dim)
            Center(
              child: SizedBox(
                width: AuthXd.qrSpinnerSize.w,
                height: AuthXd.qrSpinnerSize.w,
                child: CircularProgressIndicator(
                  strokeWidth: AuthXd.qrSpinnerStroke.w,
                  color: AuthColors.termsLink,
                ),
              ),
            ),
          if (broken) Center(child: _retryCard()),
        ],
      ),
    );
  }

  /// خطُّ المسح: 3 سماكةً، أزرقُه في الوسط وطرفاه شفّافان، وهالةٌ حوله.
  /// يمضي من أعلى الإطار حتّى يخرج من أسفله ويعود — و`ClipRRect` فوقه تقصّه.
  Widget _laserLine() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _laser, curve: Curves.easeInOut),
      builder: (BuildContext context, Widget? line) => Positioned(
        top: Curves.easeInOut.transform(_laser.value) * AuthXd.qrCodeSize.w,
        left: 0,
        right: 0,
        child: line!,
      ),
      child: Container(
        height: AuthXd.qrLaserHeight.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AuthColors.termsLink.withValues(alpha: 0),
              AuthColors.termsLink.withValues(alpha: 0.95),
              AuthColors.termsLink.withValues(alpha: 0),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AuthColors.termsLink.withValues(alpha: 0.6),
              blurRadius: 14.w,
              spreadRadius: 3.w,
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقةُ المحاولة — بطاقةُ «أظهر رمزاً جديداً» في الويب: بيضاءُ بـ0.95،
  /// حشوتُها 16 وزواياها 16، سطرٌ 14 Medium ثمّ رابطٌ 13 مسطور.
  Widget _retryCard() {
    return XdTap(
      scale: 1,
      onTap: _denied ? _retryPermission : _start,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AuthXd.qrRetryPad.h,
          horizontal: AuthXd.qrRetryPadX.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AuthXd.qrRetryRadius.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            XdText(
              _problem ?? LocaleKeys.qr_invalid_code_message.tr(),
              size: 14,
              weight: XdWeight.medium,
              align: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: AuthXd.qrRetryGap.h),
            Text(
              LocaleKeys.try_again.tr(),
              style:
                  xdTextStyle(
                    size: 13,
                    weight: XdWeight.medium,
                    color: AuthColors.termsLink,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AuthColors.termsLink,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryPermission() async {
    final bool granted = await _ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      _fail(
        QrSheetStatus.error,
        LocaleKeys.camera_permission_still_denied.tr(),
      );
      return;
    }
    await _start();
  }
}

/// أركانُ الإطار الأربعة: ذراعان من كلّ ركن، بنصف قطر صناديق الملفّ.
class _QrFramePainter extends CustomPainter {
  const _QrFramePainter({
    required this.radius,
    required this.arm,
    required this.stroke,
    required this.color,
  });

  final double radius;
  final double arm;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    for (final (bool right, bool bottom) corner in <(bool, bool)>[
      (false, false),
      (true, false),
      (false, true),
      (true, true),
    ]) {
      canvas.save();
      // كلُّ ركنٍ هو الركنُ الأعلى الأيسرُ نفسُه، معكوساً.
      canvas.translate(corner.$1 ? size.width : 0, corner.$2 ? size.height : 0);
      canvas.scale(corner.$1 ? -1 : 1, corner.$2 ? -1 : 1);
      canvas.drawPath(
        Path()
          ..moveTo(stroke / 2, radius + arm)
          ..lineTo(stroke / 2, radius)
          ..arcToPoint(
            Offset(radius, stroke / 2),
            radius: Radius.circular(radius - stroke / 2),
          )
          ..lineTo(radius + arm, stroke / 2),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_QrFramePainter old) =>
      old.radius != radius ||
      old.arm != arm ||
      old.stroke != stroke ||
      old.color != color;
}
