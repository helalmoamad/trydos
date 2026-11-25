/// الإيداع — نقلٌ كاملٌ لـ
/// `web_design/components/DemoApp1/screens/WalletCashInSheet.tsx`.
///
/// شرحُ الألواح وأرقامُها في [CashInDesign]. ولا مسارَ خادمٍ هنا بعد: كلُّ
/// البيانات بياناتُ الملفّ ([WalletCashInData] و[WalletCryptoData] …) حتّى
/// تُسلَّم المسارات — انظر [kWalletApisLive].
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
import 'pay_ways.dart';
import 'wallet_cash_in_design.dart';
import 'wallet_design.dart';
import 'wallet_picture_layer.dart';
import 'wallet_safe_sheet_v2.dart';
import 'wallet_sheet_parts.dart';
import 'wallet_sheet_title.dart';

/// نافذةُ الإيداع: نافذةٌ واحدةٌ بأربع خطوات، ومعها نافذةُ قواعد الأمان
/// وطبقتا صورة الرمز.
class WalletCashInSheetV2 extends StatefulWidget {
  const WalletCashInSheetV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.card,
  });

  final bool open;
  final VoidCallback onClose;

  /// الرصيدُ الذي يذهب إليه المال.
  final WalletCardData card;

  @override
  State<WalletCashInSheetV2> createState() => _WalletCashInSheetV2State();
}

class _WalletCashInSheetV2State extends State<WalletCashInSheetV2> {
  CashInStep _step = CashInStep.ways;

  /// محفوظٌ هنا، فيُظهر الرمزُ (`– 37`) ما طلبه النموذج.
  String _amount = '';

  /// قواعدُ الأمان (`– 39`) تقع فوق نموذج العملة الرقميّة.
  bool _safe = false;

  /// صورةُ رمزٍ تقع فوق النافذة (`– 31`، `– 38`).
  String? _picture;

  @override
  void didUpdateWidget(WalletCashInSheetV2 old) {
    super.didUpdateWidget(old);
    // النافذةُ تفتح على خطوتها الأولى كلَّ مرّة. والخطوةُ ترجع بعد أن تنزلق
    // النافذةُ بعيداً، فلا تتبدّل وهي خارجة.
    if (old.open && !widget.open) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || widget.open) return;
        setState(() {
          _step = CashInStep.ways;
          _amount = '';
          _safe = false;
          _picture = null;
        });
      });
    }
  }

  double get _lower => CashInDesign.top[_step]! - CashInDesign.layoutTop;

  /// صفُّ العنوان: «الإيداع» وصورتُه وعلامةُ العملة.
  ///
  /// والملفُّ يبدأ العنوان العريض على x 174: بكسلاً يمينَ المركز.
  Widget _title({required double top, bool medium = false}) {
    return WalletSheetTitle(
      top: top,
      icon: 'cashInBig',
      mark: widget.card.mark,
      label: LocaleKeys.cash_in.tr(),
      weight: medium ? XdWeight.medium : XdWeight.bold,
      nudge: medium ? 0 : 1,
    );
  }

  /// رأسُ نافذة trydos | rdb: العنوانُ ثمّ العلامةُ على خطّ الأساس 180.
  Widget get _rdbHead {
    final double top = CashInDesign.top[CashInStep.rdb]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(top: top),
        WalletBrand(size: 24, mt: Xd.gapTo(top + 24 + Xd.lineBox(24), 180, 24)),
      ],
    );
  }

  /// رأسُ خطوات العملة الرقميّة: العنوانُ ثمّ «بالعملات الرقميّة».
  Widget get _cryptoHead {
    final double top = CashInDesign.top[CashInStep.crypto]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(top: top),
        WalletCentred(
          mt: Xd.gapTo(top + 24 + Xd.lineBox(24), 180, 24),
          child: XdText(
            LocaleKeys.via_crypto.tr(),
            size: 24,
            weight: XdWeight.bold,
            align: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// الخطوةُ التي قبلها في الطريق الذي مشاه المستعمل.
  static const Map<CashInStep, CashInStep> _prev = <CashInStep, CashInStep>{
    CashInStep.rdb: CashInStep.ways,
    CashInStep.crypto: CashInStep.ways,
    // ولوحُ الرمز يُفتح من نموذج العملة الرقميّة بعد قواعد الأمان.
    CashInStep.code: CashInStep.crypto,
  };

  /// سهمُ الرجوع يُقشّر الأعلى: صورةُ الرمز، ثمّ قواعدُ الأمان، ثمّ خطوةٌ إلى
  /// الوراء، ثمّ النافذةُ نفسُها من خطوتها الأولى.
  void _back() {
    if (_picture != null) {
      setState(() => _picture = null);
      return;
    }
    if (_safe) {
      setState(() => _safe = false);
      return;
    }
    final CashInStep? back = _prev[_step];
    if (back != null) {
      setState(() => _step = back);
      return;
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    // و`PopScope` **داخل** `Positioned`: فـ`Positioned` لا يصلح إلّا ابناً
    // مباشراً لـ`Stack`.
    return Positioned.fill(
      child: PopScope(
        canPop: !widget.open,
        onPopInvokedWithResult: (bool didPop, Object? _) {
          if (didPop || !widget.open) return;
          _back();
        },
        child: Stack(
          children: <Widget>[
            XdSheetLayer(
              open: widget.open,
              y: CashInDesign.layoutTop,
              lower: _lower,
              radius: XdSheet.radiusWallet,
              onClose: widget.onClose,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: KeyedSubtree(
                  key: ValueKey<CashInStep>(_step),
                  child: _stepBody(),
                ),
              ),
            ),
            XdSheetLayer(
              open: widget.open && _safe,
              y: CashInDesign.rulesTop,
              radius: XdSheet.radiusWallet,
              outline: XdColors.sheetEdge,
              onClose: () => setState(() => _safe = false),
              child: WalletSafeRules(
                onAgree: () => setState(() {
                  _safe = false;
                  _step = CashInStep.code;
                }),
                onCancel: () => setState(() => _safe = false),
              ),
            ),
            WalletPictureLayer(
              open: widget.open && _picture == 'deposit',
              onClose: () => setState(() => _picture = null),
              head: _rdbHead,
              children: <Widget>[_DepositPicture(card: widget.card)],
            ),
            WalletPictureLayer(
              open: widget.open && _picture == 'crypto',
              onClose: () => setState(() => _picture = null),
              head: _cryptoHead,
              children: <Widget>[_CryptoPicture(amount: _amount)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case CashInStep.ways:
        return _Ways(
          title: _title(top: CashInDesign.top[CashInStep.ways]!, medium: true),
          onRdb: () => setState(() => _step = CashInStep.rdb),
          onCrypto: () => setState(() => _step = CashInStep.crypto),
        );
      case CashInStep.rdb:
        return _Rdb(
          head: _rdbHead,
          card: widget.card,
          onPicture: () => setState(() => _picture = 'deposit'),
        );
      case CashInStep.crypto:
        return _Crypto(
          head: _cryptoHead,
          card: widget.card,
          amount: _amount,
          onAmount: (String v) => setState(() => _amount = v),
          onGenerate: () => setState(() => _safe = true),
        );
      case CashInStep.code:
        return _CryptoCode(
          head: _cryptoHead,
          amount: _amount,
          onPicture: () => setState(() => _picture = 'crypto'),
        );
    }
  }
}

/// `Home Page – 22`، النافذةُ من y 216:
///   - العنوانُ «الإيداع» 24 Medium (والألواحُ الأخرى ترسمه Bold)؛
///   - الملاحظةُ، 14 بارتفاع سطرٍ 18، 366 عرضاً وموسَّطة، أوّلُ خطّ أساسٍ 296؛
///   - بطاقةُ trydos | rdb على y 338؛
///   - خمسُ خاناتٍ 125 على y 534 بينها 8، في صفٍّ ينزلق جانبياً؛
///   - البطاقةُ الرماديّة 390 × 204 على (20، 691) وزرّاها 366 × 38.
class _Ways extends StatelessWidget {
  const _Ways({
    required this.title,
    required this.onRdb,
    required this.onCrypto,
  });

  final Widget title;
  final VoidCallback onRdb;
  final VoidCallback onCrypto;

  @override
  Widget build(BuildContext context) {
    final double top = CashInDesign.top[CashInStep.ways]!;
    final double headEnd = top + 24 + Xd.lineBox(24);
    final double para = Xd.paraTop(
      CashInDesign.waysParaBaseline,
      14,
      CashInDesign.waysParaLine,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        WalletUnder(
          children: <Widget>[
            WalletPara(
              text: LocaleKeys.you_can_add_funds_easily_and_securely.tr(),
              mt: para - headEnd,
              ml: 32,
              width: Xd.fill(32),
              size: 14,
              lineHeight: CashInDesign.waysParaLine,
              align: TextAlign.center,
            ),
            // سطران من 18 يبدآن على 282 فينتهيان على 318.
            WalletBrandCard(
              y: CashInDesign.brandCardY,
              mt:
                  CashInDesign.brandCardY -
                  (282 + 2 * CashInDesign.waysParaLine),
              onTap: onRdb,
            ),
            PayWays(
              mt:
                  CashInDesign.payWaysY -
                  (CashInDesign.brandCardY + CashInDesign.brandCardH),
              onCrypto: onCrypto,
            ),
            _greyCard(context),
          ],
        ),
      ],
    );
  }

  /// البطاقةُ الرماديّة. تنتهي على y 895: 35 فوق أسفل اللوح.
  Widget _greyCard(BuildContext context) {
    final double para = Xd.paraTop(
      CashInDesign.greyParaBaseline,
      11,
      CashInDesign.greyParaLine,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top:
            (CashInDesign.greyCardY -
                    (CashInDesign.payWaysY + PayWaysDesign.rowHeight))
                .h,
        start: 20.w,
        bottom: CashInDesign.boardTail.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        width: Xd.fill(20),
        constraints: BoxConstraints(minHeight: CashInDesign.greyCardH.h),
        padding: EdgeInsets.only(
          bottom:
              (895 - (CashInDesign.greyButtonY2 + CashInDesign.greyButtonH)).h,
        ),
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: XdColors.line),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WalletPara(
              text: LocaleKeys.add_funds_now.tr(),
              mt: Xd.gapTo(
                CashInDesign.greyCardY,
                CashInDesign.greyTitleBaseline,
                11,
              ),
              ml: 32 - 20,
              width: Xd.fill(32),
              size: 11,
              lineHeight: Xd.lineBox(11),
              weight: XdWeight.medium,
              color: XdColors.grey,
              align: TextAlign.center,
            ),
            WalletPara(
              text: LocaleKeys.you_can_deposit_your_funds_note.tr(),
              mt: para - Xd.textBottom(CashInDesign.greyTitleBaseline, 11),
              ml: 32 - 20,
              width: Xd.fill(32),
              size: 11,
              lineHeight: CashInDesign.greyParaLine,
              color: XdColors.grey,
              align: TextAlign.center,
            ),
            // أربعةُ أسطرٍ تنتهي على y 795، والزرُّ الأوّل على 801.
            WalletInfoButton(
              mt:
                  CashInDesign.greyButtonY -
                  (para + 4 * CashInDesign.greyParaLine),
              label: LocaleKeys.available_branches.tr(),
            ),
            // الملفُّ يبدأ «معلومات أكثر» على x 190: نصفَ بكسلٍ يسارَ المركز.
            WalletInfoButton(
              mt:
                  CashInDesign.greyButtonY2 -
                  (CashInDesign.greyButtonY + CashInDesign.greyButtonH),
              nudge: -0.5,
              label: LocaleKeys.more_info.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// نافذةُ trydos | rdb، من y 90. وفي اللوحين: صفُّ العنوان، والعلامةُ على خطّ
/// الأساس 180، وتبويبان 193 × 28 على y 213 (المختارُ `#FAE26B`).
///   - `– 26` «إيداعٌ نقديّ»: الرمزُ 300.12 على (65، 260.41)؛ نقطتا الصفحة على
///     y 573؛ «trydos إيداع USD» على خطّ الأساس 605؛ حقولُ العميل الثلاثة على
///     y 639 و698 و757؛ أربعةُ إجراءاتٍ على y 855.
///   - `– 32` «من rdb الخاصّ بي»: حسابُ العميل في المصرف في ثلاثة حقولٍ على
///     y 245 و304 و363، وحقلُ المبلغ على 422 وهو مستعمَل، و«اتّصل واطلب من
///     rdb الخاصّ بك» على (20، 835).
class _Rdb extends StatefulWidget {
  const _Rdb({required this.head, required this.card, required this.onPicture});

  final Widget head;
  final WalletCardData card;

  /// «تنزيل»: إلى صورة الرمز (`– 31`).
  final VoidCallback onPicture;

  @override
  State<_Rdb> createState() => _RdbState();
}

class _RdbState extends State<_Rdb> {
  bool _fromBank = false;
  String _amount = '';

  void _act(String id) {
    if (id == 'copy') {
      Clipboard.setData(const ClipboardData(text: WalletCashInData.clientId));
    } else if (id == 'share') {
      SharePlus.instance.share(ShareParams(text: WalletCashInData.clientId));
    } else if (id == 'download') {
      widget.onPicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.head,
        // التبويبان يتقاسمان الصفَّ، 20 من حافّتي الشاشة.
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: (CashInDesign.tabsY - CashInDesign.headEnd).h,
            start: 20.w,
          ),
          child: SizedBox(
            width: Xd.fill(20),
            child: Row(
              children: <Widget>[
                WalletTab(
                  chosen: !_fromBank,
                  chosenFill: XdColors.yellow,
                  // الملفُّ يبدأ الكلمات على x 76.8 (Medium) و77.56 (عاديّ).
                  nudge: _fromBank ? 0.5 : -0.5,
                  onTap: () => setState(() => _fromBank = false),
                  spans: (XdWeight w) => <InlineSpan>[
                    TextSpan(
                      text: LocaleKeys.cash_deposit.tr(),
                      style: xdTextStyle(size: 13, weight: w),
                    ),
                  ],
                ),
                WalletTab(
                  chosen: _fromBank,
                  chosenFill: XdColors.yellow,
                  // والملفُّ يبدأها على x 274.44 (Medium) و274.79 (عاديّ).
                  nudge: _fromBank ? 0.5 : 1.17,
                  ml: 4,
                  onTap: () => setState(() => _fromBank = true),
                  spans: (XdWeight w) => walletWithBank(
                    LocaleKeys.from_my_bank.tr(),
                    size: 13,
                    weight: w,
                  ),
                ),
              ],
            ),
          ),
        ),
        WalletUnder(children: _fromBank ? _bank(context) : _cash(context)),
      ],
    );
  }

  /// `– 32`: حسابُ العميل في المصرف، وحقلُ المبلغ، والزرُّ على y 835.
  List<Widget> _bank(BuildContext context) {
    return <Widget>[
      WalletField(
        mt: CashInDesign.field1Y - (CashInDesign.tabsY + CashInDesign.tabH),
        label: Text.rich(
          TextSpan(
            children: walletWithBank(
              LocaleKeys.bank_client_id.tr(),
              size: 12,
              color: XdColors.grey,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // الرقمُ ينتهي على x 81، والعملةُ تبدأ على 91.
        value: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: WalletBankAccountData.id,
                style: xdTextStyle(size: 14, weight: XdWeight.medium),
              ),
              WidgetSpan(child: SizedBox(width: (91 - 81).w)),
              TextSpan(
                text: WalletBankAccountData.currency(widget.card.currency).tr(),
                style: xdTextStyle(size: 14),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      WalletField(
        mt: CashInDesign.field2Y - (CashInDesign.field1Y + CashInDesign.fieldH),
        label: Text.rich(
          TextSpan(
            children: walletWithBank(
              LocaleKeys.bank_client_phone_number.tr(),
              size: 12,
              color: XdColors.grey,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // «+» عريضةٌ على x 32، والرقمُ من x 44.
        value: Row(
          children: <Widget>[
            SizedBox(
              width: (44 - 32).w,
              child: const XdText('+', size: 14, weight: XdWeight.bold),
            ),
            const Flexible(
              child: XdText(
                WalletRecipientData.phone,
                size: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      WalletField(
        mt: 4,
        label: Text.rich(
          TextSpan(
            children: walletWithBank(
              LocaleKeys.bank_client_full_name_exact_id.tr(),
              size: 12,
              color: XdColors.grey,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: const XdText(
          WalletRecipientData.name,
          size: 14,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _AmountField(
        mt: CashInDesign.amountY - (CashInDesign.field3Y + CashInDesign.fieldH),
        label: Text.rich(
          TextSpan(
            children: walletWithBank(
              LocaleKeys.enter_requested_amount_from_your_bank.tr(),
              size: 12,
              weight: XdWeight.medium,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        code: widget.card.code,
        amount: _amount,
        onChanged: (String v) => setState(() => _amount = v),
      ),
      // الملفُّ يُسنِد الزرَّ إلى أسفل اللوح، فيحلّ على y 835.
      Padding(
        padding: EdgeInsets.only(
          bottom:
              CashInDesign.boardTail.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: WalletSheetButton(
          mt:
              CashInDesign.wideButtonY -
              (CashInDesign.amountY + CashInDesign.fieldH),
          label: Text.rich(
            TextSpan(
              children: walletWithBank(
                LocaleKeys.connect_and_request_from_your_bank.tr(),
                size: 16,
                color: XdColors.white,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          fill: XdColors.inkSoft,
        ),
      ),
    ];
  }

  /// `– 26`: رمزُ الإيداع وحقولُ العميل والإجراءات.
  List<Widget> _cash(BuildContext context) {
    return <Widget>[
      // الرمزُ يحفظ حجمَه، موسَّطاً كما في الملفّ. وهو صورةُ الملفّ: رقمُه
      // الحقيقيُّ يأتي من الخادم لاحقاً.
      Padding(
        padding: EdgeInsetsDirectional.only(
          top:
              (CashInDesign.qrSmallY - (CashInDesign.tabsY + CashInDesign.tabH))
                  .h,
          start: Xd.fromCentre(CashInDesign.qrSmallX),
        ),
        child: const XdSvg(
          'qrCashIn',
          folder: kWalletSvg,
          w: CashInDesign.qrSmall,
        ),
      ),
      // النقطتان على (205، 573) و(217، 573): 20 عرضاً معاً، موسَّطتان.
      Padding(
        padding: EdgeInsets.only(
          top:
              (CashInDesign.dotsY -
                      (CashInDesign.qrSmallY + CashInDesign.qrSmall))
                  .h,
        ),
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
      _DepositLine(
        mt: Xd.gapTo(
          CashInDesign.dotsY + 8,
          CashInDesign.depositLineBaseline,
          16,
        ),
        code: widget.card.code,
      ),
      _ClientFields(
        mt:
            CashInDesign.clientFieldsY -
            Xd.textBottom(CashInDesign.depositLineBaseline, 16),
        card: widget.card,
        eye: true,
      ),
      WalletActionsRow(
        mt: CashInDesign.actionsY - (757 + CashInDesign.fieldH),
        actions: kDepositActions,
        onAct: _act,
      ),
    ];
  }
}

/// `Home Page – 31`: صورةُ رمز الإيداع على صفحةٍ بيضاء. كتلُ `– 26` بلا
/// التبويبات ولا الإجراءات، و48 أعلى:
///   - الرمزُ 350.37 على (39.99، 167.42)؛
///   - «trydos إيداع USD» على خطّ الأساس 546؛
///   - حقولُ العميل على y 620 و679 و738، بلا عين؛
///   - الملاحظةُ 390 × 90 على (20، 805)، وخطٌّ على حافّتها.
class _DepositPicture extends StatelessWidget {
  const _DepositPicture({required this.card});

  final WalletCardData card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(
            top:
                (CashInDesign.depositPictureQrY -
                        Xd.textBottom(CashInDesign.pictureTitleBaseline, 24))
                    .h,
            start: Xd.fromCentre(CashInDesign.qrBigX),
          ),
          child: const XdSvg(
            'qrCashInBig',
            folder: kWalletSvg,
            w: CashInDesign.qrBig,
          ),
        ),
        _DepositLine(
          mt: Xd.gapTo(
            CashInDesign.depositPictureQrY + CashInDesign.qrBig,
            CashInDesign.depositPictureLineBaseline,
            16,
          ),
          code: card.code,
        ),
        _ClientFields(
          mt:
              CashInDesign.depositPictureFieldsY -
              Xd.textBottom(CashInDesign.depositPictureLineBaseline, 16),
          card: card,
          eye: false,
        ),
        WalletNote(
          mt: CashInDesign.noteY - (738 + CashInDesign.fieldH),
          title: LocaleKeys.your_deposit_request_ready_to_collect.tr(),
          body: LocaleKeys.present_this_code_and_pay_the_amount.tr(),
        ),
      ],
    );
  }
}

/// `Home Page – 38`: صورةُ رمز العملة الرقميّة على صفحةٍ بيضاء. كتلُ `– 37`
/// بلا الوقت الباقي ولا المحافظ ولا الإجراءات، من صفّ العنوان على y 66:
///   - وسمُ الشبكة على (119، 165)، والرمزُ 350.37 على (39.99، 212.42)؛
///   - «110 USDT إيداع» على خطّ الأساس 591، وسطرُ المسح على 648؛
///   - الأسطرُ البرتقاليّة على 747 و765، والانتهاءُ على 790؛
///   - الملاحظةُ 390 × 90 على (20، 805).
class _CryptoPicture extends StatelessWidget {
  const _CryptoPicture({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _NetworkTag(
          mt:
              CashInDesign.cryptoPictureTagY -
              Xd.textBottom(CashInDesign.pictureTitleBaseline, 24),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            top:
                (CashInDesign.cryptoPictureQrY -
                        (CashInDesign.cryptoPictureTagY + CashInDesign.tabH))
                    .h,
            start: Xd.fromCentre(CashInDesign.qrBigX),
          ),
          child: const XdSvg(
            'qrCashInBig',
            folder: kWalletSvg,
            w: CashInDesign.qrBig,
          ),
        ),
        _DepositRow(
          mt:
              CashInDesign.cryptoPictureRowY -
              (CashInDesign.cryptoPictureQrY + CashInDesign.qrBig),
          amount: amount,
        ),
        const _ScanRow(
          mt:
              CashInDesign.cryptoPictureScanY -
              (CashInDesign.cryptoPictureRowY + 20),
        ),
        _Expiry(
          mt:
              Xd.sfTop(
                CashInDesign.cryptoPictureExpiry,
                CashInDesign.ruleSize,
                CashInDesign.ruleLine,
              ) -
              (CashInDesign.cryptoPictureScanY + 15),
          first: CashInDesign.cryptoPictureExpiry,
        ),
        WalletNote(
          mt:
              CashInDesign.noteY -
              (Xd.sfTop(
                    CashInDesign.cryptoPictureExpiry + CashInDesign.expiryGap,
                    CashInDesign.ruleSize,
                    CashInDesign.ruleLine,
                  ) +
                  CashInDesign.ruleLine),
          title: LocaleKeys.wallet_above_linked_to_specific_account.tr(),
          body: LocaleKeys.once_payment_completed_balance_added.tr(),
        ),
      ],
    );
  }
}

/// الإيداعُ بالعملات الرقميّة، النافذةُ من y 90:
///   - `– 33`: صفُّ العنوان، و«بالعملات الرقميّة» (24 Bold) على خطّ الأساس
///     180، وتبويبان على y 213 («USDT Tron TRC 20» مختاراً و«ETH»)، وحقولُ
///     العميل الثلاثة على y 245 و304 و363 (الاسمُ بعينٍ رماديّة)، وحقلُ
///     المبلغ على 422 فارغاً ومستعمَلاً؛
///   - `– 34`: مبلغٌ مكتوب. فالحقلُ 93 طولاً وفيه الحسمُ على وسمٍ أزرق،
///     والبطاقةُ الرماديّة 390 × 58 على (20، 519) تقول ما يُدفع وما يَصل،
///     و«ولّد رمز QR» على (20، 835).
///
/// والملفُّ لا يرسم لوحاً لتبويب «ETH»، فلا يبدّل النموذج.
class _Crypto extends StatelessWidget {
  const _Crypto({
    required this.head,
    required this.card,
    required this.amount,
    required this.onAmount,
    required this.onGenerate,
  });

  final Widget head;
  final WalletCardData card;
  final String amount;
  final ValueChanged<String> onAmount;

  /// «ولّد رمز QR»: قواعدُ الأمان أوّلاً (`– 39`).
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final bool typed = walletAmount(amount) > 0;
    final String fee = walletCharge(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        head,
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: (CashInDesign.tabsY - CashInDesign.headEnd).h,
            start: 20.w,
          ),
          child: SizedBox(
            width: Xd.fill(20),
            child: Row(
              children: <Widget>[
                WalletTab(
                  chosen: true,
                  chosenFill: XdColors.yellow,
                  // الملفُّ يبدأ الكلمات على x 61.2.
                  nudge: 1.17,
                  onTap: () {},
                  spans: (XdWeight w) => _networkSpans(13),
                ),
                WalletTab(
                  chosen: false,
                  chosenFill: XdColors.yellow,
                  ml: 4,
                  onTap: () {},
                  spans: (XdWeight w) => <InlineSpan>[
                    TextSpan(
                      text: WalletCryptoData.other,
                      style: xdTextStyle(size: 13, weight: w),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        WalletUnder(
          children: <Widget>[
            _ClientFields(
              mt:
                  CashInDesign.field1Y -
                  (CashInDesign.tabsY + CashInDesign.tabH),
              card: card,
              eye: true,
            ),
            _AmountField(
              mt:
                  CashInDesign.amountY -
                  (CashInDesign.field3Y + CashInDesign.fieldH),
              label: XdText(
                LocaleKeys.enter_requested_amount.tr(),
                size: 12,
                weight: XdWeight.medium,
                overflow: TextOverflow.ellipsis,
              ),
              code: card.code,
              amount: amount,
              onChanged: onAmount,
              // الملفُّ يبدأ السطر على x 53: 3.2 يمينَ المركز.
              note: typed
                  ? WalletCentred(
                      mt: Xd.gapTo(477, 496, 11),
                      nudge: 3.2,
                      child: Text.rich(
                        TextSpan(
                          children: walletSlots(
                            LocaleKeys.we_will_charge_for_topping_up.tr(),
                            <String, InlineSpan>{
                              'charge': TextSpan(
                                text: fee,
                                style: xdTextStyle(
                                  size: 11,
                                  weight: XdWeight.medium,
                                  color: XdColors.card,
                                ),
                              ),
                              'coin': TextSpan(
                                text: WalletCryptoData.coin,
                                style: xdTextStyle(
                                  size: 11,
                                  color: XdColors.card,
                                ),
                              ),
                              'amount': TextSpan(
                                text: amount,
                                style: xdTextStyle(
                                  size: 11,
                                  weight: XdWeight.medium,
                                  color: XdColors.card,
                                ),
                              ),
                              'code': TextSpan(
                                text: card.code,
                                style: xdTextStyle(
                                  size: 11,
                                  color: XdColors.card,
                                ),
                              ),
                            },
                            base: xdTextStyle(size: 11, color: XdColors.card),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : null,
            ),
            if (typed) _summary(fee),
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    CashInDesign.boardTail.h +
                    MediaQuery.paddingOf(context).bottom,
              ),
              child: typed
                  ? WalletSheetButton(
                      mt:
                          CashInDesign.wideButtonY -
                          (CashInDesign.summaryY + CashInDesign.summaryH),
                      label: XdText(
                        LocaleKeys.generate_qr_code.tr(),
                        size: 16,
                        color: XdColors.white,
                        align: TextAlign.center,
                      ),
                      fill: XdColors.inkSoft,
                      onTap: onGenerate,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  /// بطاقةُ الخلاصة 390 × 58 على (20، 519)، 4 تحت الحقل.
  Widget _summary(String fee) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top:
            (CashInDesign.summaryY -
                    (CashInDesign.amountY + CashInDesign.amountTallH))
                .h,
        start: 20.w,
      ),
      child: Container(
        width: Xd.fill(20),
        constraints: BoxConstraints(minHeight: CashInDesign.summaryH.h),
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom:
              (CashInDesign.summaryY +
                      CashInDesign.summaryH -
                      Xd.textBottom(562, 11))
                  .h,
        ),
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(15.r),
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: XdColors.line),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WalletPara(
              spans: walletSlots(
                LocaleKeys.you_will_pay_to_generated_wallet.tr(),
                <String, InlineSpan>{
                  'charge': TextSpan(
                    text: fee,
                    style: xdTextStyle(size: 11, weight: XdWeight.medium),
                  ),
                  'network': TextSpan(
                    text: WalletCryptoData.network,
                    style: xdTextStyle(size: 11, weight: XdWeight.medium),
                  ),
                },
                base: xdTextStyle(size: 11, weight: XdWeight.medium),
              ),
              mt: Xd.gapTo(CashInDesign.summaryY, 542, 11),
              ml: 0,
              width: Xd.fill(32, 32),
              size: 11,
              lineHeight: Xd.lineBox(11),
            ),
            WalletPara(
              spans: walletSlots(
                LocaleKeys.we_will_send_to_your_trydos_balance.tr(),
                <String, InlineSpan>{
                  'amount': TextSpan(
                    text: amount,
                    style: xdTextStyle(size: 11, weight: XdWeight.bold),
                  ),
                  'code': TextSpan(
                    text: card.code,
                    style: xdTextStyle(size: 11),
                  ),
                },
                base: xdTextStyle(size: 11),
              ),
              mt: Xd.gapTo(Xd.textBottom(542, 11), 562, 11),
              ml: 0,
              width: Xd.fill(32, 32),
              size: 11,
              lineHeight: Xd.lineBox(11),
            ),
          ],
        ),
      ),
    );
  }
}

/// `Home Page – 37`، بعد «أوافق»: رمزُ العملة الرقميّة، النافذةُ من y 90.
///   - وسمُ الشبكة 193 × 28 على (119، 213)؛
///   - الرمزُ 300.12 على (65، 260.41)؛
///   - «110 USDT إيداع» على خطّ الأساس 589، وعلامتُه على (136، 573)؛
///   - سطرُ المسح على خطّ الأساس 651، والوقتُ الباقي (`#3066CC`، وساعتُه على
///     (137.64، 666)) على 678، و«أو جرّب الرابط المباشر إلى» على 713؛
///   - ثلاثُ محافظَ 30 على y 728، على x 140 و200 و260، بزاوية 5؛
///   - الأسطرُ البرتقاليّة على 789 و807، والانتهاءُ على 832؛
///   - ثلاثةُ إجراءاتٍ على y 855.
class _CryptoCode extends StatefulWidget {
  const _CryptoCode({
    required this.head,
    required this.amount,
    required this.onPicture,
  });

  final Widget head;
  final String amount;

  /// «تنزيل»: إلى صورة الرمز (`– 38`).
  final VoidCallback onPicture;

  @override
  State<_CryptoCode> createState() => _CryptoCodeState();
}

class _CryptoCodeState extends State<_CryptoCode> {
  int _left = WalletCryptoData.seconds;
  Timer? _tick;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.head,
        _NetworkTag(mt: CashInDesign.tabsY - CashInDesign.headEnd),
        WalletUnder(
          children: <Widget>[
            // الرمزُ يحفظ حجمَه، موسَّطاً كما في الملفّ. وعنوانُ المحفظة
            // الحقيقيُّ يأتي من الخادم لاحقاً.
            Padding(
              padding: EdgeInsetsDirectional.only(
                top:
                    (CashInDesign.qrSmallY -
                            (CashInDesign.tabsY + CashInDesign.tabH))
                        .h,
                start: Xd.fromCentre(CashInDesign.qrSmallX),
              ),
              child: const XdSvg(
                'qrCashIn',
                folder: kWalletSvg,
                w: CashInDesign.qrSmall,
              ),
            ),
            _DepositRow(
              mt:
                  CashInDesign.depositRowY -
                  (CashInDesign.qrSmallY + CashInDesign.qrSmall),
              amount: widget.amount,
            ),
            const _ScanRow(
              mt: CashInDesign.scanRowY - (CashInDesign.depositRowY + 20),
            ),
            // الوقتُ الباقي: ساعةٌ 13.73 × 15 ثمّ السطر.
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: (CashInDesign.timerY - (CashInDesign.scanRowY + 15)).h,
                start: Xd.fromCentre(CashInDesign.timerX),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const XdSvg('timerBlue', folder: kWalletSvg, w: 13.73, h: 15),
                  SizedBox(
                    width:
                        (CashInDesign.timerTextX -
                                (CashInDesign.timerX + 13.73))
                            .w,
                  ),
                  Text.rich(
                    TextSpan(
                      children: walletSlots(
                        LocaleKeys.within_time_minutes.tr(),
                        <String, InlineSpan>{
                          'time': TextSpan(
                            text: walletClock(_left),
                            style: xdTextStyle(
                              size: 12,
                              weight: XdWeight.bold,
                              color: XdColors.cryptoBlue,
                            ),
                          ),
                        },
                        base: xdTextStyle(size: 12, color: XdColors.cryptoBlue),
                      ),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // الملفُّ يبدأ هذا السطر على x 159: نصفَ بكسلٍ يمينَ المركز.
            WalletCentred(
              mt: Xd.gapTo(
                CashInDesign.timerY + 15,
                CashInDesign.directLinkBaseline,
                12,
              ),
              nudge: 0.5,
              child: XdText(
                LocaleKeys.or_try_direct_link_to.tr(),
                size: 12,
                color: XdColors.inkSoft,
                align: TextAlign.center,
              ),
            ),
            // من x 140 إلى 290 في الملفّ: موسَّطةٌ على الشاشة.
            Padding(
              padding: EdgeInsets.only(
                top:
                    (CashInDesign.appsY -
                            Xd.textBottom(CashInDesign.directLinkBaseline, 12))
                        .h,
              ),
              child: SizedBox(
                width: 1.sw,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (
                      int i = 0;
                      i < kWalletCryptoApps.length;
                      i++
                    ) ...<Widget>[
                      if (i > 0) SizedBox(width: CashInDesign.appGap.w),
                      _app(kWalletCryptoApps[i]),
                    ],
                  ],
                ),
              ),
            ),
            _Expiry(
              mt:
                  Xd.sfTop(
                    CashInDesign.expiryFirst,
                    CashInDesign.ruleSize,
                    CashInDesign.ruleLine,
                  ) -
                  (CashInDesign.appsY + CashInDesign.app),
              first: CashInDesign.expiryFirst,
            ),
            WalletActionsRow(
              mt:
                  CashInDesign.actionsY -
                  (Xd.sfTop(
                        CashInDesign.expiryFirst + CashInDesign.expiryGap,
                        CashInDesign.ruleSize,
                        CashInDesign.ruleLine,
                      ) +
                      CashInDesign.ruleLine),
              actions: kCryptoActions,
              onAct: (String id) {
                if (id == 'download') widget.onPicture();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _app(WalletAppData app) {
    return Semantics(
      button: true,
      label: app.name,
      child: XdTap(
        scale: 0.94,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.r),
          child: app.icon != null
              ? XdSvg(app.icon!, folder: kWalletSvg, w: CashInDesign.app)
              : WalletImage(name: app.picture!, size: CashInDesign.app),
        ),
      ),
    );
  }
}

/// «trydos إيداع USD»، 16: «try» عريضةٌ و«dos» عاديّةٌ والباقي Medium.
///
/// والملفُّ يبدأ السطر على x 141: نصفَ بكسلٍ يسارَ المركز.
class _DepositLine extends StatelessWidget {
  const _DepositLine({required this.mt, required this.code});

  final double mt;
  final String code;

  @override
  Widget build(BuildContext context) {
    return WalletCentred(
      mt: mt,
      nudge: -0.5,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: WalletBrandData.start,
              style: xdTextStyle(size: 16, weight: XdWeight.bold),
            ),
            TextSpan(
              text: WalletBrandData.rest.substring(0, 3),
              style: xdTextStyle(size: 16),
            ),
            TextSpan(
              text: ' ${LocaleKeys.deposit_word.tr()} $code',
              style: xdTextStyle(size: 16, weight: XdWeight.medium),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}

/// حقولُ العميل الثلاثة: الاسمُ والمعرّفُ ورقمُ الهاتف، بينها 4.
class _ClientFields extends StatelessWidget {
  const _ClientFields({
    required this.mt,
    required this.card,
    required this.eye,
  });

  final double mt;
  final WalletCardData card;

  /// العينُ الرماديّة في حقل الاسم (`– 26`، `– 33`؛ لا في الصورة `– 31`).
  final bool eye;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WalletField(
          mt: mt,
          label: XdText(
            LocaleKeys.trydos_client_name.tr(),
            size: 12,
            color: XdColors.grey,
          ),
          value: const XdText(
            WalletRecipientData.name,
            size: 14,
            overflow: TextOverflow.ellipsis,
          ),
          mark: eye,
        ),
        WalletField(
          mt: 4,
          label: XdText(
            LocaleKeys.trydos_client_id.tr(),
            size: 12,
            color: XdColors.grey,
          ),
          // الرقمُ ينتهي على x 81، والعملةُ تبدأ على 91.
          value: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: WalletCashInData.clientId,
                  style: xdTextStyle(size: 14, weight: XdWeight.medium),
                ),
                WidgetSpan(child: SizedBox(width: (91 - 81).w)),
                TextSpan(
                  text: WalletBankAccountData.currency(card.currency).tr(),
                  style: xdTextStyle(size: 14),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        WalletField(
          mt: 4,
          label: XdText(
            LocaleKeys.trydos_client_phone_number.tr(),
            size: 12,
            color: XdColors.grey,
          ),
          value: const XdText(
            WalletCashInData.phone,
            size: 14,
            weight: XdWeight.medium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// حقلُ المبلغ، 390 × 55 على x 20، كما يرسمه الملفُّ في كلّ لوح: مستعمَلاً —
/// أبيضَ بخطٍّ أزرق وعنوانٍ 12 Medium — ومعه «0,00 USD» رماديّةٌ ما دام
/// فارغاً (`– 32`، `– 33`) و«100 USD» متى كُتب مبلغٌ (`– 34`). و[note] تمدّه
/// إلى 93 وتضع وسماً أزرق 342 × 30 على 55 من أعلاه (`– 34`).
///
/// والملفُّ يكتب على هذه النماذج بلوحة أرقام الهاتف نفسِها
/// (`NATIVE_WALLET_KEYBOARD`)، فهي لوحةُ النظام هنا.
class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.mt,
    required this.label,
    required this.code,
    required this.amount,
    required this.onChanged,
    this.note,
  });

  final double mt;
  final Widget label;
  final String code;
  final String amount;
  final ValueChanged<String> onChanged;

  /// وسمُ الحسم، يُظهره اللوحُ متى كُتب مبلغ.
  final Widget? note;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _text;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.amount);
    // الحقلُ الذي يرسمه الملفُّ مستعمَلاً يأخذ الكتابةَ بعد أن تستقرّ النافذة.
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool empty = widget.amount.isEmpty;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: widget.mt.h, start: 20.w),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: Container(
          width: Xd.fill(20),
          // 55 طولاً، و93 مع وسم الحسم — والمحتوى أقصرُ منهما، فالطولُ من
          // الملفّ لا من المحتوى. و«أقلُّ طولٍ» لا طولٌ ثابت: الوسمُ يطول متى
          // التفَّ سطرُه بترجمةٍ أطول، كما يقيسه الويب.
          constraints: BoxConstraints(
            minHeight:
                (widget.note == null
                        ? CashInDesign.fieldH
                        : CashInDesign.amountTallH)
                    .h,
          ),
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: XdColors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: XdColors.blue),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.label,
              // سطرُ القيمة في كلّ حقول الملفّ: 23 طولاً و3 تحت العنوان، فيحلّ
              // نصُّ 14 على خطّ أساس الحقل 43. والرمزُ بعد المبلغ، و«0,00 USD»
              // الرماديّة، في الخانة نفسها.
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: SizedBox(
                  height: 23.h,
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: <Widget>[
                      // طبقةٌ تحت: المبلغُ يحفظ عرضَه بلا لونٍ، فيحلّ الرمزُ
                      // بعده كما في الملفّ.
                      Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: '${empty ? '0,00' : widget.amount} ',
                              style: xdTextStyle(
                                size: 14,
                                weight: XdWeight.medium,
                                color: empty
                                    ? XdColors.placeholder
                                    : const Color(0x00000000),
                              ),
                            ),
                            TextSpan(
                              text: widget.code,
                              style: xdTextStyle(
                                size: 14,
                                color: empty
                                    ? XdColors.placeholder
                                    : XdColors.ink,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                      ),
                      TextField(
                        controller: _text,
                        focusNode: _focus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          LengthLimitingTextInputFormatter(12),
                        ],
                        onChanged: widget.onChanged,
                        cursorColor: XdColors.ink,
                        cursorWidth: 1,
                        style: xdTextStyle(size: 14, weight: XdWeight.medium),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.note != null) _charge(),
            ],
          ),
        ),
      ),
    );
  }

  /// 342 × 30 على (44، 477): 55 من أعلى الحقل، 6 تحت سطر القيمة، و12 من
  /// جانبي داخل الحقل. وهو 30 بسطرٍ واحد، ويطول متى التفّ السطر.
  Widget _charge() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (CashInDesign.chargeY - (8 + Xd.lineBox(12) + 3 + 23)).h,
        start: CashInDesign.chargeX.w,
      ),
      child: Container(
        width: Xd.fill(44),
        constraints: BoxConstraints(minHeight: CashInDesign.chargeH.h),
        padding: EdgeInsets.only(
          bottom: (477 + CashInDesign.chargeH - Xd.textBottom(496, 11)).h,
        ),
        decoration: BoxDecoration(
          color: XdColors.blue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: widget.note,
      ),
    );
  }
}

/// وسمُ شبكة العملة الرقميّة: 193 × 28، `#FAE26B` بزاوية 8، موسَّطاً.
class _NetworkTag extends StatelessWidget {
  const _NetworkTag({required this.mt});

  final double mt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: Xd.fromCentre(CashInDesign.networkTagX),
      ),
      child: Container(
        width: CashInDesign.networkTagW.w,
        height: CashInDesign.tabH.h,
        decoration: BoxDecoration(
          color: XdColors.yellow,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: <Widget>[
            // الملفُّ يبدأ الكلمات على x 160.2، كما على التبويب المختار.
            WalletCentred(
              mt: Xd.gapTo(0, 19, 13),
              nudge: 1.17,
              child: Text.rich(
                TextSpan(children: _networkSpans(13)),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «110 USDT إيداع» وعلامةُ USDT 20 قبلها بـ8، من x 136. والصفُّ يحفظ مسافةَ
/// الملفّ من مركز الشاشة.
class _DepositRow extends StatelessWidget {
  const _DepositRow({required this.mt, required this.amount});

  final double mt;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: Xd.fromCentre(CashInDesign.depositRowX),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const XdSvg('usdtMark', folder: kWalletSvg, w: 20),
          SizedBox(
            width:
                (CashInDesign.depositRowTextX - (CashInDesign.depositRowX + 20))
                    .w,
          ),
          Text.rich(
            TextSpan(
              children: walletSlots(
                LocaleKeys.amount_coin_deposit.tr(),
                <String, InlineSpan>{
                  'amount': TextSpan(
                    text: walletCharge(amount),
                    style: xdTextStyle(size: 16, weight: XdWeight.bold),
                  ),
                  'coin': TextSpan(
                    text: WalletCryptoData.coin,
                    style: xdTextStyle(size: 16),
                  ),
                },
                base: xdTextStyle(size: 16, weight: XdWeight.medium),
              ),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// «امسح رمز QR من …» (12 Medium، `#404040`) وعلامةُ الهاتف على x 34.56.
///
/// والملفُّ يُبقي الصفَّ على مسافته من مركز الشاشة على الشاشة العريضة؛ وعلى
/// الضيّقة يبدأ 20 من الحافّة وتلتفّ الكلماتُ 20 قبل الحافّة الأخرى. وترجماتُنا
/// تختلف أطوالها، فاللفُّ هو الصحيح دائماً.
class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.mt});

  final double mt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: 20.w, end: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const XdSvg('scanPhone', folder: kWalletSvg, w: 10.2, h: 14.68),
          SizedBox(
            width:
                (CashInDesign.scanRowTextX - (CashInDesign.scanRowX + 10.2)).w,
          ),
          Expanded(
            child: Text(
              LocaleKeys.scan_qr_from_your_wallet_and_pay.tr(),
              style: xdTextStyle(
                size: 12,
                weight: XdWeight.medium,
                color: XdColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// الأسطرُ البرتقاليّة تحت رمزِ عملةٍ رقميّة: سطران بخطّ SF Pro Rounded على
/// 18، 350 عرضاً من x 40 وموسَّطان، ثمّ الانتهاءُ وساعتُه (والوقتُ عريض).
///
/// و[first] خطُّ أساس السطر الأوّل، والانتهاءُ 43 أخفضُ. والأسطرُ تحفظ 40 إلى
/// حافّتي الشاشة، وصفُّ الانتهاء يبقى موسَّطاً.
class _Expiry extends StatelessWidget {
  const _Expiry({required this.mt, required this.first});

  final double mt;
  final double first;

  @override
  Widget build(BuildContext context) {
    final double paraY = Xd.sfTop(
      first,
      CashInDesign.ruleSize,
      CashInDesign.ruleLine,
    );
    final double rowY = Xd.sfTop(
      first + CashInDesign.expiryGap,
      CashInDesign.ruleSize,
      CashInDesign.ruleLine,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WalletPara(
          text: LocaleKeys.after_period_expired_request_new_qr.tr(),
          mt: mt,
          ml: 40,
          width: Xd.fill(40),
          size: CashInDesign.ruleSize,
          lineHeight: CashInDesign.ruleLine,
          color: XdColors.expiry,
          family: kSafeFamily,
          align: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: (rowY - (paraY + 2 * CashInDesign.ruleLine)).h,
            start: Xd.fromCentre(CashInDesign.expiryClockX),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // أعلى الساعة 2 تحت أعلى السطر.
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: const XdSvg(
                  'expiryClock',
                  folder: kWalletSvg,
                  w: 12.81,
                  h: 14,
                ),
              ),
              SizedBox(
                width:
                    (CashInDesign.expiryTextX -
                            (CashInDesign.expiryClockX + 12.81))
                        .w,
              ),
              Text.rich(
                TextSpan(
                  children: walletSlots(
                    LocaleKeys.expiry_date_time.tr(),
                    <String, InlineSpan>{
                      'date': TextSpan(
                        text: WalletCryptoData.expiryDate,
                        style: _sf(),
                      ),
                      'time': TextSpan(
                        text: WalletCryptoData.expiryTime,
                        style: _sf(bold: true),
                      ),
                    },
                    base: _sf(),
                  ),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _sf({bool bold = false}) => xdTextStyle(
    size: CashInDesign.ruleSize,
    color: XdColors.expiry,
    height: CashInDesign.ruleLine,
  ).copyWith(fontFamily: bold ? 'SF-Pro-Rounded-Bold' : kSafeFamily);
}

/// الشبكةُ كما يكتبها التبويبُ والوسم: العملةُ والمعيارُ Medium، والسلسلةُ
/// عاديّة — `Network`.
List<InlineSpan> _networkSpans(double size) => <InlineSpan>[
  TextSpan(
    text: '${WalletCryptoData.coin} ',
    style: xdTextStyle(size: size, weight: XdWeight.medium),
  ),
  TextSpan(
    text: WalletCryptoData.chain,
    style: xdTextStyle(size: size),
  ),
  TextSpan(
    text: ' ${WalletCryptoData.standard}',
    style: xdTextStyle(size: size, weight: XdWeight.medium),
  ),
];
