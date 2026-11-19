import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// تبويبا شاشة المحادثات.
enum ChatListTabV2 { chats, calls }

/// ترويسة شاشة المحادثات: حقل البحث وشريط التبويبين.
///
/// منقولةٌ بالبكسل من رأس `ChatListScreen` في
/// `web_design/components/DemoApp1/screens/ChatListScreen.tsx` على فرع
/// `development` (لوح XD `Home Page – 41`):
///
/// > **الترويسة 50 .. 150، بيضاء، لاصقة:**
/// >
/// > * حقل البحث كما في شاشة البحث: 406×38 عند (12، 56) بنصف قطر 12 ولون
/// >   `#F8F8F8`، والعدسة عند (21.5، 65.5)، والكلمات عند x=52 على خطّ
/// >   الأساس 80 بخطّ 14 Regular `#8D8D8D`. وللشريط ظلُّ الملف (0 0 3 بأسود
/// >   10٪)، **والشريط الأبيض تحته يغطّي ذلك الظلّ**.
/// > * شريط «المحادثات | المكالمات» 100 .. 150: الظرف (25×25 عند 129، 113)
/// >   والهاتف (265، 113) وعدداهما بعدهما بـ4.26 على خطّ الأساس 125 بخطّ
/// >   12 Medium. والكتلة عرضها 172.5 وموسَّطة. والتبويب المفتوح وحده يُظهر
/// >   كلمتَه، محاذاةً إلى اليمين قبل أيقونته بـ7 (محادثات) أو 6 (مكالمات)،
/// >   على خطّ الأساس 135.
class ChatListHeaderV2 extends StatelessWidget {
  const ChatListHeaderV2({
    super.key,
    required this.controller,
    required this.hint,
    required this.tab,
    required this.onTab,
    required this.chatsLabel,
    required this.callsLabel,
    required this.chatsCount,
    required this.callsCount,
    this.onQueryChanged,
  });

  /// مُتحكّم حقل البحث — تملكه الشاشة الحاضنة.
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onQueryChanged;

  final ChatListTabV2 tab;
  final ValueChanged<ChatListTabV2> onTab;

  final String chatsLabel;
  final String callsLabel;

  /// عددا التبويبين كما يعرضهما الملف بجانب أيقونتيهما.
  final String chatsCount;
  final String callsCount;

  /// ارتفاع الترويسة كلّها: شريط البحث 50 وشريط التبويبين 50.
  static const double height =
      ChatListDesign.searchStrip + ChatListDesign.tabStrip;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // جهاتٌ مطلقة كالملف: العدسة قبل الكلمات، وترتيب التبويبين ثابت.
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: height.h,
        child: Column(children: [_searchStrip(), _tabStrip()]),
      ),
    );
  }

  /// شريط البحث بظلّه.
  Widget _searchStrip() {
    return Container(
      height: ChatListDesign.searchStrip.h,
      decoration: const BoxDecoration(
        color: ChatListDesign.white,
        boxShadow: ChatListDesign.stripShadow,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          // 406 من 430 — أي 12 من كل جهة. والحقل يبدأ عند 56، والشريط عند 50.
          margin: EdgeInsets.only(
            left: ChatListDesign.fieldX.w,
            right: ChatListDesign.fieldX.w,
            top: 6.h,
          ),
          height: ChatListDesign.fieldHeight.h,
          decoration: BoxDecoration(
            color: ChatListDesign.field,
            borderRadius: BorderRadius.circular(ChatListDesign.fieldRadius.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: ChatListDesign.glassInset.w,
                  top: ChatListDesign.glassInset.h,
                ),
                child: const XdIcon('searchGlass', width: 18.99),
              ),
              Expanded(
                child: Padding(
                  // الكلمات عند x=40 داخل الحقل، والعدسة تنتهي عند 9.5+18.99.
                  padding: EdgeInsets.only(
                    left: (40 - (ChatListDesign.glassInset + 18.99)).w,
                    right: 12.w,
                    top: 7.h,
                  ),
                  child: SizedBox(
                    height: 24.h,
                    child: TextField(
                      controller: controller,
                      onChanged: onQueryChanged,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: 'Quicksand-Regular',
                        fontSize: 14.sp,
                        height: ContactDesign.lineBox(14) / 14,
                        leadingDistribution: TextLeadingDistribution.even,
                        color: ChatListDesign.ink,
                      ),
                      cursorColor: ChatListDesign.purple,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(
                          fontFamily: 'Quicksand-Regular',
                          fontSize: 14.sp,
                          height: ContactDesign.lineBox(14) / 14,
                          leadingDistribution: TextLeadingDistribution.even,
                          color: ChatListDesign.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// شريط التبويبين — أبيضُ **بعد** شريط البحث فيغطّي ظلَّه.
  Widget _tabStrip() {
    const double block = ChatListDesign.tabBlockWidth;
    return Container(
      height: ChatListDesign.tabStrip.h,
      color: ChatListDesign.white,
      child: Center(
        child: SizedBox(
          width: block.w,
          height: ChatListDesign.tabStrip.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ChatTabButtonV2(
                icon: 'chatTabChats',
                count: chatsCount,
                label: chatsLabel,
                labelGap: ChatListDesign.chatsLabelGap,
                left: 0,
                blockWidth: block,
                on: tab == ChatListTabV2.chats,
                onTap: () => onTab(ChatListTabV2.chats),
              ),
              ChatTabButtonV2(
                icon: 'chatTabCalls',
                count: callsCount,
                label: callsLabel,
                labelGap: ChatListDesign.callsLabelGap,
                left: ChatListDesign.callsTabLeft,
                blockWidth: block,
                on: tab == ChatListTabV2.calls,
                onTap: () => onTab(ChatListTabV2.calls),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// تبويبٌ واحد من الشريط.
///
/// > أيقونتُه عند [left] داخل كتلة الـ172.5، وعددُه بعدها بـ4.26، وكلمتُه —
/// > حين يكون مفتوحاً — معلَّقةٌ على يسار الأيقونة. **والأيقونتان لا
/// > تتحرّكان؛ الكلمةُ وحدها تجيء وتذهب.**
class ChatTabButtonV2 extends StatelessWidget {
  const ChatTabButtonV2({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    required this.labelGap,
    required this.left,
    required this.blockWidth,
    required this.on,
    required this.onTap,
  });

  final String icon;
  final String count;
  final String label;

  /// الفراغ بين الكلمة وأيقونتها: 7 للمحادثات و6 للمكالمات.
  final double labelGap;

  /// موضع الأيقونة داخل الكتلة.
  final double left;
  final double blockWidth;

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الكلمة على يسار الأيقونة: حافّتُها اليمنى عند `left - labelGap`.
        //
        // والكلمة خارج الزرّ في الملف (`right: calc(100% + gap)`)، فلا تُزيح
        // الأيقونة حين تظهر — ولذلك تُرسم هنا بموضعٍ محسوبٍ من الكتلة لا
        // بصفٍّ يدفع ما بعده.
        if (on)
          Positioned(
            right: (blockWidth - left + labelGap).w,
            // خطّ الأساس 135 وشريط التبويبين يبدأ عند 100، والأيقونة عند 113.
            top: (ContactDesign.textTop(135, 12) - 100).h,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: DesignText(
                label,
                size: 12,
                family: 'Quicksand-Medium',
                letterSpacing: 0.02 * 12,
              ),
            ),
          ),
        Positioned(
          left: left.w,
          top: ChatListDesign.tabIconTop.h,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                XdIcon(icon, width: ChatListDesign.tabIconSize),
                Padding(
                  // خطّ الأساس 125 بخطّ 12 — أي أعلى الصندوق 113، بمستوى
                  // أعلى الأيقونة تماماً.
                  padding: EdgeInsets.only(left: ChatListDesign.tabCountGap.w),
                  child: DesignText(
                    count,
                    size: 12,
                    family: 'Quicksand-Medium',
                    letterSpacing: 0.02 * 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
