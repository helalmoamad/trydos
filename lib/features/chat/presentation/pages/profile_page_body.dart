import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// جسم شاشة بروفايل المحادثة بالتصميم الجديد.
///
/// منقولٌ بالبكسل من `web_design/components/DemoApp1/screens/ContactScreen.tsx`.
/// كل رقمٍ هنا مأخوذٌ من ملف XD عبر ذلك الملف، ومكتوبٌ بجانبه مصدره.
///
/// الشكل وحده: لا يعرف بلوكاً ولا مستودعاً. كل فعلٍ يصل إليه ردَّ نداءٍ من
/// الشاشة الحاضنة، فيبقى المنطق حيث هو.
class ContactProfileBody extends StatelessWidget {
  const ContactProfileBody({
    super.key,
    required this.photo,
    required this.name,
    required this.phone,
    required this.isBlocked,
    required this.isCallEnabled,
    required this.onBack,
    required this.onCall,
    required this.onVideo,
    required this.onSearch,
    required this.onMedia,
    required this.onDeleteChat,
    required this.onToggleBlock,
    required this.onShare,
    this.saveToGalleryValue,
    this.notificationValue,
  });

  /// صورة الطرف الآخر — تُبنى في الشاشة الحاضنة لأنها تعرف مصدرها.
  final Widget photo;
  final String name;
  final String phone;
  final bool isBlocked;

  /// المكالمات مفعّلة مع هذا الشخص. يحدّد أيّ الفعلين يُعرض: التعطيل أم
  /// التفعيل.
  final bool isCallEnabled;

  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onVideo;
  final VoidCallback onSearch;
  final VoidCallback onMedia;
  final VoidCallback onDeleteChat;
  final VoidCallback onToggleBlock;

  /// يشارك جهة الاتصال بورقة مشاركة النظام.
  final VoidCallback onShare;

  final String? saveToGalleryValue;
  final String? notificationValue;

  // أسماء العائلات كما تُسجَّل في `pubspec.yaml`.
  static const String _regular = 'Quicksand-Regular';
  static const String _medium = 'Quicksand-Medium';
  static const String _sfRounded = 'SF-Pro-Rounded-Regular';

  @override
  Widget build(BuildContext context) {
    // خطّ أساس كلمات الأزرار الثلاثة: 405 في الملف.
    final double labelTop = ContactDesign.textTop(405, 13);
    const double actionsTop = 358;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شيفرون الرجوع: 11×23 عند x=18.5 و y=63.5، ويمرّر مع الصفحة.
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 18.5.w,
              top: (63.5 - ContactDesign.statusBar).h,
            ),
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const XdIcon('contactBackBlue', width: 11, height: 23),
            ),
          ),

          // الصورة: 131×150، نصف قطر 30، خطّ بنفسجي 1، مركزها y=102.
          Align(
            child: Container(
              margin: EdgeInsets.only(top: (102 - (63.5 + 23)).h),
              width: 131.w,
              height: 150.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
              ),
              // الإطار في `foregroundDecoration` لا في `decoration`.
              //
              // الخلفية تُرسم **تحت** الابن، فالصورة المقصوصة كانت تغطّي
              // الإطار عند الزوايا حيث يلتقي القصّ بالحدّ — فيظهر مقطوعاً.
              // ورسمه في المقدّمة يضعه **فوق** الصورة، فيكتمل.
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: ContactDesign.purple),
              ),
              child: photo,
            ),
          ),

          // الاسم 16 Medium على خطّ أساس 280، والرقم 16 Regular على 304.
          Padding(
            padding: EdgeInsets.only(
              top: (ContactDesign.textTop(280, 16) - 252).h,
            ),
            child: SizedBox(
              width: double.infinity,
              child: DesignText(name, size: 16, family: _medium, center: true),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top:
                  (ContactDesign.textTop(304, 16) -
                          ContactDesign.textBottom(280, 16))
                      .h,
            ),
            child: SizedBox(
              width: double.infinity,
              child: DesignText(
                phone,
                size: 16,
                family: _regular,
                center: true,
              ),
            ),
          ),

          // ثلاثة أعمدة متساوية من x=16.5 إلى 14.5 قبل الحافّة المقابلة.
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 16.5.w,
              end: 14.5.w,
              top: (actionsTop - ContactDesign.textBottom(304, 16)).h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Action(
                  icon: 'chatHeaderCall',
                  label: LocaleKeys.call.tr(),
                  onTap: onCall,
                  labelGap: labelTop - actionsTop - 26,
                ),
                _Action(
                  icon: 'chatHeaderVideo',
                  label: LocaleKeys.video.tr(),
                  onTap: onVideo,
                  labelGap: labelTop - actionsTop - 26,
                ),
                _Action(
                  icon: 'contactSearch',
                  label: LocaleKeys.search.tr(),
                  onTap: onSearch,
                  labelGap: labelTop - actionsTop - 26,
                ),
              ],
            ),
          ),

          // ثلاثة صفوف 406×60 من y=458، بتباعد 2.
          _Row(
            icon: 'rowMedia',
            label: LocaleKeys.media_files.tr(),
            onTap: onMedia,
            top: 458 - (labelTop + ContactDesign.lineBox(13)),
          ),
          _Row(
            icon: 'rowGallery',
            label: LocaleKeys.save_to_gallery.tr(),
            value: saveToGalleryValue,
            top: ContactDesign.rowGap,
          ),
          _Row(
            icon: 'rowGallery',
            label: LocaleKeys.notification_row.tr(),
            value: notificationValue,
            top: ContactDesign.rowGap,
          ),

          // سطر تفعيل المكالمة: SF Pro Rounded 12 على خطّ أساس 670، ينتهي 22
          // قبل الحافّة.
          //
          // ملف XD يرصف الحالتين فوق بعضهما — عادةُ المصمّمين في عرض الحالات،
          // لا نيّةُ إظهارهما معاً. فنعرض الفعل المتاح وحده.
          //
          // و`SizedBox(width: double.infinity)` ضروري: العمود الحاضن محاذاته
          // `start`، فابنٌ يلتفّ حول عرضه كان يستقرّ في البداية مهما طُلبت
          // محاذاة النهاية.
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: (430 - 408).w,
              top: (ContactDesign.sfTop(670, 12, 17) - 642).h,
            ),
            child: SizedBox(
              width: double.infinity,
              // ارتفاع 34 — سطران من 17.
              //
              // الملف يرسم الحالتين سطرين، والشاشة تعرض واحدة. والسطر
              // الثاني يبقى **محجوزاً فارغاً** كي لا تقفز الكتل تحته.
              height: 34.h,
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                // انتقالٌ قصير عند تبدّل الحالة: صعودٌ 4 مع تلاشٍ في 0.16.
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  // سطرٌ بلا فعل — كما في الويب: الملف يرسم الكلمتين
                  // والديمو لا يربطهما بشيء، ولا طلب عندنا لتفعيل المكالمة
                  // أو تعطيلها. فيبقى تصميماً حتى يجهز الطرف الخلفي.
                  child: _SfLine(
                    isCallEnabled
                        ? LocaleKeys.disable_call.tr()
                        : LocaleKeys.enable_call.tr(),
                    key: ValueKey<bool>(isCallEnabled),
                  ),
                ),
              ),
            ),
          ),

          // الصفّ السفلي: حذف المحادثة، الحظر ورفعه، المشاركة.
          Padding(
            padding: EdgeInsets.only(
              top: (768 - (ContactDesign.sfTop(670, 12, 17) + 34)).h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BottomAction(
                  icon: 'deleteChat',
                  label: LocaleKeys.delete_chat.tr(),
                  color: ContactDesign.greyText,
                  startMargin: 61,
                  width: 125 - 61,
                  iconStart: 79 - 61,
                  onTap: onDeleteChat,
                ),
                Container(
                  margin: EdgeInsetsDirectional.only(start: (238 - 125).w),
                  width: (268 - 238).w,
                  child: Column(
                    children: [
                      _BottomAction(
                        icon: isBlocked ? 'blockGrey' : 'blockRed',
                        label: isBlocked
                            ? LocaleKeys.un_block.tr()
                            : LocaleKeys.block.tr(),
                        color: ContactDesign.red,
                        startMargin: 0,
                        width: 30,
                        iconStart: 2,
                        onTap: onToggleBlock,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: (339 - 268).w,
                    top: (ContactDesign.sfTop(814, 12, 17) - 768).h,
                  ),
                  child: GestureDetector(
                    onTap: onShare,
                    behavior: HitTestBehavior.opaque,
                    child: _SfLine(LocaleKeys.share_contact.tr()),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

/// عمودٌ من الثلاثة: أيقونة 26 في الوسط وكلمتها 13 Medium تحتها.
class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.labelGap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  /// المسافة بين أسفل الأيقونة وأعلى صندوق كلمتها.
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            XdIcon(icon, width: 26, height: 26),
            SizedBox(height: labelGap.h),
            DesignText(
              label,
              size: 13,
              family: ContactProfileBody._medium,
              center: true,
              // تباعد الملف: 0.01em عند 13 بكسل.
              letterSpacing: 13 * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}

/// صفّ 406×60: أيقونة 18 على بعد 12، الكلمات عند x=54، وقيمةٌ تنتهي 6 قبل
/// الحافّة.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.top,
    this.value,
    this.onTap,
  });

  final String icon;
  final String label;
  final double top;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: ContactDesign.rowX.w,
        end: ContactDesign.rowX.w,
        top: top.h,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: ContactDesign.rowHeight.h,
          decoration: BoxDecoration(
            color: ContactDesign.card,
            borderRadius: BorderRadius.circular(ContactDesign.rowRadius.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: 12.w, top: 21.h),
                child: XdIcon(icon, width: 18, height: 18),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: (54 - 24 - 18).w,
                  top: ContactDesign.textTop(35, 14).h,
                ),
                child: DesignText(
                  label,
                  size: 14,
                  family: ContactProfileBody._regular,
                ),
              ),
              const Spacer(),
              if (value != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: 6.w,
                    top: ContactDesign.textTop(35, 14).h,
                  ),
                  child: DesignText(
                    value!,
                    size: 14,
                    family: ContactProfileBody._regular,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// سطر SF Pro Rounded 12 بارتفاع 17 وتباعد حرفي 0.01em.
class _SfLine extends StatelessWidget {
  const _SfLine(this.label, {super.key});

  final String label;
  static const Color color = ContactDesign.ink;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      style: TextStyle(
        fontFamily: ContactProfileBody._sfRounded,
        fontSize: 12.sp,
        height: 17 / 12,
        leadingDistribution: TextLeadingDistribution.even,
        letterSpacing: 12 * 0.01,
        color: color,
      ),
    );
  }
}

/// أيقونة 25 وكلمتها تحتها بخطّ SF Pro Rounded.
class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.startMargin,
    required this.width,
    required this.iconStart,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final double startMargin;
  final double width;
  final double iconStart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsetsDirectional.only(start: startMargin.w),
        width: width.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: iconStart.w),
              child: XdIcon(icon, width: 25, height: 25),
            ),
            SizedBox(height: (ContactDesign.sfTop(814, 12, 17) - (768 + 25)).h),
            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: ContactProfileBody._sfRounded,
                  fontSize: 12.sp,
                  height: 17 / 12,
                  leadingDistribution: TextLeadingDistribution.even,
                  letterSpacing: 12 * 0.01,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
