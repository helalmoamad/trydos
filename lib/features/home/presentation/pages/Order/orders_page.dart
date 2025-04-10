import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import '../../../../../common/constant/constant.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../app/my_cached_network_image.dart';
import 'order_details1_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            buildHeader(context),
            ///////////////////
            SizedBox(
              height: 11.h,
            ),
            ///////////////////
            buildStatusBar(),
            ///////////////////
            SizedBox(
              height: 50.h,
            ),
            ///////////////////
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      HelperFunctions.slidingNavigation(
                        context,
                        OrderDetails1(),
                      );
                    },
                    child: buildOrderItemWidget(context),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 10.h,
                  );
                },
              ),
            ),
            ///////////////////
            SizedBox(
              height: 10.h,
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildOrderItemWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            buildInfoWidget(
              isSecondInfo: false,
              isTextSpan: false,
              context: context,
              text1: 'Today | 13:59:00',
              text2: 'TTISA10012',
              svgIcon1: AppAssets.orderClockSvg,
              svgIcon2: AppAssets.orderBag1Svg,
              amount: '',
              currency: '',
              itemsCount: '',
            ),
            ///////////////////
            const SizedBox(
              height: 11,
            ),
            ///////////////////
            buildInfoWidget(
              isSecondInfo: true,
              context: context,
              isTextSpan: true,
              text1: 'Preparing',
              text2: '',
              svgIcon1: AppAssets.orderBag2Svg,
              svgIcon2: AppAssets.orderInvoice2Svg,
              secondInfoSvgIcon: AppAssets.orderPreparingSvg,
              amount: '200',
              currency: 'USD',
              itemsCount: '2',
            ),
            ///////////////////
            const SizedBox(
              height: 11,
            ),
            ///////////////////

            SizedBox(
              height: 125,
              width: double.infinity,
              child: ListView.separated(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white,
                      child: MyCachedNetworkImage(
                        imageUrl:
                            'https://res.cloudinary.com/dtcmozf4d/image/upload/v1/product/2025-02-24-67bc4c4a5eb5f.png',
                        imageFit: BoxFit.contain,
                        width: 90,
                        height: 125,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 5,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfoWidget({
    required bool isSecondInfo,
    required BuildContext context,
    required String svgIcon1,
    required String svgIcon2,
    String? secondInfoSvgIcon,
    required String text1,
    required String text2,
    required bool isTextSpan,
    required String itemsCount,
    required String amount,
    required String currency,
  }) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  svgIcon1,
                  width: 15,
                ),
                ///////////////////////////
                const SizedBox(
                  width: 5,
                ),
                ///////////////////////////
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    text1,
                    // LocaleKeys.order_invoice.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                ////////////////////////////
                isSecondInfo
                    ? const SizedBox(
                        width: 5,
                      )
                    : const SizedBox.shrink(),
                ///////////////////
                isSecondInfo
                    ? SvgPicture.asset(
                        secondInfoSvgIcon ?? '',
                        width: 15,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          /////////////////////////
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  svgIcon2,
                  width: 15,
                ),
                ///////////////////////////
                SizedBox(
                  width: 5,
                ),
                ///////////////////////////
                isTextSpan
                    ? Flexible(
                        fit: FlexFit.loose,
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff505050),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text: itemsCount,
                                style:
                                    context.textTheme.bodyMedium?.bq.copyWith(
                                  color: const Color(0xff505050),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const TextSpan(text: ' Item . '),
                              TextSpan(
                                text: amount,
                                style:
                                    context.textTheme.bodyMedium?.bq.copyWith(
                                  color: const Color(0xff505050),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              TextSpan(text: ' $currency'),
                            ],
                          ),
                        ),
                      )
                    : Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          text2,
                          // LocaleKeys.order_invoice.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: SizedBox(
        height: 26,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return index == 0
                ? SvgPicture.asset(
                    AppAssets.orderStatusFilterSvg,
                    width: 25,
                  )
                : index == 1
                    ? Container(
                        height: 26,
                        width: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'All',
                            // LocaleKeys.order_invoice.tr(),
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 26,
                        width: 82,
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Status',
                            // LocaleKeys.order_invoice.tr(),
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemCount: 10,
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xffFFFFFF),
      height: 50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                AppAssets.backIconArrowSvg,
                width: 11,
              ),
            ),
            ///////////////////////////////////
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.bagsSvg,
                    width: 23,
                  ),
                  ///////////////////////////
                  SizedBox(
                    width: 4,
                  ),
                  ///////////////////////////
                  Text(
                    'Orders',
                    // LocaleKeys.order_invoice.tr(),
                    style: context.textTheme.bodyMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  ///////////////////////////
                  SizedBox(
                    width: 15,
                  ),
                  ///////////////////////////
                ],
              ),
            ),
            ////////////
          ],
        ),
      ),
    );
  }
}
