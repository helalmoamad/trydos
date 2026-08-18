import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:shimmer/shimmer.dart';

import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../../../../../common/constant/constant.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../core/data/model/pagination_model.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../../app/my_cached_network_image.dart';
import '../../../data/models/get_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import '../../manager/orderBloc/order_state.dart';
import 'hidden_orders_page.dart';
import 'order_details1_page.dart';

class OrdersPage extends StatefulWidget {
  final bool? fromNotification;
  final String? groupId;
  final String? orderIdFormNotification;
  final String? parentOrderIdFormNotification;
  OrdersPage({
    super.key,
    this.parentOrderIdFormNotification,
    this.groupId,
    this.orderIdFormNotification,
    this.fromNotification,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrderBloc orderBloc;

  Timer? debounce;
  final ScrollController ordersScrollController = ScrollController();

  final ValueNotifier<String> currentStatus = ValueNotifier('');
  bool requestReturnApiFromNotification = true;
  @override
  void initState() {
    LastPagesTracker.push("Orders Page");
    orderBloc = BlocProvider.of<OrderBloc>(context);
    orderBloc.add(GetCustomerAddressesEvent());
    if (widget.fromNotification ?? false) {
      orderBloc.add(GetOrdersEvent(getWithPagination: false, status: ""));

      orderBloc.add(
        GetOrdersByOrderGroupIDEvent(orderGroupId: widget.groupId ?? ""),
      );
    }
    ordersScrollController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }
      debounce = Timer(const Duration(milliseconds: 600), () {
        if (ordersScrollController.offset >=
            (ordersScrollController.position.maxScrollExtent * 0.6)) {
          debugPrint('scrollController');
          orderBloc.add(
            GetOrdersEvent(
              status: currentStatus.value,
              getWithPagination: true,
            ),
          );
        }
      });
    });

    super.initState();
  }

  void _openActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (_) => _HiddenOrdersSheet(orderBloc: orderBloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffFFFFFF),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
                    SvgPicture.asset(AppAssets.bagsSvg, width: 23.w),
                    ///////////////////////////
                    SizedBox(width: 4.w),
                    ///////////////////////////
                    Text(
                      LocaleKeys.orders.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
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
                InkWell(
                  onTap: _openActionsSheet,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w, left: 4.w),
                    child: Icon(
                      Icons.more_vert,
                      color: const Color(0xff1D1D1D),
                      size: 22.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 10.h),
              ///////////////////
              buildStatusBar(),
              ///////////////////
              SizedBox(height: 20.h),
              ///////////////////
              BlocListener<OrderBloc, OrderState>(
                listenWhen: (p, c) =>
                    p.getOrdersByOrderGroupIDStatus !=
                    c.getOrdersByOrderGroupIDStatus,
                listener: (context, state) {
                  if ((widget.fromNotification ?? false) &&
                      state.getOrdersByOrderGroupIDStatus ==
                          GetOrdersByOrderGroupIDStatus.success &&
                      requestReturnApiFromNotification) {
                    requestReturnApiFromNotification = false;

                    if (state.getOrdersByOrderGroupIDModel?.orders?.first !=
                        null) {
                      List<OrderListModel> order =
                          state.getOrdersByOrderGroupIDModel!.orders ?? [];

                      Future.delayed(
                        const Duration(milliseconds: 50),
                        () => Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    OrderDetails1(
                                      currentStatus: currentStatus.value,
                                      orderIdFormNotification:
                                          widget.orderIdFormNotification,
                                      parentOrderIdFormNotification:
                                          widget.parentOrderIdFormNotification,
                                      fromNotification: true,
                                      orders: order,
                                    ),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: BlocBuilder<OrderBloc, OrderState>(
                  buildWhen: (p, c) =>
                      p
                              .getOrdersModel?[currentStatus.value]
                              ?.paginationStatus !=
                          c
                              .getOrdersModel?[currentStatus.value]
                              ?.paginationStatus ||
                      p.getOrdersByOrderGroupIDStatus !=
                          c.getOrdersByOrderGroupIDStatus,
                  builder: (context, state) {
                    int itemsCount =
                        state.getOrdersModel?[currentStatus.value] == null
                        ? 0
                        : state
                              .getOrdersModel![currentStatus.value]!
                              .items
                              .length;
                    List<List<OrderListModel>> items =
                        state.getOrdersModel?[currentStatus.value]?.items ?? [];
                    return (state.getOrdersModel?[currentStatus.value] ==
                                null ||
                            state.getOrdersByCartGroupIDStatus ==
                                GetOrdersByOrderGroupIDStatus.loading ||
                            state
                                    .getOrdersModel?[currentStatus.value]
                                    ?.paginationStatus ==
                                PaginationStatus.failure ||
                            ((state
                                            .getOrdersModel?[currentStatus
                                                .value]
                                            ?.paginationStatus ==
                                        PaginationStatus.loading ||
                                    state
                                            .getOrdersModel?[currentStatus
                                                .value]
                                            ?.paginationStatus ==
                                        PaginationStatus.initial) &&
                                state
                                        .getOrdersModel?[currentStatus.value]
                                        ?.items
                                        .length ==
                                    0))
                        ? Center(child: TrydosLoader())
                        : items.isEmpty
                        ? Text(
                            LocaleKeys.there_are_no_orders.tr(),
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ListView.separated(
                                controller: ordersScrollController,
                                itemCount: itemsCount + 1,
                                itemBuilder: (context, index) {
                                  if (index < itemsCount) {
                                    return InkWell(
                                      onTap: () {
                                        /*  final double dy =
                                                            details.localPosition.dy;
                                                        if (dy < 80 &&
                                                            ((items[index]
                                                                        .statusIsOutForDelivary ??
                                                                    false) ||
                                                                items[index]
                                                                        .orderStatus
                                                                        ?.value ==
                                                                    "out_for_delivery")) {
                                                          return;
                                                        }*/

                                        HelperFunctions.slidingNavigation(
                                          context,
                                          OrderDetails1(
                                            indexGroupe: index,
                                            currentStatus: currentStatus.value,
                                            orders: items[index],
                                          ),
                                        );
                                      },
                                      child: buildOrderItemWidget(
                                        index: index,
                                        context: context,
                                        item: items[index],
                                      ),
                                    );
                                  } else {
                                    if (itemsCount > 4) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                        ),
                                        child:
                                            state
                                                .getOrdersModel![currentStatus
                                                    .value]!
                                                .hasReachedMax
                                            ? Center(
                                                child: Text(
                                                  LocaleKeys.no_orders_found
                                                      .tr(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff8D8D8D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        fontSize: 15.sp,
                                                        height: 1.3,
                                                      ),
                                                ),
                                              )
                                            : Center(child: TrydosLoader()),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10.h);
                                },
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderItemWidget({
    required BuildContext context,
    required List<OrderListModel> item,
    required int index,
  }) {
    List<OrderListDetailModel> details = [];
    item.forEach((element) => details.addAll(element.details ?? []));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            buildInfoWidget(
              isSecondInfo: false,
              orderGroupId: item[0].orderGroupId.toString(),
              isTextSpan: false,
              context: context,
              text1: HelperFunctions.orderFormatDate(
                DateTime.parse(item[0].createdAt ?? ''),
              ),
              text2: item[0].orderGroupId ?? '',
              svgIcon1: AppAssets.orderClockSvg,
              svgIcon2: AppAssets.orderBag1Svg,
              amount: '',
              currency: '',
              itemsCount: '',
            ),
            ///////////////////
            SizedBox(height: 11.h),
            ///////////////////
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  (previous.getCurrencyForCountryModel !=
                  current.getCurrencyForCountryModel),
              builder: (context, state) {
                String currencySymbol =
                    state.getCurrencyForCountryModel!.data!.currency!.symbol ??
                    "";
                double orderAmount = 0;
                item.forEach(
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

                return buildInfoWidget(
                  isSecondInfo: true,
                  orderGroupId: item[0].orderGroupId.toString(),
                  context: context,
                  isTextSpan: true,
                  text1: item[0].orderGroupStatus!.label ?? '',
                  text2: '',
                  svgIcon1: item[0].orderGroupStatus?.value == 'canceled'
                      ? ""
                      : item[0].orderGroupStatus?.value == 'pending'
                      ? AppAssets.pendingBagSvg
                      : item[0].orderGroupStatus?.value == 'preparing'
                      ? AppAssets.preparingBagSvg
                      : item[0].orderGroupStatus?.value == 'shipped'
                      ? AppAssets.shippedAndOutOfDeliveryBagSvg
                      : AppAssets.delivered_bagSvg,
                  svgIcon2: AppAssets.orderInvoice2Svg,
                  secondInfoSvgIcon:
                      item[0].orderGroupStatus?.value == 'shipped'
                      ? AppAssets.shippedBlackSvg
                      : item[0].orderGroupStatus?.value == 'delivered' ||
                            (item[0].orderGroupStatus?.value ?? "").contains(
                              "return",
                            )
                      ? AppAssets.deliveredBlackSvg
                      : item[0].orderGroupStatus?.value == 'pending'
                      ? AppAssets.pendeingBlackCheck
                      : item[0].orderGroupStatus?.value == 'canceled'
                      ? AppAssets.orderCanselSvg
                      : AppAssets.orderPreparingSvg,
                  amount: HelperFunctions.formatNumber(
                    numberToFormate: orderAmount,
                    isNeedRounding: false,
                  ),
                  currency: currencySymbol,
                  itemsCount: details.length.toString(),
                );
              },
            ),
            ///////////////////
            SizedBox(height: 11.h),

            ///////////////////
            SizedBox(
              height: 125.h,
              width: double.infinity,
              child: ListView.separated(
                itemCount: details.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        HelperFunctions.slidingNavigation(
                          context,
                          OrderDetails1(
                            indexGroupe: index,
                            orderIdToOpenPackage: details[index].orderId
                                .toString(),
                            currentStatus: currentStatus.value,
                            orders: item,
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.white,
                        child: MyCachedNetworkImage(
                          imageUrl: details[index].image ?? '',
                          imageFit: BoxFit.contain,
                          width: 90.w,
                          height: 125.h,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 5.w);
                },
              ),
            ),
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
    required String orderGroupId,
    required String text1,
    required String text2,
    required bool isTextSpan,
    required String itemsCount,
    required String amount,
    required String currency,
  }) {
    return SizedBox(
      height: 16.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                svgIcon1 == ""
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(svgIcon1, width: 15.w),
                ///////////////////////////
                SizedBox(width: 5.w),
                ///////////////////////////
                Flexible(
                  child: Text(
                    text1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                  ),
                ),
                ////////////////////////////
                isSecondInfo ? SizedBox(width: 5.w) : const SizedBox.shrink(),
                ///////////////////
                isSecondInfo
                    ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15.w)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          /////////////////////////
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(svgIcon2, width: 15.w),
                ///////////////////////////
                SizedBox(width: 5.w),
                ///////////////////////////
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
                                text: itemsCount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height: 1.3,
                                    ),
                              ),
                              TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
                              TextSpan(
                                text: amount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
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
                    : Flexible(
                        child: Text(
                          text2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
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
    return ValueListenableBuilder<String>(
      valueListenable: currentStatus,
      builder: (context, _currentStatus, _) {
        orderBloc.add(
          SaveCurrentOrederStatusEvent(currentOrderStatus: _currentStatus),
        );
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getStartingSettingsStatus !=
              current.getStartingSettingsStatus,
          builder: (context, state) {
            List<String> orderStatuseValue = state
                .startingSetting!
                .orderGroupStatuses!
                .map((e) => e.value ?? '')
                .toList();
            List<String> orderStatuseLabel = state
                .startingSetting!
                .orderGroupStatuses!
                .map((e) => e.label ?? '')
                .toList();
            return (state.startingSetting == null)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w),
                    child: SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10.h),
                              height: 40.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 247, 247, 247),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 5.w);
                        },
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w),
                    child: SizedBox(
                      height: 26.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: orderStatuseValue.length + 2,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? SvgPicture.asset(
                                  AppAssets.orderStatusFilterSvg,
                                  width: 25.w,
                                )
                              : index == 1
                              ? InkWell(
                                  onTap: () {
                                    currentStatus.value = '';
                                    ////////////////////////
                                    orderBloc.add(
                                      GetOrdersEvent(
                                        status: '',
                                        getWithPagination: false,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 26.h,
                                    width: 34.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF8F8F8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: _currentStatus == ''
                                          ? Border.all(
                                              color: const Color(0xff388CFF),
                                            )
                                          : Border.all(
                                              color: const Color(0xffF8F8F8),
                                            ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        LocaleKeys.all.tr(),
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 12.sp,
                                              height: 1.3,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    currentStatus.value =
                                        orderStatuseValue[index - 2];
                                    ////////////////////////
                                    orderBloc.add(
                                      GetOrdersEvent(
                                        status: orderStatuseValue[index - 2],
                                        getWithPagination: false,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 26.h,
                                    width: 130.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF8F8F8),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          _currentStatus ==
                                              orderStatuseValue[index - 2]
                                          ? Border.all(
                                              color: const Color(0xff388CFF),
                                            )
                                          : Border.all(
                                              color: const Color(0xffF8F8F8),
                                            ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        orderStatuseLabel[index - 2],
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 12.sp,
                                              height: 1.3,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 10.w);
                        },
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}

/// Bottom sheet opened from the Orders page three-dots menu. Fetches the hidden
/// orders (showing shimmer on the tile while loading) and, on success, opens the
/// Hidden Orders page.
class _HiddenOrdersSheet extends StatefulWidget {
  final OrderBloc orderBloc;

  const _HiddenOrdersSheet({required this.orderBloc});

  @override
  State<_HiddenOrdersSheet> createState() => _HiddenOrdersSheetState();
}

class _HiddenOrdersSheetState extends State<_HiddenOrdersSheet> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xffC4C2C2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.action_about_your_orders.tr(),
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
            color: const Color(0xffC4C2C2),
          ),
          SizedBox(height: 16.h),
          BlocConsumer<OrderBloc, OrderState>(
            bloc: widget.orderBloc,
            listenWhen: (p, c) =>
                p.getHiddenOrdersStatus != c.getHiddenOrdersStatus,
            listener: (context, state) {
              if (!_requested) return;
              if (state.getHiddenOrdersStatus ==
                  GetHiddenOrdersStatus.success) {
                _requested = false;
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => const HiddenOrdersPage(),
                  ),
                );
              } else if (state.getHiddenOrdersStatus ==
                  GetHiddenOrdersStatus.failure) {
                _requested = false;
              }
            },
            builder: (context, state) {
              final bool loading = _requested &&
                  state.getHiddenOrdersStatus == GetHiddenOrdersStatus.loading;
              final Widget tile = _buildTileContent();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: InkWell(
                  onTap: loading
                      ? null
                      : () {
                          setState(() => _requested = true);
                          widget.orderBloc.add(const GetHiddenOrdersEvent());
                        },
                  child: loading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: tile,
                        )
                      : tile,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTileContent() {
    return Container(
      width: 1.sw,
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: const Color(0xffF8F8F8),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          SvgPicture.asset(AppAssets.eyeSvg, width: 26.w),
          SizedBox(width: 15.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.hidden_orders.tr(),
                style: context.textTheme.bodyMedium?.mq.copyWith(
                  color: const Color(0xff1D1D1D),
                  letterSpacing: 0.18,
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                LocaleKeys.see_orders_and_products_you_hid.tr(),
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
    );
  }
}
