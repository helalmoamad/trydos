import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_design.dart';
import 'wallet_qr.dart';
import 'wallet_sheet_title.dart';

/// معلومات المحفظة — لوح XD `Home Page – 23`.
///
/// > نافذةٌ من y 90 بزوايا علويّة 50. من أعلى إلى أسفل:
/// >   - صفُّ العنوان على y 114، ومعرّفُ العميل (24 Bold) على خطّ الأساس 180؛
/// >   - رمزُ QR، 350.21، على (39.93، 210.32)؛
/// >   - نقطتان 8 على y 573، و«trydos USD» (16) على خطّ الأساس 605؛
/// >   - ثلاثةُ حقولٍ 390 × 55 على y 639 و698 و757، لونُها `#FCFCFC`:
/// >     عنوانٌ رماديّ 12 على خطّ الأساس 20 وقيمةٌ 14 على 43؛
/// >   - أربعةُ إجراءاتٍ على y 855: صورةٌ 20 فوق نصٍّ 11. والنصوص تبدأ على
/// >     x 65 و157 و234 و336.
///
/// والرمز **مولَّدٌ** من معرّف العميل لا صورةَ الملفّ — كصفحة الباركود في
/// البروفايل. وشكلُه شكلُ رموز الملفّ ([WalletQr]).
class WalletInfoSheetV2 extends StatelessWidget {
  const WalletInfoSheetV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.card,
    required this.clientId,
    required this.name,
    required this.phone,
  });

  final bool open;
  final VoidCallback onClose;

  /// الرصيد الذي الرمزُ له.
  final WalletCardData card;

  final String clientId;
  final String name;
  final String phone;

  /// أعلى النافذة على اللوح.
  static const double _top = 90;

  /// رمزُ QR، 350.21 على (39.93، 210.32).
  static const double _qr = 350.21;
  static const double _qrX = 39.93;
  static const double _qrY = 210.32;

  /// النقطتان على y 573، والسطر تحتهما على خطّ الأساس 605.
  static const double _dotsY = 573;
  static const double _brandBaseline = 605;

  /// الحقول الثلاثة على y 639 و698 و757، 390 × 55 على 20 من الحافّتين.
  static const double _fieldX = 20;
  static const double _fieldH = 55;

  /// الإجراءات على y 855، ونصوصُها على خطّ الأساس 892.
  static const double _actionsY = 855;
  static const double _actionLabelBaseline = 892;

  /// الإجراءات الأربعة، و x الذي يبدأ عنده الملفُّ كلَّ نصّ، وكم تزيح
  /// الصورةُ عن مركز نصّها.
  static const List<
    ({String id, String icon, String label, double x, double off})
  >
  _actions = <({String id, String icon, String label, double x, double off})>[
    (
      id: 'request',
      icon: 'infoRequest',
      label: LocaleKeys.request,
      x: 65,
      off: 0.5,
    ),
    (id: 'copy', icon: 'infoCopy', label: LocaleKeys.copy, x: 157, off: 0.5),
    (
      id: 'download',
      icon: 'infoDownload',
      label: LocaleKeys.download,
      x: 234,
      off: -0.5,
    ),
    (id: 'share', icon: 'infoShare', label: LocaleKeys.share, x: 336, off: 0.5),
  ];

  void _act(String id) {
    if (id == 'copy') {
      Clipboard.setData(ClipboardData(text: clientId));
    } else if (id == 'share') {
      SharePlus.instance.share(ShareParams(text: clientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return XdSheetLayer(
      open: open,
      y: _top,
      radius: XdSheet.radiusWallet,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // العنوان ومعرّفُ العميل يثبتان، وما تحتهما يُمرَّر.
          WalletSheetTitle(
            top: _top,
            icon: 'qrDark',
            mark: card.mark,
            label: LocaleKeys.wallet_info.tr(),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(_top + 24 + Xd.lineBox(24), 180, 24).h,
            ),
            child: SizedBox(
              width: 1.sw,
              child: XdText(
                clientId,
                size: 24,
                weight: XdWeight.bold,
                align: TextAlign.center,
              ),
            ),
          ),
          Expanded(child: _under(context)),
        ],
      ),
    );
  }

  Widget _under(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // الرمز على x 39.93 من لوح 430، محفوظةً مسافتُه عن المركز، ويبقى
          // 350 على كلّ هاتف.
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: (_qrY - Xd.textBottom(180, 24)).h,
              start: 1.sw / 2 - (Xd.designW / 2 - _qrX).w,
            ),
            child: WalletQr(data: clientId, size: _qr),
          ),
          // النقطتان على (205، 573) و(217، 573): 20 عرضاً معاً، موسَّطتان.
          Padding(
            padding: EdgeInsets.only(top: (_dotsY - (_qrY + _qr)).h),
            child: SizedBox(
              width: 1.sw,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const XdSvg('dotDark', folder: kWalletSvg, w: 8),
                  SizedBox(width: 4.w),
                  const XdSvg('dotBlueOff', folder: kWalletSvg, w: 8),
                ],
              ),
            ),
          ),
          // الملفّ يبدأ هذا السطر على x 172: نصفَ بكسلٍ يسارَ المركز.
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(_dotsY + 8, _brandBaseline, 16).h,
              right: 1.w,
            ),
            child: SizedBox(
              width: 1.sw,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'try',
                      style: xdTextStyle(size: 16, weight: XdWeight.bold),
                    ),
                    TextSpan(text: 'dos', style: xdTextStyle(size: 16)),
                    TextSpan(
                      text: ' ${card.code}',
                      style: xdTextStyle(size: 16, weight: XdWeight.medium),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          _field(
            mt: 639 - Xd.textBottom(_brandBaseline, 16),
            label: LocaleKeys.trydos_client_name.tr(),
            value: name,
            eye: true,
          ),
          _field(
            mt: 698 - (639 + _fieldH),
            label: LocaleKeys.trydos_client_id.tr(),
            value: clientId,
            medium: true,
          ),
          _field(
            mt: 757 - (698 + _fieldH),
            label: LocaleKeys.trydos_client_phone_number.tr(),
            value: phone,
            medium: true,
          ),
          _actionsRow(),
          SizedBox(height: 35.h + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  /// حقلٌ للقراءة: عنوانٌ رماديّ 12 على خطّ الأساس 20، وقيمةٌ 14 على 43.
  Widget _field({
    required double mt,
    required String label,
    required String value,
    bool medium = false,
    bool eye = false,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: _fieldX.w),
      child: Container(
        width: Xd.fill(_fieldX),
        height: _fieldH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  XdText(label, size: 12, color: XdColors.grey),
                  Padding(
                    padding: EdgeInsets.only(
                      top: Xd.gapTo(8 + Xd.lineBox(12), 43, 14).h,
                    ),
                    child: XdText(
                      value,
                      size: 14,
                      weight: medium ? XdWeight.medium : XdWeight.regular,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (eye)
              Padding(
                padding: EdgeInsets.only(top: (20 - 8).h),
                child: const XdSvg('eyeGrey', folder: kWalletSvg, w: 16),
              ),
          ],
        ),
      ),
    );
  }

  /// صفُّ الإجراءات: كلُّ خانةٍ تمتدّ من بداية نصٍّ إلى بداية التالي،
  /// فيحلّ كلُّ نصٍّ على x الملفّ. والنصوص تنتهي على y 895.
  Widget _actionsRow() {
    return Padding(
      padding: EdgeInsets.only(top: (_actionsY - (757 + _fieldH)).h),
      child: SizedBox(
        width: 1.sw,
        child: Row(
          children: <Widget>[
            SizedBox(width: _actions.first.x.w),
            for (int i = 0; i < _actions.length; i++)
              Expanded(
                flex: i == _actions.length - 1
                    ? ((Xd.designW - _actions[i].x) * 100).round()
                    : ((_actions[i + 1].x - _actions[i].x) * 100).round(),
                // الإجراءُ في أوّل خانته بعرض أوسعِ ما فيه، فيحلّ نصُّه على
                // x الملفّ وتتوسّط الصورةُ فوقه.
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: _action(_actions[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _action(
    ({String id, String icon, String label, double x, double off}) a,
  ) {
    return XdTap(
      scale: 0.92,
      onTap: () => _act(a.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // الصورة موسَّطةٌ فوق نصّها ثمّ تزيح عنه بالقدر الذي في الملفّ:
          // حشوةٌ على جانبٍ واحدٍ ضعفَ الإزاحة.
          Padding(
            padding: EdgeInsets.only(
              left: a.off > 0 ? (a.off * 2).w : 0,
              right: a.off < 0 ? (-a.off * 2).w : 0,
            ),
            child: XdSvg(a.icon, folder: kWalletSvg, w: 20),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(_actionsY + 20, _actionLabelBaseline, 11).h,
            ),
            child: XdText(a.label.tr(), size: 11),
          ),
        ],
      ),
    );
  }
}
