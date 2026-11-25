/// صناديقُ رمز التحقّق الستّة — نقلٌ لـ
/// `web_design/components/Login/Enhanced/ui/RdbPinInputs.tsx` كما يستعملها
/// طلبُ السحب (`Home Page – 101`).
///
/// > ستّةُ صناديقَ 60 × 60 بينها 6 بزاوية 15. و6 × 60 + 5 × 6 = 390، فالصفُّ
/// > يمتدّ من x 20 إلى 410 كبقيّة العناصر العريضة.
/// >
/// > وحالُ الصندوق تبدّل لونَه وخطَّه (`boxStyle`):
/// >   - رمزٌ صحيح: `#FCFFFC` بخطٍّ `#78D97F` متّصل؛
/// >   - رمزٌ خطأ: أبيضُ بخطٍّ `#FF5F61` متقطّع؛
/// >   - انتهت مدّتُه: `#FCFCFC` بخطٍّ `#FDCA57` متقطّع؛
/// >   - فيه رقم: أبيضُ بخطٍّ `#4D84FF` متّصل؛
/// >   - موضعُ الكتابة: أبيضُ بخطٍّ `#4D84FF` متقطّع؛
/// >   - غيرُ ذلك: `#FCFCFC` بخطٍّ `#C3C3C3` متقطّع.
/// > وكلُّ خطٍّ في التصميم 0.5 بتقطيعِ «3 3».
///
/// والرقمُ يُكتب بلوحة أرقام الهاتف (`NATIVE_WALLET_KEYBOARD`)، فحقلٌ واحدٌ
/// خفيٌّ يأخذ الكتابةَ وتُرسم الأرقامُ في الصناديق — كما يفعل الويب حين
/// تُغلَق لوحتُه الخاصّة.
library;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';

import 'wallet_cash_out_design.dart';

/// حالُ الصفّ كما يراه المتّصل.
enum WalletPinState { typing, valid, invalid, expired }

class WalletPinBoxes extends StatefulWidget {
  const WalletPinBoxes({
    super.key,
    required this.onComplete,
    this.state = WalletPinState.typing,
    this.autoFocus = true,
  });

  /// تمَّ إدخالُ ستّة أرقام.
  final ValueChanged<String> onComplete;

  final WalletPinState state;
  final bool autoFocus;

  @override
  State<WalletPinBoxes> createState() => _WalletPinBoxesState();
}

class _WalletPinBoxesState extends State<WalletPinBoxes> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // موضعُ الكتابة يُرسم بخطٍّ أزرق، فيُعاد الرسمُ متى دخلت الكتابةُ أو خرجت.
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.autoFocus) {
      // 300 كما في الويب: الشاشةُ تكون قد استقرّت.
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _pin => _text.text;

  void _changed(String value) {
    setState(() {});
    if (value.length == 6) {
      _focus.unfocus();
      widget.onComplete(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.state == WalletPinState.valid
          ? null
          : () => _focus.requestFocus(),
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < 6; i++) ...<Widget>[
                if (i > 0) SizedBox(width: CashOutDesign.pinGap.w),
                _box(i),
              ],
            ],
          ),
          // الحقلُ الذي يأخذ الكتابة، خفيٌّ فوق الصفّ.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _text,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: widget.state != WalletPinState.valid,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: _changed,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صندوقٌ واحد. وموضعُ الكتابة هو أوّلُ صندوقٍ فارغ.
  Widget _box(int i) {
    final bool has = i < _pin.length;
    final bool at = i == _pin.length && _focus.hasFocus;
    final (Color fill, Color stroke, bool solid) look = switch (widget.state) {
      WalletPinState.valid => (
        const Color(0xFFFCFFFC),
        const Color(0xFF78D97F),
        true,
      ),
      WalletPinState.invalid => (XdColors.white, XdColors.red, false),
      WalletPinState.expired => (XdColors.card, const Color(0xFFFDCA57), false),
      WalletPinState.typing when has => (
        XdColors.white,
        const Color(0xFF4D84FF),
        true,
      ),
      WalletPinState.typing when at => (
        XdColors.white,
        const Color(0xFF4D84FF),
        false,
      ),
      WalletPinState.typing => (XdColors.card, XdColors.hint, false),
    };

    final Widget body = Container(
      width: CashOutDesign.pinBox.w,
      height: CashOutDesign.pinBox.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: look.$1,
        borderRadius: BorderRadius.circular(CashOutDesign.pinRadius.r),
      ),
      // الخطُّ المتّصل على الحافّة لا يأكل من الصندوق.
      foregroundDecoration: look.$3
          ? BoxDecoration(
              border: Border.all(color: look.$2, width: 0.5),
              borderRadius: BorderRadius.circular(CashOutDesign.pinRadius.r),
            )
          : null,
      // الصندوقُ الفارغ فارغٌ: لا نقطةَ وامضةً في التصميم.
      child: has
          ? XdText(_pin[i], size: 16, weight: XdWeight.medium)
          : const SizedBox.shrink(),
    );

    if (look.$3) return body;
    return SizedBox(
      width: CashOutDesign.pinBox.w,
      height: CashOutDesign.pinBox.w,
      child: DottedBorder(
        padding: EdgeInsets.zero,
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        dashPattern: const <double>[3, 3],
        radius: Radius.circular(CashOutDesign.pinRadius.r),
        color: look.$2,
        child: body,
      ),
    );
  }
}
