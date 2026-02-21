import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/generated/locale_keys.g.dart';

class ProductShippingAndDelivery extends StatelessWidget {
  final String shippingDay;
  final double shippingCost;
  final String countryName;
  final PanelController panelController;
  ProductShippingAndDelivery({
    super.key,
    required this.shippingDay,
    required this.shippingCost,
    required this.countryName,
    required this.panelController,
  });

  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xffFCFCFC),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isExpanded,
        builder: (context, expanded, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  isExpanded.value = !isExpanded.value;
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.deliveryPathSvg),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        MyTextWidget(
                          '${LocaleKeys.expected_shipping_delivery_date.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            height: 16 / 13,
                            fontSize: 9,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SvgPicture.asset(
                          AppAssets.chatWithQuestionSvg,
                          height: 12,
                          // ignore: deprecated_member_use
                          color: const Color(0xffC4C2C2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
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
                                fontSize: 11,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '$formattedDate | ',
                              style: context.textTheme.titleLarge?.bq.copyWith(
                                height: 16 / 13,
                                fontSize: 11,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                            MyTextWidget(
                              '${shippingDay} ${LocaleKeys.work_days_at_your_address_in.tr()} ${countryName}',
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                height: 16 / 13,
                                fontSize: 11,
                                color: const Color(0xff1D1D1D),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (expanded) ...{
                /* shippingCost == 0
                          ? SizedBox.shrink()
                          :*/
                InkWell(
                  onTap: () {
                    panelController.open();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1.sw,
                        height: 0.5,
                        decoration: const BoxDecoration(
                          color: Color(0xffD3D3D3),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      SvgPicture.asset(AppAssets.freeShippingSvg, width: 20),
                      const SizedBox(height: 8),
                      MyTextWidget(
                        '${LocaleKeys.free_shipping.tr()}',
                        style: context.textTheme.titleLarge?.mq.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      MyTextWidget(
                        '${LocaleKeys.shipping_is_completely_free_without_any_extras.tr()}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          fontSize: 9,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.deliveryGuranteeSvg,
                            width: 20,
                          ),
                          const SizedBox(width: 5),
                          MyTextWidget(
                            '${LocaleKeys.delivery_guarantee.tr()}',
                            style: context.textTheme.titleLarge?.mq.copyWith(
                              fontSize: 11,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          MyTextWidget(
                            '${LocaleKeys.get_a.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                          MyTextWidget(
                            ' 20% ${LocaleKeys.refund.tr()} ',
                            style: context.textTheme.titleLarge?.mq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff388CFF),
                            ),
                          ),
                          MyTextWidget(
                            '${LocaleKeys.of_the_product_price_if_shipping.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1.sw,
                        height: 0.5,
                        decoration: const BoxDecoration(
                          color: Color(0xffD3D3D3),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      SvgPicture.asset(AppAssets.freeReturnSvg, width: 20),
                      const SizedBox(height: 8),
                      MyTextWidget(
                        '${LocaleKeys.free_return.tr()}',
                        style: context.textTheme.titleLarge?.mq.copyWith(
                          fontSize: 11,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      MyTextWidget(
                        '${LocaleKeys.return_is_completely_free_without_any_extras.tr()}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          fontSize: 9,
                          height: 16 / 13,
                          color: const Color(0xff1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.returnGuranteeSvg,
                            width: 20,
                          ),
                          const SizedBox(width: 5),
                          MyTextWidget(
                            '${LocaleKeys.return_guarantee.tr()}',
                            style: context.textTheme.titleLarge?.mq.copyWith(
                              fontSize: 11,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          MyTextWidget(
                            '${LocaleKeys.within.tr()}',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                          MyTextWidget(
                            ' 3 ${LocaleKeys.day.tr()} ',
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                          MyTextWidget(
                            '${LocaleKeys.after_receiving_product_return_without_conditions.tr()}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const SizedBox(width: 25),
                          MyTextWidget(
                            '${LocaleKeys.or_reasons_with_complete_ease_and.tr()} ',
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                          MyTextWidget(
                            '${LocaleKeys.get_the_amount_back.tr()}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: context.textTheme.titleLarge?.mq.copyWith(
                              fontSize: 9,
                              height: 16 / 13,
                              color: const Color(0xff388CFF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              },
            ],
          );
        },
      ),
    );
  }
}
