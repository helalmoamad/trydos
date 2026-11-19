import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_row_v2.dart';

/// حال المكالمة كما يرسمها تبويب المكالمات.
enum CallRowKindV2 { missed, incoming, noAnswer }

/// أرقام كل حال: أيقونتُها ومقاس كلماتها ولونها وخطوط أساسها.
///
/// منقولةٌ حرفياً من `CALL_STATE` في `ChatListScreen.tsx`:
///
/// > * **فائتة**: الهاتف الأحمر 18×18 عند (90، 52 داخل الصفّ)، والكلمات
/// >   14 Regular على خطّ الأساس 66 عند x=114.
/// > * **واردة**: الهاتف البنفسجي 15×15 عند (90، 40)، والكلمات 12 Regular
/// >   على خطّ الأساس 52 عند x=111.
/// > * **بلا ردّ**: الهاتف البنفسجي 18×18 عند (90، 52)، والكلمات 14 Regular
/// >   على خطّ الأساس 66 عند x=114.
typedef CallStateV2 = ({
  String icon,
  double iconSize,
  double size,
  Color color,
  double iconTop,
  double baseline,
  double x,
});

const Map<CallRowKindV2, CallStateV2> kCallStateV2 = {
  CallRowKindV2.missed: (
    icon: 'callMissed',
    iconSize: 18,
    size: 14,
    color: ChatListDesign.red,
    iconTop: 52,
    baseline: 66,
    x: 114,
  ),
  CallRowKindV2.incoming: (
    icon: 'callIncoming',
    iconSize: 15,
    size: 12,
    color: ChatListDesign.ink,
    iconTop: 40,
    baseline: 52,
    x: 111,
  ),
  CallRowKindV2.noAnswer: (
    icon: 'callOutgoing',
    iconSize: 18,
    size: 14,
    color: ChatListDesign.ink,
    iconTop: 52,
    baseline: 66,
    x: 114,
  ),
};

/// صفٌّ واحد في تبويب المكالمات.
///
/// منقولٌ بالبكسل من `CallRowFace` في
/// `web_design/components/DemoApp1/screens/ChatListScreen.tsx` على فرع
/// `development` (لوح XD `Home Page – 43`):
///
/// > صفٌّ 430×90 بلون `#FCFCFC` من y=152، الصورة 66×66، والاسم 16 Medium
/// > على خطّ الأساس 36، والوقت على خطّ الأساس 23، ثم حالُ المكالمة —
/// > أيقونتُها وكلماتُها — و«16 Min» 11 Regular على خطّ الأساس 72 تحت
/// > المكالمة الواردة.
/// >
/// > **والملف يرفع اسمَ الصفّ الذي له سطرٌ ثانٍ إلى خطّ الأساس 30.**
class CallRowFaceV2 extends StatelessWidget {
  const CallRowFaceV2({
    super.key,
    required this.kind,
    required this.name,
    required this.time,
    required this.label,
    required this.photo,
    required this.onTap,
    this.initials,
    this.minutesLabel,
  });

  final CallRowKindV2 kind;
  final String name;
  final String time;

  /// كلمات الحال بلغة التطبيق — «مكالمة صوتية فائتة !» وأخواتها.
  final String label;

  /// صورة المتّصل — تُبنى خارجاً.
  final Widget photo;
  final String? initials;

  /// «16 دقيقة» تحت المكالمة الواردة، أو `null` فلا سطر ثانٍ.
  final String? minutesLabel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CallStateV2 s = kCallStateV2[kind]!;

    // الاسم يرتفع إلى خطّ الأساس 30 حين يكون تحته سطرٌ ثانٍ.
    final double nameTop = ContactDesign.textTop(
      minutesLabel != null ? 30 : 36,
      16,
    );
    final double nameBottom = nameTop + ContactDesign.lineBox(16);
    final double stateTop = ContactDesign.textTop(s.baseline, s.size);

    // الأيقونة والكلمات يبدأ أعلاهما عند أصغر العلوَّين، ثم ينزل كلٌّ منهما
    // إلى موضعه — فيبقى خطّا أساسهما كما في الملف مهما اختلف المقاسان.
    final double top = s.iconTop < stateTop ? s.iconTop : stateTop;

    return Directionality(
      // جهاتٌ مطلقة كالملف: الصورة قبل الكلمات في كل اللغات.
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: ChatListDesign.callRowHeight.h,
          margin: EdgeInsets.only(top: ChatListDesign.rowGap.h),
          color: ChatListDesign.page,
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: ChatListDesign.line,
              width: ChatListDesign.rowLine,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: ChatListDesign.photoX.w,
                  top: ChatListDesign.photoY.h,
                ),
                child: RowPhotoV2(
                  width: ChatListDesign.callPhoto,
                  height: ChatListDesign.callPhoto,
                  initials: initials,
                  child: photo,
                ),
              ),
              // الوقت **أخو العمود لا ابنه**.
              //
              // خطُّ أساسه 23 مقيسٌ من أعلى الصفّ، والعمود يبدأ عند `nameTop`
              // — فحشوُه داخله `textTop(23,11) - nameTop` وهو **سالب** (‎-8
              // بلا سطرٍ ثانٍ و‎-2 معه). والويب يحتمل الهامش السالب؛ و`Padding`
              // في Flutter يؤكّد `padding.isNonNegative` فيسقط التخطيط، ومعه
              // تفيض الصفوف بعشرات الألوف من البكسلات.
              //
              // وبإخراجه إلى الصفّ الخارجي يُقاس من أعلى الصفّ مباشرةً، فيصير
              // 12 موجباً — وهو موضعه نفسه في الملف.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, top: nameTop.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DesignText(name, size: 16, family: 'Quicksand-Medium'),
                      Padding(
                        padding: EdgeInsets.only(top: (top - nameBottom).h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: (s.iconTop - top).h,
                              ),
                              child: XdIcon(s.icon, width: s.iconSize),
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: (s.x - 90 - s.iconSize).w,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: (stateTop - top).h,
                                      ),
                                      child: DesignText(
                                        label,
                                        size: s.size,
                                        family: 'Quicksand-Regular',
                                        color: s.color,
                                        letterSpacing: 0.012 * s.size,
                                      ),
                                    ),
                                    if (minutesLabel != null)
                                      Padding(
                                        // «16 Min» على خطّ الأساس 72.
                                        padding: EdgeInsets.only(
                                          top:
                                              (ContactDesign.textTop(72, 11) -
                                                      (stateTop +
                                                          ContactDesign.lineBox(
                                                            s.size,
                                                          )))
                                                  .h,
                                        ),
                                        child: DesignText(
                                          minutesLabel!,
                                          size: 11,
                                          family: 'Quicksand-Regular',
                                          letterSpacing: 0.012 * 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RowTimeV2(
                time: time,
                right: 12,
                top: ContactDesign.textTop(23, 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
