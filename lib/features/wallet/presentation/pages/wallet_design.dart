/// أرقام شاشات المحفظة وبياناتُها، منقولةً حرفياً عن
/// `web_design/components/DemoApp1/screens/WalletScreen.tsx` و
/// `components/DemoApp/demoWallet.ts`.
///
/// > رصيد Trydos — لوح XD `Home Page – 11` (كلُّ الأرصدة) و`– 17` (رصيدٌ
/// > واحد، ومعه الإيداع والسحب).
/// >
/// > اللوحان من أعلى إلى أسفل (y من الملفّ):
/// >   - سطر «رصيدك الكلّي» على خطّ الأساس 123، والعينُ 14 بعده؛
/// >   - البطاقات البنفسجيّة على y 138، 103 طولاً: اثنتان 200 بينهما 6 في
/// >     `– 11`، وواحدةٌ 406 في `– 17`؛
/// >   - في `– 17` نقطتا الصفحة على y 247؛
/// >   - «كلّ الحركات» على خطّ الأساس 272؛
/// >   - الحركات، 406 × 50 من y 287، بينها 4.
/// >
/// > شاشةٌ واحدة بحالين. لمسُ بطاقةٍ يمدّها إلى العرض الكامل في موضعها:
/// > فيُسمّي السطرُ فوقها عملتَها، وتدخل النقطتان والإيداعُ والسحبُ وحركاتُ
/// > تلك العملة. ولمسُ الممدودة، أو سهمُ الرجوع، يُرجع البطاقتين.
library;

import 'package:flutter/material.dart';

import 'package:trydos/generated/locale_keys.g.dart';

/// أرقام شاشة الرصيد.
abstract class WalletDesign {
  /// «رصيدك الكلّي» على خطّ الأساس 123، على x 24، والعينُ 14 بعده.
  static const double totalBaseline = 123;
  static const double totalSize = 11;
  static const double totalX = 24;
  static const double eye = 14;

  /// والعينُ تتبع الكلمةَ بفراغ 6.
  ///
  /// الملفُّ يحجز للسطر خانةً تنتهي عندها العينُ: على x 125 مطويّاً و152
  /// ممدوداً — وهما عرضُ الجملة الإنجليزيّة وفراغُها، فتثبت العينُ ولا ترقص
  /// مع تبدّل الكلمة. وترجماتُنا أقصرُ من الإنجليزيّة بكثير، فتُبقي الخانةُ
  /// فراغاً واسعاً بين الكلمة والعين. فالعينُ تتبع الكلمةَ بالفراغ نفسِه —
  /// وهو على الإنجليزيّة عينُ موضع الملفّ.
  static const double eyeGap = 6;

  // خانةُ السطر، معطَّلةٌ لما فوق:
  // static const double totalMinSmall = 125;
  // static const double totalMinWide = 152;

  /// البطاقات على y 138، 103 طولاً، بزاوية 15 ولون `#4A31E7`، وحشوتها 12.
  static const double cardsY = 138;
  static const double cardH = 103;
  static const double cardRadius = 15;
  static const double cardPad = 12;

  /// البطاقتان الصغيرتان بينهما 6؛ والممدودتان بينهما 24، وخطوةُ الانزلاق
  /// عرضُ الشاشة. وكلتاهما 12 عن الحافّتين.
  static const double gapSmall = 6;
  static const double gapWide = 24;
  static const double edge = 12;

  /// داخل البطاقة من الأعلى: العلامة 20 على y 150، واسمُ العملة (11 Light)
  /// على خطّ الأساس 187، والمبلغ (25 Medium بظلّه) على 223، والرمز (9 Light)
  /// على 227 بعد بداية المبلغ بـ60.
  static const double markY = 150;
  static const double mark = 20;
  static const double nameBaseline = 187;
  static const double nameSize = 11;
  static const double amountBaseline = 223;
  static const double amountSize = 25;
  static const double codeBaseline = 227;
  static const double codeSize = 9;
  static const double codeX = 60;

  /// عمودُ البطاقة الممدودة من x 302 إلى 406: علامةُ QR في طرفه، وتحتها
  /// الإيداعُ والسحب — صورةٌ 20 على y 189 فوق نصٍّ 11 على خطّ الأساس 226.
  /// والنصّان يبدآن على x 302 و359، فخانةُ الإيداع 57 — من بداية نصٍّ إلى
  /// بداية التالي، والسحبُ بعدها مباشرةً بلا فراغٍ زائد.
  static const double tileSlot = 359 - 302;
  static const double wideColumnX = 302;
  static const double wideColumnW = 406 - 302;
  static const double tileIconY = 189;
  static const double tileLabelBaseline = 226;
  static const double cashOutX = 359;

  /// النقطتان على (200، 247) و(222، 247): 30 عرضاً معاً، موسَّطتان، 6 تحت
  /// البطاقات. والصفُّ بطول الفراغ إلى العنوان.
  static const double dotsY = 247;
  static const double dotsAfterCards = 241;
  static const double dotOnW = 16;
  static const double dotOffW = 8;
  static const double dotH = 8;
  static const double dotGap = 6;

  /// «كلّ الحركات» على خطّ الأساس 272، ثمّ الحركات من y 287 بينها 4.
  static const double listBaseline = 272;
  static const double listSize = 11;
  static const double entriesY = 287;
  static const double entryH = 50;
  static const double entryGap = 4;

  /// حركةُ الحالين — `GROW`.
  static const Duration grow = Duration(milliseconds: 350);
  static const Cubic growEase = Cubic(0.4, 0, 0.2, 1);

  /// انزلاقُ البطاقات الممدودة: مسافةٌ أو سرعةٌ تكفي لقلب الصفحة.
  static const double slideFar = 60;
  static const double slideFast = 400;

  /// بنفسجيُّ البطاقة.
  static const Color card = Color(0xFF4A31E7);
}

/// رصيدُ عملةٍ كما يرسمه الملفّ — `WalletBalance`.
class WalletCardData {
  const WalletCardData({
    required this.currency,
    required this.icon,
    required this.mark,
    required this.name,
    required this.total,
    required this.list,
    required this.amount,
    required this.code,
  });

  /// `usd` أو `syp`.
  final String currency;

  /// علامةُ البطاقة البيضاء، وعلامتُها الداكنة بجانب عنوان النافذة.
  final String icon;
  final String mark;

  /// اسمُ العملة، والسطرُ فوق البطاقات، وعنوانُ الكشف — مفاتيح ترجمة.
  final String name;
  final String total;
  final String list;

  final String amount;
  final String code;
}

/// العملتان — `WALLET_BALANCES`.
const List<WalletCardData> kWalletCards = <WalletCardData>[
  WalletCardData(
    currency: 'usd',
    icon: 'dollarWhite',
    mark: 'dollarDark',
    name: LocaleKeys.amerikan_dollars,
    total: LocaleKeys.your_total_usd_balance,
    list: LocaleKeys.all_usd_transactions,
    amount: '1000',
    code: 'USD',
  ),
  WalletCardData(
    currency: 'syp',
    icon: 'flagSy',
    mark: 'flagSy',
    name: LocaleKeys.syrian_pounds,
    total: LocaleKeys.your_total_syp_balance,
    list: LocaleKeys.all_syp_transactions,
    amount: '1000',
    code: 'SYP',
  ),
];

/// اتّجاه الحركة: داخلٌ (سهمٌ نازلٌ داكن) أو خارجٌ (صاعدٌ برتقاليّ).
enum WalletArrow { down, up }

/// حركةٌ في الكشف كما يرسمها الملفّ — `WalletEntry`.
class WalletEntryData {
  const WalletEntryData({
    required this.id,
    required this.icon,
    required this.arrow,
    required this.title,
    required this.date,
    required this.note,
    required this.amount,
    required this.unit,
    required this.statusX,
    this.latest = false,
    this.receipt = false,
    this.muted = false,
    this.status,
    this.dueTime,
    this.dueDay,
    this.dueMonth,
  });

  final String id;
  final String icon;
  final WalletArrow arrow;

  /// مفتاحُ ترجمة.
  final String title;

  /// بياناتٌ تُكتب كما يُظهرها الملفّ.
  final String date;
  final String note;
  final String amount;
  final String unit;

  /// صفُّ الملفّ الأوّل: حوله خطٌّ 0.5 ومبلغُه Bold.
  final bool latest;

  /// له إيصال (`Home Page – 18`)، فلمسُه يفتحه.
  final bool receipt;

  /// رماديُّ العنوان والملاحظة والمبلغ — محجوبةٌ أو منتظِرة.
  final bool muted;

  /// مفتاحُ ترجمة.
  final String? status;

  /// حركةٌ منتظِرة: وقتُها ويومُها وشهرُها.
  final String? dueTime;
  final String? dueDay;
  final String? dueMonth;

  /// x الذي تبدأ عنده الحالة. وتنتهي على 406.
  final double statusX;
}

/// الحركات — `WALLET_ENTRIES`.
const List<WalletEntryData> kWalletEntries = <WalletEntryData>[
  WalletEntryData(
    id: 'deposit',
    icon: 'txDeposit',
    arrow: WalletArrow.down,
    title: LocaleKeys.cash_deposit,
    date: '03.march',
    note: 'Jamilya Center Office 20019rf',
    amount: '1000',
    unit: r'$',
    latest: true,
    receipt: true,
    status: LocaleKeys.status_success,
    statusX: 366,
  ),
  WalletEntryData(
    id: 'withdrawal',
    icon: 'txWithdrawal',
    arrow: WalletArrow.up,
    title: LocaleKeys.cash_withdrawal,
    date: '03.march',
    note: 'Jamilya Center Office 20019rf',
    amount: '10',
    unit: r'$',
    status: LocaleKeys.status_success,
    statusX: 366,
  ),
  WalletEntryData(
    id: 'order',
    icon: 'txOrder',
    arrow: WalletArrow.up,
    title: LocaleKeys.order_invoice_payment,
    date: '03.march',
    note: 'TR200 Order',
    amount: '-1010',
    unit: 'SYP',
    muted: true,
    status: LocaleKeys.status_blocked,
    statusX: 366,
  ),
  WalletEntryData(
    id: 'refund',
    icon: 'txRefund',
    arrow: WalletArrow.down,
    title: LocaleKeys.refund_order,
    date: '03.march',
    note: 'TR200 Order Refund',
    amount: '410',
    unit: r'$',
    statusX: 366,
  ),
  WalletEntryData(
    id: 'request',
    icon: 'txRequest',
    arrow: WalletArrow.down,
    title: LocaleKeys.cash_in_request,
    date: '03.march',
    note: 'Via Crypto TRC 20',
    amount: '100',
    unit: r'$',
    muted: true,
    status: LocaleKeys.waiting_due_in,
    dueTime: '13:59',
    dueDay: '3',
    dueMonth: 'March 2026',
    statusX: 231,
  ),
];

/// حركاتُ عملةٍ — `entriesFor`.
///
/// > `– 11` يسرد الأربع الأُوَل، و`– 17` (الدولار) الخمسَ كلَّها. ولا لوحَ
/// > في الملفّ لرصيد الليرة؛ فيُسرد ما كان بالليرة.
List<WalletEntryData> walletEntriesFor(String? currency) {
  if (currency == null) return kWalletEntries.sublist(0, 4);
  if (currency == 'usd') return kWalletEntries;
  return kWalletEntries.where((WalletEntryData e) => e.unit == 'SYP').toList();
}
