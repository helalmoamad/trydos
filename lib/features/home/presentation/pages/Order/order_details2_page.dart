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
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';

class OrderDetails2 extends StatefulWidget {
  OrderDetails2(
      {super.key,
      required this.order,
      this.orderIdFormNotification,
      this.fromNotification = false,
      required this.orderIdToChat});
  final String? orderIdFormNotification;
  final bool fromNotification;
  final OrderListModel order;
  final List<String> orderIdToChat;
  @override
  State<OrderDetails2> createState() => _OrderDetails2();
}

class _OrderDetails2 extends State<OrderDetails2> {
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeColor = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForCanselOrder = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeSize = ValueNotifier(false);
  final ValueNotifier<bool> enableChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> variantHasBeenChanged = ValueNotifier(false);
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  final ValueNotifier<int> colorIndexTap = ValueNotifier(0);
  final ValueNotifier<int> sizeIndexTap = ValueNotifier(0);
  final ValueNotifier<int> productIndexTap = ValueNotifier(0);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ValueNotifier<String?> optionCansel = ValueNotifier(null);
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  late OrderBloc orderBloc;
  final PanelController panelController = PanelController();
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  @override
  void initState() {
    sizeIndexTap.value = 3;
    orderBloc = BlocProvider.of<OrderBloc>(context);
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
            optionCansel.value = null;
            enableChangeAddress.value = false;
            showShadowForPanel.value = false;
            showShadowForChangeAddress.value = false;
            showShadowForCanselOrder.value = false;
            showShadowForChangeColor.value = false;
            showShadowForChangeSize.value = false;
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
                                            Text(
                                              LocaleKeys.order_status.tr(),
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
                                    return Container(
                                      height: 170,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Container(
                                              color: Colors.white,
                                              child: MyCachedNetworkImage(
                                                imageUrl: widget
                                                        .order
                                                        .details?[index]
                                                        .image ??
                                                    '',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: Stack(
                                                alignment:
                                                    AlignmentDirectional.topEnd,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                        widget
                                                                .order
                                                                .details?[index]
                                                                .productDetails
                                                                ?.name ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: context.textTheme
                                                            .bodyMedium?.rq
                                                            .copyWith(
                                                          color: const Color(
                                                              0xff505050),
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
                                                      Row(
                                                        children: [
                                                          RichText(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            text: TextSpan(
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff8D8D8D),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 10,
                                                                height: 1.3,
                                                              ),
                                                              children: [
                                                                widget
                                                                            .order
                                                                            .details?[
                                                                                index]
                                                                            .variation
                                                                            ?.color ==
                                                                        ""
                                                                    ? TextSpan(
                                                                        text:
                                                                            "")
                                                                    : TextSpan(
                                                                        text:
                                                                            '${LocaleKeys.color.tr()} : ',
                                                                      ),
                                                                ////////////////////////////
                                                                TextSpan(
                                                                  text: widget
                                                                              .order
                                                                              .details?[
                                                                                  index]
                                                                              .variation ==
                                                                          null
                                                                      ? ''
                                                                      : widget
                                                                              .order
                                                                              .details?[index]
                                                                              .variation
                                                                              ?.color ??
                                                                          '',
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mq
                                                                      .copyWith(
                                                                    color: const Color(
                                                                        0xff505050),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10,
                                                                    height: 1.3,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          ///////////////////
                                                          SizedBox(
                                                            width: widget
                                                                        .order
                                                                        .details?[
                                                                            index]
                                                                        .variation
                                                                        ?.color ==
                                                                    ""
                                                                ? 0
                                                                : 12,
                                                          ),
                                                          ///////////////////
                                                          Flexible(
                                                            fit: FlexFit.loose,
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              text: TextSpan(
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.rq
                                                                    .copyWith(
                                                                  color: const Color(
                                                                      0xff8D8D8D),
                                                                  letterSpacing:
                                                                      0.18,
                                                                  fontSize: 10,
                                                                  height: 1.3,
                                                                ),
                                                                children: [
                                                                  widget.order.details?[index].variation?.size ==
                                                                          ""
                                                                      ? TextSpan(
                                                                          text:
                                                                              "")
                                                                      : TextSpan(
                                                                          text:
                                                                              '${LocaleKeys.size.tr()} : ',
                                                                        ),
                                                                  ////////////////////////////
                                                                  TextSpan(
                                                                    text: widget.order.details?[index].variation ==
                                                                            null
                                                                        ? ''
                                                                        : widget.order.details?[index].variation?.size ??
                                                                            '',
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.mq
                                                                        .copyWith(
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          10,
                                                                      height:
                                                                          1.3,
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
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            text: TextSpan(
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff8D8D8D),
                                                                letterSpacing:
                                                                    0.18,
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
                                                                      '${widget.order.details?[index].productDetails?.countOfPieces} ${LocaleKeys.piece.tr()}',
                                                                  style: context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mq
                                                                      .copyWith(
                                                                    color: const Color(
                                                                        0xff505050),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10,
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
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              text: TextSpan(
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.rq
                                                                    .copyWith(
                                                                  color: const Color(
                                                                      0xff8D8D8D),
                                                                  letterSpacing:
                                                                      0.18,
                                                                  fontSize: 10,
                                                                  height: 1.3,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${LocaleKeys.item.tr()}: ',
                                                                  ),
                                                                  ////////////////////////////
                                                                  TextSpan(
                                                                    text: widget
                                                                        .order
                                                                        .details?[
                                                                            index]
                                                                        .qty
                                                                        .toString(),
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.mq
                                                                        .copyWith(
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          10,
                                                                      height:
                                                                          1.3,
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
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              text: TextSpan(
                                                                style: context
                                                                    .textTheme
                                                                    .bodyMedium
                                                                    ?.rq
                                                                    .copyWith(
                                                                  color: const Color(
                                                                      0xff8D8D8D),
                                                                  letterSpacing:
                                                                      0.18,
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
                                                                    text: widget
                                                                            .order
                                                                            .details?[
                                                                                index]
                                                                            .orderProductStatus
                                                                            ?.label ??
                                                                        widget
                                                                            .order
                                                                            .orderStatus
                                                                            ?.label ??
                                                                        "",
                                                                    style: context
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.mq
                                                                        .copyWith(
                                                                      color: const Color(
                                                                          0xff505050),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          10,
                                                                      height:
                                                                          1.3,
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
                                                            AppAssets
                                                                .orderPreparingSvg,
                                                            width: 15,
                                                          ),
                                                        ],
                                                      ),
                                                      ////////////////////
                                                      const Spacer(),
                                                      ////////////////////
                                                      RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rq
                                                              .copyWith(
                                                            color: const Color(
                                                                0xffC4C2C2),
                                                            letterSpacing: 0.18,
                                                            fontSize: 12,
                                                            height: 1.3,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${((widget.order.details?[index].productDetails?.price ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xffC4C2C2),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 12,
                                                                height: 1.3,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              ),
                                                            ),
                                                            ////////////////////////////
                                                            TextSpan(
                                                              text:
                                                                  ' ${((widget.order.details?[index].productDetails?.offerPrice ?? 0) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)).toStringAsFixed(GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 0)}',
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.bq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff1D1D1D),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 12,
                                                                height: 1.3,
                                                              ),
                                                            ),
                                                            /////////////
                                                            TextSpan(
                                                              text:
                                                                  ' ${(GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.symbol!)}',
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.lq
                                                                  .copyWith(
                                                                color: const Color(
                                                                    0xff1D1D1D),
                                                                letterSpacing:
                                                                    0.18,
                                                                fontSize: 12,
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
                                                    child: BlocBuilder<
                                                        OrderBloc, OrderState>(
                                                      buildWhen: (previous,
                                                              current) =>
                                                          previous.getCustomerAddressStatus != current.getCustomerAddressStatus ||
                                                          previous.editAddressToOrderStatus !=
                                                              current
                                                                  .editAddressToOrderStatus ||
                                                          previous.setCustomerAddressDefaultStatus !=
                                                              current
                                                                  .setCustomerAddressDefaultStatus ||
                                                          previous.addAddressToOrderStatus !=
                                                              current
                                                                  .addAddressToOrderStatus ||
                                                          previous.removeAddressToOrderStatus !=
                                                              current
                                                                  .removeAddressToOrderStatus,
                                                      builder:
                                                          (context, state) {
                                                        return InkWell(
                                                          onTap: () {
                                                            showPanel.value =
                                                                true;
                                                            panelController
                                                                .open();
                                                            showShadowForPanel
                                                                .value = true;
                                                            indexTap
                                                                .value = state
                                                                    .currentAddressChoosed ??
                                                                0;
                                                          },
                                                          child: Container(
                                                            width: 40,
                                                            height: 20,
                                                            child: SvgPicture
                                                                .asset(
                                                              AppAssets
                                                                  .orderMenuSvg,
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
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
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForChangeAddressContent(_indexTap);
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForChangeColor(_indexTap);
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForChangeSize(_indexTap);
                  }),
              ValueListenableBuilder<int>(
                  valueListenable: indexTap,
                  builder: (context, _indexTap, _) {
                    return shadowForCanselOrder(_indexTap);
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFirstSection(BuildContext context, String itemsCount) {
    int tapIndex = 0;
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
                      TextSpan(text: ' ${LocaleKeys.item.tr()}'),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              width: 30 *
                  (double.tryParse((widget.orderIdToChat.length).toString()) ??
                      0),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => BlocListener<ChatBloc,
                        ChatState>(
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
                        chat = chats.firstWhere(
                            (element) => element.channelMembers!.any((element) {
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
                                GetOrderRecipientIdStatus.loading &&
                            index == tapIndex) {
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
                              tapIndex = index;
                              GetIt.I<ChatBloc>().add(GetOrderRecipientIdEvent(
                                  originalUserId: GetIt.I<PrefsRepository>()
                                      .myMarketId
                                      .toString(),
                                  orderId: widget.orderIdToChat[index]));
                            },
                            child: SvgPicture.asset(
                              AppAssets.chatMarkActiveSvg,
                              width: 20,
                            ),
                          ),
                        );
                      },
                    )),
                itemCount: widget.orderIdToChat.length,
              ),
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

  Widget shadowForChangeSize(int tapIndex) {
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
                                    imageUrl:
                                        "https://res.cloudinary.com/dtcmozf4d/image/upload/f_auto,q_auto,c_scale,h_250/v1/product/2025-05-12-6821ca777ace0.png",
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
  }

  Widget shadowForCanselOrder(int tapIndex) {
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForCanselOrder,
        builder: (context, _showShadowForCanselOrder, _) {
          colorIndexTap.value = (2) ~/ 2;
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
                        LocaleKeys.about_cancel_order.tr(),
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
                          optionCansel.value = null;
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
                            optionCansel.value = null;
                            showShadowForChangeColor.value = false;
                            showShadowForChangeSize.value = false;
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

  Widget shadowForChangeColor(int tapIndex) {
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
                                    imageUrl:
                                        "https://res.cloudinary.com/dtcmozf4d/image/upload/f_auto,q_auto,c_scale,h_250/v1/product/2025-05-12-6821ca777ace0.png",
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
                                            imageUrl:
                                                "https://res.cloudinary.com/dtcmozf4d/image/upload/f_auto,q_auto,c_scale,h_250/v1/product/2025-05-12-6821ca777ace0.png",
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
  }

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
                            AppAssets.orderChangeAddressSvg,
                            width: 50,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 10,
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
                            height: 10,
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
                            height: 10,
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
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
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
                            height: 10,
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: agreeToPolicies,
                              builder: (context, _agreeToPolicies, _) {
                                return Container(
                                    alignment: Alignment.center,
                                    height: 40,
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
                            height: 45,
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
                            height: 30,
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
                              optionCansel.value = null;
                              showShadowForPanel.value = false;
                              showShadowForChangeAddress.value = false;
                              showShadowForChangeColor.value = false;
                              showShadowForChangeSize.value = false;
                            },
                            child: ValueListenableBuilder<bool>(
                                valueListenable: agreeToPolicies,
                                builder: (context, _agreeToPolicies, _) {
                                  return Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 24),
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
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      LocaleKeys.yes_agree.tr(),
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
                            height: 20,
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
                                optionCansel.value = null;
                                enableChangeAddress.value = false;
                                showShadowForPanel.value = false;
                                showShadowForChangeAddress.value = false;
                                showShadowForChangeColor.value = false;
                                showShadowForCanselOrder.value = false;
                                showShadowForChangeSize.value = false;
                              },
                              child: Text(
                                LocaleKeys.cansel.tr(),
                                textAlign: TextAlign.center,
                                style:
                                    context.textTheme.bodyMedium?.rr.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.18,
                                  fontSize: 16,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                          ? (_option == null ? 371 : (1.sh - 85))
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
                          agreeToPolicies.value = false;
                          variantHasBeenChanged.value = false;
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForChangeAddress.value = false;
                          showShadowForChangeColor.value = false;
                          showShadowForCanselOrder.value = false;
                          showShadowForChangeSize.value = false;
                        },
                        onPanelOpened: () {},
                        minHeight: 0,
                        maxHeight: _option == null ? 371 : (1.sh - 85),
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
          valueListenable: indexTap,
          builder: (context, _indexTap, _) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 23,
                    height: 18,
                    child: SvgPicture.asset(
                      AppAssets.orderChangeAddressSvg,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    LocaleKeys.change_delivery_address.tr(),
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
                    LocaleKeys
                        .you_can_easily_change_shipping_addres_delivery_notes
                        .tr(),
                    style: context.textTheme.bodyMedium?.rr.copyWith(
                      color: const Color(0xff8D8D8D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
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
                              margin: EdgeInsets.all(24),
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
                                "${LocaleKeys.change_close.tr()} ",
                                style: context.textTheme.bodyMedium?.mr
                                    .copyWith(
                                        color: const Color(0xffFFFFFF),
                                        letterSpacing: 0.18,
                                        fontSize: 16,
                                        height: 1.33),
                              )),
                        );
                      })
                ]);
          },
        );
      },
    );
  }

  Widget panelVariantContent(ScrollController sc) {
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

  Widget productWidget(int index) {
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
  }

  Widget addressWidgets(
    BuildContext context,
    OrderState state,
    int _indexTap,
    ScrollController sc,
  ) {
    return Container(
        width: 1.sw,
        height: 525.h + 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 25.h,
              width: 145.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppAssets.deliveryAddressSvg,
                      width: 18,
                      height: 18,
                      color: Color(0xff1D1D1D),
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    "${LocaleKeys.your_address_list.tr()} ",
                    style: context.textTheme.bodyMedium?.rr.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1.33),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 500.h,
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
                          indexTap.value = index;
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
    if (_option == "address") {
      return panelAddressContent(sc);
    }
    if (_option == "variant") {
      return panelVariantContent(sc);
    }
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.r),
                topRight: Radius.circular(30.r))),
        height: _option == null ? 400 : (1.sh - 85.h),
        width: 1.sw,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 23,
                  height: 18,
                  child: SvgPicture.asset(
                    AppAssets.bagsSvg,
                    width: 23,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  LocaleKeys.manage_your_order.tr(),
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                optionOfModify(
                  onTap: () {
                    optionModifyPanel.value = "address";
                  },
                  svg: AppAssets.orderChangeAddressSvg,
                  svg2: "",
                  text: LocaleKeys.change_delivery_address.tr(),
                ),
                SizedBox(
                  height: 5,
                ),
                optionOfModify(
                  onTap: () {
                    optionModifyPanel.value = "variant";
                  },
                  svg2: AppAssets.bagsOrderSvg,
                  svg: AppAssets.modifyOrderSvg,
                  text: LocaleKeys.modify_order.tr(),
                ),
                SizedBox(
                  height: 5,
                ),
                optionOfModify(
                  onTap: () {
                    optionModifyPanel.value = null;
                  },
                  svg2: "",
                  svg: "",
                  text:
                      LocaleKeys.information_about_order_modify_or_cancel.tr(),
                ),
                SizedBox(
                  height: optionModifyPanel.value == "cansel" ? 20 : 35,
                ),
                InkWell(
                  onTap: () {
                    optionModifyPanel.value = "cansel";
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 1.sw,
                      height: 55,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffFF5F61)),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffF8F8F8),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.cancel_order.tr(),
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                color: const Color(0xffFF5F61),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              LocaleKeys.you_can_cancel_back_money.tr(),
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                color: const Color(0xffFF5F61),
                                letterSpacing: 0.18,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ])),
                ),
                ValueListenableBuilder<String?>(
                    valueListenable: optionModifyPanel,
                    builder: (context, _optionModifyPanel, _) {
                      return _optionModifyPanel == null
                          ? SizedBox.shrink()
                          : canselContent();
                    })
              ]),
        ));
  }

  Widget canselContent() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            width: 1.sw,
            height: 20,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.why_was_order_cancelled.tr(),
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                Text(
                  "  ${LocaleKeys.learn_more_tips.tr()}",
                  style: context.textTheme.bodyMedium?.mr.copyWith(
                    color: const Color(0xff402CDD),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  optionOfCanselOrder(LocaleKeys.i_changed_mind.tr(), 130, () {
                    if (optionCansel.value == LocaleKeys.i_changed_mind.tr()) {
                      optionCansel.value = null;
                      return;
                    }
                    optionCansel.value = LocaleKeys.i_changed_mind.tr();
                  }),
                  SizedBox(
                    width: 10,
                  ),
                  optionOfCanselOrder(LocaleKeys.i_fear_quality.tr(), 100, () {
                    if (optionCansel.value == LocaleKeys.i_fear_quality.tr()) {
                      optionCansel.value = null;
                      return;
                    }
                    optionCansel.value = LocaleKeys.i_fear_quality.tr();
                  })
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  optionOfCanselOrder(LocaleKeys.i_fear_delivery_time.tr(), 160,
                      () {
                    if (optionCansel.value ==
                        LocaleKeys.i_fear_delivery_time.tr()) {
                      optionCansel.value = null;
                      return;
                    }
                    optionCansel.value = LocaleKeys.i_fear_delivery_time.tr();
                  }),
                  SizedBox(
                    width: 10,
                  ),
                  optionOfCanselOrder(LocaleKeys.i_am_afraid_sizes.tr(), 125,
                      () {
                    if (optionCansel.value ==
                        LocaleKeys.i_am_afraid_sizes.tr()) {
                      optionCansel.value = null;
                      return;
                    }
                    optionCansel.value = LocaleKeys.i_am_afraid_sizes.tr();
                  })
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  optionOfCanselOrder(LocaleKeys.i_saw_better_price.tr(), 135,
                      () {
                    if (optionCansel.value ==
                        LocaleKeys.i_saw_better_price.tr()) {
                      optionCansel.value = null;
                      return;
                    }
                    optionCansel.value = LocaleKeys.i_saw_better_price.tr();
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
          ValueListenableBuilder<String?>(
              valueListenable: optionCansel,
              builder: (context, _optionCansel, _) {
                return InkWell(
                  onTap: () {
                    if (_optionCansel != null) {
                      showShadowForCanselOrder.value = true;
                    }
                  },
                  child: Container(
                      width: 1.sw,
                      alignment: Alignment.center,
                      height: 53,
                      decoration: BoxDecoration(
                          color: _optionCansel != null
                              ? const Color(0xffFF5F61)
                              : const Color(0xffD3D3D3),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        LocaleKeys.cancel_my_order.tr(),
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
    );
  }

  Widget optionOfCanselOrder(
      String text, double width, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: ValueListenableBuilder<String?>(
          valueListenable: optionCansel,
          builder: (context, _optionCansel, _) {
            return Container(
                alignment: Alignment.center,
                height: 40,
                width: width,
                decoration: BoxDecoration(
                    border: _optionCansel != text
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
      required String svg2,
      required String text,
      required Function onTap}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 1.sw,
        height: 50,
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
                      ),
                      svg2 == ""
                          ? SizedBox.shrink()
                          : SvgPicture.asset(
                              svg2,
                              width: 10,
                              color: const Color(0xff402CDD),
                            ),
                    ],
                  ),
            Spacer(),
            Text(
              text,
              style: context.textTheme.bodyMedium?.rr.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            SizedBox(
              width: 30.w,
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
