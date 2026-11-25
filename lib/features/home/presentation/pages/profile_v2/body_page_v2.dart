import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// قياسات الجسم — لوح XD `Home Page – 93`.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/BodyScreen.tsx`:
///
/// > الشريط، ثمّ ثلاثة حقولٍ 406 × 55 على y 160 و221 و282: 12 تحت الشريط،
/// > ثمّ 6 بينها (لا 4 كما في المعلومات الشخصيّة — فراغ الملفّ نفسه).
/// > والتلميحان «000 CM» و«000 KG»؛ والملفّ يكتب «000 KG» تحت مقاس القدم
/// > أيضاً، وأُبقي كما رُسم.
/// >
/// > وللملفّ هذه الحال وحدها: لا زرّ حفظٍ ولا شيء في الشريط العلويّ. فلا
/// > يُضاف شيء — وما يكتبه المتسوّق يبقى كما كُتب.
///
/// ولأنّ الويب يكتب في كائنه مع كلّ حرف، ولا زرّ للحفظ، يُرسَل الحفظ عندنا
/// **عند مغادرة الشاشة** إن تغيّر شيء: لا زرّ يُضاف إلى اللوح، ولا طلبَ مع
/// كلّ ضغطة.
///
/// ومقاسُ القدم بلا حقلٍ في نموذجنا — `UpdateProfileEvent` يحمل `tall`
/// و`weight` لا غير — فيبقى تصميماً حتّى يصير له حقل.
class BodyPageV2 extends StatefulWidget {
  const BodyPageV2({
    super.key,
    required this.height,
    required this.weight,
    required this.foot,
    required this.onSave,
  });

  final String height;
  final String weight;

  /// مقاس القدم. بلا حقلٍ في الخادم بعد.
  final String foot;

  /// يُرسَل عند المغادرة إن تغيّر شيء.
  final void Function({required String height, required String weight}) onSave;

  @override
  State<BodyPageV2> createState() => _BodyPageV2State();
}

class _BodyPageV2State extends State<BodyPageV2> {
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _foot;
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _footFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _height = TextEditingController(text: widget.height);
    _weight = TextEditingController(text: widget.weight);
    _foot = TextEditingController(text: widget.foot);
    for (final FocusNode f in <FocusNode>[
      _heightFocus,
      _weightFocus,
      _footFocus,
    ]) {
      f.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final FocusNode f in <FocusNode>[
      _heightFocus,
      _weightFocus,
      _footFocus,
    ]) {
      f.removeListener(_refresh);
      f.dispose();
    }
    _height.dispose();
    _weight.dispose();
    _foot.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _saveIfChanged() {
    if (_height.text == widget.height && _weight.text == widget.weight) return;
    widget.onSave(height: _height.text, weight: _weight.text);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) _saveIfChanged();
      },
      child: XdScreenPage(
        header: XdScreenHeader(
          crumb: (LocaleKeys.profile.tr(), LocaleKeys.body_measurements.tr()),
          crumbIcon: 'titleBody',
          crumbIconW: 18,
          // الملفّ يُوسّط هذا العنوان بالعين، أيمنَ بنقطتين.
          nudge: 2,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            XdInfoBanner(
              text: LocaleKeys.entering_your_information_correctly.tr(),
            ),
            _field(
              mt: 12,
              label: LocaleKeys.how_tall_are_you.tr(),
              placeholder: LocaleKeys.placeholder_cm.tr(),
              controller: _height,
              focus: _heightFocus,
            ),
            _field(
              mt: 6,
              label: LocaleKeys.what_is_your_weight.tr(),
              placeholder: LocaleKeys.placeholder_kg.tr(),
              controller: _weight,
              focus: _weightFocus,
            ),
            _field(
              mt: 6,
              label: LocaleKeys.what_is_your_foot_size.tr(),
              // الملفّ يكتب «000 KG» تحت مقاس القدم أيضاً — كما رُسم.
              placeholder: LocaleKeys.placeholder_kg.tr(),
              controller: _foot,
              focus: _footFocus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required double mt,
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required FocusNode focus,
  }) {
    return XdField(
      mt: mt,
      label: label,
      // الحقول كلّها قابلةٌ للتحرير دائماً: لوحٌ واحدٌ لا حالَ قراءةٍ فيه.
      editing: true,
      inUse: focus.hasFocus,
      child: XdFieldInput(
        controller: controller,
        focusNode: focus,
        editing: true,
        placeholder: placeholder,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // أرقامٌ ونقطةٌ عشريّة، وخمسةُ محارف — كما يُنقّي الويب المُدخَل.
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          LengthLimitingTextInputFormatter(5),
        ],
      ),
    );
  }
}
