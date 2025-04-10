import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../app/my_cached_network_image.dart';
import 'order_details2_page.dart';
import 'package:trydos/config/theme/typography.dart';

class OrderDetails1 extends StatelessWidget {
  const OrderDetails1({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF8F8F8),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildHeader(context),
              ///////////////////
              SizedBox(
                height: 11.h,
              ),
              ///////////////////
              SizedBox(
                height: 74,
                child: buildFirstSection(context),
              ),
              ///////////////////
              SizedBox(
                height: 8.h,
              ),
              ///////////////////
              SizedBox(
                height: 74,
                child: buildSecondSection(context),
              ),
              ///////////////////
              SizedBox(
                height: 8.h,
              ),
              ///////////////////
              buildThirdSection(context),
              ///////////////////
              SizedBox(
                height: 8.h,
              ),
              ///////////////////
              InkWell(
                onTap: () {
                  HelperFunctions.slidingNavigation(
                    context,
                    OrderDetails2(),
                  );
                },
                child: buildFourthSection(context: context, itemsCount: '5'),
              ),
              ///////////////////
              SizedBox(
                height: 8.h,
              ),
              ///////////////////
              buildFifthSection(),
              ///////////////////
              SizedBox(
                height: 8.h,
              ),
              ///////////////////
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFifthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: MyCachedNetworkImage(
                      imageUrl:
                          'https://res.cloudinary.com/dtcmozf4d/image/upload/v1/product/2025-02-24-67bc4c4a5eb5f.png',
                      imageFit: BoxFit.contain,
                      width: 91,
                      height: 125,
                    ),
                  ),
                ),
                ///////////////////
                const SizedBox(
                  height: 3,
                ),
                ///////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.orderBag2Svg,
                      width: 13,
                    ),
                    //////////////////////////
                    SizedBox(
                      width: 2,
                    ),
                    //////////////////////////
                    SvgPicture.asset(
                      AppAssets.orderPreparingSvg,
                      width: 13,
                    ),
                  ],
                ),
                ///////////////////
                const SizedBox(
                  height: 2,
                ),
                ///////////////////
                Text(
                  'Medium',
                  // LocaleKeys.order_invoice.tr(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                const SizedBox(
                  height: 2,
                ),
                ///////////////////
                Text(
                  'Blue',
                  // LocaleKeys.order_invoice.tr(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 5,
            );
          },
        ),
      ),
    );
  }

  Widget buildFourthSection({
    required BuildContext context,
    required String itemsCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 74,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 237, 237, 237),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppAssets.bagsSvg,
              width: 20,
            ),
            ///////////////////
            SizedBox(
              height: 2,
            ),
            ///////////////////
            Text(
              'Order Details',
              // LocaleKeys.order_invoice.tr(),
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 2,
            ),
            ///////////////////
            RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 14,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: itemsCount,
                    style: context.textTheme.bodyMedium?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const TextSpan(text: ' Item'),
                ],
              ),
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildThirdSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Color(0xffF4F4F4),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping & Delivery Address',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              'My Home',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              'Cendere | Ayazağa | Sariyer | İstanbul | Turkiye Vadistanbul, Ofisler, 2A Block, Kat 4, 28 No',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              // LocaleKeys.order_invoice.tr(),
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              'Recipient',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              'Mohamad Katmawi',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              'Recipient Contact',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(
              height: 4,
            ),
            ///////////////////
            Text(
              '+90 552 800 2000',
              // LocaleKeys.order_invoice.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildSecondSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    AppAssets.orderAddressSvg,
                    width: 20,
                  ),
                  ///////////////////
                  SvgPicture.asset(
                    AppAssets.orderDeliveryDateSvg,
                    width: 20,
                  ),
                ],
              ),
              title: 'Expected Delivery Date',
              value: 'Monday 2.Jun | 3 Work Days',
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    AppAssets.orderBag2Svg,
                    width: 20,
                  ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  SvgPicture.asset(
                    AppAssets.orderBag3Svg,
                    width: 15,
                  ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  SvgPicture.asset(
                    AppAssets.orderBag3Svg,
                    width: 15,
                  ),
                ],
              ),
              title: 'Order Status',
              value: 'Preparing',
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFirstSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(
                AppAssets.orderBag1Svg,
                width: 20,
              ),
              title: 'Order Number',
              value: 'TTISA10012',
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(
                AppAssets.orderClockSvg,
                width: 20,
              ),
              title: 'Order Date',
              value: 'Today | 13:59:00',
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(
            width: 8,
          ),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    AppAssets.orderInvoice2Svg,
                    width: 20,
                  ),
                  SvgPicture.asset(
                    AppAssets.orderWalletSvg,
                    width: 15,
                  ),
                ],
              ),
              title: 'Order Invoice',
              amount: '360',
              isTextSpan: true,
              currency: 'USD',
              value: '',
            ),
          ),
          //////////////////////////
        ],
      ),
    );
  }

  Widget buildDetailsMainInfoWidget({
    required BuildContext context,
    required Widget firstItem,
    required String title,
    required String value,
    required bool isTextSpan,
    required String amount,
    required String currency,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          firstItem,
          ///////////////////
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              title,
              // LocaleKeys.order_invoice.tr(),
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ),
          ///////////////////
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
                          text: amount,
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
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
                    value,
                    // LocaleKeys.order_invoice.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
        ],
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                AppAssets.backIconArrowSvg,
                width: 11,
              ),
            ),
            ///////////////////////////////////
            Row(
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
                  'Orders Details',
                  // LocaleKeys.order_invoice.tr(),
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            ////////////
            SvgPicture.asset(
              AppAssets.orderMenuSvg,
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}
