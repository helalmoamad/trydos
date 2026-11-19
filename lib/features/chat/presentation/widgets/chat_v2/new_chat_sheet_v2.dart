import 'package:flutter/material.dart';
import 'package:trydos/features/app/trydos_shimmer_loading_stateless.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_icons_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/pick_sheet_v2.dart';

/// جهةٌ في قائمة «محادثة جديدة».
typedef NewChatContact = ({
  String id,
  String name,
  String phone,

  /// الحرفان حين لا صورة.
  String initials,
  Widget? photo,

  /// الجهة تملك التطبيق. وما لا يملكه يُعرض بجانبه زرُّ الدعوة بدل فتح
  /// محادثةٍ لا وجود لها.
  bool hasApp,
});

/// نافذة «محادثة جديدة» التي يفتحها الزرّ البنفسجي الدائري.
///
/// منقولةٌ بالبكسل من `web_design/components/DemoApp1/chat/NewChatSheet.tsx`
/// على فرع `development`:
///
/// > عنوانٌ 16 Medium في الوسط، ثم صفوف 60 على البطاقة `#FCFCFC`، على بعد 12
/// > من الحافّتين وبتباعد 2:
/// >
/// >   - أوّلها «جهة اتصال جديدة»: علامة جمعٍ في صندوقٍ بنفسجيّ باهت مكان
/// >     الصورة؛
/// >   - ثم صفٌّ لكل جهة: الصورة (نصف قطر 15، أو الصندوق الرمادي بالحرفين)
/// >     والاسم 14 Medium والرقم 12 Regular رمادياً.
/// >
/// > و«جهة اتصال جديدة» تحوّل النافذة إلى حقول نماذج البروفايل (`Field`
/// > و`FieldInput`): الاسم والرقم، وتحتهما زرّ النماذج البنفسجي العريض
/// > «إضافة وحفظ»، و«إلغاء» أعلى اليمين للعودة إلى القائمة. والزرّ ينتظر
/// > حتى يمتلئ الحقلان.
class NewChatSheetV2 extends StatefulWidget {
  const NewChatSheetV2({
    super.key,
    required this.contacts,
    required this.onPick,
    required this.onAdd,
    required this.listTitle,
    required this.formTitle,
    required this.newContactLabel,
    required this.nameLabel,
    required this.namePlaceholder,
    required this.phoneLabel,
    required this.phonePlaceholder,
    required this.saveLabel,
    required this.cancelLabel,
    this.onRefresh,
    this.onInvite,
    this.inviteLabel = '',
    this.busy = false,
    this.saveFailed = false,
  });

  final List<NewChatContact> contacts;

  /// جهةٌ اختيرت: تُفتح المحادثة معها.
  final ValueChanged<String> onPick;

  /// النموذج حُفظ: تُضاف الجهة وتُفتح المحادثة معها.
  final void Function(String name, String phone) onAdd;

  /// «محادثة جديدة» — عنوان القائمة.
  final String listTitle;

  /// «جهة اتصال جديدة» — العنوان نفسه يصير عنوان النموذج.
  final String formTitle;

  final String newContactLabel;
  final String nameLabel;
  final String namePlaceholder;
  final String phoneLabel;
  final String phonePlaceholder;
  final String saveLabel;
  final String cancelLabel;

  /// سحبةٌ إلى الأسفل على القائمة — تُحدِّث الجهات من الخادم.
  final Future<void> Function()? onRefresh;

  /// دعوةُ جهةٍ لا تملك التطبيق.
  final VoidCallback? onInvite;
  final String inviteLabel;

  /// يُحفظ أو تُجلب الجهات الآن — زرُّ الحفظ يصير وميضاً.
  final bool busy;

  /// أخفق آخر حفظ — فيبقى النموذج بحقوله ليُعيد المستخدم المحاولة.
  final bool saveFailed;

  /// يفتحها بغشاوة [PickSheetV2] ونصف قطرها نفسه.
  /// [sheet] ودجت لا [NewChatSheetV2] بعينها: الشاشة الحاضنة تلفّها بـ
  /// `BlocBuilder` لتتحدّث قائمةُ الجهات والنافذة مفتوحة — بعد إضافةِ جهةٍ
  /// أو سحبةٍ للتحديث.
  static Future<T?> show<T>(BuildContext context, {required Widget sheet}) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: PickSheetV2.backdrop,
      isScrollControlled: true,
      // ارتفاعها 90٪ من الشاشة — نافذةُ الملف تستقرّ عند `y` ثابت كذلك.
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      // النافذة تطول حتى تبلغ أعلى الشاشة، فعنوانها يقع تحت الشقّ والكاميرا.
      //
      // و`SafeArea` داخلها لا تنفع وحدها: `showModalBottomSheet` **يحذف
      // الحشو العلوي** من `MediaQuery` ما لم تُرفع هذه الراية
      // (`MediaQuery.removePadding(removeTop: true)` في `ModalBottomSheetRoute`)
      // — فتقرأ `SafeArea` صفراً ولا تفعل شيئاً.
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PickSheetV2.radius.r),
        ),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  State<NewChatSheetV2> createState() => _NewChatSheetV2State();
}

class _NewChatSheetV2State extends State<NewChatSheetV2> {
  /// النافذة على وضع النموذج. تُفتح على القائمة دائماً.
  bool _adding = false;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  /// الحقل قيد الكتابة — عليه وحده الحدّ الأزرق والعنوان Medium.
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  /// زمن تبديل القائمة بالنموذج ذهاباً، والعودة أسرع: 120.
  static const Duration _swap = Duration(milliseconds: 200);
  static const Duration _swapBack = Duration(milliseconds: 120);

  /// إزاحة التبديل: القائمة تخرج يساراً والنموذج يدخل يميناً.
  static const double _swapShift = 24;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onFocusChanged);
    _phoneFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _nameFocus.removeListener(_onFocusChanged);
    _phoneFocus.removeListener(_onFocusChanged);
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty;

  /// أرسلنا الحفظ وننتظر ردّ الخادم.
  bool _submitted = false;

  void _save() {
    if (!_canSave || widget.busy) return;
    setState(() => _submitted = true);
    widget.onAdd(_name.text, _phone.text);
    // ولا نُغلق النموذج هنا.
    //
    // يبقى أمام المستخدم وزرُّه وميضٌ حتى يردّ الخادم، فيرى أن طلبه جارٍ.
    // والعودة إلى القائمة في [didUpdateWidget] بعد نجاح الحفظ وجلبِ الجهات
    // — فيجد الجهة الجديدة في مكانها، لا قائمةً قديمة.
  }

  @override
  void didUpdateWidget(NewChatSheetV2 old) {
    super.didUpdateWidget(old);
    // انتهى الطلب الذي أرسلناه: إمّا إلى القائمة، وإمّا يبقى النموذج
    // بحقوله ليُعيد المستخدم المحاولة.
    if (_submitted && old.busy && !widget.busy) {
      _submitted = false;
      if (widget.saveFailed) return;
      _name.clear();
      _phone.clear();
      setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ترتفع النافذة فوق لوحة المفاتيح.
      //
      // `SafeArea` تقرأ `padding` — أشرطة النظام — ولوحةُ المفاتيح في
      // `viewInsets`. فكان حقلا الاسم والرقم يختفيان تحتها حين تُفتح.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        // وأعلاها محفوظٌ أيضاً: النافذة تعلو حتى تلامس الشقّ حين تطول
        // قائمةُ الجهات، فيقع عنوانُها تحته.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleRow(),
            // التمرير داخل كلٍّ من القائمة والنموذج، لا حولهما.
            //
            // كان `SingleChildScrollView` يلفّهما معاً، فيأخذ القائمةُ ارتفاعاً
            // غير محدود وتُبنى **كلُّ** جهات الاتصال قبل أن تظهر النافذة —
            // ومئاتُ الجهات تعني مئات الصفوف تُبنى وتُخطَّط في ضغطةٍ واحدة،
            // وهو سبب البطء عند فتحها.
            //
            // والقائمة الآن `ListView.builder` داخل `Flexible` بارتفاعٍ محدود،
            // فلا يُبنى إلّا ما يُرى. وارتفاعُها الكامل هو ما يرسمه الملف أصلاً:
            // نوافذُه تستقرّ عند `y` ثابت (440 من 932)، أي بارتفاعٍ ثابت
            // والقائمةُ تُمرَّر داخله.
            Flexible(
              child: AnimatedSwitcher(
                duration: _swap,
                reverseDuration: _swapBack,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: _swapTransition,
                layoutBuilder: (current, previous) => Stack(
                  children: [...previous, if (current != null) current],
                ),
                child: _adding ? _form() : _list(),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// النموذج يدخل من اليمين والقائمة من اليسار، كلاهما مع تلاشٍ.
  Widget _swapTransition(Widget child, Animation<double> animation) {
    final bool isForm = (child.key as ValueKey<String>?)?.value == 'form';
    final double from = isForm ? _swapShift : -_swapShift;

    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, inner) => Transform.translate(
          offset: Offset((1 - animation.value) * from.w, 0),
          child: inner,
        ),
        child: child,
      ),
    );
  }

  /// صفّ العنوان: ارتفاعه 30، والعنوان في وسطه، و«إلغاء» عند 20 من النهاية.
  Widget _titleRow() {
    final double top = (ContactDesign.textTop(30, 16) - 8).h;

    return SizedBox(
      height: 30.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: DesignText(
                _adding ? widget.formTitle : widget.listTitle,
                size: 16,
                family: 'Quicksand-Medium',
                center: true,
              ),
            ),
          ),
          PositionedDirectional(
            end: 20.w,
            top: top,
            child: AnimatedOpacity(
              opacity: _adding ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_adding,
                child: GestureDetector(
                  onTap: () => setState(() => _adding = false),
                  behavior: HitTestBehavior.opaque,
                  child: DesignText(
                    widget.cancelLabel,
                    size: 16,
                    family: 'Quicksand-Light',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// قائمة جهات الاتصال، وأوّلها «جهة اتصال جديدة».
  Widget _list() {
    // كسولة: صفُّ «جهة جديدة» أوّلاً ثم الجهات، ولا يُبنى إلّا ما يُرى.
    //
    // وسحبةٌ إلى الأسفل تُحدِّثها من الخادم — [onRefresh].
    final Widget list = ListView.builder(
      key: const ValueKey<String>('list'),
      padding: EdgeInsets.zero,
      itemCount: widget.contacts.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return PickRowV2(
            isFirst: true,
            onTap: () => setState(() => _adding = true),
            child: Row(
              children: [
                PickBoxV2(
                  background: ReminderSheetV2.tint,
                  child: ChatIconsV2.plus(
                    size: 22,
                    color: ContactDesign.purple,
                  ),
                ),
                SizedBox(width: 12.w),
                DesignText(
                  widget.newContactLabel,
                  size: 14,
                  family: 'Quicksand-Medium',
                  color: ContactDesign.purple,
                ),
              ],
            ),
          );
        }
        // صفُّ الجهة هو صفُّ المحادثة نفسه — الملف يقول إنها «كما ترسم
        // نافذةُ تحويل إلى محادثةً»، والرقم مكان اللمحة.
        final NewChatContact c = widget.contacts[i - 1];
        return SheetChatRowV2(
          entry: (
            id: c.id,
            name: c.name,
            secondLine: c.phone,
            initials: c.initials,
            photo: c.photo,
          ),
          // جهةٌ بلا تطبيق: زرُّ الدعوة بدل فتح محادثةٍ لا وجود لها — وهو
          // ما كانت تفعله صفحة جهات الاتصال القديمة.
          trailing: c.hasApp || widget.onInvite == null
              ? null
              : GestureDetector(
                  onTap: widget.onInvite,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.w),
                    child: DesignText(
                      widget.inviteLabel,
                      size: 14,
                      family: 'Quicksand-Medium',
                      color: ContactDesign.blue,
                    ),
                  ),
                ),
          onTap: c.hasApp
              ? () => widget.onPick(c.id)
              // جهةٌ بلا تطبيق ولا دعوة: النقر لا يفعل شيئاً بدل أن يفتح
              // محادثةً لا وجود لها.
              : (widget.onInvite ?? () {}),
        );
      },
    );

    final Future<void> Function()? refresh = widget.onRefresh;
    if (refresh == null) return list;
    return RefreshIndicator(
      onRefresh: refresh,
      color: ContactDesign.purple,
      child: list,
    );
  }

  /// نموذج الجهة الجديدة. تمريرُه صار داخله بعد أن خرج اللفّ المشترك.
  Widget _form() {
    return SingleChildScrollView(
      key: const ValueKey<String>('form'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            widget.nameLabel,
            widget.namePlaceholder,
            _name,
            _nameFocus,
            top: 16,
          ),
          _field(
            widget.phoneLabel,
            widget.phonePlaceholder,
            _phone,
            _phoneFocus,
            top: 4,
            keyboard: TextInputType.phone,
          ),
          _saveButton(),
        ],
      ),
    );
  }

  /// حقلٌ واحد: ارتفاعه 55 بنصف قطر 15، عنوانه 12 فوق قيمته.
  ///
  /// حدُّه أزرق أثناء الكتابة ورماديٌّ فيما عداها، وعنوانه Medium أثناءها
  /// وRegular فيما عداها. وخلفيّته بيضاء لأن النموذج كلّه في وضع `editing`.
  Widget _field(
    String label,
    String placeholder,
    TextEditingController controller,
    FocusNode focus, {
    required double top,
    TextInputType? keyboard,
  }) {
    final bool inUse = focus.hasFocus;

    return Container(
      margin: EdgeInsets.only(
        top: top.h,
        left: ContactDesign.rowX.w,
        right: ContactDesign.rowX.w,
      ),
      height: 55.h,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ContactDesign.rowRadius.r),
        border: Border.all(
          color: inUse ? ContactDesign.blue : ContactDesign.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DesignText(
            label,
            size: 12,
            family: inUse ? 'Quicksand-Medium' : 'Quicksand-Regular',
            color: ContactDesign.label,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              keyboardType: keyboard,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: 'Quicksand-Regular',
                fontSize: 14.sp,
                color: ContactDesign.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontFamily: 'Quicksand-Regular',
                  fontSize: 14.sp,
                  color: ContactDesign.grey,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// زرّ النماذج العريض: 60 بنصف قطر 20 على بعد 20، ومعطَّلٌ حتى يمتلئ
  /// الحقلان — عتمته 0.4 عندها.
  Widget _saveButton() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, left: 20.w, right: 20.w),
      child: GestureDetector(
        onTap: _save,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          opacity: _canSave ? 1 : 0.4,
          duration: const Duration(milliseconds: 200),
          // أثناء الحفظ وجلب الجهات يصير الزرّ وميضاً، فيعرف المستخدم أن
          // الطلب جارٍ — وكان يُغلق النموذج فوراً بلا أثر.
          child: widget.busy
              ? TrydosShimmerLoadingStateless(
                  width: double.infinity,
                  height: 60.h,
                  radius: 20,
                  logoTextWidth: 60.w,
                  logoTextHeight: 16.h,
                )
              : Container(
                  height: 60.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ContactDesign.purple,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: DesignText(
                    widget.saveLabel,
                    size: 16,
                    family: 'Quicksand-Regular',
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
