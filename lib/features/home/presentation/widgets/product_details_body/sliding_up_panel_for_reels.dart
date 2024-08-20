import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/reel_widget.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../trydos_application.dart';
import '../../../../app/my_text_widget.dart';

class SlidingUpPanelForReels extends StatelessWidget {
  const SlidingUpPanelForReels({super.key, required this.panelController});

  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 100,
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          return Container(
            height: 1.sh - 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xffFEFEFE),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.chromeIconSvg,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        'Buyers Camera 12 Shot',
                        style: context.textTheme.titleLarge?.rq
                            .copyWith(color: const Color(0xff8D8D8D)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SvgPicture.asset(
                        AppAssets.registerInfoSvg,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextWidget(
                        'These Shots Are Made By Users Who Have Already Purchased And Received The Product',
                        style: context.textTheme.titleMedium?.rq.copyWith(
                            height: 1.23,
                            color: Color(0xffC4C2C2),
                            fontSize: 11.sp),
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
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                        itemBuilder: (ctx, index) {
                          return const ReelWidget();
                        },
                        separatorBuilder: (ctx, index) => const SizedBox(height: 15),
                        itemCount: 10),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
