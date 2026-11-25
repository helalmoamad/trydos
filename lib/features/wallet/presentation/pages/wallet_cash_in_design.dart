/// أرقامُ نافذة الإيداع وبياناتُها، منقولةً حرفياً عن
/// `web_design/components/DemoApp1/screens/WalletCashInSheet.tsx` و
/// `components/DemoApp/demoWallet.ts`.
///
/// > الإيداع — ألواحُ XD: `– 22` (طرق الإيداع)، و`– 26` و`– 32` (نافذة
/// > trydos | rdb: رمزُ إيداعٍ، أو مالٌ من حساب العميل في rdb)، و`– 31` (صورةُ
/// > رمز الإيداع)، و`– 33` و`– 34` (الإيداع بالعملات الرقميّة)، و`– 39`
/// > (قواعدُ الأمان، نافذةٌ ثانية)، و`– 37` (رمزُ العملة الرقميّة) و`– 38`
/// > (صورتُه).
/// >
/// > نافذةٌ واحدة، أربعُ خطوات. الملفُّ يرسم الخطوة الأولى من y 216 والبواقي
/// > من y 90، وزواياها العلويّة 50 كلُّها. والنافذةُ موضوعةٌ على 90 وتستقرّ
/// > 126 أخفضَ ما دامت الخطوةُ الأولى معروضةً.
/// >
/// > وكلُّ y هنا y الملفّ. والمقبضُ ينتهي 13 تحت حافّة النافذة العليا، فأوّلُ
/// > كتلةٍ في خطوةٍ هامشُها الأعلى = y الكتلة ناقصَ (أعلى النافذة + 13).
library;

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'wallet_sheet_parts.dart';

/// خطواتُ النافذة الأربع — `type Step`.
enum CashInStep { ways, rdb, crypto, code }

/// أرقامُ نافذة الإيداع.
abstract class CashInDesign {
  /// أعلى كلّ خطوةٍ على اللوح — `TOP`.
  static const Map<CashInStep, double> top = <CashInStep, double>{
    CashInStep.ways: 216,
    CashInStep.rdb: 90,
    CashInStep.crypto: 90,
    CashInStep.code: 90,
  };

  /// النافذةُ موضوعةٌ على أعلى خطواتها، وتهبط ما بين الخطوة المعروضة وهذا.
  static const double layoutTop = 90;

  /// الألواحُ تنتهي على y 930 — `BOARD_END`.
  static const double boardEnd = 930;

  /// قواعدُ الأمان على نافذةٍ ثانية من y 265 (`– 39`، و`– 102` في الدفع).
  static const double rulesTop = 265;

  /// حيث ينتهي رأسُ الخطوة (صفُّ العنوان والسطرُ تحته) — `HEAD_END`.
  static double get headEnd => Xd.textBottom(180, 24);

  /// ما تحت آخر كتلةٍ في لوحٍ: اللوحُ ينتهي على 930 والكتلُ على 895.
  static const double boardTail = boardEnd - 895;

  /// خطوةُ `ways`: الفقرةُ من خطّ الأساس 296 بارتفاع سطرٍ 18 (سطران)، ثمّ
  /// بطاقةُ trydos | rdb على y 338 (188 طولاً)، فطرقُ الدفع على y 534،
  /// فالبطاقةُ الرماديّة على y 691.
  static const double waysParaBaseline = 296;
  static const double waysParaLine = 18;
  static const double brandCardY = 338;
  static const double brandCardH = 188;
  static const double payWaysY = 534;
  static const double greyCardY = 691;
  static const double greyCardH = 204;

  /// داخل البطاقة الرماديّة: «أضف أموالك !» على خطّ الأساس 714، ثمّ فقرةٌ من
  /// 736 بارتفاع 18 (أربعةُ أسطر)، فزرّان 38 طولاً على 801 و845.
  static const double greyTitleBaseline = 714;
  static const double greyParaBaseline = 736;
  static const double greyParaLine = 18;
  static const double greyButtonY = 801;
  static const double greyButtonY2 = 845;
  static const double greyButtonH = 38;

  /// التبويبان على y 213، 28 طولاً.
  static const double tabsY = 213;
  static const double tabH = 28;

  /// الحقولُ 55 طولاً على y 245 و304 و363، والمبلغُ على 422.
  static const double fieldH = 55;
  static const double field1Y = 245;
  static const double field2Y = 304;
  static const double field3Y = 363;
  static const double amountY = 422;

  /// حقلُ المبلغ مع وسمِ الحسم: 93 طولاً، والوسمُ 30 على 55 من أعلى الحقل.
  static const double amountTallH = 93;
  static const double chargeY = 55;
  static const double chargeH = 30;
  static const double chargeX = 44 - 32;

  /// بطاقةُ الخلاصة 58 طولاً على y 519 (`– 34`).
  static const double summaryY = 519;
  static const double summaryH = 58;

  /// الزرُّ العريض على y 835، 60 طولاً.
  static const double wideButtonY = 835;
  static const double wideButtonH = 60;

  /// `– 26`: الرمزُ 300.12 على (65، 260.41)، والنقطتان على y 573، والسطرُ
  /// على خطّ الأساس 605، فحقولُ العميل على 639 و698 و757، فالإجراءات على 855.
  static const double qrSmall = 300.12;
  static const double qrSmallX = 65;
  static const double qrSmallY = 260.41;
  static const double dotsY = 573;
  static const double depositLineBaseline = 605;
  static const double clientFieldsY = 639;
  static const double actionsY = 855;
  static const double actionLabelBaseline = 892;

  /// صورةُ الرمز (`– 31`، `– 38`): صفُّ العنوان على y 66، والرمزُ 350.37.
  static const double pictureHeadY = 66;
  static const double pictureTitleBaseline = 132;
  static const double qrBig = 350.37;
  static const double qrBigX = 39.99;

  /// `– 31`: الرمزُ على y 167.42، والسطرُ على 546، والحقولُ من 620.
  static const double depositPictureQrY = 167.42;
  static const double depositPictureLineBaseline = 546;
  static const double depositPictureFieldsY = 620;

  /// الملاحظةُ أسفل الصورة: 90 طولاً على (20، 805)، عنوانُها على خطّ الأساس
  /// 828، وفقرتُها من 848 بارتفاع 16 (ثلاثةُ أسطر).
  static const double noteY = 805;
  static const double noteH = 90;
  static const double noteTitleBaseline = 828;
  static const double noteParaBaseline = 848;
  static const double noteParaLine = 16;

  /// `– 37`: وسمُ الشبكة 193 × 28 على (119، 213)، ثمّ الرمزُ، فصفُّ الإيداع
  /// على خطّ الأساس 589 وعلامتُه على (136، 573)، فسطرُ المسح على 651، فالوقتُ
  /// الباقي على 678، فـ«أو جرّب» على 713، فالمحافظُ على y 728.
  static const double networkTagW = 193;
  static const double networkTagX = 119;
  static const double depositRowY = 573;
  static const double depositRowX = 136;
  static const double depositRowTextX = 164;
  static const double scanRowY = 639;
  static const double scanRowX = 34.56;
  static const double scanRowTextX = 51;
  static const double timerY = 666;
  static const double timerX = 137.64;
  static const double timerTextX = 158;
  static const double directLinkBaseline = 713;
  static const double appsY = 728;
  static const double app = 30;
  static const double appGap = 30;

  /// الأسطرُ البرتقاليّة: خطُّ أساسِ أوّلها، والانتهاءُ 43 بعده.
  static const double expiryFirst = 789;
  static const double expiryGap = 43;
  static const double expiryClockX = 128.59;
  static const double expiryTextX = 147;

  /// `– 38`: الوسمُ على y 165، والرمزُ على 212.42، وصفُّ الإيداع على 575،
  /// وسطرُ المسح على 636، والأسطرُ البرتقاليّة من 747.
  static const double cryptoPictureTagY = 165;
  static const double cryptoPictureQrY = 212.42;
  static const double cryptoPictureRowY = 575;
  static const double cryptoPictureScanY = 636;
  static const double cryptoPictureExpiry = 747;

  /// قواعدُ الأمان (`– 39`): الدرعُ 34 × 40 على (197.98، 288.91)، والعنوانُ
  /// على خطّ الأساس 354، والقواعدُ من 389 بارتفاع سطرٍ 18 وبينها 4، ثمّ
  /// «أوافق» 60 طولاً على (30، 803) و«لا أوافق» على خطّ الأساس 891.
  static const double shieldY = 288.91;
  static const double shieldW = 34.14;
  static const double shieldH = 40.09;
  static const double shieldX = 197.98;
  static const double safeTitleBaseline = 354;
  static const double rulesFirstBaseline = 389;
  static const double ruleLine = 18;
  static const double ruleSize = 12;
  static const double ruleGap = 4;
  static const double agreeY = 803;
  static const double agreeX = 30;
  static const double agreeH = 60;
  static const double disagreeBaseline = 891;

  /// «أوافق» في نافذة سياسات الدفع (`– 102`): 188 × 45 موسَّطاً على y 811.
  static const double policiesAgreeY = 811;
  static const double policiesAgreeW = 188;
  static const double policiesAgreeH = 45;
  static const double policiesDisagreeBaseline = 892;
}

/// علامةُ النافذة كما يكتبها الملفّ — `WALLET_BRAND`.
///
/// الملفُّ يكتب «rdb» بحروفٍ صغيرة، ويرسم [start] و[bank] بخطٍّ عريض.
abstract class WalletBrandData {
  static const String start = 'try';
  static const String rest = 'dos | ';
  static const String bank = 'rdb';
}

/// حسابُ العميل في Trydos كما تُظهره نافذةُ الإيداع — `WALLET_CASH_IN`.
abstract class WalletCashInData {
  static const String clientId = '100-708';
  static const String phone = '+90 552 800 2000';
}

/// المستلِمُ كما يملؤه الملفّ — `WALLET_RECIPIENT`.
abstract class WalletRecipientData {
  static const String phone = '90 552 800 2000';
  static const String name = 'Mohamad Katmawi';
}

/// حسابُ العميل في المصرف — `WALLET_BANK_ACCOUNT`.
abstract class WalletBankAccountData {
  static const String id = '100-708';

  /// والملفُّ يهجئ الدولار «American» هنا.
  static String currency(String code) =>
      code == 'usd' ? LocaleKeys.amerikan_dollars : LocaleKeys.syrian_pounds;
}

/// الإيداعُ بالعملات الرقميّة — `WALLET_CRYPTO`.
abstract class WalletCryptoData {
  static const String coin = 'USDT';
  static const String chain = 'Tron';
  static const String standard = 'TRC 20';

  /// التبويبُ الآخر. ولا يرسم الملفُّ له لوحاً.
  static const String other = 'ETH';

  /// الملفُّ يحسم 110 USDT لتعزيز الرصيد بـ100 USD.
  static const double fee = 0.1;

  /// الرمزُ صالحٌ ثلاثين دقيقة؛ والملفُّ يُظهر «29:59».
  static const int seconds = 30 * 60 - 1;

  static const String expiryDate = '27/08/2024';
  static const String expiryTime = '13:30';

  /// الشبكةُ اسماً واحداً: «USDT Tron TRC 20» — `NETWORK`.
  static const String network = '$coin $chain $standard';
}

/// محفظةٌ رقميّة في `– 37` — `WALLET_CRYPTO_APPS`.
class WalletAppData {
  const WalletAppData({
    required this.id,
    required this.name,
    this.picture,
    this.icon,
  });

  final String id;
  final String name;

  /// صورةٌ في `assets/images/wallet_v2/`، أو أيقونةٌ مقصوصة.
  final String? picture;
  final String? icon;
}

/// المحافظُ الثلاث، 30 حجماً وبينها 30 من x 140.
const List<WalletAppData> kWalletCryptoApps = <WalletAppData>[
  WalletAppData(id: 'trust', picture: 'walletTrust.jpg', name: 'Trust Wallet'),
  WalletAppData(
    id: 'metamask',
    picture: 'walletMetaMask.png',
    name: 'MetaMask',
  ),
  WalletAppData(id: 'binance', icon: 'binance', name: 'Binance'),
];

/// طريقةُ إيداعٍ في صفّ الخانات — `WALLET_CASH_IN_WAYS`.
class WalletWayData {
  const WalletWayData({
    required this.id,
    required this.name,
    this.icon,
    this.picture,
    this.soon = false,
    this.translate = false,
  });

  final String id;

  /// الكلماتُ لقارئ الشاشة. وأسماءُ العلامات تبقى كما هي.
  final String name;

  /// هل [name] مفتاحُ ترجمةٍ أم اسمُ علامةٍ يُكتب كما هو؟
  final bool translate;

  /// أيقونةٌ مقصوصة على صندوقٍ أبيض، أو صورة.
  final String? icon;
  final String? picture;

  final bool soon;
}

/// الطرقُ الخمس في `– 22`، من اليسار إلى اليمين وبينها 8. والصفُّ أعرضُ من
/// الشاشة فينزلق. وخانةُ البطاقات لم تُفتح بعد («متاح قريباً»).
const List<WalletWayData> kWalletCashInWays = <WalletWayData>[
  WalletWayData(
    id: 'cards',
    icon: 'payCards',
    name: 'Visa | Mastercard',
    soon: true,
  ),
  WalletWayData(
    id: 'crypto',
    icon: 'payCrypto',
    name: LocaleKeys.via_crypto,
    translate: true,
  ),
  // أسماءُ علاماتٍ تجاريّة: واحدةٌ في كلّ لغة.
  WalletWayData(id: 'sham', picture: 'payShamCash.jpg', name: 'Sham Cash'),
  WalletWayData(
    id: 'syriatel',
    picture: 'paySyriatelCash.jpg',
    name: 'Syriatel Cash',
  ),
  WalletWayData(id: 'irsal', picture: 'payIrsal.jpg', name: 'Irsal'),
];

/// خانةٌ من صفّ الطرق: 125 حجماً، ووسمُ «متاح قريباً» 76 × 19 يتدلّى 9 تحت
/// حافّتها السفلى — `PayWays.tsx`.
abstract class PayWaysDesign {
  static const double tile = 125;
  static const double gap = 8;
  static const double edge = 20;
  static const double inner = 101;
  static const double pad = 12;
  static const double radius = 15;

  /// أعلى الوسم من أعلى الخانة (534 → 650 في `– 22`)، وخطُّ أساس كلمته فيه.
  static const double tagY = 650 - 534;
  static const double tagBaseline = 663 - 650;
  static const double tagW = 76;
  static const double tagH = 19;
  static const double tagX = 45 - 20;
  static const double tagRadius = 6.8;

  /// من أعلى الخانات إلى أسفل الوسم (534 → 669 في `– 22`) — `TILE_ROW_H`.
  static const double rowHeight = tagY + tagH;
}

/// ملاحظةُ قاعدةٍ في قائمة الأمان.
class SafeNoteData {
  const SafeNoteData({required this.text, required this.ok});

  /// مفتاحُ ترجمة.
  final String text;

  /// نقطةٌ خضراء أو برتقاليّة.
  final bool ok;
}

/// قاعدةٌ في قائمة الأمان وملاحظاتُها.
class SafeRuleData {
  const SafeRuleData({
    required this.rule,
    required this.ok,
    required this.notes,
  });

  /// مفتاحُ ترجمة.
  final String rule;
  final bool ok;
  final List<SafeNoteData> notes;
}

/// قواعدُ الأمان كما يسردها `– 39` — `RULES`.
///
/// نقطةُ القاعدة على x 20، ونقطةُ الملاحظة 20 أبعدَ؛ والكلماتُ تبدأ 20
/// (قاعدة) أو 16 (ملاحظة) بعد النقطة. والقاعدةُ الأولى وملاحظاتُها 2 يسارَ
/// البواقي.
const List<SafeRuleData> kWalletSafeRules = <SafeRuleData>[
  SafeRuleData(
    rule: LocaleKeys.rule_send_the_exact_amount,
    ok: true,
    notes: <SafeNoteData>[
      SafeNoteData(
        text: LocaleKeys.rule_entire_amount_at_once_or_parts,
        ok: true,
      ),
      SafeNoteData(
        text: LocaleKeys.rule_amount_from_different_addresses,
        ok: true,
      ),
    ],
  ),
  SafeRuleData(
    rule: LocaleKeys.rule_send_the_selected_currency,
    ok: true,
    notes: <SafeNoteData>[
      SafeNoteData(text: LocaleKeys.rule_same_currency_or_suspended, ok: false),
      SafeNoteData(text: LocaleKeys.rule_contact_support_for_refund, ok: true),
    ],
  ),
  SafeRuleData(
    rule: LocaleKeys.rule_within_the_specified_period,
    ok: true,
    notes: <SafeNoteData>[
      SafeNoteData(
        text: LocaleKeys.rule_after_expiry_contact_support,
        ok: false,
      ),
    ],
  ),
  SafeRuleData(
    rule: LocaleKeys.rule_do_not_transfer_to_same_address,
    ok: false,
    notes: <SafeNoteData>[
      SafeNoteData(text: LocaleKeys.rule_address_is_temporary, ok: false),
      SafeNoteData(text: LocaleKeys.rule_contact_support_for_refund, ok: true),
    ],
  ),
];

/// `– 26`: إجراءاتُ معلومات المحفظة الأربعة (`– 23`) في مواضعها.
const List<WalletAction> kDepositActions = <WalletAction>[
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

/// `– 37`: إجراءاتُ الطلب الثلاثة (`– 28`) في مواضعها.
const List<WalletAction> kCryptoActions = <WalletAction>[
  (id: 'copy', icon: 'infoCopy', label: LocaleKeys.copy, x: 111, off: 0.5),
  (
    id: 'download',
    icon: 'infoDownload',
    label: LocaleKeys.download,
    x: 188,
    off: -0.5,
  ),
  (id: 'share', icon: 'infoShare', label: LocaleKeys.share, x: 290, off: 0.5),
];

/// ما يكلّفه الإيداعُ بالعملة الرقميّة: 110 USDT لـ100 USD في الملفّ.
String walletCharge(String amount) {
  final double value = walletAmount(amount);
  final double total = value * (1 + WalletCryptoData.fee);
  final double rounded = (total * 100).roundToDouble() / 100;
  return rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toString();
}

/// مبلغٌ مكتوبٌ رقماً — `toNumber`.
double walletAmount(String text) =>
    double.tryParse(text.replaceAll(',', '.')) ?? 0;

/// ثوانٍ دقائقَ وثوانيَ: «29:59» — `clock`.
String walletClock(int seconds) {
  final String m = (seconds ~/ 60).toString().padLeft(2, '0');
  final String s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
