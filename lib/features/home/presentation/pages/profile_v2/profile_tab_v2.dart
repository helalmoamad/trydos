import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/features/app/app_widgets/nav_v2/nav_bar_design.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'profile_tab_design.dart';

/// تبويب الملفّ بالتصميم الجديد — لوح XD `Home Page – 9`.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/ProfileScreen.tsx`. وشرحُ
/// كلّ كتلةٍ وأرقامها في [ProfileTabDesign].
///
/// وهذه الودجة **تصميمٌ فقط**: كلّ لمسةٍ تأتي من الصفحة الحاملة في
/// `profile_page.dart`، فيبقى منطقُنا كما كان ولا يدخل هذا الملفّ بلوكاً.
class ProfileTabV2 extends StatelessWidget {
  const ProfileTabV2({
    super.key,
    required this.clientId,
    required this.name,
    required this.phone,
    required this.address,
    required this.photo,
    required this.ordersValue,
    required this.walletValue,
    required this.languageName,
    required this.onOpenCard,
    required this.onOpenQr,
    required this.onOpenPhoto,
    required this.onOpenOrders,
    required this.onOpenWallet,
    required this.onOpenPromo,
    required this.onRow,
    required this.onOpenAddress,
    required this.onOpenName,
    required this.verified,
    this.onWeb,
    this.onLock,
  });

  /// معرّف العميل كما يُكتب في البطاقة (`1012-3456` في الملفّ).
  final String clientId;

  /// الاسم، أو فراغٌ فيُكتب «أدخل اسمك !» بلون التلميح.
  final String name;
  final String phone;

  /// عنوان المستخدم الأوّل، أو فراغٌ فيُكتب «أضف عنواناً !».
  final String address;

  /// رابط صورة المستخدم، أو فراغٌ فيُرسم مربّع الرمز بشريط «أضف صورة».
  final String photo;

  /// السطر الثاني في بطاقة الطلبات (`1 action` في الملفّ).
  final String ordersValue;

  /// السطر الثاني في بطاقة المحفظة (`120 USD` في الملفّ).
  final String walletValue;

  /// اسم اللغة بلغتها — صفُّ اللغة في القائمة.
  final String languageName;

  final VoidCallback onOpenCard;
  final VoidCallback onOpenQr;
  final VoidCallback onOpenPhoto;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenWallet;

  /// بطاقة عرضٍ لُمست: 0 القياسات، 1 التوثيق، 2 الأعمال.
  final void Function(int index) onOpenPromo;

  /// صفُّ قائمةٍ لُمس، بترتيب [_menu].
  final void Function(int index) onRow;

  /// سطرُ الاسم في بطاقة العميل: «أدخل اسمك !» يفتح المعلومات الشخصيّة.
  final VoidCallback onOpenName;

  /// سطرُ العنوان في بطاقة العميل. الملفّ يجعل البطاقة كلّها تفتح قائمة
  /// الملفّ، ورمزَ QR ومربّعَ الصورة وحدهما يفتحان شاشتيهما. وزِيد هذا:
  /// «أضف عنواناً !» يفتح شاشة العناوين مباشرةً.
  final VoidCallback onOpenAddress;

  /// حسابٌ موثَّق: تختفي بطاقةُ عرض التوثيق.
  ///
  /// الملفّ يرسم البطاقات الثلاث دائماً لأنّه عرض؛ وبطاقةُ «حساب غير موثّق»
  /// لا معنى لها لموثَّق.
  final bool verified;

  final VoidCallback? onWeb;
  final VoidCallback? onLock;

  /// مفتاحا الصفّ الأعلى: الويب والقفل.
  static const List<({String icon, String label, double x, double textX})>
  _switches = <({String icon, String label, double x, double textX})>[
    (icon: 'web', label: LocaleKeys.web_label, x: 335.49, textX: 338),
    (icon: 'lock', label: LocaleKeys.lock_label, x: 380.49, textX: 382),
  ];

  /// صفوف القائمة وهوامشها. انظر [ProfileTabDesign.rowH] لحكاية «من نحن».
  static const List<({String icon, String label, double mt})> _menu =
      <({String icon, String label, double mt})>[
        (icon: 'menuSettings', label: LocaleKeys.settings, mt: 12),
        (icon: 'menuTerms', label: LocaleKeys.terms_conditions, mt: 4),
        (icon: 'menuLegal', label: LocaleKeys.legal_information, mt: 4),
        (icon: 'menuAbout', label: LocaleKeys.about_us, mt: 4),
        (icon: 'menuShare', label: LocaleKeys.share_app, mt: 4),
        // صفُّ اللغة يُسمّي اللغة بلغتها، فنصُّه يأتي من [languageName].
        (icon: 'menuLanguage', label: '', mt: 4),
        (icon: 'menuHistory', label: LocaleKeys.login_history, mt: 4),
        (icon: 'menuLogout', label: LocaleKeys.logout, mt: 4),
      ];

  /// البطاقات الثلاث — `PROMOS` في الويب.
  static const List<ProfilePromo> _allPromos = <ProfilePromo>[
    ProfilePromo(
      bg: Color(0xFFFFF9F0),
      button: Color(0xFFFFF2DE),
      contentX: 131,
      buttonX: 12,
      icon: 'size',
      buttonIcon: 'size',
      title: LocaleKeys.setup_your_size_profile,
      text: LocaleKeys.smart_recommendations_that_fit,
      action: LocaleKeys.setup_size_now,
    ),
    ProfilePromo(
      bg: Color(0xFFF0F6FD),
      button: Color(0xFFE0EDFF),
      contentX: 143,
      buttonX: 13,
      icon: 'verifiedDark',
      buttonIcon: 'verifiedBlue',
      title: LocaleKeys.unverified_account,
      text: LocaleKeys.tap_verify_skip_the_line,
      action: LocaleKeys.verify_now,
      hideWhenVerified: true,
    ),
    ProfilePromo(
      bg: Color(0xFFF0FCFD),
      button: Color(0xFFE0F7FF),
      contentX: 128,
      buttonX: 13,
      title: LocaleKeys.get_trydos_business,
      text: LocaleKeys.tap_verify_skip_the_line,
      action: LocaleKeys.start_your_business_now,
      hideWhenVerified: true,
    ),
  ];

  /// ما يُعرض منها: ما لا يسقط بالتوثيق — [ProfilePromo.hideWhenVerified].
  List<ProfilePromo> get _promos => verified
      ? <ProfilePromo>[
          for (final ProfilePromo p in _allPromos)
            if (!p.hideWhenVerified) p,
        ]
      : _allPromos;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // الصفحة لا تقصر عن اللوح الطويل، كما في `ScreenPage.contentHeight`.
      constraints: BoxConstraints(
        minHeight:
            (ProfileTabDesign.contentHeight - ProfileTabDesign.scrollTop).h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _topRow(),
          _clientCard(),
          _PromoSliderV2(
            promos: _promos,
            // الدليل بترتيب القائمة الكاملة، فلا يتبدّل معنى الرقم حين
            // تسقط بطاقةٌ منها.
            onOpen: (int i) => onOpenPromo(_allPromos.indexOf(_promos[i])),
          ),
          _statRow(),
          for (int i = 0; i < _menu.length; i++) _menuRow(i),
          // غرفة الشريط السفليّ — `paddingBottom: TAB_ROOM` في `ScreenPage`.
          SizedBox(height: navTabRoom(context)),
        ],
      ),
    );
  }

  /// 69.5 .. 113.5: الشعار (43 طولاً) والمفتاحان (44). والمفتاحان يُبقيان
  /// 23.51 من الملفّ عن الحافّة اليمنى.
  Widget _topRow() {
    return Padding(
      padding: EdgeInsets.only(
        top: (ProfileTabDesign.wordmarkY - ProfileTabDesign.scrollTop).h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: ProfileTabDesign.wordmarkX.w),
          const XdSvg(
            'wordmark',
            folder: kProfileSvg,
            w: ProfileTabDesign.wordmarkW,
            h: ProfileTabDesign.wordmarkH,
          ),
          const Spacer(),
          _switch(0),
          SizedBox(
            width:
                (_switches[1].x - (_switches[0].x + ProfileTabDesign.switchW))
                    .w,
          ),
          _switch(1),
          SizedBox(
            width: (Xd.designW - (_switches[1].x + ProfileTabDesign.switchW)).w,
          ),
        ],
      ),
    );
  }

  Widget _switch(int i) {
    final ({String icon, String label, double x, double textX}) item =
        _switches[i];
    return _Tap(
      onTap: i == 0 ? onWeb : onLock,
      scale: 0.92,
      child: SizedBox(
        width: ProfileTabDesign.switchW.w,
        height: ProfileTabDesign.switchH.h,
        child: Column(
          children: <Widget>[
            XdSvg(
              item.icon,
              folder: kProfileSvg,
              w: ProfileTabDesign.switchIcon,
            ),
            // النصّ 10 بكسلاً على خطّ الأساس 109، موسَّطاً تحت الأيقونة.
            //
            // الملفّ يضعه على `textX` من حافّة المفتاح اليسرى (338 و382)، أي
            // 2.51 و1.51 داخل صندوقٍ عرضُه 26 — وهما مركزُ الصندوق للنصّ
            // الإنجليزيّ: «Web» بمقاس 10 عرضُه نحو 21 فمركزُه 2.5، و«lock»
            // نحو 23 فمركزُه 1.5. فالتوسيط هو المقصود، والرقمان قياسُ
            // الإنجليزيّة. وبأربع لغاتٍ يُخرج هامشٌ ثابتٌ النصَّ عن المركز.
            //
            // و`OverflowBox` كي لا يُقَصّ نصٌّ أعرض من 26 بل يفيض عن
            // الجانبين بالسواء — والويب لا يقصّه أيضاً (`whitespace-nowrap`
            // في زرٍّ عرضُه 26).
            Padding(
              padding: EdgeInsets.only(
                top: Xd.gapTo(
                  ProfileTabDesign.wordmarkY + ProfileTabDesign.switchIcon,
                  ProfileTabDesign.switchLabelBaseline,
                  ProfileTabDesign.switchLabelSize,
                ).h,
              ),
              // و`SizedBox` حول `OverflowBox` لازم: الأخير يأخذ حجمه من
              // `constraints.biggest`، و`Column` يُعطي أبناءه ارتفاعاً غير
              // محدودٍ على محوره — فيصير ارتفاعه لانهائيّاً. وارتفاعُ النصّ
              // صندوقُ سطره.
              child: SizedBox(
                height: Xd.lineBox(ProfileTabDesign.switchLabelSize).h,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  child: XdText(
                    item.label.tr(),
                    size: ProfileTabDesign.switchLabelSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة العميل، 406 × 140 على (12، 124)، 12 عن الحافّتين. ولمسُها يفتح
  /// الملفّ.
  Widget _clientCard() {
    return Padding(
      padding: EdgeInsets.only(
        top: (ProfileTabDesign.cardY - 113.5).h,
        left: XdRow.x.w,
      ),
      child: GestureDetector(
        onTap: onOpenCard,
        child: Container(
          width: Xd.fill(XdRow.x),
          height: ProfileTabDesign.cardH.h,
          decoration: BoxDecoration(
            color: XdColors.card,
            borderRadius: BorderRadius.circular(ProfileTabDesign.cardRadius.r),
          ),
          padding: EdgeInsets.only(
            left: ProfileTabDesign.cardPad.w,
            right: ProfileTabDesign.cardPad.w,
            top: ProfileTabDesign.cardPad.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // يُفسح النصُّ لمربّع الصورة على شاشةٍ ضيّقة، ويُقَصّ العنوان
              // بـ«…» قبل أن يبلغ المربّع.
              Expanded(child: _cardText()),
              _photoBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: onOpenQr,
          child: const XdSvg(
            'qrBig',
            folder: kProfileSvg,
            w: 250,
            size: ProfileTabDesign.qr,
          ),
        ),
        // المعرّف على خطّ الأساس 207، والاسم على 229.
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(
              ProfileTabDesign.cardY +
                  ProfileTabDesign.cardPad +
                  ProfileTabDesign.qr,
              ProfileTabDesign.idBaseline,
              ProfileTabDesign.idSize,
            ).h,
          ),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: clientId,
                  style: xdTextStyle(
                    size: ProfileTabDesign.idSize,
                    weight: XdWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' ${LocaleKeys.id_label.tr()}',
                  style: xdTextStyle(size: ProfileTabDesign.idSize),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: Xd.gapTo(
              Xd.textBottom(
                ProfileTabDesign.idBaseline,
                ProfileTabDesign.idSize,
              ),
              ProfileTabDesign.nameBaseline,
              ProfileTabDesign.idSize,
            ).h,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // كالعنوان: لمسةُ السطر وحدَه تفتح شاشته ولا تصل إلى البطاقة.
            onTap: onOpenName,
            child: XdText(
              name.isEmpty ? LocaleKeys.enter_your_name.tr() : name,
              size: ProfileTabDesign.idSize,
              color: name.isEmpty ? XdColors.hint : XdColors.ink,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // الهاتف والعنوان: علامتان 14 على x 24 و147، y 238، والنصُّ 11 بعد
        // كلٍّ منهما بـ6، على خطّ الأساس 249. والهاتف خانةٌ بعرض الخطوة إلى
        // علامة الخريطة.
        Padding(
          padding: EdgeInsets.only(
            top:
                (ProfileTabDesign.markY -
                        Xd.textBottom(
                          ProfileTabDesign.nameBaseline,
                          ProfileTabDesign.idSize,
                        ))
                    .h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: ProfileTabDesign.phoneSlot.w,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const XdSvg(
                      'phone',
                      folder: kProfileSvg,
                      w: ProfileTabDesign.markSize,
                    ),
                    SizedBox(width: ProfileTabDesign.markGap.w),
                    XdText(phone, size: ProfileTabDesign.lineSize),
                  ],
                ),
              ),
              const XdSvg(
                'mapSmall',
                folder: kProfileSvg,
                w: ProfileTabDesign.markSize,
              ),
              SizedBox(width: ProfileTabDesign.markGap.w),
              Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // لمسةُ السطر وحدَه تفتح العناوين، ولا تصل إلى البطاقة
                  // تحتها — كما يفعل رمزُ QR ومربّعُ الصورة في الملفّ.
                  onTap: onOpenAddress,
                  child: XdText(
                    address.isEmpty ? LocaleKeys.enter_address.tr() : address,
                    size: ProfileTabDesign.lineSize,
                    color: address.isEmpty ? XdColors.hint : XdColors.ink,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// مربّع الصورة، 116 × 115 على (290، 136): 12 نزولاً و12 عن حافّة البطاقة
  /// اليمنى. ويفتح شاشة الصورة.
  Widget _photoBox() {
    final bool hasPhoto = photo.isNotEmpty;
    return _Tap(
      onTap: onOpenPhoto,
      scale: 0.97,
      child: Container(
        width: ProfileTabDesign.photoW.w,
        height: ProfileTabDesign.photoH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(ProfileTabDesign.cardRadius.r),
          // خطُّ الملفّ حول المربّع.
          border: Border.all(color: XdColors.hint, width: 0.5),
        ),
        // لا يُقَصّ إلّا حول صورة: بغيرها يجب أن يُظهر الشريط الداكن
        // (230 .. 252 في الملفّ) زواياه المستديرة بكسلاً تحت المربّع.
        clipBehavior: hasPhoto ? Clip.antiAlias : Clip.none,
        child: hasPhoto
            ? Image.network(photo, fit: BoxFit.cover)
            : Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: ProfileTabDesign.avatarX.w,
                    top: ProfileTabDesign.avatarY.h,
                    child: const XdSvg(
                      'avatarSmall',
                      folder: kProfileSvg,
                      w: ProfileTabDesign.avatarW,
                      h: ProfileTabDesign.avatarH,
                    ),
                  ),
                  // الشريط 22 طولاً من y 94. والملفّ يضعه فوق آخر 7.24 من
                  // الرمز، فهامشه في الويب سالب — وهنا يُوضع بـ`Positioned`
                  // لأنّ `Padding` في فلَتَر يرفض الهامش السالب.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: ProfileTabDesign.stripY.h,
                    height: ProfileTabDesign.stripH.h,
                    child: _addPhotoStrip(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _addPhotoStrip() {
    return Container(
      decoration: BoxDecoration(
        color: XdColors.inkSoft,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ProfileTabDesign.cardRadius.r),
          bottomRight: Radius.circular(ProfileTabDesign.cardRadius.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: ProfileTabDesign.addPhotoIconX.w),
          Padding(
            padding: EdgeInsets.only(top: ProfileTabDesign.addPhotoIconY.h),
            child: const XdSvg(
              'addPhoto',
              folder: kProfileSvg,
              w: ProfileTabDesign.addPhotoIcon,
            ),
          ),
          SizedBox(
            width:
                (ProfileTabDesign.addPhotoTextX -
                        ProfileTabDesign.addPhotoIconX -
                        ProfileTabDesign.addPhotoIcon)
                    .w,
          ),
          Padding(
            padding: EdgeInsets.only(top: ProfileTabDesign.addPhotoIconY.h),
            child: XdText(
              LocaleKeys.add_photo.tr(),
              size: ProfileTabDesign.addPhotoSize,
              color: XdColors.card,
            ),
          ),
        ],
      ),
    );
  }

  /// الطلبات ومحفظة Trydos، 201 × 94 على y 380، بينهما 4. تتقاسمان الصفّ
  /// الذي يُبقي 12 عن الحافّتين.
  Widget _statRow() {
    return Padding(
      padding: EdgeInsets.only(
        top: ProfileTabDesign.statGap.h,
        left: XdRow.x.w,
      ),
      child: SizedBox(
        width: Xd.fill(XdRow.x),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _statCard(
                icon: 'orders',
                title: LocaleKeys.orders.tr(),
                value: ordersValue,
                onTap: onOpenOrders,
              ),
            ),
            SizedBox(width: ProfileTabDesign.statGap.w),
            Expanded(
              child: _statCard(
                icon: 'wallet',
                title: LocaleKeys.trydos_wallet.tr(),
                value: walletValue,
                onTap: onOpenWallet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return _Tap(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        height: ProfileTabDesign.statH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(ProfileTabDesign.cardRadius.r),
        ),
        padding: EdgeInsets.only(
          left: ProfileTabDesign.promoPad.w,
          right: ProfileTabDesign.promoPad.w,
          top: ProfileTabDesign.promoPad.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            XdSvg(icon, folder: kProfileSvg, w: ProfileTabDesign.statIcon),
            // خطّا الأساس 61 و81 في البطاقة.
            Padding(
              padding: EdgeInsets.only(
                top: Xd.gapTo(
                  ProfileTabDesign.promoPad + ProfileTabDesign.statIcon,
                  ProfileTabDesign.statTitleBaseline,
                  ProfileTabDesign.statTitleSize,
                ).h,
              ),
              child: XdText(
                title,
                size: ProfileTabDesign.statTitleSize,
                weight: XdWeight.medium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Xd.gapTo(
                  Xd.textBottom(
                    ProfileTabDesign.statTitleBaseline,
                    ProfileTabDesign.statTitleSize,
                  ),
                  ProfileTabDesign.statValueBaseline,
                  ProfileTabDesign.statValueSize,
                ).h,
              ),
              child: XdText(
                value,
                size: ProfileTabDesign.statValueSize,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// صفُّ قائمة — `MenuRow` في `DemoApp1/ui.tsx`.
  Widget _menuRow(int i) {
    final ({String icon, String label, double mt}) row = _menu[i];
    final Widget tile = _Tap(
      onTap: () => onRow(i),
      scale: 0.985,
      child: Container(
        width: Xd.fill(XdRow.x),
        height: ProfileTabDesign.rowH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: ProfileTabDesign.promoPad.w),
            XdSvg(row.icon, folder: kProfileSvg, w: ProfileTabDesign.rowIcon),
            SizedBox(
              width:
                  (ProfileTabDesign.rowTextX -
                          XdRow.x -
                          ProfileTabDesign.promoPad -
                          ProfileTabDesign.rowIcon)
                      .w,
            ),
            Expanded(
              child: XdText(
                row.label.isEmpty ? languageName : row.label.tr(),
                size: ProfileTabDesign.rowTextSize,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
    // الهامش السالب لـ«من نحن»: الصفّان يتراكبان بكسلين، فيُرفع الصفّ
    // بـ`Transform` لأنّ `Padding` يرفض السالب.
    if (row.mt < 0) {
      return Padding(
        padding: EdgeInsets.only(left: XdRow.x.w),
        child: Transform.translate(offset: Offset(0, row.mt.h), child: tile),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: row.mt.h, left: XdRow.x.w),
      child: tile,
    );
  }
}

/// «Scroll Group 88» في الملفّ: ثلاث بطاقاتٍ 406 × 108 على y 268 (4 تحت بطاقة
/// العميل)، بينها 4، الأولى على x 12 والتالية تُطلّ من الحافّة اليمنى.
///
/// والمستخدم يُحرّكها بيده: اسحب فتَثِب إلى أقرب بطاقة. والتصميم سيُظهر
/// بطاقةً واحدةً لاحقاً؛ وثلاثٌ تُعرض للعرض.
class _PromoSliderV2 extends StatefulWidget {
  const _PromoSliderV2({required this.promos, required this.onOpen});

  final List<ProfilePromo> promos;
  final void Function(int index) onOpen;

  @override
  State<_PromoSliderV2> createState() => _PromoSliderV2State();
}

class _PromoSliderV2State extends State<_PromoSliderV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _x;
  int _index = 0;

  /// وقع سحبٌ في هذه اللمسة، فلا تفتح البطاقةُ عند رفع الإصبع.
  bool _dragged = false;

  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: ProfileTabDesign.promoStiffness,
    damping: ProfileTabDesign.promoDamping,
  );

  @override
  void initState() {
    super.initState();
    _x = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _x.dispose();
    super.dispose();
  }

  /// البطاقة هي الشريط ناقص 12 من كلّ جانب، والخطوة بطاقةٌ وفراغها.
  double _step(double sliderW) =>
      sliderW - 2 * XdRow.x.w + ProfileTabDesign.promoGap.w;

  void _settle(double step, {double velocity = 0}) {
    // حيث تركت السحبةُ الشريط، مدفوعةً نصف بطاقةٍ بنفضة.
    final double moved = -_x.value / step;
    final double flick = velocity < -ProfileTabDesign.promoFlick
        ? 0.5
        : (velocity > ProfileTabDesign.promoFlick ? -0.5 : 0);
    _index = (moved + flick).round().clamp(0, widget.promos.length - 1);
    // النابض يعمل وإن لم يتبدّل الدليل.
    _x.animateWith(
      SpringSimulation(_spring, _x.value, -_index * step, -velocity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sliderW = 1.sw;
    final double step = _step(sliderW);
    final double minX = -(widget.promos.length - 1) * step;

    return Padding(
      padding: EdgeInsets.only(top: ProfileTabDesign.promoGap.h),
      child: SizedBox(
        width: sliderW,
        height: ProfileTabDesign.promoH.h,
        child: ClipRect(
          child: GestureDetector(
            // المسار كلّه سطحُ السحب، كما في الويب: الفراغ بين بطاقتين
            // والـ12 الأولى شفافان، و`deferToChild` كان يُسقط اللمسة فيهما.
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) {
              _dragged = true;
              _x.stop();
            },
            onHorizontalDragUpdate: (DragUpdateDetails d) {
              double next = _x.value + d.delta.dx;
              // جرٌّ مطّاطيّ وراء الطرفين.
              if (next > 0) {
                next = next * ProfileTabDesign.promoElastic;
              } else if (next < minX) {
                next = minX + (next - minX) * ProfileTabDesign.promoElastic;
              }
              _x.value = next;
            },
            onHorizontalDragEnd: (DragEndDetails d) {
              _settle(step, velocity: d.primaryVelocity ?? 0);
              // لمسةُ الإطار نفسه لا تفتح البطاقة.
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _dragged = false,
              );
            },
            child: AnimatedBuilder(
              animation: _x,
              builder: (context, _) => Transform.translate(
                offset: Offset(_x.value, 0),
                // المسار أعرض من الشريط: ثلاث بطاقاتٍ عرضُ كلٍّ منها
                // `1.sw - 24`، فمجموعه `3·sw - 52` مقابل `sw` متاح.
                // و`Row` يُحصر بعرض أبيه فيفيض ويرسم شريط الخطأ، وتُرسم
                // البطاقتان التاليتان خارج الحدود فلا يُحرّكهما السحب.
                // فـ`OverflowBox` يرفع الحصر ويترك المسار يأخذ عرضه،
                // و`ClipRect` يقصّ ما خرج — وهذا `overflow: hidden` في الويب.
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: double.infinity,
                  child: SizedBox(
                    width: XdRow.x.w + widget.promos.length * step,
                    height: ProfileTabDesign.promoH.h,
                    // `Positioned.left` مسافةٌ **فيزيائيّة** لا تنعكس في
                    // العربيّة، فالمسار يُقاس من اليسار كما يقيسه الملفّ:
                    // الأولى على x 12، والتالية تُطلّ من اليمين بـ8، والسحب
                    // يساراً يُقدّم — وحسابُ `_x` و`minX` كلّه مقيسٌ من اليسار.
                    //
                    // و`Row` كان ينعكس في العربيّة فتصير الأولى على اليمين
                    // والبقيّة خارج الشاشة؛ وفرضُ `Directionality(ltr)` عليه
                    // يُصلح ترتيبها لكنّه يجرّ **محتوى البطاقات** معه إلى
                    // اليسار. و`Stack` يُصلح الاثنين: ترتيبٌ من اليسار،
                    // وكلّ بطاقةٍ تبقى على اتّجاه التطبيق.
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        for (int i = 0; i < widget.promos.length; i++)
                          Positioned(
                            left: XdRow.x.w + i * step,
                            top: 0,
                            width: Xd.fill(XdRow.x),
                            height: ProfileTabDesign.promoH.h,
                            child: _PromoCardV2(
                              promo: widget.promos[i],
                              onOpen: () {
                                if (!_dragged) widget.onOpen(i);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة عرضٍ واحدة.
///
/// في البطاقة: العلامة 14 على (12، 12)، والعنوان 11 Medium من x 32 على خطّ
/// الأساس 23، وعلامة المساعدة (15) على (379.5، 11.5)، والنصّ على خطّ
/// الأساس 43، والزرّ 382 × 38 على (12، 58).
class _PromoCardV2 extends StatelessWidget {
  const _PromoCardV2({required this.promo, required this.onOpen});

  final ProfilePromo promo;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    // الزرّ أضيق من البطاقة بالفراغين الذين يتركهما، ومحتواه يحفظ مسافته عن
    // مركز الزرّ (`contentX` على شاشة 430).
    // عرض الزرّ: `fill(buttonX, 406 - buttonX - 382)` في الويب، ومقياسُ
    // النسبة فيه **البطاقة** لا الشاشة — فهو عرضُ البطاقة ناقص الفراغين
    // اللذين يتركهما، ومجموعهما 24 في البطاقات الثلاث (12 + 12، و13 + 11).
    //
    // وكان محسوباً بـ`Xd.fill` الذي يقيس من الشاشة، فخرج الزرّ بعشرين بكسلاً.
    final double buttonW =
        Xd.fill(XdRow.x) - (XdRow.width - ProfileTabDesign.promoButtonW).w;

    return Container(
      height: ProfileTabDesign.promoH.h,
      decoration: BoxDecoration(
        color: promo.bg,
        borderRadius: BorderRadius.circular(ProfileTabDesign.cardRadius.r),
      ),
      padding: EdgeInsets.only(top: ProfileTabDesign.promoPad.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: ProfileTabDesign.promoPad.w,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (promo.icon != null)
                  XdSvg(
                    promo.icon!,
                    folder: kProfileSvg,
                    w: ProfileTabDesign.promoIcon,
                  ),
                SizedBox(
                  width:
                      (ProfileTabDesign.promoTitleX -
                              ProfileTabDesign.promoPad -
                              (promo.icon == null
                                  ? 0
                                  : ProfileTabDesign.promoIcon))
                          .w,
                ),
                Expanded(
                  child: XdText(
                    promo.title.tr(),
                    size: ProfileTabDesign.promoTitleSize,
                    weight: XdWeight.medium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // أعلى من العنوان بنصف بكسل وأطول منه ببكسل؛ والويب يُلغي
                // ذلك بهامشين سالبين كي يبقى الصفّ 14. وهنا يُرفع
                // بـ`Transform` للسبب نفسه.
                Transform.translate(
                  offset: Offset(0, -0.5.h),
                  child: const XdSvg(
                    'helpGrey',
                    folder: kProfileSvg,
                    w: ProfileTabDesign.promoHelp,
                    h: 15,
                  ),
                ),
                SizedBox(width: ProfileTabDesign.promoHelpRight.w),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: ProfileTabDesign.promoTitleX.w,
              top: Xd.gapTo(
                ProfileTabDesign.promoPad + ProfileTabDesign.promoIcon,
                ProfileTabDesign.promoTextBaseline,
                ProfileTabDesign.promoTitleSize,
              ).h,
            ),
            child: XdText(
              promo.text.tr(),
              size: ProfileTabDesign.promoTitleSize,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              top:
                  (ProfileTabDesign.promoButtonY -
                          Xd.textBottom(
                            ProfileTabDesign.promoTextBaseline,
                            ProfileTabDesign.promoTitleSize,
                          ))
                      .h,
              start: promo.buttonX.w,
            ),
            child: _Tap(
              onTap: onOpen,
              scale: 0.98,
              child: Container(
                width: buttonW,
                height: ProfileTabDesign.promoButtonH.h,
                decoration: BoxDecoration(
                  color: promo.button,
                  borderRadius: BorderRadius.circular(
                    ProfileTabDesign.cardRadius.r,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  // الملفّ يضع محتوى الزرّ على `contentX` من حافّته اليسرى
                  // (131 و143 و128)، وهو في كلّ بطاقةٍ **مركزُ الزرّ** للنصّ
                  // الإنجليزيّ: 382/2 ناقص نصفَ عرض المحتوى. وبأربع لغاتٍ
                  // يختلف عرض النصّ، فهامشٌ ثابتٌ يُخرجه عن المركز؛ والتوسيط
                  // يُصيبه في كلّ لغة، ويستقيم في العربيّة من غير حيلة.
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (promo.buttonIcon != null) ...<Widget>[
                      XdSvg(
                        promo.buttonIcon!,
                        folder: kProfileSvg,
                        w: ProfileTabDesign.promoIcon,
                      ),
                      SizedBox(width: ProfileTabDesign.markGap.w),
                    ],
                    Flexible(
                      child: XdText(
                        promo.action.tr(),
                        size: ProfileTabDesign.promoTitleSize,
                        weight: XdWeight.medium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// لمسةٌ تُصغّر ما تحتها — `whileTap={{ scale }}` في framer-motion.
class _Tap extends StatefulWidget {
  const _Tap({required this.child, required this.scale, this.onTap});

  final Widget child;
  final double scale;
  final VoidCallback? onTap;

  @override
  State<_Tap> createState() => _TapState();
}

class _TapState extends State<_Tap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // الهدفُ صندوقُه كلُّه، لا ما رُسم فيه: بغيره تسقط اللمسةُ على فراغٍ
      // داخل الصندوق فلا تُحسب.
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
