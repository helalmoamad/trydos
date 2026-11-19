import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_icons_v2.dart';

/// ترويسة البحث في المحادثة.
///
/// تحلّ محلّ ترويسة المحادثة حين يُفتح البحث. منقولةٌ من
/// `ConversationScreen.tsx` على فرع `development`:
///
/// > ارتفاعها 50 كترويسة المحادثة، فيها شيفرون الإغلاق عند 18.5، وحقلٌ
/// > 38 بنصف قطر 12 ولون `#F8F8F8` من x=40، وفيه عدسةٌ على بعد 9.5 ونصّ
/// > 14، و✕ تظهر متى كُتب شيء.
class ConversationSearchHeader extends StatelessWidget {
  const ConversationSearchHeader({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hasQuery,
    required this.onClose,
    required this.onClear,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final bool hasQuery;
  final VoidCallback onClose;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ContactDesign.statusBar.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: ChatDesign.headerShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 18.5.w, top: 13.5.h),
            child: GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: const XdIcon('chatBackPurple', width: 11, height: 23),
            ),
          ),
          Expanded(
            child: Container(
              // من x=40: الشيفرون يبدأ عند 18.5 وعرضه 8 في حساب الملف.
              margin: EdgeInsetsDirectional.only(
                start: (40 - (18.5 + 8)).w,
                end: 12.w,
                top: 6.h,
              ),
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 9.5.w, end: 6.w),
                    child: const XdIcon('searchGlass', width: 19, height: 19),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: 'Quicksand-Regular',
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
                  if (hasQuery)
                    GestureDetector(
                      onTap: onClear,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 38.w,
                        height: 38.h,
                        child: Center(
                          child: ChatIconsV2.close(color: ContactDesign.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ترويسة شاشة المحادثة بالتصميم الجديد.
///
/// منقولةٌ بالبكسل من `ConversationScreen.tsx` (لوحة XD `Home Page – 44`):
/// من y=50 إلى 100، بيضاء بظلّ `0 0 3` أسود 10٪. فيها الشيفرون البنفسجي عند
/// x=18.5، وعدّاد غير المقروء من 40 إلى 62، والصورة 38×38 عند (62, 56)،
/// والاسم عند x=112 على خطّ أساس 81، وأيقونتا الفيديو والمكالمة عند 323 و379.
class ConversationHeader extends StatelessWidget {
  const ConversationHeader({
    super.key,
    required this.name,
    required this.photo,
    required this.unreadCount,
    required this.onBack,
    required this.onOpenProfile,
    required this.onVideoCall,
    required this.onVoiceCall,
    this.statusLine,
    this.isMenuOpen = false,
  });

  /// قائمة رسالةٍ مفتوحة — يسقط ظلّ الترويسة.
  final bool isMenuOpen;

  /// سطر «يكتب الآن / متصل / آخر ظهور» تحت الاسم.
  ///
  /// ميزةٌ عندنا لا يحويها تصميم الويب، فتُمرَّر من الخارج ويُترك مكانها
  /// فارغاً إن لم تُمرَّر — فتعود الترويسة إلى التصميم حرفياً.
  final Widget? statusLine;

  final String name;

  /// صورة الطرف الآخر — تُبنى خارجاً لأن مصدرها يخصّ الشاشة الحاضنة.
  final Widget photo;

  /// عدد غير المقروء في **بقية** المحادثات، كما في الويب.
  final int unreadCount;

  final VoidCallback onBack;
  final VoidCallback onOpenProfile;
  final VoidCallback onVideoCall;
  final VoidCallback onVoiceCall;

  static const String _medium = 'Quicksand-Medium';
  static const String _sfRounded = 'SF-Pro-Rounded-Regular';

  @override
  Widget build(BuildContext context) {
    // خطوط الأساس في الملف محسوبةٌ من أعلى الصفحة؛ والترويسة تبدأ عند 50،
    // فنطرحها لنحصل على الإزاحة داخلها.
    const double baseline = 81 - ContactDesign.statusBar;

    return Container(
      // الملف يرسمها 50 تماماً؛ وسطر الحالة إضافةٌ عندنا فتكبر بقدره وحده.
      constraints: BoxConstraints(minHeight: ContactDesign.statusBar.h),
      decoration: BoxDecoration(
        color: Colors.white,
        // الظلّ يختفي حين تُفتح قائمة: الغشاوة تغطّي الترويسة أيضاً، وظلٌّ
        // تحتها يرسم خطّاً فوق الغشاوة.
        boxShadow: isMenuOpen ? null : ChatDesign.headerShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشيفرون 11×23 عند x=18.5 و y=63.5.
          Padding(
            padding: EdgeInsetsDirectional.only(start: 18.5.w, top: 13.5.h),
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const XdIcon('chatBackPurple', width: 11, height: 23),
            ),
          ),

          // عدّاد غير المقروء: من x=40 إلى الصورة عند 62، SF Pro Rounded 18.
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: (40 - (18.5 + 11)).w,
              top: ContactDesign.sfTop(baseline, 18, 22).h,
            ),
            child: SizedBox(
              width: (62 - 40).w,
              child: Text(
                unreadCount > 0 ? '$unreadCount' : '',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: _sfRounded,
                  fontSize: 18.sp,
                  height: 22 / 18,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: ContactDesign.purple,
                ),
              ),
            ),
          ),

          // الصورة والاسم — معاً يفتحان البروفايل.
          Expanded(
            child: GestureDetector(
              onTap: onOpenProfile,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 38.w,
                    height: 38.h,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    // الإطار فوق الصورة لا تحتها — وإلّا قُصّ عند الزوايا.
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white),
                    ),
                    child: photo,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 12.w,
                        top: ContactDesign.textTop(baseline, 16).h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DesignText(name, size: 16, family: _medium),
                          if (statusLine != null) statusLine!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // الفيديو عند x=323، والمكالمة عند 379، كلتاهما 26 عند y=62.
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: GestureDetector(
              onTap: onVideoCall,
              behavior: HitTestBehavior.opaque,
              child: const XdIcon('chatHeaderVideo', width: 26, height: 26),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: (379 - 349).w,
              end: (430 - 405).w,
              top: 12.h,
            ),
            child: GestureDetector(
              onTap: onVoiceCall,
              behavior: HitTestBehavior.opaque,
              child: const XdIcon('chatHeaderCall', width: 26, height: 26),
            ),
          ),
        ],
      ),
    );
  }
}
