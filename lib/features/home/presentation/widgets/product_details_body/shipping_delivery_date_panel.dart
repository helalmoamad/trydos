import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
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
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        minHeight: 0,
        controller: panelController,
        maxHeight: 1.sh - 65,
        backdropEnabled: true,
        panelBuilder: (scrollController) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1.sh - 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xffFEFEFE),
            ),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: (1.sw / 2) - 40, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xffC4C2C2)),
                  height: 2,
                  width: 40,
                ),
                const SizedBox(
                  height: 5,
                ),
                SvgPicture.asset(
                  AppAssets.deliveryPathSvg,
                  // ignore: deprecated_member_use
                  color: const Color(0xff1D1D1D),
                  height: 30,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextWidget(
                  LocaleKeys.expected_shipping_delivery_date.tr(),
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff1D1D1D), fontSize: 13),
                ),
                const SizedBox(
                  height: 10,
                ),
                Builder(
                  builder: (context) {
                    // Parse shippingDay to int
                    final shippingDays = int.tryParse(shippingDay) ?? 0;
                    // Calculate the delivery date
                    final deliveryDate =
                        DateTime.now().add(Duration(days: shippingDays));

                    // Get current locale
                    final locale = context.locale.toString();

                    // Format day name (EEEE = full weekday name)
                    final dayName =
                        DateFormat('EEEE', locale).format(deliveryDate);

                    // Format date (d MMM = day abbreviated month)
                    final formattedDate =
                        DateFormat('d MMM', locale).format(deliveryDate);

                    return Row(
                      children: [
                        MyTextWidget(
                          '$dayName ',
                          style: context.textTheme.titleLarge?.rr.copyWith(
                              height: 16 / 13,
                              fontSize: 11,
                              color: const Color(0xff1D1D1D)),
                        ),
                        MyTextWidget(
                          '$formattedDate | ',
                          style: context.textTheme.titleLarge?.br.copyWith(
                              height: 16 / 13,
                              fontSize: 11,
                              color: const Color(0xff1D1D1D)),
                        ),
                        MyTextWidget(
                          '${shippingDay} ${LocaleKeys.work_days_at_your_address_in.tr()} ${countryName}',
                          style: context.textTheme.titleLarge?.rr.copyWith(
                              height: 16 / 13,
                              fontSize: 11,
                              color: const Color(0xff1D1D1D)),
                        ),
                      ],
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffD3D3D3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 0.5,
                  width: 1.sw,
                ),
                Row(
                  children: [
                    MyTextWidget(
                      LocaleKeys.shipping_company.tr(),
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 11),
                    ),
                    MyTextWidget(
                      ' Trydos',
                      style: context.textTheme.titleLarge?.br.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffD3D3D3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 0.5,
                  width: 1.sw,
                ),
                MyTextWidget(
                  LocaleKeys
                      .based_on_previous_delivery_statistics_below_to_your_area_we_conclude
                      .tr(),
                  style: context.textTheme.titleLarge?.rr
                      .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    MyTextWidget(
                      LocaleKeys
                          .that_the_expected_delivery_time_for_your_product_is
                          .tr(),
                      style: context.textTheme.titleLarge?.rr.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 11),
                    ),
                    MyTextWidget(
                      ' 3 ${LocaleKeys.day.tr()}',
                      style: context.textTheme.titleLarge?.br.copyWith(
                          color: const Color(0xff1D1D1D), fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffD3D3D3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 0.5,
                  width: 1.sw,
                ),
                _buyerReviewSingle("1", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("2", 3, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("3", 70, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("4", 18, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("5", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("6", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("7", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("8", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("9", 1, context),
                const SizedBox(
                  height: 5,
                ),
                _buyerReviewSingle("10", 1, context),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffD3D3D3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 0.5,
                  width: 1.sw,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppAssets.deliveryGuranteeSvg,
                      width: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.delivery_guarantee.tr()}',
                      style: context.textTheme.titleLarge?.mr.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(children: [
                      SvgPicture.asset(
                        AppAssets.dolarSvg,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        '${LocaleKeys.get_a.tr()}',
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                      MyTextWidget(
                        ' 20% ${LocaleKeys.refund.tr()} ',
                        style: context.textTheme.titleLarge?.mr.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff388CFF)),
                      ),
                      MyTextWidget(
                        '${LocaleKeys.of_the_product_price_if_shipping.tr()}',
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                    ]),
                    const SizedBox(
                      height: 8,
                    ),
                    SvgPicture.asset(
                      AppAssets.freeShippingSvg,
                      width: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.free_shipping.tr()}',
                      style: context.textTheme.titleLarge?.mr.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.shipping_is_completely_free_without_any_extras.tr()}',
                      style: context.textTheme.titleLarge?.ra.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SvgPicture.asset(
                      AppAssets.returnGuranteeSvg,
                      width: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.return_guarantee.tr()}',
                      style: context.textTheme.titleLarge?.mr.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(children: [
                      MyTextWidget(
                        '${LocaleKeys.within.tr()}',
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                      MyTextWidget(
                        ' 3 ${LocaleKeys.day.tr()} ',
                        style: context.textTheme.titleLarge?.br.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                      MyTextWidget(
                        '${LocaleKeys.after_receiving_product_return_without_conditions.tr()}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11.sp,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                    ]),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(children: [
                      SvgPicture.asset(
                        AppAssets.dolarSvg,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      MyTextWidget(
                        '${LocaleKeys.get_a.tr()} ',
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                      /*  MyTextWidget(
                        '${LocaleKeys.full.tr()} ',
                        style: context.textTheme.titleLarge?.mr.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff388CFF)),
                      ),*/
                      MyTextWidget(
                        LocaleKeys.the_product_price_when_returned.tr(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                    ]),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(children: [
                      MyTextWidget(
                        '${LocaleKeys.or_reasons_with_complete_ease_and.tr()} ',
                        style: context.textTheme.titleLarge?.ra.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff1D1D1D)),
                      ),
                      MyTextWidget(
                        '${LocaleKeys.get_the_amount_back.tr()}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: context.textTheme.titleLarge?.mr.copyWith(
                            fontSize: 11,
                            height: 16 / 13,
                            color: const Color(0xff388CFF)),
                      ),
                    ]),
                    const SizedBox(
                      height: 8,
                    ),
                    SvgPicture.asset(
                      AppAssets.freeReturnSvg,
                      width: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.free_return.tr()}',
                      style: context.textTheme.titleLarge?.mr.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    MyTextWidget(
                      '${LocaleKeys.return_is_completely_free_without_any_extras.tr()}',
                      style: context.textTheme.titleLarge?.ra.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D)),
                    ),
                  ],
                )
              ],
            )),
          );
        });
  }

  Widget _buyerReviewSingle(
      String day, int numOfPercent, BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 20,
      child: Row(children: [
        Stack(
          children: [
            Container(
              height: 15,
              width: 284.w,
              decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xffD3D3D3))),
            ),
            Container(
              height: 15,
              width: (numOfPercent / 100) * 284.w,
              decoration: BoxDecoration(
                  color: const Color(0xff1D1D1D),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xff1D1D1D))),
            )
          ],
        ),
        const Spacer(),
        MyTextWidget(
          "${numOfPercent}%",
          style: context.textTheme.titleLarge?.rr
              .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
        ),
        const Spacer(),
        MyTextWidget(
          day,
          style: context.textTheme.titleLarge?.br
              .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
        ),
        MyTextWidget(
          " ${LocaleKeys.day.tr()}",
          style: context.textTheme.titleLarge?.rr
              .copyWith(color: const Color(0xff1D1D1D), fontSize: 11),
        ),
        SizedBox(width: day == "10" ? 5.w : 10.w),
      ]),
    );
  }
}
