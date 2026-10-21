import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/features/chat/data/models/message_tag_model.dart';

/// أيقونة الوسم في ذيل الفقاعة، وبالضغط عليها لوحةٌ داكنة بأسماء الوسوم.
///
/// الأسماء لا تُعرض في الفقاعة نفسها: الوسم قد يبلغ ثلاثين حرفاً وقد تحمل
/// الرسالة عدّة وسوم، فعرضها كلّها يطغى على نصّ الرسالة. فتبقى أيقونةً
/// واحدة، واللوحة تُظهرها عند الطلب.
class MessageTagsIndicator extends StatefulWidget {
  const MessageTagsIndicator({super.key, required this.tags});

  final List<MessageTag> tags;

  @override
  State<MessageTagsIndicator> createState() => _MessageTagsIndicatorState();
}

class _MessageTagsIndicatorState extends State<MessageTagsIndicator> {
  static const Color _panel = Color(0xff3A3B3C);
  static const Color _dot = Color(0xffB0B3B8);

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) => _overlay(),
        child: GestureDetector(
          onTap: _controller.toggle,
          child: SvgPicture.asset(
            AppAssets.addToGroupSvg,
            width: 10.sp,
            height: 10.sp,
          ),
        ),
      ),
    );
  }

  Widget _overlay() {
    return Stack(
      children: [
        // ضغطةٌ في أي مكان تُغلق اللوحة. بلا هذا تبقى معلّقة فوق المحادثة
        // ويمرّر المستخدم الرسائل من تحتها.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _controller.hide,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          // فوق الأيقونة لا تحتها: الذيل قريبٌ من أسفل الشاشة في أحدث
          // الرسائل، واللوحة تحته تُقصّ.
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: Offset(0, -4.h),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: 180.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final MessageTag tag in widget.tags)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: _dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              tag.tag,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white,
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
        ),
      ],
    );
  }
}
