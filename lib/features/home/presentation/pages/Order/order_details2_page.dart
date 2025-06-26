import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart'
    show OrderBloc;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/profile_section/crope_image.dart'
    show CopperImage;
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';

class OrderDetails2 extends StatefulWidget {
  OrderDetails2({
    super.key,
    required this.order,
    this.fromNotification = false,
  });

  final bool fromNotification;
  final OrderListModel order;

  @override
  State<OrderDetails2> createState() => _OrderDetails2();
}

class _OrderDetails2 extends State<OrderDetails2> {
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeAddress = ValueNotifier(false);
  final PanelController panelController = PanelController();
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForCanselOrder = ValueNotifier(false);
  final ValueNotifier<bool> visiblecamera = ValueNotifier(false);
  final ValueNotifier<List<File?>> orderPhotos = ValueNotifier([]);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final ValueNotifier<List<String>> optionCanselOrReturn = ValueNotifier([]);
  final ValueNotifier<bool> shadowForChangeVariant = ValueNotifier(false);

  // final ValueNotifier<bool> showShadowForChangeSize = ValueNotifier(false);
  final ValueNotifier<bool> enableChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> variantHasBeenChanged = ValueNotifier(false);
  final ValueNotifier<int> indexTapAddress = ValueNotifier(0);
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  final ValueNotifier<int?> colorIndexTap = ValueNotifier(null);
  final ValueNotifier<int?> sizeIndexTap = ValueNotifier(null);
  final ValueNotifier<int> productIndexTap = ValueNotifier(0);

  final ValueNotifier<String?> optionVariant = ValueNotifier("color");
  bool allOrder = false;
  late OrderBloc orderBloc;
  late HomeBloc homeBloc;

  @override
  void initState() {
    sizeIndexTap.value = 3;
    orderBloc = BlocProvider.of<OrderBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // didCallOnWillPop = true;
        orderBloc.add(ChangeOrderByGroupStatus());
        try {
          if (panelController.isPanelOpen) {
            agreeToPolicies.value = false;
            panelController.close();
            showPanel.value = false;
            optionModifyPanel.value = null;
            optionCanselOrReturn.value = [];
            enableChangeAddress.value = false;
            showShadowForPanel.value = false;
            showShadowForChangeAddress.value = false;
            showShadowForCanselOrder.value = false;
            shadowForChangeVariant.value = false;
            return false;
          }
        } catch (e) {
          return true;
        }
        return true;
      },
      child: Container(
        color: const Color(0xffFFFFFF),
        child: Material(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: const Color(0xffF8F8F8),
                resizeToAvoidBottomInset: true,
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
                      InkWell(
                        onTap: () {
                          allOrder = true;
                          optionModifyPanel.value = "All_Order";
                          showPanel.value = true;
                          panelController.open();
                          showShadowForPanel.value = true;
                        },
                        child: Container(
                          width: 40,
                          height: 20,
                          child: SvgPicture.asset(
                            AppAssets.orderMenuSvg,
                            width: 20,
                          ),
                        ),
                      ),
                      ///////////////////////////
                      SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: 11.h,
                    ),
                    ///////////////////
                    buildFirstSection(
                        context, widget.order.details!.length.toString()),
                    ///////////////////
                    SizedBox(
                      height: 10.h,
                    ),
                    ///////////////////
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  width: 60,
                                  color: Colors.black,
                                ),
                                ///////////////////
                                const SizedBox(
                                  height: 5,
                                ),
                                ///////////////////
                                BlocBuilder<HomeBloc, HomeState>(
                                  buildWhen: (previous, current) =>
                                      (previous.getCurrencyForCountryModel !=
                                          current.getCurrencyForCountryModel),
                                  builder: (context, state) {
                                    String currencySymbol = state
                                            .getCurrencyForCountryModel!
                                            .data!
                                            .currency!
                                            .symbol ??
                                        "";
                                    String orderAmount =
                                        (widget.order.orderAmount! *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toStringAsFixed(state
                                                    .startingSetting
                                                    ?.decimalPointSettings ??
                                                0);

                                    return RichText(
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                        children: [
                                          TextSpan(
                                              text:
                                                  '${LocaleKeys.buying.tr()} '),
                                          /////////////////////////
                                          TextSpan(
                                            text:
                                                '${widget.order.details?.length ?? 0}',
                                            style: context
                                                .textTheme.bodyMedium?.bq
                                                .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                          /////////////////////////
                                          TextSpan(
                                              text:
                                                  ' ${LocaleKeys.item.tr()} . '),
                                          /////////////////////////
                                          TextSpan(
                                            text: '${orderAmount}',
                                            style: context
                                                .textTheme.bodyMedium?.bq
                                                .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                          /////////////////////////
                                          TextSpan(text: ' $currencySymbol'),
                                          /////////////////////////
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                ///////////////////
                                SizedBox(
                                  height: 5.h,
                                ),
                                ///////////////////
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.orderAddressSvg,
                                            width: 20,
                                          ),
                                          ///////////////////
                                          SizedBox(
                                            height: 5,
                                          ),
                                          ///////////////////
                                          Text(
                                            LocaleKeys.expected_delivery_date
                                                .tr(),
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 10,
                                              height: 1.3,
                                            ),
                                          ),
                                          ///////////////////
                                          SizedBox(
                                            height: 5,
                                          ),
                                          ///////////////////
                                          Text(
                                            'Monday 2.Jun | 3 Work Days',
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    /////////////
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                widget.order.orderGroupStatus
                                                            ?.label ==
                                                        'Pending'
                                                    ? SvgPicture.asset(
                                                        AppAssets.pendingBagSvg,
                                                        width: 20,
                                                      )
                                                    : SvgPicture.asset(
                                                        AppAssets.pendingBagSvg,
                                                        width: 15,
                                                      ),
                                                ////////////////////
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                ///////////////////
                                                widget.order.orderGroupStatus
                                                            ?.label ==
                                                        'Pending'
                                                    ? SvgPicture.asset(
                                                        AppAssets.whiteBagSvg,
                                                        width: 15,
                                                      )
                                                    : widget
                                                                .order
                                                                .orderGroupStatus
                                                                ?.label ==
                                                            'Preparing'
                                                        ? SvgPicture.asset(
                                                            AppAssets
                                                                .preparingBagSvg,
                                                            width: 20,
                                                          )
                                                        : SvgPicture.asset(
                                                            AppAssets
                                                                .preparingBagSvg,
                                                            width: 15,
                                                          ),
                                                ////////////////////
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                ///////////////////
                                                widget.order.orderGroupStatus
                                                            ?.label ==
                                                        'Pending'
                                                    ? SvgPicture.asset(
                                                        AppAssets.whiteBagSvg,
                                                        width: 15,
                                                      )
                                                    : widget
                                                                .order
                                                                .orderGroupStatus
                                                                ?.label ==
                                                            'Preparing'
                                                        ? SvgPicture.asset(
                                                            AppAssets
                                                                .whiteBagSvg,
                                                            width: 15,
                                                          )
                                                        : widget
                                                                    .order
                                                                    .orderGroupStatus
                                                                    ?.label ==
                                                                'Shipped'
                                                            ? SvgPicture.asset(
                                                                AppAssets
                                                                    .shippedAndOutOfDeliveryBagSvg,
                                                                width: 20,
                                                              )
                                                            : SvgPicture.asset(
                                                                AppAssets
                                                                    .shippedAndOutOfDeliveryBagSvg,
                                                                width: 15,
                                                              ),
                                                ////////////////////
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                ///////////////////
                                                widget.order.orderGroupStatus
                                                            ?.label ==
                                                        'Pending'
                                                    ? SvgPicture.asset(
                                                        AppAssets.whiteBagSvg,
                                                        width: 15,
                                                      )
                                                    : widget
                                                                .order
                                                                .orderGroupStatus
                                                                ?.label ==
                                                            'Preparing'
                                                        ? SvgPicture.asset(
                                                            AppAssets
                                                                .whiteBagSvg,
                                                            width: 15,
                                                          )
                                                        : widget
                                                                    .order
                                                                    .orderGroupStatus
                                                                    ?.label ==
                                                                'Shipped'
                                                            ? SvgPicture.asset(
                                                                AppAssets
                                                                    .whiteBagSvg,
                                                                width: 15,
                                                              )
                                                            : widget
                                                                        .order
                                                                        .orderGroupStatus
                                                                        ?.label ==
                                                                    'Delivered'
                                                                ? SvgPicture
                                                                    .asset(
                                                                    AppAssets
                                                                        .delivered_bagSvg,
                                                                    width: 20,
                                                                  )
                                                                : SvgPicture
                                                                    .asset(
                                                                    AppAssets
                                                                        .delivered_bagSvg,
                                                                    width: 15,
                                                                  ),
                                                ///////////////////////
                                              ],
                                            ),
                                            ///////////////////
                                            SizedBox(
                                              height: 5,
                                            ),
                                            ///////////////////
                                            Row(
                                              children: [
                                                Spacer(),
                                                Text(
                                                  LocaleKeys.order_status.tr(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme.bodyMedium?.rq
                                                      .copyWith(
                                                    color:
                                                        const Color(0xff8D8D8D),
                                                    letterSpacing: 0.18,
                                                    fontSize: 10,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                )
                                              ],
                                            ),
                                            ///////////////////
                                            SizedBox(
                                              height: 5,
                                            ),
                                            ///////////////////
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  widget.order.orderGroupStatus
                                                          ?.label ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme.bodyMedium?.rq
                                                      .copyWith(
                                                    color:
                                                        const Color(0xff1D1D1D),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                ///////////////////
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                ///////////////////
                                                SvgPicture.asset(
                                                  AppAssets.orderPreparingSvg,
                                                  width: 15,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                ///////////////////
                                SizedBox(
                                  height: 12,
                                ),
                                ///////////////////
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: const Color(0xffC4C2C2),
                                ),
                                ///////////////////
                                SizedBox(
                                  height: 12,
                                ),
                                ///////////////////
                                ListView.separated(
                                  itemCount: widget.order.details?.length ?? 0,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return productWidget(
                                        widget.order.details![index], index);
                                  },
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: const Color(0xffC4C2C2),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              shadowForPanel(),
              panelWidget(),
              ValueListenableBuilder<int>(
                  valueListenable: indexTapAddress,
                  builder: (context, _indexTap, _) {
                    return shadowForChangeAddressContent(_indexTap);
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForChangeOrderVariant(_indexTap);
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForCanselOrRutuenOrder(_indexTap,
                        optionModifyPanel.value == "Return_This_Product");
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget optionsForAllOrder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10.h,
        ),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
              color: Color(0xffC4C2C2),
              border: Border.all(color: Color(0xffC4C2C2)),
              borderRadius: BorderRadius.all(Radius.circular(2))),
        ),
        SizedBox(
          height: 20.h,
        ),
        Container(
          width: 1.sw,
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Color(0xffF8F8F8),
              border: Border.all(color: Color(0xffF8F8F8)),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: 1.sw,
                height: 16.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(
                      AppAssets.orderClockSvg,
                      height: 15.h,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      HelperFunctions.orderFormatDate(
                        DateTime.tryParse(widget.order.createdAt ?? '') ??
                            DateTime.now(),
                      ),
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    Spacer(),
                    SvgPicture.asset(
                      AppAssets.orderBag1Svg,
                      height: 15.h,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.order.orderGroupId ?? "",
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: 1.sw,
                height: 16.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(
                      AppAssets.preparingBagSvg,
                      height: 15.h,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.order.orderGroupStatus?.label ?? "",
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SvgPicture.asset(
                      AppAssets.orderPreparingSvg,
                      height: 15.h,
                    ),
                    Spacer(),
                    SvgPicture.asset(
                      AppAssets.orderInvoice2Svg,
                      height: 15.h,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      (widget.order.details?.length ?? "").toString(),
                      style: context.textTheme.bodyMedium?.br.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      LocaleKeys.item.tr(),
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      (widget.order.orderAmount! *
                              homeBloc.state.getCurrencyForCountryModel!.data!
                                  .currency!.exchangeRate!)
                          .toStringAsFixed(homeBloc.state.startingSetting
                                  ?.decimalPointSettings ??
                              0),
                      style: context.textTheme.bodyMedium?.br.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      homeBloc.state.getCurrencyForCountryModel!.data!.currency!
                          .symbol!,
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                height: 125.h,
                width: 1.sw,
                padding: EdgeInsets.only(
                    left: LanguageService.languageCode == "ar" ? 0 : 10,
                    right: LanguageService.languageCode != "ar" ? 0 : 10),
                child: ListView.builder(
                  itemCount: widget.order.details?.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 125.h,
                      width: 92,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: MyCachedNetworkImage(
                            imageUrl: widget.order.details?[index].image ?? "",
                            width: 92,
                            imageFit: BoxFit.contain,
                            height: 125.h),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text("${LocaleKeys.action_about_order.tr()}",
            style: context.textTheme.bodyMedium?.rr.copyWith(
              color: const Color(0xff8D8D8D),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.3,
            )),
        SizedBox(
          height: 10,
        ),
        Container(
          width: 1.sw,
          height: 0.5,
          decoration: BoxDecoration(
              color: Color(0xffC4C2C2),
              border: Border.all(color: Color(0xffC4C2C2)),
              borderRadius: BorderRadius.all(Radius.circular(2))),
        ),
        SizedBox(
          height: 30.h,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: optionOfModify(
              onTap: () {
                optionModifyPanel.value = "Change_Address";
              },
              svg: AppAssets.orderChangeAddressSvg,
              image2: "",
              tiltle: "${LocaleKeys.change_delivery_address.tr()}",
              body:
                  "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}"),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: optionOfModify(
              onTap: () {
                optionModifyPanel.value = "Hide_This_Product";
              },
              svg: AppAssets.hideThisProductSvg,
              image2: "",
              tiltle: "${LocaleKeys.hide_this_product.tr()}",
              body: "${LocaleKeys.hide_this_product_from_list.tr()}"),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: optionOfModify(
              onTap: () {
                optionModifyPanel.value = "Cancel_This_Product";
              },
              svg: AppAssets.orderCanselSvg,
              image2: "",
              tiltle: "${LocaleKeys.cancel_this_product.tr()}",
              body: "Cancel This Product In 3 Hours And Back Your Money"),
        ),
      ],
    );
  }

  Widget productWidget(OrderListDetailModel orderListDetailModel, int index) {
    return Container(
      height: 170 + 100 + 132,
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            width: 1.sw,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: const Color.fromARGB(255, 250, 250, 250),
                    child: MyCachedNetworkImage(
                      imageUrl: orderListDetailModel.image ?? '',
                      imageFit: BoxFit.contain,
                      width: 100,
                      height: 150,
                    ),
                  ),
                ),
                ///////////////////
                const SizedBox(
                  width: 12,
                ),
                ///////////////////
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 8,
                              width: 50,
                              color: Colors.black,
                            ),
                            ///////////////////
                            const SizedBox(
                              height: 15,
                            ),
                            ///////////////////
                            Text(
                              orderListDetailModel.productDetails?.name ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            ///////////////////
                            const SizedBox(
                              height: 5,
                            ),
                            ///////////////////
                            (orderListDetailModel.variation?.size == null ||
                                        orderListDetailModel.variation?.size ==
                                            "") &&
                                    (orderListDetailModel.variation?.color ==
                                            null ||
                                        orderListDetailModel.variation?.color ==
                                            "")
                                ? SizedBox.shrink()
                                : Row(
                                    children: [
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          style: context
                                              .textTheme.bodyMedium?.rq
                                              .copyWith(
                                            color: const Color(0xff8D8D8D),
                                            letterSpacing: 0.18,
                                            fontSize: 10,
                                            height: 1.3,
                                          ),
                                          children: [
                                            orderListDetailModel
                                                            .variation?.color ==
                                                        "" ||
                                                    orderListDetailModel
                                                            .variation?.color ==
                                                        null
                                                ? TextSpan(text: "")
                                                : TextSpan(
                                                    text:
                                                        '${LocaleKeys.color.tr()} : ',
                                                  ),
                                            ////////////////////////////
                                            TextSpan(
                                              text: orderListDetailModel
                                                          .variation ==
                                                      null
                                                  ? ''
                                                  : orderListDetailModel
                                                          .variation?.color ??
                                                      '',
                                              style: context
                                                  .textTheme.bodyMedium?.mq
                                                  .copyWith(
                                                color: const Color(0xff505050),
                                                letterSpacing: 0.18,
                                                fontSize: 10,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ///////////////////
                                      SizedBox(
                                        width: orderListDetailModel
                                                        .variation?.color ==
                                                    "" ||
                                                orderListDetailModel
                                                        .variation?.color ==
                                                    null
                                            ? 0
                                            : 12,
                                      ),
                                      ///////////////////
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 10,
                                              height: 1.3,
                                            ),
                                            children: [
                                              orderListDetailModel.variation
                                                              ?.size ==
                                                          null ||
                                                      orderListDetailModel
                                                              .variation
                                                              ?.size ==
                                                          ""
                                                  ? TextSpan(text: "")
                                                  : TextSpan(
                                                      text:
                                                          '${LocaleKeys.size.tr()} : ',
                                                    ),
                                              ////////////////////////////
                                              TextSpan(
                                                text: orderListDetailModel
                                                            .variation ==
                                                        null
                                                    ? ''
                                                    : orderListDetailModel
                                                            .variation?.size ??
                                                        '',
                                                style: context
                                                    .textTheme.bodyMedium?.mq
                                                    .copyWith(
                                                  color:
                                                      const Color(0xff505050),
                                                  letterSpacing: 0.18,
                                                  fontSize: 10,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            ///////////////////
                            const SizedBox(
                              height: 5,
                            ),
                            ///////////////////
                            Row(
                              children: [
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                      color: const Color(0xff8D8D8D),
                                      letterSpacing: 0.18,
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${LocaleKeys.composed_of.tr()}: ',
                                      ),
                                      ////////////////////////////
                                      TextSpan(
                                        text:
                                            '${orderListDetailModel.productDetails?.countOfPieces} ${LocaleKeys.piece.tr()}',
                                        style: context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 10,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ///////////////////
                                SizedBox(
                                  width: 12,
                                ),
                                ///////////////////
                                Flexible(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.item.tr()}: ',
                                        ),
                                        ////////////////////////////
                                        TextSpan(
                                          text: orderListDetailModel.qty
                                              .toString(),
                                          style: context
                                              .textTheme.bodyMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            fontSize: 10,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ///////////////////
                            const SizedBox(
                              height: 5,
                            ),
                            ///////////////////
                            Row(
                              children: [
                                Flexible(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${LocaleKeys.item_status.tr()}: ',
                                        ),
                                        ////////////////////////////
                                        TextSpan(
                                          text:
                                              widget.order.orderStatus?.label ??
                                                  "",
                                          style: context
                                              .textTheme.bodyMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            fontSize: 10,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ///////////////////

                                ///
                                ///
                                ///
                                SizedBox(
                                  width: 12,
                                ),
                                ///////////////////
                                SvgPicture.asset(
                                  widget.order.orderStatus?.label == 'Shipped'
                                      ? AppAssets.shippedBlackSvg
                                      : widget.order.orderStatus?.label ==
                                              'Delivered'
                                          ? AppAssets.deliveredBlackSvg
                                          : widget.order.orderStatus?.label ==
                                                  'Pending'
                                              ? AppAssets.pendeingBlackCheck
                                              : AppAssets.orderPreparingSvg,
                                  width: 15,
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 5,
                            ),
                            ///////////////////
                            /*  Row(
                              children: [
                                Text(
                                  '${LocaleKeys.return_request.tr()}',
                                  style:
                                      context.textTheme.bodyMedium?.mr.copyWith(
                                    color: const Color(0xffFFB16F),
                                    letterSpacing: 0.18,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                ),
                                ///////////////////

                                ///
                                ///
                                ///
                                SizedBox(
                                  width: 12,
                                ),
                                ///////////////////
                                SvgPicture.asset(
                                  AppAssets.returnThisProductSvg,
                                  width: 15,
                                ),
                              ],
                            ),*/
                            Row(
                              children: [
                                Text(
                                  'Canseled',
                                  style:
                                      context.textTheme.bodyMedium?.mr.copyWith(
                                    color: const Color(0xff505050),
                                    letterSpacing: 0.18,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                ),
                                ///////////////////

                                ///
                                ///
                                ///
                                SizedBox(
                                  width: 12,
                                ),
                                ///////////////////
                                SvgPicture.asset(
                                  AppAssets.orderCanselSvg,
                                  width: 15,
                                ),
                              ],
                            ),
                            ////////////////////
                            const Spacer(),
                            ////////////////////
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(
                                style:
                                    context.textTheme.bodyMedium?.rq.copyWith(
                                  color: const Color(0xffC4C2C2),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '${((orderListDetailModel.productDetails?.price ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                      color: const Color(0xffC4C2C2),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  ////////////////////////////
                                  TextSpan(
                                    text:
                                        ' ${((orderListDetailModel.productDetails?.offerPrice ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                    style: context.textTheme.bodyMedium?.bq
                                        .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  /////////////
                                  TextSpan(
                                    text:
                                        ' ${(GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.symbol!)}',
                                    style: context.textTheme.bodyMedium?.lq
                                        .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '  ${LocaleKeys.back_to_your_wallet.tr()}',
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                      color: const Color(0xff388CFF),
                                      letterSpacing: 0.18,
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ///////////////////
                        Container(
                          width: 30,
                          height: 15,
                          child: BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.getCustomerAddressStatus !=
                                    current.getCustomerAddressStatus ||
                                previous.editAddressToOrderStatus !=
                                    current.editAddressToOrderStatus ||
                                previous.setCustomerAddressDefaultStatus !=
                                    current.setCustomerAddressDefaultStatus ||
                                previous.addAddressToOrderStatus !=
                                    current.addAddressToOrderStatus ||
                                previous.removeAddressToOrderStatus !=
                                    current.removeAddressToOrderStatus,
                            builder: (context, state) {
                              return InkWell(
                                  onTap: () {
                                    allOrder = false;
                                    showPanel.value = true;
                                    panelController.open();
                                    showShadowForPanel.value = true;
                                    indexTapAddress.value =
                                        state.currentAddressChoosed ?? 0;
                                    indexTap.value = index;
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 20,
                                    child: SvgPicture.asset(
                                      AppAssets.orderMenuSvg,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 1.sw,
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            height: 53 + 132,
            decoration: BoxDecoration(
                color: Color(0xffFFFCF0),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                /*  SuccessFulOfReturned(
                    AppAssets.returnedBlacSvg,
                    LocaleKeys.product_has_been_returned_successfully.tr(),
                    LocaleKeys.back_to_your_wallet.tr(),
                    "140 USD",
                    "3 H",
                    "2 h ago",
                    true,
                    true),*/
                statusOfReturned(
                    AppAssets.returnedBlacSvg,
                    LocaleKeys.product_return_has_been_requested.tr(),
                    LocaleKeys.product_return_request_approve.tr(),
                    "3 H",
                    "00:02:19",
                    true,
                    true),
                statusOfReturned(
                    AppAssets.returnedBlacSvg,
                    LocaleKeys.product_return_request_approve.tr(),
                    "${LocaleKeys.product_collection_within.tr()}" +
                        "  1 ${LocaleKeys.day.tr()}",
                    "",
                    "",
                    false,
                    false),
                statusOfReturned(
                    AppAssets.returnedBlacSvg,
                    LocaleKeys.product_return_has_been_requested.tr(),
                    LocaleKeys.product_return_request_approve.tr(),
                    "",
                    "",
                    false,
                    false),
                statusOfReturned(
                    AppAssets.returnedBlacSvg,
                    LocaleKeys.product_return_has_been_requested.tr(),
                    LocaleKeys.product_return_request_approve.tr(),
                    "",
                    "",
                    false,
                    false)
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${LocaleKeys.cancel_return_request_get.tr()}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    decoration: TextDecoration.underline,
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                Text(
                  " 3 USD",
                  style: context.textTheme.bodyMedium?.br.copyWith(
                    decoration: TextDecoration.underline,
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusOfReturned(String svg, String tilte, String body, String time,
      String timer, bool isBlac, bool isTextBlac) {
    return Container(
      width: 1.sw,
      height: 45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 1.sw,
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(svg),
                SizedBox(
                  width: 5,
                ),
                Text(
                  tilte,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                Spacer(),
                Text(
                  time,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xffC4C2C2),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.orderClockSvg,
                ),
              ],
            ),
          ),
          Container(
            width: 1.sw,
            height: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  "${LocaleKeys.waiting.tr()}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff388CFF),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                Text(
                  " $body",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                Spacer(),
                Text(
                  timer,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.orderClockSvg,
                  color: isBlac ? Color(0xff1D1D1D) : null,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget SuccessFulOfReturned(String svg, String tilte, String body,
      String money, String time, String timer, bool isBlac, bool isTextBlac) {
    return Container(
      width: 1.sw,
      height: 45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 1.sw,
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(svg),
                SizedBox(
                  width: 5,
                ),
                Text(
                  tilte,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                Spacer(),
                Text(
                  time,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xffC4C2C2),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.orderClockSvg,
                ),
              ],
            ),
          ),
          Container(
            width: 1.sw,
            height: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  " $body",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                Text(
                  " $money",
                  style: context.textTheme.bodyMedium?.br.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                Spacer(),
                Text(
                  timer,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                SvgPicture.asset(
                  AppAssets.orderClockSvg,
                  color: isBlac ? Color(0xff1D1D1D) : null,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget buildFirstSection(BuildContext context, String itemsCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xffC4C2C2),
            )),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  AppAssets.bagsSvg,
                  width: 20,
                ),
                ///////////////////
                SizedBox(
                  height: 3,
                ),
                ///////////////////
                Text(
                  LocaleKeys.order_details.tr(),
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                SizedBox(
                  height: 3,
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
                      TextSpan(text: ' ${LocaleKeys.item.tr()}   '),
                      TextSpan(text: ' 1 ${LocaleKeys.returned.tr()}  '),
                      TextSpan(text: ' 1 ${LocaleKeys.not_delivery.tr()}')
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            widget.order.orderStatus?.value != "out_for_delivery"
                ? SizedBox.shrink()
                : Container(
                    width: 30,
                    height: 40,
                    child: BlocListener<ChatBloc, ChatState>(
                        listenWhen: (previous, current) =>
                            previous.getOrderRecipientIdStatus !=
                            current.getOrderRecipientIdStatus,
                        listener: (context, state) {
                          if (state.getOrderRecipientIdStatus ==
                              GetOrderRecipientIdStatus.success) {
                            String receiverName = "DW";
                            String fullReceiverName = "Delivery Worker";
                            String? recipientUserId = state.recipientUserId;
                            if (recipientUserId == null) {
                              return;
                            }
                            Chat? chat;
                            User? receiver;
                            List<Chat> chats =
                                List.of(GetIt.I<ChatBloc>().state.chats);
                            debugPrint(chats.toString());
                            chats.addAll(GetIt.I<ChatBloc>().state.pinnedChats);
                            chat = chats.firstWhere((element) =>
                                element.channelMembers!.any((element) {
                                  return element.userId.toString() ==
                                      recipientUserId;
                                }));
                            final preferences = GetIt.I<PrefsRepository>();
                            receiver = chat.channelMembers
                                ?.firstWhere(
                                  (element) =>
                                      element.userId != preferences.myChatId,
                                  orElse: () => ChannelMember(
                                      userId: int.tryParse(recipientUserId),
                                      user: User(
                                          id: int.tryParse(recipientUserId),
                                          name: receiverName)),
                                )
                                .user;
                            String fromOrder = "true";
                            context.go(GRouter.config.applicationRoutes
                                    .kSinglePageChatPagePath +
                                '?chatId=${chat.id!.toString()}&fromOrder=$fromOrder&receiverName=$receiverName&fullReceiverName=${fullReceiverName}&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}&senderName=${HelperFunctions.getTheFirstTwoLettersOfName(GetIt.I<PrefsRepository>().myChatName!)}');
                          }
                          // TODO: implement listener
                        },
                        child: BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (previous, current) =>
                              previous.getOrderRecipientIdStatus !=
                              current.getOrderRecipientIdStatus,
                          builder: (context, state) {
                            if (state.getOrderRecipientIdStatus ==
                                GetOrderRecipientIdStatus.loading) {
                              return Container(
                                width: 30,
                                height: 30,
                                child: TrydosLoader(
                                  size: 16,
                                ),
                              );
                            }
                            return Container(
                              alignment: Alignment.center,
                              width: 30,
                              height: 30,
                              child: InkWell(
                                onTap: () {
                                  GetIt.I<ChatBloc>().add(
                                      GetOrderRecipientIdEvent(
                                          originalUserId:
                                              GetIt.I<PrefsRepository>()
                                                  .myMarketId
                                                  .toString(),
                                          orderId: widget.order.id.toString()));
                                },
                                child: SvgPicture.asset(
                                  AppAssets.chatMarkActiveSvg,
                                  width: 20,
                                ),
                              ),
                            );
                          },
                        )),
                  ),
          ],
        ),
      ),
    );
  }

  Widget shadowForPanel() {
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForPanel,
        builder: (context, isShowShadowForPanel, _) {
          return !isShowShadowForPanel
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    showShadowForPanel.value = false;
                    Future.delayed(
                      Duration(microseconds: 300),
                      () {
                        panelController.close();
                        showShadowForPanel.value = false;
                      },
                    );
                  },
                  child: Container(
                    height: 1.sh,
                    width: 1.sw,
                    color: Color.fromRGBO(29, 29, 29, 0.6),
                  ),
                );
        });
  }

  /* Widget shadowForChangeSize(int tapIndex) {
    final List<String> sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];

    colorIndexTap.value = 3;
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForChangeSize,
        builder: (context, _showShadowForChangeSize, _) {
          colorIndexTap.value = (2) ~/ 2;
          return !_showShadowForChangeSize
              ? SizedBox.shrink()
              : Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: Color.fromRGBO(29, 29, 29, 0.95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.modifyOrderSvg,
                            width: 50,
                            color: Colors.white,
                          ),
                          SvgPicture.asset(
                            AppAssets.bagsOrderSvg,
                            color: Colors.white,
                            width: 25,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        LocaleKeys.change_below_size.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: const Color(0xffD3D3D3),
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        height: 138,
                        width: 1.sw,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xffD3D3D3))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                child: MyCachedNetworkImage(
                                    imageUrl: widget.order
                                            .details?[indexTap.value].image ??
                                        "",
                                    width: 70,
                                    imageFit: BoxFit.contain,
                                    height: 70),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                alignment: Alignment.center,
                                width: 150,
                                height: 20,
                                child: Text(
                                  "xxl",
                                  style:
                                      context.textTheme.bodyMedium?.mr.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        LocaleKeys.to_new_size.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: sizeIndexTap,
                        builder: (context, _sizeIndexTap, _) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            height: 138,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Color(0xffD3D3D3)),
                            ),
                            child: CarouselSlider.builder(
                              itemCount: sizes.length,
                              itemBuilder: (context, index, realIdx) {
                                int distance = (_sizeIndexTap - index).abs();
                                if (distance > 3) distance = 3;

                                // تدرج حجم الخط حسب المسافة
                                double fontSize;
                                switch (distance) {
                                  case 0:
                                    fontSize = 30;
                                    break;
                                  case 1:
                                    fontSize = 20;
                                    break;
                                  case 2:
                                    fontSize = 14;
                                    break;
                                  default:
                                    fontSize = 10;
                                }

                                // مقياس التكبير نتركه ثابت 1.0 لأن حجم الدائرة ثابت
                                double scale = 1.4;

                                bool isCenter = distance == 0;

                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.ease,
                                  width: 70,
                                  height: 70,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 10 - distance * 2,
                                    horizontal:
                                        4, // تقليل المسافة الأفقية قليلاً
                                  ),
                                  child: Transform.scale(
                                    scale: !isCenter ? 1.0 : scale,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: isCenter
                                            ? Border.all(
                                                color: Color(0xff366CB8),
                                              )
                                            : null,
                                        color: isCenter
                                            ? Color(0xffFF5F61)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              8), // مساحة داخلية حول النص
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          sizes[index],
                                          style: context
                                              .textTheme.bodyMedium?.ba
                                              .copyWith(
                                            color: Color(0xffF8F8F8),
                                            fontSize: fontSize,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 140,
                                initialPage: _sizeIndexTap,
                                viewportFraction: 0.14, // لعرض 7 عناصر تقريبًا
                                enableInfiniteScroll: false,
                                enlargeCenterPage: false,
                                onPageChanged: (index, reason) {
                                  sizeIndexTap.value = index;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 70.h,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: agreeToPolicies,
                          builder: (context, _agreeToPolicies, _) {
                            return Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 1.sw,
                                child: InkWell(
                                  onTap: () =>
                                      agreeToPolicies.value = !_agreeToPolicies,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(AppAssets.detectedSvg,
                                          color: _agreeToPolicies
                                              ? Color(0xff388CFF)
                                              : Color(0xff8E8E8E)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        LocaleKeys.change_size_terms.tr(),
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                          decorationColor: Colors.white,
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                      SizedBox(
                        height: 30.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '${LocaleKeys.we_will_ignore_size.tr()} "xxl" ${LocaleKeys.and_send_you_size.tr()} "xl"',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      InkWell(
                        onTap: () {
                          if (agreeToPolicies.value == false) {
                            return;
                          }
                          agreeToPolicies.value = false;

                          showShadowForCanselOrder.value = false;
                          variantHasBeenChanged.value = true;
                          showShadowForChangeAddress.value = false;
                          showShadowForChangeColor.value = false;
                          showShadowForChangeSize.value = false;
                        },
                        child: ValueListenableBuilder<bool>(
                            valueListenable: agreeToPolicies,
                            builder: (context, _agreeToPolicies, _) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                width: 1.sw,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: agreeToPolicies.value == true
                                        ? Colors.white
                                        : const Color(0xffC4C2C2),
                                    border: agreeToPolicies.value == false
                                        ? null
                                        : Border.all(
                                            color: const Color(0xff402CDD),
                                          ),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  LocaleKeys.yes_agree.tr(),
                                  textAlign: TextAlign.center,
                                  style:
                                      context.textTheme.bodyMedium?.br.copyWith(
                                    color: agreeToPolicies.value == true
                                        ? const Color(0xff402CDD)
                                        : Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            agreeToPolicies.value = false;

                            showShadowForCanselOrder.value = false;

                            showShadowForChangeAddress.value = false;
                            showShadowForChangeColor.value = false;
                            showShadowForChangeSize.value = false;
                          },
                          child: Text(
                            LocaleKeys.cansel.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                );
        });
  }*/

  Widget shadowForChangeOrderVariant(int tapIndex) {
    return ValueListenableBuilder<bool>(
        valueListenable: shadowForChangeVariant,
        builder: (context, _shadowForChangeVariant, _) {
          return !_shadowForChangeVariant
              ? SizedBox.shrink()
              : Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: Color.fromRGBO(29, 29, 29, 0.95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Spacer(),
                      SvgPicture.asset(
                        AppAssets.clarificationSvg,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        LocaleKeys.clarification.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 40,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        LocaleKeys.about_change_request_address.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        LocaleKeys.you_will_not_charged_fees.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        "${LocaleKeys.you_will_receive_your_refund_within.tr()} 12 ${LocaleKeys.hours.tr()}",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "${LocaleKeys.repeated_cancellations_affect_rating.tr()} \n ",
                          textAlign: TextAlign.start,
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 160.h,
                      ),
                      SvgPicture.asset(
                        AppAssets.termsCanselSvg,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        "${LocaleKeys.change_terms.tr()} ",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: agreeToPolicies,
                          builder: (context, _agreeToPolicies, _) {
                            return Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 1.sw,
                                child: InkWell(
                                  onTap: () =>
                                      agreeToPolicies.value = !_agreeToPolicies,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(AppAssets.detectedSvg,
                                          color: _agreeToPolicies
                                              ? Color(0xff388CFF)
                                              : Color(0xff8E8E8E)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        LocaleKeys.change_terms.tr(),
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                          decorationColor: Colors.white,
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                      SizedBox(
                        height: 30.h,
                      ),
                      InkWell(
                        onTap: () {
                          if (agreeToPolicies.value == false) {
                            return;
                          }
                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;
                          optionCanselOrReturn.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                        },
                        child: ValueListenableBuilder<bool>(
                            valueListenable: agreeToPolicies,
                            builder: (context, _agreeToPolicies, _) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                width: 1.sw,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: agreeToPolicies.value == true
                                        ? const Color(0xff3066CC)
                                        : const Color(0xffC4C2C2),
                                    border: agreeToPolicies.value == true
                                        ? Border.all(
                                            color: const Color(0xffF8F8F8),
                                          )
                                        : Border.all(
                                            color: const Color(0xffC4C2C2),
                                          ),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  LocaleKeys.i_agree_change.tr(),
                                  textAlign: TextAlign.center,
                                  style:
                                      context.textTheme.bodyMedium?.br.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            agreeToPolicies.value = false;
                            panelController.close();
                            showPanel.value = false;
                            optionModifyPanel.value = null;
                            enableChangeAddress.value = false;
                            showShadowForPanel.value = false;
                            showShadowForChangeAddress.value = false;
                            showShadowForCanselOrder.value = false;
                            optionCanselOrReturn.value = [];
                            shadowForChangeVariant.value = false;
                          },
                          child: Text(
                            LocaleKeys.i_disagree.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                );
        });
  }

  Widget shadowForCanselOrRutuenOrder(int tapIndex, bool isReturn) {
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForCanselOrder,
        builder: (context, _showShadowForCanselOrder, _) {
          return !_showShadowForCanselOrder
              ? SizedBox.shrink()
              : Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: Color.fromRGBO(29, 29, 29, 0.95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Spacer(),
                      SvgPicture.asset(
                        AppAssets.clarificationSvg,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        LocaleKeys.clarification.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 40,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        isReturn
                            ? LocaleKeys.about_return_your_product.tr()
                            : allOrder
                                ? LocaleKeys.about_cancel_order.tr()
                                : LocaleKeys.about_cancel_product.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      Text(
                        LocaleKeys.you_will_not_charged_fees.tr(),
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        "${LocaleKeys.you_will_receive_your_refund_within.tr()} 12 ${LocaleKeys.hours.tr()}",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "${LocaleKeys.repeated_cancellations_affect_rating.tr()} \n ",
                          textAlign: TextAlign.start,
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 160.h,
                      ),
                      SvgPicture.asset(
                        AppAssets.termsCanselSvg,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        "${LocaleKeys.terms_of_cancellation_term.tr()} ",
                        style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: agreeToPolicies,
                          builder: (context, _agreeToPolicies, _) {
                            return Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 1.sw,
                                child: InkWell(
                                  onTap: () =>
                                      agreeToPolicies.value = !_agreeToPolicies,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(AppAssets.detectedSvg,
                                          color: _agreeToPolicies
                                              ? Color(0xff388CFF)
                                              : Color(0xff8E8E8E)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        LocaleKeys.cancellation_term.tr(),
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                          decorationColor: Colors.white,
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                      SizedBox(
                        height: 30.h,
                      ),
                      InkWell(
                        onTap: () {
                          if (agreeToPolicies.value == false) {
                            return;
                          }
                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;
                          optionCanselOrReturn.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                        },
                        child: ValueListenableBuilder<bool>(
                            valueListenable: agreeToPolicies,
                            builder: (context, _agreeToPolicies, _) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                width: 1.sw,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: agreeToPolicies.value == true
                                        ? const Color(0xff3066CC)
                                        : const Color(0xffC4C2C2),
                                    border: agreeToPolicies.value == true
                                        ? Border.all(
                                            color: const Color(0xffF8F8F8),
                                          )
                                        : Border.all(
                                            color: const Color(0xffC4C2C2),
                                          ),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  LocaleKeys.i_agree_cancel.tr(),
                                  textAlign: TextAlign.center,
                                  style:
                                      context.textTheme.bodyMedium?.br.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            agreeToPolicies.value = false;
                            panelController.close();
                            showPanel.value = false;
                            optionModifyPanel.value = null;
                            enableChangeAddress.value = false;
                            showShadowForPanel.value = false;
                            showShadowForChangeAddress.value = false;
                            showShadowForCanselOrder.value = false;
                            optionCanselOrReturn.value = [];
                            shadowForChangeVariant.value = false;
                          },
                          child: Text(
                            LocaleKeys.i_disagree.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                );
        });
  }

  /* Widget shadowForChangeColor(int tapIndex) {
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForChangeColor,
        builder: (context, _showShadowForChangeColor, _) {
          colorIndexTap.value = (2) ~/ 2;
          return !_showShadowForChangeColor
              ? SizedBox.shrink()
              : Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: Color.fromRGBO(29, 29, 29, 0.95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.modifyOrderSvg,
                            width: 50,
                            color: Colors.white,
                          ),
                          SvgPicture.asset(
                            AppAssets.bagsOrderSvg,
                            color: Colors.white,
                            width: 25,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        LocaleKeys.change_below_color.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: const Color(0xffD3D3D3),
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        height: 138,
                        width: 1.sw,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xffD3D3D3))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                child: MyCachedNetworkImage(
                                    imageUrl: widget.order
                                            .details?[indexTap.value].image ??
                                        "",
                                    width: 70,
                                    imageFit: BoxFit.contain,
                                    height: 70),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                alignment: Alignment.center,
                                width: 150,
                                height: 20,
                                child: Text(
                                  "Denim Blue",
                                  style:
                                      context.textTheme.bodyMedium?.mr.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        LocaleKeys.to_new_color.tr(),
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          height: 138,
                          width: 1.sw,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Color(0xffD3D3D3))),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Container(
                              width: 78,
                              height: 138,
                              child: InkWell(
                                onTap: () => colorIndexTap.value = index,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(40)),
                                        child: MyCachedNetworkImage(
                                            imageUrl: widget
                                                    .order
                                                    .details?[indexTap.value]
                                                    .image ??
                                                "",
                                            width: 70,
                                            imageFit: BoxFit.contain,
                                            height: 70),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    ValueListenableBuilder<int>(
                                        valueListenable: colorIndexTap,
                                        builder: (context, _colorIndexTap, _) {
                                          return Container(
                                              alignment: Alignment.center,
                                              width: 150,
                                              height: 20,
                                              child: Text(
                                                "Denim Blue",
                                                style: index != _colorIndexTap
                                                    ? context.textTheme
                                                        .bodyMedium?.rr
                                                        .copyWith(
                                                        color: const Color(
                                                            0xffD3D3D3),
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: 1.3,
                                                      )
                                                    : context.textTheme
                                                        .bodyMedium?.mr
                                                        .copyWith(
                                                        color: Colors.white,
                                                        letterSpacing: 0.18,
                                                        fontSize: 14,
                                                        height: 1.3,
                                                      ),
                                              ));
                                        })
                                  ],
                                ),
                              ),
                            ),
                            itemCount: 2,
                          )),
                      SizedBox(
                        height: 70.h,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: agreeToPolicies,
                          builder: (context, _agreeToPolicies, _) {
                            return Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 1.sw,
                                child: InkWell(
                                  onTap: () =>
                                      agreeToPolicies.value = !_agreeToPolicies,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(AppAssets.detectedSvg,
                                          color: _agreeToPolicies
                                              ? Color(0xff388CFF)
                                              : Color(0xff8E8E8E)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      Text(
                                        LocaleKeys.change_color_terms.tr(),
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                          decorationColor: Colors.white,
                                          decoration: TextDecoration.underline,
                                          color: Colors.white,
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                      SizedBox(
                        height: 30.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '${LocaleKeys.we_will_ignore_first_color.tr()} "Blue" ${LocaleKeys.and_send_you_color.tr()} "Blue"',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      InkWell(
                        onTap: () {
                          if (agreeToPolicies.value == false) {
                            return;
                          }
                          agreeToPolicies.value = false;

                          showShadowForCanselOrder.value = false;
                          variantHasBeenChanged.value = true;
                          showShadowForChangeAddress.value = false;
                          showShadowForChangeColor.value = false;
                          showShadowForChangeSize.value = false;
                        },
                        child: ValueListenableBuilder<bool>(
                            valueListenable: agreeToPolicies,
                            builder: (context, _agreeToPolicies, _) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                width: 1.sw,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: agreeToPolicies.value == true
                                        ? Colors.white
                                        : const Color(0xffC4C2C2),
                                    border: agreeToPolicies.value == false
                                        ? null
                                        : Border.all(
                                            color: const Color(0xff402CDD),
                                          ),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  LocaleKeys.yes_agree.tr(),
                                  textAlign: TextAlign.center,
                                  style:
                                      context.textTheme.bodyMedium?.br.copyWith(
                                    color: agreeToPolicies.value == true
                                        ? const Color(0xff402CDD)
                                        : Colors.white,
                                    letterSpacing: 0.18,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 200,
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            agreeToPolicies.value = false;

                            showShadowForCanselOrder.value = false;

                            showShadowForChangeAddress.value = false;
                            showShadowForChangeColor.value = false;
                            showShadowForChangeSize.value = false;
                          },
                          child: Text(
                            LocaleKeys.cansel.tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                );
        });
  }*/

  Widget shadowForChangeAddressContent(int tapIndex) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.getCustomerAddressStatus !=
              current.getCustomerAddressStatus ||
          previous.editAddressToOrderStatus !=
              current.editAddressToOrderStatus ||
          previous.setCustomerAddressDefaultStatus !=
              current.setCustomerAddressDefaultStatus ||
          previous.addAddressToOrderStatus != current.addAddressToOrderStatus ||
          previous.removeAddressToOrderStatus !=
              current.removeAddressToOrderStatus,
      builder: (context, state) {
        return ValueListenableBuilder<bool>(
            valueListenable: showShadowForChangeAddress,
            builder: (context, isShowShadowForChangeAddress, _) {
              return !isShowShadowForChangeAddress
                  ? SizedBox.shrink()
                  : Container(
                      height: 1.sh,
                      width: 1.sw,
                      color: Color.fromRGBO(29, 29, 29, 0.95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.clarificationSvg,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            LocaleKeys.clarification.tr(),
                            style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 40,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            LocaleKeys.about_change_request_address.tr(),
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          SvgPicture.asset(
                            AppAssets.orderChangeAddressSvg,
                            width: 50,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            LocaleKeys.change_below_address.tr(),
                            style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: const Color(0xffD3D3D3),
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: addressInfoWithContactInfoCart(
                              isChange: true,
                              customerAddressesInfo:
                                  state.listOfAddressInfoClassToSave![
                                      state.currentAddressChoosed ?? 0],
                              context: context,
                              index: 0,
                              indexTap: 1,
                              onTapDelete: () {},
                              onTapEdit: () {
                                //     panelController.close();
                                HelperFunctions.slidingNavigation(
                                  context,
                                  AddShippingAdress(
                                    addressInfoClassToEdid:
                                        state.listOfAddressInfoClassToSave![
                                            state.currentAddressChoosed ?? 0],
                                    fromEdid: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            LocaleKeys.to_new_address.tr(),
                            style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: addressInfoWithContactInfoCart(
                              isChange: true,
                              customerAddressesInfo:
                                  state.listOfAddressInfoClassToSave![tapIndex],
                              context: context,
                              index: 0,
                              indexTap: 0,
                              onTapDelete: () {},
                              onTapEdit: () {
                                // panelController.close();
                                HelperFunctions.slidingNavigation(
                                  context,
                                  AddShippingAdress(
                                    addressInfoClassToEdid:
                                        state.listOfAddressInfoClassToSave![
                                            tapIndex],
                                    fromEdid: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Text(
                            LocaleKeys
                                .we_will_ignore_first_address_send_order_new_address
                                .tr(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          SvgPicture.asset(
                            AppAssets.termsCanselSvg,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "${LocaleKeys.terms_of_change_address_terms.tr()} ",
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: agreeToPolicies,
                              builder: (context, _agreeToPolicies, _) {
                                return Container(
                                    alignment: Alignment.center,
                                    height: 40.h,
                                    width: 1.sw,
                                    child: InkWell(
                                      onTap: () => agreeToPolicies.value =
                                          !_agreeToPolicies,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                              AppAssets.detectedSvg,
                                              color: _agreeToPolicies
                                                  ? Color(0xff388CFF)
                                                  : Color(0xff8E8E8E)),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                            style: context
                                                .textTheme.bodyMedium?.rr
                                                .copyWith(
                                              color: Colors.white,
                                              letterSpacing: 0.18,
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                          Text(
                                            LocaleKeys.change_addres_terms.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.mr
                                                .copyWith(
                                              decorationColor: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.white,
                                              letterSpacing: 0.18,
                                              fontSize: 16,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              }),
                          SizedBox(
                            height: 10.h,
                          ),
                          InkWell(
                            onTap: () {
                              if (agreeToPolicies.value == false) {
                                return;
                              }
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              showShadowForCanselOrder.value = false;
                              enableChangeAddress.value = false;
                              optionCanselOrReturn.value = [];
                              showShadowForPanel.value = false;
                              showShadowForChangeAddress.value = false;
                              shadowForChangeVariant.value = false;
                            },
                            child: ValueListenableBuilder<bool>(
                                valueListenable: agreeToPolicies,
                                builder: (context, _agreeToPolicies, _) {
                                  return Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    alignment: Alignment.center,
                                    width: 1.sw,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                        color: agreeToPolicies.value == true
                                            ? Colors.white
                                            : const Color(0xffC4C2C2),
                                        border: agreeToPolicies.value == false
                                            ? null
                                            : Border.all(
                                                color: const Color(0xff402CDD),
                                              ),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      LocaleKeys.i_agree_change.tr(),
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.bodyMedium?.br
                                          .copyWith(
                                        color: agreeToPolicies.value == true
                                            ? const Color(0xff402CDD)
                                            : Colors.white,
                                        letterSpacing: 0.18,
                                        fontSize: 16,
                                        height: 1.3,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 200,
                            height: 40.h,
                            child: InkWell(
                              onTap: () {
                                agreeToPolicies.value = false;
                                panelController.close();
                                showPanel.value = false;
                                optionModifyPanel.value = null;
                                optionCanselOrReturn.value = [];
                                enableChangeAddress.value = false;
                                showShadowForPanel.value = false;
                                showShadowForChangeAddress.value = false;
                                shadowForChangeVariant.value = false;
                                showShadowForCanselOrder.value = false;
                              },
                              child: Text(
                                LocaleKeys.i_disagree.tr(),
                                textAlign: TextAlign.center,
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  color: Colors.white,
                                  decorationColor: Colors.white,
                                  decoration: TextDecoration.underline,
                                  letterSpacing: 0.18,
                                  fontSize: 16,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          )
                        ],
                      ),
                    );
            });
      },
    );
  }

  Widget panelWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: showPanel,
      builder: (context, isShowPanel, _) {
        return Positioned(
            bottom: 0,
            child: ValueListenableBuilder<String?>(
                valueListenable: optionModifyPanel,
                builder: (context, _option, _) {
                  return Container(
                      width: 1.sw,
                      height: isShowPanel
                          ? ((_option == null)
                              ? 524
                              : (_option == "All_Order")
                                  ? 512
                                  : (1.sh - 70))
                          : 0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.r),
                              topRight: Radius.circular(30.r))),
                      child: SlidingUpPanel(
                        controller: panelController,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r)),
                        isDraggable: true,
                        onPanelClosed: () {
                          colorIndexTap.value = null;
                          sizeIndexTap.value = null;
                          agreeToPolicies.value = false;
                          variantHasBeenChanged.value = false;
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          optionCanselOrReturn.value = [];
                          showShadowForChangeAddress.value = false;

                          showShadowForCanselOrder.value = false;
                          shadowForChangeVariant.value = false;
                        },
                        onPanelOpened: () {},
                        minHeight: 0,
                        maxHeight: _option == null ? 524 : (1.sh - 70),
                        panelBuilder: (sc) => panelBuilderContent(_option, sc),
                      ));
                }));
      },
    );
  }

  Widget panelAddressContent(ScrollController sc) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.getCustomerAddressStatus !=
              current.getCustomerAddressStatus ||
          previous.editAddressToOrderStatus !=
              current.editAddressToOrderStatus ||
          previous.setCustomerAddressDefaultStatus !=
              current.setCustomerAddressDefaultStatus ||
          previous.addAddressToOrderStatus != current.addAddressToOrderStatus ||
          previous.removeAddressToOrderStatus !=
              current.removeAddressToOrderStatus,
      builder: (context, state) {
        return ValueListenableBuilder<int>(
          valueListenable: indexTapAddress,
          builder: (context, _indexTap, _) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                        color: Color(0xffC4C2C2),
                        border: Border.all(color: Color(0xffC4C2C2)),
                        borderRadius: BorderRadius.all(Radius.circular(2))),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 1.sw,
                    height: 200.h,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Color(0xffF8F8F8),
                        border: Border.all(color: Color(0xffF8F8F8)),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: 1.sw,
                          height: 16.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(
                                AppAssets.orderClockSvg,
                                height: 15.h,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                HelperFunctions.orderFormatDate(
                                  DateTime.tryParse(
                                          widget.order.createdAt ?? '') ??
                                      DateTime.now(),
                                ),
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppAssets.orderBag1Svg,
                                height: 15.h,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.order.orderGroupId ?? "",
                                style:
                                    context.textTheme.bodyMedium?.mr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: 1.sw,
                          height: 16.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(
                                AppAssets.preparingBagSvg,
                                height: 15.h,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.order.orderGroupStatus?.label ?? "",
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              SvgPicture.asset(
                                AppAssets.orderPreparingSvg,
                                height: 15.h,
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                AppAssets.orderInvoice2Svg,
                                height: 15.h,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                (widget.order.details?.length ?? "").toString(),
                                style:
                                    context.textTheme.bodyMedium?.br.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                LocaleKeys.item.tr(),
                                style:
                                    context.textTheme.bodyMedium?.mr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                (widget.order.orderAmount! *
                                        homeBloc
                                            .state
                                            .getCurrencyForCountryModel!
                                            .data!
                                            .currency!
                                            .exchangeRate!)
                                    .toStringAsFixed(homeBloc
                                            .state
                                            .startingSetting
                                            ?.decimalPointSettings ??
                                        0),
                                style:
                                    context.textTheme.bodyMedium?.br.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                homeBloc.state.getCurrencyForCountryModel!.data!
                                    .currency!.symbol!,
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          height: 125.h,
                          width: 1.sw,
                          padding: EdgeInsets.only(
                              left:
                                  LanguageService.languageCode == "ar" ? 0 : 10,
                              right: LanguageService.languageCode != "ar"
                                  ? 0
                                  : 10),
                          child: ListView.builder(
                            itemCount: widget.order.details?.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 125.h,
                                width: 92,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  child: MyCachedNetworkImage(
                                      imageUrl:
                                          widget.order.details?[index].image ??
                                              "",
                                      width: 92,
                                      imageFit: BoxFit.contain,
                                      height: 125.h),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SvgPicture.asset(
                    AppAssets.orderChangeAddressSvg,
                    height: 30.h,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text(
                    LocaleKeys.change_delivery_address.tr(),
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    LocaleKeys.you_can_change_delivery_address_delivery_note
                        .tr(),
                    style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: const Color(0xff8D8D8D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 1.sw,
                    height: 0.5,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                        color: Color(0xffC4C2C2),
                        border: Border.all(color: Color(0xffC4C2C2)),
                        borderRadius: BorderRadius.all(Radius.circular(2))),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: addressWidgets(context, state, _indexTap, sc),
                  ),
                  Spacer(),
                  ValueListenableBuilder<bool>(
                      valueListenable: enableChangeAddress,
                      builder: (context, _enableChangeAddress, _) {
                        return InkWell(
                          onTap: () {
                            if (_enableChangeAddress) {
                              showShadowForChangeAddress.value = true;
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              width: 1.sw,
                              height: 53,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _enableChangeAddress
                                    ? const Color(0xff402CDD)
                                    : const Color(0xffD3D3D3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${LocaleKeys.change_request.tr()} ",
                                style: context.textTheme.bodyMedium?.mr
                                    .copyWith(
                                        color: const Color(0xffFFFFFF),
                                        letterSpacing: 0.18,
                                        fontSize: 16,
                                        height: 1.33),
                              )),
                        );
                      }),
                  SizedBox(
                    height: 10.h,
                  ),
                ]);
          },
        );
      },
    );
  }

  /* Widget panelVariantContent(ScrollController sc) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.modifyOrderSvg,
                width: 23,
              ),
              SvgPicture.asset(
                AppAssets.bagsOrderSvg,
                color: const Color(0xff402CDD),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            LocaleKeys.modify_order.tr(),
            style: context.textTheme.bodyMedium?.mq.copyWith(
              color: const Color(0xff402CDD),
              letterSpacing: 0.18,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            LocaleKeys.you_can_modify_order_within_specific_period.tr(),
            style: context.textTheme.bodyMedium?.rr.copyWith(
              color: const Color(0xff8D8D8D),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          Text(
            LocaleKeys.cancel_the_order_any_time_get_full_refund.tr(),
            style: context.textTheme.bodyMedium?.rr.copyWith(
              color: const Color(0xff8D8D8D),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            width: 1.sw,
            height: 1.sh - 330.h,
            child: ListView.builder(
              padding: EdgeInsets.all(0),
              controller: sc,
              itemBuilder: (context, index) {
                if (index == (widget.order.details?.length ?? 0)) {
                  return SizedBox(height: 20);
                }

                return productWidget(index);
              },
              itemCount: (widget.order.details?.length ?? 0) + 1,
            ),
          ),
          Spacer(),
          ValueListenableBuilder<bool>(
              valueListenable: variantHasBeenChanged,
              builder: (context, _variantHasBeenChanged, _) {
                return InkWell(
                  onTap: () {
                    if (_variantHasBeenChanged) {
                      panelController.close();
                    }
                  },
                  child: Container(
                      margin: EdgeInsets.all(24),
                      width: 1.sw,
                      height: 53,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _variantHasBeenChanged
                            ? const Color(0xff3066CC)
                            : const Color(0xffD3D3D3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${LocaleKeys.modify_close.tr()} ",
                        style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xffFFFFFF),
                            letterSpacing: 0.18,
                            fontSize: 16,
                            height: 1.33),
                      )),
                );
              }),
        ]);
  }
*/
  /*Widget productWidget(int index) {
    return Container(
      width: 1.sw,
      height: 187,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8),
            height: 0.5,
            width: 1.sw,
            color: Color(0xffC4C2C2),
          ),
          Container(
            height: 170,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: MyCachedNetworkImage(
                      imageUrl: widget.order.details?[index].image ?? '',
                      imageFit: BoxFit.contain,
                      width: 100,
                      height: 150,
                    ),
                  ),
                ),
                ///////////////////
                const SizedBox(
                  width: 12,
                ),
                ///////////////////
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 8,
                          width: 50,
                          color: Colors.black,
                        ),
                        ///////////////////
                        const SizedBox(
                          height: 5,
                        ),
                        ///////////////////
                        Text(
                          widget.order.details?[index].productDetails?.name ??
                              '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff505050),
                            letterSpacing: 0.18,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        ///////////////////
                        widget.order.details?[index].variation?.color == "" ||
                                widget.order.details?[index].variation?.color ==
                                    null
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        ///////////////////
                        widget.order.details?[index].variation?.color == "" ||
                                widget.order.details?[index].variation?.color ==
                                    null
                            ? SizedBox.shrink()
                            : Row(
                                children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${LocaleKeys.color.tr()} : ',
                                        ),
                                        ////////////////////////////
                                        TextSpan(
                                          text: widget.order.details?[index]
                                                      .variation ==
                                                  null
                                              ? ''
                                              : widget.order.details?[index]
                                                      .variation?.color ??
                                                  '',
                                          style: context
                                              .textTheme.bodyMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            fontSize: 10,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () =>
                                        showShadowForChangeColor.value = true,
                                    child: Container(
                                      width: 50,
                                      height: 15,
                                      child: Text(
                                        LocaleKeys.change.tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          decorationColor:
                                              const Color(0xff388CFF),
                                          decoration: TextDecoration.underline,
                                          color: const Color(0xff388CFF),
                                          letterSpacing: 0.18,
                                          fontSize: 10,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ///////////////////
                        widget.order.details?[index].variation?.size == "" ||
                                widget.order.details?[index].variation?.size ==
                                    null
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        widget.order.details?[index].variation?.size == "" ||
                                widget.order.details?[index].variation?.size ==
                                    null
                            ? SizedBox.shrink()
                            : Row(
                                children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                      children: [
                                        widget.order.details?[index].variation
                                                    ?.size ==
                                                ""
                                            ? TextSpan(text: "")
                                            : TextSpan(
                                                text:
                                                    '${LocaleKeys.size.tr()} : ',
                                              ),
                                        ////////////////////////////
                                        TextSpan(
                                          text: widget.order.details?[index]
                                                      .variation ==
                                                  null
                                              ? ''
                                              : widget.order.details?[index]
                                                      .variation?.size ??
                                                  '',
                                          style: context
                                              .textTheme.bodyMedium?.mq
                                              .copyWith(
                                            color: const Color(0xff505050),
                                            letterSpacing: 0.18,
                                            fontSize: 10,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () =>
                                        showShadowForChangeSize.value = true,
                                    child: Container(
                                      width: 50,
                                      height: 15,
                                      child: Text(
                                        LocaleKeys.change.tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          decorationColor:
                                              const Color(0xff388CFF),
                                          decoration: TextDecoration.underline,
                                          color: const Color(0xff388CFF),
                                          letterSpacing: 0.18,
                                          fontSize: 10,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                        ///////////////////
                        const SizedBox(
                          height: 5,
                        ),
                        ///////////////////
                        Row(
                          children: [
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  style:
                                      context.textTheme.bodyMedium?.rq.copyWith(
                                    color: const Color(0xff8D8D8D),
                                    letterSpacing: 0.18,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${LocaleKeys.item_status.tr()}: ',
                                    ),
                                    ////////////////////////////
                                    TextSpan(
                                      text: widget.order.details?[index]
                                              .orderProductStatus?.label ??
                                          widget.order.orderStatus?.label ??
                                          "",
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                        color: const Color(0xff505050),
                                        letterSpacing: 0.18,
                                        fontSize: 10,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ///////////////////
                            SizedBox(
                              width: 12,
                            ),
                            ///////////////////
                            SvgPicture.asset(
                              AppAssets.orderPreparingSvg,
                              width: 15,
                            ),
                          ],
                        ),
                        ////////////////////
                        const SizedBox(
                          height: 5,
                        ),
                        ////////////////////
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xffC4C2C2),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${((widget.order.details?[index].productDetails?.price ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                style:
                                    context.textTheme.bodyMedium?.rq.copyWith(
                                  color: const Color(0xffC4C2C2),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              ////////////////////////////
                              TextSpan(
                                text:
                                    ' ${((widget.order.details?[index].productDetails?.offerPrice ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                style:
                                    context.textTheme.bodyMedium?.bq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              /////////////
                              TextSpan(
                                text:
                                    ' ${(GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.symbol!)}',
                                style:
                                    context.textTheme.bodyMedium?.lq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 200,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppAssets.orderCanselSvg,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                LocaleKeys.cancel_this_product.tr(),
                                overflow: TextOverflow.ellipsis,
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  decorationColor: const Color(0xffFF5F61),
                                  decoration: TextDecoration.underline,
                                  color: const Color(0xffFF5F61),
                                  letterSpacing: 0.18,
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          (index == ((widget.order.details?.length ?? 0) - 1))
              ? Container(
                  margin: EdgeInsets.only(top: 8),
                  height: 0.5,
                  width: 1.sw,
                  color: Color(0xffC4C2C2),
                )
              : SizedBox.fromSize()
        ],
      ),
    );
  }*/

  Widget addressWidgets(
    BuildContext context,
    OrderState state,
    int _indexTap,
    ScrollController sc,
  ) {
    return Container(
        width: 1.sw,
        height: 410.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 50.h,
              width: 1.sw,
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                  color: Color(0xffF8F8F8),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 50.h,
                    width: ((1.sw - 58) / 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff402CDD)),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Text(
                      LocaleKeys.delivery_address.tr(),
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.33),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 50.h,
                    width: ((1.sw - 58) / 2),
                    decoration: BoxDecoration(
                        //   border: Border.all(color: Color(0xff402CDD)),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Text(
                      LocaleKeys.delivery_note.tr(),
                      style: context.textTheme.bodyMedium?.rr.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.33),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              "${LocaleKeys.your_address_list.tr()} ",
              style: context.textTheme.bodyMedium?.mr.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12,
                  height: 1.33),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 295.h,
              width: 1.sw,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemBuilder: (context, index) => index ==
                        state.listOfAddressInfoClassToSave!.length
                    ? InkWell(
                        onTap: () {
                          // panelController.close();
                          HelperFunctions.slidingNavigation(
                              context, AddShippingAdress());
                        },
                        child: Container(
                          height: 40,
                          width: 1.sw,
                          decoration: BoxDecoration(
                              color: Color(0xffE8FFED),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Color(0xffC4C2C2))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.addShippingAddressSvg,
                                    ),
                                    Positioned(
                                      top: 2,
                                      child: SvgPicture.asset(
                                        AppAssets.addShippingAddressWhiteSvg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                "${LocaleKeys.add_new_shipping_address.tr()} ",
                                style: context.textTheme.bodyMedium?.mr
                                    .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.33),
                              ),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          if (index != state.currentAddressChoosed) {
                            enableChangeAddress.value = true;
                          } else {
                            enableChangeAddress.value = false;
                          }
                          indexTapAddress.value = index;
                        },
                        child: addressInfoWithContactInfoCart(
                          isChange: false,
                          customerAddressesInfo:
                              state.listOfAddressInfoClassToSave![index],
                          context: context,
                          index: index,
                          indexTap: _indexTap,
                          onTapDelete: () {},
                          onTapEdit: () {
                            //   panelController.close();
                            HelperFunctions.slidingNavigation(
                              context,
                              AddShippingAdress(
                                addressInfoClassToEdid:
                                    state.listOfAddressInfoClassToSave![index],
                                fromEdid: true,
                              ),
                            );
                          },
                        ),
                      ),
                separatorBuilder: (context, index) => SizedBox(
                  height: 10,
                ),
                itemCount: state.listOfAddressInfoClassToSave!.length + 1,
                controller: sc,
              ),
            ),
          ],
        ));
  }

  Widget addressInfoWithContactInfoCart({
    required CustomerAddressesInfo customerAddressesInfo,
    required int index,
    required int indexTap,
    required bool isChange,
    required BuildContext context,
    required void Function()? onTapEdit,
    required void Function()? onTapDelete,
  }) {
    return Container(
        // height: (placeOrder ?? false)
        //     ? 120
        //     : (!isDelete && cartChoosed)
        //         ? 125
        //         : 90,
        width: 1.sw,
        height: 100,
        padding: EdgeInsets.only(
          right: LanguageService.languageCode == "ar" ? 20 : 10,
          left: LanguageService.languageCode != "ar" ? 20 : 10,
          bottom: 5,
        ),
        decoration: BoxDecoration(
            color: isChange ? Color.fromRGBO(0, 0, 0, 0) : Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
            border: isChange
                ? Border.all(
                    color: (isChange && index != indexTap)
                        ? Color(0xffD3D3D3)
                        : Colors.white)
                : index != indexTap
                    ? null
                    : Border.all(color: Color(0xff388CFF))),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              width: 360.w,
              height: 16,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.homeInactiveSvg,
                    color: (isChange && index != indexTap)
                        ? Color(0xffD3D3D3)
                        : (isChange && index == indexTap)
                            ? Colors.white
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    customerAddressesInfo.address ?? "",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? Color(0xffD3D3D3)
                            : isChange
                                ? Color(0xffFFFFFF)
                                : index != indexTap
                                    ? Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  Spacer(),
                  isChange
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: onTapEdit,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            width: 20,
                            height: 30,
                            child: SvgPicture.asset(
                              AppAssets.editSvg,
                              height: 30,
                              width: 20,
                            ),
                          ),
                        ),
                  /*  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : SizedBox(
                          width: 10,
                        ),
                  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: onTapDelete,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            width: 20,
                            height: 30,
                            child: SvgPicture.asset(
                              AppAssets.deletecartSvg,
                              height: 14,
                              width: 14,
                            ),
                          ),
                        ),*/
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Text(
                    "${(customerAddressesInfo.regionDetails?.building.toString() == "null" || customerAddressesInfo.regionDetails?.building == "") ? "" : customerAddressesInfo.regionDetails?.building}${(customerAddressesInfo.regionDetails?.building.toString() != "null" && customerAddressesInfo.regionDetails?.building != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.street.toString() == "null" || customerAddressesInfo.regionDetails?.street == "" ? "" : customerAddressesInfo.regionDetails?.street}${(customerAddressesInfo.regionDetails?.street.toString() != "null" && customerAddressesInfo.regionDetails?.street != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.town.toString() == "null" || customerAddressesInfo.regionDetails?.town == "" ? "" : customerAddressesInfo.regionDetails?.town}${(customerAddressesInfo.regionDetails?.town.toString() != "null" && customerAddressesInfo.regionDetails?.town != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.city.toString() == "null" || customerAddressesInfo.regionDetails?.city == "" ? "" : customerAddressesInfo.regionDetails?.city}${(customerAddressesInfo.regionDetails?.city.toString() != "null" && customerAddressesInfo.regionDetails?.city != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.province.toString() == "null" || customerAddressesInfo.regionDetails?.province == "" ? "" : customerAddressesInfo.regionDetails?.province} | ${customerAddressesInfo.regionDetails?.country ?? ''}",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? Color(0xffD3D3D3)
                            : isChange
                                ? Color(0xffFFFFFF)
                                : index != indexTap
                                    ? Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  )
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: Row(
                children: [
                  Text(
                    "${customerAddressesInfo.addressDetail}",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? Color(0xffD3D3D3)
                            : isChange
                                ? Color(0xffFFFFFF)
                                : index != indexTap
                                    ? Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  )
                ],
              ),
            ),
            Container(
              width: 350.w,
              height: 16,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.phoneCallSvg,
                    color: (isChange && index != indexTap)
                        ? Color(0xffD3D3D3)
                        : isChange
                            ? Color(0xffFFFFFF)
                            : index != indexTap
                                ? Color(0xff8D8D8D)
                                : Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '+${customerAddressesInfo.contactInfo?.phone ?? ""}',
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? Color(0xffD3D3D3)
                            : isChange
                                ? Color(0xffFFFFFF)
                                : index != indexTap
                                    ? Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Container(
                    height: 16,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.personSvg,
                          color: (isChange && index != indexTap)
                              ? Color(0xffD3D3D3)
                              : isChange
                                  ? Color(0xffFFFFFF)
                                  : index != indexTap
                                      ? Color(0xff8D8D8D)
                                      : Color(0xff1D1D1D),
                          height: 12,
                          width: 12,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${customerAddressesInfo.contactInfo?.name ?? ""}',
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: (isChange && index != indexTap)
                                  ? Color(0xffD3D3D3)
                                  : isChange
                                      ? Color(0xffFFFFFF)
                                      : index != indexTap
                                          ? Color(0xff8D8D8D)
                                          : const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  /*  Spacer(),
                  index != indexTap || isDelete
                      ? SizedBox.shrink()
                      : SvgPicture.asset(
                          AppAssets.shareSvg,
                          color: isDelete || cartChoosed
                              ? Color(0xffFFFFFF)
                              : Color(0xff388CFF),
                          allowDrawingOutsideViewBox: true,
                          height: 12,
                          width: 12,
                        ),*/
                ],
              ),
            ),
            /*   SizedBox(
                    height: 5,
                  ),
            Container(
                    height: 30,
                    width: 1.sw,
                    decoration: BoxDecoration(
                        color:
                          Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${LocaleKeys.expected_delivery.tr()}',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 10,
                              height: 1.3),
                        ),
                        Text(
                          ' ${HelperFunctions.getDateInFormatForShippingDays(int.tryParse(shippingDays ?? "0") ?? 0)}. ',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 10,
                              height: 1.3),
                        ),
                        Text(
                          '${LocaleKeys.delivery_not.tr()}',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xff388CFF),
                              color: const Color(0xff388CFF),
                              letterSpacing: 0.18,
                              fontSize: 10,
                              height: 1.3),
                        ),
                      ],
                    ))*/
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
  }

  Widget panelBuilderContent(
    String? _option,
    ScrollController sc,
  ) {
    if (_option == "All_Order") {
      return optionsForAllOrder();
    }
    if (_option == "Change_Address") {
      return panelAddressContent(sc);
    }
    if (_option == "Cancel_This_Product") {
      return panelCanelContent(sc);
    }
    if (_option == "Return_This_Product") {
      return panelReturnedContent(sc);
    }
    if (_option == "Change_Product_Request") {
      return panelVaraintContent(sc);
    }
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r))),
        height: _option == null ? 524 : (1.sh - 85.h),
        width: 1.sw,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                    color: Color(0xffC4C2C2),
                    border: Border.all(color: Color(0xffC4C2C2)),
                    borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: 104,
                  height: 144,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white,
                      child: MyCachedNetworkImage(
                        withInnerShadow: true,
                        withImageShadow: true,
                        radius: 15,
                        imageUrl:
                            widget.order.details?[indexTap.value].image ?? "",
                        imageFit: BoxFit.contain,
                        width: 100,
                        height: 150,
                      ),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Text("${LocaleKeys.action_about_product.tr()}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 1.sw,
                height: 0.5,
                decoration: BoxDecoration(
                    color: Color(0xffC4C2C2),
                    border: Border.all(color: Color(0xffC4C2C2)),
                    borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Change_Product_Request";
                    },
                    svg: AppAssets.changeProductRequestSvg,
                    image2: widget.order.details?[indexTap.value].image ?? "",
                    tiltle: "${LocaleKeys.change_product_request.tr()}",
                    body: "${LocaleKeys.change_size_color_other.tr()}"),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Return_This_Product";
                    },
                    svg: AppAssets.returnThisProductSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.return_this_product.tr()}",
                    body:
                        "${LocaleKeys.return_this_product_in_24_hours_and_back_your_money.tr()}"),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Report_This_Product";
                    },
                    svg: AppAssets.reporthisProductSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.report_this_product.tr()}",
                    body:
                        "${LocaleKeys.delivery_time_delivery_man_delivery_car.tr()}"),
              ),
              /*    Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Cancel_This_Product";
                    },
                    svg: AppAssets.orderCanselSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.cancel_this_product.tr()}",
                    body: "Cancel This Product In 3 Hours And Back Your Money"),
              ),*/
              SizedBox(
                height: 5,
              ),
              /*  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Change_Address";
                    },
                    svg: AppAssets.orderChangeAddressSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.change_delivery_address.tr()}",
                    body:
                        "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}"),
              ),*/
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      optionModifyPanel.value = "Hide_This_Product";
                    },
                    svg: AppAssets.hideThisProductSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.hide_this_product.tr()}",
                    body: "${LocaleKeys.hide_this_product_from_list.tr()}"),
              ),
            ]));
  }

  Widget panelCanelContent(ScrollController sc) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 15.h,
          ),
          allOrder
              ? Container(
                  width: 1.sw,
                  height: 200.h,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      border: Border.all(color: Color(0xffF8F8F8)),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        width: 1.sw,
                        height: 16.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppAssets.orderClockSvg,
                              height: 15.h,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              HelperFunctions.orderFormatDate(
                                DateTime.tryParse(
                                        widget.order.createdAt ?? '') ??
                                    DateTime.now(),
                              ),
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            Spacer(),
                            SvgPicture.asset(
                              AppAssets.orderBag1Svg,
                              height: 15.h,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.order.orderGroupId ?? "",
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        width: 1.sw,
                        height: 16.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppAssets.preparingBagSvg,
                              height: 15.h,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.order.orderGroupStatus?.label ?? "",
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              AppAssets.orderPreparingSvg,
                              height: 15.h,
                            ),
                            Spacer(),
                            SvgPicture.asset(
                              AppAssets.orderInvoice2Svg,
                              height: 15.h,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              (widget.order.details?.length ?? "").toString(),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              LocaleKeys.item.tr(),
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              (widget.order.orderAmount! *
                                      homeBloc.state.getCurrencyForCountryModel!
                                          .data!.currency!.exchangeRate!)
                                  .toStringAsFixed(homeBloc
                                          .state
                                          .startingSetting
                                          ?.decimalPointSettings ??
                                      0),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              homeBloc.state.getCurrencyForCountryModel!.data!
                                  .currency!.symbol!,
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        height: 125.h,
                        width: 1.sw,
                        padding: EdgeInsets.only(
                            left: LanguageService.languageCode == "ar" ? 0 : 10,
                            right:
                                LanguageService.languageCode != "ar" ? 0 : 10),
                        child: ListView.builder(
                          itemCount: widget.order.details?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 125.h,
                              width: 92,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                child: MyCachedNetworkImage(
                                    imageUrl:
                                        widget.order.details?[index].image ??
                                            "",
                                    width: 92,
                                    imageFit: BoxFit.contain,
                                    height: 125.h),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                )
              : Container(
                  width: 104,
                  height: 140.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white,
                      child: MyCachedNetworkImage(
                        withInnerShadow: true,
                        withImageShadow: true,
                        radius: 15,
                        imageUrl:
                            widget.order.details?[indexTap.value].image ?? "",
                        imageFit: BoxFit.contain,
                        width: 100,
                        height: 140,
                      ),
                    ),
                  )),
          SizedBox(
            height: 8.h,
          ),
          SvgPicture.asset(
            AppAssets.orderCanselSvg,
            width: 30,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text(
              "${allOrder ? LocaleKeys.cancel_this_order.tr() : LocaleKeys.cancel_this_product.tr()}",
              style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3,
              )),
          SizedBox(
            height: 8.h,
          ),
          Text("${LocaleKeys.you_can_cancel_product_without_condition.tr()}",
              maxLines: 1,
              style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${LocaleKeys.cancel_policy_refund.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
              Text(" 140",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.br.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
              Text(" USD ${LocaleKeys.to_your_account.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            width: 1.sw,
            height: 0.5,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 30.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "${allOrder ? LocaleKeys.why_was_order_cancelled.tr() : LocaleKeys.why_was_product_cancel.tr()} ",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  )),
              Text(" ${LocaleKeys.learn_more_tips.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff402CDD),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          canselContent()
        ]);
  }

  Widget panelVaraintContent(ScrollController sc) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
              width: 104,
              height: 140.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.white,
                  child: MyCachedNetworkImage(
                    withInnerShadow: true,
                    withImageShadow: true,
                    radius: 15,
                    imageUrl: widget.order.details?[indexTap.value].image ?? "",
                    imageFit: BoxFit.contain,
                    width: 100,
                    height: 140,
                  ),
                ),
              )),
          SizedBox(
            height: 15.h,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.changeProductRequestSvg,
                width: 30,
                color: Color(0xff1D1D1D),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: MyCachedNetworkImage(
                  radius: 15,
                  imageUrl: widget.order.details?[indexTap.value].image ?? "",
                  imageFit: BoxFit.fill,
                  width: 20,
                  height: 20,
                ),
              )
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Text("${LocaleKeys.change_product_request.tr()}",
              style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3,
              )),
          SizedBox(
            height: 8.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Text(
                "${LocaleKeys.you_can_change_variant_product_without_conditions.tr()}",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.rr.copyWith(
                  color: const Color(0xff8D8D8D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 1.sw,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 0.5,
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 10,
          ),
          changeSizeOrColorOrQty(),
          Spacer(),
          ValueListenableBuilder<int?>(
              valueListenable: colorIndexTap,
              builder: (context, _colorIndexTap, _) {
                return ValueListenableBuilder<int?>(
                    valueListenable: sizeIndexTap,
                    builder: (context, _sizeIndexTap, _) {
                      return InkWell(
                        onTap: () {
                          if (_sizeIndexTap != null || _colorIndexTap != null) {
                            shadowForChangeVariant.value = true;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            alignment: Alignment.center,
                            width: 1.sw,
                            height: 53,
                            decoration: BoxDecoration(
                                color: (_sizeIndexTap != null ||
                                        _colorIndexTap != null)
                                    ? Color(0xff402CDD)
                                    : Color(0xffD3D3D3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text("${LocaleKeys.change_request.tr()}",
                                maxLines: 1,
                                style:
                                    context.textTheme.bodyMedium?.mr.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.18,
                                  fontSize: 16,
                                  height: 1.3,
                                )),
                          ),
                        ),
                      );
                    });
              }),
        ]);
  }

  Widget changeSizeOrColorOrQty() {
    return ValueListenableBuilder<String?>(
        valueListenable: optionVariant,
        builder: (context, _option, _) {
          return Column(
            children: [
              Container(
                width: 1.sw,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 50,
                decoration: BoxDecoration(
                    color: Color(0xffF8F8F8),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        optionVariant.value = "color";
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        width: (1.sw - 48) / 3,
                        decoration: BoxDecoration(
                            border: _option == "color"
                                ? Border.all(color: Color(0xff402CDD))
                                : null,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text("${LocaleKeys.change_color.tr()}",
                            textAlign: TextAlign.center,
                            style: _option == "color"
                                ? context.textTheme.bodyMedium?.mr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )
                                : context.textTheme.bodyMedium?.rr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        optionVariant.value = "size";
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        width: (1.sw - 48) / 3,
                        decoration: BoxDecoration(
                            border: _option == "size"
                                ? Border.all(color: Color(0xff402CDD))
                                : null,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text("${LocaleKeys.change_size.tr()}",
                            textAlign: TextAlign.center,
                            style: _option == "size"
                                ? context.textTheme.bodyMedium?.mr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )
                                : context.textTheme.bodyMedium?.rr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        optionVariant.value = "qty";
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: (1.sw - 48) / 3,
                        decoration: BoxDecoration(
                            border: _option == "qty"
                                ? Border.all(color: Color(0xff402CDD))
                                : null,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text("${LocaleKeys.change_qty.tr()}",
                            textAlign: TextAlign.center,
                            style: _option == "qty"
                                ? context.textTheme.bodyMedium?.mr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )
                                : context.textTheme.bodyMedium?.rr.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14,
                                    height: 1.3,
                                  )),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: MyCachedNetworkImage(
                      withInnerShadow: true,
                      withImageShadow: true,
                      radius: 15,
                      imageUrl:
                          widget.order.details?[indexTap.value].image ?? "",
                      imageFit: BoxFit.fill,
                      width: 70,
                      height: 70,
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Text(
                  "${LocaleKeys.change_from.tr()} ${(_option == "color") ? "Denim Blue" : (_option == "size") ? "Medium" : "${LocaleKeys.qty.tr()} 1"}",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3,
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 1.sw,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 0.5,
                decoration: BoxDecoration(
                    color: Color(0xffC4C2C2),
                    border: Border.all(color: Color(0xffC4C2C2)),
                    borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
              SizedBox(
                height: 10,
              ),
              (_option == "color")
                  ? Text("${LocaleKeys.to_new_color.tr()} ?",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1.3,
                      ))
                  : (_option == "size")
                      ? Text("${LocaleKeys.to_new_size.tr()} ?",
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 14,
                            height: 1.3,
                          ))
                      : SizedBox.shrink(),
              SizedBox(
                height: 15,
              ),
              (_option == "color")
                  ? ValueListenableBuilder<int?>(
                      valueListenable: colorIndexTap,
                      builder: (context, _colorIndexTap, _) {
                        return Container(
                          width: 1.sw,
                          height: 100,
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: InkWell(
                                onTap: () {
                                  if (_colorIndexTap == index) {
                                    colorIndexTap.value = null;
                                    return;
                                  }
                                  colorIndexTap.value = index;
                                },
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              border: _colorIndexTap == index
                                                  ? Border.all(
                                                      color: Color(0xff402CDD))
                                                  : null,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40))),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(40)),
                                            child: MyCachedNetworkImage(
                                              withInnerShadow: true,
                                              withImageShadow: true,
                                              radius: 40,
                                              imageUrl: widget
                                                      .order
                                                      .details?[indexTap.value]
                                                      .image ??
                                                  "",
                                              imageFit: BoxFit.fill,
                                              width: 70,
                                              height: 70,
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("White",
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: _colorIndexTap == index
                                              ? Color(0xff402CDD)
                                              : const Color(0xff5D5C5D),
                                          letterSpacing: 0.18,
                                          fontSize: 14,
                                          height: 1.3,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                  : (_option == "size")
                      ? ValueListenableBuilder<int?>(
                          valueListenable: sizeIndexTap,
                          builder: (context, _sizeIndexTap, _) {
                            return Container(
                              width: 1.sw,
                              height: 100,
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: InkWell(
                                          onTap: () {
                                            if (_sizeIndexTap == index) {
                                              sizeIndexTap.value = null;
                                              return;
                                            }
                                            sizeIndexTap.value = index;
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                      border: _sizeIndexTap ==
                                                              index
                                                          ? Border.all(
                                                              color: Color(
                                                                  0xff402CDD))
                                                          : null,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  40))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                40)),
                                                    child: MyCachedNetworkImage(
                                                      withInnerShadow: true,
                                                      withImageShadow: true,
                                                      radius: 40,
                                                      imageUrl: widget
                                                              .order
                                                              .details?[indexTap
                                                                  .value]
                                                              .image ??
                                                          "",
                                                      imageFit: BoxFit.fill,
                                                      width: 70,
                                                      height: 70,
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text("XXL",
                                                  style: context
                                                      .textTheme.bodyMedium?.rr
                                                      .copyWith(
                                                    color:
                                                        _sizeIndexTap == index
                                                            ? Color(0xff402CDD)
                                                            : const Color(
                                                                0xff5D5C5D),
                                                    letterSpacing: 0.18,
                                                    fontSize: 14,
                                                    height: 1.3,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      )),
                            );
                          })
                      : SizedBox.shrink(),
            ],
          );
        });
  }

  Widget panelReturnedContent(ScrollController sc) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
              width: 104,
              height: 140.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.white,
                  child: MyCachedNetworkImage(
                    withInnerShadow: true,
                    withImageShadow: true,
                    radius: 15,
                    imageUrl: widget.order.details?[indexTap.value].image ?? "",
                    imageFit: BoxFit.contain,
                    width: 100,
                    height: 140,
                  ),
                ),
              )),
          SizedBox(
            height: 8.h,
          ),
          SvgPicture.asset(
            AppAssets.returnWihoutPhotoSvg,
          ),
          SizedBox(
            height: 14.h,
          ),
          Text("${LocaleKeys.return_this_product.tr()}",
              style: context.textTheme.bodyMedium?.mr.copyWith(
                color: const Color(0xff402CDD),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3,
              )),
          SizedBox(
            height: 8.h,
          ),
          Text("${LocaleKeys.you_can_return_product_without_conditions.tr()}",
              maxLines: 1,
              style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${LocaleKeys.return_policy_get_full_refund.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
              Text(" 140",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.br.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
              Text(" USD ${LocaleKeys.to_your_account.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            width: 1.sw,
            height: 0.5,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Color(0xffC4C2C2),
                border: Border.all(color: Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
          SizedBox(
            height: 30.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${LocaleKeys.why_was_product_return.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  )),
              Text(" ${LocaleKeys.learn_more_tips.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff402CDD),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  )),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_didnt_like.tr(), 90, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_didnt_like.tr())) {
                        options.remove(LocaleKeys.i_didnt_like.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_didnt_like.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(LocaleKeys.bad_quality.tr(), 90,
                        () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.bad_quality.tr())) {
                        options.remove(LocaleKeys.bad_quality.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.bad_quality.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.it_arrived_damaged.tr(), 130, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.it_arrived_damaged.tr())) {
                        options.remove(LocaleKeys.it_arrived_damaged.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.it_arrived_damaged.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_received_different_product.tr(), 190, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_received_different_product.tr())) {
                        options.remove(
                            LocaleKeys.i_received_different_product.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_received_different_product.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.different_color.tr(), 90, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.different_color.tr())) {
                        options.remove(LocaleKeys.different_color.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.different_color.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.differen_sizes.tr(), 90, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.differen_sizes.tr())) {
                        options.remove(LocaleKeys.differen_sizes.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.differen_sizes.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.completely_different.tr(), 120, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.completely_different.tr())) {
                        options.remove(LocaleKeys.completely_different.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.completely_different.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                  ],
                ),
                SizedBox(
                  height: 24.h,
                ),
                Container(
                  width: 1.sw,
                  height: 0.5,
                  decoration: BoxDecoration(
                      color: Color(0xffC4C2C2),
                      border: Border.all(color: Color(0xffC4C2C2)),
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                ),
                SizedBox(
                  height: 12.h,
                ),
                ValueListenableBuilder<List<File?>?>(
                    valueListenable: orderPhotos,
                    builder: (context, _orderPhotos, _) {
                      return SizedBox(
                        height: 198.h,
                        width: 1.sw,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 1.sw,
                              height: 80,
                              decoration: BoxDecoration(
                                  color: Color(0xffF8F8F8),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.r)),
                                  border: (_orderPhotos?.length ?? 0) > 0
                                      ? null
                                      : Border.all(color: Color(0xff402CDD))),
                              child: (_orderPhotos?.length ?? 0) > 0
                                  ? Stack(
                                      children: [
                                        ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: orderPhotos.value.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                width: 57,
                                                height: 80,
                                                margin: EdgeInsets.only(
                                                    right: LanguageService
                                                                .languageCode ==
                                                            "ar"
                                                        ? 0
                                                        : 5,
                                                    left: LanguageService
                                                                .languageCode !=
                                                            "ar"
                                                        ? 0
                                                        : 5),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(12),
                                                  ),
                                                  child: Image.file(
                                                    _orderPhotos![index]!,
                                                    width: 57,
                                                    height: 80,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ));
                                          },
                                        ),
                                        Positioned(
                                          right: LanguageService.languageCode ==
                                                  "ar"
                                              ? null
                                              : 20,
                                          left: LanguageService.languageCode !=
                                                  "ar"
                                              ? null
                                              : 20,
                                          top: 30,
                                          child: InkWell(
                                            onTap: () async {
                                              AssetEntity? assetEntity;
                                              assetEntity =
                                                  await HelperFunctions
                                                      .getAssetFromGallery(
                                                          context);
                                              if (assetEntity != null) {
                                                if (assetEntity.type ==
                                                    AssetType.video) {
                                                  showMessage('only photo',
                                                      showInRelease: true);
                                                } else {
                                                  File? file = await assetEntity
                                                      .originFile;
                                                  if (file != null) {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    CopperImage(
                                                                      fromOrder:
                                                                          true,
                                                                      orderPhotos:
                                                                          orderPhotos,
                                                                      image:
                                                                          file,
                                                                      visiblecamera:
                                                                          visiblecamera,
                                                                    )));
                                                  }
                                                }
                                              }
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.addPhotoSvg,
                                                  color: Color(0xff402CDD),
                                                  width: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        AssetEntity? assetEntity;
                                        assetEntity = await HelperFunctions
                                            .getAssetFromGallery(context);
                                        if (assetEntity != null) {
                                          if (assetEntity.type ==
                                              AssetType.video) {
                                            showMessage('only photo',
                                                showInRelease: true);
                                          } else {
                                            File? file =
                                                await assetEntity.originFile;
                                            if (file != null) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CopperImage(
                                                            fromOrder: true,
                                                            orderPhotos:
                                                                orderPhotos,
                                                            image: file,
                                                            visiblecamera:
                                                                visiblecamera,
                                                          )));
                                            }
                                          }
                                        }
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.addPhotoSvg,
                                            color: Color(0xff402CDD),
                                            width: 20,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text("${LocaleKeys.add_photo.tr()}",
                                              textAlign: TextAlign.center,
                                              style: context
                                                  .textTheme.bodyMedium?.rr
                                                  .copyWith(
                                                color: Color(0xff402CDD),
                                                letterSpacing: 0.18,
                                                fontSize: 10,
                                                height: 1.3,
                                              )),
                                        ],
                                      ),
                                    ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            (_orderPhotos?.length ?? 0) > 0
                                ? SizedBox.shrink()
                                : Text(
                                    "${LocaleKeys.please_add_photos_of_product_received.tr()}",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium?.rr
                                        .copyWith(
                                      color: Color(0xff402CDD),
                                      letterSpacing: 0.18,
                                      fontSize: 10,
                                      height: 1.3,
                                    )),
                          ],
                        ),
                      );
                    }),
                SizedBox(
                  height: 22.h,
                ),
                ValueListenableBuilder<List<String>>(
                    valueListenable: optionCanselOrReturn,
                    builder: (context, _optionCansel, _) {
                      return ValueListenableBuilder<List<File?>?>(
                          valueListenable: orderPhotos,
                          builder: (context, _orderPhotos, _) {
                            return InkWell(
                              onTap: () {
                                if ((_orderPhotos?.length ?? 0) > 0 &&
                                    (_optionCansel.length > 0)) {
                                  showShadowForCanselOrder.value = true;
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 1.sw,
                                height: 53,
                                decoration: BoxDecoration(
                                    color: (_orderPhotos?.length ?? 0) > 0 &&
                                            (_optionCansel.length > 0)
                                        ? Color(0xff402CDD)
                                        : Color(0xffD3D3D3),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Text("${LocaleKeys.return_request.tr()}",
                                    maxLines: 1,
                                    style: context.textTheme.bodyMedium?.mr
                                        .copyWith(
                                      color: Colors.white,
                                      letterSpacing: 0.18,
                                      fontSize: 16,
                                      height: 1.3,
                                    )),
                              ),
                            );
                          });
                    }),
                SizedBox(
                  height: 10.h,
                )
              ],
            ),
          ),
        ]);
  }

  Widget canselContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_changed_mind.tr(), 130, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_changed_mind.tr())) {
                        options.remove(LocaleKeys.i_changed_mind.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_changed_mind.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_fear_quality.tr(), 100, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_fear_quality.tr())) {
                        options.remove(LocaleKeys.i_fear_quality.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_fear_quality.tr());

                      optionCanselOrReturn.value = [...options];
                    })
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_fear_delivery_time.tr(), 160, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_fear_delivery_time.tr())) {
                        options.remove(LocaleKeys.i_fear_delivery_time.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_fear_delivery_time.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                    SizedBox(
                      width: 10,
                    ),
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_am_afraid_sizes.tr(), 125, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_am_afraid_sizes.tr())) {
                        options.remove(LocaleKeys.i_am_afraid_sizes.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_am_afraid_sizes.tr());

                      optionCanselOrReturn.value = [...options];
                    })
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    optionOfCanselOrReturnOrder(
                        LocaleKeys.i_saw_better_price.tr(), 135, () {
                      List<String> options = optionCanselOrReturn.value;
                      if (optionCanselOrReturn.value
                          .contains(LocaleKeys.i_saw_better_price.tr())) {
                        options.remove(LocaleKeys.i_saw_better_price.tr());

                        optionCanselOrReturn.value = [...options];

                        return;
                      }
                      options.add(LocaleKeys.i_saw_better_price.tr());

                      optionCanselOrReturn.value = [...options];
                    }),
                  ],
                ),
              ],
            ),
            Spacer(),
            Container(
                width: 1.sw,
                alignment: Alignment.center,
                height: 53,
                decoration: BoxDecoration(
                    color: const Color(0xff388CFF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  LocaleKeys.we_have_other_solutions_instead_cancellation.tr(),
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            ValueListenableBuilder<List<String>?>(
                valueListenable: optionCanselOrReturn,
                builder: (context, _optionCanselOrReturn, _) {
                  return InkWell(
                    onTap: () {
                      if ((_optionCanselOrReturn?.length ?? 0) > 0) {
                        showShadowForCanselOrder.value = true;
                      }
                    },
                    child: Container(
                        width: 1.sw,
                        alignment: Alignment.center,
                        height: 53,
                        decoration: BoxDecoration(
                            color: (_optionCanselOrReturn?.length ?? 0) > 0
                                ? const Color(0xffFF5F61)
                                : const Color(0xffD3D3D3),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          LocaleKeys.cancel_request.tr(),
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        )),
                  );
                }),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget optionOfCanselOrReturnOrder(
      String text, double width, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: ValueListenableBuilder<List<String>>(
          valueListenable: optionCanselOrReturn,
          builder: (context, _optionCansel, _) {
            return Container(
                alignment: Alignment.center,
                height: 40,
                width: width,
                decoration: BoxDecoration(
                    border: !_optionCansel.contains(text)
                        ? null
                        : Border.all(color: Color(0xff402CDD)),
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  text,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff5D5C5D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ));
          }),
    );
  }

  Widget optionOfModify(
      {required String svg,
      required String image2,
      required String tiltle,
      required String body,
      required Function onTap}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 1.sw,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xffF8F8F8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 12.w,
            ),
            svg == ""
                ? SizedBox(
                    width: 22.w,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        svg,
                        width: 30,
                      ),
                      image2 == ""
                          ? SizedBox.shrink()
                          : image2.split(".").last != "svg"
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  child: MyCachedNetworkImage(
                                    radius: 15,
                                    imageUrl: image2,
                                    imageFit: BoxFit.fill,
                                    width: 15,
                                    height: 15,
                                  ),
                                )
                              : SvgPicture.asset(
                                  image2,
                                  width: 10,
                                  color: const Color(0xff402CDD),
                                ),
                    ],
                  ),
            SizedBox(
              width: 15.w,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tiltle,
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  body,
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
