import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart'
    show PanelController, SlidingUpPanel;
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/authentication/presentation/widgets/guest_phone_verification_dialog.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart'
    show CallsBloc, CallsState, MakeCallStatus;
import 'package:trydos/features/calls/presentation/pages/in_app_view.dart'
    show AgoraInAppWebView;
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/data/models/get_order_rating_model.dart'
    show Comment;
import 'package:trydos/features/home/domain/use_cases/cancel_order_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_order_address_usecase.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart'
    show
        ChangeOrderByGroupStatus,
        GetOrdersEvent,
        CancelOrderEvent,
        GetOrdersByOrderGroupIDEvent,
        GetCustomerAddressesEvent,
        ChangeOrderAddressEvent,
        FetchOrderReturnDetailsEvent,
        HideOrderEvent,
        ResetAllStatusEvent;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/pages/Order/order_status.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/star_rating_widget.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
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
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/helper/dev_log.dart';

class OrderDetails1 extends StatefulWidget {
  const OrderDetails1({
    super.key,
    this.fromNotification = false,
    this.currentStatus = "",
    this.orderIdToOpenPackage = "",
    this.indexGroupe = -1,
    this.orderIdFormNotification,
    this.parentOrderIdFormNotification,
    required this.orders,
  });

  final List<OrderListModel> orders;
  final bool fromNotification;
  final String? orderIdFormNotification;
  final String? parentOrderIdFormNotification;

  final String orderIdToOpenPackage;
  final String? currentStatus;
  final int indexGroupe;
  @override
  State<OrderDetails1> createState() => _OrderDetails1State();
}

class _OrderDetails1State extends State<OrderDetails1> {
  List<String?> addressParts = [];

  late ChatBloc chatBloc;
  late OrderBloc orderBloc;

  late HomeBloc homeBloc;
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> enableChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeAddress = ValueNotifier(false);
  final PanelController panelController = PanelController();
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForCanselOrder = ValueNotifier(false);
  final ValueNotifier<int> indexTapAddress = ValueNotifier(0);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<int> indexTapPackage = ValueNotifier(0);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ScrollController singleChildController = ScrollController();
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final ValueNotifier<List<String>> optionCanselOrReturn = ValueNotifier([]);
  List<OrderListModel> orders = [];
  int firstAddressChoosed = 0;
  bool firstOpenPage = true;
  bool requestReturnApiFromNotification = false;
  bool requestReturnApi = false;
  bool canFetchReturnDetails = false;
  bool fromNotification = false;

  /// Set to true right before hiding a pack so the next order-group re-fetch
  /// knows to run the post-hide navigation (stay / back to Orders page).
  bool _pendingHide = false;
  @override
  void initState() {
    LastPagesTracker.push("OrderDetails1 Page");
    fromNotification = widget.fromNotification;
    orders = widget.orders;
    /* widget.orders.forEach(
      (element) {
        List<OrderListDetailModel> details = [];
        element.details?.forEach((elements) {
          for (var i = 0; i < (elements.qty ?? 0); i++) {
            details.add(elements.copyWith(qty: 1));
          }
        });
        orders.add(element.copyWith(details: details));
      },
    );*/
    if (fromNotification &&
        widget.orderIdFormNotification != null &&
        widget.orderIdFormNotification != "") {
      if (kDebugMode)
        devLog(
          "FDDDDDDDDDDDDDDDDDDDDDDDddddd${widget.parentOrderIdFormNotification}  //${widget.orderIdFormNotification}",
        );
      requestReturnApiFromNotification = true;
      indexTapPackage.value = orders.indexWhere(
        (element) =>
            element.id.toString() ==
            ((widget.parentOrderIdFormNotification == null ||
                    widget.parentOrderIdFormNotification == "" ||
                    widget.parentOrderIdFormNotification == "-1")
                ? (widget.orderIdFormNotification)
                : widget.parentOrderIdFormNotification),
      );

      GetIt.I<ChatBloc>().add(
        GetOrderRecipientIdEvent(
          originalUserId: GetIt.I<PrefsRepository>().myMarketId.toString(),
          parentOrderId:
              (widget.parentOrderIdFormNotification == "" ||
                  widget.parentOrderIdFormNotification == "-1")
              ? null
              : widget.parentOrderIdFormNotification,
          orderId: widget.orderIdFormNotification!,
        ),
      );
    } else if (widget.orderIdToOpenPackage != "") {
      indexTapPackage.value = orders.indexWhere(
        (element) => element.id.toString() == widget.orderIdToOpenPackage,
      );
    }
    homeBloc = BlocProvider.of<HomeBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    if (!fromNotification) {
      Future.delayed(const Duration(seconds: 5), () {
        orderBloc.add(
          GetOrdersByOrderGroupIDEvent(
            orderGroupId: orders[indexTapPackage.value].orderGroupId ?? "",
            firstOpenPage: true,
          ),
        );
      });
    }
    orders.forEach((element) {
      if (element.returnRequestId != null) {
        canFetchReturnDetails = true;
      }
    });
    if (canFetchReturnDetails && !fromNotification) {
      orderBloc.add(
        FetchOrderReturnDetailsEvent(
          orders[indexTapPackage.value].orderGroupId ?? "",
        ),
      );
    } else {
      orderBloc.add(
        FetchOrderReturnDetailsEvent(
          orders[indexTapPackage.value].orderGroupId ?? "",
          notFound: true,
        ),
      );
    }

    indexTapAddress.value =
        orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
          (element) =>
              element.id ==
              orders[indexTapPackage.value].shippingAddressData?.id,
        ) ??
        -1;

    firstAddressChoosed = indexTapAddress.value;

    if (orders[indexTapPackage.value].orderStatus?.value == 'delivered') {
      homeBloc.add(
        GetOrderRatingEvent(
          orderDetailIds: (orders[indexTapPackage.value].details!
              .map((e) => e.id!)
              .toList()),
          userId: GetIt.I<PrefsRepository>().myMarketId,
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshData() async {
      fromNotification = false;
      if (canFetchReturnDetails) {
        orderBloc.add(
          FetchOrderReturnDetailsEvent(
            orders[indexTapPackage.value].orderGroupId ?? "",
          ),
        );
      } else {
        orderBloc.add(
          FetchOrderReturnDetailsEvent(
            orders[indexTapPackage.value].orderGroupId ?? "",
            notFound: true,
          ),
        );
      }

      orderBloc.add(
        GetOrdersByOrderGroupIDEvent(
          orderGroupId: widget.orders[0].orderGroupId ?? "",
        ),
      );

      // 🚀 إزالة التأخير المصطنع - دع البيانات تحدد سرعة التحميل!
      await Future.delayed(
        const Duration(seconds: 3),
      ); // ❌ تم حذف التأخير المصطنع
    }

    return
    // ignore: deprecated_member_use
    WillPopScope(
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

            return false;
          }
        } catch (e) {
          return true;
        }
        return true;
      },
      child: BlocListener<OrderBloc, OrderState>(
        listenWhen: (p, c) =>
            p.getOrdersByOrderGroupIDStatus != c.getOrdersByOrderGroupIDStatus,
        listener: (context, state) {
          devLog("GGGGGGGGGGGGGGGGGG/*/*/");
          if (state.getOrdersByOrderGroupIDStatus ==
              GetOrdersByOrderGroupIDStatus.success) {
            final List<OrderListModel> groupOrders =
                state.getOrdersByOrderGroupIDModel?.orders ?? [];

            // Post-hide navigation — only the page that initiated the hide
            // (its own _pendingHide is set) navigates, so OrderDetails1 and
            // OrderDetails2 never both pop on the same re-fetch.
            devLog("GGGGGGGGGGGGGGGGGG/*/*/${groupOrders}");
            if (_pendingHide) {
              devLog("GGGGGGGGGGGGGGGGGG/*/*//////${groupOrders}");
              _pendingHide = false;
              if (groupOrders.isEmpty) {
                devLog("GGGGGGGGGGGGGGGGGG/*/*/*****${groupOrders}");
                // Group fully hidden -> back to the Orders page. The main
                // list is refreshed by the bloc after the hide.
                if (Navigator.of(context).canPop()) {
                  devLog("GGGGGGGGGGGGGGGGGG/*/*----/${groupOrders}");
                  Navigator.of(context).pop();
                }
                return;
              }
              // Packs remain: refresh this page's local pack list and keep a
              // valid selection. Main list refreshed by the bloc, so we do
              // NOT re-inject here.
              orders = groupOrders;
              if (indexTapPackage.value >= orders.length) {
                indexTapPackage.value = 0;
              }
              return;
            }

            if (groupOrders.isNotEmpty &&
                orders.isNotEmpty &&
                orders.first.orderGroupId == groupOrders.first.orderGroupId) {
              orders = groupOrders;
              if (indexTapPackage.value >= orders.length) {
                indexTapPackage.value = 0;
              }
              orders.forEach((element) {
                if (element.returnRequestId != null) {
                  canFetchReturnDetails = true;
                }
              });
            }
            // Only refresh this group in place when it still has packs.
            // If the group became empty (its last pack was hidden), do NOT
            // re-inject the stale pack list — that would re-add the group to
            // the main Orders list after it was removed. The empty-group
            // navigation/refresh is handled above (or by the page that
            // initiated the hide).
            if (!firstOpenPage &&
                orders.isNotEmpty &&
                indexTapPackage.value < orders.length) {
              indexTapAddress.value =
                  orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
                    (element) =>
                        element.id ==
                        orders[indexTapPackage.value].shippingAddressData?.id,
                  ) ??
                  -1;
              firstAddressChoosed = indexTapAddress.value;
              orderBloc.add(
                GetOrdersEvent(
                  status: widget.currentStatus ?? '',
                  orders: orders,
                  index: widget.indexGroupe,
                  getWithPagination: false,
                ),
              );
            }
          }
          if (state.getOrdersByOrderGroupIDStatus !=
                  GetOrdersByOrderGroupIDStatus.loading &&
              state.getOrdersByOrderGroupIDStatus !=
                  GetOrdersByOrderGroupIDStatus.init) {
            firstOpenPage = false;
          }
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          buildWhen: (p, c) =>
              p.getOrdersByOrderGroupIDStatus !=
                  c.getOrdersByOrderGroupIDStatus ||
              p.hideOrderVisibilityStatus != c.hideOrderVisibilityStatus,
          builder: (context, state) {
            return ValueListenableBuilder<int>(
              valueListenable: indexTapPackage,
              builder: (context, _indexTapPackage, _) {
                // Defensive: while a group is being emptied (its last pack
                // hidden) the page is about to pop; avoid a RangeError if a
                // rebuild happens on a transiently empty/short pack list.
                if (orders.isEmpty || _indexTapPackage >= orders.length) {
                  return const ColoredBox(color: Color(0xffFFFFFF));
                }
                addressParts = [
                  orders[_indexTapPackage].shippingAddressData?.country,
                  orders[_indexTapPackage].shippingAddressData?.province,
                  orders[_indexTapPackage].shippingAddressData?.city,
                  orders[_indexTapPackage].shippingAddressData?.town,
                  orders[_indexTapPackage].shippingAddressData?.street,
                  orders[_indexTapPackage].shippingAddressData?.building,
                ];
                devLog(addressParts);
                final addressString = addressParts
                    .where(
                      (part) =>
                          part != null && part != 'null' && part.isNotEmpty,
                    )
                    .join(' | ');

                return Container(
                  color: const Color(0xffFFFFFF),
                  child: Material(
                    child: Stack(
                      children: [
                        Scaffold(
                          resizeToAvoidBottomInset: true,
                          backgroundColor: const Color(0xffF8F8F8),
                          appBar: TrydosAppBar(
                            appBarParams: AppBarParams(
                              backgroundColor: const Color(0xffFFFFFF),
                              scrolledUnderElevation: 0,
                              backIconColor: Colors.black,
                              withShadow: false,
                              action: [
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 12.w),
                                    SvgPicture.asset(
                                      AppAssets.bagsSvg,
                                      width: 23.w,
                                    ),
                                    ///////////////////////////
                                    SizedBox(width: 4.w),
                                    ///////////////////////////
                                    Text(
                                      LocaleKeys.order_details.tr(),
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                            color: const Color(0xff1D1D1D),
                                            letterSpacing: 0.18,
                                            fontSize: 14.sp,
                                            height: 1.3,
                                          ),
                                    ),
                                    ///////////////////////////
                                    SizedBox(width: 15.w),
                                    ///////////////////////////
                                  ],
                                ),
                                const Spacer(),
                                ////////////
                                InkWell(
                                  onTap: () {
                                    if (state.getOrdersByOrderGroupIDStatus ==
                                        GetOrdersByOrderGroupIDStatus.loading) {
                                      return;
                                    }
                                    optionModifyPanel.value = "All_Order";
                                    showPanel.value = true;
                                    panelController.open();
                                    showShadowForPanel.value = true;
                                  },
                                  child: Container(
                                    width: 40.w,
                                    height: 20.h,
                                    child:
                                        state.getOrdersByOrderGroupIDStatus ==
                                                GetOrdersByOrderGroupIDStatus
                                                    .loading ||
                                            state.hideOrderVisibilityStatus ==
                                                HideOrderVisibilityStatus
                                                    .loading
                                        ? TrydosLoader(size: 16)
                                        : SvgPicture.asset(
                                            AppAssets.orderMenuSvg,
                                            width: 20.w,
                                          ),
                                  ),
                                ),
                                ///////////////////////////
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),
                          body: RefreshIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            onRefresh: _refreshData,
                            child: SingleChildScrollView(
                              controller: singleChildController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: 11.h),
                                  ///////////////////
                                  BlocBuilder<HomeBloc, HomeState>(
                                    buildWhen: (previous, current) =>
                                        (previous.getCurrencyForCountryModel !=
                                        current.getCurrencyForCountryModel),
                                    builder: (context, state) {
                                      String currencySymbol =
                                          state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .symbol ??
                                          "";
                                      double orderAmount = 0;
                                      orders.forEach(
                                        (element) => orderAmount =
                                            orderAmount +
                                            (HelperFunctions.truncateToDecimalPlaces(
                                                  element.orderAmount!,
                                                  state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .decimalDigits!,
                                                ) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!),
                                      );

                                      return SizedBox(
                                        height: 95.h,
                                        child: buildFirstSection(
                                          context: context,
                                          orderNumber:
                                              orders[_indexTapPackage]
                                                  .orderGroupId ??
                                              '',
                                          orderDate:
                                              HelperFunctions.orderFormatDate(
                                                DateTime.tryParse(
                                                      orders[_indexTapPackage]
                                                              .createdAt ??
                                                          '',
                                                    ) ??
                                                    DateTime.now(),
                                              ),
                                          orderAmount:
                                              HelperFunctions.formatNumber(
                                                numberToFormate: orderAmount,
                                                isNeedRounding: false,
                                              ),
                                          orderCurrency: currencySymbol,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8.h),
                                  ///////////////////////
                                  SizedBox(
                                    height: 85.h,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                      ),
                                      child:
                                          state.getOrdersByOrderGroupIDStatus ==
                                                  GetOrdersByOrderGroupIDStatus
                                                      .loading ||
                                              state.hideOrderVisibilityStatus ==
                                                  HideOrderVisibilityStatus
                                                      .loading
                                          ? TrydosLoader(size: 16)
                                          : buildDetailsMainInfoWidget(
                                              context: context,
                                              firstItem: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  orders[_indexTapPackage]
                                                              .orderGroupStatus
                                                              ?.value ==
                                                          'canceled'
                                                      ? SvgPicture.asset(
                                                          AppAssets
                                                              .orderCanselSvg,
                                                          width: 20.w,
                                                        )
                                                      : SvgPicture.asset(
                                                          AppAssets
                                                              .pendingBagSvg,
                                                          width: 15.w,
                                                        ),
                                                  ////////////////////
                                                  SizedBox(width: 3.w),

                                                  ///////////////////
                                                  orders[_indexTapPackage]
                                                              .orderGroupStatus
                                                              ?.value ==
                                                          'canceled'
                                                      ? const SizedBox.shrink()
                                                      : orders[_indexTapPackage]
                                                                .orderGroupStatus
                                                                ?.value ==
                                                            'pending'
                                                      ? SvgPicture.asset(
                                                          AppAssets.whiteBagSvg,
                                                          width: 15.w,
                                                        )
                                                      : SvgPicture.asset(
                                                          AppAssets
                                                              .preparingBagSvg,
                                                          width: 15.w,
                                                        ),
                                                  ////////////////////
                                                  SizedBox(width: 3.w),
                                                  ///////////////////
                                                  orders[_indexTapPackage]
                                                              .orderGroupStatus
                                                              ?.value ==
                                                          'canceled'
                                                      ? const SizedBox.shrink()
                                                      : ((orders[_indexTapPackage]
                                                                    .orderGroupStatus
                                                                    ?.value ==
                                                                'pending') ||
                                                            (orders[_indexTapPackage]
                                                                    .orderGroupStatus
                                                                    ?.value ==
                                                                'preparing'))
                                                      ? SvgPicture.asset(
                                                          AppAssets.whiteBagSvg,
                                                          width: 15.w,
                                                        )
                                                      : SvgPicture.asset(
                                                          AppAssets
                                                              .shippedAndOutOfDeliveryBagSvg,
                                                          width: 15.w,
                                                        ),
                                                  ////////////////////
                                                  SizedBox(width: 3.w),
                                                  ///////////////////
                                                  orders[_indexTapPackage]
                                                              .orderGroupStatus
                                                              ?.value ==
                                                          'canceled'
                                                      ? const SizedBox.shrink()
                                                      : ((orders[_indexTapPackage]
                                                                    .orderGroupStatus
                                                                    ?.value ==
                                                                'pending') ||
                                                            (orders[_indexTapPackage]
                                                                    .orderGroupStatus
                                                                    ?.value ==
                                                                'preparing') ||
                                                            (orders[_indexTapPackage]
                                                                    .orderGroupStatus
                                                                    ?.value ==
                                                                'shipped'))
                                                      ? SvgPicture.asset(
                                                          AppAssets.whiteBagSvg,
                                                          width: 15.w,
                                                        )
                                                      : SvgPicture.asset(
                                                          AppAssets
                                                              .delivered_bagSvg,
                                                          width: 15.w,
                                                        ),
                                                ],
                                              ),
                                              title: LocaleKeys.order_status
                                                  .tr(),
                                              value:
                                                  orders[_indexTapPackage]
                                                          .orderGroupStatus
                                                          ?.value ==
                                                      'delivered'
                                                  ? '${orders[_indexTapPackage].orderGroupStatus?.label} ${LocaleKeys.to.tr()} ${orders[_indexTapPackage].shippingAddressData?.contactPersonName ?? ''}'
                                                  : orders[_indexTapPackage]
                                                            .orderGroupStatus
                                                            ?.label ??
                                                        "",
                                              amount: '',
                                              isTextSpan: false,
                                              titleIcons: buildTitleIcons(
                                                status:
                                                    orders[_indexTapPackage]
                                                        .orderGroupStatus
                                                        ?.value ??
                                                    "",
                                              ),
                                              valueIcons: buildValueIcons(
                                                status:
                                                    orders[_indexTapPackage]
                                                        .orderGroupStatus
                                                        ?.value ??
                                                    "",
                                              ),
                                              currency: '',
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF4F4F4),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15.r),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ...List.generate(
                                          orders.length,
                                          (index) => InkWell(
                                            onTap: () {
                                              indexTapPackage.value = index;
                                              if (orders[index]
                                                      .orderStatus
                                                      ?.value ==
                                                  'delivered') {
                                                homeBloc.add(
                                                  GetOrderRatingEvent(
                                                    orderDetailIds:
                                                        (orders[index].details!
                                                            .map((e) => e.id!)
                                                            .toList()),
                                                    userId:
                                                        GetIt.I<
                                                              PrefsRepository
                                                            >()
                                                            .myMarketId,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 30.h,
                                              width:
                                                  (1.sw - 40) / (orders.length),
                                              decoration: BoxDecoration(
                                                border:
                                                    index != _indexTapPackage
                                                    ? null
                                                    : Border.all(
                                                        color: const Color(
                                                          0xff402CDD,
                                                        ),
                                                      ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(15.r),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "${LocaleKeys.pack.tr()} ${orders[index].id}",
                                                style: index != _indexTapPackage
                                                    ? context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff5D5C5D,
                                                            ),
                                                            letterSpacing: 0.18,
                                                            fontSize: 12.sp,
                                                            height: 1.3,
                                                          )
                                                    : context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.mq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff1D1D1D,
                                                            ),
                                                            letterSpacing: 0.18,
                                                            fontSize: 12.sp,
                                                            height: 1.3,
                                                          ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  ///////////////////
                                  SizedBox(
                                    height: 85.h,
                                    child:
                                        state.getOrdersByOrderGroupIDStatus ==
                                                GetOrdersByOrderGroupIDStatus
                                                    .loading ||
                                            state.hideOrderVisibilityStatus ==
                                                HideOrderVisibilityStatus
                                                    .loading
                                        ? TrydosLoader(size: 16)
                                        : buildSecondSection(
                                            context: context,
                                            expectedDeliveryDate:
                                                'Monday 2.Jun | 3 ${LocaleKeys.work_days.tr()}',
                                            orderStatus:
                                                orders[_indexTapPackage]
                                                    .orderStatus
                                                    ?.value ??
                                                '',
                                            orderStatusLable:
                                                orders[_indexTapPackage]
                                                    .orderStatus
                                                    ?.label ??
                                                '',
                                            deliverdTo:
                                                orders[_indexTapPackage]
                                                    .shippingAddressData
                                                    ?.contactPersonName ??
                                                '',
                                          ),
                                  ),
                                  ///////////////////
                                  SizedBox(height: 8.h),
                                  ///////////////////
                                  orders[_indexTapPackage].orderStatus?.value ==
                                          "delivered"
                                      ? buildThirdSectionForRating()
                                      : buildThirdSection(
                                          context: context,
                                          contactInfo:
                                              orders[_indexTapPackage]
                                                  .shippingAddressData
                                                  ?.phone ??
                                              '',
                                          recipientName:
                                              orders[_indexTapPackage]
                                                  .shippingAddressData
                                                  ?.contactPersonName ??
                                              '',
                                          shippingDeliveryAddress:
                                              addressString,
                                        ),
                                  ///////////////////
                                  SizedBox(height: 8.h),
                                  ///////////////////
                                  BlocListener<OrderBloc, OrderState>(
                                    listenWhen: (previous, current) =>
                                        previous.orderReturnDetailsStatus !=
                                        current.orderReturnDetailsStatus,
                                    listener: (context, state) {
                                      if (state.orderReturnDetailsStatus ==
                                              OrderReturnDetailsStatus
                                                  .success &&
                                          requestReturnApi) {
                                        requestReturnApi = false;
                                        HelperFunctions.slidingNavigation(
                                          context,
                                          OrderDetails2(
                                            indexGroupe: widget.indexGroupe,
                                            indexPackage: _indexTapPackage,
                                            order: orders[_indexTapPackage],
                                          ),
                                        );
                                      }
                                    },
                                    child: BlocBuilder<OrderBloc, OrderState>(
                                      buildWhen: (previous, current) =>
                                          previous.orderReturnDetailsStatus !=
                                          current.orderReturnDetailsStatus,
                                      builder: (context, state) {
                                        ReturnRequestsDatum? orderReturnDetail;

                                        if (state.orderReturnDetailsModel !=
                                            null) {
                                          if (state
                                                  .orderReturnDetailsModel!
                                                  .data
                                                  ?.returnRequestsData !=
                                              null) {
                                            orderReturnDetail = state
                                                .orderReturnDetailsModel!
                                                .data!
                                                .returnRequestsData!
                                                .firstWhere(
                                                  (element) =>
                                                      element.orderId ==
                                                      orders[_indexTapPackage]
                                                          .id,
                                                  orElse: () =>
                                                      ReturnRequestsDatum(),
                                                );
                                          }
                                        }
                                        return GestureDetector(
                                          onTapUp: (details) {
                                            final double dx =
                                                details.localPosition.dx;
                                            devLog(dx);

                                            if ((dx > (1.sw - 75) &&
                                                (orders[_indexTapPackage]
                                                            .orderStatus
                                                            ?.value ==
                                                        "out_for_delivery" ||
                                                    (orderReturnDetail != null
                                                        ? orderReturnDetail
                                                                  .status
                                                                  ?.value ==
                                                              "out_for_return"
                                                        : false)))) {
                                              return;
                                            }
                                            if (state
                                                    .orderReturnDetailsStatus ==
                                                OrderReturnDetailsStatus
                                                    .success) {
                                              HelperFunctions.slidingNavigation(
                                                context,
                                                OrderDetails2(
                                                  indexGroupe:
                                                      widget.indexGroupe,
                                                  indexPackage:
                                                      _indexTapPackage,
                                                  order:
                                                      orders[_indexTapPackage],
                                                ),
                                              );
                                              return;
                                            }
                                            if (orders[_indexTapPackage]
                                                    .orderHasReturnRequest ??
                                                false) {
                                              requestReturnApi = true;
                                              if (canFetchReturnDetails) {
                                                orderBloc.add(
                                                  FetchOrderReturnDetailsEvent(
                                                    orders[_indexTapPackage]
                                                            .orderGroupId ??
                                                        "",
                                                  ),
                                                );
                                              }
                                              return;
                                            } else {
                                              requestReturnApi = false;
                                            }
                                            HelperFunctions.slidingNavigation(
                                              context,
                                              OrderDetails2(
                                                indexGroupe: widget.indexGroupe,
                                                indexPackage: _indexTapPackage,
                                                order: orders[_indexTapPackage],
                                              ),
                                            );
                                          },
                                          child: buildFourthSection(
                                            context: context,
                                            itemsCount: orders[_indexTapPackage]
                                                .details!
                                                .length
                                                .toString(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ///////////////////
                                  SizedBox(height: 8.h),
                                  ///////////////////
                                  buildFifthSection(
                                    details: orders[_indexTapPackage].details,
                                    orderStatus:
                                        orders[_indexTapPackage]
                                            .orderStatus
                                            ?.value ??
                                        "",
                                    orderStatusLabel:
                                        orders[_indexTapPackage]
                                            .orderStatus
                                            ?.label ??
                                        "",
                                  ),
                                  ///////////////////
                                  SizedBox(height: 8.h),
                                  ///////////////////
                                ],
                              ),
                            ),
                          ),
                        ),
                        shadowForPanel(),
                        panelWidget(),
                        ValueListenableBuilder<int>(
                          valueListenable: indexTapAddress,
                          builder: (context, _indexTap, _) {
                            return shadowForChangeAddressContent(_indexTap);
                          },
                        ),
                        shadowForCanselOrRutuenOrder(false),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget shadowForCanselOrRutuenOrder(bool isReturn) {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForCanselOrder,
      builder: (context, _showShadowForCanselOrder, _) {
        return !_showShadowForCanselOrder
            ? const SizedBox.shrink()
            : Container(
                height: 1.sh,
                width: 1.sw,
                color: const Color.fromRGBO(29, 29, 29, 0.95),
                child: Column(
                  children: [
                    const Spacer(),
                    SvgPicture.asset(AppAssets.clarificationSvg),
                    SizedBox(height: 20.h),
                    Text(
                      LocaleKeys.clarification.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 40.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      isReturn
                          ? LocaleKeys.about_return_your_product.tr()
                          : LocaleKeys.about_cancel_order.tr(),
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 45.h),
                    Text(
                      LocaleKeys.you_will_not_charged_fees.tr(),
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    orders[indexTapPackage.value].paymentStatus == "unpaid"
                        ? const SizedBox.shrink()
                        : Text(
                            "${LocaleKeys.you_will_receive_your_refund_within.tr()} 12 ${LocaleKeys.hours.tr()}",
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16.sp,
                              height: 1.3,
                            ),
                          ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        "${LocaleKeys.repeated_cancellations_affect_rating.tr()} \n ",
                        textAlign: TextAlign.start,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.18,
                          fontSize: 16.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 160.h),
                    SvgPicture.asset(AppAssets.termsCanselSvg),
                    SizedBox(height: 10.h),
                    Text(
                      "${LocaleKeys.terms_of_cancellation_term.tr()} ",
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 14.sp,
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
                            onTap: () =>
                                agreeToPolicies.value = !_agreeToPolicies,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.detectedSvg,
                                  // ignore: deprecated_member_use
                                  color: _agreeToPolicies
                                      ? const Color(0xff388CFF)
                                      : const Color(0xff8E8E8E),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: Colors.white,
                                        letterSpacing: 0.18,
                                        fontSize: 14.sp,
                                        height: 1.3,
                                      ),
                                ),
                                Text(
                                  LocaleKeys.cancellation_term.tr(),
                                  style: context.textTheme.bodyMedium?.mq
                                      .copyWith(
                                        decorationColor: Colors.white,
                                        decoration: TextDecoration.underline,
                                        color: Colors.white,
                                        letterSpacing: 0.18,
                                        fontSize: 16.sp,
                                        height: 1.3,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: agreeToPolicies,
                      builder: (context, _agreeToPolicies, _) {
                        return BlocListener<OrderBloc, OrderState>(
                          listenWhen: (previous, current) =>
                              previous.cancelOrderStatus !=
                              current.cancelOrderStatus,
                          listener: (context, state) {
                            if (state.cancelOrderStatus ==
                                CancelOrderStatus.success) {
                              orderBloc.add(
                                GetOrdersByOrderGroupIDEvent(
                                  orderGroupId:
                                      orders[indexTapPackage.value]
                                          .orderGroupId ??
                                      "",
                                ),
                              );
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              enableChangeAddress.value = false;
                              showShadowForPanel.value = false;
                              showShadowForCanselOrder.value = false;
                              optionCanselOrReturn.value = [];
                              showShadowForChangeAddress.value = false;
                            }
                          },
                          child: BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.cancelOrderStatus !=
                                current.cancelOrderStatus,
                            builder: (context, state) {
                              return state.cancelOrderStatus ==
                                      CancelOrderStatus.loading
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[500]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: agreeToPolicies.value == true
                                              ? const Color(0xff3066CC)
                                              : const Color(0xffC4C2C2),
                                          border: agreeToPolicies.value == true
                                              ? Border.all(
                                                  color: const Color(
                                                    0xffF8F8F8,
                                                  ),
                                                )
                                              : Border.all(
                                                  color: const Color(
                                                    0xffC4C2C2,
                                                  ),
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        if (agreeToPolicies.value == false) {
                                          return;
                                        }
                                        orderBloc.add(
                                          CancelOrderEvent(
                                            cancelOrderParams:
                                                CancelOrderParams(
                                                  orderId:
                                                      orders[indexTapPackage
                                                              .value]
                                                          .id
                                                          .toString(),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: agreeToPolicies.value == true
                                              ? const Color(0xff3066CC)
                                              : const Color(0xffC4C2C2),
                                          border: agreeToPolicies.value == true
                                              ? Border.all(
                                                  color: const Color(
                                                    0xffF8F8F8,
                                                  ),
                                                )
                                              : Border.all(
                                                  color: const Color(
                                                    0xffC4C2C2,
                                                  ),
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          LocaleKeys.i_agree_cancel.tr(),
                                          textAlign: TextAlign.center,
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.bq
                                              .copyWith(
                                                color: Colors.white,
                                                letterSpacing: 0.18,
                                                fontSize: 16.sp,
                                                height: 1.3,
                                              ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 200.w,
                      height: 40.h,
                      child: BlocBuilder<OrderBloc, OrderState>(
                        buildWhen: (previous, current) =>
                            previous.cancelOrderStatus !=
                            current.cancelOrderStatus,
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              if (state.cancelOrderStatus ==
                                  CancelOrderStatus.loading) {
                                return;
                              }
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              enableChangeAddress.value = false;
                              showShadowForPanel.value = false;
                              showShadowForChangeAddress.value = false;
                              showShadowForCanselOrder.value = false;
                              optionCanselOrReturn.value = [];
                            },
                            child: Text(
                              LocaleKeys.i_disagree.tr(),
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: Colors.white,
                                decorationColor: Colors.white,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.18,
                                fontSize: 16.sp,
                                height: 1.3,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              );
      },
    );
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
                ? const SizedBox.shrink()
                : Container(
                    height: 1.sh,
                    width: 1.sw,
                    color: const Color.fromRGBO(29, 29, 29, 0.95),
                    child: Column(
                      children: [
                        const Spacer(),
                        SvgPicture.asset(AppAssets.clarificationSvg),
                        SizedBox(height: 20.h),
                        Text(
                          LocaleKeys.clarification.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 40.h,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LocaleKeys.about_change_request_address.tr(),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 16.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        SvgPicture.asset(
                          AppAssets.orderChangeAddressSvg,
                          width: 50.w,
                          // ignore: deprecated_member_use
                          color: Colors.white,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LocaleKeys.change_below_address.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xffD3D3D3),
                            letterSpacing: 0.18,
                            fontSize: 16.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: addressInfoWithContactInfoCart(
                            isChange: true,
                            customerAddressesInfo: CustomerAddressesInfo(
                              address:
                                  orders[indexTapPackage.value]
                                      .shippingAddressData
                                      ?.address ??
                                  '',
                              addressDetail:
                                  orders[indexTapPackage.value]
                                      .shippingAddressData
                                      ?.addressDetail ??
                                  '',
                              contactInfo: ContactInfo(
                                alternativePhone:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.alternativePhone ??
                                    '',
                                name:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.contactPersonName ??
                                    '',
                                phone:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.phone ??
                                    '',
                              ),
                              id: orders[indexTapPackage.value]
                                  .shippingAddressData
                                  ?.id,
                              regionDetails: RegionDetails(
                                building:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.building ??
                                    '',
                                city:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.city ??
                                    '',
                                country:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.country ??
                                    '',
                                province:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.province ??
                                    '',
                                street:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.street ??
                                    '',
                                town:
                                    orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.town ??
                                    '',
                              ),
                            ),
                            context: context,
                            index: 0,
                            indexTap: 1,
                            onTapDelete: () {},
                            onTapEdit: () {
                              /*    //     panelController.close();
                                HelperFunctions.slidingNavigation(
                                  context,
                                  AddShippingAdress(
                                    addressInfoClassToEdid:
                                        state.listOfAddressInfoClassToSave![
                                            state.currentAddressChoosed ?? 0],
                                    fromEdid: true,
                                  ),
                                );*/
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          LocaleKeys.to_new_address.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 16.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                                  addressInfoClassToEdid: state
                                      .listOfAddressInfoClassToSave![tapIndex],
                                  fromEdid: true,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          LocaleKeys
                              .we_will_ignore_first_address_send_order_new_address
                              .tr(),
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        SvgPicture.asset(AppAssets.termsCanselSvg),
                        SizedBox(height: 10.h),
                        Text(
                          "${LocaleKeys.terms_of_change_address_terms.tr()} ",
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.18,
                            fontSize: 14.sp,
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
                                onTap: () =>
                                    agreeToPolicies.value = !_agreeToPolicies,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.detectedSvg,
                                      // ignore: deprecated_member_use
                                      color: _agreeToPolicies
                                          ? const Color(0xff388CFF)
                                          : const Color(0xff8E8E8E),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: Colors.white,
                                            letterSpacing: 0.18,
                                            fontSize: 14.sp,
                                            height: 1.3,
                                          ),
                                    ),
                                    Text(
                                      LocaleKeys.change_addres_terms.tr(),
                                      style: context.textTheme.bodyMedium?.mq
                                          .copyWith(
                                            decorationColor: Colors.white,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.white,
                                            letterSpacing: 0.18,
                                            fontSize: 16.sp,
                                            height: 1.3,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        BlocListener<OrderBloc, OrderState>(
                          listenWhen: (previous, current) =>
                              previous.changeOrderAddressStatus !=
                              current.changeOrderAddressStatus,
                          listener: (context, state) {
                            if (state.changeOrderAddressStatus ==
                                ChangeOrderAddressStatus.success) {
                              orderBloc.add(
                                GetOrdersByOrderGroupIDEvent(
                                  orderGroupId:
                                      orders[indexTapPackage.value]
                                          .orderGroupId ??
                                      "",
                                ),
                              );
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              showShadowForCanselOrder.value = false;
                              enableChangeAddress.value = false;
                              optionCanselOrReturn.value = [];
                              showShadowForPanel.value = false;
                              showShadowForChangeAddress.value = false;
                            }
                          },
                          child: BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.changeOrderAddressStatus !=
                                current.changeOrderAddressStatus,
                            builder: (context, state) {
                              return state.changeOrderAddressStatus ==
                                      ChangeOrderAddressStatus.loading
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[500]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: agreeToPolicies.value == true
                                              ? const Color(0xff3066CC)
                                              : const Color(0xffC4C2C2),
                                          border: agreeToPolicies.value == true
                                              ? Border.all(
                                                  color: const Color(
                                                    0xffF8F8F8,
                                                  ),
                                                )
                                              : Border.all(
                                                  color: const Color(
                                                    0xffC4C2C2,
                                                  ),
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        if (agreeToPolicies.value == false) {
                                          return;
                                        }
                                        orderBloc.add(
                                          ChangeOrderAddressEvent(
                                            changeOrderAddressParams:
                                                ChangeOrderAddressParams(
                                                  orderGroupId:
                                                      orders[indexTapPackage
                                                              .value]
                                                          .orderGroupId ??
                                                      "",
                                                  newShippingAddressId:
                                                      state
                                                          .listOfAddressInfoClassToSave?[indexTapAddress
                                                              .value]
                                                          .id
                                                          .toString() ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: agreeToPolicies,
                                        builder:
                                            (context, _agreeToPolicies, _) {
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 24.w,
                                                ),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      agreeToPolicies.value ==
                                                          true
                                                      ? Colors.white
                                                      : const Color(0xffC4C2C2),
                                                  border:
                                                      agreeToPolicies.value ==
                                                          false
                                                      ? null
                                                      : Border.all(
                                                          color: const Color(
                                                            0xff402CDD,
                                                          ),
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        15.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  LocaleKeys.i_agree_change
                                                      .tr(),
                                                  textAlign: TextAlign.center,
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        color:
                                                            agreeToPolicies
                                                                    .value ==
                                                                true
                                                            ? const Color(
                                                                0xff402CDD,
                                                              )
                                                            : Colors.white,
                                                        letterSpacing: 0.18,
                                                        fontSize: 16.sp,
                                                        height: 1.3,
                                                      ),
                                                ),
                                              );
                                            },
                                      ),
                                    );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: 200.w,
                          height: 40.h,
                          child: BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.changeOrderAddressStatus !=
                                current.changeOrderAddressStatus,
                            builder: (context, state) {
                              return InkWell(
                                onTap: () {
                                  if (state.changeOrderAddressStatus ==
                                      ChangeOrderAddressStatus.loading) {
                                    return;
                                  }
                                  agreeToPolicies.value = false;
                                  panelController.close();
                                  showPanel.value = false;
                                  optionModifyPanel.value = null;
                                  optionCanselOrReturn.value = [];
                                  enableChangeAddress.value = false;
                                  showShadowForPanel.value = false;
                                  showShadowForChangeAddress.value = false;

                                  showShadowForCanselOrder.value = false;
                                },
                                child: Text(
                                  LocaleKeys.i_disagree.tr(),
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.rq
                                      .copyWith(
                                        color: Colors.white,

                                        decorationColor: Colors.white,
                                        decoration: TextDecoration.underline,
                                        letterSpacing: 0.18,
                                        fontSize: 16.sp,
                                        height: 1.3,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  );
          },
        );
      },
    );
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
      height: 100.h,
      padding: EdgeInsets.only(
        right: LanguageService.languageCode == "ar" ? 20.w : 10.w,
        left: LanguageService.languageCode != "ar" ? 20.w : 10.w,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        color: isChange
            ? const Color.fromRGBO(0, 0, 0, 0)
            : const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15.r),
        border: isChange
            ? Border.all(
                color: (isChange && index != indexTap)
                    ? const Color(0xffD3D3D3)
                    : Colors.white,
              )
            : index != indexTap
            ? null
            : Border.all(color: const Color(0xff388CFF)),
      ),
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Container(
            width: 360.w,
            height: 16.h,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.homeInactiveSvg,
                  // ignore: deprecated_member_use
                  color: (isChange && index != indexTap)
                      ? const Color(0xffD3D3D3)
                      : (isChange && index == indexTap)
                      ? Colors.white
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  height: 12.h,
                  width: 12.w,
                ),
                SizedBox(width: 5.w),
                Text(
                  customerAddressesInfo.address ?? "",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: (isChange && index != indexTap)
                        ? const Color(0xffD3D3D3)
                        : isChange
                        ? const Color(0xffFFFFFF)
                        : index != indexTap
                        ? const Color(0xff8D8D8D)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                isChange
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: onTapEdit,
                        child: Container(
                          margin: EdgeInsets.only(top: 5.h),
                          width: 20.w,
                          height: 30.h,
                          child: SvgPicture.asset(
                            AppAssets.editSvg,
                            height: 30.h,
                            width: 20.w,
                          ),
                        ),
                      ),
                /*  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : SizedBox(
                          width: 10.w,
                        ),
                  isDelete || cartChoosed
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: onTapDelete,
                          child: Container(
                            margin: EdgeInsets.only(top: 5.h),
                            width: 20.w,
                            height: 30,
                            child: SvgPicture.asset(
                              AppAssets.deletecartSvg,
                              height: 14,
                              width: 14.w,
                            ),
                          ),
                        ),*/
              ],
            ),
          ),
          Container(
            width: 350.w,
            height: 16.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Text(
                  "${(customerAddressesInfo.regionDetails?.building.toString() == "null" || customerAddressesInfo.regionDetails?.building == "") ? "" : customerAddressesInfo.regionDetails?.building}${(customerAddressesInfo.regionDetails?.building.toString() != "null" && customerAddressesInfo.regionDetails?.building != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.street.toString() == "null" || customerAddressesInfo.regionDetails?.street == "" ? "" : customerAddressesInfo.regionDetails?.street}${(customerAddressesInfo.regionDetails?.street.toString() != "null" && customerAddressesInfo.regionDetails?.street != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.town.toString() == "null" || customerAddressesInfo.regionDetails?.town == "" ? "" : customerAddressesInfo.regionDetails?.town}${(customerAddressesInfo.regionDetails?.town.toString() != "null" && customerAddressesInfo.regionDetails?.town != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.city.toString() == "null" || customerAddressesInfo.regionDetails?.city == "" ? "" : customerAddressesInfo.regionDetails?.city}${(customerAddressesInfo.regionDetails?.city.toString() != "null" && customerAddressesInfo.regionDetails?.city != "") ? " | " : ""}${customerAddressesInfo.regionDetails?.province.toString() == "null" || customerAddressesInfo.regionDetails?.province == "" ? "" : customerAddressesInfo.regionDetails?.province} | ${customerAddressesInfo.regionDetails?.country ?? ''}",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: (isChange && index != indexTap)
                        ? const Color(0xffD3D3D3)
                        : isChange
                        ? const Color(0xffFFFFFF)
                        : index != indexTap
                        ? const Color(0xff8D8D8D)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 350.w,
            height: 16.h,
            child: Row(
              children: [
                Text(
                  "${customerAddressesInfo.addressDetail}",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: (isChange && index != indexTap)
                        ? const Color(0xffD3D3D3)
                        : isChange
                        ? const Color(0xffFFFFFF)
                        : index != indexTap
                        ? const Color(0xff8D8D8D)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 350.w,
            height: 16.h,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.phoneCallSvg,
                  // ignore: deprecated_member_use
                  color: (isChange && index != indexTap)
                      ? const Color(0xffD3D3D3)
                      : isChange
                      ? const Color(0xffFFFFFF)
                      : index != indexTap
                      ? const Color(0xff8D8D8D)
                      : const Color(0xff1D1D1D),
                  height: 12.h,
                  width: 12.w,
                ),
                SizedBox(width: 5.w),
                Text(
                  '+${(customerAddressesInfo.contactInfo?.phone ?? "").replaceAll("+", "")}',
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: (isChange && index != indexTap)
                        ? const Color(0xffD3D3D3)
                        : isChange
                        ? const Color(0xffFFFFFF)
                        : index != indexTap
                        ? const Color(0xff8D8D8D)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(width: 40.w),
                Container(
                  height: 16.h,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.personSvg,
                        // ignore: deprecated_member_use
                        color: (isChange && index != indexTap)
                            ? const Color(0xffD3D3D3)
                            : isChange
                            ? const Color(0xffFFFFFF)
                            : index != indexTap
                            ? const Color(0xff8D8D8D)
                            : const Color(0xff1D1D1D),
                        height: 12.h,
                        width: 12.w,
                      ),
                      SizedBox(width: 5.w),
                      SizedBox(
                        width: 130.w,
                        child: Text(
                          '${customerAddressesInfo.contactInfo?.name ?? ""}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: (isChange && index != indexTap)
                                ? const Color(0xffD3D3D3)
                                : isChange
                                ? const Color(0xffFFFFFF)
                                : index != indexTap
                                ? const Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
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
                          width: 12.w,
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
                        borderRadius: BorderRadius.circular(10.r)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${LocaleKeys.expected_delivery.tr()}',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 10.sp,
                              height: 1.3),
                        ),
                        Text(
                          ' ${HelperFunctions.getDateInFormatForShippingDays(int.tryParse(shippingDays ?? "0") ?? 0)}. ',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 10.sp,
                              height: 1.3),
                        ),
                        Text(
                          '${LocaleKeys.delivery_not.tr()}',
                          style: context.textTheme.bodyMedium?.rr.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xff388CFF),
                              color: const Color(0xff388CFF),
                              letterSpacing: 0.18,
                              fontSize: 10.sp,
                              height: 1.3),
                        ),
                      ],
                    ))*/
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
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
                    ? ((_option == null) ? 512 : (1.sh - 70.h))
                    : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SlidingUpPanel(
                  controller: panelController,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                  onPanelClosed: () {
                    agreeToPolicies.value = false;

                    showPanel.value = false;
                    optionModifyPanel.value = null;
                    enableChangeAddress.value = false;
                    showShadowForPanel.value = false;
                    optionCanselOrReturn.value = [];
                    showShadowForChangeAddress.value = false;

                    showShadowForCanselOrder.value = false;
                  },
                  onPanelOpened: () {},
                  minHeight: 0,
                  maxHeight: (_option == null) ? 512 : (1.sh - 70.h),
                  panelBuilder: (sc) => panelBuilderContent(_option, sc),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget panelBuilderContent(String? _option, ScrollController sc) {
    if (_option == "All_Order") {
      return optionsForAllOrder();
    }
    if (_option == "Change_Address") {
      if (orderBloc.state.getCustomerAddressStatus !=
          GetCustomerAddressesStatus.success) {
        orderBloc.add(GetCustomerAddressesEvent());
      }
      return panelAddressContent(sc);
    }
    if (_option == "Cancel_This_Order") {
      return panelCanelContent();
    }

    return const SizedBox.shrink();
  }

  Widget panelCanelContent() {
    return ValueListenableBuilder<int>(
      valueListenable: indexTapPackage,
      builder: (context, _indexTapPackage, _) {
        // Defensive: the pack list may have shrunk (a pack was hidden) while
        // this panel content rebuilds — render nothing instead of a RangeError.
        if (orders.isEmpty || _indexTapPackage >= orders.length) {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
              ),
            ),
            SizedBox(height: 15.h),
            Container(
              width: 1.sw,
              height: 205.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                border: Border.all(color: const Color(0xffF8F8F8)),
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    height: 16.h,
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        SvgPicture.asset(AppAssets.orderClockSvg, height: 15.h),
                        SizedBox(width: 5.w),
                        Text(
                          HelperFunctions.orderFormatDate(
                            DateTime.tryParse(
                                  orders[_indexTapPackage].createdAt ?? '',
                                ) ??
                                DateTime.now(),
                          ),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(AppAssets.orderBag1Svg, height: 15.h),
                        SizedBox(width: 5.w),
                        Text(
                          orders[_indexTapPackage].orderGroupId ?? "",
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    height: 16.h,
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        SvgPicture.asset(
                          AppAssets.preparingBagSvg,
                          height: 15.h,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          orders[_indexTapPackage].orderGroupStatus?.label ??
                              "",
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 11.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        SvgPicture.asset(
                          AppAssets.orderPreparingSvg,
                          height: 15.h,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppAssets.orderInvoice2Svg,
                          height: 15.h,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          (orders[_indexTapPackage].details?.length ?? "")
                              .toString(),
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          LocaleKeys.item.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          HelperFunctions.formatNumber(
                            numberToFormate:
                                (HelperFunctions.truncateToDecimalPlaces(
                                  orders[_indexTapPackage].orderAmount!,
                                  homeBloc
                                      .state
                                      .getCurrencyForCountryModel!
                                      .data!
                                      .currency!
                                      .decimalDigits!,
                                ) *
                                homeBloc
                                    .state
                                    .getCurrencyForCountryModel!
                                    .data!
                                    .currency!
                                    .exchangeRate!),
                            isNeedRounding: false,
                          ),
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          homeBloc
                              .state
                              .getCurrencyForCountryModel!
                              .data!
                              .currency!
                              .symbol!,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 125.h,
                    width: 1.sw,
                    padding: EdgeInsets.only(
                      left: LanguageService.languageCode == "ar" ? 0 : 10.w,
                      right: LanguageService.languageCode != "ar" ? 0 : 10.w,
                    ),
                    child: ListView.builder(
                      itemCount: orders[_indexTapPackage].details?.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 125.h,
                          width: 92.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl:
                                  orders[_indexTapPackage]
                                      .details?[index]
                                      .image ??
                                  "",
                              width: 92.w,
                              imageFit: BoxFit.contain,
                              height: 125.h,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            SvgPicture.asset(AppAssets.orderCanselSvg, width: 30.w),
            SizedBox(height: 14.h),
            Text(
              "${LocaleKeys.cancel_this_order.tr()}",
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "${LocaleKeys.you_can_cancel_product_without_condition.tr()}",
              maxLines: 1,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${LocaleKeys.cancel_policy_refund.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                Text(
                  "  ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((orders[_indexTapPackage].orderAmount ?? 0), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.0,
                  ),
                ),
                Text(
                  " ${homeBloc.state.getCurrencyForCountryModel!.data!.currency!.symbol} ${LocaleKeys.to_your_account.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              width: 1.sw,
              height: 0.5,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${LocaleKeys.why_was_order_cancelled.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                Text(
                  " ${LocaleKeys.learn_more_tips.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff402CDD),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            canselContent(),
          ],
        );
      },
    );
  }

  Widget canselContent() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Column(
              children: [
                Row(
                  children: [
                    optionOfCanselOrReturnOrder(
                      LocaleKeys.i_changed_mind.tr(),
                      130,
                      () {
                        List<String> options = optionCanselOrReturn.value;
                        if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_changed_mind.tr(),
                        )) {
                          options.remove(LocaleKeys.i_changed_mind.tr());

                          optionCanselOrReturn.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_changed_mind.tr());

                        optionCanselOrReturn.value = [...options];
                      },
                    ),
                    SizedBox(width: 10.w),
                    optionOfCanselOrReturnOrder(
                      LocaleKeys.i_fear_quality.tr(),
                      100,
                      () {
                        List<String> options = optionCanselOrReturn.value;
                        if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_fear_quality.tr(),
                        )) {
                          options.remove(LocaleKeys.i_fear_quality.tr());

                          optionCanselOrReturn.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_fear_quality.tr());

                        optionCanselOrReturn.value = [...options];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    optionOfCanselOrReturnOrder(
                      LocaleKeys.i_fear_delivery_time.tr(),
                      160,
                      () {
                        List<String> options = optionCanselOrReturn.value;
                        if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_fear_delivery_time.tr(),
                        )) {
                          options.remove(LocaleKeys.i_fear_delivery_time.tr());

                          optionCanselOrReturn.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_fear_delivery_time.tr());

                        optionCanselOrReturn.value = [...options];
                      },
                    ),
                    SizedBox(width: 10.w),
                    optionOfCanselOrReturnOrder(
                      LocaleKeys.i_am_afraid_sizes.tr(),
                      125,
                      () {
                        List<String> options = optionCanselOrReturn.value;
                        if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_am_afraid_sizes.tr(),
                        )) {
                          options.remove(LocaleKeys.i_am_afraid_sizes.tr());

                          optionCanselOrReturn.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_am_afraid_sizes.tr());

                        optionCanselOrReturn.value = [...options];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    optionOfCanselOrReturnOrder(
                      LocaleKeys.i_saw_better_price.tr(),
                      135,
                      () {
                        List<String> options = optionCanselOrReturn.value;
                        if (optionCanselOrReturn.value.contains(
                          LocaleKeys.i_saw_better_price.tr(),
                        )) {
                          options.remove(LocaleKeys.i_saw_better_price.tr());

                          optionCanselOrReturn.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_saw_better_price.tr());

                        optionCanselOrReturn.value = [...options];
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 1.sw,
              alignment: Alignment.center,
              height: 53.h,
              decoration: BoxDecoration(
                color: const Color(0xff388CFF),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                LocaleKeys.we_have_other_solutions_instead_cancellation.tr(),
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.18,
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 20.h),
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
                    height: 53.h,
                    decoration: BoxDecoration(
                      color: (_optionCanselOrReturn?.length ?? 0) > 0
                          ? const Color(0xffFF5F61)
                          : const Color(0xffD3D3D3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      LocaleKeys.cancel_request.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 25.h),
          ],
        ),
      ),
    );
  }

  Widget optionOfCanselOrReturnOrder(
    String text,
    double width,
    void Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: ValueListenableBuilder<List<String>>(
        valueListenable: optionCanselOrReturn,
        builder: (context, _optionCansel, _) {
          return Container(
            alignment: Alignment.center,
            height: 40.h,
            width: width,
            decoration: BoxDecoration(
              border: !_optionCansel.contains(text)
                  ? null
                  : Border.all(color: const Color(0xff402CDD)),
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget panelAddressContent(ScrollController sc) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.getCustomerAddressStatus != current.getCustomerAddressStatus,
      listener: (context, state) {
        if (state.getCustomerAddressStatus ==
            GetCustomerAddressesStatus.success) {
          indexTapAddress.value =
              orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
                (element) =>
                    element.id ==
                    orders[indexTapPackage.value].shippingAddressData?.id,
              ) ??
              -1;
          firstAddressChoosed = indexTapAddress.value;
          if (indexTapAddress.value == -1) {
            enableChangeAddress.value = true;
          } else if (indexTapAddress.value != firstAddressChoosed ||
              (state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .address !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.address ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .addressDetail !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.addressDetail ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.name !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.contactPersonName ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.phone !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.phone ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.country !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.country ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.city !=
                      orders[indexTapPackage.value].shippingAddressData?.city ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.province !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.province ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.street !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.street ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.building !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.building ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.town !=
                      orders[indexTapPackage.value].shippingAddressData?.town ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .location
                          ?.latitude !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.latitude ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .location
                          ?.longitude !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.longitude ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.alternativePhone !=
                      orders[indexTapPackage.value]
                          .shippingAddressData
                          ?.alternativePhone)) {
            enableChangeAddress.value = true;
          } else {
            enableChangeAddress.value = false;
          }
        }
      },
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
          return ValueListenableBuilder<int>(
            valueListenable: indexTapPackage,
            builder: (context, _indexTapPackage, _) {
              return ValueListenableBuilder<int>(
                valueListenable: indexTapAddress,
                builder: (context, _indexTap, _) {
                  return Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        width: 40.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffC4C2C2),
                          border: Border.all(color: const Color(0xffC4C2C2)),
                          borderRadius: BorderRadius.all(Radius.circular(2.r)),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 1.sw,
                        height: 205.h,
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F8F8),
                          border: Border.all(color: const Color(0xffF8F8F8)),
                          borderRadius: BorderRadius.all(Radius.circular(15.r)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            Container(
                              width: 1.sw,
                              height: 16.h,
                              child: Row(
                                children: [
                                  SizedBox(width: 10.w),
                                  SvgPicture.asset(
                                    AppAssets.orderClockSvg,
                                    height: 15.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    HelperFunctions.orderFormatDate(
                                      DateTime.tryParse(
                                            orders[_indexTapPackage]
                                                    .createdAt ??
                                                '',
                                          ) ??
                                          DateTime.now(),
                                    ),
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset(
                                    AppAssets.orderBag1Svg,
                                    height: 15.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    orders[_indexTapPackage].orderGroupId ?? "",
                                    style: context.textTheme.bodyMedium?.mq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: 1.sw,
                              height: 16.h,
                              child: Row(
                                children: [
                                  SizedBox(width: 10.w),
                                  SvgPicture.asset(
                                    AppAssets.preparingBagSvg,
                                    height: 15.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    orders[_indexTapPackage]
                                            .orderGroupStatus
                                            ?.label ??
                                        "",
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 5.w),
                                  SvgPicture.asset(
                                    AppAssets.orderPreparingSvg,
                                    height: 15.h,
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset(
                                    AppAssets.orderInvoice2Svg,
                                    height: 15.h,
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    (orders[_indexTapPackage].details?.length ??
                                            "")
                                        .toString(),
                                    style: context.textTheme.bodyMedium?.bq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    LocaleKeys.item.tr(),
                                    style: context.textTheme.bodyMedium?.mq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    HelperFunctions.formatNumber(
                                      numberToFormate:
                                          (HelperFunctions.truncateToDecimalPlaces(
                                            orders[_indexTapPackage]
                                                .orderAmount!,
                                            homeBloc
                                                .state
                                                .getCurrencyForCountryModel!
                                                .data!
                                                .currency!
                                                .decimalDigits!,
                                          ) *
                                          homeBloc
                                              .state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .exchangeRate!),
                                      isNeedRounding: false,
                                    ),
                                    style: context.textTheme.bodyMedium?.bq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    homeBloc
                                        .state
                                        .getCurrencyForCountryModel!
                                        .data!
                                        .currency!
                                        .symbol!,
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: 12.sp,
                                          height: 1.3,
                                        ),
                                  ),
                                  SizedBox(width: 10.w),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              height: 125.h,
                              width: 1.sw,
                              padding: EdgeInsets.only(
                                left: LanguageService.languageCode == "ar"
                                    ? 0
                                    : 10.w,
                                right: LanguageService.languageCode != "ar"
                                    ? 0
                                    : 10.w,
                              ),
                              child: ListView.builder(
                                itemCount:
                                    orders[_indexTapPackage].details?.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 125.h,
                                    width: 92.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15.r),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15.r),
                                      ),
                                      child: MyCachedNetworkImage(
                                        imageUrl:
                                            orders[_indexTapPackage]
                                                .details?[index]
                                                .image ??
                                            "",
                                        width: 92.w,
                                        imageFit: BoxFit.contain,
                                        height: 125.h,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SvgPicture.asset(
                        AppAssets.orderChangeAddressSvg,
                        height: 30.h,
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        LocaleKeys.change_delivery_address.tr(),
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        LocaleKeys.you_can_change_delivery_address_delivery_note
                            .tr(),
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: const Divider(color: Color(0xffC4C2C2)),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: addressWidgets(context, state, _indexTap, sc),
                      ),
                      const Spacer(),
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
                              margin: EdgeInsets.symmetric(horizontal: 24.w),
                              width: 1.sw,
                              height: 53.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: _enableChangeAddress
                                    ? const Color(0xff402CDD)
                                    : const Color(0xffD3D3D3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${LocaleKeys.change_request.tr()} ",
                                style: context.textTheme.bodyMedium?.mq
                                    .copyWith(
                                      color: const Color(0xffFFFFFF),
                                      letterSpacing: 0.18,
                                      fontSize: 16.sp,
                                      height: 1.33,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                    ],
                  );
                },
              );
            },
          );
        },
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
      height: 410.h,
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            height: 50.h,
            width: 1.sw,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.all(Radius.circular(15.r)),
            ),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  width: ((1.sw - 58) / 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff402CDD)),
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                  ),
                  child: Text(
                    LocaleKeys.delivery_address.tr(),
                    style: context.textTheme.bodyMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14.sp,
                      height: 1.33,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  width: ((1.sw - 58) / 2),
                  decoration: BoxDecoration(
                    //   border: Border.all(color: Color(0xff402CDD)),
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                  ),
                  child: Text(
                    LocaleKeys.delivery_note.tr(),
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14.sp,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          state.getCustomerAddressStatus ==
                      GetCustomerAddressesStatus.loading ||
                  state.addAddressToOrderStatus ==
                      AddAddressToOrderStatus.loading ||
                  state.removeAddressToOrderStatus ==
                      RemoveAddressToOrderStatus.loading ||
                  state.editAddressToOrderStatus ==
                      EditAddressToOrderStatus.loading
              ? TrydosLoader(size: 16)
              : Text(
                  "${LocaleKeys.your_address_list.tr()} ",
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.33,
                  ),
                ),
          SizedBox(height: 10.h),
          state.getCustomerAddressStatus ==
                      GetCustomerAddressesStatus.loading ||
                  state.addAddressToOrderStatus ==
                      AddAddressToOrderStatus.loading ||
                  state.removeAddressToOrderStatus ==
                      RemoveAddressToOrderStatus.loading ||
                  state.editAddressToOrderStatus ==
                      EditAddressToOrderStatus.loading
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    Container(
                      height: 295.h,
                      width: 1.sw,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemBuilder: (context, index) =>
                            index == state.listOfAddressInfoClassToSave!.length
                            ? SizedBox(height: 50.h, width: 1.sw)
                            : InkWell(
                                onTap: () {
                                  if (index != firstAddressChoosed ||
                                      (state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .address !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.address ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .addressDetail !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.addressDetail ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.name !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.contactPersonName ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.phone !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.phone ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.country !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.country ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.city !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.city ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.province !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.province ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.street !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.street ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.building !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.building ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.town !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.town ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .location
                                                  ?.latitude !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.latitude ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .location
                                                  ?.longitude !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.longitude ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.alternativePhone !=
                                              orders[indexTapPackage.value]
                                                  .shippingAddressData
                                                  ?.alternativePhone)) {
                                    enableChangeAddress.value = true;
                                  } else {
                                    enableChangeAddress.value = false;
                                  }
                                  indexTapAddress.value = index;
                                },
                                child: addressInfoWithContactInfoCart(
                                  isChange: false,
                                  customerAddressesInfo: state
                                      .listOfAddressInfoClassToSave![index],
                                  context: context,
                                  index: index,
                                  indexTap: _indexTap,
                                  onTapDelete: () {},
                                  onTapEdit: () {
                                    //   panelController.close();
                                    HelperFunctions.slidingNavigation(
                                      context,
                                      AddShippingAdress(
                                        addressInfoClassToEdid: state
                                            .listOfAddressInfoClassToSave![index],
                                        fromEdid: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemCount:
                            state.listOfAddressInfoClassToSave!.length + 1,
                        controller: sc,
                      ),
                    ),
                    Positioned(
                      child: InkWell(
                        onTap: () {
                          // panelController.close();
                          HelperFunctions.slidingNavigation(
                            context,
                            const AddShippingAdress(),
                          );
                        },
                        child: Container(
                          height: 40.h,
                          width: 1.sw - 56,

                          decoration: BoxDecoration(
                            color: const Color(0xffE8FFED),
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: const Color(0xffC4C2C2)),
                          ),
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
                              SizedBox(width: 3.w),
                              Text(
                                "${LocaleKeys.add_new_shipping_address.tr()} ",
                                style: context.textTheme.bodyMedium?.mq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height: 1.33,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      bottom: 0,
                    ),
                  ],
                  alignment: Alignment.center,
                ),
        ],
      ),
    );
  }

  Widget optionsForAllOrder() {
    return ValueListenableBuilder<int>(
      valueListenable: indexTapPackage,
      builder: (context, _indexTapPackage, _) {
        // Defensive: the pack list may have shrunk (a pack was hidden) while
        // this panel content rebuilds — render nothing instead of a RangeError.
        if (orders.isEmpty || _indexTapPackage >= orders.length) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 1.sw,
              height: 205.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                border: Border.all(color: const Color(0xffF8F8F8)),
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    height: 16.h,
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        SvgPicture.asset(AppAssets.orderClockSvg, height: 15.h),
                        SizedBox(width: 5.w),
                        Text(
                          HelperFunctions.orderFormatDate(
                            DateTime.tryParse(
                                  orders[_indexTapPackage].createdAt ?? '',
                                ) ??
                                DateTime.now(),
                          ),
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(AppAssets.orderBag1Svg, height: 15.h),
                        SizedBox(width: 5.w),
                        Text(
                          orders[_indexTapPackage].orderGroupId ?? "",
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    height: 16.h,
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        SvgPicture.asset(
                          AppAssets.preparingBagSvg,
                          height: 15.h,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          orders[_indexTapPackage].orderGroupStatus?.label ??
                              "",
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        SvgPicture.asset(
                          AppAssets.orderPreparingSvg,
                          height: 15.h,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppAssets.orderInvoice2Svg,
                          height: 15.h,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          (orders[_indexTapPackage].details?.length ?? "")
                              .toString(),
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          LocaleKeys.item.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          HelperFunctions.formatNumber(
                            numberToFormate:
                                (HelperFunctions.truncateToDecimalPlaces(
                                  orders[_indexTapPackage].orderAmount!,
                                  homeBloc
                                      .state
                                      .getCurrencyForCountryModel!
                                      .data!
                                      .currency!
                                      .decimalDigits!,
                                ) *
                                homeBloc
                                    .state
                                    .getCurrencyForCountryModel!
                                    .data!
                                    .currency!
                                    .exchangeRate!),
                            isNeedRounding: false,
                          ),
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          homeBloc
                              .state
                              .getCurrencyForCountryModel!
                              .data!
                              .currency!
                              .symbol!,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 125.h,
                    width: 1.sw,
                    padding: EdgeInsets.only(
                      left: LanguageService.languageCode == "ar" ? 0 : 10.w,
                      right: LanguageService.languageCode != "ar" ? 0 : 10.w,
                    ),
                    child: ListView.builder(
                      itemCount: orders[_indexTapPackage].details?.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 125.h,
                          width: 92.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl:
                                  orders[_indexTapPackage]
                                      .details?[index]
                                      .image ??
                                  "",
                              width: 92.w,
                              imageFit: BoxFit.contain,
                              height: 125.h,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "${LocaleKeys.action_about_order.tr()}",
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 1.sw,
              height: 0.5,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: BorderRadius.all(Radius.circular(2.r)),
              ),
            ),
            SizedBox(height: 30.h),
            orders[_indexTapPackage].canUpdateAddress ?? false
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: optionOfModify(
                      onTap: () {
                        orderBloc.add(const ResetAllStatusEvent());
                        optionModifyPanel.value = "Change_Address";
                      },
                      svg: AppAssets.orderChangeAddressSvg,
                      image2: "",
                      tiltle: "${LocaleKeys.change_delivery_address.tr()}",
                      body:
                          "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}",
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: optionOfModify(
                onTap: () {
                  orderBloc.add(const ResetAllStatusEvent());
                  _showHideConfirmDialog(
                    title: LocaleKeys.hide_this_pack.tr(),
                    body: LocaleKeys.are_you_sure_hide_this_pack.tr(),
                    onConfirm: () {
                      _pendingHide = true;
                      panelController.close();
                      showPanel.value = false;
                      optionModifyPanel.value = null;
                      showShadowForPanel.value = false;
                      orderBloc.add(
                        HideOrderEvent(
                          orderId:
                              orders[_indexTapPackage].id?.toString() ?? '',
                          orderGroupId:
                              orders[_indexTapPackage].orderGroupId ?? '',
                        ),
                      );
                    },
                  );
                },
                svg: AppAssets.hideThisProductSvg,
                image2: "",
                tiltle: "${LocaleKeys.hide_this_pack.tr()}",
                body: "${LocaleKeys.hide_this_pack_from_list.tr()}",
              ),
            ),
            SizedBox(height: 8.h),
            (orders[_indexTapPackage].canCanceleOrder ?? false)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: optionOfModify(
                      onTap: () {
                        orderBloc.add(const ResetAllStatusEvent());
                        optionModifyPanel.value = "Cancel_This_Order";
                      },
                      svg: AppAssets.orderCanselSvg,
                      image2: "",
                      tiltle:
                          "${LocaleKeys.cancel_this_order.tr()} ${orders[_indexTapPackage].id}",
                      body: LocaleKeys.cancel_order_hours_back_money.tr(
                        namedArgs: {'hours': '3'},
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget optionOfModify({
    required String svg,
    required String image2,
    required String tiltle,
    required String body,
    required Function onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 1.sw,
        height: 60.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: const Color(0xffF8F8F8),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),
            svg == ""
                ? SizedBox(width: 22.w)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(svg, width: 30.w),
                      image2 == ""
                          ? const SizedBox.shrink()
                          : image2.split(".").last != "svg"
                          ? ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.r),
                              ),
                              child: MyCachedNetworkImage(
                                radius: 15,
                                imageUrl: image2,
                                imageFit: BoxFit.fill,
                                width: 15.w,
                                height: 15.h,
                              ),
                            )
                          : SvgPicture.asset(
                              image2,
                              width: 10.w,
                              // ignore: deprecated_member_use
                              color: const Color(0xff402CDD),
                            ),
                    ],
                  ),
            SizedBox(width: 15.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tiltle,
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  body,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
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

  void _showHideConfirmDialog({
    required String title,
    required String body,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: const Color(0xff1D1D1D),
                    fontSize: 18.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        height: 44.h,
                        width: 110.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xffECECEC),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          LocaleKeys.cansel.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onConfirm();
                      },
                      child: Container(
                        height: 44.h,
                        width: 110.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xffE30613),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          LocaleKeys.confirm.tr(),
                          style: context.textTheme.bodyMedium?.mq.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shadowForPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForPanel,
      builder: (context, isShowShadowForPanel, _) {
        return !isShowShadowForPanel
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  showShadowForPanel.value = false;
                  Future.delayed(const Duration(microseconds: 300), () {
                    panelController.close();
                    showShadowForPanel.value = false;
                  });
                },
                child: Container(
                  height: 1.sh,
                  width: 1.sw,
                  color: const Color.fromRGBO(29, 29, 29, 0.6),
                ),
              );
      },
    );
  }

  Widget buildFifthSection({
    required List<OrderListDetailModel>? details,
    required String orderStatus,
    required String orderStatusLabel,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SizedBox(
        height: orderStatus == 'delivered' ? 195.h : 180.h,
        child: ListView.separated(
          itemCount: details?.length ?? 0,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    BlocProvider.of<HomeBloc>(context).add(
                      GetFullProductDetailsEvent(
                        currentColorName:
                            (details?[index].variation.isNullOrEmpty ?? false)
                            ? ""
                            : details?[index].variant?.split("-").first,
                        productSlug: details?[index].productSlug ?? "",
                      ),
                    );

                    Future.delayed(
                      const Duration(seconds: 1),
                      () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProductDetailsPageNew(
                                    productSlugForOpeningChatDirectly:
                                        details?[index].productSlug ?? "",
                                    productIdForOpeningChatDirectly:
                                        details?[index].productId.toString(),
                                  ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Container(
                      color: Colors.white,
                      child: MyCachedNetworkImage(
                        imageUrl: details?[index].image ?? '',
                        imageFit: BoxFit.contain,
                        width: 91.w,
                        height: 125.h,
                      ),
                    ),
                  ),
                ),
                ///////////////////
                SizedBox(height: 3.h),
                ///////////////////
                OrderStatusClass.statusOrderIsDelivered(orderStatus)
                    ? SvgPicture.asset(AppAssets.delivered_bagSvg, width: 13.w)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OrderStatusClass.statusOrderIsCanceled(orderStatus)
                              ? const SizedBox.shrink()
                              : SvgPicture.asset(
                                  OrderStatusClass.statusOrderIsPending(
                                        orderStatus,
                                      )
                                      ? AppAssets.pendingBagSvg
                                      : OrderStatusClass.statusOrderIsPreparing(
                                          orderStatus,
                                        )
                                      ? AppAssets.preparingBagSvg
                                      : OrderStatusClass.statusOrderIsShipped(
                                          orderStatus,
                                        )
                                      ? AppAssets.shippedAndOutOfDeliveryBagSvg
                                      : AppAssets.delivered_bagSvg,
                                  width: 13.w,
                                ),
                          //////////////////////////
                          SizedBox(width: 2.w),
                          //////////////////////////
                          SvgPicture.asset(
                            OrderStatusClass.statusOrderIsCanceled(orderStatus)
                                ? AppAssets.orderCanselSvg
                                : OrderStatusClass.statusOrderIsShipped(
                                    orderStatus,
                                  )
                                ? AppAssets.shippedBlackSvg
                                : OrderStatusClass.statusOrderIsPreparing(
                                    orderStatus,
                                  )
                                ? AppAssets.orderPreparingSvg
                                : OrderStatusClass.statusOrderIsPending(
                                    orderStatus,
                                  )
                                ? AppAssets.pendeingBlackCheck
                                : AppAssets.deliveredBlackSvg,
                            width: 13.w,
                          ),
                        ],
                      ),
                ///////////////////
                SizedBox(height: 2.h),

                ///////////////////
                OrderStatusClass.statusOrderIsDelivered(orderStatus)
                    ? Text(
                        LocaleKeys.delivered.tr(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10.sp,
                          height: 1.3,
                        ),
                      )
                    : Text(
                        (details?[index].variation.isNullOrEmpty ?? false)
                            ? ''
                            : details?[index].variation
                                      ?.firstWhere(
                                        (element) =>
                                            element.type ==
                                            details[index].variant,
                                      )
                                      .color
                                      ?.name ??
                                  "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10.sp,
                          height: 1.3,
                        ),
                      ),
                ///////////////////
                SizedBox(height: 2.h),
                ///////////////////
                OrderStatusClass.statusOrderIsDelivered(orderStatus)
                    ? BlocListener<HomeBloc, HomeState>(
                        listenWhen: (previous, current) =>
                            previous.createCommentRatingStatus !=
                                current.createCommentRatingStatus ||
                            previous.updateOrderCommentRatingStatus !=
                                current.updateOrderCommentRatingStatus,
                        listener: (context, state) {
                          if (state.createCommentRatingStatus ==
                                  CreateCommentRatingStatus.success ||
                              state.updateOrderCommentRatingStatus ==
                                  UpdateOrderCommentRatingStatus.success) {
                            homeBloc.add(
                              GetOrderRatingEvent(
                                orderDetailIds: (details!
                                    .map((e) => e.id!)
                                    .toList()),
                                userId: GetIt.I<PrefsRepository>().myMarketId,
                              ),
                            );
                          }
                        },
                        child: BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) =>
                              previous.getOrderRatingStatus !=
                                  current.getOrderRatingStatus ||
                              previous.createCommentRatingStatus !=
                                  current.createCommentRatingStatus ||
                              previous.updateOrderCommentRatingStatus !=
                                  current.updateOrderCommentRatingStatus,
                          builder: (context, state) {
                            if (state.statusCodeOfCommentProcess == "401" &&
                                (state.updateOrderCommentRatingStatus ==
                                        UpdateOrderCommentRatingStatus
                                            .failure ||
                                    state.deleteOrderCommentRatingStatus ==
                                        DeleteOrderCommentRatingStatus
                                            .failure ||
                                    state.createCommentRatingStatus ==
                                        CreateCommentRatingStatus.failure)) {
                              if (!(prefsRepository.isVerifiedPhone ?? false)) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    GuestPhoneVerificationDialog.show(context);
                                  }
                                });
                              }
                            }
                            return state.getOrderRatingStatus ==
                                        GetOrderRatingStatus.loading ||
                                    state.createCommentRatingStatus ==
                                        CreateCommentRatingStatus.loading ||
                                    state.updateOrderCommentRatingStatus ==
                                        UpdateOrderCommentRatingStatus.loading
                                ? Center(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: SizedBox(
                                        width: 80.w,
                                        height: 16.h,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (index) => Container(
                                              width: 16.w,
                                              height: 16.h,
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  AppAssets.starOutlineSvg,
                                                  width: 14.w,
                                                  height: 14.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: StarRatingWidget(
                                      initialRating:
                                          (state.getOrderRatingComments
                                              .firstWhere(
                                                (element) =>
                                                    element.orderDetailsId
                                                        .toString() ==
                                                    details?[index].id
                                                        .toString(),
                                                orElse: () => Comment(
                                                  orderDetailsId:
                                                      details?[index].id
                                                          ?.toString(),
                                                  starRating: 0,
                                                ),
                                              )
                                              .starRating ??
                                          0),
                                      initialImages: (state
                                          .getOrderRatingComments
                                          .firstWhere(
                                            (element) =>
                                                element.orderDetailsId
                                                    .toString() ==
                                                details?[index].id.toString(),
                                            orElse: () => Comment(
                                              images: [],
                                              orderDetailsId: details?[index].id
                                                  ?.toString(),
                                              starRating: 0,
                                            ),
                                          )
                                          .images),
                                      initialComment:
                                          (state.getOrderRatingComments
                                              .firstWhere(
                                                (element) =>
                                                    element.orderDetailsId
                                                        .toString() ==
                                                    details?[index].id
                                                        .toString(),
                                                orElse: () => Comment(
                                                  orderDetailsId:
                                                      details?[index].id
                                                          ?.toString(),
                                                  comment: "",
                                                ),
                                              )
                                              .comment ??
                                          ""),
                                      onRatingChanged: (rating, comment, photo) {
                                        if ((state.getOrderRatingComments
                                                    .firstWhere(
                                                      (element) =>
                                                          element.orderDetailsId
                                                              .toString() ==
                                                          details?[index].id
                                                              .toString(),
                                                      orElse: () => Comment(
                                                        orderDetailsId:
                                                            details?[index].id
                                                                ?.toString(),
                                                        starRating: 0,
                                                      ),
                                                    )
                                                    .starRating ??
                                                0) >
                                            0) {
                                          homeBloc.add(
                                            UpdateCommentRatingEvent(
                                              commentId:
                                                  (state.getOrderRatingComments
                                                      .firstWhere(
                                                        (element) =>
                                                            element
                                                                .orderDetailsId
                                                                .toString() ==
                                                            details?[index].id
                                                                .toString(),
                                                        orElse: () => Comment(
                                                          id: "",
                                                          orderDetailsId:
                                                              details?[index].id
                                                                  ?.toString(),
                                                          starRating: 0,
                                                        ),
                                                      )
                                                      .id ??
                                                  "0"),
                                              ownerId:
                                                  orders[indexTapPackage.value]
                                                      .ownerId,
                                              ownerType:
                                                  orders[indexTapPackage.value]
                                                      .ownerType,
                                              orderDetailsId: details?[index].id
                                                  ?.toString(),
                                              productId: details?[index]
                                                  .productId
                                                  .toString(),
                                              slug: details?[index].productSlug
                                                  .toString(),
                                              images: photo,
                                              variant: details?[index].variant,
                                              rating: rating.toString(),
                                              text: comment,
                                            ),
                                          );
                                          return;
                                        }
                                        homeBloc.add(
                                          CreateCommentRatingEvent(
                                            images: photo,
                                            orderDetailsId: details?[index].id
                                                ?.toString(),
                                            ownerId:
                                                orders[indexTapPackage.value]
                                                    .ownerId,
                                            ownerType:
                                                orders[indexTapPackage.value]
                                                    .ownerType,
                                            productId: details?[index].productId
                                                .toString(),
                                            variant: details?[index].variant,
                                            slug: details?[index].productSlug
                                                .toString(),

                                            rating: rating.toString(),
                                            text: comment,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                          },
                        ),
                      )
                    : Text(
                        orderStatus == 'delivered'
                            ? orderStatusLabel
                            : (details?[index].variation.isNullOrEmpty ?? false)
                            ? ''
                            : details?[index].variation?[0].size ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10.sp,
                          height: 1.3,
                        ),
                      ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(width: 5.w);
          },
        ),
      ),
    );
  }

  Widget buildFourthSection({
    required BuildContext context,
    required String itemsCount,
  }) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.orderReturnDetailsStatus != current.orderReturnDetailsStatus,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child:
              state.orderReturnDetailsStatus == OrderReturnDetailsStatus.loading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    alignment: Alignment.center,
                    width: 1.sw,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffC4C2C2),
                      border: Border.all(color: const Color(0xffC4C2C2)),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                )
              : Container(
                  height: 80.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 237, 237),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(AppAssets.bagsSvg, width: 20.w),
                          ///////////////////
                          SizedBox(height: 2.h),
                          ///////////////////
                          Text(
                            LocaleKeys.order_details.tr(),
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              fontSize: 10.sp,
                              height: 1.3,
                            ),
                          ),
                          ///////////////////
                          SizedBox(height: 2.h),
                          ///////////////////
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 14.sp,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(
                                  text: itemsCount,
                                  style: context.textTheme.bodyMedium?.bq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 14.sp,
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
                      const Spacer(),
                      ValueListenableBuilder<int>(
                        valueListenable: indexTapPackage,
                        builder: (context, _indexTapPackage, _) {
                          ReturnRequestsDatum? orderReturnDetail;

                          if (state.orderReturnDetailsModel != null) {
                            if (state
                                    .orderReturnDetailsModel!
                                    .data
                                    ?.returnRequestsData !=
                                null) {
                              orderReturnDetail = state
                                  .orderReturnDetailsModel!
                                  .data!
                                  .returnRequestsData!
                                  .firstWhere(
                                    (element) =>
                                        element.orderId ==
                                        orders[_indexTapPackage].id,
                                    orElse: () => ReturnRequestsDatum(),
                                  );
                            }
                          }

                          return (orders[_indexTapPackage].orderStatus?.value !=
                                          "out_for_delivery" &&
                                      orderReturnDetail?.status?.value !=
                                          "out_for_return") &&
                                  (!(fromNotification &&
                                      ((!(widget.parentOrderIdFormNotification ==
                                                  null ||
                                              widget.parentOrderIdFormNotification ==
                                                  "" ||
                                              widget.parentOrderIdFormNotification ==
                                                  "-1")) ||
                                          (!(widget.orderIdFormNotification ==
                                                  null ||
                                              widget.orderIdFormNotification ==
                                                  "" ||
                                              widget.orderIdFormNotification ==
                                                  "-1")))))
                              ? const SizedBox.shrink()
                              : Container(
                                  height: 40.h,
                                  child: BlocListener<CallsBloc, CallsState>(
                                    listenWhen: (p, c) =>
                                        p.makeCallStatus != c.makeCallStatus &&
                                        p.makeCallStatus ==
                                            MakeCallStatus.init &&
                                        c.makeCallStatus ==
                                            MakeCallStatus.loading,
                                    listener: (context, state) {
                                      if (kDebugMode)
                                        devLog(
                                          "GGGGGGFFFFFFFFFFFFFDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQ////",
                                        );
                                      callInProgressDialog(context);
                                    },
                                    child: BlocListener<CallsBloc, CallsState>(
                                      listenWhen: (p, c) =>
                                          p.makeCallStatus !=
                                              c.makeCallStatus &&
                                          c.makeCallStatus ==
                                              MakeCallStatus.failure,
                                      listener: (context, state) {
                                        Navigator.pop(context);
                                        showWarningMessage(
                                          context,
                                          '${state.receiverCallName ?? LocaleKeys.user.tr()} ${LocaleKeys.in_another_call.tr()}',
                                        );
                                      },
                                      child: BlocListener<CallsBloc, CallsState>(
                                        listenWhen: (p, c) =>
                                            p.makeCallStatus !=
                                                c.makeCallStatus &&
                                            c.makeCallStatus ==
                                                MakeCallStatus.startCall,
                                        listener: (context, state) {
                                          if (kDebugMode)
                                            devLog(
                                              "GGGGGGFFFFFFFFFFFFFDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQ",
                                            );
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => AgoraInAppWebView(
                                                type: state.isVideoCall
                                                    ? 'video'
                                                    : 'voice',
                                                isReceivingCall: false,
                                                isPrivate: true,
                                                channelId: state
                                                    .channelIdForCurrentCall!,
                                                auth_token:
                                                    GetIt.I<PrefsRepository>()
                                                        .chatToken!,
                                                uId: GetIt.I<PrefsRepository>()
                                                    .myChatId
                                                    .toString(),
                                                action: 'sent',
                                                messageId: state.messageId!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: BlocListener<ChatBloc, ChatState>(
                                          listenWhen: (previous, current) =>
                                              previous
                                                  .getOrderRecipientIdStatus !=
                                              current.getOrderRecipientIdStatus,
                                          listener: (context, state) {
                                            if (requestReturnApiFromNotification &&
                                                (state.getOrderRecipientIdStatus ==
                                                        GetOrderRecipientIdStatus
                                                            .success ||
                                                    state.getOrderRecipientIdStatus ==
                                                        GetOrderRecipientIdStatus
                                                            .failure)) {
                                              fromNotification = false;
                                              requestReturnApiFromNotification =
                                                  false;
                                              Future.delayed(
                                                const Duration(seconds: 3),
                                                () {
                                                  if (canFetchReturnDetails) {
                                                    orderBloc.add(
                                                      FetchOrderReturnDetailsEvent(
                                                        orders[indexTapPackage
                                                                    .value]
                                                                .orderGroupId ??
                                                            "",
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }

                                            if (state
                                                    .getOrderRecipientIdStatus ==
                                                GetOrderRecipientIdStatus
                                                    .success) {
                                              String receiverName =
                                                  HelperFunctions.getTheFirstTwoLettersOfName(
                                                    LocaleKeys.delivery_worker
                                                        .tr(),
                                                  );
                                              String fullReceiverName =
                                                  LocaleKeys.delivery_worker
                                                      .tr();
                                              String? recipientUserId =
                                                  state.recipientUserId;
                                              if (kDebugMode)
                                                devLog(
                                                  "recipientUserId $recipientUserId",
                                                );
                                              if (recipientUserId == null) {
                                                return;
                                              }
                                              Chat? chat;
                                              User? receiver;
                                              List<Chat> chats = List.of(
                                                GetIt.I<ChatBloc>().state.chats,
                                              );
                                              debugPrint(chats.toString());
                                              chats.addAll(
                                                GetIt.I<ChatBloc>()
                                                    .state
                                                    .pinnedChats,
                                              );
                                              chat = chats.firstWhere(
                                                (element) => element
                                                    .channelMembers!
                                                    .any((element) {
                                                      return element.userId
                                                              .toString() ==
                                                          recipientUserId;
                                                    }),
                                              );
                                              final preferences =
                                                  GetIt.I<PrefsRepository>();
                                              receiver = chat.channelMembers
                                                  ?.firstWhere(
                                                    (element) =>
                                                        element.userId !=
                                                        preferences.myChatId,
                                                    orElse: () => ChannelMember(
                                                      userId: int.tryParse(
                                                        recipientUserId,
                                                      ),
                                                      user: User(
                                                        id: int.tryParse(
                                                          recipientUserId,
                                                        ),
                                                        name: receiverName,
                                                      ),
                                                    ),
                                                  )
                                                  .user;
                                              String fromOrder = "true";
                                              context.go(
                                                GRouter
                                                        .config
                                                        .applicationRoutes
                                                        .kSinglePageChatPagePath +
                                                    '?chatId=${chat.id!.toString()}&fromOrder=$fromOrder&receiverName=$receiverName&fullReceiverName=${fullReceiverName}&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}&senderName=${HelperFunctions.getTheFirstTwoLettersOfName(GetIt.I<PrefsRepository>().myChatName!)}',
                                              );
                                            }
                                            // TODO: implement listener
                                          },
                                          child: BlocBuilder<ChatBloc, ChatState>(
                                            buildWhen: (previous, current) =>
                                                previous
                                                    .getOrderRecipientIdStatus !=
                                                current
                                                    .getOrderRecipientIdStatus,
                                            builder: (context, state) {
                                              if (state
                                                      .getOrderRecipientIdStatus ==
                                                  GetOrderRecipientIdStatus
                                                      .loading) {
                                                return Container(
                                                  width: 30.w,
                                                  height: 30.h,
                                                  child: TrydosLoader(size: 16),
                                                );
                                              }
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 5.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    82,
                                                    139,
                                                    236,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(12.r),
                                                      ),
                                                ),
                                                alignment: Alignment.center,

                                                height: 30.h,

                                                child: InkWell(
                                                  onTap: () {
                                                    chatBloc.add(
                                                      GetOrderRecipientIdEvent(
                                                        originalUserId:
                                                            GetIt.I<
                                                                  PrefsRepository
                                                                >()
                                                                .myMarketId
                                                                .toString(),
                                                        parentOrderId:
                                                            orderReturnDetail ==
                                                                null
                                                            ? null
                                                            : orderReturnDetail
                                                                      .status
                                                                      ?.value ==
                                                                  "out_for_return"
                                                            ? orders[indexTapPackage
                                                                      .value]
                                                                  .id
                                                                  .toString()
                                                            : null,
                                                        orderId:
                                                            orderReturnDetail ==
                                                                null
                                                            ? orders[indexTapPackage
                                                                      .value]
                                                                  .id
                                                                  .toString()
                                                            : orderReturnDetail
                                                                      .status
                                                                      ?.value ==
                                                                  "out_for_return"
                                                            ? orderReturnDetail
                                                                  .returnRequestId
                                                                  .toString()
                                                            : orders[indexTapPackage
                                                                      .value]
                                                                  .id
                                                                  .toString(),
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        AppAssets.chatSvg,
                                                        width: 15.w,
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Text(
                                                        LocaleKeys
                                                            .chat_with_delivery_person
                                                            .tr(),
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.rq
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xffFFFFFF,
                                                                  ),
                                                              fontSize: 9.sp,
                                                              height: 1.3,
                                                              letterSpacing:
                                                                  0.18,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget buildThirdSectionForRating() {
    return Container(
      padding: EdgeInsets.only(top: 12.h, left: 12.w, right: 12.w),
      margin: EdgeInsets.symmetric(horizontal: 12.w),

      width: 1.sw,
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xff402CDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppAssets.groupStarsRattingSvg),
          SizedBox(height: 7.h),
          Text(
            LocaleKeys.rate_and_get_money.tr(),
            style: context.textTheme.bodyMedium?.mq.copyWith(
              color: const Color(0xff1D1D1D),
              letterSpacing: 0.18,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            LocaleKeys.rating_section_description.tr(),
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff5D5C5D),
              letterSpacing: 0.18,
              fontSize: 10.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  singleChildController.jumpTo(
                    singleChildController.position.maxScrollExtent,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 290.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: const Color(0xff402CDD),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.groupStarsRattingSvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xffFFD800),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        LocaleKeys.rate_and_get_money.tr(),
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          fontSize: 14.sp,
                          height: 1.7,
                          color: const Color(0xffFFD800),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(
                        AppAssets.groupStarsRattingSvg,
                        // ignore: deprecated_member_use
                        color: const Color(0xffFFD800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffF4F4F4),
          borderRadius: BorderRadius.circular(15.r),
        ),
        padding: EdgeInsets.all(8.w),
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
                fontSize: 10.sp,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            Text(
              LocaleKeys.my_home.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            BlocBuilder<OrderBloc, OrderState>(
              buildWhen: (previous, current) =>
                  previous.getOrdersByOrderGroupIDStatus !=
                      current.getOrdersByOrderGroupIDStatus ||
                  previous.hideOrderVisibilityStatus !=
                      current.hideOrderVisibilityStatus,
              builder: (context, state) {
                return (state.getOrdersByOrderGroupIDStatus ==
                            GetOrdersByOrderGroupIDStatus.loading ||
                        state.hideOrderVisibilityStatus ==
                            HideOrderVisibilityStatus.loading)
                    ? TrydosLoader(size: 16)
                    : Text(
                        shippingDeliveryAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      );
              },
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            Text(
              LocaleKeys.recipient.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10.sp,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            Text(
              recipientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            Text(
              LocaleKeys.phone.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 10.sp,
                height: 1.3,
              ),
            ),
            ///////////////////
            SizedBox(height: 4.h),
            ///////////////////
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                contactInfo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
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
    required String orderStatusLable,
    String deliverdTo = '',
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(AppAssets.orderAddressSvg, width: 20.w),
                  ///////////////////
                  SvgPicture.asset(AppAssets.orderDeliveryDateSvg, width: 20.w),
                ],
              ),
              title: LocaleKeys.expected_delivery_date.tr(),
              value: expectedDeliveryDate,
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
          //////////////////////////
          SizedBox(width: 8.w),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OrderStatusClass.statusOrderIsCanceled(orderStatus)
                      ? SvgPicture.asset(AppAssets.orderCanselSvg, width: 20.w)
                      : SvgPicture.asset(AppAssets.pendingBagSvg, width: 15.w),
                  ////////////////////
                  SizedBox(width: 3.w),
                  ///////////////////
                  OrderStatusClass.statusOrderIsCanceled(orderStatus)
                      ? const SizedBox.shrink()
                      : OrderStatusClass.statusOrderIsPending(orderStatus)
                      ? SvgPicture.asset(AppAssets.whiteBagSvg, width: 15.w)
                      : SvgPicture.asset(
                          AppAssets.preparingBagSvg,
                          width: 15.w,
                        ),
                  ////////////////////
                  SizedBox(width: 3.w),
                  ///////////////////
                  OrderStatusClass.statusOrderIsCanceled(orderStatus)
                      ? const SizedBox.shrink()
                      : (OrderStatusClass.statusOrderIsPending(orderStatus) ||
                            OrderStatusClass.statusOrderIsPreparing(
                              orderStatus,
                            ))
                      ? SvgPicture.asset(AppAssets.whiteBagSvg, width: 15.w)
                      : SvgPicture.asset(
                          AppAssets.shippedAndOutOfDeliveryBagSvg,
                          width: 15.w,
                        ),
                  ////////////////////
                  SizedBox(width: 3.w),
                  ///////////////////
                  OrderStatusClass.statusOrderIsCanceled(orderStatus)
                      ? const SizedBox.shrink()
                      : (OrderStatusClass.statusOrderIsPending(orderStatus) ||
                            OrderStatusClass.statusOrderIsPreparing(
                              orderStatus,
                            ) ||
                            OrderStatusClass.statusOrderIsShipped(orderStatus))
                      ? SvgPicture.asset(AppAssets.whiteBagSvg, width: 15.w)
                      : SvgPicture.asset(
                          AppAssets.delivered_bagSvg,
                          width: 15.w,
                        ),
                ],
              ),
              title: LocaleKeys.order_status.tr(),
              value: orderStatus == 'delivered'
                  ? '$orderStatusLable ${LocaleKeys.to.tr()} $deliverdTo'
                  : orderStatusLable,
              amount: '',
              isTextSpan: false,
              titleIcons: buildTitleIcons(status: orderStatus),
              valueIcons: buildValueIcons(status: orderStatus),
              currency: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitleIcons({required String status}) {
    if (OrderStatusClass.statusOrderIsPending(status))
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.pendingBlueCheckSvg, width: 15.w),
        ],
      );
    else if (OrderStatusClass.statusOrderIsPreparing(status))
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingBlueSvg, width: 15.w),
        ],
      );
    else
      return const SizedBox.shrink();
  }

  Widget buildValueIcons({required String status}) {
    if (OrderStatusClass.statusOrderIsPending(status))
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.pendeingBlackCheck, width: 15.w),
        ],
      );
    else if (OrderStatusClass.statusOrderIsPreparing(status))
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingBlackSvg, width: 15.w),
          /////////////////////////////
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingGreySvg, width: 15.w),
          /////////////////////////////
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingGrey2Svg, width: 15.w),
        ],
      );
    else if (OrderStatusClass.statusOrderIsShipped(status))
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedBlackSvg, width: 15.w),
          /////////////////////////////
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedGreySvg, width: 15.w),
          /////////////////////////////
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedGrey_2Svg, width: 15.w),
        ],
      );
    else
      return Row(
        children: [
          SizedBox(width: 5.w),
          //////////////////////////
          SvgPicture.asset(AppAssets.deliveredBlackSvg, width: 15.w),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(AppAssets.orderBag1Svg, width: 20.w),
              title: LocaleKeys.order_number.tr(),
              value: orderNumber,
              amount: '',
              isTextSpan: false,
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
              currency: '',
            ),
          ),
          //////////////////////////
          SizedBox(width: 8.w),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(AppAssets.orderClockSvg, width: 20.w),
              title: LocaleKeys.order_date.tr(),
              value: orderDate,
              amount: '',
              isTextSpan: false,
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
              currency: '',
            ),
          ),
          //////////////////////////
          SizedBox(width: 8.w),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(AppAssets.orderInvoice2Svg, width: 20.w),
                  SvgPicture.asset(AppAssets.orderWalletSvg, width: 15.w),
                ],
              ),
              title: LocaleKeys.order_invoice.tr(),
              amount: orderAmount,
              isTextSpan: true,
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
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
    required Widget titleIcons,
    required Widget valueIcons,
    required String title,
    required String value,
    required bool isTextSpan,
    required String amount,
    required String currency,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(15.r),
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          firstItem,
          ///////////////////
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 10.sp,
                    height: 1.3,
                  ),
                ),
              ),
              ///////////////
              titleIcons,
            ],
          ),
          ///////////////////
          isTextSpan
              ? Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff505050),
                        letterSpacing: 0.18,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: amount,
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        TextSpan(text: ' $currency'),
                      ],
                    ),
                  ),
                )
              : Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                    valueIcons,
                  ],
                ),
        ],
      ),
    );
  }
}
