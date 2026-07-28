import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import '../../../../../common/constant/constant.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../data/models/get_hidden_orders_model.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_state.dart';
import '../../manager/orderBloc/order_bloc.dart';
import '../../manager/orderBloc/order_event.dart';
import '../../manager/orderBloc/order_state.dart';

class HiddenOrdersPage extends StatefulWidget {
  const HiddenOrdersPage({super.key});

  @override
  State<HiddenOrdersPage> createState() => _HiddenOrdersPageState();
}

class _HiddenOrdersPageState extends State<HiddenOrdersPage> {
  late OrderBloc orderBloc;

  /// Local, immediate loading flag flipped the instant a restore is confirmed —
  /// so the shimmer shows right away without waiting for the bloc round-trip
  /// (HydratedBloc serializes the whole state on each emit, which can add a
  /// small delay before the first restore-loading state reaches the UI).
  final ValueNotifier<bool> _restoring = ValueNotifier(false);

  @override
  void initState() {
    LastPagesTracker.push("Hidden Orders Page");
    orderBloc = BlocProvider.of<OrderBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _restoring.dispose();
    super.dispose();
  }

  void _restore(VoidCallback dispatch) {
    _restoring.value = true;
    dispatch();
  }

  /// Groups the flat hidden-orders list by `order_group_id`, preserving order.
  List<List<HiddenOrderModel>> _groupByOrderGroupId(
    List<HiddenOrderModel> orders,
  ) {
    final List<List<HiddenOrderModel>> groups = [];
    final Map<String, int> indexByGroupId = {};
    for (final order in orders) {
      final String groupId = order.orderGroupId ?? '${order.id}';
      if (indexByGroupId.containsKey(groupId)) {
        groups[indexByGroupId[groupId]!].add(order);
      } else {
        indexByGroupId[groupId] = groups.length;
        groups.add([order]);
      }
    }
    return groups;
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
                    SvgPicture.asset(AppAssets.eyeSvg, width: 20.w),
                    SizedBox(width: 6.w),
                    Text(
                      LocaleKeys.hidden_orders.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(width: 15.w),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 12.h),
              _buildHint(),
              SizedBox(height: 12.h),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _restoring,
                  builder: (context, restoring, _) {
                    return BlocConsumer<OrderBloc, OrderState>(
                      listenWhen: (p, c) =>
                          p.getHiddenOrdersStatus != c.getHiddenOrdersStatus ||
                          p.restoreOrderVisibilityStatus !=
                              c.restoreOrderVisibilityStatus,
                      listener: (context, state) {
                        // Once the bloc owns the loading indication (or the
                        // restore failed), drop the local flag so there is no
                        // double state to reconcile.
                        final bool blocTookOver =
                            state.restoreOrderVisibilityStatus ==
                                    RestoreOrderVisibilityStatus.loading ||
                                state.getHiddenOrdersStatus ==
                                    GetHiddenOrdersStatus.loading;
                        final bool failed =
                            state.restoreOrderVisibilityStatus ==
                                RestoreOrderVisibilityStatus.failure;
                        if (_restoring.value && (blocTookOver || failed)) {
                          _restoring.value = false;
                        }
                      },
                      buildWhen: (p, c) =>
                          p.getHiddenOrdersStatus != c.getHiddenOrdersStatus ||
                          p.getHiddenOrdersModel != c.getHiddenOrdersModel ||
                          p.restoreOrderVisibilityStatus !=
                              c.restoreOrderVisibilityStatus,
                      builder: (context, state) {
                        // Shimmer immediately on tap (local flag), and kept
                        // through the restore PATCH and the hidden-list
                        // re-fetch, so there is no gap after Confirm.
                        if (restoring ||
                            state.getHiddenOrdersStatus ==
                                GetHiddenOrdersStatus.loading ||
                            state.getHiddenOrdersStatus ==
                                GetHiddenOrdersStatus.init ||
                            state.restoreOrderVisibilityStatus ==
                                RestoreOrderVisibilityStatus.loading) {
                          return _buildShimmerList();
                        }
                        final List<HiddenOrderModel> orders =
                            state.getHiddenOrdersModel?.data ?? [];
                        if (orders.isEmpty) {
                          return Center(
                            child: Text(
                              LocaleKeys.there_are_no_orders.tr(),
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                            ),
                          );
                        }
                        final List<List<HiddenOrderModel>> groups =
                            _groupByOrderGroupId(orders);
                        return ListView.separated(
                          padding: EdgeInsets.only(bottom: 20.h),
                          itemCount: groups.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, index) =>
                              _buildGroupCard(groups[index]),
                        );
                      },
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

  Widget _buildHint() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xffF3F6FF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffD9E2FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.w, color: const Color(0xff388CFF)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              LocaleKeys.hidden_orders_hint.tr(),
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff8D8D8D),
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: const Color(0xffF7F7F7),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<HiddenOrderModel> group) {
    final HiddenOrderModel first = group.first;
    // Flatten all products of the group, keeping the owning order with each.
    final List<_HiddenCell> cells = [];
    for (final order in group) {
      for (final detail in order.details ?? <HiddenOrderDetailModel>[]) {
        cells.add(_HiddenCell(order: order, detail: detail));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              isSecondInfo: false,
              isTextSpan: false,
              text1: HelperFunctions.orderFormatDate(
                DateTime.tryParse(first.createdAt ?? '') ?? DateTime.now(),
              ),
              text2: first.orderGroupId ?? '',
              svgIcon1: AppAssets.orderClockSvg,
              svgIcon2: AppAssets.orderBag1Svg,
              amount: '',
              currency: '',
              itemsCount: '',
            ),
            SizedBox(height: 11.h),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (p, c) =>
                  p.getCurrencyForCountryModel != c.getCurrencyForCountryModel,
              builder: (context, state) {
                final currency =
                    state.getCurrencyForCountryModel?.data?.currency;
                final String currencySymbol = currency?.symbol ?? "";
                double orderAmount = 0;
                for (final order in group) {
                  orderAmount +=
                      HelperFunctions.truncateToDecimalPlaces(
                        order.orderAmount ?? 0,
                        currency?.decimalDigits ?? 0,
                      ) *
                      (currency?.exchangeRate ?? 1);
                }
                return _buildInfoRow(
                  isSecondInfo: true,
                  isTextSpan: true,
                  text1: first.orderGroupStatus?.label ?? '',
                  text2: '',
                  svgIcon1: _statusIcon(first.orderGroupStatus?.value),
                  svgIcon2: AppAssets.orderInvoice2Svg,
                  secondInfoSvgIcon: _statusSecondaryIcon(
                    first.orderGroupStatus?.value,
                  ),
                  amount: HelperFunctions.formatNumber(
                    numberToFormate: orderAmount,
                    isNeedRounding: false,
                  ),
                  currency: currencySymbol,
                  itemsCount: cells.length.toString(),
                );
              },
            ),
            SizedBox(height: 11.h),
            SizedBox(
              height: 125.h,
              width: double.infinity,
              child: ListView.separated(
                itemCount: cells.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 5.w),
                itemBuilder: (context, index) =>
                    _buildProductCell(cells[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCell(_HiddenCell cell) {
    final bool orderHidden = cell.order.isHidden ?? false;
    final bool detailHidden = cell.detail.isHidden ?? false;
    final bool showEye = orderHidden || detailHidden;

    final Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        color: Colors.white,
        child: MyCachedNetworkImage(
          imageUrl: cell.detail.image ?? '',
          imageFit: BoxFit.contain,
          width: 90.w,
          height: 125.h,
        ),
      ),
    );

    if (!showEye) return image;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.55, child: image),
        InkWell(
          onTap: () {
            if (orderHidden) {
              _showRestoreConfirmDialog(
                title: LocaleKeys.restore_this_order.tr(),
                body: LocaleKeys.are_you_sure_restore_this_order.tr(),
                onConfirm: () => _restore(
                  () => orderBloc.add(
                    RestoreOrderEvent(
                      orderId: cell.order.id?.toString() ?? '',
                    ),
                  ),
                ),
              );
            } else {
              _showRestoreConfirmDialog(
                title: LocaleKeys.restore_this_product.tr(),
                body: LocaleKeys.are_you_sure_restore_this_product.tr(),
                onConfirm: () => _restore(
                  () => orderBloc.add(
                    RestoreProductEvent(
                      detailId: cell.detail.id?.toString() ?? '',
                    ),
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(AppAssets.eyeSvg, width: 22.w),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required bool isSecondInfo,
    required String svgIcon1,
    required String svgIcon2,
    String? secondInfoSvgIcon,
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
                SizedBox(width: 5.w),
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
                isSecondInfo ? SizedBox(width: 5.w) : const SizedBox.shrink(),
                isSecondInfo
                    ? SvgPicture.asset(secondInfoSvgIcon ?? '', width: 15.w)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(svgIcon2, width: 15.w),
                SizedBox(width: 5.w),
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
                                      fontSize: 12.sp,
                                    ),
                              ),
                              TextSpan(text: ' ${LocaleKeys.item.tr()} . '),
                              TextSpan(
                                text: amount,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      fontSize: 12.sp,
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

  String _statusIcon(String? value) {
    switch (value) {
      case 'canceled':
        return "";
      case 'pending':
        return AppAssets.pendingBagSvg;
      case 'preparing':
        return AppAssets.preparingBagSvg;
      case 'shipped':
        return AppAssets.shippedAndOutOfDeliveryBagSvg;
      default:
        return AppAssets.delivered_bagSvg;
    }
  }

  String _statusSecondaryIcon(String? value) {
    if (value == 'shipped') return AppAssets.shippedBlackSvg;
    if (value == 'delivered' || (value ?? "").contains("return")) {
      return AppAssets.deliveredBlackSvg;
    }
    if (value == 'pending') return AppAssets.pendeingBlackCheck;
    if (value == 'canceled') return AppAssets.orderCanselSvg;
    return AppAssets.orderPreparingSvg;
  }

  void _showRestoreConfirmDialog({
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
}

class _HiddenCell {
  final HiddenOrderModel order;
  final HiddenOrderDetailModel detail;

  _HiddenCell({required this.order, required this.detail});
}
