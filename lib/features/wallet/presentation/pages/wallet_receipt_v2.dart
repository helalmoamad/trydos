import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_qr.dart';

/// الإيصال — لوح XD `Home Page – 18`.
///
/// > بطاقةٌ بيضاء 406 × 568 على (12، 149) بزوايا 50، فوق المحفظة. وما خلفها
/// > مغطّىً بـ`#1D1D1D` بنصف شفافيّة ومُمَوَّهٌ بتمويه الملفّ (15.4).
/// >
/// > في البطاقة من أعلى إلى أسفل:
/// >   - العلامة 50 على (190، 161)، و«إيصال» (40 Medium) على خطّ الأساس 255؛
/// >   - رمز QR، 69.72، على (180، 277)، ورقمُه (16 Medium) على 367؛
/// >   - الخلايا، 50 طولاً، `#FCFCFC` بزاوية 15، بينها 4، من y 383: عنوانٌ
/// >     رماديّ 11 على خطّ الأساس 19 وقيمةٌ 13 على 39، 12 من الداخل؛
/// >   - الشعار على (174.72، 625)؛
/// >   - التنزيلُ والمشاركة على y 664: صورةٌ 20 فوق نصٍّ 11. والنصّان يبدآن
/// >     على x 145 و252.
class WalletReceiptV2 extends StatelessWidget {
  const WalletReceiptV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.number,
    required this.date,
    required this.reference,
    required this.amount,
    required this.code,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.status,
    required this.mark,
    required this.arrow,
    required this.statusOk,
  });

  final bool open;
  final VoidCallback onClose;

  final String number;
  final String date;
  final String reference;
  final String amount;
  final String code;
  final String sender;
  final String receiver;

  /// «استلام | إيداعٌ نقديّ» — اتّجاهُ الحركة واسمُها.
  final String type;

  /// حالُها: «تمّت» أو «محجوبة» أو «بانتظار…».
  final String status;

  /// علامةُ الحركة — هي نفسُها التي في صفّها بالكشف.
  final String mark;

  /// سهمُ اتّجاهها: نازلٌ للوارد وصاعدٌ للصادر.
  final String arrow;

  /// تمّت، فتُرسم علامةُ الإتمام بجانب الحال.
  final bool statusOk;

  /// البطاقة 406 × 568 على (12، 149) بزوايا 50.
  static const double _cardX = 12;
  static const double _cardY = 149;
  static const double _cardH = 568;
  static const double _cardRadius = 50;

  /// العلامة 50 على y 161، والعنوان على خطّ الأساس 255.
  static const double _markY = 161;
  static const double _mark = 50;
  static const double _titleBaseline = 255;

  /// رمز QR 69.72 على y 277، ورقمُه على خطّ الأساس 367.
  static const double _qr = 69.72;
  static const double _qrY = 277;
  static const double _numberBaseline = 367;

  /// الخلايا من y 383، 50 طولاً، بينها 4.
  static const double _cellsY = 383;
  static const double _cellH = 50;
  static const double _cellGap = 4;

  /// الشعار على y 625، والإجراءان على y 664.
  static const double _wordmarkY = 625;
  static const double _actionsY = 664;
  static const double _actionLabelBaseline = 701;

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.shrink();
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          // `#1D1D1D` بنصف شفافيّة فوق الصفحة البيضاء. و`Positioned.fill`
          // لازمة: صندوقٌ ملوَّنٌ بلا طفلٍ في `Stack` يأخذ صفراً.
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: const ColoredBox(color: XdColors.backdropGlass),
            ),
          ),
          // داخلَ `Material` شفّافة: النصُّ خارجَها يُرسم بخطٍّ أصفرَ مزدوجٍ
          // تحته، وهذه طبقةٌ فوق `Scaffold` لا تحته.
          Material(
            type: MaterialType.transparency,
            child: SafeArea(
              bottom: false,
              // البطاقةُ 568 في الملفّ، ومحتواها يملؤها إلّا 13. وأبعادُ
              // الصور والرموز تُقاس بالعرض والبطاقةُ بالطول، ففرقُ النسبتين
              // على بعض الشاشات يبتلع تلك الـ13 ويُلصق الإجراءين بالحافّة.
              // فتطول البطاقةُ بمحتواها، وتُمرَّر الصفحةُ إن جاوزت الشاشة.
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: (_cardY - Xd.statusBar).h,
                    start: _cardX.w,
                    end: _cardX.w,
                    bottom: _cardX.h,
                  ),
                  child: _card(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card() {
    return Container(
      width: Xd.fill(_cardX),
      constraints: BoxConstraints(minHeight: _cardH.h),
      decoration: BoxDecoration(
        color: XdColors.white,
        borderRadius: BorderRadius.circular(_cardRadius.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: (_markY - _cardY).h),
            // الملفّ يرسم علامةً واحدةً لأنّ لوحَه إيداعٌ نقديّ. وهي هنا
            // علامةُ الحركة الملموسة، كما في صفّها بالكشف.
            child: Center(
              child: XdSvg(mark, folder: kWalletSvg, w: _mark),
            ),
          ),
          _centred(
            LocaleKeys.receipt.tr(),
            size: 40,
            weight: XdWeight.medium,
            top: Xd.gapTo(_markY + _mark, _titleBaseline, 40),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: (_qrY - Xd.textBottom(_titleBaseline, 40)).h,
            ),
            child: Center(
              child: WalletQr(data: number, size: _qr),
            ),
          ),
          _centred(
            number,
            size: 16,
            weight: XdWeight.medium,
            top: Xd.gapTo(_qrY + _qr, _numberBaseline, 16),
          ),
          _cells(),
          Padding(
            padding: EdgeInsets.only(top: (_wordmarkY - (545 + 50)).h),
            child: const Center(
              child: XdSvg(
                'receiptWordmark',
                folder: kWalletSvg,
                w: 80.56,
                h: 25,
              ),
            ),
          ),
          _actions(),
          // الملفّ يُنهي الكلمتين على y 704 والبطاقةَ على 717.
          SizedBox(
            height:
                (_cardY + _cardH - Xd.textBottom(_actionLabelBaseline, 11)).h,
          ),
        ],
      ),
    );
  }

  Widget _centred(
    String text, {
    required double size,
    required XdWeight weight,
    required double top,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: top.h),
      child: SizedBox(
        width: double.infinity,
        child: XdText(
          text,
          size: size,
          weight: weight,
          align: TextAlign.center,
        ),
      ),
    );
  }

  /// الخلايا. عروضُها من الملفّ في بطاقةٍ 406، وتتقاسم عرضَ البطاقة بنسبها.
  Widget _cells() {
    return Padding(
      padding: EdgeInsets.only(
        top: (_cellsY - Xd.textBottom(_numberBaseline, 16)).h,
      ),
      child: Column(
        children: <Widget>[
          _row(<({double w, String label, String value, List<String> marks})>[
            (
              w: 124,
              label: LocaleKeys.date_and_time.tr(),
              value: date,
              marks: const <String>[],
            ),
            (
              w: 124,
              label: LocaleKeys.reference.tr(),
              value: reference,
              marks: const <String>[],
            ),
            (
              w: 126,
              label: LocaleKeys.amount_label.tr(),
              value: '$amount $code',
              marks: const <String>[],
            ),
          ]),
          _row(<({double w, String label, String value, List<String> marks})>[
            (
              w: 252,
              label: LocaleKeys.type.tr(),
              value: type,
              marks: <String>[mark, arrow],
            ),
            (
              w: 126,
              label: LocaleKeys.status.tr(),
              value: status,
              marks: statusOk
                  ? const <String>['receiptDone']
                  : const <String>[],
            ),
          ]),
          _row(<({double w, String label, String value, List<String> marks})>[
            (
              w: 382,
              label: LocaleKeys.sender.tr(),
              value: sender,
              marks: const <String>[],
            ),
          ]),
          _row(<({double w, String label, String value, List<String> marks})>[
            (
              w: 382,
              label: LocaleKeys.receiver.tr(),
              value: '$receiver ${LocaleKeys.wallet_word.tr()} $code',
              marks: const <String>[],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _row(
    List<({double w, String label, String value, List<String> marks})> cells,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: _cellGap.h, start: 12.w),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < cells.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: _cellGap.w),
            Expanded(flex: (cells[i].w * 100).round(), child: _cell(cells[i])),
          ],
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _cell(({double w, String label, String value, List<String> marks}) c) {
    return Container(
      height: _cellH.h,
      decoration: BoxDecoration(
        color: XdColors.card,
        borderRadius: BorderRadius.circular(XdRow.radius.r),
      ),
      padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          XdText(c.label, size: 11, color: XdColors.grey),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(Xd.textBottom(19, 11), 39, 13).h,
            ),
            child: Row(
              children: <Widget>[
                for (final String m in c.marks) ...<Widget>[
                  XdSvg(m, folder: kWalletSvg, w: 14),
                  SizedBox(width: 4.w),
                ],
                Flexible(
                  child: XdText(
                    c.value,
                    size: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// التنزيل والمشاركة. الخانةُ تمتدّ من بداية نصٍّ إلى بداية التالي
  /// (252 − 145)، ويحفظان مسافتهما عن مركز البطاقة.
  Widget _actions() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (_actionsY - (_wordmarkY + 25)).h,
        start: 1.sw / 2 - (406 / 2 - (145 - 12)).w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _action('infoDownload', LocaleKeys.download.tr(), 252 - 145, -0.5),
          _action('infoShare', LocaleKeys.share.tr(), 0, 0.5),
        ],
      ),
    );
  }

  /// الصورةُ موسَّطةٌ فوق نصّها ثمّ تزيح عنه بالقدر الذي في الملفّ. والخانةُ
  /// تمتدّ من بداية نصٍّ إلى بداية التالي، والإجراءُ في أوّلها.
  Widget _action(String icon, String label, double slot, double off) {
    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: off > 0 ? (off * 2).w : 0,
            right: off < 0 ? (-off * 2).w : 0,
          ),
          child: XdSvg(icon, folder: kWalletSvg, w: 20),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(_actionsY + 20, _actionLabelBaseline, 11).h,
          ),
          child: XdText(label, size: 11),
        ),
      ],
    );
    return slot == 0
        ? body
        : SizedBox(
            width: slot.w,
            child: Align(alignment: AlignmentDirectional.topStart, child: body),
          );
  }
}
