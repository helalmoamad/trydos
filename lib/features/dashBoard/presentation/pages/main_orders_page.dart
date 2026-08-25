import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/dashBoard/presentation/pages/order_details_page.dart';
import 'package:trydos/features/dashBoard/presentation/widgets/order_status.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/common/helper/dev_log.dart';

class MainOrdersPage extends StatefulWidget {
  const MainOrdersPage({super.key});

  @override
  State<MainOrdersPage> createState() => _MainOrdersPageState();
}

class _MainOrdersPageState extends State<MainOrdersPage> {
  Timer? debounce;
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = context.read<DashboardBloc>();
    _dashboardBloc.ordersStatus = '';
    _dashboardBloc.add(NewGetOrdersEvent());
  }

  final ScrollController ordersScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      SvgPicture.asset(AppAssets.bagsSvg, width: 23),
                      ///////////////////////////
                      const SizedBox(width: 4),
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
                      const SizedBox(width: 15),
                      ///////////////////////////
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            body: Column(
              children: [
                ///////////////////
                buildStatusBar(),
                ///////////////////
                SizedBox(height: 25.h),
                ///////////////////
                Expanded(
                  child: BlocBuilder<DashboardBloc, DashBoardState>(
                    builder: (context, state) {
                      if (state.newGetOrdersStatus ==
                          NewGetOrdersStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 🔴 Failure
                      if (state.newGetOrdersStatus ==
                          NewGetOrdersStatus.failure) {
                        return Center(
                          child: Text(LocaleKeys.something_went_wrong.tr()),
                        );
                      }

                      // 🟢 Success
                      if (state.newGetOrdersStatus ==
                          NewGetOrdersStatus.success) {
                        final ordersList = state.new_orders ?? [];

                        if (ordersList.isEmpty) {
                          return Center(child: Text(LocaleKeys.no_orders_found.tr()));
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ListView.separated(
                            itemCount: ordersList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsNew(
                                        orderNumber:
                                            '00${ordersList[index].id}',
                                        orders: ordersList[index],
                                        indexGroupe: index,
                                      ),
                                    ),
                                  );
                                },
                                child: buildOrderItemWidget(
                                  context: context,
                                  item: ordersList[index],
                                  indexInGroup: index + 1,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10.h),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOrderItemWidget({
    required BuildContext context,
    required UserOrderNew item,
    required int indexInGroup,
  }) {
    final details = item.details;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            buildInfoWidget(
              context: context,
              isSecondInfo: false,
              isTextSpan: false,
              orderGroupId: indexInGroup.toString(),
              text1:
                  item.createdAt.date +
                  ' | ' +
                  (item.createdAt.time) +
                  ' | Remain ' +
                  item.remainingInMinutes.toString() +
                  'm',
              text2: '00' + indexInGroup.toString(),
              svgIcon1: AppAssets.orderClockSvg,
              svgIcon2: AppAssets.orderBag1Svg,
              amount: '',
              currency: '',
              itemsCount: '',
            ),
            const SizedBox(height: 11),
            buildInfoWidget(
              context: context,
              isSecondInfo: true,
              isTextSpan: true,
              orderGroupId: item.id.toString(),
              text1: item.orderStatus,
              text2: '',
              svgIcon1: AppAssets.cartCart,
              svgIcon2: AppAssets.orderInvoice2Svg,
              secondInfoSvgIcon: AppAssets.pendeingBlackCheck,
              amount: item.orderAmount.toString(),
              currency: 'USD',
              itemsCount: details.length.toString(),
            ),
            const SizedBox(height: 11),
            SizedBox(
              height: 125,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: details.length,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MyCachedNetworkImage(
                      imageUrl: details[index].cartImage,
                      width: 91,
                      height: 125,
                      imageFit: BoxFit.cover,
                      radius: 15,
                    ),
                  );
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
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                svgIcon1 == ""
                    ? const SizedBox.shrink()
                    : SvgPicture.asset(svgIcon1, width: 15),
                ///////////////////////////
                const SizedBox(width: 2),
                ///////////////////////////
                Flexible(
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
                    ? const SizedBox(width: 5)
                    : const SizedBox.shrink(),
                ///////////////////
                isSecondInfo
                    ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          /////////////////////////
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(svgIcon2, width: 15),
                ///////////////////////////
                const SizedBox(width: 5),
                ///////////////////////////
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
                                text: itemsCount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
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

  ////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  final ValueNotifier<ConstOrderStatus> currentStatusOfOrder = ValueNotifier(
    ConstOrderStatus.all,
  );

  Widget buildStatusBar() {
    return ValueListenableBuilder<ConstOrderStatus>(
      valueListenable: currentStatusOfOrder,
      builder: (context, _currentStatus, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: SizedBox(
            height: 26,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ConstOrderStatus.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SvgPicture.asset(
                    AppAssets.orderStatusFilterSvg,
                    width: 25,
                  );
                }

                final status = ConstOrderStatus.values[index - 1];
                final bool isSelected = _currentStatus == status;

                return InkWell(
                  onTap: () {
                    currentStatusOfOrder.value = status;
                    final String statusForApi = status.apiValue;
                    _dashboardBloc.ordersStatus = statusForApi;
                    devLog('Selected status: ${_dashboardBloc.ordersStatus}');
                    _dashboardBloc.add(NewGetOrdersEvent());
                  },
                  child: Container(
                    height: 26,
                    width: status == ConstOrderStatus.all ? 60 : 130,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff388CFF)
                            : const Color(0xffF8F8F8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getStatusLabel(status),
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
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
              separatorBuilder: (context, index) => const SizedBox(width: 10),
            ),
          ),
        );
      },
    );
  }
}
