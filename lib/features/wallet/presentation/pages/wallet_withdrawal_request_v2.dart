/// طلبُ السحب — نقلٌ كاملٌ لـ
/// `web_design/components/DemoApp1/screens/WalletWithdrawalRequest.tsx`.
///
/// > ألواحُ XD `Home Page – 101` و`– 28` و`– 24`. والأوّلان خطوتان من نافذة
/// > السحب (من y 90)، بعد «طلب سحب» في النموذج. والثالثُ صورةُ الطلب على
/// > صفحةٍ بيضاء.
/// >
/// > وكلٌّ منها يبدأ برأسِ النافذة: صفُّ العنوان والعلامة، وينتهي على y 186.
/// >
/// > والخلايا تحفظ 20 إلى حافّتي الشاشة. والرموزُ وصناديقُ الرمز وصفوفُ
/// > الإجراءات تحفظ حجمَها وتبقى موسَّطةً كما يُوسّطها الملفّ.
library;

import 'dart:async';

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
import 'wallet_cash_in_design.dart';
import 'wallet_cash_out_design.dart';
import 'wallet_design.dart';
import 'wallet_pin_boxes.dart';
import 'wallet_sheet_parts.dart';

/// `Home Page – 101`، وكلُّ شيءٍ فيه 40 من الحافّة:
///   - المبلغُ و«طلب سحب» (16، والمبلغُ Bold) على خطّ الأساس 276؛
///   - «التوثيق !» (30 Bold) على 318 والسطرُ تحته (16 Medium) على 354؛
///   - ثلاثةُ صفوفٍ بينها 8: «أرسلنا رمز التحقّق…» (12) من y 366 وصورةٌ 15
///     بعدها بـ4، والرقمُ مع «إعادة الإرسال بعد − 01:58» من 389، وسطرُ
///     الخصوصيّة الرماديّ (11) من 412؛
///   - صناديقُ الرمز الستّة على (20، 502).
///
/// ولا يُرسَل رمزٌ: أيُّ ستّة أرقامٍ رمزٌ صحيح، حتّى يُسلَّم مسارُ الخادم.
class WalletRequestCode extends StatefulWidget {
  const WalletRequestCode({
    super.key,
    required this.head,
    required this.card,
    required this.request,
    required this.onVerified,
  });

  final Widget head;
  final WalletCardData card;
  final WithdrawalRequestData request;
  final VoidCallback onVerified;

  @override
  State<WalletRequestCode> createState() => _WalletRequestCodeState();
}

class _WalletRequestCodeState extends State<WalletRequestCode> {
  int _left = CashOutDesign.codeSeconds;
  Timer? _tick;
  WalletPinState _state = WalletPinState.typing;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _left = _left > 0 ? _left - 1 : 0);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String get _clock => walletClock(_left);

  @override
  Widget build(BuildContext context) {
    final double headEnd = CashOutDesign.headEnd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.head,
        WalletUnder(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: Xd.gapTo(headEnd, CashOutDesign.codeRequestBaseline, 16).h,
                start: CashOutDesign.codeX.w,
              ),
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: widget.request.amount,
                      style: xdTextStyle(size: 16, weight: XdWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' ${widget.card.code} '
                          '${LocaleKeys.withdrawal_request.tr()}',
                      style: xdTextStyle(size: 16),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: Xd.gapTo(
                  Xd.textBottom(CashOutDesign.codeRequestBaseline, 16),
                  CashOutDesign.codeTitleBaseline,
                  30,
                ).h,
                start: CashOutDesign.codeX.w,
              ),
              child: XdText(
                LocaleKeys.verification_excl.tr(),
                size: 30,
                weight: XdWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: Xd.gapTo(
                  Xd.textBottom(CashOutDesign.codeTitleBaseline, 30),
                  CashOutDesign.codeLineBaseline,
                  16,
                ).h,
                start: CashOutDesign.codeX.w,
                end: 20.w,
              ),
              child: XdText(
                LocaleKeys.enter_verification_code_sent_to_your_whatsapp.tr(),
                size: 16,
                weight: XdWeight.medium,
                maxLines: 2,
              ),
            ),
            // «أرسلنا رمز التحقّق إلى الرقم» وصورةٌ 15 بعدها بـ4.
            _row(
              mt:
                  CashOutDesign.codeRow1Y -
                  Xd.textBottom(CashOutDesign.codeLineBaseline, 16),
              children: <Widget>[
                Flexible(
                  child: XdText(
                    LocaleKeys.we_have_sent_a_verification_code_to_the_number
                        .tr(),
                    size: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                const XdSvg('codeSent', folder: kWalletSvg, w: 15),
              ],
            ),
            _row(
              mt: CashOutDesign.codeRow2Y - (CashOutDesign.codeRow1Y + 15),
              children: <Widget>[
                const XdText(WalletRequestData.codeSentTo, size: 12),
                SizedBox(width: 6.w),
                XdTap(
                  scale: 1,
                  onTap: _left > 0
                      ? null
                      : () => setState(() {
                          _left = CashOutDesign.codeSeconds;
                          _state = WalletPinState.typing;
                        }),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: LocaleKeys.resend_after.tr(),
                          style: xdTextStyle(size: 12, color: XdColors.hint),
                        ),
                        TextSpan(
                          text: ' - $_clock',
                          style: xdTextStyle(
                            size: 12,
                            weight: XdWeight.medium,
                            color: XdColors.blue,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 4.w),
                const XdSvg('codeHelp', folder: kWalletSvg, w: 15),
              ],
            ),
            _row(
              mt: CashOutDesign.codeRow3Y - (CashOutDesign.codeRow2Y + 15),
              children: <Widget>[
                XdText(
                  LocaleKeys.your_privacy_is_completely_safe.tr(),
                  size: 11,
                  color: XdColors.hint,
                ),
                SizedBox(width: 3.w),
                const XdSvg('shieldGrey', folder: kWalletSvg, w: 14),
              ],
            ),
            // الصناديقُ تحفظ حجمَها: الصفُّ 390 على x 20، فيبقى على مركز
            // الشاشة.
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: (CashOutDesign.codeBoxesY - (CashOutDesign.codeRow3Y + 14))
                    .h,
                start: Xd.fromCentre(CashOutDesign.codeBoxesX),
                bottom:
                    CashOutDesign.boardTail.h +
                    MediaQuery.paddingOf(context).bottom,
              ),
              child: WalletPinBoxes(
                state: _state,
                onComplete: (String _) {
                  setState(() => _state = WalletPinState.valid);
                  Future<void>.delayed(
                    const Duration(milliseconds: 600),
                    widget.onVerified,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row({required double mt, required List<Widget> children}) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: CashOutDesign.codeX.w,
        end: 20.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// `Home Page – 28`، بعد رمزٍ صحيح:
///   - الرمزُ 301 على (65، 215)؛
///   - «طلب سحب» (16 Medium) على خطّ الأساس 544؛
///   - الخلايا من y 588؛
///   - ثلاثةُ إجراءاتٍ على y 855: صورةٌ 20 فوق نصٍّ 11.
class WalletRequestReady extends StatelessWidget {
  const WalletRequestReady({
    super.key,
    required this.head,
    required this.card,
    required this.request,
    required this.onPicture,
  });

  final Widget head;
  final WalletCardData card;
  final WithdrawalRequestData request;

  /// «تنزيل»: إلى صورة الطلب (`– 24`).
  final VoidCallback onPicture;

  void _act(String id) {
    if (id == 'copy') {
      Clipboard.setData(const ClipboardData(text: WalletRequestData.reference));
    } else if (id == 'download') {
      onPicture();
    } else if (id == 'share') {
      SharePlus.instance.share(ShareParams(text: WalletRequestData.reference));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        head,
        WalletUnder(
          children: <Widget>[
            // الرمزُ يحفظ حجمَه، موسَّطاً كما في الملفّ. ورقمُه الحقيقيُّ
            // يأتي من الخادم لاحقاً.
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: (CashOutDesign.requestQrY - CashOutDesign.headEnd).h,
                start: Xd.fromCentre(CashOutDesign.requestQrX),
              ),
              child: const XdSvg(
                'qrRequest',
                folder: kWalletSvg,
                w: CashOutDesign.requestQr,
              ),
            ),
            WalletCentred(
              mt: Xd.gapTo(
                CashOutDesign.requestQrY + CashOutDesign.requestQr,
                CashOutDesign.requestTitleBaseline,
                16,
              ),
              child: XdText(
                LocaleKeys.withdrawal_request.tr(),
                size: 16,
                weight: XdWeight.medium,
                align: TextAlign.center,
              ),
            ),
            WalletRequestCells(
              mt:
                  CashOutDesign.requestCellsY -
                  Xd.textBottom(CashOutDesign.requestTitleBaseline, 16),
              card: card,
              request: request,
            ),
            WalletActionsRow(
              mt: WalletActionsRow.y - (765 + CashOutDesign.cellH),
              actions: kRequestActions,
              onAct: _act,
            ),
          ],
        ),
      ],
    );
  }
}

/// `Home Page – 24`: صورةُ الطلب على صفحةٍ بيضاء. كتلُ `– 28` نفسُها، 48 أعلى
/// وبرمزٍ 350.56:
///   - صفُّ العنوان على y 66 والعلامةُ على خطّ الأساس 132؛
///   - الرمزُ على (40، 167) و«طلب سحب» على خطّ الأساس 546؛
///   - الخلايا من y 561؛
///   - الملاحظةُ 390 × 90 على (20، 805)، وخطٌّ على حافّتها.
class WalletRequestPicture extends StatelessWidget {
  const WalletRequestPicture({
    super.key,
    required this.card,
    required this.request,
  });

  final WalletCardData card;
  final WithdrawalRequestData request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(
            top:
                (CashOutDesign.pictureQrY -
                        Xd.textBottom(CashOutDesign.pictureTitleBaseline, 24))
                    .h,
            start: Xd.fromCentre(CashOutDesign.pictureQrX),
          ),
          child: const XdSvg(
            'qrRequestBig',
            folder: kWalletSvg,
            w: CashOutDesign.pictureQr,
          ),
        ),
        // الملفُّ يبدأ السطر على x 139.5: نصفَ بكسلٍ يمينَ المركز.
        WalletCentred(
          mt: Xd.gapTo(
            CashOutDesign.pictureQrY + CashOutDesign.pictureQr,
            CashOutDesign.pictureTitleY,
            16,
          ),
          nudge: 0.5,
          child: XdText(
            LocaleKeys.withdrawal_request.tr(),
            size: 16,
            weight: XdWeight.medium,
            align: TextAlign.center,
          ),
        ),
        WalletRequestCells(
          mt:
              CashOutDesign.pictureCellsY -
              Xd.textBottom(CashOutDesign.pictureTitleY, 16),
          card: card,
          request: request,
        ),
        WalletNote(
          mt: WalletNote.y - (738 + CashOutDesign.cellH),
          title: LocaleKeys.your_withdrawal_request_ready_to_collect.tr(),
          body: LocaleKeys.present_this_code_and_receive_the_amount.tr(),
        ),
      ],
    );
  }
}

/// خلايا الطلب، `#FCFCFC` بزاوية 15، 55 طولاً وبينها 4: اسمُ العميل واسمُ
/// المستلم المفوَّض (390 عرضاً)، ثمّ صفّان من اثنتين (193 عرضاً). عنوانٌ
/// رماديٌّ 12 على خطّ الأساس 20 وقيمةٌ 14 على 43 — `Cells`.
///
/// وكلُّ صفٍّ يحفظ 20 إلى حافّتي الشاشة. وفي صفِّ الاثنتين تتقاسمان العرضَ
/// بفراغ الملفّ 4 بينهما.
class WalletRequestCells extends StatelessWidget {
  const WalletRequestCells({
    super.key,
    required this.mt,
    required this.card,
    required this.request,
  });

  final double mt;
  final WalletCardData card;
  final WithdrawalRequestData request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _cell(
          mt: mt,
          label: LocaleKeys.trydos_client_name.tr(),
          value: const XdText(
            WalletRecipientData.name,
            size: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (request.authorized != null)
          _cell(
            mt: CashOutDesign.cellGap,
            label: LocaleKeys.authorized_recipient_full_name.tr(),
            value: XdText(
              request.authorized!,
              size: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        _pair(
          first: _cell(
            label: LocaleKeys.amount_label.tr(),
            value: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${request.amount} ',
                    style: xdTextStyle(size: 14, weight: XdWeight.medium),
                  ),
                  TextSpan(text: card.code, style: xdTextStyle(size: 14)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          second: _cell(
            label: '${LocaleKeys.reference.tr()} | ${LocaleKeys.id_label.tr()}',
            value: const XdText(
              WalletRequestData.reference,
              size: 14,
              weight: XdWeight.medium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _pair(
          first: _cell(
            label: LocaleKeys.date_and_time.tr(),
            value: const XdText(
              WalletRequestData.date,
              size: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          second: _cell(
            label: LocaleKeys.type.tr(),
            value: XdText(
              LocaleKeys.withdrawal_request.tr(),
              size: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// صفٌّ من خليّتين تتقاسمان عرضَه.
  Widget _pair({required Widget first, required Widget second}) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: CashOutDesign.cellGap.h,
        start: 20.w,
      ),
      child: SizedBox(
        width: Xd.fill(20),
        child: Row(
          children: <Widget>[
            Expanded(child: first),
            SizedBox(width: CashOutDesign.cellGap.w),
            Expanded(child: second),
          ],
        ),
      ),
    );
  }

  /// خليّةٌ واحدة. الكاملةُ 20 من حافّتي الشاشة؛ ونصفُ الصفّ لا هامشَ له،
  /// فالصفُّ يُعطيه موضعَه.
  Widget _cell({double? mt, required String label, required Widget value}) {
    final Widget box = Container(
      height: CashOutDesign.cellH.h,
      decoration: BoxDecoration(
        color: XdColors.card,
        borderRadius: BorderRadius.circular(15.r),
      ),
      padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          XdText(label, size: 12, color: XdColors.grey),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(8 + Xd.lineBox(12), 43, 14).h,
            ),
            child: value,
          ),
        ],
      ),
    );
    if (mt == null) return box;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: 20.w),
      child: SizedBox(width: Xd.fill(20), child: box),
    );
  }
}
