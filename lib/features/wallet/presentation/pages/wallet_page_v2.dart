import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../wallet_config.dart';
import 'wallet_cash_in_sheet_v2.dart';
import 'wallet_cash_out_sheet_v2.dart';
import 'wallet_design.dart';
import 'wallet_info_sheet_v2.dart';
import 'wallet_receipt_v2.dart';

/// رصيد Trydos — لوحا XD `Home Page – 11` و`– 17`.
///
/// شرحُ اللوحين وأرقامُهما في [WalletDesign].
///
/// وبياناتُها بياناتُ الملفّ ([kWalletCards] و[kWalletEntries]) حتّى تجهز
/// مسارات الخادم — انظر [kWalletApisLive].
class WalletPageV2 extends StatefulWidget {
  const WalletPageV2({super.key});

  @override
  State<WalletPageV2> createState() => _WalletPageV2State();
}

class _WalletPageV2State extends State<WalletPageV2> {
  /// دليلُ البطاقة الممدودة، أو `null` والبطاقتان صغيرتان.
  int? _grown;

  /// وقع انزلاقٌ في هذه اللمسة، فلا تُطوى البطاقة عند رفع الإصبع.
  bool _sliding = false;

  /// الطبقات التي تفتح فوق الصفحة — `– 23` و`– 18`.
  bool _info = false;
  bool _receipt = false;

  /// الأرصدةُ مخفيّةٌ نجوماً — لمسةُ العين في سطر «رصيدك الكلّي».
  bool _hidden = false;

  /// الحركةُ التي حولها الخطّ ومبلغُها عريض. والملفُّ يرسمها على الأولى
  /// (أحدثِ حركة)، ثمّ تتبع ما يُلمَس.
  int _picked = 0;

  bool _cashIn = false;
  bool _cashOut = false;

  WalletCardData? get _card => _grown == null ? null : kWalletCards[_grown!];

  double get _smallWidth =>
      (Xd.fill(WalletDesign.edge) - WalletDesign.gapSmall.w) / 2;

  double get _wideWidth => Xd.fill(WalletDesign.edge);

  /// إزاحةُ المسار: صفحةٌ كاملة لكلّ بطاقةٍ ممدودة.
  double get _rest =>
      _grown == null ? 0 : -_grown! * (_wideWidth + WalletDesign.gapWide.w);

  void _open(int i) {
    if (_sliding) return;
    setState(() => _grown = _grown == null ? i : null);
  }

  /// أيُّ طبقةٍ مفتوحةٌ فوق الصفحة.
  bool get _overlay => _info || _receipt || _cashIn || _cashOut;

  @override
  Widget build(BuildContext context) {
    final List<WalletEntryData> entries = walletEntriesFor(_card?.currency);
    // قائمةُ الحركات تقصر وتطول مع البطاقة المعروضة.
    if (_picked >= entries.length) _picked = 0;
    final WalletEntryData picked = entries[_picked];
    return PopScope(
      // سهمُ الرجوع يُغلق المفتوحَ فوق الصفحة، ولا يخرج منها إلّا وهي وحدَها.
      // والنوافذُ ذاتُ الخطوات تُغلق نفسَها بنفسها، فلها طبقاتٌ فوقها.
      canPop: !_overlay,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop || _cashIn || _cashOut) return;
        if (_receipt) {
          setState(() => _receipt = false);
        } else if (_info) {
          setState(() => _info = false);
        }
      },
      child: Stack(
        children: <Widget>[
          _page(entries),
          if (_card != null)
            WalletInfoSheetV2(
              open: _info,
              onClose: () => setState(() => _info = false),
              card: _card!,
              // تأتي من الملفّ حتّى تجهز مسارات الخادم.
              clientId: '100-708',
              name: 'Mohamad Katmawi',
              phone: '+90 552 800 2000',
            ),
          if (_card != null)
            WalletCashInSheetV2(
              open: _cashIn,
              onClose: () => setState(() => _cashIn = false),
              card: _card!,
            ),
          if (_card != null)
            WalletCashOutSheetV2(
              open: _cashOut,
              onClose: () => setState(() => _cashOut = false),
              card: _card!,
            ),
          WalletReceiptV2(
            open: _receipt,
            onClose: () => setState(() => _receipt = false),
            // ما تحمله الحركةُ يأتي منها، وما لا تحمله من الملفّ حتّى
            // يُسلَّم مسارُ الخادم.
            amount: picked.amount,
            // الكشفُ يكتب الدولار «$» والإيصالُ يكتبه «USD».
            code: picked.unit == r'$' ? 'USD' : picked.unit,
            type:
                '${picked.arrow == WalletArrow.down ? LocaleKeys.receive.tr() : LocaleKeys.send.tr()}'
                ' | ${picked.title.tr()}',
            status: (picked.status ?? LocaleKeys.succeeded).tr(),
            mark: picked.icon,
            arrow: picked.arrow == WalletArrow.down ? 'arrowDown' : 'arrowUp',
            statusOk:
                picked.status == null ||
                picked.status == LocaleKeys.status_success,
            number: '200192',
            date: '03.march | 14:55',
            reference: 'TSCR10012',
            sender: 'Trydos Jamilya Center Office',
            receiver: '+963988222592',
          ),
        ],
      ),
    );
  }

  Widget _page(List<WalletEntryData> entries) {
    return XdScreenPage(
      header: XdScreenHeader(
        // الملفّ يكتبها فتاتاً وبعده أيقونةُ المحفظة 18.
        crumb: (LocaleKeys.profile.tr(), LocaleKeys.trydos_balance.tr()),
        crumbIcon: 'titleWallet',
        crumbIconW: 18,
        onBack: () {
          // سهمُ الرجوع يُرجع البطاقتين قبل أن يُغلق الشاشة.
          if (_grown != null) {
            setState(() => _grown = null);
            return;
          }
          Navigator.of(context).maybePop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _totalLine(),
          _cardsRow(),
          _dots(),
          Padding(
            padding: EdgeInsetsDirectional.only(start: WalletDesign.totalX.w),
            child: XdText(
              (_card?.list ?? LocaleKeys.all_transactions).tr(),
              size: WalletDesign.listSize,
              weight: XdWeight.medium,
            ),
          ),
          for (int i = 0; i < entries.length; i++)
            _WalletEntryRow(
              entry: entries[i],
              selected: i == _picked,
              onOpen: () => setState(() {
                _picked = i;
                _receipt = true;
              }),
              mt: i == 0
                  ? WalletDesign.entriesY -
                        Xd.textBottom(
                          WalletDesign.listBaseline,
                          WalletDesign.listSize,
                        )
                  : WalletDesign.entryGap,
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  /// سطر «رصيدك الكلّي» والعينُ بعده بـ6.
  ///
  /// ولمسةُ العين تُبدّل الأرصدةَ نجوماً وتُرجعها. والملفُّ يرسم أيقونةً
  /// واحدةً لهذا السطر، فلا تتبدّل صورتُها — والنجومُ هي الجواب.
  Widget _totalLine() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: Xd.gapTo(
          kXdBodyY,
          WalletDesign.totalBaseline,
          WalletDesign.totalSize,
        ).h,
        start: WalletDesign.totalX.w,
        end: WalletDesign.totalX.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: XdText(
              (_card?.total ?? LocaleKeys.your_total_balance).tr(),
              size: WalletDesign.totalSize,
              weight: XdWeight.medium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: WalletDesign.eyeGap.w),
          XdTap(
            scale: 0.92,
            onTap: () => setState(() => _hidden = !_hidden),
            child: const XdSvg(
              'eyeHidden',
              folder: kWalletSvg,
              w: WalletDesign.eye,
            ),
          ),
        ],
      ),
    );
  }

  /// صفُّ البطاقات. وما ينتظر خارج الشاشة يُقصّ.
  ///
  /// والمواضعُ محسوبةٌ بنفسها لا بـ`Row`: فـ`Row` اتّجاهيٌّ والإزاحةُ ماديّةٌ،
  /// فاجتماعُهما كان يُزيح المسارَ كلَّه بعرض بطاقةٍ ويترك فراغاً في طرفه.
  /// وهي تنقلب مع اللغة: في العربيّة تُحسب من الحافّة اليمنى، فتبدأ البطاقةُ
  /// الأولى من اليمين وتنتظر الثانيةُ إلى يسارها.
  Widget _cardsRow() {
    // `easy_localization` يُصدّر `TextDirection` الخاصّ بـ`intl`، فيُظلّل
    // نسخةَ `dart:ui` التي تعنيها `Directionality`.
    final bool rtl = Directionality.of(context) == ui.TextDirection.rtl;
    final double w = _grown == null ? _smallWidth : _wideWidth;
    final double gap =
        (_grown == null ? WalletDesign.gapSmall : WalletDesign.gapWide).w;
    // موضعُ البطاقة من حافّة الاتّجاه، ثمّ يُقلب إلى موضعٍ ماديّ.
    double leftOf(int i) {
      final double from = WalletDesign.edge.w + i * (w + gap) + _rest;
      return rtl ? 1.sw - from - w : from;
    }

    return Padding(
      padding: EdgeInsets.only(
        top:
            (WalletDesign.cardsY -
                    Xd.textBottom(
                      WalletDesign.totalBaseline,
                      WalletDesign.totalSize,
                    ))
                .h,
      ),
      child: SizedBox(
        width: 1.sw,
        height: WalletDesign.cardH.h,
        child: ClipRect(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _grown == null
                ? null
                : (_) => _sliding = true,
            onHorizontalDragEnd: _grown == null
                ? null
                : (DragEndDetails d) {
                    // السحبُ إلى جهة الكتابة يُقدّم الصفحة: فهو إلى اليسار
                    // في الإنجليزيّة وإلى اليمين في العربيّة.
                    final double v = (d.primaryVelocity ?? 0) * (rtl ? -1 : 1);
                    int next = _grown!;
                    if (v < -WalletDesign.slideFast) next += 1;
                    if (v > WalletDesign.slideFast) next -= 1;
                    setState(
                      () => _grown = next.clamp(0, kWalletCards.length - 1),
                    );
                    // اللمسةُ التي تُنهي الانزلاق تأتي بعده مباشرةً.
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _sliding = false,
                    );
                  },
            child: Stack(
              children: <Widget>[
                for (int i = 0; i < kWalletCards.length; i++)
                  AnimatedPositioned(
                    duration: WalletDesign.grow,
                    curve: WalletDesign.growEase,
                    left: leftOf(i),
                    top: 0,
                    width: w,
                    height: WalletDesign.cardH.h,
                    child: _WalletBalanceCard(
                      card: kWalletCards[i],
                      wide: _grown != null,
                      hidden: _hidden,
                      onTap: () => _open(i),
                      onInfo: () => setState(() => _info = true),
                      onCashIn: () => setState(() => _cashIn = true),
                      onCashOut: () => setState(() => _cashOut = true),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// النقطتان، 6 تحت البطاقات. والصفُّ بطول الفراغ إلى العنوان، فلا تتحرّك
  /// القائمة حين تدخلان.
  Widget _dots() {
    return SizedBox(
      width: 1.sw,
      height: Xd.gapTo(
        WalletDesign.dotsAfterCards,
        WalletDesign.listBaseline,
        WalletDesign.listSize,
      ).h,
      child: AnimatedOpacity(
        opacity: _grown == null ? 0 : 1,
        duration: WalletDesign.grow,
        curve: WalletDesign.growEase,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: (WalletDesign.dotsY - WalletDesign.dotsAfterCards).h,
            ),
            // النقطتان تتبعان المسار، وهو ينقلب مع اللغة — فتنقلبان معه.
            Builder(
              builder: (BuildContext context) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < kWalletCards.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: WalletDesign.dotGap.w),
                    XdSvg(
                      i == _grown ? 'dotOn' : 'dotOff',
                      folder: kWalletSvg,
                      w: i == _grown
                          ? WalletDesign.dotOnW
                          : WalletDesign.dotOffW,
                      h: WalletDesign.dotH,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقةُ رصيد، 103 طولاً على y 138، `#4A31E7` بزاوية 15 وحشوة 12.
///
/// > يساراً من الأعلى: العلامة 20 على y 150، واسمُ العملة (11 Light) على خطّ
/// > الأساس 187، والمبلغ (25 Medium بظلّه) على 223، والرمز (9 Light) على 227
/// > بعد بداية المبلغ بـ60.
/// >
/// > وللبطاقة الممدودة في `– 17` عمودٌ ثانٍ من x 302 إلى 406: علامةُ QR في
/// > طرفه، وتحتها الإيداعُ والسحب — صورةٌ 20 على y 189 فوق نصٍّ 11 على خطّ
/// > الأساس 226. والنصّان يبدآن على x 302 و359.
class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.card,
    required this.wide,
    required this.hidden,
    required this.onTap,
    required this.onInfo,
    required this.onCashIn,
    required this.onCashOut,
  });

  final WalletCardData card;
  final bool wide;

  /// المبلغُ نجومٌ بعددِ أرقامه، فلا يتبدّل قياسُ البطاقة.
  final bool hidden;

  final VoidCallback onTap;

  /// علامةُ QR تفتح «معلومات المحفظة» — `– 23`.
  final VoidCallback onInfo;

  /// خانةُ «الإيداع» تفتح نافذةَ الإيداع — `– 22`.
  final VoidCallback onCashIn;

  /// وخانةُ «السحب» تفتح نافذةَ السحب — `– 21`.
  final VoidCallback onCashOut;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: WalletDesign.grow,
        curve: WalletDesign.growEase,
        decoration: BoxDecoration(
          color: WalletDesign.card,
          borderRadius: BorderRadius.circular(WalletDesign.cardRadius.r),
        ),
        clipBehavior: Clip.antiAlias,
        // 12 من الجانبين و12 من الأعلى — ولا حشوةَ أسفل: الملفُّ يُنهي
        // المحتوى على y 229 والبطاقةَ على 241، فالـ12 الأخيرة **فراغٌ** لا
        // حشوة. وحجزُها كان يُلغي كلَّ فراغٍ في العمود، فيَفيض بفرق قياسِ
        // الأبعاد: الحشوةُ والعلامةُ بـ`.w` والبطاقةُ بـ`.h`.
        padding: EdgeInsetsDirectional.only(
          start: WalletDesign.cardPad.w,
          end: WalletDesign.cardPad.w,
          top: WalletDesign.cardPad.h,
        ),
        // داخلُ البطاقة يتبع اتّجاه اللغة: العلامةُ والمبلغُ في أوّلها،
        // وQR والخانتان في آخرها — فينقلب الطرفان في العربيّة.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _left()),
            if (wide) _right(context),
          ],
        ),
      ),
    );
  }

  Widget _left() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        XdSvg(card.icon, folder: kWalletSvg, w: WalletDesign.mark),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(
              WalletDesign.markY + WalletDesign.mark,
              WalletDesign.nameBaseline,
              WalletDesign.nameSize,
            ).h,
          ),
          child: XdText(
            card.name.tr(),
            size: WalletDesign.nameSize,
            weight: XdWeight.light,
            color: XdColors.white,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(
              Xd.textBottom(WalletDesign.nameBaseline, WalletDesign.nameSize),
              WalletDesign.amountBaseline,
              WalletDesign.amountSize,
            ).h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Text(
                  hidden ? '*' * card.amount.length : card.amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      xdTextStyle(
                        size: WalletDesign.amountSize,
                        weight: XdWeight.medium,
                        color: XdColors.white,
                      ).copyWith(
                        shadows: <Shadow>[
                          Shadow(
                            color: const Color(0x29000000),
                            offset: Offset(0, 3.h),
                            blurRadius: 3.r,
                          ),
                        ],
                      ),
                ),
              ),
              // الرمز على خطّ الأساس 227، أي 4 تحت أساس المبلغ.
              Padding(
                padding: EdgeInsets.only(
                  top:
                      (WalletDesign.codeBaseline -
                              WalletDesign.codeSize -
                              (WalletDesign.amountBaseline -
                                  WalletDesign.amountSize))
                          .h,
                ),
                child: XdText(
                  card.code,
                  size: WalletDesign.codeSize,
                  weight: XdWeight.light,
                  color: XdColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// العمود الثاني، مثبّتٌ إلى حافّة البطاقة اليمنى فيحفظ 104 ويتبع الفراغُ
  /// قبله عرضَ الشاشة.
  Widget _right(BuildContext context) {
    return SizedBox(
      width: WalletDesign.wideColumnW.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          XdTap(
            scale: 0.92,
            onTap: onInfo,
            child: const XdSvg(
              'qrWhite',
              folder: kWalletSvg,
              w: WalletDesign.mark,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top:
                  (WalletDesign.tileIconY -
                          (WalletDesign.markY + WalletDesign.mark))
                      .h,
            ),
            // خانةُ الإيداع تمتدّ من بداية نصّه إلى بداية نصّ السحب (57)،
            // والسحبُ بعدها مباشرةً. و`Spacer` كان يدفع السحبَ إلى طرف
            // العمود، فيتّسع ما بينهما بقدر ما تقصر الكلمة.
            //
            // والملفُّ يُرسي الخانتين على **بداية** كلمتيهما (302 و359)،
            // و«Cash Out» تكاد تملأ العمودَ إلى 406. وكلماتُنا العربيّةُ
            // أقصرُ، فينقلب الفراغُ الباقي إلى حافّة البطاقة ويُرى. فتُلاصق
            // الخانتان حافّةَ العمود في العربيّة — كعلامة QR فوقهما — ويحفظ
            // الإنجليزيُّ مرساتَيِ الملفّ.
            child: Row(
              mainAxisAlignment:
                  Directionality.of(context) == ui.TextDirection.rtl
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: WalletDesign.tileSlot.w,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: XdTap(
                      scale: 0.96,
                      onTap: onCashIn,
                      child: _tile('cashIn', LocaleKeys.cash_in.tr()),
                    ),
                  ),
                ),
                XdTap(
                  scale: 0.96,
                  onTap: onCashOut,
                  child: _tile('cashOut', LocaleKeys.cash_out.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// الإيداع أو السحب. الصورةُ موسَّطةٌ فوق نصّها ثمّ تزيح نصفَ بكسلٍ يميناً،
  /// كما في الملفّ.
  Widget _tile(String icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // موسَّطةٌ فوق كلمتها ثمّ نصفَ بكسلٍ بعدها — `ml: 1` في الملفّ. ورسمُها
        // ينقلب في العربيّة كما ينقلب موضعُها: سهمٌ له جهة.
        Padding(
          padding: EdgeInsetsDirectional.only(start: 1.w),
          child: XdSvg(
            icon,
            folder: kWalletSvg,
            w: WalletDesign.mark,
            flipRtl: true,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(
              WalletDesign.tileIconY + WalletDesign.mark,
              WalletDesign.tileLabelBaseline,
              WalletDesign.nameSize,
            ).h,
          ),
          child: XdText(
            label,
            size: WalletDesign.nameSize,
            color: XdColors.card,
          ),
        ),
      ],
    );
  }
}

/// حركةٌ واحدة، 50 طولاً و12 عن حافّتي الشاشة، `#FCFCFC` بزاوية 15.
///
/// > وأعلى الصفّ صفرٌ: الصورة 16 على (12، 8) والسهم 14 على (13، 28)؛
/// > والعنوان (13 Medium) على خطّ الأساس 21 والملاحظة (11، وتاريخُها Light)
/// > على 39، كلاهما من x 36؛ والمبلغ (13: العددُ Medium والوحدةُ Light) على
/// > خطّ الأساس 21 ينتهي 12 عن الحافّة اليمنى، والحالةُ (11 Light) على 39.
class _WalletEntryRow extends StatelessWidget {
  const _WalletEntryRow({
    required this.entry,
    required this.mt,
    required this.selected,
    this.onOpen,
  });

  final WalletEntryData entry;
  final double mt;

  /// حولها الخطُّ 0.5 ومبلغُها عريض — منظرُ أحدثِ حركةٍ في الملفّ، ويتبع
  /// هنا ما يُلمَس.
  final bool selected;

  /// يفتح إيصال الحركة — `– 18`.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final Color ink = entry.muted ? XdColors.grey : XdColors.ink;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: mt.h,
        start: WalletDesign.edge.w,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        child: Container(
          width: Xd.fill(WalletDesign.edge),
          height: WalletDesign.entryH.h,
          decoration: BoxDecoration(
            color: XdColors.card,
            borderRadius: BorderRadius.circular(WalletDesign.cardRadius.r),
          ),
          // الخطّ فوق الصفّ لا في إطاره، فلا يقتطع من محتواه.
          foregroundDecoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    WalletDesign.cardRadius.r,
                  ),
                  border: Border.all(color: XdColors.line, width: 0.5),
                )
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: XdSvg(entry.icon, folder: kWalletSvg, w: 16),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: (28 - (8 + 16)).h,
                      start: 1.w,
                    ),
                    child: XdSvg(
                      entry.arrow == WalletArrow.down ? 'arrowDown' : 'arrowUp',
                      folder: kWalletSvg,
                      w: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(width: (48 - 40).w),
              Expanded(child: _texts(ink)),
              _amount(ink),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: Xd.gapTo(0, 21, 13).h),
          child: XdText(
            entry.title.tr(),
            size: 13,
            weight: XdWeight.medium,
            color: ink,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(Xd.textBottom(21, 13), 39, 11).h,
          ),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: entry.date,
                  style: xdTextStyle(
                    size: 11,
                    weight: XdWeight.light,
                    color: ink,
                  ),
                ),
                TextSpan(
                  text: ' | ${entry.note}',
                  style: xdTextStyle(size: 11, color: ink),
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

  Widget _amount(Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: Xd.gapTo(0, 21, 13).h),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: entry.amount,
                  style: xdTextStyle(
                    size: 13,
                    weight: selected ? XdWeight.bold : XdWeight.medium,
                    color: ink,
                  ),
                ),
                TextSpan(
                  text: ' ${entry.unit}',
                  style: xdTextStyle(
                    size: 13,
                    weight: XdWeight.light,
                    color: ink,
                  ),
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
        if (entry.status != null)
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(Xd.textBottom(21, 13), 39, 11).h,
            ),
            // الملفّ يبدأ الحالة على x ثابتٍ ويتركها تمتدّ إلى 406.
            child: SizedBox(width: (406 - entry.statusX).w, child: _status()),
          ),
      ],
    );
  }

  Widget _status() {
    final TextStyle light = xdTextStyle(size: 11, weight: XdWeight.light);
    if (entry.dueTime == null) {
      return Text(
        entry.status!.tr(),
        style: light,
        // الملفّ يُحاذيها إلى يسار خانتها، وتبقى كذلك في العربيّة: فتُلاصق
        // حافّةَ الصفّ بدل أن ينقلب الفراغُ إليها.
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '${entry.status!.tr()} ${entry.dueTime} | ',
            style: light,
          ),
          TextSpan(text: entry.dueDay, style: xdTextStyle(size: 11)),
          TextSpan(text: ' ${entry.dueMonth}', style: light),
        ],
      ),
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
