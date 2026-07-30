import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../app/my_text_widget.dart';

class ShippingDeliveryDatePanel extends StatelessWidget {
  final String shippingDay;
  final double shippingCost;
  final String countryName;
  const ShippingDeliveryDatePanel({
    super.key,
    required this.panelController,
    required this.shippingDay,
    required this.shippingCost,
    required this.countryName,
  });

  final PanelController panelController;

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
      controller: panelController,
      maxHeight: 1.sh - 65.h,
      backdropEnabled: true,
      panelBuilder: (scrollController) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: 1.sh - 65.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: const Color(0xffFEFEFE),
          ),
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
                previous.getDeliveredOrdersResponseStatus !=
                current.getDeliveredOrdersResponseStatus,
            builder: (context, state) {
              if (state.deliveredOrdersResponse?.data.deliveredOrders == null) {
                return const SizedBox();
              }
              final deliveredOrders =
                  state.deliveredOrdersResponse!.data.deliveredOrders;

              final statistics = getDeliveryStatistics(deliveredOrders);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: (1.sw / 2) - 40.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        color: const Color(0xffC4C2C2),
                      ),
                      height: 2.h,
                      width: 40.w,
                    ),
                    SizedBox(height: 5.h),
                    SvgPicture.asset(
                      AppAssets.deliveryPathSvg,
                      // ignore: deprecated_member_use
                      color: const Color(0xff1D1D1D),
                      height: 30.h,
                    ),
                    SizedBox(height: 10.h),
                    MyTextWidget(
                      LocaleKeys.expected_shipping_delivery_date.tr(),
                      style: context.textTheme.titleLarge?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Builder(
                      builder: (context) {
                        // Parse shippingDay to int
                        final shippingDays = int.tryParse(shippingDay) ?? 0;
                        // Calculate the delivery date
                        final deliveryDate = DateTime.now().add(
                          Duration(days: shippingDays),
                        );

                        // Get current locale
                        final locale = context.locale.toString();

                        // Format day name (EEEE = full weekday name)
                        final dayName = DateFormat(
                          'EEEE',
                          locale,
                        ).format(deliveryDate);

                        // Format date (d MMM = day abbreviated month)
                        final formattedDate = DateFormat(
                          'd MMM',
                          locale,
                        ).format(deliveryDate);

                        return Row(
                          children: [
                            MyTextWidget(
                              '$dayName ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                height: 16 / 13,
                                fontSize: 11.sp,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '$formattedDate | ',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                height: 16 / 13,
                                fontSize: 11.sp,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '${shippingDay} ${LocaleKeys.work_days_at_your_address_in.tr()} ${countryName}',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                height: 16 / 13,
                                fontSize: 11.sp,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xffD3D3D3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      height: 0.5.h,
                      width: 1.sw,
                    ),
                    Row(
                      children: [
                        MyTextWidget(
                          LocaleKeys.shipping_company.tr(),
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          ' Trydos',
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xffD3D3D3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      height: 0.5.h,
                      width: 1.sw,
                    ),
                    MyTextWidget(
                      LocaleKeys
                          .based_on_previous_delivery_statistics_below_to_your_area_we_conclude
                          .tr(),
                      style: context.textTheme.titleLarge?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 11.sp,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        MyTextWidget(
                          LocaleKeys
                              .that_the_expected_delivery_time_for_your_product_is
                              .tr(),
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                        MyTextWidget(
                          ' ${shippingDay} ${LocaleKeys.day.tr()}',
                          style: context.textTheme.titleLarge?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xffD3D3D3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      height: 0.5.h,
                      width: 1.sw,
                    ),

                    ...statistics.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: _buyerReviewSingle(
                          item["day"].toString(),
                          item["percent"],
                          context,
                        ),
                      );
                    }).toList(),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xffD3D3D3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      height: 0.5,
                      width: 1.sw,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.deliveryGuranteeSvg,
                          width: 20.w,
                        ),
                        const SizedBox(height: 5),
                        MyTextWidget(
                          '${LocaleKeys.delivery_guarantee.tr()}',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SvgPicture.asset(AppAssets.dolarSvg),
                            SizedBox(width: 5.w),
                            MyTextWidget(
                              '${LocaleKeys.get_a.tr()}',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              ' 20% ${LocaleKeys.refund.tr()} ',
                              style: context.textTheme.titleLarge?.mq.copyWith(
                                fontSize: 11,
                                height: 16 / 13,
                                color: const Color(0xff388CFF),
                              ),
                            ),
                            MyTextWidget(
                              '${LocaleKeys.of_the_product_price_if_shipping.tr()}',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        SvgPicture.asset(
                          AppAssets.freeShippingSvg,
                          width: 20.w,
                        ),
                        SizedBox(height: 5.h),
                        MyTextWidget(
                          '${LocaleKeys.free_shipping.tr()}',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        MyTextWidget(
                          '${LocaleKeys.shipping_is_completely_free_without_any_extras.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SvgPicture.asset(
                          AppAssets.returnGuranteeSvg,
                          width: 20.w,
                        ),
                        SizedBox(height: 5.h),
                        MyTextWidget(
                          '${LocaleKeys.return_guarantee.tr()}',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            MyTextWidget(
                              '${LocaleKeys.within.tr()}',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              ' ${shippingDay} ${LocaleKeys.day.tr()} ',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '${LocaleKeys.after_receiving_product_return_without_conditions.tr()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            SvgPicture.asset(AppAssets.dolarSvg),
                            SizedBox(width: 5.w),
                            MyTextWidget(
                              '${LocaleKeys.get_a.tr()} ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            /*  MyTextWidget(
                                  '${LocaleKeys.full.tr()} ',
                                  style: context.textTheme.titleLarge?.mr.copyWith(
                                      fontSize: 11.sp,
                                      height: 16 / 13,
                                      color: const Color(0xff388CFF)),
                                ),*/
                            MyTextWidget(
                              LocaleKeys.the_product_price_when_returned.tr(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            MyTextWidget(
                              '${LocaleKeys.or_reasons_with_complete_ease_and.tr()} ',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '${LocaleKeys.get_the_amount_back.tr()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.titleLarge?.mq.copyWith(
                                fontSize: 11.sp,
                                height: 16 / 13,
                                color: const Color(0xff388CFF),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        SvgPicture.asset(AppAssets.freeReturnSvg, width: 20.w),
                        SizedBox(height: 5.h),
                        MyTextWidget(
                          '${LocaleKeys.free_return.tr()}',
                          style: context.textTheme.titleLarge?.mq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        MyTextWidget(
                          '${LocaleKeys.return_is_completely_free_without_any_extras.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buyerReviewSingle(
    String day,
    int numOfPercent,
    BuildContext context,
  ) {
    return SizedBox(
      width: 1.sw,
      height: 20.h,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 15.h,
                width: 284.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xffD3D3D3)),
                ),
              ),
              Container(
                height: 15.h,
                width: (numOfPercent / 100) * 284.w,
                decoration: BoxDecoration(
                  color: const Color(0xff1D1D1D),
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: const Color(0xff1D1D1D)),
                ),
              ),
            ],
          ),
          const Spacer(),
          MyTextWidget(
            "${numOfPercent}%",
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11.sp,
            ),
          ),
          const Spacer(),
          MyTextWidget(
            day,
            style: context.textTheme.titleLarge?.bq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11.sp,
            ),
          ),
          MyTextWidget(
            " ${LocaleKeys.day.tr()}",
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11.sp,
            ),
          ),
          SizedBox(width: day == "10" ? 5.w : 10.w),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> getDeliveryStatistics(List deliveredOrders) {
    final totalOrders = deliveredOrders.fold<num>(
      0,
      (sum, item) => sum + item.ordersCount,
    );

    final Map<int, int> ordersByDay = {
      for (var item in deliveredOrders) item.daysCount: item.ordersCount,
    };

    return List.generate(10, (index) {
      final day = index + 1;

      final count = ordersByDay[index] ?? 0;

      final percent = totalOrders == 0
          ? 0
          : ((count / totalOrders) * 100).round();

      return {
        "day": day.toString() == "10" ? "+" + day.toString() : day.toString(),
        "percent": percent,
        "count": count,
      };
    });
  }
}
