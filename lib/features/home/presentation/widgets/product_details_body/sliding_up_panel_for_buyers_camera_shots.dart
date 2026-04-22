import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../trydos_application.dart';
import '../../../../app/my_text_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class SlidingUpPanelForBuyersCameraShots extends StatelessWidget {
  const SlidingUpPanelForBuyersCameraShots({
    super.key,
    required this.panelController,
    required this.panelControllerForReels,
  });

  final PanelController panelController;
  final PanelController panelControllerForReels;
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SlidingUpPanel(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.w),
        topRight: Radius.circular(20.w),
      ),
      minHeight: 0,
      onPanelClosed: () {
        denySlidingBackForSlidingUpPanels.value = false;
      },
      onPanelOpened: () {
        denySlidingBackForSlidingUpPanels.value = true;
      },
      controller: panelController,
      maxHeight: 1.sh - 100.h,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return Container(
          height: 1.sh - 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: const Color(0xffF8F8F8),
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
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 195 / 277,
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 25.w,
                      right: 25.w,
                      top: 15.h,
                    ),
                    crossAxisSpacing: 10.w,
                    primary: false,
                    mainAxisSpacing: 10.h,
                    physics: const ClampingScrollPhysics(),
                    children: List.generate(
                      20,
                      (index) => GestureDetector(
                        onTap: () {
                          panelControllerForReels.open();
                        },
                        child: ProductDetailsImageWidget(
                          radius: 30.r,
                          width: 185.w,
                          height: 267.h,
                          imageFit: BoxFit.fill,
                        ),
                      ),
                    ),
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
