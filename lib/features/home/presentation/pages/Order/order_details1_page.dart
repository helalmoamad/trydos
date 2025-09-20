import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart' as local;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart'
    show PanelController, SlidingUpPanel;
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/domain/use_cases/add_order_comment_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_order_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_order_address_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_order_comment_usecase.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart'
    show
        ChangeOrderByGroupStatus,
        GetOrdersEvent,
        CancelOrderEvent,
        GetOrdersByOrderGroupIDEvent,
        GetCustomerAddressesEvent,
        ChangeOrderAddressEvent,
        UpdateOrderCommentEvent,
        AddOrderCommentEvent,
        FetchOrderReturnDetailsEvent,
        ResetAllStatusEvent;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';
import 'package:trydos/features/home/presentation/widgets/star_rating_widget.dart';
import 'package:trydos/main.dart' show navigatorKey;
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

class OrderDetails1 extends StatefulWidget {
  const OrderDetails1(
      {super.key,
      this.fromNotification = false,
      this.currentStatus = "",
      this.orderIdToOpenPackage = "",
      this.indexGroupe = -1,
      this.orderIdFormNotification,
      this.parentOrderIdFormNotification,
      required this.orders});

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
  final ValueNotifier<int> indexTapPackage = ValueNotifier(0);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final ValueNotifier<List<String>> optionCanselOrReturn = ValueNotifier([]);
  List<OrderListModel> orders = [];
  int firstAddressChoosed = 0;
  bool firstOpenPage = true;
  bool requestReturnApiFromNotification = false;
  bool requestReturnApi = false;
  bool canFetchReturnDetails = false;
  @override
  void initState() {
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
    if (widget.fromNotification &&
        widget.orderIdFormNotification != null &&
        widget.orderIdFormNotification != "") {
      requestReturnApiFromNotification = true;
      indexTapPackage.value = orders.indexWhere((element) =>
          element.id.toString() ==
          (widget.parentOrderIdFormNotification ??
              widget.orderIdFormNotification));

      GetIt.I<ChatBloc>().add(GetOrderRecipientIdEvent(
          originalUserId: GetIt.I<PrefsRepository>().myMarketId.toString(),
          orderId: widget.orderIdFormNotification!));
    } else if (widget.orderIdToOpenPackage != "") {
      indexTapPackage.value = orders.indexWhere(
          (element) => element.id.toString() == widget.orderIdToOpenPackage);
    }
    homeBloc = BlocProvider.of<HomeBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    if (!widget.fromNotification) {
      Future.delayed(const Duration(seconds: 5), () {
        orderBloc.add(
          GetOrdersByOrderGroupIDEvent(
              orderGroupId: orders[indexTapPackage.value].orderGroupId ?? "",
              firstOpenPage: true),
        );
      });
    }
    orders.forEach(
      (element) {
        if (element.returnRequestId != null) {
          canFetchReturnDetails = true;
        }
      },
    );
    if (canFetchReturnDetails && !widget.fromNotification) {
      orderBloc.add(FetchOrderReturnDetailsEvent(
        orders[indexTapPackage.value].orderGroupId ?? "",
      ));
    }

    indexTapAddress.value = orderBloc.state.listOfAddressInfoClassToSave
            ?.indexWhere((element) =>
                element.id ==
                orders[indexTapPackage.value].shippingAddressData?.id) ??
        -1;

    firstAddressChoosed = indexTapAddress.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshData() async {
      if (canFetchReturnDetails) {
        orderBloc.add(FetchOrderReturnDetailsEvent(
          orders[indexTapPackage.value].orderGroupId ?? "",
        ));
      }

      orderBloc.add(
        GetOrdersByOrderGroupIDEvent(
            orderGroupId: widget.orders[0].orderGroupId ?? ""),
      );

      // 🚀 إزالة التأخير المصطنع - دع البيانات تحدد سرعة التحميل!
      await Future.delayed(
          const Duration(seconds: 3)); // ❌ تم حذف التأخير المصطنع
    }

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

              return false;
            }
          } catch (e) {
            return true;
          }
          return true;
        },
        child: BlocListener<OrderBloc, OrderState>(
            listenWhen: (p, c) =>
                p.getOrdersByOrderGroupIDStatus !=
                c.getOrdersByOrderGroupIDStatus,
            listener: (context, state) {
              if (state.getOrdersByOrderGroupIDStatus ==
                  GetOrdersByOrderGroupIDStatus.success) {
                if (orders[indexTapPackage.value].orderGroupId ==
                    state.getOrdersByOrderGroupIDModel
                        ?.orders?[indexTapPackage.value].orderGroupId) {
                  orders = state.getOrdersByOrderGroupIDModel?.orders ?? [];
                  orders.forEach(
                    (element) {
                      if (element.returnRequestId != null) {
                        canFetchReturnDetails = true;
                      }
                    },
                  );
                }
                if (!firstOpenPage) {
                  indexTapAddress.value = orderBloc
                          .state.listOfAddressInfoClassToSave
                          ?.indexWhere((element) =>
                              element.id ==
                              orders[indexTapPackage.value]
                                  .shippingAddressData
                                  ?.id) ??
                      -1;
                  firstAddressChoosed = indexTapAddress.value;
                  orderBloc.add(GetOrdersEvent(
                      status: widget.currentStatus ?? '',
                      orders: orders,
                      index: widget.indexGroupe,
                      getWithPagination: false));
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
                    c.getOrdersByOrderGroupIDStatus,
                builder: (context, state) {
                  return ValueListenableBuilder<int>(
                      valueListenable: indexTapPackage,
                      builder: (context, _indexTapPackage, _) {
                        addressParts = [
                          orders[_indexTapPackage].shippingAddressData?.country,
                          orders[_indexTapPackage]
                              .shippingAddressData
                              ?.province,
                          orders[_indexTapPackage].shippingAddressData?.city,
                          orders[_indexTapPackage].shippingAddressData?.town,
                          orders[_indexTapPackage].shippingAddressData?.street,
                          orders[_indexTapPackage]
                              .shippingAddressData
                              ?.building,
                        ];
                        print(addressParts);
                        final addressString = addressParts
                            .where((part) =>
                                part != null &&
                                part != 'null' &&
                                part.isNotEmpty)
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            SvgPicture.asset(
                                              AppAssets.bagsSvg,
                                              width: 23,
                                            ),
                                            ///////////////////////////
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            ///////////////////////////
                                            Text(
                                              LocaleKeys.order_details.tr(),
                                              style: context
                                                  .textTheme.bodyMedium?.mq
                                                  .copyWith(
                                                color: const Color(0xff1D1D1D),
                                                letterSpacing: 0.18,
                                                fontSize: 14,
                                                height: 1.3,
                                              ),
                                            ),
                                            ///////////////////////////
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            ///////////////////////////
                                          ],
                                        ),
                                        const Spacer(),
                                        ////////////
                                        InkWell(
                                          onTap: () {
                                            if (state
                                                    .getOrdersByOrderGroupIDStatus ==
                                                GetOrdersByOrderGroupIDStatus
                                                    .loading) {
                                              return;
                                            }
                                            optionModifyPanel.value =
                                                "All_Order";
                                            showPanel.value = true;
                                            panelController.open();
                                            showShadowForPanel.value = true;
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 20,
                                            child: state.getOrdersByOrderGroupIDStatus ==
                                                    GetOrdersByOrderGroupIDStatus
                                                        .loading
                                                ? TrydosLoader(
                                                    size: 16,
                                                  )
                                                : SvgPicture.asset(
                                                    AppAssets.orderMenuSvg,
                                                    width: 20,
                                                  ),
                                          ),
                                        ),
                                        ///////////////////////////
                                        const SizedBox(
                                          width: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  body: RefreshIndicator(
                                    backgroundColor: Colors.white,
                                    color: Colors.black,
                                    onRefresh: _refreshData,
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 11.h,
                                          ),
                                          ///////////////////
                                          BlocBuilder<HomeBloc, HomeState>(
                                            buildWhen: (previous, current) => (previous
                                                    .getCurrencyForCountryModel !=
                                                current
                                                    .getCurrencyForCountryModel),
                                            builder: (context, state) {
                                              String currencySymbol = state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .symbol ??
                                                  "";
                                              double orderAmount = 0;
                                              orders.forEach((element) =>
                                                  orderAmount = orderAmount +
                                                      (element.orderAmount! *
                                                          state
                                                              .getCurrencyForCountryModel!
                                                              .data!
                                                              .currency!
                                                              .exchangeRate!));

                                              return SizedBox(
                                                height: 95,
                                                child: buildFirstSection(
                                                  context: context,
                                                  orderNumber:
                                                      orders[_indexTapPackage]
                                                              .orderGroupId ??
                                                          '',
                                                  orderDate: HelperFunctions
                                                      .orderFormatDate(
                                                    DateTime.tryParse(
                                                            orders[_indexTapPackage]
                                                                    .createdAt ??
                                                                '') ??
                                                        DateTime.now(),
                                                  ),
                                                  orderAmount: HelperFunctions
                                                      .formatNumber(
                                                          number: orderAmount,
                                                          isNeedRounding:
                                                              false),
                                                  orderCurrency: currencySymbol,
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          ///////////////////////
                                          SizedBox(
                                            height: 85,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: state.getOrdersByOrderGroupIDStatus ==
                                                      GetOrdersByOrderGroupIDStatus
                                                          .loading
                                                  ? TrydosLoader(
                                                      size: 16,
                                                    )
                                                  : buildDetailsMainInfoWidget(
                                                      context: context,
                                                      firstItem: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          orders[_indexTapPackage]
                                                                      .orderGroupStatus
                                                                      ?.value ==
                                                                  'canceled'
                                                              ? SvgPicture
                                                                  .asset(
                                                                  AppAssets
                                                                      .orderCanselSvg,
                                                                  width: 20,
                                                                )
                                                              : orders[_indexTapPackage]
                                                                          .orderGroupStatus
                                                                          ?.value ==
                                                                      'pending'
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      AppAssets
                                                                          .pendingBagSvg,
                                                                      width: 20,
                                                                    )
                                                                  : SvgPicture
                                                                      .asset(
                                                                      AppAssets
                                                                          .pendingBagSvg,
                                                                      width: 15,
                                                                    ),
                                                          ////////////////////
                                                          const SizedBox(
                                                            width: 3,
                                                          ),
                                                          ///////////////////

                                                          orders[_indexTapPackage]
                                                                      .orderGroupStatus
                                                                      ?.value ==
                                                                  'canceled'
                                                              ? const SizedBox
                                                                  .shrink()
                                                              : orders[_indexTapPackage]
                                                                          .orderGroupStatus
                                                                          ?.value ==
                                                                      'pending'
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      AppAssets
                                                                          .whiteBagSvg,
                                                                      width: 15,
                                                                    )
                                                                  : orders[_indexTapPackage]
                                                                              .orderGroupStatus
                                                                              ?.value ==
                                                                          'preparing'
                                                                      ? SvgPicture
                                                                          .asset(
                                                                          AppAssets
                                                                              .preparingBagSvg,
                                                                          width:
                                                                              20,
                                                                        )
                                                                      : SvgPicture
                                                                          .asset(
                                                                          AppAssets
                                                                              .preparingBagSvg,
                                                                          width:
                                                                              15,
                                                                        ),
                                                          ////////////////////
                                                          const SizedBox(
                                                            width: 3,
                                                          ),
                                                          ///////////////////
                                                          orders[_indexTapPackage]
                                                                      .orderGroupStatus
                                                                      ?.value ==
                                                                  'canceled'
                                                              ? const SizedBox
                                                                  .shrink()
                                                              : orders[_indexTapPackage]
                                                                          .orderGroupStatus
                                                                          ?.value ==
                                                                      'pending'
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      AppAssets
                                                                          .whiteBagSvg,
                                                                      width: 15,
                                                                    )
                                                                  : orders[_indexTapPackage]
                                                                              .orderGroupStatus
                                                                              ?.value ==
                                                                          'preparing'
                                                                      ? SvgPicture
                                                                          .asset(
                                                                          AppAssets
                                                                              .whiteBagSvg,
                                                                          width:
                                                                              15,
                                                                        )
                                                                      : orders[_indexTapPackage].orderGroupStatus?.value ==
                                                                              'shipped'
                                                                          ? SvgPicture
                                                                              .asset(
                                                                              AppAssets.shippedAndOutOfDeliveryBagSvg,
                                                                              width: 20,
                                                                            )
                                                                          : SvgPicture
                                                                              .asset(
                                                                              AppAssets.shippedAndOutOfDeliveryBagSvg,
                                                                              width: 15,
                                                                            ),
                                                          ////////////////////
                                                          const SizedBox(
                                                            width: 3,
                                                          ),
                                                          ///////////////////
                                                          orders[_indexTapPackage]
                                                                      .orderGroupStatus
                                                                      ?.value ==
                                                                  'canceled'
                                                              ? const SizedBox
                                                                  .shrink()
                                                              : orders[_indexTapPackage]
                                                                          .orderGroupStatus
                                                                          ?.value ==
                                                                      'pending'
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      AppAssets
                                                                          .whiteBagSvg,
                                                                      width: 15,
                                                                    )
                                                                  : orders[_indexTapPackage].orderGroupStatus?.value ==
                                                                              'preparing' ||
                                                                          orders[_indexTapPackage].orderGroupStatus?.value ==
                                                                              'canceled'
                                                                      ? SvgPicture
                                                                          .asset(
                                                                          AppAssets
                                                                              .whiteBagSvg,
                                                                          width:
                                                                              15,
                                                                        )
                                                                      : orders[_indexTapPackage].orderGroupStatus?.value ==
                                                                              'shipped'
                                                                          ? SvgPicture
                                                                              .asset(
                                                                              AppAssets.whiteBagSvg,
                                                                              width: 15,
                                                                            )
                                                                          : orders[_indexTapPackage].orderGroupStatus?.value == 'delivered'
                                                                              ? SvgPicture.asset(
                                                                                  AppAssets.delivered_bagSvg,
                                                                                  width: 20,
                                                                                )
                                                                              : SvgPicture.asset(
                                                                                  AppAssets.delivered_bagSvg,
                                                                                  width: 15,
                                                                                ),
                                                        ],
                                                      ),
                                                      title: LocaleKeys
                                                          .order_status
                                                          .tr(),
                                                      value: orders[_indexTapPackage]
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
                                                          status: orders[
                                                                      _indexTapPackage]
                                                                  .orderGroupStatus
                                                                  ?.value ??
                                                              ""),
                                                      valueIcons: buildValueIcons(
                                                          status: orders[
                                                                      _indexTapPackage]
                                                                  .orderGroupStatus
                                                                  ?.value ??
                                                              ""),
                                                      currency: '',
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: const BoxDecoration(
                                                color: Color(0xffF4F4F4),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            child: Row(
                                              children: [
                                                ...List.generate(
                                                    orders.length,
                                                    (index) => InkWell(
                                                          onTap: () =>
                                                              indexTapPackage
                                                                      .value =
                                                                  index,
                                                          child: Container(
                                                            height: 30,
                                                            width: (1.sw - 40) /
                                                                (orders.length),
                                                            decoration: BoxDecoration(
                                                                border: index !=
                                                                        _indexTapPackage
                                                                    ? null
                                                                    : Border.all(
                                                                        color: const Color(
                                                                            0xff402CDD)),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            15))),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              "Pack ${orders[index].id}",
                                                              style: index !=
                                                                      _indexTapPackage
                                                                  ? context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.rr
                                                                      .copyWith(
                                                                      color: const Color(
                                                                          0xff5D5C5D),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          12,
                                                                      height:
                                                                          1.3,
                                                                    )
                                                                  : context
                                                                      .textTheme
                                                                      .bodyMedium
                                                                      ?.mr
                                                                      .copyWith(
                                                                      color: const Color(
                                                                          0xff1D1D1D),
                                                                      letterSpacing:
                                                                          0.18,
                                                                      fontSize:
                                                                          12,
                                                                      height:
                                                                          1.3,
                                                                    ),
                                                            ),
                                                          ),
                                                        ))
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          ///////////////////
                                          SizedBox(
                                            height: 85,
                                            child: state.getOrdersByOrderGroupIDStatus ==
                                                    GetOrdersByOrderGroupIDStatus
                                                        .loading
                                                ? TrydosLoader(
                                                    size: 16,
                                                  )
                                                : buildSecondSection(
                                                    context: context,
                                                    expectedDeliveryDate:
                                                        'Monday 2.Jun | 3 Work Days',
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
                                                    deliverdTo: orders[
                                                                _indexTapPackage]
                                                            .shippingAddressData
                                                            ?.contactPersonName ??
                                                        '',
                                                  ),
                                          ),
                                          ///////////////////
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          ///////////////////
                                          orders[_indexTapPackage]
                                                      .orderStatus
                                                      ?.value ==
                                                  "delivered"
                                              ? buildThirdSectionForRating()
                                              : buildThirdSection(
                                                  context: context,
                                                  contactInfo: orders[
                                                              _indexTapPackage]
                                                          .shippingAddressData
                                                          ?.phone ??
                                                      '',
                                                  recipientName: orders[
                                                              _indexTapPackage]
                                                          .shippingAddressData
                                                          ?.contactPersonName ??
                                                      '',
                                                  shippingDeliveryAddress:
                                                      addressString,
                                                ),
                                          ///////////////////
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          ///////////////////
                                          BlocListener<OrderBloc, OrderState>(
                                              listenWhen: (previous, current) =>
                                                  previous
                                                      .orderReturnDetailsStatus !=
                                                  current
                                                      .orderReturnDetailsStatus,
                                              listener: (context, state) {
                                                if (state.orderReturnDetailsStatus ==
                                                        OrderReturnDetailsStatus
                                                            .success &&
                                                    requestReturnApi) {
                                                  requestReturnApi = false;
                                                  HelperFunctions
                                                      .slidingNavigation(
                                                    context,
                                                    OrderDetails2(
                                                      indexGroupe:
                                                          widget.indexGroupe,
                                                      indexPackage:
                                                          _indexTapPackage,
                                                      fromNotification: widget
                                                          .fromNotification,
                                                      order: orders[
                                                          _indexTapPackage],
                                                    ),
                                                  );
                                                }
                                              },
                                              child: BlocBuilder<OrderBloc,
                                                      OrderState>(
                                                  buildWhen: (previous,
                                                          current) =>
                                                      previous
                                                          .orderReturnDetailsStatus !=
                                                      current
                                                          .orderReturnDetailsStatus,
                                                  builder: (context, state) {
                                                    ReturnRequestsDatum?
                                                        orderReturnDetail;

                                                    if (state
                                                            .orderReturnDetailsModel !=
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
                                                            details
                                                                .localPosition
                                                                .dx;
                                                        print(dx);

                                                        if ((dx > (1.sw - 75) &&
                                                            (orders[_indexTapPackage]
                                                                        .orderStatus
                                                                        ?.value ==
                                                                    "out_for_delivery" ||
                                                                (orderReturnDetail !=
                                                                        null
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
                                                          HelperFunctions
                                                              .slidingNavigation(
                                                            context,
                                                            OrderDetails2(
                                                              indexGroupe: widget
                                                                  .indexGroupe,
                                                              indexPackage:
                                                                  _indexTapPackage,
                                                              fromNotification:
                                                                  widget
                                                                      .fromNotification,
                                                              order: orders[
                                                                  _indexTapPackage],
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                        if (orders[_indexTapPackage]
                                                                .orderHasReturnRequest ??
                                                            false) {
                                                          requestReturnApi =
                                                              true;
                                                          if (canFetchReturnDetails) {
                                                            orderBloc.add(
                                                                FetchOrderReturnDetailsEvent(
                                                                    orders[_indexTapPackage]
                                                                            .orderGroupId ??
                                                                        ""));
                                                          }

                                                          return;
                                                        } else {
                                                          requestReturnApi =
                                                              false;
                                                        }
                                                        HelperFunctions
                                                            .slidingNavigation(
                                                          context,
                                                          OrderDetails2(
                                                            indexGroupe: widget
                                                                .indexGroupe,
                                                            indexPackage:
                                                                _indexTapPackage,
                                                            fromNotification: widget
                                                                .fromNotification,
                                                            order: orders[
                                                                _indexTapPackage],
                                                          ),
                                                        );
                                                      },
                                                      child: buildFourthSection(
                                                          context: context,
                                                          itemsCount: orders[
                                                                  _indexTapPackage]
                                                              .details!
                                                              .length
                                                              .toString()),
                                                    );
                                                  })),
                                          ///////////////////
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          ///////////////////
                                          buildFifthSection(
                                              details: orders[_indexTapPackage]
                                                  .details,
                                              orderStatus:
                                                  orders[_indexTapPackage]
                                                          .orderStatus
                                                          ?.value ??
                                                      "",
                                              orderStatusLabel:
                                                  orders[_indexTapPackage]
                                                          .orderStatus
                                                          ?.label ??
                                                      ""),
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
                                shadowForPanel(),
                                panelWidget(),
                                ValueListenableBuilder<int>(
                                    valueListenable: indexTapAddress,
                                    builder: (context, _indexTap, _) {
                                      return shadowForChangeAddressContent(
                                          _indexTap);
                                    }),
                                shadowForCanselOrRutuenOrder(false)
                              ],
                            ),
                          ),
                        );
                      });
                })));
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
                            : LocaleKeys.about_cancel_order.tr(),
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
                      orders[indexTapPackage.value].paymentStatus == "unpaid"
                          ? const SizedBox.shrink()
                          : Text(
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
                                    children: [
                                      SvgPicture.asset(AppAssets.detectedSvg,
                                          color: _agreeToPolicies
                                              ? const Color(0xff388CFF)
                                              : const Color(0xff8E8E8E)),
                                      const SizedBox(
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
                                                  ""),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color:
                                                        agreeToPolicies.value ==
                                                                true
                                                            ? const Color(
                                                                0xff3066CC)
                                                            : const Color(
                                                                0xffC4C2C2),
                                                    border:
                                                        agreeToPolicies.value ==
                                                                true
                                                            ? Border.all(
                                                                color: const Color(
                                                                    0xffF8F8F8),
                                                              )
                                                            : Border.all(
                                                                color: const Color(
                                                                    0xffC4C2C2),
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                              ))
                                          : InkWell(
                                              onTap: () {
                                                if (agreeToPolicies.value ==
                                                    false) {
                                                  return;
                                                }
                                                orderBloc.add(CancelOrderEvent(
                                                  cancelOrderParams:
                                                      CancelOrderParams(
                                                    orderId: orders[
                                                            indexTapPackage
                                                                .value]
                                                        .id
                                                        .toString(),
                                                  ),
                                                ));
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color:
                                                        agreeToPolicies.value ==
                                                                true
                                                            ? const Color(
                                                                0xff3066CC)
                                                            : const Color(
                                                                0xffC4C2C2),
                                                    border:
                                                        agreeToPolicies.value ==
                                                                true
                                                            ? Border.all(
                                                                color: const Color(
                                                                    0xffF8F8F8),
                                                              )
                                                            : Border.all(
                                                                color: const Color(
                                                                    0xffC4C2C2),
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Text(
                                                  LocaleKeys.i_agree_cancel
                                                      .tr(),
                                                  textAlign: TextAlign.center,
                                                  style: context
                                                      .textTheme.bodyMedium?.br
                                                      .copyWith(
                                                    color: Colors.white,
                                                    letterSpacing: 0.18,
                                                    fontSize: 16,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ));
                                    }));
                          }),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        width: 200,
                        height: 40,
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
                                  style:
                                      context.textTheme.bodyMedium?.rr.copyWith(
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
                  ? const SizedBox.shrink()
                  : Container(
                      height: 1.sh,
                      width: 1.sw,
                      color: const Color.fromRGBO(29, 29, 29, 0.95),
                      child: Column(
                        children: [
                          const Spacer(),
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
                              customerAddressesInfo: CustomerAddressesInfo(
                                address: orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.address ??
                                    '',
                                addressDetail: orders[indexTapPackage.value]
                                        .shippingAddressData
                                        ?.addressDetail ??
                                    '',
                                contactInfo: ContactInfo(
                                  alternativePhone:
                                      orders[indexTapPackage.value]
                                              .shippingAddressData
                                              ?.alternativePhone ??
                                          '',
                                  name: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.contactPersonName ??
                                      '',
                                  phone: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.phone ??
                                      '',
                                ),
                                id: orders[indexTapPackage.value]
                                    .shippingAddressData
                                    ?.id,
                                regionDetails: RegionDetails(
                                  building: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.building ??
                                      '',
                                  city: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.city ??
                                      '',
                                  country: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.country ??
                                      '',
                                  province: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.province ??
                                      '',
                                  street: orders[indexTapPackage.value]
                                          .shippingAddressData
                                          ?.street ??
                                      '',
                                  town: orders[indexTapPackage.value]
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
                                        children: [
                                          SvgPicture.asset(
                                              AppAssets.detectedSvg,
                                              color: _agreeToPolicies
                                                  ? const Color(0xff388CFF)
                                                  : const Color(0xff8E8E8E)),
                                          const SizedBox(
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
                                                ""),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24),
                                              alignment: Alignment.center,
                                              width: 1.sw,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: agreeToPolicies
                                                              .value ==
                                                          true
                                                      ? const Color(0xff3066CC)
                                                      : const Color(0xffC4C2C2),
                                                  border:
                                                      agreeToPolicies.value ==
                                                              true
                                                          ? Border.all(
                                                              color: const Color(
                                                                  0xffF8F8F8),
                                                            )
                                                          : Border.all(
                                                              color: const Color(
                                                                  0xffC4C2C2),
                                                            ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                            ))
                                        : InkWell(
                                            onTap: () {
                                              if (agreeToPolicies.value ==
                                                  false) {
                                                return;
                                              }
                                              orderBloc
                                                  .add(ChangeOrderAddressEvent(
                                                changeOrderAddressParams:
                                                    ChangeOrderAddressParams(
                                                  orderGroupId: orders[
                                                              indexTapPackage
                                                                  .value]
                                                          .orderGroupId ??
                                                      "",
                                                  newShippingAddressId: state
                                                          .listOfAddressInfoClassToSave?[
                                                              indexTapAddress
                                                                  .value]
                                                          .id
                                                          .toString() ??
                                                      '',
                                                ),
                                              ));
                                            },
                                            child: ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    agreeToPolicies,
                                                builder: (context,
                                                    _agreeToPolicies, _) {
                                                  return Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24),
                                                    alignment: Alignment.center,
                                                    width: 1.sw,
                                                    height: 50.h,
                                                    decoration: BoxDecoration(
                                                        color: agreeToPolicies
                                                                    .value ==
                                                                true
                                                            ? Colors.white
                                                            : const Color(
                                                                0xffC4C2C2),
                                                        border: agreeToPolicies
                                                                    .value ==
                                                                false
                                                            ? null
                                                            : Border.all(
                                                                color: const Color(
                                                                    0xff402CDD),
                                                              ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Text(
                                                      LocaleKeys.i_agree_change
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: context.textTheme
                                                          .bodyMedium?.br
                                                          .copyWith(
                                                        color: agreeToPolicies
                                                                    .value ==
                                                                true
                                                            ? const Color(
                                                                0xff402CDD)
                                                            : Colors.white,
                                                        letterSpacing: 0.18,
                                                        fontSize: 16,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          );
                                  })),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                              width: 200,
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
                                        showShadowForChangeAddress.value =
                                            false;

                                        showShadowForCanselOrder.value = false;
                                      },
                                      child: Text(
                                        LocaleKeys.i_disagree.tr(),
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium?.rr
                                            .copyWith(
                                          color: Colors.white,
                                          decorationColor: Colors.white,
                                          decoration: TextDecoration.underline,
                                          letterSpacing: 0.18,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    );
                                  })),
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
            color: isChange
                ? const Color.fromRGBO(0, 0, 0, 0)
                : const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
            border: isChange
                ? Border.all(
                    color: (isChange && index != indexTap)
                        ? const Color(0xffD3D3D3)
                        : Colors.white)
                : index != indexTap
                    ? null
                    : Border.all(color: const Color(0xff388CFF))),
        child: Column(
          children: [
            const SizedBox(
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
                        ? const Color(0xffD3D3D3)
                        : (isChange && index == indexTap)
                            ? Colors.white
                            : index != indexTap
                                ? const Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    customerAddressesInfo.address ?? "",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? const Color(0xffD3D3D3)
                            : isChange
                                ? const Color(0xffFFFFFF)
                                : index != indexTap
                                    ? const Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  const Spacer(),
                  isChange
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: onTapEdit,
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
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
                            ? const Color(0xffD3D3D3)
                            : isChange
                                ? const Color(0xffFFFFFF)
                                : index != indexTap
                                    ? const Color(0xff8D8D8D)
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
                            ? const Color(0xffD3D3D3)
                            : isChange
                                ? const Color(0xffFFFFFF)
                                : index != indexTap
                                    ? const Color(0xff8D8D8D)
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
                        ? const Color(0xffD3D3D3)
                        : isChange
                            ? const Color(0xffFFFFFF)
                            : index != indexTap
                                ? const Color(0xff8D8D8D)
                                : const Color(0xff1D1D1D),
                    height: 12,
                    width: 12,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '+${customerAddressesInfo.contactInfo?.phone ?? ""}',
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                        color: (isChange && index != indexTap)
                            ? const Color(0xffD3D3D3)
                            : isChange
                                ? const Color(0xffFFFFFF)
                                : index != indexTap
                                    ? const Color(0xff8D8D8D)
                                    : const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12,
                        height: 1.3),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Container(
                    height: 16,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.personSvg,
                          color: (isChange && index != indexTap)
                              ? const Color(0xffD3D3D3)
                              : isChange
                                  ? const Color(0xffFFFFFF)
                                  : index != indexTap
                                      ? const Color(0xff8D8D8D)
                                      : const Color(0xff1D1D1D),
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${customerAddressesInfo.contactInfo?.name ?? ""}',
                          style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: (isChange && index != indexTap)
                                  ? const Color(0xffD3D3D3)
                                  : isChange
                                      ? const Color(0xffFFFFFF)
                                      : index != indexTap
                                          ? const Color(0xff8D8D8D)
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
                              ? 512
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
                        maxHeight: (_option == null || (_option == "All_Order"))
                            ? 512
                            : (1.sh - 70),
                        panelBuilder: (sc) => panelBuilderContent(_option, sc),
                      ));
                }));
      },
    );
  }

  Widget panelBuilderContent(
    String? _option,
    ScrollController sc,
  ) {
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
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                      color: const Color(0xffC4C2C2),
                      border: Border.all(color: const Color(0xffC4C2C2)),
                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  width: 1.sw,
                  height: 200.h,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      border: Border.all(color: const Color(0xffF8F8F8)),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                        width: 1.sw,
                        height: 16.h,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppAssets.orderClockSvg,
                              height: 15.h,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              HelperFunctions.orderFormatDate(
                                DateTime.tryParse(
                                        orders[_indexTapPackage].createdAt ??
                                            '') ??
                                    DateTime.now(),
                              ),
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            SvgPicture.asset(
                              AppAssets.orderBag1Svg,
                              height: 15.h,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              orders[_indexTapPackage].orderGroupId ?? "",
                              style: context.textTheme.bodyMedium?.mr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(
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
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppAssets.preparingBagSvg,
                              height: 15.h,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              orders[_indexTapPackage]
                                      .orderGroupStatus
                                      ?.label ??
                                  "",
                              style: context.textTheme.bodyMedium?.rr.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              AppAssets.orderPreparingSvg,
                              height: 15.h,
                            ),
                            const Spacer(),
                            SvgPicture.asset(
                              AppAssets.orderInvoice2Svg,
                              height: 15.h,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              (orders[_indexTapPackage].details?.length ?? "")
                                  .toString(),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(
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
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              HelperFunctions.formatNumber(
                                  number:
                                      (orders[_indexTapPackage].orderAmount! *
                                          homeBloc
                                              .state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .exchangeRate!),
                                  isNeedRounding: false),
                              style: context.textTheme.bodyMedium?.br.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(
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
                            const SizedBox(
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
                          itemCount: orders[_indexTapPackage].details?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 125.h,
                              width: 92,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: MyCachedNetworkImage(
                                    imageUrl: orders[_indexTapPackage]
                                            .details?[index]
                                            .image ??
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
                  height: 8.h,
                ),
                SvgPicture.asset(
                  AppAssets.orderCanselSvg,
                  width: 30,
                ),
                SizedBox(
                  height: 14.h,
                ),
                Text("${LocaleKeys.cancel_this_order.tr()}",
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.3,
                    )),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                    "${LocaleKeys.you_can_cancel_product_without_condition.tr()}",
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xffC4C2C2),
                      border: Border.all(color: const Color(0xffC4C2C2)),
                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${LocaleKeys.why_was_order_cancelled.tr()}",
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
        });
  }

  Widget canselContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Row(
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
                    const SizedBox(
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
                const SizedBox(
                  height: 10,
                ),
                Row(
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
                    const SizedBox(
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
                const SizedBox(
                  height: 10,
                ),
                Row(
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
            const Spacer(),
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
            const SizedBox(
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
            const SizedBox(
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
                        : Border.all(color: const Color(0xff402CDD)),
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

  Widget panelAddressContent(ScrollController sc) {
    return BlocListener<OrderBloc, OrderState>(
        listenWhen: (previous, current) =>
            previous.getCustomerAddressStatus !=
            current.getCustomerAddressStatus,
        listener: (context, state) {
          if (state.getCustomerAddressStatus ==
              GetCustomerAddressesStatus.success) {
            indexTapAddress.value = orderBloc.state.listOfAddressInfoClassToSave
                    ?.indexWhere((element) =>
                        element.id ==
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.id) ??
                -1;
            firstAddressChoosed = indexTapAddress.value;
            if (indexTapAddress.value != firstAddressChoosed ||
                (state.listOfAddressInfoClassToSave![indexTapAddress.value].address != orders[indexTapPackage.value].shippingAddressData?.address ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].addressDetail !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.addressDetail ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].contactInfo?.name !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.contactPersonName ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].contactInfo?.phone !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.phone ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].regionDetails?.country !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.country ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].regionDetails?.city !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.city ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].regionDetails?.province !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.province ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].regionDetails?.street !=
                        orders[indexTapPackage.value]
                            .shippingAddressData
                            ?.street ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value]
                            .regionDetails?.building !=
                        orders[indexTapPackage.value].shippingAddressData?.building ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].regionDetails?.town != orders[indexTapPackage.value].shippingAddressData?.town ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].location?.latitude != orders[indexTapPackage.value].shippingAddressData?.latitude ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].location?.longitude != orders[indexTapPackage.value].shippingAddressData?.longitude ||
                    state.listOfAddressInfoClassToSave![indexTapAddress.value].contactInfo?.alternativePhone != orders[indexTapPackage.value].shippingAddressData?.alternativePhone)) {
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
                      return Column(children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                              color: const Color(0xffC4C2C2),
                              border:
                                  Border.all(color: const Color(0xffC4C2C2)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2))),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          width: 1.sw,
                          height: 200.h,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: const Color(0xffF8F8F8),
                              border:
                                  Border.all(color: const Color(0xffF8F8F8)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                width: 1.sw,
                                height: 16.h,
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.orderClockSvg,
                                      height: 15.h,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      HelperFunctions.orderFormatDate(
                                        DateTime.tryParse(
                                                orders[_indexTapPackage]
                                                        .createdAt ??
                                                    '') ??
                                            DateTime.now(),
                                      ),
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const Spacer(),
                                    SvgPicture.asset(
                                      AppAssets.orderBag1Svg,
                                      height: 15.h,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      orders[_indexTapPackage].orderGroupId ??
                                          "",
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
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
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.preparingBagSvg,
                                      height: 15.h,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      orders[_indexTapPackage]
                                              .orderGroupStatus
                                              ?.label ??
                                          "",
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SvgPicture.asset(
                                      AppAssets.orderPreparingSvg,
                                      height: 15.h,
                                    ),
                                    const Spacer(),
                                    SvgPicture.asset(
                                      AppAssets.orderInvoice2Svg,
                                      height: 15.h,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      (orders[_indexTapPackage]
                                                  .details
                                                  ?.length ??
                                              "")
                                          .toString(),
                                      style: context.textTheme.bodyMedium?.br
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      LocaleKeys.item.tr(),
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      HelperFunctions.formatNumber(
                                          number: (orders[_indexTapPackage]
                                                  .orderAmount! *
                                              homeBloc
                                                  .state
                                                  .getCurrencyForCountryModel!
                                                  .data!
                                                  .currency!
                                                  .exchangeRate!),
                                          isNeedRounding: false),
                                      style: context.textTheme.bodyMedium?.br
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      homeBloc.state.getCurrencyForCountryModel!
                                          .data!.currency!.symbol!,
                                      style: context.textTheme.bodyMedium?.rr
                                          .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        letterSpacing: 0.18,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
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
                                    left: LanguageService.languageCode == "ar"
                                        ? 0
                                        : 10,
                                    right: LanguageService.languageCode != "ar"
                                        ? 0
                                        : 10),
                                child: ListView.builder(
                                  itemCount:
                                      orders[_indexTapPackage].details?.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: 125.h,
                                      width: 92,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                        child: MyCachedNetworkImage(
                                            imageUrl: orders[_indexTapPackage]
                                                    .details?[index]
                                                    .image ??
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
                          LocaleKeys
                              .you_can_change_delivery_address_delivery_note
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
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                              color: const Color(0xffC4C2C2),
                              border:
                                  Border.all(color: const Color(0xffC4C2C2)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2))),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 24),
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
                });
          },
        ));
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
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 50.h,
              width: 1.sw,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                  color: Color(0xffF8F8F8),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 50.h,
                    width: ((1.sw - 58) / 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xff402CDD)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
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
                    decoration: const BoxDecoration(
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
            state.getCustomerAddressStatus ==
                        GetCustomerAddressesStatus.loading ||
                    state.addAddressToOrderStatus ==
                        AddAddressToOrderStatus.loading ||
                    state.removeAddressToOrderStatus ==
                        RemoveAddressToOrderStatus.loading ||
                    state.editAddressToOrderStatus ==
                        EditAddressToOrderStatus.loading
                ? TrydosLoader(
                    size: 16,
                  )
                : Text(
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
            state.getCustomerAddressStatus ==
                        GetCustomerAddressesStatus.loading ||
                    state.addAddressToOrderStatus ==
                        AddAddressToOrderStatus.loading ||
                    state.removeAddressToOrderStatus ==
                        RemoveAddressToOrderStatus.loading ||
                    state.editAddressToOrderStatus ==
                        EditAddressToOrderStatus.loading
                ? const SizedBox.shrink()
                : Container(
                    height: 295.h,
                    width: 1.sw,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemBuilder: (context, index) => index ==
                              state.listOfAddressInfoClassToSave!.length
                          ? InkWell(
                              onTap: () {
                                // panelController.close();
                                HelperFunctions.slidingNavigation(
                                    context, const AddShippingAdress());
                              },
                              child: Container(
                                height: 40,
                                width: 1.sw,
                                decoration: BoxDecoration(
                                    color: const Color(0xffE8FFED),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: const Color(0xffC4C2C2))),
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
                                              AppAssets
                                                  .addShippingAddressWhiteSvg,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
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
                                if (index != firstAddressChoosed ||
                                    (state.listOfAddressInfoClassToSave![index].address != orders[indexTapPackage.value].shippingAddressData?.address ||
                                        state.listOfAddressInfoClassToSave![index].addressDetail !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.addressDetail ||
                                        state.listOfAddressInfoClassToSave![index].contactInfo?.name !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.contactPersonName ||
                                        state.listOfAddressInfoClassToSave![index].contactInfo?.phone !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.phone ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.country !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.country ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.city !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.city ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.province !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.province ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.street !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.street ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.building !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.building ||
                                        state.listOfAddressInfoClassToSave![index].regionDetails?.town !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.town ||
                                        state.listOfAddressInfoClassToSave![index].location?.latitude !=
                                            orders[indexTapPackage.value]
                                                .shippingAddressData
                                                ?.latitude ||
                                        state.listOfAddressInfoClassToSave![index].location?.longitude != orders[indexTapPackage.value].shippingAddressData?.longitude ||
                                        state.listOfAddressInfoClassToSave![index].contactInfo?.alternativePhone != orders[indexTapPackage.value].shippingAddressData?.alternativePhone)) {
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
                                      addressInfoClassToEdid: state
                                          .listOfAddressInfoClassToSave![index],
                                      fromEdid: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: state.listOfAddressInfoClassToSave!.length + 1,
                      controller: sc,
                    ),
                  ),
          ],
        ));
  }

  Widget optionsForAllOrder() {
    return ValueListenableBuilder<int>(
        valueListenable: indexTapPackage,
        builder: (context, _indexTapPackage, _) {
          return Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                    color: const Color(0xffC4C2C2),
                    border: Border.all(color: const Color(0xffC4C2C2)),
                    borderRadius: const BorderRadius.all(Radius.circular(2))),
              ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                width: 1.sw,
                height: 200.h,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    border: Border.all(color: const Color(0xffF8F8F8)),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: 1.sw,
                      height: 16.h,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(
                            AppAssets.orderClockSvg,
                            height: 15.h,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            HelperFunctions.orderFormatDate(
                              DateTime.tryParse(
                                      orders[_indexTapPackage].createdAt ??
                                          '') ??
                                  DateTime.now(),
                            ),
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            AppAssets.orderBag1Svg,
                            height: 15.h,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            orders[_indexTapPackage].orderGroupId ?? "",
                            style: context.textTheme.bodyMedium?.mr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(
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
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(
                            AppAssets.preparingBagSvg,
                            height: 15.h,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            orders[_indexTapPackage].orderGroupStatus?.label ??
                                "",
                            style: context.textTheme.bodyMedium?.rr.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SvgPicture.asset(
                            AppAssets.orderPreparingSvg,
                            height: 15.h,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            AppAssets.orderInvoice2Svg,
                            height: 15.h,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            (orders[_indexTapPackage].details?.length ?? "")
                                .toString(),
                            style: context.textTheme.bodyMedium?.br.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(
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
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            HelperFunctions.formatNumber(
                                number: (orders[_indexTapPackage].orderAmount! *
                                    homeBloc.state.getCurrencyForCountryModel!
                                        .data!.currency!.exchangeRate!),
                                isNeedRounding: false),
                            style: context.textTheme.bodyMedium?.br.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(
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
                          const SizedBox(
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
                        itemCount: orders[_indexTapPackage].details?.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 125.h,
                            width: 92,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: MyCachedNetworkImage(
                                  imageUrl: orders[_indexTapPackage]
                                          .details?[index]
                                          .image ??
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
              const SizedBox(
                height: 10,
              ),
              Text("${LocaleKeys.action_about_order.tr()}",
                  style: context.textTheme.bodyMedium?.rr.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 1.sw,
                height: 0.5,
                decoration: BoxDecoration(
                    color: const Color(0xffC4C2C2),
                    border: Border.all(color: const Color(0xffC4C2C2)),
                    borderRadius: const BorderRadius.all(Radius.circular(2))),
              ),
              SizedBox(
                height: 30.h,
              ),
              orders[_indexTapPackage].canUpdateAddress ?? false
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: optionOfModify(
                          onTap: () {
                            orderBloc.add(const ResetAllStatusEvent());
                            optionModifyPanel.value = "Change_Address";
                          },
                          svg: AppAssets.orderChangeAddressSvg,
                          image2: "",
                          tiltle: "${LocaleKeys.change_delivery_address.tr()}",
                          body:
                              "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}"),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () {
                      orderBloc.add(const ResetAllStatusEvent());
                      optionModifyPanel.value = "Hide_This_Product";
                    },
                    svg: AppAssets.hideThisProductSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.hide_this_product.tr()}",
                    body: "${LocaleKeys.hide_this_product_from_list.tr()}"),
              ),
              const SizedBox(
                height: 8,
              ),
              (orders[_indexTapPackage].canCanceleOrder ?? false)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: optionOfModify(
                          onTap: () {
                            orderBloc.add(const ResetAllStatusEvent());
                            optionModifyPanel.value = "Cancel_This_Order";
                          },
                          svg: AppAssets.orderCanselSvg,
                          image2: "",
                          tiltle: "${LocaleKeys.cancel_this_order.tr()}",
                          body: LocaleKeys.cancel_order_hours_back_money
                              .tr(args: ['3'])),
                    )
                  : const SizedBox.shrink(),
            ],
          );
        });
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
                          ? const SizedBox.shrink()
                          : image2.split(".").last != "svg"
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
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
                const SizedBox(height: 2),
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

  Widget shadowForPanel() {
    return ValueListenableBuilder<bool>(
        valueListenable: showShadowForPanel,
        builder: (context, isShowShadowForPanel, _) {
          return !isShowShadowForPanel
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    showShadowForPanel.value = false;
                    Future.delayed(
                      const Duration(microseconds: 300),
                      () {
                        panelController.close();
                        showShadowForPanel.value = false;
                      },
                    );
                  },
                  child: Container(
                    height: 1.sh,
                    width: 1.sw,
                    color: const Color.fromRGBO(29, 29, 29, 0.6),
                  ),
                );
        });
  }

  Widget buildFifthSection(
      {required List<OrderListDetailModel>? details,
      required String orderStatus,
      required String orderStatusLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: orderStatus == 'delivered' ? 190 : 180,
        child: ListView.separated(
          itemCount: details?.length ?? 0,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: MyCachedNetworkImage(
                      imageUrl: details?[index].image ?? '',
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
                orderStatus == 'delivered'
                    ? SvgPicture.asset(
                        AppAssets.delivered_bagSvg,
                        width: 13,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            orderStatus == 'shipped'
                                ? AppAssets.shippedAndOutOfDeliveryBagSvg
                                : AppAssets.preparingBagSvg,
                            width: 13,
                          ),
                          //////////////////////////
                          const SizedBox(
                            width: 2,
                          ),
                          //////////////////////////
                          SvgPicture.asset(
                            orderStatus == 'shipped'
                                ? AppAssets.shippedBlackSvg
                                : orderStatus == 'delivered'
                                    ? AppAssets.deliveredBlackSvg
                                    : orderStatus == 'pending'
                                        ? AppAssets.pendeingBlackCheck
                                        : AppAssets.orderPreparingSvg,
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
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                const SizedBox(
                  height: 2,
                ),
                ///////////////////
                orderStatus == 'delivered'
                    ? BlocListener<OrderBloc, OrderState>(
                        listenWhen: (previous, current) =>
                            previous.addOrderCommentStatus !=
                                current.addOrderCommentStatus ||
                            previous.updateOrderCommentStatus !=
                                current.updateOrderCommentStatus,
                        listener: (context, state) {
                          if (state.addOrderCommentStatus ==
                                  AddOrderCommentStatus.success ||
                              state.updateOrderCommentStatus ==
                                  UpdateOrderCommentStatus.success) {
                            GetIt.I<OrderBloc>()
                                .add(GetOrdersByOrderGroupIDEvent(
                              getWithRating: true,
                              orderGroupId:
                                  orders[indexTapPackage.value].orderGroupId ??
                                      '',
                            ));
                          }
                        },
                        child: BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.addOrderCommentStatus !=
                                    current.addOrderCommentStatus ||
                                previous.updateOrderCommentStatus !=
                                    current.updateOrderCommentStatus ||
                                previous.getOrdersByOrderGroupIDStatus !=
                                    current.getOrdersByOrderGroupIDStatus,
                            builder: (context, state) {
                              return state.getOrdersByOrderGroupIDStatus ==
                                          GetOrdersByOrderGroupIDStatus
                                              .loadingForRating ||
                                      state.updateOrderCommentStatus ==
                                          UpdateOrderCommentStatus.loading ||
                                      state.addOrderCommentStatus ==
                                          AddOrderCommentStatus.loading
                                  ? Center(
                                      child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: SizedBox(
                                        width: 80,
                                        height: 16,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (index) => Container(
                                              width: 16,
                                              height: 16,
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  AppAssets.starOutlineSvg,
                                                  width: 14,
                                                  height: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                  : Center(
                                      child: StarRatingWidget(
                                        initialRating: (details?[index]
                                                    .comments
                                                    .isNullOrEmpty ??
                                                false)
                                            ? 0
                                            : details?[index]
                                                        .comments
                                                        ?.first
                                                        .starRating ==
                                                    null
                                                ? 0
                                                : double.parse(details?[index]
                                                        .comments
                                                        ?.first
                                                        .starRating ??
                                                    '0'),
                                        onRatingChanged: (rating, comment) {
                                          if (details?[index]
                                                  .comments
                                                  .isNullOrEmpty ??
                                              false) {
                                            GetIt.I<OrderBloc>().add(
                                                AddOrderCommentEvent(
                                                    params:
                                                        AddOrderCommentParams(
                                              orderDetailsId: details?[index]
                                                      .id
                                                      .toString() ??
                                                  '',
                                              productId: details?[index]
                                                      .productId
                                                      .toString() ??
                                                  '',
                                              customerId:
                                                  GetIt.I<PrefsRepository>()
                                                      .myMarketId
                                                      .toString(),
                                              starRating: rating.toString(),
                                              comment: comment,
                                            )));
                                          } else {
                                            if (details?[index]
                                                    .comments
                                                    ?.first
                                                    .id ==
                                                null) {
                                            } else {
                                              GetIt.I<OrderBloc>().add(
                                                  UpdateOrderCommentEvent(
                                                      params:
                                                          UpdateOrderCommentParams(
                                                orderDetailsId: details?[index]
                                                        .id
                                                        .toString() ??
                                                    '',
                                                id: details?[index]
                                                        .comments
                                                        ?.first
                                                        .id
                                                        .toString() ??
                                                    '',
                                                comment: comment,
                                                productId: details?[index]
                                                        .productId
                                                        .toString() ??
                                                    '',
                                                customerId:
                                                    GetIt.I<PrefsRepository>()
                                                        .myMarketId
                                                        .toString(),
                                                starRating: rating.toString(),
                                              )));
                                            }
                                          }
                                        },
                                      ),
                                    );
                            }))
                    : Text(
                        (details?[index].variation.isNullOrEmpty ?? false)
                            ? ''
                            : details?[index].variation?[0].color ?? '',
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
    return BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (previous, current) =>
            previous.orderReturnDetailsStatus !=
            current.orderReturnDetailsStatus,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: state.orderReturnDetailsStatus ==
                    OrderReturnDetailsStatus.loading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      alignment: Alignment.center,
                      width: 1.sw,
                      height: 74,
                      decoration: BoxDecoration(
                          color: const Color(0xffC4C2C2),
                          border: Border.all(
                            color: const Color(0xffC4C2C2),
                          ),
                          borderRadius: BorderRadius.circular(15)),
                    ))
                : Container(
                    height: 74,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 237, 237),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(8),
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
                            const SizedBox(
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
                            const SizedBox(
                              height: 2,
                            ),
                            ///////////////////
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style:
                                    context.textTheme.bodyMedium?.rq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: itemsCount,
                                    style: context.textTheme.bodyMedium?.bq
                                        .copyWith(
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
                        const Spacer(),
                        ValueListenableBuilder<int>(
                            valueListenable: indexTapPackage,
                            builder: (context, _indexTapPackage, _) {
                              ReturnRequestsDatum? orderReturnDetail;

                              if (state.orderReturnDetailsModel != null) {
                                if (state.orderReturnDetailsModel!.data
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

                              return (orders[_indexTapPackage]
                                                  .orderStatus
                                                  ?.value !=
                                              "out_for_delivery" &&
                                          orderReturnDetail?.status?.value !=
                                              "out_for_return") &&
                                      (!widget.fromNotification)
                                  ? const SizedBox.shrink()
                                  : Container(
                                      width: 105,
                                      height: 40,
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
                                                  ));
                                                }
                                              });
                                            }

                                            if (state
                                                    .getOrderRecipientIdStatus ==
                                                GetOrderRecipientIdStatus
                                                    .success) {
                                              String receiverName = "DW";
                                              String fullReceiverName =
                                                  "Delivery Worker";
                                              String? recipientUserId =
                                                  state.recipientUserId;
                                              print(
                                                  "recipientUserId $recipientUserId");
                                              if (recipientUserId == null) {
                                                return;
                                              }
                                              Chat? chat;
                                              User? receiver;
                                              List<Chat> chats = List.of(
                                                  GetIt.I<ChatBloc>()
                                                      .state
                                                      .chats);
                                              debugPrint(chats.toString());
                                              chats.addAll(GetIt.I<ChatBloc>()
                                                  .state
                                                  .pinnedChats);
                                              chat = chats.firstWhere(
                                                  (element) => element
                                                          .channelMembers!
                                                          .any((element) {
                                                        return element.userId
                                                                .toString() ==
                                                            recipientUserId;
                                                      }));
                                              final preferences =
                                                  GetIt.I<PrefsRepository>();
                                              receiver = chat.channelMembers
                                                  ?.firstWhere(
                                                    (element) =>
                                                        element.userId !=
                                                        preferences.myChatId,
                                                    orElse: () => ChannelMember(
                                                        userId: int.tryParse(
                                                            recipientUserId),
                                                        user: User(
                                                            id: int.tryParse(
                                                                recipientUserId),
                                                            name:
                                                                receiverName)),
                                                  )
                                                  .user;
                                              String fromOrder = "true";
                                              context.go(GRouter
                                                      .config
                                                      .applicationRoutes
                                                      .kSinglePageChatPagePath +
                                                  '?chatId=${chat.id!.toString()}&fromOrder=$fromOrder&receiverName=$receiverName&fullReceiverName=${fullReceiverName}&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}&senderName=${HelperFunctions.getTheFirstTwoLettersOfName(GetIt.I<PrefsRepository>().myChatName!)}');
                                            }
                                            // TODO: implement listener
                                          },
                                          child:
                                              BlocBuilder<ChatBloc, ChatState>(
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
                                                  width: 30,
                                                  height: 30,
                                                  child: TrydosLoader(
                                                    size: 16,
                                                  ),
                                                );
                                              }
                                              return Container(
                                                alignment: Alignment.center,
                                                width: 70,
                                                height: 30,
                                                child: InkWell(
                                                    onTap: () {
                                                      chatBloc.add(
                                                          GetOrderRecipientIdEvent(
                                                              originalUserId: GetIt.I<
                                                                      PrefsRepository>()
                                                                  .myMarketId
                                                                  .toString(),
                                                              orderId: orderReturnDetail ==
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
                                                                          .toString()));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          AppAssets
                                                              .chatMarkActiveSvg,
                                                          width: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          LocaleKeys
                                                              .chat_with_delivery_person
                                                              .tr(),
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.rr
                                                              .copyWith(
                                                            color: const Color(
                                                                0xff1D1D1D),
                                                            fontSize: 9,
                                                            height: 1.3,
                                                            letterSpacing: 0.18,
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              );
                                            },
                                          )),
                                    );
                            }),
                      ],
                    ),
                  ),
          );
        });
  }

  Widget buildThirdSectionForRating() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 158,
      width: 1.sw,
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xff402CDD)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SvgPicture.asset(
          AppAssets.groupStarsRattingSvg,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          LocaleKeys.rate_and_get_money.tr(),
          style: context.textTheme.bodyMedium?.mr.copyWith(
            color: const Color(0xff1D1D1D),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.3,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          LocaleKeys.rating_section_description.tr(),
          style: context.textTheme.bodyMedium?.rr.copyWith(
            color: const Color(0xff5D5C5D),
            letterSpacing: 0.18,
            fontSize: 10,
            height: 1.3,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              alignment: Alignment.center,
              width: 290.w,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff402CDD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.groupStarsRattingSvg,
                    color: const Color(0xffFFD800),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    LocaleKeys.rate_and_get_money.tr(),
                    style: context.textTheme.bodyMedium?.mr.copyWith(
                      fontSize: 14,
                      height: 1.7,
                      color: const Color(0xffFFD800),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  SvgPicture.asset(
                    AppAssets.groupStarsRattingSvg,
                    color: const Color(0xffFFD800),
                  ),
                ],
              ))
        ])
      ]),
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
          color: const Color(0xffF4F4F4),
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
            const SizedBox(
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
            const SizedBox(
              height: 4,
            ),
            ///////////////////
            BlocBuilder<OrderBloc, OrderState>(
              buildWhen: (previous, current) =>
                  previous.getOrdersByOrderGroupIDStatus !=
                  current.getOrdersByOrderGroupIDStatus,
              builder: (context, state) {
                return state.getOrdersByOrderGroupIDStatus ==
                        GetOrdersByOrderGroupIDStatus.loading
                    ? TrydosLoader(
                        size: 16,
                      )
                    : Text(
                        shippingDeliveryAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff8D8D8D),
                          letterSpacing: 0.18,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      );
              },
            ),
            ///////////////////
            const SizedBox(
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
            const SizedBox(
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
            const SizedBox(
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
            const SizedBox(
              height: 4,
            ),
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
                  fontSize: 12,
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
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  orderStatus == 'canceled'
                      ? SvgPicture.asset(
                          AppAssets.orderCanselSvg,
                          width: 20,
                        )
                      : orderStatus == 'pending'
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
                  orderStatus == 'canceled'
                      ? const SizedBox.shrink()
                      : orderStatus == 'pending'
                          ? SvgPicture.asset(
                              AppAssets.whiteBagSvg,
                              width: 15,
                            )
                          : orderStatus == 'preparing'
                              ? SvgPicture.asset(
                                  AppAssets.preparingBagSvg,
                                  width: 20,
                                )
                              : SvgPicture.asset(
                                  AppAssets.preparingBagSvg,
                                  width: 15,
                                ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  orderStatus == 'canceled'
                      ? const SizedBox.shrink()
                      : orderStatus == 'pending'
                          ? SvgPicture.asset(
                              AppAssets.whiteBagSvg,
                              width: 15,
                            )
                          : orderStatus == 'preparing'
                              ? SvgPicture.asset(
                                  AppAssets.whiteBagSvg,
                                  width: 15,
                                )
                              : orderStatus == 'shipped'
                                  ? SvgPicture.asset(
                                      AppAssets.shippedAndOutOfDeliveryBagSvg,
                                      width: 20,
                                    )
                                  : SvgPicture.asset(
                                      AppAssets.shippedAndOutOfDeliveryBagSvg,
                                      width: 15,
                                    ),
                  ////////////////////
                  const SizedBox(
                    width: 3,
                  ),
                  ///////////////////
                  orderStatus == 'canceled'
                      ? const SizedBox.shrink()
                      : orderStatus == 'pending'
                          ? SvgPicture.asset(
                              AppAssets.whiteBagSvg,
                              width: 15,
                            )
                          : orderStatus == 'preparing'
                              ? SvgPicture.asset(
                                  AppAssets.whiteBagSvg,
                                  width: 15,
                                )
                              : orderStatus == 'shipped'
                                  ? SvgPicture.asset(
                                      AppAssets.whiteBagSvg,
                                      width: 15,
                                    )
                                  : orderStatus == 'delivered'
                                      ? SvgPicture.asset(
                                          AppAssets.delivered_bagSvg,
                                          width: 20,
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.delivered_bagSvg,
                                          width: 15,
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

  Widget buildTitleIcons({
    required String status,
  }) {
    if (status == 'pending')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.pendingBlueCheckSvg,
            width: 15,
          ),
        ],
      );
    else if (status == 'preparing')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingBlueSvg,
            width: 15,
          ),
        ],
      );
    else
      return const SizedBox.shrink();
  }

  Widget buildValueIcons({
    required String status,
  }) {
    if (status == 'pending')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.pendeingBlackCheck,
            width: 15,
          ),
        ],
      );
    else if (status == 'preparing')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingBlackSvg,
            width: 15,
          ),
          /////////////////////////////
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingGreySvg,
            width: 15,
          ),
          /////////////////////////////
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.preparingGrey2Svg,
            width: 15,
          ),
        ],
      );
    else if (status == 'shipped')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedBlackSvg,
            width: 15,
          ),
          /////////////////////////////
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedGreySvg,
            width: 15,
          ),
          /////////////////////////////
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.shippedGrey_2Svg,
            width: 15,
          ),
        ],
      );
    if (status == 'delivered')
      return Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          //////////////////////////
          SvgPicture.asset(
            AppAssets.deliveredBlackSvg,
            width: 15,
          ),
        ],
      );
    else
      return const SizedBox.shrink();
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
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
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
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
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
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
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
                    fontSize: 10,
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
                          fontSize: 12,
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
