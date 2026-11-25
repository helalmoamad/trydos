import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'profile_tab_design.dart';

/// معلومات العميل — لوح XD `Home Page – 87`.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/ClientInfoScreen.tsx`:
///
/// > ستُّ بطاقاتٍ للقراءة فقط، 55 طولاً بزاوية 15 ولون `#FCFCFC`، من y 112
/// > (12 تحت الترويسة)، بينها 4 نزولاً وعرضاً: المعرّف (406 عرضاً، ورمز QR
/// > على يمينه يفتح شاشة معرّف العميل)، والحالة و«عميل منذ»، والنوع
/// > والتوثيق (201 عرضاً، زوجاً زوجاً)، والهاتف (406، بخطّ 0.5 `#D3D3D3`).
/// > العنوان 12 Regular `#C3C3C3` على خطّ الأساس +20، والقيمة 14 Medium على
/// > +43 — إلّا «23 يوماً»، فالملفّ يرسم العدد Medium والكلمة Regular.
/// >
/// > وفي الأسفل زرّا طلبٍ 406 × 56 (خطّ 0.5 `#C3C3C3`، نصّ 14 Medium
/// > موسَّط)، مثبّتان أسفل الصفحة كأزرار تسجيل الدخول. ولا خدمة تستقبل هذين
/// > الطلبين بعد.
class ClientInfoPageV2 extends StatelessWidget {
  const ClientInfoPageV2({
    super.key,
    required this.clientId,
    required this.phone,
    required this.verified,
    this.sinceDays,
    this.onOpenQr,
    this.onChangePhone,
    this.onDeleteAccount,
  });

  final String clientId;
  final String phone;

  /// موثَّق الهاتف. والملفّ يكتب «موثَّق» دائماً؛ وعندنا حالةٌ حقيقيّة.
  final bool verified;

  /// أيّامٌ منذ إنشاء الحساب — `profile.clientSince`. وغيابُه يُفرغ القيمة.
  final int? sinceDays;

  final VoidCallback? onOpenQr;
  final VoidCallback? onChangePhone;
  final VoidCallback? onDeleteAccount;

  /// ارتفاع البطاقة وزاويتها وحشوتها.
  static const double _cardH = 55;
  static const double _pad = 12;
  static const double _padTop = 8;
  static const double _gap = 4;

  /// العنوان على +20 والقيمة على +43 من أعلى البطاقة.
  static const double _labelSize = 12;
  static const double _valueSize = 14;

  /// زرّا الطلب: 56 طولاً، بينهما 8، والسفليّ 36 فوق الأسفل.
  static const double _buttonH = 56;
  static const double _buttonGap = 8;
  static const double _buttonBottom = 36;

  @override
  Widget build(BuildContext context) {
    return XdScreenPage(
      header: XdScreenHeader(
        title: LocaleKeys.client_information.tr(),
        // الملفّ يُوسّط هذا العنوان بالعين، أيسرَ بنقطتين.
        nudge: -2,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      footer: _footer(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _idCard(),
          _pair(
            left: (
              label: LocaleKeys.client_status.tr(),
              value: LocaleKeys.active.tr(),
            ),
            right: (
              label: LocaleKeys.client_since.tr(),
              value: sinceDays == null
                  ? ''
                  : '$sinceDays ${LocaleKeys.days.tr()}',
            ),
            // «23 يوماً»: العدد Medium والكلمة Regular — والقيمة كلّها
            // Regular هنا، فالعددُ جزءٌ من جملةٍ مترجمة لا رقمٌ وحده.
            rightWeight: XdWeight.regular,
          ),
          _pair(
            left: (
              label: LocaleKeys.client_type.tr(),
              value: LocaleKeys.personal.tr(),
            ),
            right: (
              label: LocaleKeys.client_verified.tr(),
              value: verified
                  ? LocaleKeys.verified.tr()
                  : LocaleKeys.not_verified.tr(),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: _gap.h, start: XdRow.x.w),
            child: _card(
              width: Xd.fill(XdRow.x),
              label: LocaleKeys.client_phone_number.tr(),
              value: phone,
              line: true,
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة المعرّف: 406 عرضاً، ورمز QR 39 × 39 على (367، 120) — 8 نزولاً
  /// و12 عن حافّتها اليمنى — يفتح شاشة معرّف العميل.
  Widget _idCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: _pad.h, start: XdRow.x.w),
      child: Container(
        width: Xd.fill(XdRow.x),
        height: _cardH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        padding: EdgeInsetsDirectional.only(
          start: _pad.w,
          end: _pad.w,
          top: _padTop.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _lines(LocaleKeys.client_id.tr(), clientId)),
            XdTap(
              scale: 0.97,
              onTap: onOpenQr,
              child: const XdSvg(
                'qrBig',
                folder: kProfileSvg,
                w: 250,
                size: 39,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// صفٌّ من بطاقتين تتقاسمان عرضه، بينهما 4 — `HALF` في الويب.
  Widget _pair({
    required ({String label, String value}) left,
    required ({String label, String value}) right,
    XdWeight rightWeight = XdWeight.medium,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: _gap.h, start: XdRow.x.w),
      child: SizedBox(
        width: Xd.fill(XdRow.x),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _card(label: left.label, value: left.value),
            ),
            SizedBox(width: _gap.w),
            Expanded(
              child: _card(
                label: right.label,
                value: right.value,
                weight: rightWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقةٌ للقراءة فقط: العنوان 12 على +20، والقيمة 14 على +43.
  Widget _card({
    required String label,
    required String value,
    double? width,
    XdWeight weight = XdWeight.medium,
    bool line = false,
  }) {
    return Container(
      width: width,
      height: _cardH.h,
      decoration: BoxDecoration(
        color: XdColors.card,
        borderRadius: BorderRadius.circular(XdRow.radius.r),
        border: line ? Border.all(color: XdColors.line, width: 0.5) : null,
      ),
      padding: EdgeInsetsDirectional.only(
        start: _pad.w,
        end: _pad.w,
        top: _padTop.h,
      ),
      child: _lines(label, value, weight: weight),
    );
  }

  Widget _lines(
    String label,
    String value, {
    XdWeight weight = XdWeight.medium,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        XdText(
          label,
          size: _labelSize,
          color: XdColors.hint,
          overflow: TextOverflow.ellipsis,
        ),
        // 6 بين صندوقي السطرين — خطّا الأساس +20 و+43.
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: XdText(
            value,
            size: _valueSize,
            weight: weight,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// زرّا الطلب، مثبّتان أسفل الصفحة: 56 طولاً، بينهما 8، والسفليّ 36 فوق
  /// الحافّة الآمنة، و12 عن الحافّتين.
  Widget _footer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: XdRow.x.w,
        right: XdRow.x.w,
        bottom: _buttonBottom.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _requestButton(
            LocaleKeys.change_my_phone_number_request.tr(),
            onChangePhone,
          ),
          SizedBox(height: _buttonGap.h),
          _requestButton(
            LocaleKeys.delete_my_account_request.tr(),
            onDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _requestButton(String label, VoidCallback? onTap) {
    return XdTap(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: _buttonH.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
          border: Border.all(color: XdColors.hint, width: 0.5),
        ),
        child: XdText(
          label,
          size: _valueSize,
          weight: XdWeight.medium,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
