/// السحب — نقلٌ كاملٌ لـ
/// `web_design/components/DemoApp1/screens/WalletCashOutSheet.tsx`.
///
/// شرحُ الألواح وأرقامُها في [CashOutDesign]. ولا مسارَ خادمٍ هنا بعد: كلُّ
/// البيانات بياناتُ الملفّ ([WalletRecipientData] و[WalletRequestData] …)
/// حتّى تُسلَّم المسارات — انظر [kWalletApisLive].
///
/// ولوحةُ الأرقام: الويبُ يكتب على هذه النماذج بلوحة الهاتف نفسِها
/// (`NATIVE_WALLET_KEYBOARD = true`)، فلا لوحةَ تطبيقٍ ولا رفعَ نافذةٍ فوقها
/// (`hold` و`drop` و`lift` كلُّها أصفارٌ في تلك الحال) — وهنا لوحةُ النظام.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_cash_in_design.dart';
import 'wallet_cash_out_design.dart';
import 'wallet_design.dart';
import 'wallet_picture_layer.dart';
import 'wallet_sheet_parts.dart';
import 'wallet_sheet_title.dart';
import 'wallet_withdrawal_request_v2.dart';

/// نافذةُ السحب: نافذةٌ واحدةٌ بخمس خطوات، ومعها صفحةُ صورة الطلب.
class WalletCashOutSheetV2 extends StatefulWidget {
  const WalletCashOutSheetV2({
    super.key,
    required this.open,
    required this.onClose,
    required this.card,
  });

  final bool open;
  final VoidCallback onClose;

  /// الرصيدُ الذي يخرج منه المال.
  final WalletCardData card;

  @override
  State<WalletCashOutSheetV2> createState() => _WalletCashOutSheetV2State();
}

class _WalletCashOutSheetV2State extends State<WalletCashOutSheetV2> {
  CashOutStep _step = CashOutStep.ways;

  /// محفوظان هنا، فيعودان إلى النموذج بعد «رجوع» في قارئ الرمز.
  String _amount = '';
  ({String phone, String name})? _authorized;

  /// صورةُ الطلب (`Home Page – 24`) تقع فوق النافذة.
  bool _picture = false;

  @override
  void didUpdateWidget(WalletCashOutSheetV2 old) {
    super.didUpdateWidget(old);
    // النافذةُ تفتح على خطوتها الأولى كلَّ مرّة. والخطوةُ ترجع بعد أن تنزلق
    // النافذةُ بعيداً، فلا تتبدّل وهي خارجة.
    if (old.open && !widget.open) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || widget.open) return;
        setState(() {
          _step = CashOutStep.ways;
          _amount = '';
          _authorized = null;
          _picture = false;
        });
      });
    }
  }

  double get _lower => CashOutDesign.top[_step]! - CashOutDesign.layoutTop;

  WithdrawalRequestData get _request => WithdrawalRequestData(
    amount: _amount,
    authorized: (_authorized?.name.trim().isEmpty ?? true)
        ? null
        : _authorized!.name.trim(),
  );

  /// صفُّ العنوان: «السحب» وصورتُه وعلامةُ العملة.
  Widget _title({required double top}) {
    return WalletSheetTitle(
      top: top,
      icon: 'cashOutBig',
      mark: widget.card.mark,
      label: LocaleKeys.cash_out.tr(),
    );
  }

  /// رأسُ النافذة: العنوانُ ثمّ العلامةُ على خطّ الأساس 180.
  Widget get _head {
    const double top = CashOutDesign.layoutTop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(top: top),
        WalletBrand(size: 24, mt: Xd.gapTo(top + 24 + Xd.lineBox(24), 180, 24)),
      ],
    );
  }

  /// الخطوةُ التي قبلها في الطريق الذي مشاه المستعمل. والمبلغُ والمستلمُ
  /// المفوَّضُ محفوظان في النافذة، فيعودان إلى النموذج كما كانا.
  static const Map<CashOutStep, CashOutStep> _prev = <CashOutStep, CashOutStep>{
    CashOutStep.form: CashOutStep.ways,
    CashOutStep.scan: CashOutStep.form,
    CashOutStep.code: CashOutStep.form,
    CashOutStep.request: CashOutStep.code,
  };

  /// سهمُ الرجوع يُقشّر الأعلى: صورةُ الطلب، ثمّ خطوةٌ إلى الوراء، ثمّ
  /// النافذةُ نفسُها من خطوتها الأولى.
  void _back() {
    if (_picture) {
      setState(() => _picture = false);
      return;
    }
    final CashOutStep? back = _prev[_step];
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
              y: CashOutDesign.layoutTop,
              lower: _lower,
              radius: XdSheet.radiusWallet,
              onClose: widget.onClose,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: KeyedSubtree(
                  key: ValueKey<CashOutStep>(_step),
                  child: _stepBody(),
                ),
              ),
            ),
            WalletPictureLayer(
              open: widget.open && _picture,
              onClose: () => setState(() => _picture = false),
              head: _head,
              children: <Widget>[
                WalletRequestPicture(card: widget.card, request: _request),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case CashOutStep.ways:
        return _Ways(
          title: _title(top: CashOutDesign.top[CashOutStep.ways]!),
          onPick: () => setState(() => _step = CashOutStep.form),
        );
      case CashOutStep.form:
        return _Form(
          head: _head,
          card: widget.card,
          amount: _amount,
          onAmount: (String v) => setState(() => _amount = v),
          authorized: _authorized,
          onAuthorized: (({String phone, String name})? v) =>
              setState(() => _authorized = v),
          onNow: () => setState(() => _step = CashOutStep.scan),
          onRequest: () => setState(() => _step = CashOutStep.code),
        );
      case CashOutStep.scan:
        return _Scan(
          head: _head,
          card: widget.card,
          amount: _amount,
          onBack: () => setState(() => _step = CashOutStep.form),
        );
      case CashOutStep.code:
        return WalletRequestCode(
          head: _head,
          card: widget.card,
          request: _request,
          onVerified: () => setState(() => _step = CashOutStep.request),
        );
      case CashOutStep.request:
        return WalletRequestReady(
          head: _head,
          card: widget.card,
          request: _request,
          onPicture: () => setState(() => _picture = true),
        );
    }
  }
}

/// `Home Page – 21`، النافذةُ من y 244:
///   - الملاحظةُ، 14 بارتفاع سطرٍ 18، 366 عرضاً وموسَّطة، أوّلُ خطّ أساسٍ 324؛
///   - بطاقةُ trydos | rdb 390 × 188 على (20، 366) بخطٍّ بنفسجيّ؛
///   - ثلاثُ خاناتٍ 125 على y 562 وفي كلٍّ صورةٌ 101 على 12 من الداخل؛
///   - البطاقةُ الرماديّة 390 × 188 على (20، 707) وزرّاها 366 × 38.
///
/// وخطوطُ البطاقات والخانات **على** الحافّة (خطُّ XD الأوسط).
class _Ways extends StatelessWidget {
  const _Ways({required this.title, required this.onPick});

  final Widget title;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final double top = CashOutDesign.top[CashOutStep.ways]!;
    final double headEnd = top + 24 + Xd.lineBox(24);
    final double para = Xd.paraTop(
      CashOutDesign.waysParaBaseline,
      14,
      CashOutDesign.waysParaLine,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        WalletUnder(
          children: <Widget>[
            WalletPara(
              text: LocaleKeys.you_can_withdraw_easily_and_securely.tr(),
              mt: para - headEnd,
              ml: 32,
              width: Xd.fill(32),
              size: 14,
              lineHeight: CashOutDesign.waysParaLine,
              align: TextAlign.center,
            ),
            // سطران من 18 يبدآن على 310 فينتهيان على 346.
            WalletBrandCard(
              y: CashOutDesign.brandCardY,
              mt:
                  CashOutDesign.brandCardY -
                  (310 + 2 * CashOutDesign.waysParaLine),
              onTap: onPick,
            ),
            _tiles(),
            _greyCard(context),
          ],
        ),
      ],
    );
  }

  /// الخاناتُ الثلاث تتقاسم عرضَ الصفّ، وبينها 8 ثمّ 7 كما في الملفّ: 125
  /// لكلٍّ على شاشة 430. والصورةُ تملأ الخانة على 12 من الداخل، 101 طولاً.
  Widget _tiles() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top:
            (CashOutDesign.tilesY -
                    (CashOutDesign.brandCardY + CashOutDesign.brandCardH))
                .h,
        start: 20.w,
      ),
      child: SizedBox(
        width: Xd.fill(20),
        child: Row(
          children: <Widget>[
            for (final WalletProviderData p in kWalletProviders) ...<Widget>[
              if (p.gap > 0) SizedBox(width: p.gap.w),
              Expanded(
                child: Semantics(
                  button: true,
                  label: p.name,
                  child: XdTap(
                    scale: 0.97,
                    child: Container(
                      height: CashOutDesign.tile.h,
                      padding: EdgeInsets.all(PayWaysDesign.pad.w),
                      decoration: BoxDecoration(
                        color: XdColors.card,
                        borderRadius: BorderRadius.circular(
                          PayWaysDesign.radius.r,
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(color: XdColors.line),
                        borderRadius: BorderRadius.circular(
                          PayWaysDesign.radius.r,
                        ),
                      ),
                      // الصورةُ تأخذ عرضَ الخانة وتُقصّ من جانبيها على
                      // الشاشة الضيّقة، كما يفعل الملفّ.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          PayWaysDesign.radius.r,
                        ),
                        child: Image.asset(
                          'assets/images/wallet_v2/${p.picture}',
                          height: PayWaysDesign.inner.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// البطاقةُ الرماديّة. تنتهي على y 895: 35 فوق أسفل اللوح.
  Widget _greyCard(BuildContext context) {
    final double para = Xd.paraTop(
      CashOutDesign.greyParaBaseline,
      11,
      CashOutDesign.greyParaLine,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top:
            (CashOutDesign.greyCardY -
                    (CashOutDesign.tilesY + CashOutDesign.tile))
                .h,
        start: 20.w,
        bottom:
            CashOutDesign.boardTail.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        width: Xd.fill(20),
        constraints: BoxConstraints(minHeight: CashOutDesign.greyCardH.h),
        padding: EdgeInsets.only(
          bottom:
              (895 - (CashOutDesign.greyButtonY2 + CashOutDesign.greyButtonH))
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
              text: LocaleKeys.withdraw_your_funds_now.tr(),
              mt: Xd.gapTo(
                CashOutDesign.greyCardY,
                CashOutDesign.greyTitleBaseline,
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
              text: LocaleKeys.you_can_withdraw_your_funds_note.tr(),
              mt: para - Xd.textBottom(CashOutDesign.greyTitleBaseline, 11),
              ml: 32 - 20,
              width: Xd.fill(32),
              size: 11,
              lineHeight: CashOutDesign.greyParaLine,
              color: XdColors.grey,
              align: TextAlign.center,
            ),
            // ثلاثةُ أسطرٍ تنتهي على y 793، والزرُّ الأوّل على 801.
            WalletInfoButton(
              mt:
                  CashOutDesign.greyButtonY -
                  (para + 3 * CashOutDesign.greyParaLine),
              label: LocaleKeys.available_branches.tr(),
            ),
            // الملفُّ يبدأ «معلومات أكثر» على x 190: نصفَ بكسلٍ يسارَ المركز.
            WalletInfoButton(
              mt:
                  CashOutDesign.greyButtonY2 -
                  (CashOutDesign.greyButtonY + CashOutDesign.greyButtonH),
              nudge: -0.5,
              label: LocaleKeys.more_info.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// النموذج، النافذةُ من y 90. وفي كلّ لوح:
///   - العلامةُ (24) على خطّ الأساس 180؛
///   - تبويبان 193 × 28 على y 213 بينهما 4: المختارُ `#79E9B3` والآخرُ بخطّ؛
///   - حقلا المستلم، 390 × 55 على y 245 و304.
///
/// وتحتهما الحالاتُ التي يرسمها الملفّ:
///   - `– 19` عند الفتح: «+ أضف مستلماً مفوَّضاً» 356 × 30 على (32، 363)،
///     وحقلُ المبلغ مستعمَلاً على y 515 (أبيضُ بخطٍّ أزرق)؛
///   - `– 20` والمبلغُ أكثرُ من الرصيد: الحقلُ 93 طولاً بخطٍّ برتقاليّ، وفيه
///     «رصيدك غير كافٍ» على وسمٍ 366 × 30 على 55 من أعلاه؛
///   - `– 25` بعد «+ أضف»: حقلان على y 363 و422، أوّلُهما مستعمَل، ثمّ
///     «− أزِل مستلماً مفوَّضاً» على (37، 481)؛
///   - `– 27` وكلٌّ مملوء ومعه مستلمٌ مفوَّض: كلُّ حقلٍ `#FCFCFC` وفي عنوانه
///     «تعديل» أزرق، والتنبيهُ على (37، 574) و«طلب سحب» على (20، 835)؛
///   - `– 29` وكلٌّ مملوء بلا مستلمٍ مفوَّض: حقلُ المبلغ يصعد إلى y 397،
///     و«اسحب الآن» (20، 767) فوق «طلب سحب».
///
/// و`– 36` هو التبويبُ الآخر «إلى rdb الخاصّ بي»: حسابُ العميل في ثلاثة حقولٍ
/// على y 245 و304 و363، وحقلُ المبلغ تحتها على 422 مستعمَلاً. والتبويبُ غيرُ
/// المختار `#F8F8F8` هناك. و`– 35` هو هو مع مبلغٍ مكتوب: «اسحب إلى rdb» على
/// (20، 835).
class _Form extends StatefulWidget {
  const _Form({
    required this.head,
    required this.card,
    required this.amount,
    required this.onAmount,
    required this.authorized,
    required this.onAuthorized,
    required this.onNow,
    required this.onRequest,
  });

  final Widget head;
  final WalletCardData card;

  final String amount;
  final ValueChanged<String> onAmount;

  final ({String phone, String name})? authorized;
  final ValueChanged<({String phone, String name})?> onAuthorized;

  /// «اسحب الآن»: إلى قارئ الرمز.
  final VoidCallback onNow;

  /// «طلب سحب»: إلى الرمز (`Home Page – 101`).
  final VoidCallback onRequest;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool _toBank = false;
  CashOutField? _active;

  /// كان حقلُ المبلغ فارغاً حين دخلته الكتابةُ آخرَ مرّة.
  bool _fromEmpty = false;

  final TextEditingController _amountText = TextEditingController();
  final TextEditingController _phoneText = TextEditingController();
  final TextEditingController _nameText = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // النموذجُ يُبنى من جديدٍ بعد «رجوع» في قارئ الرمز، والمبلغُ والمفوَّضُ
    // محفوظان في النافذة — فتُستأنف الحقولُ ممّا فيها.
    _amountText.text = widget.amount;
    _phoneText.text = widget.authorized?.phone ?? '';
    _nameText.text = widget.authorized?.name ?? '';
    _amountFocus.addListener(_watch);
    _phoneFocus.addListener(_watch);
    _nameFocus.addListener(_watch);
  }

  @override
  void dispose() {
    _amountText.dispose();
    _phoneText.dispose();
    _nameText.dispose();
    _amountFocus.dispose();
    _phoneFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  /// أيُّ حقلٍ مستعمَل. والملفُّ يفتح لوحةَ الهاتف باللمس وحدَه، فلا حقلَ
  /// مستعمَلاً عند الفتح: حقلُ المبلغ ينتظر على y 515.
  void _watch() {
    final CashOutField? now = _amountFocus.hasFocus
        ? CashOutField.amount
        : _phoneFocus.hasFocus
        ? CashOutField.phone
        : _nameFocus.hasFocus
        ? CashOutField.name
        : null;
    if (now == CashOutField.amount && _active != CashOutField.amount) {
      _fromEmpty = widget.amount.isEmpty;
    }
    if (now != _active) setState(() => _active = now);
  }

  /// المستلمُ المفوَّض جزءٌ من تبويب النقد وحدَه.
  ({String phone, String name})? get _named =>
      _toBank ? null : widget.authorized;

  bool get _typing => _active == CashOutField.amount;

  /// `– 20`: أكثرُ ممّا يحمله الرصيد.
  bool get _short =>
      walletAmount(widget.amount) > walletAmount(widget.card.amount);

  /// منظرُ `– 27` و`– 29`: `#FCFCFC` و«تعديل» في العنوان.
  bool get _saved => widget.amount.isNotEmpty && !_typing && !_short;

  bool get _complete {
    final ({String phone, String name})? n = _named;
    return n == null || (n.phone.isNotEmpty && n.name.trim().isNotEmpty);
  }

  bool get _ready =>
      _active == null &&
      walletAmount(widget.amount) > 0 &&
      !_short &&
      _complete;

  /// حيث تنتهي الكتلةُ فوق حقل المبلغ.
  double get _above => _toBank
      ? CashOutDesign.field3Y + CashOutDesign.fieldH
      : _named != null
      ? CashOutDesign.removeY + CashOutDesign.addH
      : CashOutDesign.field3Y + CashOutDesign.addH;

  double get _amountHeight =>
      _short ? CashOutDesign.amountTallH : CashOutDesign.fieldH;

  /// y حقل المبلغ. وبلوحة الهاتف لا يرتفع شيء: الحقلُ الفارغ الذي دخلته
  /// الكتابةُ يبقى على 515 حتّى تخرج منه.
  double get _amountTop {
    if (_toBank) return CashOutDesign.amountBankY;
    if (_named != null) return CashOutDesign.amountUseY;
    if (_typing) {
      return _fromEmpty ? CashOutDesign.amountUseY : _above + 4;
    }
    return widget.amount.isEmpty
        ? CashOutDesign.amountUseY
        : CashOutDesign.amountSavedY;
  }

  void _choose(bool bank) {
    if (bank == _toBank) return;
    setState(() => _toBank = bank);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.head,
        // التبويبان يتقاسمان عرضَ الصفّ، وبينهما 4: 193 لكلٍّ على شاشة 430.
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: (CashOutDesign.tabsY - CashOutDesign.headEnd).h,
            start: 20.w,
          ),
          child: SizedBox(
            width: Xd.fill(20),
            child: Row(
              children: <Widget>[
                WalletTab(
                  chosen: !_toBank,
                  fill: XdColors.field,
                  // الملفُّ يبدأ كلماتِ Medium على x 65.14.
                  nudge: _toBank ? 0.5 : -0.5,
                  onTap: () => _choose(false),
                  spans: (XdWeight w) => <InlineSpan>[
                    TextSpan(
                      text: LocaleKeys.cash_withdrawal.tr(),
                      style: xdTextStyle(size: 13, weight: w),
                    ),
                  ],
                ),
                WalletTab(
                  chosen: _toBank,
                  // والملفُّ يبدأها على x 283.33 (Medium) و283.55 (عاديّ).
                  nudge: _toBank ? 0.5 : 1.17,
                  ml: 4,
                  onTap: () => _choose(true),
                  spans: (XdWeight w) => walletWithBank(
                    LocaleKeys.to_my_bank.tr(),
                    size: 13,
                    weight: w,
                  ),
                ),
              ],
            ),
          ),
        ),
        WalletUnder(children: _under(context)),
      ],
    );
  }

  List<Widget> _under(BuildContext context) {
    return <Widget>[
      if (_toBank)
        WalletField(
          mt:
              CashOutDesign.field1Y -
              (CashOutDesign.tabsY + CashOutDesign.tabH),
          label: _bankLabel(LocaleKeys.bank_client_id),
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
                  text: WalletBankAccountData.currency(
                    widget.card.currency,
                  ).tr(),
                  style: xdTextStyle(size: 14),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      WalletField(
        mt: _toBank
            ? CashOutDesign.field2Y -
                  (CashOutDesign.field1Y + CashOutDesign.fieldH)
            : CashOutDesign.field1Y -
                  (CashOutDesign.tabsY + CashOutDesign.tabH),
        label: _toBank
            ? _bankLabel(LocaleKeys.bank_client_phone_number)
            : _recipientLabel(LocaleKeys.trydos_client_phone_number),
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
        mt: CashOutDesign.cellGap,
        label: _toBank
            ? _bankLabel(LocaleKeys.bank_client_full_name_exact_id)
            : _recipientLabel(LocaleKeys.trydos_client_full_name_exact_id),
        value: const XdText(
          WalletRecipientData.name,
          size: 14,
          overflow: TextOverflow.ellipsis,
        ),
        // الملفُّ يرسم العينَ على ألواح تبويب النقد بلا حقلٍ مستعمَل،
        // على (383، 324): 20 من أعلى الحقل و12 من حافّته اليمنى.
        mark: !_toBank && _active == null,
        markIcon: 'eyeGreySmall',
        markW: 15,
      ),
      if (!_toBank) ...(_named != null ? _withNamed() : _addButton()),
      _amountField(),
      if (_named != null && _active == null) _namedNote(),
      // الملفُّ يُدخِل الزرّين ويُخرجهما (`AnimatePresence`)، فلا يشغلان
      // فراغاً ما لم يجهز النموذج.
      if (_ready) _buttons(context),
    ];
  }

  /// عنوانٌ فيه اسمُ المصرف عريضاً.
  Widget _bankLabel(String key) => Text.rich(
    TextSpan(
      children: walletWithBank(key.tr(), size: 12, color: XdColors.grey),
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  /// عنوانُ حقلِ المستلم: «المستلم» Medium ثمّ بقيّةُ العنوان.
  Widget _recipientLabel(String key) => Text.rich(
    TextSpan(
      children: <InlineSpan>[
        TextSpan(
          text: LocaleKeys.recipient.tr(),
          style: xdTextStyle(
            size: 12,
            weight: XdWeight.medium,
            color: XdColors.grey,
          ),
        ),
        TextSpan(
          text: ' ${key.tr()}',
          style: xdTextStyle(size: 12, color: XdColors.grey),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  /// `– 19`: «+ أضف مستلماً مفوَّضاً» على (32، 363).
  List<Widget> _addButton() => <Widget>[
    _RecipientButton(
      mt: CashOutDesign.addY - (CashOutDesign.field2Y + CashOutDesign.fieldH),
      ml: CashOutDesign.addX,
      // الملفُّ يبدأ الكلمات على x 140.06.
      nudge: -2,
      sign: '+',
      verb: LocaleKeys.add.tr(),
      onTap: () {
        widget.onAuthorized((phone: '', name: ''));
        // `– 25`: حقلُ الهاتف الجديد هو المستعمَل.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _phoneFocus.requestFocus(),
        );
      },
    ),
  ];

  /// `– 25` و`– 27`: حقلا المفوَّض ثمّ «− أزِل».
  List<Widget> _withNamed() {
    final ({String phone, String name}) n = _named!;
    return <Widget>[
      _Entry(
        mt:
            CashOutDesign.entry1Y -
            (CashOutDesign.field2Y + CashOutDesign.fieldH),
        label: LocaleKeys.authorized_recipient_phone_number.tr(),
        filled: n.phone.isNotEmpty,
        active: _active == CashOutField.phone,
        onUse: _phoneFocus.requestFocus,
        // «+» عريضةٌ على x 32، والرقمُ من x 44.
        child: Row(
          children: <Widget>[
            SizedBox(
              width: (44 - 32).w,
              child: XdText(
                '+',
                size: 14,
                weight: XdWeight.bold,
                color: n.phone.isEmpty ? XdColors.placeholder : XdColors.ink,
              ),
            ),
            Expanded(
              child: _input(
                controller: _phoneText,
                focus: _phoneFocus,
                keyboard: TextInputType.phone,
                formatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                hint: n.phone.isEmpty
                    ? LocaleKeys.enter_recipient_phone_number.tr()
                    : null,
                hintWeight: XdWeight.light,
                onChanged: (String v) =>
                    widget.onAuthorized((phone: v, name: n.name)),
              ),
            ),
          ],
        ),
      ),
      _Entry(
        mt:
            CashOutDesign.entry2Y -
            (CashOutDesign.entry1Y + CashOutDesign.fieldH),
        label: LocaleKeys.authorized_recipient_full_name_exact_id.tr(),
        filled: n.name.isNotEmpty,
        active: _active == CashOutField.name,
        onUse: _nameFocus.requestFocus,
        child: _input(
          controller: _nameText,
          focus: _nameFocus,
          keyboard: TextInputType.name,
          onChanged: (String v) =>
              widget.onAuthorized((phone: n.phone, name: v)),
        ),
      ),
      // الملفُّ يرسم هذا الزرَّ 5 يمينَ زرّ الإضافة.
      _RecipientButton(
        mt:
            CashOutDesign.removeY -
            (CashOutDesign.entry2Y + CashOutDesign.fieldH),
        ml: CashOutDesign.removeX,
        // الملفُّ يبدأ الكلمات على x 134.99.
        nudge: -2.67,
        sign: '-',
        verb: LocaleKeys.remove.tr(),
        onTap: () {
          widget.onAuthorized(null);
          _phoneText.clear();
          _nameText.clear();
          FocusScope.of(context).unfocus();
        },
      ),
    ];
  }

  /// حقلٌ عاديّ 23 طولاً، ونصُّه 14 على خطّ أساس الحقل 43.
  Widget _input({
    required TextEditingController controller,
    required FocusNode focus,
    required TextInputType keyboard,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? formatters,
    String? hint,
    XdWeight hintWeight = XdWeight.regular,
  }) {
    return SizedBox(
      height: 23.h,
      child: TextField(
        controller: controller,
        focusNode: focus,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: onChanged,
        cursorColor: XdColors.ink,
        cursorWidth: 1,
        style: xdTextStyle(size: 14),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: xdTextStyle(
            size: 14,
            weight: hintWeight,
            color: XdColors.placeholder,
          ),
        ),
      ),
    );
  }

  /// حقلُ المبلغ بحالاته الأربع.
  Widget _amountField() {
    final bool empty = widget.amount.isEmpty;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsetsDirectional.only(
        top: (_amountTop - _above).h,
        start: 20.w,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _amountFocus.requestFocus,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: Xd.fill(20),
          // 55 طولاً، و93 مع التنبيه — والمحتوى أقصرُ منهما، فالطولُ من
          // الملفّ لا من المحتوى. و«أقلُّ طولٍ» لا طولٌ ثابت: التنبيهُ يطول
          // متى التفَّ سطرُه بترجمةٍ أطول.
          constraints: BoxConstraints(minHeight: _amountHeight.h),
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _saved ? XdColors.card : XdColors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          foregroundDecoration: _saved
              ? null
              : BoxDecoration(
                  border: Border.all(
                    color: _short
                        ? XdColors.orange
                        : _typing
                        ? XdColors.blue
                        : XdColors.line,
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _amountLabel(),
              // سطرُ القيمة: 23 طولاً و3 تحت العنوان، فيحلّ نصُّ 14 على خطّ
              // أساس الحقل 43.
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: SizedBox(
                  height: 23.h,
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: <Widget>[
                      if (empty)
                        Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: '0,00 ',
                                style: xdTextStyle(
                                  size: 14,
                                  weight: XdWeight.medium,
                                  color: XdColors.placeholder,
                                ),
                              ),
                              TextSpan(
                                text: widget.card.code,
                                style: xdTextStyle(
                                  size: 14,
                                  color: XdColors.placeholder,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                        )
                      else if (_saved)
                        // الرمزُ بعد المبلغ المحفوظ: «USD» تبدأ على x 58، 5
                        // بعد «100». ونسخةٌ غيرُ مرئيّةٍ من المبلغ تحفظ مكانَه.
                        Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: widget.amount,
                                style: xdTextStyle(
                                  size: 14,
                                  weight: XdWeight.medium,
                                  color: const Color(0x00000000),
                                ),
                              ),
                              WidgetSpan(child: SizedBox(width: 5.w)),
                              TextSpan(
                                text: widget.card.code,
                                style: xdTextStyle(size: 14),
                              ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      TextField(
                        controller: _amountText,
                        focusNode: _amountFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          LengthLimitingTextInputFormatter(12),
                        ],
                        onChanged: widget.onAmount,
                        cursorColor: XdColors.ink,
                        cursorWidth: 1,
                        style: xdTextStyle(
                          size: 14,
                          weight: _saved ? XdWeight.medium : XdWeight.regular,
                        ),
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
              if (_short) _shortTint(),
            ],
          ),
        ),
      ),
    );
  }

  /// عنوانُ حقل المبلغ: «أدخل المبلغ» حين يزيد، أو العنوانُ والرصيدُ المتاح
  /// حين يكون مستعمَلاً، أو «تعديل المبلغ» حين يُحفظ، أو «المبلغ» رماديّاً.
  Widget _amountLabel() {
    if (_short) {
      return XdText(
        LocaleKeys.enter_amount_label.tr(),
        size: 12,
        weight: XdWeight.medium,
      );
    }
    if (_typing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _toBank
                ? Text.rich(
                    TextSpan(
                      children: walletWithBank(
                        LocaleKeys.enter_withdrawal_amount_to_your_bank.tr(),
                        size: 12,
                        weight: XdWeight.medium,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : XdText(
                    LocaleKeys.enter_withdrawal_amount.tr(),
                    size: 12,
                    weight: XdWeight.medium,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          // من x 291 في الملفّ، وينتهي 12 داخل الحافّة.
          SizedBox(
            width: CashOutDesign.availableW.w,
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${LocaleKeys.available.tr()} ',
                    style: xdTextStyle(size: 12, color: XdColors.placeholder),
                  ),
                  TextSpan(
                    text: widget.card.amount,
                    style: xdTextStyle(
                      size: 12,
                      weight: XdWeight.medium,
                      color: XdColors.placeholder,
                    ),
                  ),
                  TextSpan(
                    text: ' ${widget.card.code}',
                    style: xdTextStyle(size: 12, color: XdColors.placeholder),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    if (_saved) return _EditLabel(field: LocaleKeys.amount_label.tr());
    return XdText(LocaleKeys.amount_label.tr(), size: 12, color: XdColors.grey);
  }

  /// 366 × 30 على (32، 532): 55 من أعلى الحقل، 6 تحت سطر القيمة.
  Widget _shortTint() {
    return Padding(
      // 55 من أعلى الحقل، أي 6 تحت سطر القيمة.
      padding: EdgeInsets.only(
        top: (CashOutDesign.shortTintY - (8 + Xd.lineBox(12) + 3 + 23)).h,
      ),
      child: Container(
        width: double.infinity,
        height: CashOutDesign.shortH.h,
        decoration: BoxDecoration(
          color: XdColors.orangeTint,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: <Widget>[
            WalletCentred(
              mt: Xd.gapTo(
                CashOutDesign.shortY,
                CashOutDesign.shortBaseline,
                11,
              ),
              child: XdText(
                LocaleKeys.your_balance_is_insufficient.tr(),
                size: 11,
                align: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 356 × 30 على (37، 574)، 4 تحت حقل المبلغ. والملفُّ يُوسّط الكلمات على
  /// x 210: 5 يسارَ مركز الوسم.
  Widget _namedNote() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top:
            (CashOutDesign.namedY -
                    (CashOutDesign.amountUseY + CashOutDesign.fieldH))
                .h,
        start: CashOutDesign.namedX.w,
      ),
      child: Container(
        width: Xd.fill(CashOutDesign.namedX),
        constraints: BoxConstraints(minHeight: CashOutDesign.namedH.h),
        decoration: BoxDecoration(
          color: XdColors.noteTint,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: <Widget>[
            WalletCentred(
              mt: Xd.gapTo(
                CashOutDesign.namedY,
                CashOutDesign.namedBaseline,
                11,
              ),
              nudge: -5,
              child: XdText(
                LocaleKeys.only_the_named_person_may_receive.tr(),
                size: 11,
                align: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// الزرّان العريضان. والملفُّ يُسنِدهما إلى أسفل اللوح، فيحلّان على y 767
  /// و835 وينتهيان على 895.
  Widget _buttons(BuildContext context) {
    final double afterAmount = _amountTop + _amountHeight;
    final double mt = _named != null
        ? CashOutDesign.buttonY - (CashOutDesign.namedY + CashOutDesign.namedH)
        : _toBank
        ? CashOutDesign.buttonY - afterAmount
        : CashOutDesign.buttonNowY - afterAmount;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            CashOutDesign.boardTail.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        builder: (BuildContext context, double t, Widget? buttons) =>
            Opacity(opacity: t, child: buttons),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_toBank)
              // `– 35`. والملفُّ يبدأ الكلمات على x 147: نصفَ بكسلٍ يمينَ
              // المركز.
              WalletSheetButton(
                mt: mt,
                label: Text.rich(
                  TextSpan(
                    children: walletWithBank(
                      LocaleKeys.withdrawal_to_bank.tr(),
                      size: 16,
                      color: XdColors.white,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                nudge: 0.5,
                fill: XdColors.inkSoft,
              )
            else ...<Widget>[
              if (_named == null)
                WalletSheetButton(
                  mt: mt,
                  label: XdText(
                    LocaleKeys.withdrawal_now.tr(),
                    size: 16,
                    color: XdColors.white,
                    align: TextAlign.center,
                  ),
                  fill: XdColors.purple,
                  onTap: widget.onNow,
                ),
              WalletSheetButton(
                mt: _named == null
                    ? CashOutDesign.buttonY -
                          (CashOutDesign.buttonNowY + CashOutDesign.buttonH)
                    : mt,
                label: XdText(
                  LocaleKeys.withdrawal_request.tr(),
                  size: 16,
                  color: XdColors.white,
                  align: TextAlign.center,
                ),
                fill: XdColors.inkSoft,
                onTap: widget.onRequest,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `Home Page – 30`، النافذةُ من y 90 بعد «اسحب الآن»:
///   - العلامةُ (24) على خطّ الأساس 180؛
///   - الصندوقُ الأسود 350 × 350 على (40، 213) بزاوية 30: العلامةُ 25 على
///     (202، 500) وسطرٌ 11 على خطّ الأساس 548؛
///   - «سحبٌ نقديّ» (16 Medium) على 591 والمبلغُ (24) على 631؛
///   - الملاحظةُ الرماديّة، 13 بارتفاع سطرٍ 18، 366 عرضاً، أوّلُ خطّ أساسٍ 662؛
///   - «رجوع» 390 × 60 على (20، 835)، `#FCFCFC` بخطٍّ متقطّع.
///
/// والصندوقُ الأسود يحفظ طولَه 350 و40 إلى الحافّتين، فيكون مربّعاً على شاشة
/// 430 وحدَها.
class _Scan extends StatelessWidget {
  const _Scan({
    required this.head,
    required this.card,
    required this.amount,
    required this.onBack,
  });

  final Widget head;
  final WalletCardData card;
  final String amount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final double para = Xd.paraTop(
      CashOutDesign.scanParaBaseline,
      CashOutDesign.scanParaSize,
      CashOutDesign.scanParaLine,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        head,
        WalletUnder(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: (CashOutDesign.scanBoxY - CashOutDesign.headEnd).h,
                start: CashOutDesign.scanBoxX.w,
              ),
              child: Container(
                width: Xd.fill(CashOutDesign.scanBoxX),
                height: CashOutDesign.scanBoxH.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(
                    CashOutDesign.scanBoxRadius.r,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    // الملفُّ يضع العلامةَ نصفَ بكسلٍ يسارَ مركز الصندوق.
                    Padding(
                      padding: EdgeInsets.only(
                        top: (CashOutDesign.scanMarkY - CashOutDesign.scanBoxY)
                            .h,
                        right: 1.w,
                      ),
                      child: const XdSvg(
                        'scanCode',
                        folder: kWalletSvg,
                        w: CashOutDesign.scanMark,
                      ),
                    ),
                    // والسطرَ بكسلاً يمينَه. والصندوقُ 350 ثابتةٌ، والسطرُ
                    // سطرٌ واحدٌ في الملفّ — فإن التفَّ بترجمةٍ أطولَ أخذ ما
                    // بقي من الصندوق ولم يَفِض عنه.
                    Flexible(
                      child: WalletCentred(
                        mt: Xd.gapTo(
                          CashOutDesign.scanMarkY + CashOutDesign.scanMark,
                          CashOutDesign.scanLineBaseline,
                          11,
                        ),
                        nudge: 1,
                        child: XdText(
                          LocaleKeys.read_the_code_on_the_opposite_side.tr(),
                          size: 11,
                          color: XdColors.card,
                          align: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WalletCentred(
              mt: Xd.gapTo(
                CashOutDesign.scanBoxY + CashOutDesign.scanBoxH,
                CashOutDesign.scanTitleBaseline,
                16,
              ),
              nudge: -0.5,
              child: XdText(
                LocaleKeys.cash_withdraw.tr(),
                size: 16,
                weight: XdWeight.medium,
                align: TextAlign.center,
              ),
            ),
            WalletCentred(
              mt: Xd.gapTo(
                Xd.textBottom(CashOutDesign.scanTitleBaseline, 16),
                CashOutDesign.scanAmountBaseline,
                24,
              ),
              nudge: -0.5,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$amount ',
                      style: xdTextStyle(size: 24, weight: XdWeight.medium),
                    ),
                    TextSpan(text: card.code, style: xdTextStyle(size: 24)),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            // ثلاثُ فقراتٍ يفصلها الملفُّ بسطرٍ فارغٍ ثمّ بسطر، وآخرُها
            // «شكراً لك.» بخطٍّ Medium.
            WalletPara(
              spans: <InlineSpan>[
                ..._brandSentence(),
                TextSpan(
                  text:
                      '\n\n${LocaleKeys.do_not_leave_the_page_until_confirmed.tr()}\n',
                  style: _grey(),
                ),
                TextSpan(
                  text: '${LocaleKeys.thank_you.tr()}.',
                  style: _grey(weight: XdWeight.medium),
                ),
              ],
              mt: para - Xd.textBottom(CashOutDesign.scanAmountBaseline, 24),
              ml: 32,
              width: Xd.fill(32),
              size: CashOutDesign.scanParaSize,
              lineHeight: CashOutDesign.scanParaLine,
              color: XdColors.grey,
              align: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    CashOutDesign.boardTail.h +
                    MediaQuery.paddingOf(context).bottom,
              ),
              // الملفُّ يبدأ «رجوع» على x 197: نصفَ بكسلٍ يمينَ المركز.
              child: WalletSheetButton(
                mt:
                    CashOutDesign.buttonY -
                    (para + 6 * CashOutDesign.scanParaLine),
                label: XdText(
                  LocaleKeys.back.tr(),
                  size: 16,
                  align: TextAlign.center,
                ),
                nudge: 0.5,
                fill: XdColors.card,
                color: XdColors.ink,
                stroke: XdColors.lineDark,
                dash: true,
                onTap: onBack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _grey({XdWeight weight = XdWeight.regular}) => xdTextStyle(
    size: CashOutDesign.scanParaSize,
    weight: weight,
    color: XdColors.grey,
    height: CashOutDesign.scanParaLine,
  );

  /// الجملةُ الأولى وفيها العلامةُ، و«try» و«rdb» عريضتان فيها.
  List<InlineSpan> _brandSentence() {
    final List<String> parts = LocaleKeys.please_read_the_code_at_the_center
        .tr()
        .split('{brand}');
    return <InlineSpan>[
      TextSpan(text: parts.first, style: _grey()),
      TextSpan(
        text: WalletBrandData.start,
        style: _grey(weight: XdWeight.bold),
      ),
      TextSpan(text: WalletBrandData.rest, style: _grey()),
      TextSpan(
        text: WalletBrandData.bank,
        style: _grey(weight: XdWeight.bold),
      ),
      if (parts.length > 1) TextSpan(text: parts[1], style: _grey()),
    ];
  }
}

/// «+ أضف مستلماً مفوَّضاً» أو «− أزِل مستلماً مفوَّضاً»: 356 × 30، `#FCFCFC`
/// بزاوية 12، وكلماتُه 11 على خطّ الأساس 19 — `RecipientButton`.
class _RecipientButton extends StatelessWidget {
  const _RecipientButton({
    required this.mt,
    required this.ml,
    required this.sign,
    required this.verb,
    required this.onTap,
    this.nudge = 0,
  });

  final double mt;
  final double ml;

  /// كم يُزيح الملفُّ الكلماتَ عن مركز الزرّ.
  final double nudge;

  final String sign;
  final String verb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: ml.w),
      child: XdTap(
        scale: 0.98,
        onTap: onTap,
        child: Container(
          width: Xd.fill(ml, Xd.designW - ml - CashOutDesign.addW),
          height: CashOutDesign.addH.h,
          decoration: BoxDecoration(
            color: XdColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: <Widget>[
              WalletCentred(
                mt: Xd.gapTo(CashOutDesign.addY, CashOutDesign.addBaseline, 11),
                nudge: nudge,
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: '$sign $verb ',
                        style: xdTextStyle(size: 11, weight: XdWeight.medium),
                      ),
                      TextSpan(
                        text: LocaleKeys.authorized_recipient.tr(),
                        style: xdTextStyle(size: 11),
                      ),
                      // سطرُ الملفّ ينتهي بفراغٍ، وهو موسَّطٌ معه.
                      TextSpan(
                        text: ' ',
                        style: xdTextStyle(size: 11, weight: XdWeight.medium),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنوانُ حقلٍ مملوء: اسمُ الحقل رماديٌّ و«تعديل» أزرق — `EditLabel`.
class _EditLabel extends StatelessWidget {
  const _EditLabel({required this.field});

  final String field;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = LocaleKeys.edit_field.tr().split('{field}');
    final TextStyle grey = xdTextStyle(size: 12, color: XdColors.grey);
    final TextStyle blue = xdTextStyle(size: 12, color: XdColors.blue);
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: parts.first, style: blue),
          TextSpan(text: field, style: grey),
          if (parts.length > 1) TextSpan(text: parts[1], style: blue),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// حقلُ المستلم المفوَّض، 390 × 55. وله ثلاثةُ مناظرَ في الملفّ:
///   - مستعمَلاً (`– 25`، الهاتف): أبيضُ بخطٍّ أزرق، وعنوانُه Medium داكنٌ
///     يبدأ بـ«أدخل»؛
///   - فارغاً وغيرَ مستعمَلٍ (`– 25`، الاسم): أبيضُ بخطٍّ رماديٍّ وعنوانٍ
///     رماديّ؛
///   - مملوءاً (`– 27`): `#FCFCFC` بلا خطّ، و«تعديل» أزرقُ قبل عنوانه.
class _Entry extends StatelessWidget {
  const _Entry({
    required this.mt,
    required this.label,
    required this.filled,
    required this.active,
    required this.onUse,
    required this.child,
  });

  final double mt;
  final String label;
  final bool filled;
  final bool active;
  final VoidCallback onUse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool saved = filled && !active;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: mt.h, start: 20.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onUse,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: Xd.fill(20),
          height: CashOutDesign.fieldH.h,
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, top: 8.h),
          decoration: BoxDecoration(
            color: saved ? XdColors.card : XdColors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          foregroundDecoration: saved
              ? null
              : BoxDecoration(
                  border: Border.all(
                    color: active ? XdColors.blue : XdColors.line,
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (active)
                XdText(
                  LocaleKeys.enter_field.tr(
                    namedArgs: <String, String>{'field': label},
                  ),
                  size: 12,
                  weight: XdWeight.medium,
                  overflow: TextOverflow.ellipsis,
                )
              else if (saved)
                _EditLabel(field: label)
              else
                XdText(
                  label,
                  size: 12,
                  color: XdColors.grey,
                  overflow: TextOverflow.ellipsis,
                ),
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
