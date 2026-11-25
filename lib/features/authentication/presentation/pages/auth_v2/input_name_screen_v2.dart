/// «أدخل اسمك» — نقلٌ لـ`web_design/NewLoginDesign/NewInputNameScreen.tsx`.
///
/// > أرضيّةٌ خضراءُ باهتة `#F4FFF4`، والشعارُ على 116 بنقطتين وحلقةٍ خضراوين.
/// >   - «أدخل اسمك !» 30 Bold على 288؛
/// >   - «خطوةٌ أخيرةٌ وتمتّع بخدماتنا» 16 Medium على 338؛
/// >   - «لأمانٍ أكبرَ وحمايةِ أموالك» 12 على 366؛
/// >   - حقلُ الاسم على 503: صندوقٌ أبيضُ بخطٍّ متقطّعٍ يُضيء `#388CFF` متى
/// >     دخلته الكتابة، و`#8D8D8D` فيما سوى ذلك. والنصُّ 16 على 20 من أعلاه،
/// >     20 من الجانبين، والسهمُ 20 عن اليمين.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'auth_design.dart';
import 'auth_logo.dart';
import 'auth_parts.dart';

class InputNameScreenV2 extends StatefulWidget {
  const InputNameScreenV2({
    super.key,
    required this.name,
    required this.onName,
    required this.onSubmit,
    this.onClose,
    this.busy = false,
  });

  final String name;
  final ValueChanged<String> onName;
  final VoidCallback onSubmit;
  final VoidCallback? onClose;
  final bool busy;

  /// أرضيّةُ اللوح، ولونُ شعاره.
  static const Color bg = Color(0xFFF4FFF4);
  static const AuthBadgeTone tone = AuthBadgeTone.green;

  /// حشوةُ الحقل من جانبيه، وموضعُ سطره.
  static const double inset = 20;
  static const double lineTop = 20;
  static const double arrow = 20;

  @override
  State<InputNameScreenV2> createState() => _InputNameScreenV2State();
}

class _InputNameScreenV2State extends State<InputNameScreenV2> {
  late final TextEditingController _text = TextEditingController(
    text: widget.name,
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

  @override
  Widget build(BuildContext context) {
    return AuthBoard(
      bg: InputNameScreenV2.bg,
      children: <Widget>[
        if (widget.onClose != null)
          AuthCorner(
            icon: 'close',
            size: AuthXd.controlCloseSize,
            onTap: widget.onClose!,
            semantics: LocaleKeys.close.tr(),
          ),
        Positioned(
          top: AuthXd.headTitle.h,
          left: AuthXd.textLeft.w,
          child: XdText(
            LocaleKeys.enter_your_name_excl.tr(),
            size: 30,
            weight: XdWeight.bold,
          ),
        ),
        Positioned(
          top: AuthXd.headLine2.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: XdText(
            LocaleKeys.last_step.tr(),
            size: 16,
            weight: XdWeight.medium,
            maxLines: 2,
          ),
        ),
        Positioned(
          top: AuthXd.headLine3.h,
          left: AuthXd.textLeft.w,
          right: AuthXd.boxLeft.w,
          child: XdText(
            LocaleKeys.ensure_greater_security_and_protect_funds.tr(),
            size: 12,
            maxLines: 2,
          ),
        ),
        Positioned(
          top: AuthXd.boxTop.h,
          left: AuthXd.boxLeft.w,
          child: _field(),
        ),
      ],
    );
  }

  Widget _field() {
    return SizedBox(
      width: Xd.fill(AuthXd.boxLeft),
      height: AuthXd.boxHeight.h,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DottedBorder(
              padding: EdgeInsets.zero,
              borderType: BorderType.RRect,
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              dashPattern: const <double>[3, 3],
              radius: Radius.circular(AuthXd.boxRadius.r),
              color: _focus.hasFocus ? AuthColors.termsLink : XdColors.grey,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AuthXd.boxRadius.r),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          PositionedDirectional(
            start: InputNameScreenV2.inset.w,
            top: InputNameScreenV2.lineTop.h,
            end: (InputNameScreenV2.inset + 25).w,
            child: SizedBox(
              height: Xd.lineBox(16).h,
              child: TextField(
                controller: _text,
                focusNode: _focus,
                textCapitalization: TextCapitalization.words,
                onChanged: widget.onName,
                onSubmitted: (_) => widget.onSubmit(),
                cursorColor: XdColors.ink,
                cursorWidth: 1,
                style: xdTextStyle(size: 16),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: LocaleKeys.enter_your_name_exact_id.tr(),
                  hintStyle: xdTextStyle(size: 16, color: XdColors.hint),
                ),
              ),
            ),
          ),
          if (widget.name.trim().isNotEmpty)
            PositionedDirectional(
              end: InputNameScreenV2.inset.w,
              top: InputNameScreenV2.lineTop.h,
              child: Opacity(
                opacity: widget.busy ? 0.5 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.busy ? null : widget.onSubmit,
                  child: SvgPicture.asset(
                    'assets/svg/$kAuthSvg/arrow-right.svg',
                    width: InputNameScreenV2.arrow.w,
                    height: InputNameScreenV2.arrow.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
