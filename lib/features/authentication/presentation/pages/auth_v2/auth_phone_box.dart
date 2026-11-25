/// حقلُ الهاتف — نقلٌ لـ
/// `web_design/components/Login/Enhanced/ui/RdbPhoneInput.tsx`.
///
/// > صندوقٌ 390 × 60 بخطّه المتقطّع، وكلُّ ما فيه على x من الملفّ مقيسٍ من
/// > حافّة الصندوق اليسرى: العلمُ 20، وصورةُ الهاتف 19.7، و«+» 52، والرقمُ
/// > 65، وسهمُ الإرسال 20 عن اليمين. وصفٌّ بفراغاتٍ لا يُعيدها، لأنّ فراغات
/// > الملفّ غيرُ متساويةٍ ولا تخرج من عرض النصّ.
/// >
/// > ونصُّ 16 على 20 من أعلى الصندوق: صندوقُ سطرِه 20، فيحلّ خطُّ أساسه على
/// > 36 — حيث يضعه XD.
/// >
/// > والعلمُ **يركب الحافّة العليا**: 6.5 فوقها، 20 × 13.
/// >
/// > ولونُ الخطّ `#388CFF` متى كان الحقلُ مستعمَلاً أو الرقمُ صالحاً، و
/// > `#5D5C5D` فيما سوى ذلك.
library;

import 'package:country_flags/country_flags.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';

class AuthPhoneBox extends StatefulWidget {
  const AuthPhoneBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onSend,
    required this.dialCode,
    required this.flag,
    required this.hint,
    this.valid = false,
    this.busy = false,
  });

  /// الرقمُ المحلّيُّ بلا مفتاح الدولة.
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  /// مفتاحُ الدولة بلا «+».
  final String dialCode;

  /// رمزُ الدولة من حرفين، لرسم علمها.
  final String flag;

  final String hint;

  /// الرقمُ مكتملٌ صالح.
  final bool valid;

  /// الإرسالُ جارٍ، فلا يُضغط السهم.
  final bool busy;

  /// مواضعُ ما في الصندوق، من حافّته اليسرى.
  static const double flagLeft = 20;
  static const double flagTop = -6.5;
  static const double flagW = 20;
  static const double flagH = 13;
  static const double iconLeft = 19.7;
  static const double iconW = 20.9;
  static const double iconH = 24.3;
  static const double plusLeft = 52;
  static const double numberLeft = 65;
  static const double sendRight = 20;
  static const double sendSize = 20;
  static const double lineTop = 20;

  @override
  State<AuthPhoneBox> createState() => _AuthPhoneBoxState();
}

class _AuthPhoneBoxState extends State<AuthPhoneBox> {
  late final TextEditingController _text = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _lit => _focus.hasFocus || widget.valid;

  @override
  Widget build(BuildContext context) {
    final bool typed = widget.value.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focus.requestFocus,
      child: SizedBox(
        width: Xd.fill(AuthXd.boxLeft),
        height: AuthXd.boxHeight.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: DottedBorder(
                padding: EdgeInsets.zero,
                borderType: BorderType.RRect,
                strokeCap: StrokeCap.round,
                strokeWidth: 0.5,
                dashPattern: const <double>[3, 3],
                radius: Radius.circular(AuthXd.boxRadius.r),
                color: _lit ? AuthColors.termsLink : AuthColors.dash,
                child: const SizedBox.expand(),
              ),
            ),
            // صورةُ الهاتف، موسَّطةً رأسياً في الصندوق، وتخبو ما دام فارغاً.
            PositionedDirectional(
              start: AuthPhoneBox.iconLeft.w,
              top: ((AuthXd.boxHeight - AuthPhoneBox.iconH) / 2).h,
              child: Opacity(
                opacity: typed ? 1 : 0.5,
                child: SvgPicture.asset(
                  'assets/svg/$kAuthSvg/phone.svg',
                  width: AuthPhoneBox.iconW.w,
                  height: AuthPhoneBox.iconH.w,
                ),
              ),
            ),
            // العلمُ يركب الحافّة العليا.
            PositionedDirectional(
              start: AuthPhoneBox.flagLeft.w,
              top: AuthPhoneBox.flagTop.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: SizedBox(
                  width: AuthPhoneBox.flagW.w,
                  height: AuthPhoneBox.flagH.h,
                  child: _flag(),
                ),
              ),
            ),
            PositionedDirectional(
              start: AuthPhoneBox.plusLeft.w,
              top: AuthPhoneBox.lineTop.h,
              child: XdText(
                '+${widget.dialCode}',
                size: 16,
                weight: XdWeight.medium,
                color: typed ? XdColors.ink : XdColors.grey,
              ),
            ),
            PositionedDirectional(
              start: AuthPhoneBox.numberLeft.w,
              top: AuthPhoneBox.lineTop.h,
              end: (AuthPhoneBox.sendRight + AuthPhoneBox.sendSize + 5).w,
              child: SizedBox(
                height: Xd.lineBox(16).h,
                child: TextField(
                  controller: _text,
                  focusNode: _focus,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSend(),
                  cursorColor: XdColors.ink,
                  cursorWidth: 1,
                  style: xdTextStyle(size: 16, weight: XdWeight.medium),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.hint,
                    hintStyle: xdTextStyle(size: 16, color: XdColors.hint),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: AuthPhoneBox.sendRight.w,
              top: AuthPhoneBox.lineTop.h,
              child: Opacity(
                opacity: widget.busy ? 0.5 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.busy ? null : widget.onSend,
                  child: SvgPicture.asset(
                    'assets/svg/$kAuthSvg/arrow-right.svg',
                    width: AuthPhoneBox.sendSize.w,
                    height: AuthPhoneBox.sendSize.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// علمُ الدولة، بالحزمة التي يرسم بها التطبيقُ أعلامَه في بقيّة شاشاته.
  Widget _flag() => CountryFlag.fromCountryCode(
    widget.flag,
    theme: ImageTheme(
      width: AuthPhoneBox.flagW.w,
      height: AuthPhoneBox.flagH.h,
      shape: RoundedRectangle(2.r),
    ),
  );
}
