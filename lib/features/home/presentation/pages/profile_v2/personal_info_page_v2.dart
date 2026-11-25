import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/constant/design/xd_design.dart';
import 'package:trydos/common/constant/design/xd_svg.dart';
import 'package:trydos/common/constant/design/xd_ui.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// الجنس كما يرسله الخادم: 1 ذكر، 2 أنثى، 3 آخر.
enum PersonalGenderV2 {
  man('1'),
  women('2'),
  other('3');

  const PersonalGenderV2(this.code);

  final String code;

  /// من اسم الحقل القادم من الخادم (`Man` / `Women` / `Other`).
  static PersonalGenderV2? fromName(String? name) {
    if (name == null) return null;
    if (name == 'Man') return PersonalGenderV2.man;
    if (name.startsWith('Wom')) return PersonalGenderV2.women;
    if (name.startsWith('Other')) return PersonalGenderV2.other;
    return null;
  }
}

/// المعلومات الشخصيّة — ألواح XD `Home Page – 88` إلى `– 92`.
///
/// نقلٌ لـ`web_design/components/DemoApp1/screens/PersonalInfoScreen.tsx`:
///
/// >   92  للقراءة — وعليه تفتح الشاشة: حقولٌ `#FCFCFC` بلا خطّ، و«تعديل»
/// >       في أعلى اليمين؛
/// >   88  بعد «تعديل»: حقولٌ بيضاء بخطّ 0.5 `#D3D3D3`؛
/// >   89  أثناء الكتابة: «إلغاء» في أعلى اليمين؛ وبريدٌ لم يُوثَّق بعد يبقى
/// >       رماديّاً (`#D3D3D3`)؛
/// >   90  نافذة رمز البريد، يفتحها «إضافة وحفظ» إن كان البريد جديداً؛
/// >   91  «إضافة وحفظ»؛ ورمزٌ صحيحٌ يحفظ النموذج ويعود إلى القراءة.
/// >
/// > الحقول: 406 × 55 على y 160 (الاسم) و219 (البريد) و278 (الجنس) — 12 تحت
/// > الشريط ثمّ 4 بينها؛ العنوان 12 `#505050` على خطّ الأساس +20 والقيمة 14
/// > على +43. والجنس ثلاثُ كلماتٍ على x 68 و186 و326 — المختارة Medium
/// > `#1D1D1D` والأخريان Regular `#C3C3C3`.
///
/// ونافذةُ رمز البريد (اللوح 90) **لم تُنقل**: لا خدمة توثيق بريدٍ عندنا،
/// والويب نفسه يقول عنها «لا يُرسَل بريد. وأيُّ ستّة أرقامٍ توثّق العنوان» —
/// فهي عرضٌ لا منطق. فالحفظ يمضي مباشرةً.
class PersonalInfoPageV2 extends StatefulWidget {
  const PersonalInfoPageV2({
    super.key,
    required this.name,
    required this.email,
    required this.gender,
    required this.emailVerified,
    required this.onSave,
    this.busy = false,
    this.saved = false,
  });

  final String name;
  final String email;
  final PersonalGenderV2? gender;

  /// بريدٌ موثَّق: قيمتُه حبريّة، وغيرُ الموثَّق رماديّ — اللوح 89.
  final bool emailVerified;

  /// يُرسل الحفظ. والصفحةُ لا تعرف البلوك.
  final void Function({
    required String name,
    required String email,
    required PersonalGenderV2? gender,
  })
  onSave;

  /// الطلب جارٍ: مؤشّرٌ مكان نصّ الزرّ.
  final bool busy;

  /// نجح الطلب: تعود الشاشة إلى القراءة.
  final bool saved;

  @override
  State<PersonalInfoPageV2> createState() => _PersonalInfoPageV2State();
}

class _PersonalInfoPageV2State extends State<PersonalInfoPageV2> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  /// الشاشة تفتح للقراءة (اللوح 92)، و«تعديل» يجعل النموذج قابلاً للتحرير.
  bool _editing = false;
  PersonalGenderV2? _gender;

  /// كلماتُ الجنس تبدأ على x 68 و186 و326. وكلُّ كلمةٍ في خانةٍ بعرض الخطوة
  /// إلى التالية، وحولها حشوةٌ 12، فتحلّ كلُّ كلمةٍ على x الملفّ مهما كان
  /// عرض الشاشة.
  static const List<({PersonalGenderV2 id, String label, double? slot})>
  _genders = <({PersonalGenderV2 id, String label, double? slot})>[
    (id: PersonalGenderV2.man, label: LocaleKeys.man, slot: 186 - 68),
    (id: PersonalGenderV2.women, label: LocaleKeys.women, slot: 326 - 186),
    (id: PersonalGenderV2.other, label: LocaleKeys.other_gender, slot: null),
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _email = TextEditingController(text: widget.email);
    _gender = widget.gender;
    _nameFocus.addListener(_refresh);
    _emailFocus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(PersonalInfoPageV2 old) {
    super.didUpdateWidget(old);
    // نجح الحفظ: ارجع إلى القراءة، كما يفعل `save` في الويب.
    if (!old.saved && widget.saved) setState(() => _editing = false);
  }

  @override
  void dispose() {
    _nameFocus.removeListener(_refresh);
    _emailFocus.removeListener(_refresh);
    _nameFocus.dispose();
    _emailFocus.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _dirty =>
      _name.text != widget.name ||
      _email.text != widget.email ||
      _gender != widget.gender;

  bool get _canSave => _editing && _dirty && _name.text.trim().isNotEmpty;

  void _reset() {
    setState(() {
      _name.text = widget.name;
      _email.text = widget.email;
      _gender = widget.gender;
      _editing = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return XdScreenPage(
      header: XdScreenHeader(
        crumb: (LocaleKeys.profile.tr(), LocaleKeys.personal_info.tr()),
        crumbIcon: 'titlePersonal',
        crumbIconW: 18,
        onBack: () => Navigator.of(context).maybePop(),
        action: _editing ? LocaleKeys.cancel.tr() : LocaleKeys.edit.tr(),
        onAction: () => _editing ? _reset() : setState(() => _editing = true),
      ),
      footer: XdWideButton(
        label: LocaleKeys.add_save.tr(),
        visible: _canSave || widget.busy,
        busy: widget.busy,
        onTap: () => widget.onSave(
          name: _name.text.trim(),
          email: _email.text,
          gender: _gender,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          XdInfoBanner(
            text: LocaleKeys.entering_your_information_correctly.tr(),
          ),
          XdField(
            mt: 12,
            label: LocaleKeys.full_name.tr(),
            editing: _editing,
            inUse: _nameFocus.hasFocus,
            child: XdFieldInput(
              controller: _name,
              focusNode: _nameFocus,
              editing: _editing,
              placeholder: LocaleKeys.enter_full_name.tr(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          XdField(
            mt: 4,
            label: LocaleKeys.email.tr(),
            editing: _editing,
            inUse: _emailFocus.hasFocus,
            child: XdFieldInput(
              controller: _email,
              focusNode: _emailFocus,
              editing: _editing,
              keyboardType: TextInputType.emailAddress,
              placeholder: LocaleKeys.enter_email_address.tr(),
              // رماديٌّ حتّى يُوثَّق العنوان — اللوح 89.
              color: widget.emailVerified && _email.text == widget.email
                  ? XdColors.ink
                  : XdColors.placeholder,
              onChanged: (_) => setState(() {}),
            ),
          ),
          XdField(
            mt: 4,
            label: LocaleKeys.gender.tr(),
            editing: _editing,
            child: _genderRow(),
          ),
        ],
      ),
    );
  }

  /// الكلمة الأولى على x 68: الصفّ يبدأ 12 قبلها، تحت العنوان.
  Widget _genderRow() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: (68 - 12 - 12 - 12).w),
      child: Row(
        children: <Widget>[
          for (final ({PersonalGenderV2 id, String label, double? slot}) g
              in _genders)
            _genderWord(g),
        ],
      ),
    );
  }

  Widget _genderWord(({PersonalGenderV2 id, String label, double? slot}) g) {
    final bool on = g.id == _gender;
    // الخانة بعرض الملفّ، وقد تضيق حتّى كلمتها: على هاتفٍ أضيق من 430 يضيق
    // الحقل، وعلى الكلمات الثلاث أن تبقى فيه. وعلى 430 لا يضيق شيءٌ فتحلّ
    // كلُّ كلمةٍ على x الملفّ.
    final Widget word = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: xdTextStyle(
          size: 14,
          weight: on ? XdWeight.medium : XdWeight.regular,
          color: on ? XdColors.ink : XdColors.hint,
        ),
        child: Text(g.label.tr(), maxLines: 1, softWrap: false),
      ),
    );
    return Flexible(
      child: GestureDetector(
        onTap: _editing ? () => setState(() => _gender = g.id) : null,
        behavior: HitTestBehavior.opaque,
        child: g.slot == null ? word : SizedBox(width: g.slot!.w, child: word),
      ),
    );
  }
}
