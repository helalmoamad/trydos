import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';
import 'order_details2_page.dart';
import 'package:trydos/config/theme/typography.dart';

class OrderDetails1 extends StatefulWidget {
  OrderDetails1({super.key, required this.order});

  final OrderListModel order;

  @override
  State<OrderDetails1> createState() => _OrderDetails1State();
}

class _OrderDetails1State extends State<OrderDetails1> {
  List<String?> addressParts = [];
  @override
  void initState() {
    addressParts = [
      widget.order.shippingAddressData?.country,
      widget.order.shippingAddressData?.province,
      widget.order.shippingAddressData?.city,
      widget.order.shippingAddressData?.town,
      widget.order.shippingAddressData?.street,
      widget.order.shippingAddressData?.building,
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final addressString = addressParts
        .where((part) => part != null && part.isNotEmpty)
        .join(' | ');

    return Container(
      color: const Color(0xffFFFFFF),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xffF8F8F8),
          appBar: TrydosAppBar(
            appBarParams: AppBarParams(
              backgroundColor: const Color(0xffFFFFFF),
              scrolledUnderElevation: 0,
              backIconColor: Colors.black,
              withShadow: false,
              action: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                    ),
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
                      LocaleKeys.order_details.tr(),
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
                Spacer(),
                ////////////
                SvgPicture.asset(
                  AppAssets.orderMenuSvg,
                  width: 20,
                ),
                ///////////////////////////
                SizedBox(
                  width: 12,
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 11.h,
                ),
                ///////////////////
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) =>
                      (previous.getCurrencyForCountryModel !=
                          current.getCurrencyForCountryModel),
                  builder: (context, state) {
                    String currencySymbol = state.getCurrencyForCountryModel!
                            .data!.currency!.symbol ??
                        "";
                    double orderAmount = widget.order.orderAmount! *
                        state.getCurrencyForCountryModel!.data!.currency!
                            .exchangeRate!;
                    ;

                    return SizedBox(
                      height: 95,
                      child: buildFirstSection(
                        context: context,
                        orderNumber: widget.order.orderGroupId ?? '',
                        orderDate: HelperFunctions.orderFormatDate(
                          DateTime.parse(widget.order.createdAt ?? ''),
                        ),
                        orderAmount: orderAmount.toString(),
                        orderCurrency: currencySymbol,
                      ),
                    );
                  },
                ),
                ///////////////////////

                SizedBox(
                  height: 8.h,
                ),
                ///////////////////
                SizedBox(
                  height: 74,
                  child: buildSecondSection(
                    context: context,
                    expectedDeliveryDate: 'Monday 2.Jun | 3 Work Days',
                    orderStatus: widget.order.orderGroupStatus?.label ?? '',
                  ),
                ),
                ///////////////////
                SizedBox(
                  height: 8.h,
                ),
                ///////////////////
                buildThirdSection(
                  context: context,
                  contactInfo: widget.order.shippingAddressData?.phone ?? '',
                  recipientName:
                      widget.order.shippingAddressData?.contactPersonName ?? '',
                  shippingDeliveryAddress: addressString,
                ),
                ///////////////////
                SizedBox(
                  height: 8.h,
                ),
                ///////////////////
                InkWell(
                  onTap: () {
                    HelperFunctions.slidingNavigation(
                      context,
                      OrderDetails2(
                        order: widget.order,
                      ),
                    );
                  },
                  child: buildFourthSection(
                      context: context,
                      itemsCount: widget.order.details!.length.toString()),
                ),
                ///////////////////
                SizedBox(
                  height: 8.h,
                ),
                ///////////////////
                buildFifthSection(
                  details: widget.order.details,
                ),
                ///////////////////
                SizedBox(
                  height: 8.h,
                ),
                ///////////////////
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFifthSection({
    required List<OrderListDetailModel>? details,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          itemCount: details?.length ?? 0,
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
                          details?[index].productDetails?.images?[0] ?? '',
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
                  details?[index].variation == null
                      ? ''
                      : details?[index].variation?.size ?? '',
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
                  details?[index].variation == null
                      ? ''
                      : details?[index].variation?.color ?? '',
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
              LocaleKeys.order_details.tr(),
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
                  TextSpan(text: ' ${LocaleKeys.item.tr()}'),
                ],
              ),
            ),
            ///////////////////
          ],
        ),
      ),
    );
  }

  Widget buildThirdSection({
    required BuildContext context,
    required String shippingDeliveryAddress,
    required String recipientName,
    required String contactInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
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
              LocaleKeys.shipping_delivery_address.tr(),
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
              LocaleKeys.my_home.tr(),
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
              shippingDeliveryAddress,
              maxLines: 2,
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
              LocaleKeys.recipient.tr(),
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
              recipientName,
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
              LocaleKeys.recipient_contact.tr(),
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
              contactInfo,
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

  Widget buildSecondSection({
    required BuildContext context,
    required String expectedDeliveryDate,
    required String orderStatus,
  }) {
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
              title: LocaleKeys.expected_delivery_date.tr(),
              value: expectedDeliveryDate,
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
              title: LocaleKeys.order_status.tr(),
              value: orderStatus,
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFirstSection({
    required BuildContext context,
    required String orderNumber,
    required String orderDate,
    required String orderAmount,
    required String orderCurrency,
  }) {
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
              title: LocaleKeys.order_number.tr(),
              value: orderNumber,
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
              title: LocaleKeys.order_date.tr(),
              value: orderDate,
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
              title: LocaleKeys.order_invoice.tr(),
              amount: orderAmount,
              isTextSpan: true,
              currency: orderCurrency,
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
                    maxLines: 2,
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
}
