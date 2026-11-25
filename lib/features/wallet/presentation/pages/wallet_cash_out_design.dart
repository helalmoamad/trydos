/// أرقامُ نافذة السحب وطلبِه وبياناتُها، منقولةً حرفياً عن
/// `web_design/components/DemoApp1/screens/WalletCashOutSheet.tsx` و
/// `WalletWithdrawalRequest.tsx` و`components/DemoApp/demoWallet.ts`.
///
/// > السحب — ألواحُ XD: `– 21` (طرقُ السحب)، و`– 19` و`– 20` و`– 25` و`– 27`
/// > و`– 29` و`– 35` و`– 36` (نموذجُ trydos | rdb وحالاتُه)، و`– 30` (قارئُ
/// > الرمز)، و`– 101` و`– 28` و`– 24` (طلبُ السحب).
/// >
/// > نافذةٌ واحدة، خمسُ خطوات. الملفُّ يرسم الخطوة الأولى من y 244 والبواقي
/// > من y 90، وزواياها العلويّة 50 كلُّها. والنافذةُ موضوعةٌ على 90 وتستقرّ
/// > 154 أخفضَ ما دامت الخطوةُ الأولى معروضةً.
/// >
/// > وكلُّ y هنا y الملفّ. والمقبضُ ينتهي 13 تحت حافّة النافذة العليا، فأوّلُ
/// > كتلةٍ في خطوةٍ هامشُها الأعلى = y الكتلة ناقصَ (أعلى النافذة + 13).
library;

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'wallet_sheet_parts.dart';

/// خطواتُ النافذة الخمس — `type Step`.
enum CashOutStep { ways, form, scan, code, request }

/// الحقلُ الذي يكتب فيه المشتري — `type InUse`.
enum CashOutField { amount, phone, name }

/// أرقامُ نافذة السحب.
abstract class CashOutDesign {
  /// أعلى كلّ خطوةٍ على اللوح — `TOP`.
  static const Map<CashOutStep, double> top = <CashOutStep, double>{
    CashOutStep.ways: 244,
    CashOutStep.form: 90,
    CashOutStep.scan: 90,
    CashOutStep.code: 90,
    CashOutStep.request: 90,
  };

  /// النافذةُ موضوعةٌ على أعلى خطواتها، وتهبط ما بين الخطوة المعروضة وهذا.
  static const double layoutTop = 90;

  /// لوحا النموذج وقارئ الرمز ينتهيان على y 930 — `BOARD_END`.
  static const double boardEnd = 930;

  /// ما تحت آخر كتلةٍ في لوحٍ: اللوحُ ينتهي على 930 والكتلُ على 895.
  static const double boardTail = boardEnd - 895;

  /// حيث ينتهي صندوقُ سطر العلامة على النافذة — `HEAD_END`.
  static double get headEnd => Xd.textBottom(180, 24);

  /// `– 21`: الفقرةُ من خطّ الأساس 324 بارتفاع 18 (سطران)، ثمّ بطاقةُ
  /// trydos | rdb على y 366، فثلاثُ خاناتٍ 125 على y 562، فالبطاقةُ الرماديّة
  /// 390 × 188 على (20، 707).
  static const double waysParaBaseline = 324;
  static const double waysParaLine = 18;
  static const double brandCardY = 366;
  static const double brandCardH = 188;
  static const double tilesY = 562;
  static const double tile = 125;
  static const double greyCardY = 707;
  static const double greyCardH = 188;

  /// داخل البطاقة الرماديّة: «اسحب أموالك !» على خطّ الأساس 730، ثمّ فقرةٌ من
  /// 752 بارتفاع 18 (ثلاثةُ أسطر)، فزرّان 38 طولاً على 801 و845.
  static const double greyTitleBaseline = 730;
  static const double greyParaBaseline = 752;
  static const double greyParaLine = 18;
  static const double greyButtonY = 801;
  static const double greyButtonY2 = 845;
  static const double greyButtonH = 38;

  /// النموذج: تبويبان على y 213، والحقولُ 55 طولاً.
  static const double tabsY = 213;
  static const double tabH = 28;
  static const double fieldH = 55;
  static const double field1Y = 245;
  static const double field2Y = 304;
  static const double field3Y = 363;

  /// زرُّ المستلم المفوَّض: 356 × 30 بزاوية 12، كلمتُه على خطّ الأساس 382.
  static const double addY = 363;
  static const double addX = 32;
  static const double addW = 356;
  static const double addH = 30;
  static const double addBaseline = 382;

  /// بعد «+ أضف»: حقلان على y 363 و422، ثمّ «− أزِل» على (37، 481).
  static const double entry1Y = 363;
  static const double entry2Y = 422;
  static const double removeY = 481;
  static const double removeX = 37;

  /// حقلُ المبلغ: على y 422 في تبويب المصرف، و515 حين يكون مستعمَلاً أو مع
  /// مستلمٍ مفوَّض، و397 حين يُحفظ المبلغ. و93 طولاً مع التنبيه.
  static const double amountBankY = 422;
  static const double amountUseY = 515;
  static const double amountSavedY = 397;
  static const double amountTallH = 93;

  /// تنبيهُ «رصيدك غير كافٍ»: 366 × 30 على (32، 532)، كلمتُه على 551. وهو
  /// 55 من أعلى الحقل، أي 6 تحت سطر القيمة.
  static const double shortTintY = 55;
  static const double shortY = 532;
  static const double shortH = 30;
  static const double shortBaseline = 551;

  /// «الرصيد المتاح» في عنوان الحقل: من x 291، وينتهي 12 داخل الحافّة.
  static const double availableX = 291;
  static const double availableW = 398 - 291;

  /// تنبيهُ «لا يستلم إلّا المسمّى»: 356 × 30 على (37، 574)، كلمتُه على 593.
  static const double namedY = 574;
  static const double namedH = 30;
  static const double namedX = 37;
  static const double namedBaseline = 593;

  /// الزرّان العريضان على y 767 و835، 60 طولاً.
  static const double buttonNowY = 767;
  static const double buttonY = 835;
  static const double buttonH = 60;

  /// `– 30`: الصندوقُ الأسود 350 على (40، 213) بزاوية 30، وعلامتُه 25 على
  /// y 500 وسطرُها على خطّ الأساس 548؛ ثمّ «سحبٌ نقديّ» على 591 والمبلغُ على
  /// 631، فالفقرةُ الرماديّة من 662 بارتفاع 18.
  static const double scanBoxY = 213;
  static const double scanBoxX = 40;
  static const double scanBoxH = 350;
  static const double scanBoxRadius = 30;
  static const double scanMarkY = 500;
  static const double scanMark = 25;
  static const double scanLineBaseline = 548;
  static const double scanTitleBaseline = 591;
  static const double scanAmountBaseline = 631;
  static const double scanParaBaseline = 662;
  static const double scanParaSize = 13;
  static const double scanParaLine = 18;

  /// `– 101`: كلُّ شيءٍ 40 من الحافّة. المبلغُ و«طلب سحب» على خطّ الأساس 276،
  /// و«التوثيق !» (30 Bold) على 318 والسطرُ تحته على 354؛ ثمّ ثلاثةُ صفوفٍ
  /// بينها 8 من y 366 و389 و412؛ فصناديقُ الرمز الستّة على (20، 502).
  static const double codeX = 40;
  static const double codeRequestBaseline = 276;
  static const double codeTitleBaseline = 318;
  static const double codeLineBaseline = 354;
  static const double codeRow1Y = 366;
  static const double codeRow2Y = 389;
  static const double codeRow3Y = 412;
  static const double codeBoxesY = 502;
  static const double codeBoxesX = 20;

  /// حياةُ الرمز دقيقتان، كما في تسجيل الدخول — `CODE_SECONDS`.
  static const int codeSeconds = 120;

  /// `– 28`: الرمزُ 301 على (65، 215)، و«طلب سحب» (16 Medium) على خطّ الأساس
  /// 544، والخلايا من y 588، وثلاثةُ إجراءاتٍ على y 855.
  static const double requestQr = 301;
  static const double requestQrX = 65;
  static const double requestQrY = 215;
  static const double requestTitleBaseline = 544;
  static const double requestCellsY = 588;
  static const double actionsY = 855;
  static const double actionLabelBaseline = 892;

  /// `– 24`: صفُّ العنوان على y 66 والعلامةُ على خطّ الأساس 132؛ والرمزُ
  /// 350.56 على (40، 167) و«طلب سحب» على 546، والخلايا من 561، والملاحظةُ
  /// 390 × 90 على (20، 805).
  static const double pictureTitleBaseline = 132;
  static const double pictureQr = 351;
  static const double pictureQrX = 40;
  static const double pictureQrY = 167;
  static const double pictureTitleY = 546;
  static const double pictureCellsY = 561;
  static const double noteY = 805;
  static const double noteH = 90;
  static const double noteTitleBaseline = 828;
  static const double noteParaBaseline = 848;
  static const double noteParaLine = 16;

  /// الخلايا 55 طولاً بينها 4، والصفُّ 20 من الحافّتين.
  static const double cellH = 55;
  static const double cellGap = 4;

  /// صناديقُ الرمز الستّة: 60 حجماً بينها 6 بزاوية 15 — `XD.otp`.
  static const double pinBox = 60;
  static const double pinGap = 6;
  static const double pinRadius = 15;
}

/// طريقةُ سحبٍ في `– 21` — `WALLET_PROVIDERS`.
class WalletProviderData {
  const WalletProviderData({
    required this.id,
    required this.name,
    required this.picture,
    required this.gap,
  });

  final String id;

  /// اسمُ علامةٍ تجاريّة: واحدٌ في كلّ لغة.
  final String name;
  final String picture;

  /// الفراغُ قبل الخانة: الملفُّ يضع 8 ثمّ 7.
  final double gap;
}

/// الطرقُ الثلاث في `– 21`، من اليسار إلى اليمين.
const List<WalletProviderData> kWalletProviders = <WalletProviderData>[
  WalletProviderData(
    id: 'sham',
    name: 'Sham Cash',
    picture: 'payShamCash.jpg',
    gap: 0,
  ),
  WalletProviderData(
    id: 'syriatel',
    name: 'Syriatel Cash',
    picture: 'paySyriatelCash.jpg',
    gap: 8,
  ),
  WalletProviderData(
    id: 'irsal',
    name: 'Irsal',
    picture: 'payIrsal.jpg',
    gap: 7,
  ),
];

/// طلبُ سحبٍ كما تملؤه الألواحُ `– 101` و`– 28` و`– 24` — `WALLET_REQUEST`.
abstract class WalletRequestData {
  /// الرقمُ الذي يذهب إليه الرمز، ووسطُه محجوب.
  static const String codeSentTo = '+90 5x2 8xx xx00';
  static const String reference = '101213';
  static const String date = '03.march | 14:55';
}

/// ما يقوله طلبُ السحب — `WithdrawalRequest`.
class WithdrawalRequestData {
  const WithdrawalRequestData({required this.amount, this.authorized});

  final String amount;

  /// اسمُ المستلم المفوَّض متى كان في النموذج.
  final String? authorized;
}

/// إجراءاتُ `– 28` الثلاثة، وx الذي يبدأ عنده الملفُّ كلمةَ كلٍّ منها.
const List<WalletAction> kRequestActions = <WalletAction>[
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
