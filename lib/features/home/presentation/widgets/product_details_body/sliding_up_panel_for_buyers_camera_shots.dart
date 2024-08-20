import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_image_widget.dart';

import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../trydos_application.dart';
import '../../../../app/my_text_widget.dart';

class SlidingUpPanelForBuyersCameraShots extends StatelessWidget {
  const SlidingUpPanelForBuyersCameraShots(
      {super.key,
      required this.panelController,
      required this.panelControllerForReels});

  final PanelController panelController;
  final PanelController panelControllerForReels;
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        onPanelClosed: () {
          denySlidingBackForSlidingUpPanels.value = false;
        },
        onPanelOpened: () {
          denySlidingBackForSlidingUpPanels.value = true;
        },
        controller: panelController,
        maxHeight: 1.sh - 100,
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          return Container(
            height: 1.sh - 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color(0xffF8F8F8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.chromeIconSvg,
                        height: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        'Buyers Camera 12 Shot',
                        style: context.textTheme.titleLarge?.rq
                            .copyWith(color: Color(0xff8D8D8D)),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SvgPicture.asset(
                        AppAssets.registerInfoSvg,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                SizedBox(
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
                    behavior: CupertinoScrollBehavior(),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 195 / 277,
                      controller: scrollController,
                      padding: EdgeInsets.only(left: 25, right: 25, top: 15),
                      crossAxisSpacing: 10,
                      primary: false,
                      mainAxisSpacing: 10,
                      physics: ClampingScrollPhysics(),
                      children: List.generate(
                          20,
                          (index) => GestureDetector(
                                onTap: () {
                                  panelControllerForReels.open();
                                },
                                child: const ProductDetailsImageWidget(
                                  radius: 30,
                                  width: 185,
                                  height: 267,
                                  imageFit: BoxFit.fill,
                                ),
                              )),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
