import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// عنوانٌ كما تعرضه الشاشة — ما تحتاجه الودجة من نموذجنا، لا أكثر.
class AddressRowV2 {
  const AddressRowV2({
    required this.id,
    required this.title,
    required this.area,
    required this.detail,
  });

  final String id;

  /// اسم العنوان، بجانبه علامةُ خريطةٍ 15.
  final String title;

  /// سطر المنطقة: الشارع والبلدة عاديّان، والبقيّة Medium —
  /// «Cendere | Ayazağa | Sariyer | İstanbul | Turkiye».
  final List<String> area;

  final String detail;
}

/// العناوين — ألواح XD `Home Page – 96` (فارغة) و`– 98` (القائمة) و`– 100`
/// (سؤال الحذف).
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/AddressListScreen.tsx`:
///
/// > فارغةً: علامةُ المساعدة الرماديّة وسطران رماديّان موسَّطان على
/// > y 432 .. 492، وبطاقةُ «لماذا تُضيف عنواناً؟» على y 700 (وتُغلق)، وزرُّ
/// > «أضف عنوان الشحن» الداكن (`#404040`).
/// >
/// > القائمة: بطاقاتٌ 406 × 79 من y 160 (12 تحت الشريط)، بينها 4، لونها
/// > `#FCFCFC`. العنوان 12 Medium وعلامةُ خريطةٍ 15 بعده بـ12؛ ثمّ سطر
/// > المنطقة (12، وآخرُ ثلاثة أجزاءٍ منه Medium)؛ ثمّ سطر التفصيل؛
/// > وعلامتا التعديل والحذف في أعلى اليمين.
/// >
/// > الحذف: الشاشة كلّها تُعتِم إلى `#1D1D1D` بـ90%، وسلّةٌ بيضاء كبيرة على
/// > (190، 380)، و«أتحذف العنوان أدناه؟»، والبطاقة ثانيةً بخطوطٍ بيضاء،
/// > وإكسٌ بيضاء في أعلى اليمين، وزرٌّ أبيض «نعم، احذف».
class AddressListPageV2 extends StatefulWidget {
  const AddressListPageV2({
    super.key,
    required this.addresses,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AddressRowV2> addresses;

  /// عنوانٌ جديد — `open(null)` في الويب.
  final VoidCallback onAdd;

  /// تعديل عنوانٍ قائم — `open(address.id)`.
  final void Function(AddressRowV2 address) onEdit;

  final void Function(AddressRowV2 address) onDelete;

  @override
  State<AddressListPageV2> createState() => _AddressListPageV2State();
}

class _AddressListPageV2State extends State<AddressListPageV2> {
  bool _showWhy = true;
  AddressRowV2? _deleting;

  /// ارتفاع بطاقة العنوان، والفراغ بينها وبين تاليتها.
  static const double _cardH = 79;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final bool empty = widget.addresses.isEmpty;
    return Stack(
      children: <Widget>[
        XdScreenPage(
          header: XdScreenHeader(
            crumb: (LocaleKeys.profile.tr(), LocaleKeys.address.tr()),
            crumbIcon: 'titleAddress',
            crumbIconW: 18,
            // الملفّ يُوسّط هذا العنوان بالعين، أيمنَ بنقطة.
            nudge: 1,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 700 .. 824 في الملفّ، 12 فوق الزرّ.
              if (empty && _showWhy)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: XdWhyCard(
                    onClose: () => setState(() => _showWhy = false),
                  ),
                ),
              XdWideButton(
                label: LocaleKeys.add_shipping_address.tr(),
                fill: XdColors.inkSoft,
                onTap: widget.onAdd,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              XdInfoBanner(
                text: LocaleKeys.entering_your_information_correctly.tr(),
              ),
              for (int i = 0; i < widget.addresses.length; i++)
                _card(widget.addresses[i], i),
              if (empty) const _EmptyAddressesV2(),
            ],
          ),
        ),
        if (_deleting != null)
          _DeleteQuestionV2(
            address: _deleting!,
            onClose: () => setState(() => _deleting = null),
            onDelete: () {
              final AddressRowV2 gone = _deleting!;
              setState(() => _deleting = null);
              widget.onDelete(gone);
            },
          ),
      ],
    );
  }

  Widget _card(AddressRowV2 address, int i) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: (i == 0 ? 12 : _gap).h,
        start: XdRow.x.w,
      ),
      child: Container(
        width: Xd.fill(XdRow.x),
        height: _cardH.h,
        decoration: BoxDecoration(
          color: XdColors.card,
          borderRadius: BorderRadius.circular(XdRow.radius.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: AddressLinesV2(address: address)),
            // العلامتان على (356، 172) و(383، 172)، كلٌّ في هدفٍ 31 ينزل 4.
            // والسطور تمرّ تحتهما إلى 12 من حافّة البطاقة اليمنى (394 من
            // 406)، فيتراجع الهدفان فوق نهايتها. وهدفُ الحذف ينتهي 4 عن
            // الحافّة اليمنى على كلّ عرض.
            _mark('edit', LocaleKeys.edit.tr(), () => widget.onEdit(address)),
            _mark(
              'trash',
              LocaleKeys.delete.tr(),
              () => setState(() => _deleting = address),
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }

  Widget _mark(String icon, String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Semantics(
        button: true,
        label: label,
        child: XdTap(
          scale: 0.9,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: XdSvg(icon, folder: kXdSharedSvg, w: 15),
          ),
        ),
      ),
    );
  }
}

/// العنوان وعلامتُه، وسطر المنطقة وسطر التفصيل — تتقاسمهما البطاقةُ وسؤالُ
/// الحذف.
///
/// في البطاقة: صفُّ العنوان (15 طولاً) ينزل 12، والسطران على خطّي الأساس +45
/// و+64، وكلُّها 12 من الداخل و12 عن حافّة البطاقة اليمنى (382 في بطاقة 406).
class AddressLinesV2 extends StatelessWidget {
  const AddressLinesV2({
    super.key,
    required this.address,
    this.color = XdColors.ink,
    this.mark = true,
  });

  final AddressRowV2 address;
  final Color color;

  /// علامةُ الخريطة. والملفّ يُسقطها في سؤال الحذف.
  final bool mark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: SizedBox(
              height: 15.h,
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: XdText(
                      address.title,
                      size: 12,
                      weight: XdWeight.medium,
                      color: color,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (mark) ...<Widget>[
                    SizedBox(width: 12.w),
                    const XdSvg('mapTiny', folder: kXdSharedSvg, w: 15),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Xd.gapTo(12 + 15, 45, 12).h),
            child: _areaLine(),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(Xd.textBottom(45, 12), 64, 12).h,
            ),
            child: XdText(
              address.detail,
              size: 12,
              color: color,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// الشارع والبلدة عاديّان، والبقيّة Medium.
  Widget _areaLine() {
    final List<String> a = address.area;
    final String plain = a.take(2).join(' | ');
    final String strong = a.skip(2).join(' | ');
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: plain.isEmpty ? '' : '$plain | ',
            style: xdTextStyle(size: 12, color: color),
          ),
          TextSpan(
            text: strong,
            style: xdTextStyle(size: 12, weight: XdWeight.medium, color: color),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// القائمة الفارغة: علامةُ المساعدة الرماديّة 19 موسَّطةً على y 432.5،
/// والسطران الرماديّان على خطّي الأساس 472 و492.
class _EmptyAddressesV2 extends StatelessWidget {
  const _EmptyAddressesV2();

  /// حيث تُوضع علامةُ الكتلة الفارغة، والشريطُ ينتهي على 148.
  static const double _markY = 432.5;
  static const double _from = 148;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: (_markY - _from).h),
            child: const XdSvg(
              'helpBig',
              folder: kXdSharedSvg,
              w: 18.99,
              h: 19,
            ),
          ),
          // الملفّ يبدأ هذا السطر على x 135 موسَّطاً. والفراغان 7.5 و6
          // بخطّ الأساس — بكسلات الملفّ نفسها.
          Padding(
            padding: EdgeInsets.only(top: Xd.gapTo(451.5, 472, 13).h),
            child: XdText(
              LocaleKeys.your_address_list_is_empty.tr(),
              size: 13,
              weight: XdWeight.medium,
              color: XdColors.hint,
              align: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Xd.gapTo(Xd.textBottom(472, 13), 492, 11).h,
            ),
            child: XdText(
              LocaleKeys.you_can_also_create_multiple_addresses.tr(),
              size: 11,
              color: XdColors.hint,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// سؤال الحذف، فوق الشاشة كلّها: إكسٌ بيضاء على (384.5، 59.7) في هدفٍ 36،
/// وسلّةٌ 50 موسَّطةٌ على y 380، والسؤال على خطّ الأساس 456، والبطاقة ثانيةً
/// بخطوطٍ بيضاء على y 472.
class _DeleteQuestionV2 extends StatelessWidget {
  const _DeleteQuestionV2({
    required this.address,
    required this.onClose,
    required this.onDelete,
  });

  final AddressRowV2 address;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: XdColors.backdrop,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    // 59.7 - 10 (حشوة الهدف) - 50 (شريط الحالة) = -0.3،
                    // و`Padding` يرفض السالب. وثلاثةُ أعشارٍ لا تُرى.
                    end: (Xd.designW - (384.5 - 10 + 36)).w,
                  ),
                  child: Semantics(
                    button: true,
                    label: LocaleKeys.close.tr(),
                    child: XdTap(
                      scale: 0.9,
                      onTap: onClose,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: const XdSvg(
                          'closeWhite',
                          folder: kXdSharedSvg,
                          w: 15.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.only(top: (380 - (59.7 - 10 + 36)).h),
                  child: const XdSvg('trashBig', folder: kXdSharedSvg, w: 50),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: Xd.gapTo(430, 456, 14).h),
                child: SizedBox(
                  width: 1.sw,
                  child: XdText(
                    LocaleKeys.delete_below_address.tr(),
                    size: 14,
                    color: XdColors.white,
                    align: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: (472 - Xd.textBottom(456, 14)).h,
                  start: XdRow.x.w,
                ),
                child: Container(
                  width: Xd.fill(XdRow.x),
                  height: 79.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(XdRow.radius.r),
                    border: Border.all(color: XdColors.white, width: 0.5),
                  ),
                  // السطور نفسها، بيضاء؛ والملفّ يُسقط علامة الخريطة هنا.
                  child: AddressLinesV2(
                    address: address,
                    color: XdColors.white,
                    mark: false,
                  ),
                ),
              ),
              const Spacer(),
              XdWideButton(
                label: LocaleKeys.sure_delete.tr(),
                fill: XdColors.card,
                color: XdColors.ink,
                weight: XdWeight.medium,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
