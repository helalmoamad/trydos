import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/reel_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class SlidingUpPanelForReels extends StatelessWidget {
  const SlidingUpPanelForReels({super.key, required this.panelController});

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      minHeight: 0,
      controller: panelController,
      maxHeight: 1.sh - 100.h,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return Container(
          height: 1.sh - 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: const Color(0xffFEFEFE),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AppAssets.chromeIconSvg, height: 20.h),
                    SizedBox(width: 5.w),
                    MyTextWidget(
                      '${LocaleKeys.buyers_camera.tr()} 12 ${LocaleKeys.shot.tr()}',
                      style: context.textTheme.titleLarge?.rq.copyWith(
                        color: const Color(0xff8D8D8D),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    SvgPicture.asset(AppAssets.registerInfoSvg, height: 12.h),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Padding(
                padding: EdgeInsets.only(left: 45.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextWidget(
                      '${LocaleKeys.these_shots_are_made_by_users.tr()}',
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        height: 1.23,
                        color: const Color(0xffC4C2C2),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: const CupertinoScrollBehavior(),
                  child: ListView.separated(
                    shrinkWrap: true,
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: 10.w,
                      top: 15.h,
                    ),
                    itemBuilder: (ctx, index) {
                      return const ReelWidget();
                    },
                    separatorBuilder: (ctx, index) => SizedBox(height: 15.h),
                    itemCount: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
