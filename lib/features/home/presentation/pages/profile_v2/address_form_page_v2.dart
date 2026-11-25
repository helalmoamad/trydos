import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// إضافةُ عنوانٍ أو تعديله — ألواح XD `Home Page – 94` (النموذج) و`– 95`
/// (نافذة الدول) و`– 97` (نافذة الأماكن) و`– 99` (مملوءاً).
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/AddressFormScreen.tsx`:
///
/// > بطاقةُ الخريطة (406 × 121 على y 160، 12 تحت الشريط) تحمل الخريطة
/// > (382 × 79 بزاوية 15) وحبّةَ «حدّد موقعك على الخريطة» السوداء. ولمسُها
/// > يُسقط الدبّوس: فتكبر البطاقة إلى 186 والخريطةُ إلى 162، وتصير الحبّة
/// > `#4A31E7` ونصُّها «موقعك على الخريطة»، وينزل كلُّ حقلٍ تحتها 65 معها —
/// > وهو بالضبط الفرق بين 94 و99.
/// >
/// > الحقول، 55 طولاً، 4 تحت البطاقة وبينها 4: الدولة (تفتح نافذة الدول)،
/// > و«اختر من القائمة» (تفتح نافذة الأماكن)، والعنوان التفصيليّ، واسم
/// > العنوان. وحتّى يمتلئ النموذج كلُّه يبقى كلُّ حقلٍ أبيضَ بخطّه الرماديّ،
/// > مملوءاً كان أو لا. والحقل قيد الاستعمال يُزرِق خطَّه ويجعل عنوانه
/// > Medium. و«إضافة وحفظ» موجودٌ من البداية، رماديّاً مُطفأً. فإذا امتلأ
/// > النموذج صار بنفسجيّاً، وصار كلُّ حقلٍ `#FCFCFC` وذهبت الخطوط كلُّها،
/// > وخطُّ بطاقة الخريطة معها، كما في 99.
///
/// وفرقٌ عن الملفّ قرّره صاحبُ المشروع: الويب يقول «لا شيء يُستعلَم عنه:
/// الخريطةُ صورةٌ والأماكنُ قائمةٌ وهميّة»، وعندنا العكس — **خريطةٌ حقيقيّة**
/// في البطاقة، وحقلُ «اختر من القائمة» يعرض ما حلّه الدبّوس من محافظةٍ ومدينةٍ
/// ودولة. ونافذةُ المستويات الأربعة (`– 97`) مؤجَّلةٌ حتّى يصير لها خدمة.
class AddressFormPageV2 extends StatefulWidget {
  const AddressFormPageV2({
    super.key,
    required this.map,
    required this.located,
    required this.onLocate,
    required this.countryName,
    required this.countryFlag,
    required this.onPickCountry,
    required this.placeLine,
    required this.placeDone,
    required this.detail,
    required this.title,
    required this.onSave,
    this.countrySheet,
    this.countrySheetOpen = false,
    this.busy = false,
  });

  /// خريطتُنا الحقيقيّة داخل بطاقة الملفّ.
  final Widget map;

  /// وُضع الدبّوس: تكبر البطاقة والخريطة وتتبدّل الحبّة.
  final bool located;
  final VoidCallback onLocate;

  final String countryName;

  /// علامة الدولة 18، أو `null` فيُزاح الاسم إلى x 38 كما في الملفّ.
  final Widget? countryFlag;
  final VoidCallback onPickCountry;

  /// سطر «اختر من القائمة»: ما حلّه الدبّوس، أو أسماء المستويات تلميحاً.
  final String placeLine;
  final bool placeDone;

  final TextEditingController detail;
  final TextEditingController title;

  final VoidCallback onSave;

  /// نافذة الدول، تُرسم فوق الصفحة.
  final Widget? countrySheet;
  final bool countrySheetOpen;

  final bool busy;

  @override
  State<AddressFormPageV2> createState() => _AddressFormPageV2State();
}

class _AddressFormPageV2State extends State<AddressFormPageV2> {
  final FocusNode _detailFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();

  /// كم تكبر بطاقة الخريطة حين تُفتح: 186 − 121.
  static const double _mapGrowth = 65;

  /// حركة البطاقة والخريطة معاً — `GROW`.
  static const Duration _grow = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _detailFocus.addListener(_refresh);
    _titleFocus.addListener(_refresh);
    widget.detail.addListener(_refresh);
    widget.title.addListener(_refresh);
  }

  @override
  void dispose() {
    _detailFocus.removeListener(_refresh);
    _titleFocus.removeListener(_refresh);
    widget.detail.removeListener(_refresh);
    widget.title.removeListener(_refresh);
    _detailFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _complete =>
      widget.placeDone &&
      widget.detail.text.trim().isNotEmpty &&
      widget.title.text.trim().isNotEmpty;

  /// خطُّ بطاقة الخريطة يذهب لحظةَ يكتمل النموذج، ولو بقي حقلٌ مركَّزاً.
  /// ونافذةٌ مفتوحةٌ تُبقيه، كما في 95 و97.
  bool get _done => _complete && !widget.countrySheetOpen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        XdScreenPage(
          header: XdScreenHeader(
            crumb: (LocaleKeys.profile.tr(), LocaleKeys.address.tr()),
            crumbIcon: 'titleAddress',
            crumbIconW: 18,
            nudge: 1,
            onBack: () => Navigator.of(context).maybePop(),
            action: LocaleKeys.cancel.tr(),
            onAction: () => Navigator.of(context).maybePop(),
          ),
          footer: XdWideButton(
            label: LocaleKeys.add_save.tr(),
            disabled: !_complete,
            busy: widget.busy,
            onTap: widget.onSave,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              XdInfoBanner(
                text: LocaleKeys.entering_your_information_correctly.tr(),
              ),
              _mapCard(),
              _countryField(),
              _placeField(),
              XdField(
                mt: 4,
                label: LocaleKeys.detailed_address.tr(),
                editing: !_complete,
                inUse: _detailFocus.hasFocus,
                child: XdFieldInput(
                  controller: widget.detail,
                  focusNode: _detailFocus,
                  editing: true,
                  placeholder: LocaleKeys.street_address_building.tr(),
                ),
              ),
              XdField(
                mt: 4,
                label: LocaleKeys.address_title.tr(),
                editing: !_complete,
                inUse: _titleFocus.hasFocus,
                child: XdFieldInput(
                  controller: widget.title,
                  focusNode: _titleFocus,
                  editing: true,
                  placeholder: LocaleKeys.ex_home_my_office.tr(),
                ),
              ),
            ],
          ),
        ),
        if (widget.countrySheet != null) widget.countrySheet!,
      ],
    );
  }

  /// بطاقة الخريطة، 12 تحت الشريط. ارتفاعُها متحرّك، فتنزل الحقول تحتها معها.
  Widget _mapCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 12.h, start: XdRow.x.w),
      child: AnimatedContainer(
        duration: _grow,
        curve: XdTransition.ease,
        width: Xd.fill(XdRow.x),
        height: (widget.located ? 121 + _mapGrowth : 121).h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
          border: _done ? null : Border.all(color: XdColors.line, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // الخريطة على (12، 12)، 12 من جانبي البطاقة (382 في بطاقة 406).
            // ولا حشوة سفليّة: الملفّ يُعطي الخريطة هامشاً علويّاً وجانبين
            // فقط، والشرحُ تحتها يأتي بهامشه. و`EdgeInsets.all` كان يُضيف 12
            // أسفلها فيفيض ارتفاعُ البطاقة (121).
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: 12.h,
                start: 12.w,
                end: 12.w,
              ),
              child: AnimatedContainer(
                duration: _grow,
                curve: XdTransition.ease,
                height: (widget.located ? 162 : 79).h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(XdRow.radius.r),
                  border: Border.all(color: XdColors.line, width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: widget.map),
                    _pill(),
                    if (widget.located) _pin(),
                  ],
                ),
              ),
            ),
            // 11 Medium على خطّ الأساس 110 في البطاقة، من x 52: موسَّطٌ على
            // البطاقة في الملفّ، فيحفظ تلك المسافة عن المركز.
            if (!widget.located)
              Padding(
                padding: EdgeInsets.only(top: Xd.gapTo(12 + 79, 110, 11).h),
                child: SizedBox(
                  width: Xd.fill(XdRow.x) - 24.w,
                  child: XdText(
                    LocaleKeys.location_is_accurate.tr(),
                    size: 11,
                    weight: XdWeight.medium,
                    color: XdColors.label,
                    align: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 198 × 30 على (104، 37) في البطاقة، سوداء؛ ومُحدَّدةً 159 عرضاً على
  /// (124، 58) و`#4A31E7` بخطّ 1 `#388CFF`.
  Widget _pill() {
    final bool on = widget.located;
    return AnimatedPositionedDirectional(
      duration: _grow,
      curve: XdTransition.ease,
      start: ((on ? 124 : 104) - 12).w,
      top: ((on ? 58 : 37) - 12).h,
      child: XdTap(
        scale: 0.96,
        onTap: widget.onLocate,
        child: AnimatedContainer(
          duration: _grow,
          curve: XdTransition.ease,
          width: (on ? 159 : 198).w,
          height: 30.h,
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 11.5.w),
          decoration: BoxDecoration(
            color: on ? XdColors.purple : XdColors.ink,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: on ? XdColors.blue : XdColors.line,
              width: on ? 1 : 0.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x29000000),
                offset: Offset(0, 2.h),
                blurRadius: 2.r,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: XdText(
                  on
                      ? LocaleKeys.your_location_on_map.tr()
                      : LocaleKeys.locate_your_location_on_map.tr(),
                  size: 11,
                  weight: XdWeight.medium,
                  color: const Color(0xFFF4F4F4),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 15، على 11.5 من طرف الحبّة الأيمن.
              const XdSvg('navigation', folder: kXdSharedSvg, w: 15),
            ],
          ),
        ),
      ),
    );
  }

  /// الدبّوس على (188.5، 90.5) في البطاقة: 2.5 تحت الحبّة.
  Widget _pin() {
    return PositionedDirectional(
      start: (188.5 - 12).w,
      top: (90.5 - 12).h,
      child: const XdSvg('pin', folder: kXdSharedSvg, w: 28.96, h: 37.53),
    );
  }

  /// علامةُ الدولة 18 على (12، 29)، والاسم من x 38 على خطّ الأساس 43.
  Widget _countryField() {
    return XdField(
      mt: 4,
      label: LocaleKeys.country_region.tr(),
      editing: !_complete,
      inUse: widget.countrySheetOpen,
      onTap: widget.onPickCountry,
      child: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.countryFlag != null) widget.countryFlag!,
            SizedBox(width: (widget.countryFlag != null ? 8 : 26).w),
            Flexible(
              child: XdText(
                widget.countryName,
                size: 14,
                weight: XdWeight.medium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeField() {
    return XdField(
      mt: 4,
      label: LocaleKeys.select_from_list.tr(),
      editing: !_complete,
      child: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            XdSvg(
              widget.placeDone ? 'radioOn' : 'radio',
              folder: kXdSharedSvg,
              w: 18,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: XdText(
                widget.placeLine,
                size: 14,
                color: widget.placeDone ? XdColors.ink : XdColors.placeholder,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نافذة الدول — `Home Page – 95`.
///
/// > النافذة من y 539: «اختر» (30 Bold) على خطّ الأساس 593، و«الدولة |
/// > المنطقة» (16 Medium) على 629، ثمّ صفوفٌ 406 × 60 من y 645 بينها 4:
/// > علامةٌ 30 على 12، والاسم من x 54.
///
/// والدول من قائمتنا المسموحة لا من الأربع الوهميّة في الويب.
class CountrySheetV2 extends StatelessWidget {
  const CountrySheetV2({
    super.key,
    required this.open,
    required this.countries,
    required this.value,
    required this.onPick,
    required this.onClose,
  });

  final bool open;

  /// كلُّ دولةٍ: رمزُها ISO واسمُها وعلامتُها.
  final List<({String iso, String name, Widget flag})> countries;

  /// رمز الدولة المختارة.
  final String? value;

  final void Function(String iso) onPick;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return XdSheetLayer(
      open: open,
      y: 539,
      onClose: onClose,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // الملفّ يُوسّط السطرين بالعين: «اختر» بنقطةٍ يميناً، والثاني
            // بنقطةٍ يساراً.
            _centred(
              LocaleKeys.select.tr(),
              size: 30,
              weight: XdWeight.bold,
              nudge: 1,
              top: Xd.gapTo(539 + 13, 593, 30),
            ),
            _centred(
              LocaleKeys.country_region.tr(),
              size: 16,
              weight: XdWeight.medium,
              nudge: -1,
              top: Xd.gapTo(Xd.textBottom(593, 30), 629, 16),
            ),
            for (int i = 0; i < countries.length; i++)
              _row(countries[i], i == 0),
          ],
        ),
      ),
    );
  }

  Widget _centred(
    String text, {
    required double size,
    required XdWeight weight,
    required double nudge,
    required double top,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top.h,
        left: nudge > 0 ? (nudge * 2).w : 0,
        right: nudge < 0 ? (-nudge * 2).w : 0,
      ),
      child: SizedBox(
        width: 1.sw,
        child: XdText(
          text,
          size: size,
          weight: weight,
          align: TextAlign.center,
        ),
      ),
    );
  }

  Widget _row(({String iso, String name, Widget flag}) c, bool first) {
    final bool on = c.iso == value;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (first ? 645 - Xd.textBottom(629, 16) : 4).h,
        start: XdRow.x.w,
      ),
      child: XdTap(
        scale: 0.98,
        onTap: () => onPick(c.iso),
        child: Container(
          width: Xd.fill(XdRow.x),
          height: 60.h,
          decoration: BoxDecoration(
            color: on ? XdColors.field : XdColors.card,
            borderRadius: BorderRadius.circular(XdRow.radius.r),
            border: on
                ? Border.all(color: const Color(0xFF402CDD), width: 0.5)
                : null,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 12.w),
              c.flag,
              SizedBox(width: (54 - 12 - 30).w),
              Expanded(
                child: XdText(
                  c.name,
                  size: 14,
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
