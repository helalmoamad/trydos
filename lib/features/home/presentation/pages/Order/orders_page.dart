import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/pages/single_page_chat.dart';
import 'package:trydos/routes/router.dart';
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
import 'order_details1_page.dart';

class OrdersPage extends StatefulWidget {
  bool? fromNotification;
  final String? groupId;
  final String? orderIdFormNotification;
  OrdersPage(
      {super.key,
      this.groupId,
      this.orderIdFormNotification,
      this.fromNotification});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrderBloc orderBloc;

  Timer? debounce;
  final ScrollController ordersScrollController = ScrollController();

  final ValueNotifier<String> currentStatus = ValueNotifier('');

  @override
  void initState() {
    orderBloc = BlocProvider.of<OrderBloc>(context);

    if (widget.fromNotification ?? false) {
      orderBloc.add(
        GetOrdersEvent(getWithPagination: false, status: ""),
      );

      orderBloc.add(
        GetOrdersByOrderGroupIDEvent(orderGroupId: widget.groupId ?? ""),
      );
    }
    ordersScrollController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }
      debounce = Timer(Duration(milliseconds: 600), () {
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
                Spacer(),
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
                      LocaleKeys.orders.tr(),
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
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 11.h,
              ),
              ///////////////////
              buildStatusBar(),
              ///////////////////
              SizedBox(
                height: 50.h,
              ),
              ///////////////////
              BlocListener<OrderBloc, OrderState>(
                listenWhen: (p, c) =>
                    p.getOrdersByOrderGroupIDStatus !=
                    c.getOrdersByOrderGroupIDStatus,
                listener: (context, state) {
                  if ((widget.fromNotification ?? false) &&
                      state.getOrdersByOrderGroupIDStatus ==
                          GetOrdersByOrderGroupIDStatus.success) {
                    widget.fromNotification = false;

                    if (state.getOrdersByOrderGroupIDModel?.orders?.first !=
                        null) {
                      List<OrderListModel> order =
                          state.getOrdersByOrderGroupIDModel!.orders ?? [];

                      Future.delayed(
                          Duration(milliseconds: 50),
                          () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      OrderDetails1(
                                          currentStatus: currentStatus.value,
                                          orderIdFormNotification:
                                              widget.orderIdFormNotification,
                                          fromNotification: true,
                                          orders: order))));
                    }
                  }
                },
                child: BlocBuilder<OrderBloc, OrderState>(
                  buildWhen: (p, c) =>
                      p.getOrdersModel?[currentStatus.value]
                              ?.paginationStatus !=
                          c.getOrdersModel?[currentStatus.value]
                              ?.paginationStatus ||
                      p.getOrdersByOrderGroupIDStatus !=
                          c.getOrdersByOrderGroupIDStatus,
                  builder: (context, state) {
                    int itemsCount =
                        state.getOrdersModel?[currentStatus.value] == null
                            ? 0
                            : state.getOrdersModel![currentStatus.value]!.items
                                .length;
                    List<List<OrderListModel>> items =
                        state.getOrdersModel?[currentStatus.value]?.items ?? [];
                    return (state.getOrdersModel?[currentStatus.value] ==
                                null ||
                            state.getOrdersByCartGroupIDStatus ==
                                GetOrdersByOrderGroupIDStatus.loading ||
                            state.getOrdersModel?[currentStatus.value]
                                    ?.paginationStatus ==
                                PaginationStatus.failure ||
                            ((state.getOrdersModel?[currentStatus.value]
                                            ?.paginationStatus ==
                                        PaginationStatus.loading ||
                                    state.getOrdersModel?[currentStatus.value]
                                            ?.paginationStatus ==
                                        PaginationStatus.initial) &&
                                state.getOrdersModel?[currentStatus.value]
                                        ?.items.length ==
                                    0))
                        ? Center(
                            child: TrydosLoader(),
                          )
                        : items.isEmpty
                            ? Text(
                                LocaleKeys.there_are_no_orders.tr(),
                                overflow: TextOverflow.ellipsis,
                                style:
                                    context.textTheme.bodyMedium?.rq.copyWith(
                                  color: const Color(0xff1D1D1D),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
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
                                                  currentStatus:
                                                      currentStatus.value,
                                                  orders: items[index]),
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: state
                                                    .getOrdersModel![
                                                        currentStatus.value]!
                                                    .hasReachedMax
                                                ? Center(
                                                    child: Text(
                                                      LocaleKeys.no_orders_found
                                                          .tr(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: context.textTheme
                                                          .bodyMedium?.bq
                                                          .copyWith(
                                                        color: const Color(
                                                            0xff8D8D8D),
                                                        letterSpacing: 0.18,
                                                        fontSize: 15,
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
                                      return SizedBox(
                                        height: 10.h,
                                      );
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
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
            const SizedBox(
              height: 11,
            ),
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
                item.forEach((element) => orderAmount = orderAmount +
                    (element.orderAmount! *
                        state.getCurrencyForCountryModel!.data!.currency!
                            .exchangeRate!));

                return buildInfoWidget(
                  isSecondInfo: true,
                  orderGroupId: item[0].orderGroupId.toString(),
                  context: context,
                  isTextSpan: true,
                  text1: item[0].orderGroupStatus!.label ?? '',
                  text2: '',
                  svgIcon1: AppAssets.preparingBagSvg,
                  svgIcon2: AppAssets.orderInvoice2Svg,
                  secondInfoSvgIcon:
                      item[0].orderGroupStatus?.label == 'Shipped'
                          ? AppAssets.shippedBlackSvg
                          : item[0].orderGroupStatus?.label == 'Delivered'
                              ? AppAssets.deliveredBlackSvg
                              : item[0].orderGroupStatus?.label == 'Pending'
                                  ? AppAssets.pendeingBlackCheck
                                  : AppAssets.orderPreparingSvg,
                  amount: orderAmount.toStringAsFixed(
                      state.startingSetting?.decimalPointSettings ?? 0),
                  currency: currencySymbol,
                  itemsCount: details.length.toString(),
                );
              },
            ),
            ///////////////////
            const SizedBox(
              height: 11,
            ),
            ///////////////////

            SizedBox(
              height: 125,
              width: double.infinity,
              child: ListView.separated(
                itemCount: details.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  print(
                      "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII${details[index].image}");
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white,
                      child: MyCachedNetworkImage(
                        imageUrl: details[index].image ?? '',
                        imageFit: BoxFit.contain,
                        width: 90,
                        height: 125,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 5,
                  );
                },
              ),
            )
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
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  svgIcon1,
                  width: 15,
                ),
                ///////////////////////////
                const SizedBox(
                  width: 5,
                ),
                ///////////////////////////
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    text1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                ////////////////////////////
                isSecondInfo
                    ? const SizedBox(
                        width: 5,
                      )
                    : const SizedBox.shrink(),
                ///////////////////
                isSecondInfo
                    ? SvgPicture.asset(
                        secondInfoSvgIcon ?? '',
                        width: 15,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          /////////////////////////
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  svgIcon2,
                  width: 15,
                ),
                ///////////////////////////
                SizedBox(
                  width: 5,
                ),
                ///////////////////////////
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
                                text: itemsCount,
                                style:
                                    context.textTheme.bodyMedium?.bq.copyWith(
                                  color: const Color(0xff505050),
                                  letterSpacing: 0.18,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
                              TextSpan(
                                text: amount,
                                style:
                                    context.textTheme.bodyMedium?.bq.copyWith(
                                  color: const Color(0xff505050),
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
                          text2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12,
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
            SaveCurrentOrederStatusEvent(currentOrederStatus: _currentStatus));
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getStartingSettingsStatus !=
              current.getStartingSettingsStatus,
          builder: (context, state) {
            List<String> orderStatuseValue =
                state.startingSetting!.orderGroupStatuses!
                    .map(
                      (e) => e.value ?? '',
                    )
                    .toList();
            List<String> orderStatuseLabel =
                state.startingSetting!.orderGroupStatuses!
                    .map(
                      (e) => e.label ?? '',
                    )
                    .toList();
            return (state.startingSetting == null)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                            enabled: true,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10.h),
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 247, 247, 247),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: 5,
                          );
                        },
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: SizedBox(
                      height: 26,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: orderStatuseValue.length + 2,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? SvgPicture.asset(
                                  AppAssets.orderStatusFilterSvg,
                                  width: 25,
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
                                        height: 26,
                                        width: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF8F8F8),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: _currentStatus == ''
                                              ? Border.all(
                                                  color:
                                                      const Color(0xff388CFF),
                                                )
                                              : Border.all(
                                                  color:
                                                      const Color(0xffF8F8F8),
                                                ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            LocaleKeys.all.tr(),
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
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
                                            status:
                                                orderStatuseValue[index - 2],
                                            getWithPagination: false,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 26,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF8F8F8),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: _currentStatus ==
                                                  orderStatuseValue[index - 2]
                                              ? Border.all(
                                                  color:
                                                      const Color(0xff388CFF),
                                                )
                                              : Border.all(
                                                  color:
                                                      const Color(0xffF8F8F8),
                                                ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            orderStatuseLabel[index - 2],
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .textTheme.bodyMedium?.rq
                                                .copyWith(
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: 10,
                          );
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
