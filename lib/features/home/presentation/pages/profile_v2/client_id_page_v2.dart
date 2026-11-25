import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// معرّف العميل — لوح XD `Home Page – 81`، والصورة التي يحفظها (`– 82`).
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/ClientIdScreen.tsx`:
///
/// > رمز QR 250 × 250 على (90، 120)، والمعرّف تحته («1012-3456» Medium
/// > و«ID» Regular، 16، موسَّطاً على خطّ الأساس 394)، وبطاقتان 382 × 55 على
/// > (24، 448) و(24، 507) — الاسم بشارة التوثيق الزرقاء، ثمّ الهاتف —
/// > و«نسخ» و«تنزيل» و«مشاركة» في الأسفل.
/// >
/// > وكلُّ إجراءٍ هدفٌ 60 × 50، بينها 30، من x 94، و32 فوق الأسفل.
///
/// وفرقٌ عن الملفّ: الويب يرسم رمز QR الساكن الذي في الملفّ ويقول إنّه
/// «يُستبدَل بمولَّدٍ حين يأتي معرّف العميل من الخادم» — وعندنا المعرّف
/// موجود، فالرمز **مولَّدٌ منه** بـ`qr_flutter`.
class ClientIdPageV2 extends StatefulWidget {
  const ClientIdPageV2({
    super.key,
    required this.clientId,
    required this.name,
    required this.phone,
    required this.verified,
  });

  final String clientId;

  /// اسم العميل، أو فراغٌ فيُكتب «أدخل اسمك !» بلون التلميح.
  final String name;
  final String phone;

  /// موثَّق: تظهر الشارة الزرقاء بعد الاسم.
  final bool verified;

  @override
  State<ClientIdPageV2> createState() => _ClientIdPageV2State();
}

class _ClientIdPageV2State extends State<ClientIdPageV2> {
  /// ما يُلتقَط صورةً عند «تنزيل».
  final GlobalKey _card = GlobalKey();

  /// رمز QR 250 على (90، 120)، والمعرّف على خطّ الأساس 394.
  static const double _qr = 250;
  static const double _qrY = 120;
  static const double _idBaseline = 394;

  /// البطاقتان 382 × 55 على (24، 448) و(24، 507).
  static const double _cardX = 24;
  static const double _cardH = 55;
  static const double _firstCardY = 448;
  static const double _secondCardY = 507;

  /// الإجراءات: هدفٌ 60 × 50، بينها 30، و32 فوق الأسفل، ونصُّها على خطّ
  /// الأساس 893.
  static const double _actionW = 60;
  static const double _actionH = 50;
  static const double _actionGap = 30;
  static const double _actionsTop = 850;
  static const double _actionLabelBaseline = 893;

  String get _display =>
      widget.name.isEmpty ? LocaleKeys.enter_your_name.tr() : widget.name;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.clientId));
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(text: '${LocaleKeys.client_id.tr()}: ${widget.clientId}'),
    );
  }

  /// يحفظ البطاقة صورةً — `– 82` في الملفّ.
  ///
  /// والويب يرسم لوحاً 430 × 932 على `canvas`؛ وعندنا تُلتقَط الكتلةُ
  /// المعروضة نفسها (الرمز والمعرّف والبطاقتان) بـ`RepaintBoundary`.
  Future<void> _download() async {
    try {
      final RenderRepaintBoundary? box =
          _card.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (box == null) return;
      final ui.Image image = await box.toImage(pixelRatio: 3);
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (data == null) return;
      await FileSaver.instance.saveFile(
        name: 'trydos-${widget.clientId}',
        bytes: data.buffer.asUint8List(),
        ext: 'png',
        mimeType: MimeType.png,
      );
    } catch (e) {
      devLog('client_id_page_v2: download failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return XdScreenPage(
      header: XdScreenHeader(
        title: LocaleKeys.client_id.tr(),
        // الملفّ يُوسّط هذا العنوان بالعين، أيسرَ بـ1.67.
        nudge: -1.67,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      footer: _actions(context),
      child: RepaintBoundary(
        key: _card,
        child: ColoredBox(
          color: XdColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: (_qrY - kXdBodyY).h),
                child: Center(
                  child: QrImageView(
                    data: widget.clientId,
                    size: _qr.w,
                    backgroundColor: XdColors.white,
                    padding: EdgeInsets.zero,
                    // حوافّ شبه دائريّة كرمز الملفّ: العيون الثلاث والنقاط
                    // مستديرة لا مربّعة.
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: XdColors.ink,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: XdColors.ink,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: Xd.gapTo(370, _idBaseline, 16).h),
                child: SizedBox(
                  width: 1.sw,
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: widget.clientId,
                          style: xdTextStyle(size: 16, weight: XdWeight.medium),
                        ),
                        TextSpan(
                          text: ' ${LocaleKeys.id_label.tr()}',
                          style: xdTextStyle(size: 16),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
              _nameCard(),
              _phoneCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameCard() {
    return _card2(
      top: (_firstCardY - Xd.textBottom(_idBaseline, 16)),
      label: LocaleKeys.client_name.tr(),
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: XdText(
              _display,
              size: 14,
              weight: XdWeight.medium,
              color: widget.name.isEmpty ? XdColors.hint : XdColors.ink,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.name.isNotEmpty && widget.verified) ...<Widget>[
            SizedBox(width: 3.w),
            Transform.translate(
              offset: Offset(0, -2.h),
              child: const XdSvg('verifiedBadge', folder: kXdSharedSvg, w: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _phoneCard() {
    return _card2(
      top: _secondCardY - (_firstCardY + _cardH),
      label: LocaleKeys.client_phone_number.tr(),
      value: XdText(
        widget.phone,
        size: 14,
        weight: XdWeight.medium,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _card2({
    required double top,
    required String label,
    required Widget value,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: top.h, start: _cardX.w),
      child: Container(
        width: Xd.fill(_cardX),
        height: _cardH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // الملفّ يضع العنوان 0.3 يسارَ القيمة.
            Transform.translate(
              offset: Offset(-0.3.w, 0),
              child: XdText(label, size: 12, color: XdColors.grey),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: value,
            ),
          ],
        ),
      ),
    );
  }

  /// مثبّتةٌ أسفل الصفحة كأزرار تسجيل الدخول. والحشوة اليمنى 2 تضع مركز
  /// المجموعة بكسلاً يسارَ الوسط، كما في الملفّ.
  Widget _actions(BuildContext context) {
    final List<
      ({String icon, double w, double h, String label, VoidCallback tap})
    >
    actions =
        <({String icon, double w, double h, String label, VoidCallback tap})>[
          (icon: 'copy', w: 21, h: 21, label: LocaleKeys.copy.tr(), tap: _copy),
          (
            icon: 'download',
            w: 21.01,
            h: 21,
            label: LocaleKeys.download.tr(),
            tap: _download,
          ),
          (
            icon: 'share',
            w: 20,
            h: 20,
            label: LocaleKeys.share.tr(),
            tap: _share,
          ),
        ];
    return Padding(
      padding: EdgeInsets.only(
        right: 2.w,
        bottom: 32.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < actions.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: _actionGap.w),
            _action(actions[i]),
          ],
        ],
      ),
    );
  }

  Widget _action(
    ({String icon, double w, double h, String label, VoidCallback tap}) a,
  ) {
    return XdTap(
      scale: 0.9,
      onTap: a.tap,
      child: SizedBox(
        width: _actionW.w,
        height: _actionH.h,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.5.h),
              child: XdSvg(a.icon, folder: kXdSharedSvg, w: a.w, h: a.h),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: (_actionLabelBaseline - 11 - _actionsTop - (5.5 + a.h)).h,
              ),
              // `OverflowBox` يأخذ حجمه من `constraints.biggest`، و`Column`
              // يُعطي أبناءه ارتفاعاً غير محدود — فيلزم حدٌّ، وهو صندوق
              // سطر النصّ.
              child: SizedBox(
                height: Xd.lineBox(11).h,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  child: XdText(a.label, size: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
