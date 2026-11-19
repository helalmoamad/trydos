import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// نافذةٌ سفلية قصيرة من الخيارات.
///
/// منقولةٌ بالبكسل من `web_design/components/DemoApp1/chat/PickSheet.tsx`
/// على فرع `development`:
///
/// > عنوانٌ 16 Medium في الوسط، وصفوف 60 على البطاقة `#FCFCFC`، على بعد 12
/// > من الحافّتين وبتباعد 2 — بأسلوب نافذتَي «تحويل إلى» و«محادثة جديدة».
/// > ولكل صفٍّ صندوق 44×44 في بدايته (أيقونة أو لون أو صورة) وكلماتُه بعده.
///
/// تخدم نوافذ الوسم والتذكير والأرشيف.
class PickSheetV2 extends StatelessWidget {
  const PickSheetV2({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  /// نصف قطر أعلى النافذة.
  static const double radius = 30;

  /// الغشاوة خلفها.
  static const Color backdrop = Color(0xE61D1D1D);

  /// يفتحها بالحركة التي يفتحها بها الويب.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: backdrop,
      isScrollControlled: true,
      // نافذةٌ طويلة (الأرشيف بعشرين محادثة مثلاً) تبلغ أعلى الشاشة، فيقع
      // عنوانها تحت الشقّ. و`showModalBottomSheet` **يحذف الحشو العلوي** من
      // `MediaQuery` ما لم تُرفع هذه الراية، فلا تنفع `SafeArea` داخلها.
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.r)),
      ),
      builder: (_) => PickSheetV2(title: title, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ترتفع النافذة فوق لوحة المفاتيح.
      //
      // `SafeArea` وحدها لا تكفي: هي تقرأ `padding` — أشرطة النظام — ولوحةُ
      // المفاتيح في `viewInsets`. فكانت نافذةٌ فيها حقلُ كتابة (الوسم مثلاً)
      // تبقى مكانها حين تُفتح اللوحة، فتحجب اللوحةُ الحقلَ الذي فتحها.
      //
      // وهي تنفع كلَّ نافذةٍ مبنيّة على هذه (الوسم والتحويل والتذكير)،
      // و`isScrollControlled` مرفوعةٌ في `show` أعلاه فتتّسع للارتفاع الجديد.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان على خطّ أساس 30 داخل النافذة، ناقص 8.
            Padding(
              padding: EdgeInsets.only(
                top: (ContactDesign.textTop(30, 16) - 8).h,
              ),
              child: DesignText(
                title,
                size: 16,
                family: 'Quicksand-Medium',
                center: true,
              ),
            ),
            // جسمٌ يُمرَّر، كـ`Under` في الملف (`overflow-y: auto`).
            //
            // وبلا تمرير كان العمود يطلب ارتفاع محتواه كلّه: نافذةُ التحويل
            // بعشرين محادثة تطلب نحو 1240 — فتفيض عن الشاشة. و`Flexible`
            // يجعلها تكبر بقدر محتواها ولا تتجاوز حدّ النافذة.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

/// صفٌّ واحد في [PickSheetV2].
class PickRowV2 extends StatelessWidget {
  const PickRowV2({
    super.key,
    required this.child,
    required this.onTap,
    this.isFirst = false,
  });

  final Widget child;
  final VoidCallback onTap;

  /// الأول يبعد 16 عن العنوان، وما بعده 2 عن سابقه.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(
          top: (isFirst ? 16 : ContactDesign.rowGap).h,
          left: ContactDesign.rowX.w,
          right: ContactDesign.rowX.w,
        ),
        height: ContactDesign.rowHeight.h,
        decoration: BoxDecoration(
          color: ContactDesign.card,
          borderRadius: BorderRadius.circular(ContactDesign.rowRadius.r),
        ),
        child: child,
      ),
    );
  }
}

/// الصندوق 44×44 في بداية الصفّ، على بعد 8.
class PickBoxV2 extends StatelessWidget {
  const PickBoxV2({super.key, required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(start: 8.w),
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: child,
    );
  }
}

/// نافذة الوسم التي يفتحها زرّ التصنيف في القائمة.
///
/// > صفٌّ لكل وسم، لونه نقطةً 14 في صندوق الصفّ واسمه 14 Medium؛ والوسم
/// > الذي تحمله الرسالة تظهر بجانبه علامةُ صحٍّ بلونه. وآخر صفّ «بلا» يرفع
/// > الوسم.
class CategorySheetV2 extends StatelessWidget {
  const CategorySheetV2({
    super.key,
    required this.categories,
    required this.onPick,
    required this.noneLabel,
    this.chosenId,
  });

  /// الوسوم المتاحة: معرّفٌ واسمٌ ولون.
  final List<({String id, String name, Color color})> categories;

  /// يُستدعى بمعرّف الوسم، أو `null` لرفعه.
  final ValueChanged<String?> onPick;

  final String noneLabel;
  final String? chosenId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < categories.length; i++)
          PickRowV2(
            isFirst: i == 0,
            onTap: () => onPick(categories[i].id),
            child: Row(
              children: [
                PickBoxV2(child: _dot(categories[i].color)),
                SizedBox(width: 12.w),
                Expanded(
                  child: DesignText(
                    categories[i].name,
                    size: 14,
                    family: 'Quicksand-Medium',
                  ),
                ),
                if (chosenId == categories[i].id)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.w),
                    child: Icon(
                      Icons.check,
                      size: 18.sp,
                      color: categories[i].color,
                    ),
                  ),
              ],
            ),
          ),
        PickRowV2(
          onTap: () => onPick(null),
          child: Row(
            children: [
              PickBoxV2(child: _emptyDot()),
              SizedBox(width: 12.w),
              DesignText(
                noneLabel,
                size: 14,
                family: 'Quicksand-Medium',
                color: ContactDesign.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 14.w,
    height: 14.w,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  /// نقطة «بلا»: دائرةٌ فارغة بحدٍّ 1.5.
  Widget _emptyDot() => Container(
    width: 14.w,
    height: 14.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: ContactDesign.line, width: 1.5),
    ),
  );
}

/// نافذة الأرشيف التي يفتحها صفّ «المؤرشفة».
///
/// > المحادثات المؤرشفة، الأحدث أولاً، كما ترسم نافذةُ «تحويل إلى» محادثةً
/// > — الصورة أو الحرفان، والاسم 14 Medium، واللمحة 12 Regular رمادية —
/// > ومعها زرٌّ دائري بنفسجيٌّ باهت في النهاية يعيد المحادثة إلى القائمة.
/// > ونقرةٌ على الصفّ تفتح المحادثة.
class ArchivedSheetV2 extends StatelessWidget {
  const ArchivedSheetV2({
    super.key,
    required this.chats,
    required this.onOpen,
    required this.onUnarchive,
    required this.emptyLabel,
  });

  /// المحادثات المؤرشفة، بصفّ المحادثة المشترك.
  final List<SheetChatEntry> chats;

  final ValueChanged<String> onOpen;
  final ValueChanged<String> onUnarchive;

  /// ما يُكتب حين لا مؤرشفة.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
        child: DesignText(
          emptyLabel,
          size: 14,
          family: 'Quicksand-Regular',
          color: ContactDesign.grey,
          center: true,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < chats.length; i++)
          SheetChatRowV2(
            entry: chats[i],
            isFirst: i == 0,
            onTap: () => onOpen(chats[i].id),
            // زرّ الإعادة: 44 بنصف قطر 15 بلون بنفسجيّ باهت.
            trailing: GestureDetector(
              onTap: () => onUnarchive(chats[i].id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsetsDirectional.only(end: 8.w),
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ReminderSheetV2.tint,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.unarchive_outlined,
                  size: 20.sp,
                  color: ContactDesign.purple,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// وسمٌ يمكن أن تحمله رسالة: معرّفٌ واسمٌ ولون.
typedef MessageCategory = ({String id, String name, Color color});

/// الوسوم التي يعرضها التصميم.
///
/// > هذه ما يعرضه الديمو؛ **والقائمة الحقيقية تأتي من خدمة الدردشة**.
///
/// وهذا السطر في الويب يحسم الأمر: الخمسة عيّنةٌ لا عقد. فتُستعمل حتى يرسل
/// خادمُنا قائمته، وحينها تُستبدل بلا أن يتغيّر شيءٌ في النافذة.
///
/// وخادمنا اليوم يقبل **نصّاً حرّاً** حتى 30 حرفاً، لا معرّفات من قائمة.
/// فالوسم المختار هنا يُرسَل باسمه.
abstract class MessageCategoriesV2 {
  static const List<MessageCategory> seeded = [
    (id: 'orders', name: 'Orders', color: Color(0xFF4A31E7)),
    (id: 'payment', name: 'Payment', color: Color(0xFF00DD80)),
    (id: 'shipping', name: 'Shipping', color: Color(0xFF388CFF)),
    (id: 'question', name: 'Question', color: Color(0xFFF4780E)),
    (id: 'important', name: 'Important', color: Color(0xFFFF0508)),
  ];

  /// لون وسمٍ باسمه، أو البنفسجي حين لا يكون من القائمة.
  ///
  /// وسومُ المستخدم الحرّة لا لون لها في التصميم، فتأخذ لون الوسم الأول.
  static Color colorOf(String name) {
    for (final MessageCategory c in seeded) {
      if (c.name.toLowerCase() == name.toLowerCase()) return c.color;
    }
    return seeded.first.color;
  }
}

/// خيارات التذكير الثلاثة كما يحسبها الويب.
///
/// > بعد ساعة · غداً · الأسبوع القادم — والأخيران عند **التاسعة صباحاً**.
///
/// ثلاثةٌ لا أربعة: نافذتنا السابقة كانت تعرض «بعد ٢٠ دقيقة» و«بعد ٣ ساعات»
/// و«صباح الغد»، وهي من اجتهادنا لا من التصميم.
abstract class ReminderOptionsV2 {
  /// بعد ساعة من الآن.
  static DateTime inOneHour([DateTime? now]) =>
      (now ?? DateTime.now()).add(const Duration(hours: 1));

  /// التاسعة صباحاً بعد [days] يوماً.
  static DateTime atNine(int days, [DateTime? now]) {
    final DateTime base = now ?? DateTime.now();
    return DateTime(base.year, base.month, base.day + days, 9);
  }

  static DateTime tomorrow([DateTime? now]) => atNine(1, now);

  static DateTime nextWeek([DateTime? now]) => atNine(7, now);
}

/// نافذة التذكير التي يفتحها جرس القائمة.
///
/// > صفٌّ لكل خيار، جرسُه في صندوق الصفّ، والوقت الذي يعنيه الصفّ 12 Regular
/// > رمادياً تحت كلماته. ومتى حملت الرسالة تذكيراً، صفٌّ أخيرٌ بالأحمر
/// > يرفعه.
/// محادثةٌ أو جهةٌ في صفوف النوافذ.
typedef SheetChatEntry = ({
  String id,
  String name,

  /// السطر الثاني: لمحةُ آخر رسالة، أو الرقم.
  String secondLine,

  /// الحرفان حين لا صورة.
  String initials,
  Widget? photo,
});

/// صفُّ محادثةٍ في نافذةٍ سفلية.
///
/// شكلٌ واحد تشترك فيه نوافذ «تحويل إلى» و«المؤرشفة» و«محادثة جديدة» — فالملف
/// يرسمها الثلاث بصفٍّ واحد، ويقول في نافذتَي الأرشيف والمحادثة الجديدة
/// صراحةً: «كما ترسم نافذةُ تحويل إلى محادثةً».
///
/// > صفٌّ 60 على البطاقة: الصورة 44 بنصف قطر 15 وحدٍّ شعريٍّ 0.3 (أو الصندوق
/// > الرمادي بالحرفين على خطّ أساس 27)، والاسم 14 Medium، واللمحة 12 Regular
/// > رمادية، وكلماتُه على بعد 12 من الجهتين.
class SheetChatRowV2 extends StatelessWidget {
  const SheetChatRowV2({
    super.key,
    required this.entry,
    required this.onTap,
    this.isFirst = false,
    this.trailing,
  });

  final SheetChatEntry entry;
  final VoidCallback onTap;
  final bool isFirst;

  /// ما يُرسم في نهاية الصفّ — زرّ إعادةٍ من الأرشيف مثلاً.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PickRowV2(
      isFirst: isFirst,
      onTap: onTap,
      child: Row(
        children: [
          photoBox(photo: entry.photo, initials: entry.initials),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DesignText(entry.name, size: 14, family: 'Quicksand-Medium'),
                  DesignText(
                    entry.secondLine,
                    size: 12,
                    family: 'Quicksand-Regular',
                    color: ContactDesign.grey,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  /// صندوق الصورة 44×44: الصورة، أو الحرفان على خطّ أساس 27.
  ///
  /// والحدّ 0.3 فوق الصورة لا تحتها — وإلّا قُصّ عند الزوايا.
  static Widget photoBox({required Widget? photo, required String initials}) {
    return Container(
      margin: EdgeInsetsDirectional.only(start: 8.w),
      width: 44.w,
      height: 44.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: photo == null ? const Color(0xFFF8F8F8) : null,
        borderRadius: BorderRadius.circular(15.r),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: ContactDesign.line, width: 0.3),
      ),
      child:
          photo ??
          Padding(
            padding: EdgeInsets.only(top: ContactDesign.textTop(27, 12).h),
            child: DesignText(
              initials,
              size: 12,
              family: 'Quicksand-Medium',
              center: true,
            ),
          ),
    );
  }
}

/// نافذة «تحويل إلى» التي تختار المحادثة التي تذهب إليها الرسالة.
///
/// منقولةٌ من `chat/ForwardSheet.tsx` على فرع `development`:
///
/// > صفوف المحادثات بأسلوب القائمة — الصورة بنصف قطر 15، والاسم 14 Medium،
/// > واللمحة 12 Regular رمادية — 60 لكلٍّ منها، على بعد 12 من الحافّتين، على
/// > البطاقة `#FCFCFC` التي تستعملها صفوف جهة الاتصال.
///
/// والمحادثة التي الرسالة فيها لا تُعرض.
class ForwardSheetV2 extends StatelessWidget {
  const ForwardSheetV2({
    super.key,
    required this.chats,
    required this.onPick,
    required this.emptyLabel,
  });

  final List<SheetChatEntry> chats;
  final ValueChanged<String> onPick;

  /// ما يُكتب حين لا محادثة أخرى تُحوَّل إليها.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: DesignText(
          emptyLabel,
          size: 14,
          family: 'Quicksand-Regular',
          color: ContactDesign.grey,
          center: true,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < chats.length; i++)
          SheetChatRowV2(
            entry: chats[i],
            isFirst: i == 0,
            onTap: () => onPick(chats[i].id),
          ),
      ],
    );
  }
}

/// صفُّ وسمٍ في [TagSheetV2].
typedef MessageTagRowV2 = ({
  String name,

  /// كم شخصاً وضع هذا الوسم. صفرٌ للاقتراح الذي لم يوضع بعد.
  int count,

  /// وضعتُه أنا — فيظهر بعلامة صحّ.
  bool applied,

  /// هذا الصفّ بعينه ينتظر ردّ الخادم.
  bool pending,
});

/// نافذة وسوم الرسالة.
///
/// هندستُها هندسة [CategorySheetV2] — صفوف 60 ونقطةٌ ملوّنة في صندوق 44 —
/// لكن وسومنا تختلف عن وسوم الويب في ثلاثة أمور، ولذلك نافذةٌ على حدة:
///
/// * الويب يعطي وسماً **واحداً** للرسالة من قائمةٍ ثابتة؛ وعندنا عدّة وسوم
///   على الرسالة الواحدة، فلكلّ صفٍّ علامةُ صحٍّ تُرفع وتُوضع.
/// * الويب لا يعرض عدّاداً؛ وعندنا الوسم يحمل عدد من وضعه.
/// * الويب لا يكتب وسماً جديداً؛ وخادمنا يقبل نصّاً حرّاً، فتحت القائمة حقلٌ.
class TagSheetV2 extends StatelessWidget {
  const TagSheetV2({
    super.key,
    required this.rows,
    required this.onToggle,
    required this.controller,
    required this.onAddTyped,
    required this.hintText,
    required this.addLabel,
    this.addPending = false,
  });

  final List<MessageTagRowV2> rows;

  /// الاسم، و`true` للوضع و`false` للرفع.
  final void Function(String name, bool add) onToggle;

  final TextEditingController controller;
  final VoidCallback onAddTyped;
  final String hintText;
  final String addLabel;

  /// الوسم المكتوب ينتظر الخادم: مؤشّرٌ مكان كلمة «إضافة».
  final bool addPending;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++)
          PickRowV2(
            isFirst: i == 0,
            onTap: rows[i].pending
                ? () {}
                : () => onToggle(rows[i].name, !rows[i].applied),
            child: Row(
              children: [
                PickBoxV2(
                  child: _dot(MessageCategoriesV2.colorOf(rows[i].name)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DesignText(
                    rows[i].name,
                    size: 14,
                    family: 'Quicksand-Medium',
                  ),
                ),
                if (rows[i].count > 0)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: DesignText(
                      '${rows[i].count}',
                      size: 12,
                      family: 'Quicksand-Regular',
                      color: ContactDesign.grey,
                    ),
                  ),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 16.w),
                  child: _mark(rows[i]),
                ),
              ],
            ),
          ),
        _addRow(),
      ],
    );
  }

  /// علامة الصفّ: مؤشّر انتظارٍ، أو صحٌّ بلون نقطته، أو فراغٌ بمقاسه.
  ///
  /// الفراغ بمقاس العلامة حتى لا يقفز النصّ حين تظهر أو تختفي.
  Widget _mark(MessageTagRowV2 row) {
    if (row.pending) {
      return SizedBox(
        width: 18.sp,
        height: 18.sp,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            MessageCategoriesV2.colorOf(row.name),
          ),
        ),
      );
    }
    if (!row.applied) return SizedBox(width: 18.sp, height: 18.sp);
    return Icon(
      Icons.check,
      size: 18.sp,
      color: MessageCategoriesV2.colorOf(row.name),
    );
  }

  /// صفّ كتابة وسمٍ جديد — بمقاس الصفوف وخلفيّتها.
  Widget _addRow() {
    return Container(
      margin: EdgeInsets.only(
        top: ContactDesign.rowGap.h,
        left: ContactDesign.rowX.w,
        right: ContactDesign.rowX.w,
      ),
      height: ContactDesign.rowHeight.h,
      decoration: BoxDecoration(
        color: ContactDesign.card,
        borderRadius: BorderRadius.circular(ContactDesign.rowRadius.r),
      ),
      child: Row(
        children: [
          PickBoxV2(child: _emptyDot()),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onAddTyped(),
              style: TextStyle(
                fontFamily: 'Quicksand-Medium',
                fontSize: 14.sp,
                color: ContactDesign.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Quicksand-Regular',
                  fontSize: 14.sp,
                  color: ContactDesign.grey,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16.w),
            child: addPending
                ? SizedBox(
                    width: 18.sp,
                    height: 18.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ContactDesign.purple,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onAddTyped,
                    behavior: HitTestBehavior.opaque,
                    child: DesignText(
                      addLabel,
                      size: 14,
                      family: 'Quicksand-Medium',
                      color: ContactDesign.purple,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 14.w,
    height: 14.w,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _emptyDot() => Container(
    width: 14.w,
    height: 14.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: ContactDesign.line, width: 1.5),
    ),
  );
}

/// صفّ «اختر التاريخ والوقت» تحت مواعيد [ReminderSheetV2] الجاهزة.
///
/// لا نظير له في الويب: الملف يعطي ثلاثة مواعيد ثابتة ولا يتيح موعداً حرّاً.
/// والموعد الحرّ ميزةٌ قائمة عندنا، فأخذ شكل الصفوف نفسه بدل نافذةٍ على حدة.
class ReminderCustomRowV2 extends StatelessWidget {
  const ReminderCustomRowV2({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PickRowV2(
      onTap: onTap,
      child: Row(
        children: [
          const PickBoxV2(
            background: ReminderSheetV2.tint,
            child: XdIcon('menuRemind', width: 18, height: 18),
          ),
          SizedBox(width: 12.w),
          DesignText(label, size: 14, family: 'Quicksand-Medium'),
        ],
      ),
    );
  }
}

class ReminderSheetV2 extends StatelessWidget {
  const ReminderSheetV2({
    super.key,
    required this.options,
    required this.onPick,
    required this.removeLabel,
    this.hasReminder = false,
  });

  /// الخيارات: اسمٌ ووقتٌ مكتوب.
  final List<({String label, String timeText, DateTime at})> options;

  /// يُستدعى بالوقت، أو `null` لرفع التذكير.
  final ValueChanged<DateTime?> onPick;

  final String removeLabel;
  final bool hasReminder;

  /// خلفية صندوق الجرس — بنفسجيٌّ باهت.
  static const Color tint = Color(0xFFF5F4FF);

  /// خلفية صندوق الإزالة — أحمرُ باهت.
  static const Color removeTint = Color(0xFFFFE6E5);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++)
          PickRowV2(
            isFirst: i == 0,
            onTap: () => onPick(options[i].at),
            child: Row(
              children: [
                const PickBoxV2(
                  background: tint,
                  child: XdIcon('menuRemind', width: 18, height: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DesignText(
                        options[i].label,
                        size: 14,
                        family: 'Quicksand-Medium',
                      ),
                      DesignText(
                        options[i].timeText,
                        size: 12,
                        family: 'Quicksand-Regular',
                        color: ContactDesign.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (hasReminder)
          PickRowV2(
            onTap: () => onPick(null),
            child: Row(
              children: [
                const PickBoxV2(
                  background: removeTint,
                  child: XdIcon('menuRemind', width: 18, height: 18),
                ),
                SizedBox(width: 12.w),
                DesignText(
                  removeLabel,
                  size: 14,
                  family: 'Quicksand-Medium',
                  color: ChatDesign.missedRed,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
