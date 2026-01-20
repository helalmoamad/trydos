import 'dart:io';

import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/gallery_and_camera_dialog_widget.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/home/data/models/color_size_for_product.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_order_details_return_model.dart';
import 'package:trydos/features/home/data/models/return_reasons_model.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_order_item_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_order_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_return_request_product_usecase.dart';

import 'package:trydos/features/home/domain/use_cases/change_order_address_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/change_order_item_variant_usecase.dart';

import 'package:trydos/features/home/domain/use_cases/store_return_request_product_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/store_return_request_usecase.dart';
import 'package:trydos/features/home/domain/use_cases/update_return_request_product_usecase.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart'
    show OrderBloc;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/pages/Order/order_status.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/add_shipping_address.dart';

import 'package:trydos/features/search/presentation/widgets/search_image_preview_widget.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/main.dart';
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
  const OrderDetails2({
    super.key,
    required this.order,
    required this.indexPackage,
    required this.indexGroupe,
    this.currentStatus = "",
  });
  final String? currentStatus;

  final int indexGroupe;
  final int indexPackage;
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
  final ValueNotifier<bool> showShadowForConfirmOrder = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForCancelAllOrder = ValueNotifier(false);
  final ValueNotifier<bool> visiblecamera = ValueNotifier(false);
  final ValueNotifier<List<String>> orderPhotos = ValueNotifier([]);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final ValueNotifier<List<String>> optionCansel = ValueNotifier([]);
  final ValueNotifier<int> optionReturn = ValueNotifier(0);
  final ValueNotifier<bool> shadowForChangeVariant = ValueNotifier(false);

  // final ValueNotifier<bool> showShadowForChangeSize = ValueNotifier(false);
  final ValueNotifier<bool> enableChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> variantHasBeenChanged = ValueNotifier(false);
  final ValueNotifier<int> indexTapAddress = ValueNotifier(0);
  final ValueNotifier<int> indexTap = ValueNotifier(0);
  final ValueNotifier<int?> colorIndexTap = ValueNotifier(null);
  final ValueNotifier<int?> sizeIndexTap = ValueNotifier(null);
  final ValueNotifier<int> returnBottomIndexTap = ValueNotifier(0);
  final ValueNotifier<double> reasonCost = ValueNotifier(0);
  final ValueNotifier<int> qtyOfReturnValueNotifier = ValueNotifier(0);
  final ValueNotifier<String?> optionVariant = ValueNotifier(null);
  bool allOrder = false;
  late OrderBloc orderBloc;
  late HomeBloc homeBloc;
  int firstAddressChoosed = 0;
  OrderListModel? order;
  List<ProductColor> productColors = [];
  List<ProductSyncColorImage> productSyncColorImages = [];
  List<ProductChoiceOption> productChoiceOptions = [];
  String? firstColorNum;
  String? firstColorOption;
  String? firstVariant;
  String? firstSizeOption;
  String? firstColorName;
  String? firstSizeName;
  ReturnRequestsDatum? returnRequestsData;
  List<ReturnOrderDetail> orderDetails = [];
  List<String> returnRequestIdsToConfirm = [];
  List<String> returnRequestIdsToCancel = [];
  final ValueNotifier<int> qtyToChangeController = ValueNotifier(0);
  // TextEditingController qtyOfReturnController = TextEditingController();
  @override
  void initState() {
    LastPagesTracker.push("OrderDetails2 Page");
    order = widget.order;

    orderBloc = BlocProvider.of<OrderBloc>(context);
    orderBloc.add(const GetReturnReasonsEvent());

    homeBloc = BlocProvider.of<HomeBloc>(context);
    indexTapAddress.value =
        orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
          (element) => element.id == order?.shippingAddressData?.id,
        ) ??
        -1;
    firstAddressChoosed = indexTapAddress.value;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    qtyToChangeController.dispose();
    // qtyOfReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //bool _isLoading = false;

    /* Future<void> _refreshData() async {
      setState(() {
        _isLoading = true; // بدء التحميل
      });
      orderBloc.add(
        GetOrdersByOrderGroupIDEvent(
            orderGroupId: widget.order.orderGroupId ?? ""),
      );

      // 🚀 إزالة التأخير المصطنع - دع البيانات تحدد سرعة التحميل!
      await Future.delayed(Duration(seconds: 3)); // ❌ تم حذف التأخير المصطنع

      setState(() {
        _isLoading = false; // إنهاء التحميل
      });
    }*/
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
          return false;
        }
        // didCallOnWillPop = true;
        orderBloc.add(ChangeOrderByGroupStatus());
        try {
          if (panelController.isPanelOpen) {
            agreeToPolicies.value = false;
            panelController.close();
            showPanel.value = false;
            optionModifyPanel.value = null;
            optionReturn.value = 0;
            reasonCost.value = 0;
            reasonCost.value = 0;
            qtyOfReturnValueNotifier.value = 0;
            qtyToChangeController.value = 0;
            //  qtyOfReturnController.clear();
            optionCansel.value = [];
            enableChangeAddress.value = false;
            showShadowForPanel.value = false;

            showShadowForChangeAddress.value = false;
            showShadowForCancelAllOrder.value = false;
            showShadowForConfirmOrder.value = false;
            showShadowForCanselOrder.value = false;
            shadowForChangeVariant.value = false;
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
          if (state.getOrdersByOrderGroupIDStatus ==
              GetOrdersByOrderGroupIDStatus.success) {
            if (order?.orderGroupId ==
                state
                    .getOrdersByOrderGroupIDModel
                    ?.orders?[widget.indexPackage]
                    .orderGroupId) {
              orderBloc.add(
                GetOrdersEvent(
                  index: widget.indexGroupe,
                  orders: state.getOrdersByOrderGroupIDModel?.orders ?? [],
                  status: widget.currentStatus ?? '',
                  getWithPagination: false,
                ),
              );
              order = state
                  .getOrdersByOrderGroupIDModel
                  ?.orders?[widget.indexPackage];
              indexTapAddress.value =
                  orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
                    (element) => element.id == order!.shippingAddressData?.id,
                  ) ??
                  -1;
              firstAddressChoosed = indexTapAddress.value;
            }
          }
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          buildWhen: (p, c) =>
              p.getOrdersByOrderGroupIDStatus !=
              c.getOrdersByOrderGroupIDStatus,
          builder: (context, state) {
            return Container(
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
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 12),
                                SvgPicture.asset(AppAssets.bagsSvg, width: 23),
                                ///////////////////////////
                                const SizedBox(width: 4),
                                ///////////////////////////
                                Text(
                                  LocaleKeys.order_details.tr(),
                                  style: context.textTheme.bodyMedium?.mq
                                      .copyWith(
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
                            ////////////
                            InkWell(
                              onTap: () {
                                if (state
                                        .getOrdersModel?[widget.currentStatus]
                                        ?.paginationStatus ==
                                    PaginationStatus.loading) {
                                  return;
                                }
                                allOrder = true;
                                optionModifyPanel.value = "All_Order";
                                showPanel.value = true;
                                panelController.open();
                                showShadowForPanel.value = true;
                              },
                              child: Container(
                                width: 40,
                                height: 20,
                                child:
                                    state.getOrdersByOrderGroupIDStatus ==
                                        GetOrdersByOrderGroupIDStatus.loading
                                    ? TrydosLoader(size: 16)
                                    : SvgPicture.asset(
                                        AppAssets.orderMenuSvg,
                                        width: 20,
                                      ),
                              ),
                            ),
                            ///////////////////////////
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                      body: Column(
                        children: [
                          SizedBox(height: 11.h),
                          ///////////////////
                          buildFirstSection(
                            context,
                            order!.details!.length.toString(),
                          ),
                          ///////////////////
                          SizedBox(height: 10.h),
                          ///////////////////
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 10,
                                        width: 60,
                                        color: Colors.black,
                                      ),
                                      ///////////////////
                                      const SizedBox(height: 5),
                                      ///////////////////
                                      BlocBuilder<HomeBloc, HomeState>(
                                        buildWhen: (previous, current) =>
                                            (previous
                                                .getCurrencyForCountryModel !=
                                            current.getCurrencyForCountryModel),
                                        builder: (context, state) {
                                          String currencySymbol =
                                              state
                                                  .getCurrencyForCountryModel!
                                                  .data!
                                                  .currency!
                                                  .symbol ??
                                              "";
                                          String
                                          orderAmount = HelperFunctions.formatNumber(
                                            numberToFormate:
                                                (HelperFunctions.truncateToDecimalPlaces(
                                                  order!.orderAmount!,
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
                                            isNeedRounding: false,
                                          );

                                          return RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff505050,
                                                    ),
                                                    letterSpacing: 0.18,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${LocaleKeys.buying.tr()} ',
                                                ),
                                                /////////////////////////
                                                TextSpan(
                                                  text:
                                                      '${order!.details?.length ?? 0}',
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff1D1D1D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        fontSize: 12,
                                                        height: 1.3,
                                                      ),
                                                ),
                                                /////////////////////////
                                                TextSpan(
                                                  text:
                                                      ' ${LocaleKeys.item.tr()} . ',
                                                ),
                                                /////////////////////////
                                                TextSpan(
                                                  text: '${orderAmount}',
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.bq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff1D1D1D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        fontSize: 12,
                                                        height: 1.3,
                                                      ),
                                                ),
                                                /////////////////////////
                                                TextSpan(
                                                  text: ' $currencySymbol',
                                                ),
                                                /////////////////////////
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      ///////////////////
                                      SizedBox(height: 5.h),
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
                                                const SizedBox(height: 5),
                                                ///////////////////
                                                Text(
                                                  LocaleKeys
                                                      .expected_delivery_date
                                                      .tr(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.rq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff8D8D8D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        fontSize: 10,
                                                        height: 1.3,
                                                      ),
                                                ),
                                                ///////////////////
                                                const SizedBox(height: 5),
                                                ///////////////////
                                                Text(
                                                  'Monday 2.Jun | 3 ${LocaleKeys.work_days.tr()}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.rq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff1D1D1D,
                                                        ),
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
                                            child:
                                                state.getOrdersByOrderGroupIDStatus ==
                                                    GetOrdersByOrderGroupIDStatus
                                                        .loading
                                                ? TrydosLoader(size: 16)
                                                : Container(
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            order!
                                                                        .orderGroupStatus
                                                                        ?.value ==
                                                                    'canceled'
                                                                ? SvgPicture.asset(
                                                                    AppAssets
                                                                        .orderCanselSvg,
                                                                    width: 20,
                                                                  )
                                                                : SvgPicture.asset(
                                                                    AppAssets
                                                                        .pendingBagSvg,
                                                                    width: 15,
                                                                  ),
                                                            ////////////////////
                                                            const SizedBox(
                                                              width: 3,
                                                            ),

                                                            ///////////////////
                                                            order!
                                                                        .orderGroupStatus
                                                                        ?.value ==
                                                                    'canceled'
                                                                ? const SizedBox.shrink()
                                                                : order!
                                                                          .orderGroupStatus
                                                                          ?.value ==
                                                                      'pending'
                                                                ? SvgPicture.asset(
                                                                    AppAssets
                                                                        .whiteBagSvg,
                                                                    width: 15,
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
                                                            order!
                                                                        .orderGroupStatus
                                                                        ?.value ==
                                                                    'canceled'
                                                                ? const SizedBox.shrink()
                                                                : ((order!.orderGroupStatus?.value ==
                                                                          'pending') ||
                                                                      (order!
                                                                              .orderGroupStatus
                                                                              ?.value ==
                                                                          'preparing'))
                                                                ? SvgPicture.asset(
                                                                    AppAssets
                                                                        .whiteBagSvg,
                                                                    width: 15,
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
                                                            order!
                                                                        .orderGroupStatus
                                                                        ?.value ==
                                                                    'canceled'
                                                                ? const SizedBox.shrink()
                                                                : ((order!.orderGroupStatus?.value ==
                                                                          'pending') ||
                                                                      (order!
                                                                              .orderGroupStatus
                                                                              ?.value ==
                                                                          'preparing') ||
                                                                      (order!
                                                                              .orderGroupStatus
                                                                              ?.value ==
                                                                          'shipped'))
                                                                ? SvgPicture.asset(
                                                                    AppAssets
                                                                        .whiteBagSvg,
                                                                    width: 15,
                                                                  )
                                                                : SvgPicture.asset(
                                                                    AppAssets
                                                                        .delivered_bagSvg,
                                                                    width: 15,
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
                                                            const Spacer(),
                                                            Text(
                                                              LocaleKeys
                                                                  .order_status
                                                                  .tr(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff8D8D8D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        10,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                          ],
                                                        ),
                                                        ///////////////////
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        ///////////////////
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              order!
                                                                      .orderGroupStatus
                                                                      ?.label ??
                                                                  '',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.rq
                                                                  .copyWith(
                                                                    color: const Color(
                                                                      0xff1D1D1D,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.18,
                                                                    fontSize:
                                                                        12,
                                                                    height: 1.3,
                                                                  ),
                                                            ),
                                                            ///////////////////
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            ///////////////////
                                                            SvgPicture.asset(
                                                              (OrderStatusClass.statusOrderIsCanceled(
                                                                    order!
                                                                            .orderStatus
                                                                            ?.value ??
                                                                        "",
                                                                  ))
                                                                  ? AppAssets
                                                                        .orderCanselSvg
                                                                  : (OrderStatusClass.statusOrderIsShipped(
                                                                      order!.orderStatus?.value ??
                                                                          "",
                                                                    ))
                                                                  ? AppAssets
                                                                        .shippedBlackSvg
                                                                  : (OrderStatusClass.statusOrderIsDelivered(
                                                                      order!.orderStatus?.value ??
                                                                          "",
                                                                    ))
                                                                  ? AppAssets
                                                                        .deliveredBlackSvg
                                                                  : (OrderStatusClass.statusOrderIsPending(
                                                                      order!.orderStatus?.value ??
                                                                          "",
                                                                    ))
                                                                  ? AppAssets
                                                                        .pendeingBlackCheck
                                                                  : AppAssets
                                                                        .orderPreparingSvg,
                                                              width: 15,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                      ///////////////////
                                      const SizedBox(height: 12),
                                      ///////////////////
                                      /*  (order?.returnRequestId != null &&
                                              (order?.editReturnRequest ??
                                                  false))
                                          ? Container(
                                              width: double.infinity,
                                              height: 1,
                                              color: const Color(0xffC4C2C2),
                                            )
                                          : const SizedBox.shrink(),*/

                                      ///////////////////
                                      BlocBuilder<OrderBloc, OrderState>(
                                        buildWhen: (previous, current) =>
                                            previous.cancelReturnRequestStatus !=
                                                current
                                                    .cancelReturnRequestStatus ||
                                            previous.getOrdersByOrderGroupIDStatus !=
                                                current
                                                    .getOrdersByOrderGroupIDStatus ||
                                            previous.orderReturnDetailsStatus !=
                                                current
                                                    .orderReturnDetailsStatus,
                                        builder: (context, state) {
                                          returnRequestIdsToCancel = [];
                                          state.getOrdersByOrderGroupIDModel?.orders?.forEach((
                                            element,
                                          ) {
                                            if (element.editReturnRequest ??
                                                false
                                            /* &&
                                                      (element.editReturnRequest ??
                                                          false)*/
                                            ) {
                                              state
                                                  .orderReturnDetailsModel
                                                  ?.data
                                                  ?.returnRequestsData
                                                  ?.forEach((elements) {
                                                    elements.orderDetails?.forEach((
                                                      element,
                                                    ) {
                                                      if ((element.alreadyReturn ??
                                                              false) &&
                                                          elements
                                                                  .status
                                                                  ?.value !=
                                                              "cancelled") {
                                                        returnRequestIdsToCancel
                                                            .add(
                                                              element
                                                                  .returnRequestId
                                                                  .toString(),
                                                            );
                                                      }
                                                    });
                                                  });
                                            }
                                          });
                                          return returnRequestIdsToCancel
                                                  .isEmpty
                                              ? const SizedBox.shrink()
                                              : state.cancelReturnRequestStatus ==
                                                        CancelReturnRequestStatus
                                                            .loading ||
                                                    state.orderReturnDetailsStatus ==
                                                        OrderReturnDetailsStatus
                                                            .loading ||
                                                    state.getOrdersByOrderGroupIDStatus ==
                                                        GetOrdersByOrderGroupIDStatus
                                                            .loading
                                              ? TrydosLoader(size: 16)
                                              : InkWell(
                                                  onTap: () {
                                                    showShadowForCancelAllOrder
                                                            .value =
                                                        true;
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      "${LocaleKeys.cancel_return_request.tr()}",
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            decorationColor:
                                                                Colors.red,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: Colors.red,
                                                            letterSpacing: 0.18,
                                                            fontSize: 12,
                                                            height: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                      const SizedBox(height: 2),

                                      BlocBuilder<OrderBloc, OrderState>(
                                        buildWhen: (previous, current) =>
                                            previous.confirmReturnRequestStatus !=
                                                current
                                                    .confirmReturnRequestStatus ||
                                            previous.getOrdersByOrderGroupIDStatus !=
                                                current
                                                    .getOrdersByOrderGroupIDStatus ||
                                            previous.orderReturnDetailsStatus !=
                                                current
                                                    .orderReturnDetailsStatus,
                                        builder: (context, state) {
                                          returnRequestIdsToConfirm = [];
                                          bool appearConfirm = false;
                                          returnRequestsData = state
                                              .orderReturnDetailsModel
                                              ?.data
                                              ?.returnRequestsData!
                                              .firstWhere(
                                                (element) =>
                                                    element.orderId ==
                                                    order?.id,
                                                orElse: () =>
                                                    ReturnRequestsDatum(),
                                              );
                                          orderDetails =
                                              returnRequestsData
                                                  ?.orderDetails ??
                                              [];

                                          state
                                              .orderReturnDetailsModel
                                              ?.data
                                              ?.returnRequestsData
                                              ?.forEach((element) {
                                                if ((element.status?.value ??
                                                            "")
                                                        .contains("draft") ||
                                                    (element.status?.name ?? "")
                                                        .contains("draft")) {
                                                  element.orderDetails?.forEach((
                                                    element,
                                                  ) {
                                                    if (element.alreadyReturn ??
                                                        false) {
                                                      returnRequestIdsToConfirm
                                                          .add(
                                                            element
                                                                .returnRequestId
                                                                .toString(),
                                                          );
                                                      appearConfirm = true;
                                                    }
                                                  });
                                                }
                                              });

                                          return !appearConfirm
                                              ? const SizedBox.shrink()
                                              : state.confirmReturnRequestStatus ==
                                                        ConfirmReturnRequestStatus
                                                            .loading ||
                                                    state.orderReturnDetailsStatus ==
                                                        OrderReturnDetailsStatus
                                                            .loading ||
                                                    state.getOrdersByOrderGroupIDStatus ==
                                                        GetOrdersByOrderGroupIDStatus
                                                            .loading
                                              ? TrydosLoader(size: 16)
                                              : InkWell(
                                                  onTap: () {
                                                    showShadowForConfirmOrder
                                                            .value =
                                                        true;
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      "${LocaleKeys.confirm_return_request.tr()}",
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            decorationColor:
                                                                Colors.green,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: Colors.green,
                                                            letterSpacing: 0.18,
                                                            fontSize: 12,
                                                            height: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                      order?.returnRequestId == null
                                          ? const SizedBox.shrink()
                                          : const SizedBox(height: 10),
                                      order?.returnRequestId == null
                                          ? const SizedBox.shrink()
                                          : Container(
                                              width: double.infinity,
                                              height: 1,
                                              color: const Color(0xffC4C2C2),
                                            ),
                                      const SizedBox(height: 10),
                                      ///////////////////
                                      ListView.separated(
                                        itemCount: order!.details?.length ?? 0,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return productWidget(
                                            order!.details![index],
                                            index,
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
                          ),
                        ],
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
                    ValueListenableBuilder<int>(
                      valueListenable: indexTap,
                      builder: (context, _indexTap, _) {
                        return shadowForChangeOrderVariant(_indexTap);
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: indexTap,
                      builder: (context, _indexTap, _) {
                        return shadowForCanselOrRutuenOrder(_indexTap);
                      },
                    ),
                    shadowForConfirmOrder(),
                    shadowForCancelAllOrder(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget optionsForAllOrder() {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          width: 1.sw,
          height: 200.h,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            border: Border.all(color: const Color(0xffF8F8F8)),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                    const SizedBox(width: 10),
                    SvgPicture.asset(AppAssets.orderClockSvg, height: 15.h),
                    const SizedBox(width: 5),
                    Text(
                      HelperFunctions.orderFormatDate(
                        DateTime.tryParse(order!.createdAt ?? '') ??
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
                    const SizedBox(width: 5),
                    Text(
                      order!.orderGroupId ?? "",
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: 1.sw,
                height: 16.h,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    SvgPicture.asset(AppAssets.preparingBagSvg, height: 15.h),
                    const SizedBox(width: 5),
                    Text(
                      order!.orderGroupStatus?.label ?? "",
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 5),
                    SvgPicture.asset(
                      order!.orderGroupStatus?.value == 'canceled'
                          ? AppAssets.orderCanselSvg
                          : order!.orderGroupStatus?.value == 'shipped'
                          ? AppAssets.shippedBlackSvg
                          : (order!.orderGroupStatus?.value == 'delivered' ||
                                (order!.orderGroupStatus?.value ?? "").contains(
                                  "return",
                                ))
                          ? AppAssets.deliveredBlackSvg
                          : order!.orderGroupStatus?.value == 'pending'
                          ? AppAssets.pendeingBlackCheck
                          : AppAssets.orderPreparingSvg,
                      height: 15.h,
                    ),
                    const Spacer(),
                    SvgPicture.asset(AppAssets.orderInvoice2Svg, height: 15.h),
                    const SizedBox(width: 5),
                    Text(
                      (order!.details?.length ?? "").toString(),
                      style: context.textTheme.bodyMedium?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      LocaleKeys.item.tr(),
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      HelperFunctions.formatNumber(
                        numberToFormate:
                            (HelperFunctions.truncateToDecimalPlaces(
                              order!.orderAmount!,
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
                    const SizedBox(width: 5),
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
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 125.h,
                width: 1.sw,
                padding: EdgeInsets.only(
                  left: LanguageService.languageCode == "ar" ? 0 : 10,
                  right: LanguageService.languageCode != "ar" ? 0 : 10,
                ),
                child: ListView.builder(
                  itemCount: order!.details?.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 125.h,
                      width: 92,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        child: MyCachedNetworkImage(
                          imageUrl: order!.details?[index].image ?? "",
                          width: 92,
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
        const SizedBox(height: 10),
        Text(
          "${LocaleKeys.action_about_order.tr()}",
          style: context.textTheme.bodyMedium?.rq.copyWith(
            color: const Color(0xff8D8D8D),
            letterSpacing: 0.18,
            fontSize: 12,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 1.sw,
          height: 0.5,
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        SizedBox(height: 30.h),
        order?.canUpdateAddress ?? false
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
                      "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}",
                ),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 8),
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
            body: "${LocaleKeys.hide_this_product_from_list.tr()}",
          ),
        ),
        const SizedBox(height: 8),
        (order?.canCanceleOrder ?? false)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                  onTap: () {
                    orderBloc.add(const ResetAllStatusEvent());
                    optionModifyPanel.value = "Cancel";
                  },
                  svg: AppAssets.orderCanselSvg,
                  image2: "",
                  tiltle: "${LocaleKeys.cancel_this_order.tr()} ${order?.id}",
                  body: allOrder
                      ? LocaleKeys.cancel_order_hours_back_money.tr(
                          namedArgs: {'hours': '3'},
                        )
                      : LocaleKeys.cancel_product_hours_back_money.tr(
                          namedArgs: {'hours': '3'},
                        ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget productWidget(OrderListDetailModel orderListDetailModel, int index) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.orderReturnDetailsStatus !=
              current.orderReturnDetailsStatus ||
          previous.cancelReturnRequestProductStatus !=
              current.cancelReturnRequestProductStatus ||
          previous.cancelReturnRequestStatus !=
              current.cancelReturnRequestStatus ||
          previous.confirmReturnRequestStatus !=
              current.confirmReturnRequestStatus ||
          previous.storeReturnRequestProductStatus !=
              current.storeReturnRequestProductStatus,
      builder: (context, state) {
        returnRequestsData = state
            .orderReturnDetailsModel
            ?.data
            ?.returnRequestsData!
            .firstWhere(
              (element) => element.orderId == order?.id,
              orElse: () => ReturnRequestsDatum(),
            );
        orderDetails = returnRequestsData?.orderDetails ?? [];
        ReturnOrderDetail? orderDetail = orderDetails.firstWhere(
          (element) => element.detailId == orderListDetailModel.id,
          orElse: () => ReturnOrderDetail(),
        );
        ReturnReasonModel? reason;
        if ((state.returnReasonsModel?.data?.returnReasons?.length ?? 0) > 0) {
          reason = state.returnReasonsModel?.data?.returnReasons!.firstWhere(
            (element) => element.id == orderDetail.returnRequestProductReasonId,
            orElse: () => ReturnReasonModel(cost: 0),
          );
        }

        return Container(
          height:
              orderDetail.returnRequestProductId == null ||
                  order?.returnRequestId == null
              ? 190
              : 170 + 100 + 100,
          width: 1.sw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 170,
                width: 1.sw,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          BlocProvider.of<HomeBloc>(
                            navigatorKey.currentState!.context,
                          ).add(
                            GetFullProductDetailsEvent(
                              currentColorName:
                                  (orderListDetailModel.variation.isNullOrEmpty)
                                  ? ""
                                  : orderListDetailModel
                                        .variation?[0]
                                        .colorOption,
                              productSlug:
                                  orderListDetailModel.productSlug ?? "",
                            ),
                          );

                          Future.delayed(
                            const Duration(seconds: 1),
                            () =>
                                Navigator.of(
                                  navigatorKey.currentState!.context,
                                ).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ProductDetailsPageNew(
                                          productSlugForOpeningChatDirectly:
                                              orderListDetailModel
                                                  .productSlug ??
                                              "",
                                          productIdForOpeningChatDirectly:
                                              orderListDetailModel.productId
                                                  .toString(),
                                        ),
                                  ),
                                ),
                          );
                        },
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
                    ),
                    ///////////////////
                    const SizedBox(width: 12),
                    ///////////////////
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            InkWell(
                              onTap: () {
                                BlocProvider.of<HomeBloc>(
                                  navigatorKey.currentState!.context,
                                ).add(
                                  GetFullProductDetailsEvent(
                                    currentColorName:
                                        (orderListDetailModel
                                            .variation
                                            .isNullOrEmpty)
                                        ? ""
                                        : orderListDetailModel
                                              .variation?[0]
                                              .colorOption,
                                    productSlug:
                                        orderListDetailModel.productSlug ?? "",
                                  ),
                                );

                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () =>
                                      Navigator.of(
                                        navigatorKey.currentState!.context,
                                      ).push(
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => ProductDetailsPageNew(
                                                productSlugForOpeningChatDirectly:
                                                    orderListDetailModel
                                                        .productSlug ??
                                                    "",
                                                productIdForOpeningChatDirectly:
                                                    orderListDetailModel
                                                        .productId
                                                        .toString(),
                                              ),
                                        ),
                                      ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 8,
                                    width: 50,
                                    color: Colors.black,
                                  ),
                                  ///////////////////
                                  const SizedBox(height: 15),
                                  ///////////////////
                                  Text(
                                    orderListDetailModel.productDetails?.name ??
                                        '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xff505050),
                                          letterSpacing: 0.18,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                  ),
                                  ///////////////////
                                  const SizedBox(height: 5),
                                  ///////////////////
                                  (orderListDetailModel.variation.isNullOrEmpty)
                                      ? const SizedBox.shrink()
                                      : (orderListDetailModel
                                                        .variation?[0]
                                                        .size ==
                                                    null ||
                                                orderListDetailModel
                                                        .variation?[0]
                                                        .size ==
                                                    "") &&
                                            (orderListDetailModel
                                                        .variation?[0]
                                                        .color ==
                                                    null ||
                                                orderListDetailModel
                                                        .variation?[0]
                                                        .color ==
                                                    "")
                                      ? const SizedBox.shrink()
                                      : Row(
                                          children: [
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff8D8D8D,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      fontSize: 10,
                                                      height: 1.3,
                                                    ),
                                                children: [
                                                  orderListDetailModel
                                                          .variation
                                                          .isNullOrEmpty
                                                      ? const TextSpan(text: "")
                                                      : orderListDetailModel
                                                                    .variation?[0]
                                                                    .color ==
                                                                "" ||
                                                            orderListDetailModel
                                                                    .variation?[0]
                                                                    .color ==
                                                                null
                                                      ? const TextSpan(text: "")
                                                      : TextSpan(
                                                          text:
                                                              '${LocaleKeys.color.tr()} : ',
                                                        ),
                                                  ////////////////////////////
                                                  TextSpan(
                                                    text:
                                                        orderListDetailModel
                                                            .variation
                                                            .isNullOrEmpty
                                                        ? ''
                                                        : orderListDetailModel
                                                                  .variation?[0]
                                                                  .color ??
                                                              '',
                                                    style: context
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.mq
                                                        .copyWith(
                                                          color: const Color(
                                                            0xff505050,
                                                          ),
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
                                              width:
                                                  (orderListDetailModel
                                                      .variation
                                                      .isNullOrEmpty)
                                                  ? 0
                                                  : orderListDetailModel
                                                                .variation?[0]
                                                                .color ==
                                                            "" ||
                                                        orderListDetailModel
                                                                .variation?[0]
                                                                .color ==
                                                            null
                                                  ? 0
                                                  : 12,
                                            ),
                                            ///////////////////
                                            Flexible(
                                              child: RichText(
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                text: TextSpan(
                                                  style: context
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.rq
                                                      .copyWith(
                                                        color: const Color(
                                                          0xff8D8D8D,
                                                        ),
                                                        letterSpacing: 0.18,
                                                        fontSize: 10,
                                                        height: 1.3,
                                                      ),
                                                  children: [
                                                    (orderListDetailModel
                                                            .variation
                                                            .isNullOrEmpty)
                                                        ? const TextSpan(
                                                            text: "",
                                                          )
                                                        : orderListDetailModel
                                                                      .variation?[0]
                                                                      .size ==
                                                                  null ||
                                                              orderListDetailModel
                                                                      .variation?[0]
                                                                      .size ==
                                                                  ""
                                                        ? const TextSpan(
                                                            text: "",
                                                          )
                                                        : TextSpan(
                                                            text:
                                                                '${LocaleKeys.size.tr()} : ',
                                                          ),
                                                    ////////////////////////////
                                                    TextSpan(
                                                      text:
                                                          orderListDetailModel
                                                              .variation
                                                              .isNullOrEmpty
                                                          ? ""
                                                          : orderListDetailModel
                                                                    .variation?[0]
                                                                    .size ==
                                                                null
                                                          ? ''
                                                          : orderListDetailModel
                                                                    .variation?[0]
                                                                    .size ??
                                                                '',
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.mq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff505050,
                                                            ),
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
                                  const SizedBox(height: 5),
                                  ///////////////////
                                  Row(
                                    children: [
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.rq
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
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.mq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xff505050,
                                                    ),
                                                    letterSpacing: 0.18,
                                                    fontSize: 10,
                                                    height: 1.3,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ///////////////////
                                      const SizedBox(width: 12),
                                      ///////////////////
                                      Flexible(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff8D8D8D,
                                                  ),
                                                  letterSpacing: 0.18,
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
                                                text: orderListDetailModel.qty
                                                    .toString(),
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.mq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff505050,
                                                      ),
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
                                  const SizedBox(height: 5),
                                  ///////////////////
                                  BlocBuilder<OrderBloc, OrderState>(
                                    buildWhen: (p, c) =>
                                        p
                                                .getOrdersModel?[widget
                                                    .currentStatus]
                                                ?.paginationStatus !=
                                            c
                                                .getOrdersModel?[widget
                                                    .currentStatus]
                                                ?.paginationStatus ||
                                        p.getOrdersByOrderGroupIDStatus !=
                                            c.getOrdersByOrderGroupIDStatus,
                                    builder: (context, state) =>
                                        state.getOrdersByOrderGroupIDStatus ==
                                                GetOrdersByOrderGroupIDStatus
                                                    .loading ||
                                            state.orderReturnDetailsStatus ==
                                                OrderReturnRequestsViewStatus
                                                    .loading
                                        ? TrydosLoader(size: 16)
                                        : Row(
                                            children: [
                                              Flexible(
                                                child: RichText(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  text: TextSpan(
                                                    style: context
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.rq
                                                        .copyWith(
                                                          color: const Color(
                                                            0xff8D8D8D,
                                                          ),
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
                                                            ("${(orderListDetailModel.qty ?? 0) == 0 ? LocaleKeys.canceled_status_short.tr() : order!.orderStatus?.label ?? ""} ${orderDetail.returnRequestProductId == null ? "" : "- ${LocaleKeys.return_request.tr()}"}"),
                                                        style: context
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.mq
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xff505050,
                                                                  ),
                                                              letterSpacing:
                                                                  0.18,
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
                                              const SizedBox(width: 12),
                                              ///////////////////
                                              SvgPicture.asset(
                                                (OrderStatusClass.statusOrderIsCanceled(
                                                          order!
                                                                  .orderStatus
                                                                  ?.value ??
                                                              "",
                                                        )) ||
                                                        (orderListDetailModel
                                                                    .qty ??
                                                                0) ==
                                                            0
                                                    ? AppAssets.orderCanselSvg
                                                    : (OrderStatusClass.statusOrderIsShipped(
                                                        order!
                                                                .orderStatus
                                                                ?.value ??
                                                            "",
                                                      ))
                                                    ? AppAssets.shippedBlackSvg
                                                    : (OrderStatusClass.statusOrderIsDelivered(
                                                        order!
                                                                .orderStatus
                                                                ?.value ??
                                                            "",
                                                      ))
                                                    ? AppAssets
                                                          .deliveredBlackSvg
                                                    : (OrderStatusClass.statusOrderIsPending(
                                                        order!
                                                                .orderStatus
                                                                ?.value ??
                                                            "",
                                                      ))
                                                    ? AppAssets
                                                          .pendeingBlackCheck
                                                    : AppAssets
                                                          .orderPreparingSvg,
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                  ),

                                  const SizedBox(height: 5),
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
                                  /* Row(
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
                            ),*/
                                  ////////////////////
                                  const Spacer(),
                                  ////////////////////
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: const Color(0xffC4C2C2),
                                            letterSpacing: 0.18,
                                            fontSize: 12,
                                            height: 1.3,
                                          ),
                                      children: [
                                        (orderListDetailModel.price ?? 0) ==
                                                (orderListDetailModel
                                                        .priceAfterDiscount ??
                                                    0)
                                            ? const TextSpan()
                                            : TextSpan(
                                                text:
                                                    '${HelperFunctions.formatNumber(numberToFormate: ((HelperFunctions.truncateToDecimalPlaces((orderListDetailModel.price ?? 0), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!)) * (homeBloc.state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)}',
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xffC4C2C2,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      fontSize: 12,
                                                      height: 1.3,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                              ),
                                        ////////////////////////////
                                        TextSpan(
                                          text:
                                              ' ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((orderListDetailModel.priceAfterDiscount ?? 0), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)}',
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.bq
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
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.lq
                                              .copyWith(
                                                color: const Color(0xff1D1D1D),
                                                letterSpacing: 0.18,
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                        ),
                                        orderDetail.returnRequestProductId ==
                                                    null ||
                                                order!.paymentStatus == "unpaid"
                                            ? const TextSpan(text: "")
                                            : TextSpan(
                                                text:
                                                    ' ${LocaleKeys.back_to_your_wallet.tr()} ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(((((orderListDetailModel.priceAfterDiscount ?? 0) / (orderListDetailModel.qty ?? 1)) * (orderDetail.quantity ?? 0)) - (reason?.isCostBySystem == 1 ? 0 : reason?.cost ?? 0)), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)} ${homeBloc.state.getCurrencyForCountryModel!.data!.currency!.symbol}',
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff388CFF,
                                                      ),
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
                            ),
                            ///////////////////
                            Container(
                              width: 40,
                              height: 25,
                              child: BlocBuilder<OrderBloc, OrderState>(
                                buildWhen: (previous, current) =>
                                    previous.getCustomerAddressStatus !=
                                        current.getCustomerAddressStatus ||
                                    previous.editAddressToOrderStatus !=
                                        current.editAddressToOrderStatus ||
                                    previous.setCustomerAddressDefaultStatus !=
                                        current
                                            .setCustomerAddressDefaultStatus ||
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
                                      height: 25,
                                      child: SvgPicture.asset(
                                        AppAssets.orderMenuSvg,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              orderDetail.returnRequestProductId == null ||
                      order?.returnRequestId == null
                  ? const SizedBox.shrink()
                  : state.cancelReturnRequestProductStatus ==
                            CancelReturnRequestProductStatus.loading ||
                        state.orderReturnDetailsStatus ==
                            OrderReturnDetailsStatus.loading
                  ? TrydosLoader(size: 18)
                  : Container(
                      width: 1.sw,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 5,
                      ),
                      height:
                          (returnRequestsData!.status?.value?.contains(
                                    "rejected",
                                  ) ??
                                  false) ||
                              (returnRequestsData!.status?.value?.contains(
                                    "cancelled",
                                  ) ??
                                  false) ||
                              (returnRequestsData!.status?.value?.contains(
                                    "resolved",
                                  ) ??
                                  false)
                          ? 30
                          : (53 + 100),
                      decoration: const BoxDecoration(
                        color: Color(0xffFFFCF0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child:
                          (returnRequestsData!.status?.value?.contains(
                                "resolved",
                              ) ??
                              false)
                          ? statusOfReturned(
                              AppAssets.returnedBlacSvg,
                              LocaleKeys.return_problem_resolved.tr(),
                              "",
                              "",
                              "",
                              true,
                              true,
                              true,
                            )
                          : (returnRequestsData!.status?.value?.contains(
                                  "cancelled",
                                ) ??
                                false)
                          ? statusOfReturned(
                              AppAssets.returnedBlacSvg,
                              LocaleKeys.return_request_cancelled.tr(),
                              "",
                              "",
                              "",
                              true,
                              true,
                              true,
                            )
                          : (returnRequestsData!.status?.value?.contains(
                                  "rejected",
                                ) ??
                                false)
                          ? statusOfReturned(
                              AppAssets.returnedBlacSvg,
                              LocaleKeys.return_request_rejected.tr(),
                              "",
                              "",
                              "",
                              true,
                              true,
                              true,
                            )
                          : Column(
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
                                  LocaleKeys.product_return_has_been_requested
                                      .tr(),
                                  LocaleKeys.product_return_request_approve
                                      .tr(),
                                  "3 H",
                                  "00:02:19",
                                  returnRequestsData!.status?.value?.contains(
                                        "pending",
                                      ) ??
                                      false,
                                  returnRequestsData!.status?.value?.contains(
                                        "pending",
                                      ) ??
                                      false,
                                  true,
                                ),
                                statusOfReturned(
                                  AppAssets.returnedBlacSvg,
                                  LocaleKeys.product_return_request_approve
                                      .tr(),
                                  "${LocaleKeys.product_collection_within.tr()}" +
                                      "  1 ${LocaleKeys.day.tr()}",
                                  "3 H",
                                  "00:02:19",
                                  returnRequestsData!.status?.value?.contains(
                                        "approved",
                                      ) ??
                                      false,
                                  returnRequestsData!.status?.value?.contains(
                                        "approved",
                                      ) ??
                                      false,
                                  true,
                                ),
                                statusOfReturned(
                                  AppAssets.returnedBlacSvg,
                                  LocaleKeys.out_for_return.tr(),
                                  "",
                                  "3 H",
                                  "00:02:19",
                                  returnRequestsData!.status?.value?.contains(
                                        "out_for_return",
                                      ) ??
                                      false,
                                  returnRequestsData!.status?.value?.contains(
                                        "out_for_return",
                                      ) ??
                                      false,
                                  true,
                                ),
                                statusOfReturned(
                                  AppAssets.returnedBlacSvg,
                                  LocaleKeys
                                      .product_has_been_returned_successfully
                                      .tr(),
                                  order?.paymentStatus == "unpaid"
                                      ? ""
                                      : '${LocaleKeys.back_to_your_wallet.tr()} ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(((((orderListDetailModel.priceAfterDiscount ?? 0) / (orderListDetailModel.qty ?? 1)) * (orderDetail.quantity ?? 0)) - (reason?.isCostBySystem == 1 ? 0 : reason?.cost ?? 0)), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)} ${homeBloc.state.getCurrencyForCountryModel!.data!.currency!.symbol}',
                                  "3 H",
                                  "00:02:19",
                                  ((returnRequestsData!.status?.value?.contains(
                                        "returned_to_location",
                                      ) ??
                                      false)),
                                  ((returnRequestsData!.status?.value?.contains(
                                        "returned_to_location",
                                      ) ??
                                      false)),
                                  false,
                                ) /*,
                                statusOfReturned(
                                    AppAssets.returnedBlacSvg,
                                    LocaleKeys.product_return_has_been_requested
                                        .tr(),
                                    LocaleKeys.product_return_request_approve
                                        .tr(),
                                    "",
                                    "",
                                    false,
                                    false)*/,
                              ],
                            ),
                    ),
              const SizedBox(height: 10),
              (!((orderDetail.alreadyReturn ?? false) &&
                      (returnRequestsData?.status?.value != "cancelled") &&
                      (order?.orderHasReturnRequest ?? false) &&
                      (order?.editReturnRequest ?? false)))
                  ? const SizedBox.shrink()
                  : state.cancelReturnRequestProductStatus ==
                            CancelReturnRequestProductStatus.loading ||
                        state.orderReturnDetailsStatus ==
                            OrderReturnDetailsStatus.loading
                  ? TrydosLoader(size: 18)
                  : InkWell(
                      onTap: () {
                        orderBloc.add(
                          CancelReturnRequestProductEvent(
                            orderGroupId: order?.orderGroupId ?? "",
                            returnRequestId: orderDetail.returnRequestId ?? 0,
                            params: CancelReturnRequestProductParams(
                              returnRequestProductId:
                                  (orderDetail.returnRequestProductId ?? "")
                                      .toString(),
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${LocaleKeys.cancel_return_request_get.tr()}",
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                decoration: TextDecoration.underline,
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              " 3 USD",
                              style: context.textTheme.bodyMedium?.bq.copyWith(
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
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget statusOfReturned(
    String svg,
    String tilte,
    String body,
    String time,
    String timer,
    bool isBlak,
    bool isTextBlak,
    bool isWaiting,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      width: 1.sw,
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
                const SizedBox(width: 5),
                Text(
                  tilte,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: !isTextBlak
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: !isTextBlak
                        ? const Color(0xffC4C2C2)
                        : const Color(0xffC4C2C2),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(AppAssets.orderClockSvg),
              ],
            ),
          ),
          body == ""
              ? const SizedBox.shrink()
              : Container(
                  width: 1.sw,
                  height: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        isWaiting ? "${LocaleKeys.waiting.tr()}" : "",
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: !isTextBlak
                              ? const Color(0xffC4C2C2)
                              : const Color(0xff388CFF),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        " $body",
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: !isTextBlak
                              ? const Color(0xffC4C2C2)
                              : const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timer,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: !isTextBlak
                              ? const Color(0xffC4C2C2)
                              : const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      SvgPicture.asset(
                        AppAssets.orderClockSvg,
                        // ignore: deprecated_member_use
                        color: isBlak ? const Color(0xff1D1D1D) : null,
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget SuccessFulOfReturned(
    String svg,
    String tilte,
    String body,
    String money,
    String time,
    String timer,
    bool isBlac,
    bool isTextBlac,
  ) {
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
                const SizedBox(width: 5),
                Text(
                  tilte,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xffC4C2C2),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(AppAssets.orderClockSvg),
              ],
            ),
          ),
          Container(
            width: 1.sw,
            height: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Text(
                  " $body",
                  style: context.textTheme.bodyMedium?.rq.copyWith(
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
                  style: context.textTheme.bodyMedium?.bq.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  timer,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: !isTextBlac
                        ? const Color(0xffC4C2C2)
                        : const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(
                  AppAssets.orderClockSvg,
                  // ignore: deprecated_member_use
                  color: isBlac ? const Color(0xff1D1D1D) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget buildFirstSection(BuildContext context, String itemsCount) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (p, c) =>
          p.orderReturnDetailsStatus != c.orderReturnDetailsStatus,
      builder: (context, state) {
        ReturnRequestsDatum? orderReturnDetail;

        if (state.orderReturnDetailsModel != null) {
          if (state.orderReturnDetailsModel!.data?.returnRequestsData != null) {
            orderReturnDetail = state
                .orderReturnDetailsModel!
                .data!
                .returnRequestsData!
                .firstWhere(
                  (element) => element.orderId == order?.id,
                  orElse: () => ReturnRequestsDatum(),
                );
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffF4F4F4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xffC4C2C2)),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.bagsSvg, width: 20),
                    ///////////////////
                    const SizedBox(height: 3),
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
                    const SizedBox(height: 3),
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
                          TextSpan(text: ' 1 ${LocaleKeys.not_delivery.tr()}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                order!.orderStatus?.value != "out_for_delivery" &&
                        orderReturnDetail?.status?.value != "out_for_return"
                    ? const SizedBox.shrink()
                    : Container(
                        height: 30,
                        child: BlocListener<ChatBloc, ChatState>(
                          listenWhen: (previous, current) =>
                              previous.getOrderRecipientIdStatus !=
                              current.getOrderRecipientIdStatus,
                          listener: (context, state) {
                            if (state.getOrderRecipientIdStatus ==
                                GetOrderRecipientIdStatus.success) {
                              String receiverName =
                                  HelperFunctions.getTheFirstTwoLettersOfName(
                                    LocaleKeys.delivery_worker.tr(),
                                  );
                              String fullReceiverName = LocaleKeys
                                  .delivery_worker
                                  .tr();
                              String? recipientUserId = state.recipientUserId;
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
                                GetIt.I<ChatBloc>().state.pinnedChats,
                              );
                              chat = chats.firstWhere(
                                (element) =>
                                    element.channelMembers!.any((element) {
                                      return element.userId.toString() ==
                                          recipientUserId;
                                    }),
                              );
                              final preferences = GetIt.I<PrefsRepository>();
                              receiver = chat.channelMembers
                                  ?.firstWhere(
                                    (element) =>
                                        element.userId != preferences.myChatId,
                                    orElse: () => ChannelMember(
                                      userId: int.tryParse(recipientUserId),
                                      user: User(
                                        id: int.tryParse(recipientUserId),
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
                                previous.getOrderRecipientIdStatus !=
                                current.getOrderRecipientIdStatus,
                            builder: (context, state) {
                              if (state.getOrderRecipientIdStatus ==
                                  GetOrderRecipientIdStatus.loading) {
                                return Container(
                                  width: 30,
                                  height: 30,
                                  child: TrydosLoader(size: 16),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    82,
                                    139,
                                    236,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                alignment: Alignment.center,

                                height: 30,
                                child: InkWell(
                                  onTap: () {
                                    GetIt.I<ChatBloc>().add(
                                      GetOrderRecipientIdEvent(
                                        originalUserId:
                                            GetIt.I<PrefsRepository>()
                                                .myMarketId
                                                .toString(),
                                        parentOrderId: orderReturnDetail == null
                                            ? null
                                            : orderReturnDetail.status?.value ==
                                                  "out_for_return"
                                            ? order!.id.toString()
                                            : null,
                                        orderId:
                                            orderReturnDetail?.status?.value ==
                                                "out_for_return"
                                            ? orderReturnDetail!.returnRequestId
                                                  .toString()
                                            : order!.id.toString(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.chatSvg,
                                        width: 10,
                                      ),
                                      const SizedBox(width: 1),
                                      Text(
                                        LocaleKeys.chat_with_delivery_person
                                            .tr(),
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xffFFFFFF),
                                              fontSize: 8,
                                              height: 1.3,
                                              letterSpacing: 0.18,
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
                      LocaleKeys.about_change_request_product.tr(),
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
                    order?.paymentStatus == "unpaid"
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      "${LocaleKeys.change_terms.tr()} ",
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
                                const SizedBox(width: 5),
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
                                  LocaleKeys.change_terms.tr(),
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
                    BlocListener<OrderBloc, OrderState>(
                      listenWhen: (previous, current) =>
                          previous.cancelOrderItemStatus !=
                              current.cancelOrderItemStatus ||
                          previous.changeOrderItemVariantStatus !=
                              current.changeOrderItemVariantStatus,
                      listener: (context, state) {
                        if (state.changeOrderItemVariantStatus ==
                                ChangeOrderItemVariantStatus.success ||
                            state.cancelOrderItemStatus ==
                                CancelOrderItemStatus.success) {
                          orderBloc.add(
                            GetOrdersByOrderGroupIDEvent(
                              orderGroupId: order!.orderGroupId ?? "",
                            ),
                          );

                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;
                          optionReturn.value = 0;
                          showShadowForCancelAllOrder.value = false;
                          reasonCost.value = 0;
                          showShadowForConfirmOrder.value = false;
                          optionCansel.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                        }
                      },
                      child: InkWell(
                        onTap: () {
                          if (agreeToPolicies.value == false) {
                            return;
                          }
                          if (order!.details?[indexTap.value].qty!.round() !=
                              qtyToChangeController.value) {
                            orderBloc.add(
                              CancelOrderItemEvent(
                                cancelOrderItemParams: CancelOrderItemParams(
                                  orderId: order!.id.toString(),
                                  detailId:
                                      order!.details?[indexTap.value].id
                                          .toString() ??
                                      "",
                                  qty:
                                      ((order!.details?[indexTap.value].qty!
                                                      .round() ??
                                                  0) -
                                              (qtyToChangeController.value))
                                          .toString(),
                                ),
                              ),
                            );
                            return;
                          }
                          orderBloc.add(
                            ChangeOrderItemVariantEvent(
                              params: ChangeOrderItemVariantParams(
                                orderDetailId:
                                    order!.details?[indexTap.value].id
                                        .toString() ??
                                    "",
                                choice1: sizeIndexTap.value == null
                                    ? (firstSizeOption ?? "").replaceAll(
                                        "_",
                                        "-",
                                      )
                                    : productChoiceOptions[0]
                                              .options?[sizeIndexTap.value!]
                                              .option ??
                                          "",
                                color: colorIndexTap.value == null
                                    ? firstColorNum ?? ""
                                    : productColors[colorIndexTap.value!]
                                              .color ??
                                          "",
                              ),
                            ),
                          );
                        },
                        child: ValueListenableBuilder<bool>(
                          valueListenable: agreeToPolicies,
                          builder: (context, _agreeToPolicies, _) {
                            return BlocBuilder<OrderBloc, OrderState>(
                              buildWhen: (previous, current) =>
                                  previous.changeOrderItemVariantStatus !=
                                      current.changeOrderItemVariantStatus ||
                                  previous.cancelOrderItemStatus !=
                                      current.cancelOrderItemStatus,
                              builder: (context, state) {
                                return (state.changeOrderItemVariantStatus ==
                                            ChangeOrderItemVariantStatus
                                                .loading ||
                                        state.cancelOrderItemStatus ==
                                            CancelOrderItemStatus.loading)
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey[500]!,
                                        highlightColor: Colors.grey[300]!,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          alignment: Alignment.center,
                                          width: 1.sw,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            color: agreeToPolicies.value == true
                                                ? const Color(0xff3066CC)
                                                : const Color(0xffC4C2C2),
                                            border:
                                                agreeToPolicies.value == true
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
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
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
                                          LocaleKeys.i_agree_change.tr(),
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
                                      );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<OrderBloc, OrderState>(
                      buildWhen: (previous, current) =>
                          previous.changeOrderItemVariantStatus !=
                              current.changeOrderItemVariantStatus ||
                          previous.cancelOrderItemStatus !=
                              current.cancelOrderItemStatus,
                      builder: (context, state) {
                        return Container(
                          width: 200,
                          height: 40.h,
                          child: InkWell(
                            onTap: () {
                              if (state.changeOrderItemVariantStatus ==
                                      ChangeOrderItemVariantStatus.loading ||
                                  state.cancelOrderItemStatus ==
                                      CancelOrderItemStatus.loading) {
                                return;
                              }
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              showShadowForConfirmOrder.value = false;
                              optionModifyPanel.value = null;
                              enableChangeAddress.value = false;
                              showShadowForPanel.value = false;
                              showShadowForCancelAllOrder.value = false;
                              showShadowForChangeAddress.value = false;
                              showShadowForCanselOrder.value = false;
                              optionReturn.value = 0;
                              reasonCost.value = 0;
                              optionCansel.value = [];
                              shadowForChangeVariant.value = false;
                            },
                            child: Text(
                              LocaleKeys.i_disagree.tr(),
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.18,
                                decorationColor: Colors.white,
                                decoration: TextDecoration.underline,
                                fontSize: 16.sp,
                                height: 1.3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              );
      },
    );
  }

  Widget shadowForConfirmOrder() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForConfirmOrder,
      builder: (context, _showShadowForConfirmOrder, _) {
        List<String> images = [];

        orderBloc.state.orderReturnDetailsModel?.data?.returnRequestsData!
            .forEach((element) {
              if ((element.status?.value ?? "").contains("draft") ||
                  (element.status?.name ?? "").contains("draft")) {
                element.orderDetails?.forEach((element) {
                  if (element.returnRequestProductId != null &&
                      element.returnRequestId != null &&
                      (element.alreadyReturn ?? false)) {
                    images.add(element.image ?? "");
                  }
                });
              }
            });

        return !_showShadowForConfirmOrder
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
                      LocaleKeys.about_return_your_product.tr(),
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
                    order?.paymentStatus == "unpaid"
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    Container(
                      height: 130.h,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: images.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 130.h,
                          width: 100,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            child: MyCachedNetworkImage(
                              imageUrl: images[index],
                              width: 100,
                              imageFit: BoxFit.contain,
                              height: 130.h,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                const SizedBox(width: 5),
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
                    BlocListener<OrderBloc, OrderState>(
                      listenWhen: (previous, current) =>
                          previous.confirmReturnRequestStatus !=
                          current.confirmReturnRequestStatus,
                      listener: (context, state) {
                        if (state.confirmReturnRequestStatus ==
                            ConfirmReturnRequestStatus.success) {
                          orderBloc.add(
                            GetOrdersByOrderGroupIDEvent(
                              orderGroupId: widget.order.orderGroupId ?? "",
                            ),
                          );
                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;

                          optionReturn.value = 0;
                          reasonCost.value = 0;
                          optionCansel.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                          showShadowForCancelAllOrder.value = false;
                          showShadowForConfirmOrder.value = false;
                        }
                      },
                      child: ValueListenableBuilder<int>(
                        valueListenable: returnBottomIndexTap,
                        builder: (context, _returnBottomIndexTap, _) {
                          return BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.confirmReturnRequestStatus !=
                                current.confirmReturnRequestStatus,
                            builder: (context, state) {
                              return (state.confirmReturnRequestStatus ==
                                      ConfirmReturnRequestStatus.loading)
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[500]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
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
                                          ConfirmReturnRequestEvent(
                                            orderGroupId:
                                                order?.orderGroupId ?? "",
                                            returnRequestId:
                                                returnRequestIdsToConfirm,
                                          ),
                                        );
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: agreeToPolicies,
                                        builder:
                                            (context, _agreeToPolicies, _) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                    ),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      agreeToPolicies.value ==
                                                          true
                                                      ? const Color(0xff3066CC)
                                                      : const Color(0xffC4C2C2),
                                                  border:
                                                      agreeToPolicies.value ==
                                                          true
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
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  LocaleKeys.i_agree_return
                                                      .tr(),
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
                                              );
                                            },
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 200,
                      height: 40.h,
                      child: BlocBuilder<OrderBloc, OrderState>(
                        buildWhen: (previous, current) =>
                            previous.confirmReturnRequestStatus !=
                            current.confirmReturnRequestStatus,
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              if (state.confirmReturnRequestStatus ==
                                  ConfirmReturnRequestStatus.loading) {
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
                              optionReturn.value = 0;
                              reasonCost.value = 0;
                              showShadowForConfirmOrder.value = false;
                              showShadowForCancelAllOrder.value = false;
                              optionCansel.value = [];
                              shadowForChangeVariant.value = false;
                            },
                            child: Text(
                              LocaleKeys.i_disagree.tr(),
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.18,
                                decorationColor: Colors.white,
                                decoration: TextDecoration.underline,
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

  Widget shadowForCancelAllOrder() {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForCancelAllOrder,
      builder: (context, _showShadowForCancelAllOrder, _) {
        List<String> images = [];

        orderBloc.state.getOrdersByOrderGroupIDModel?.orders?.forEach((
          element,
        ) {
          if (element.editReturnRequest ?? false
          /* &&
                                                      (element.editReturnRequest ??
                                                          false)*/
          ) {
            orderBloc.state.orderReturnDetailsModel?.data?.returnRequestsData
                ?.forEach((elements) {
                  elements.orderDetails?.forEach((element) {
                    if ((element.alreadyReturn ?? false) &&
                        elements.status?.value != "cancelled") {
                      images.add(element.image ?? "");
                    }
                  });
                });
          }
        });

        return !_showShadowForCancelAllOrder
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
                      LocaleKeys.about_return_your_product.tr(),
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 16,
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
                    order?.paymentStatus == "unpaid"
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    images.isEmpty
                        ? const SizedBox.shrink()
                        : Container(
                            height: 130.h,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: ListView.builder(
                              itemCount: images.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                height: 130.h,
                                width: 100,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  child: MyCachedNetworkImage(
                                    imageUrl: images[index],
                                    width: 100,
                                    imageFit: BoxFit.contain,
                                    height: 130.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                                const SizedBox(width: 5),
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
                    BlocListener<OrderBloc, OrderState>(
                      listenWhen: (previous, current) =>
                          previous.cancelReturnRequestStatus !=
                          current.cancelReturnRequestStatus,
                      listener: (context, state) {
                        if (state.cancelReturnRequestStatus ==
                            CancelReturnRequestStatus.success) {
                          orderBloc.add(
                            GetOrdersByOrderGroupIDEvent(
                              orderGroupId: widget.order.orderGroupId ?? "",
                            ),
                          );
                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;

                          optionReturn.value = 0;
                          reasonCost.value = 0;
                          optionCansel.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                          showShadowForCancelAllOrder.value = false;
                          showShadowForConfirmOrder.value = false;
                        }
                      },
                      child: ValueListenableBuilder<int>(
                        valueListenable: returnBottomIndexTap,
                        builder: (context, _returnBottomIndexTap, _) {
                          return BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.cancelReturnRequestStatus !=
                                current.cancelReturnRequestStatus,
                            builder: (context, state) {
                              return (state.cancelReturnRequestStatus ==
                                      CancelReturnRequestStatus.loading)
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[500]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
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
                                          CancelReturnRequestEvent(
                                            orderGroupId:
                                                order?.orderGroupId ?? "",
                                            returnRequestId:
                                                returnRequestIdsToCancel,
                                          ),
                                        );
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: agreeToPolicies,
                                        builder:
                                            (context, _agreeToPolicies, _) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                    ),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      agreeToPolicies.value ==
                                                          true
                                                      ? const Color(0xff3066CC)
                                                      : const Color(0xffC4C2C2),
                                                  border:
                                                      agreeToPolicies.value ==
                                                          true
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
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  LocaleKeys
                                                      .cancel_return_request
                                                      .tr(),
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
                                              );
                                            },
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 200,
                      height: 40.h,
                      child: BlocBuilder<OrderBloc, OrderState>(
                        buildWhen: (previous, current) =>
                            previous.cancelReturnRequestStatus !=
                            current.cancelReturnRequestStatus,
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              if (state.cancelReturnRequestStatus ==
                                  CancelReturnRequestStatus.loading) {
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
                              optionReturn.value = 0;
                              reasonCost.value = 0;
                              showShadowForCancelAllOrder.value = false;
                              showShadowForConfirmOrder.value = false;
                              optionCansel.value = [];
                              shadowForChangeVariant.value = false;
                            },
                            child: Text(
                              LocaleKeys.i_disagree.tr(),
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.18,
                                fontSize: 16.sp,
                                decorationColor: Colors.white,
                                decoration: TextDecoration.underline,
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

  Widget shadowForCanselOrRutuenOrder(int tapIndex) {
    return ValueListenableBuilder<bool>(
      valueListenable: showShadowForCanselOrder,
      builder: (context, _showShadowForCanselOrder, _) {
        List<String> images = [];
        returnRequestsData = orderBloc
            .state
            .orderReturnDetailsModel
            ?.data
            ?.returnRequestsData!
            .firstWhere(
              (element) => element.orderId == order?.id,
              orElse: () => ReturnRequestsDatum(),
            );
        orderDetails = returnRequestsData?.orderDetails ?? [];
        ReturnOrderDetail? orderDetail = orderDetails.firstWhere(
          (element) => element.detailId == order?.details?[indexTap.value].id,
          orElse: () => ReturnOrderDetail(),
        );

        orderBloc.state.orderReturnDetailsModel?.data?.returnRequestsData
            ?.forEach((element) {
              if ((element.status?.value ?? "").contains("draft") ||
                  (element.status?.name ?? "").contains("draft")) {
                element.orderDetails?.forEach((element) {
                  if (element.alreadyReturn ?? false) {
                    images.add(element.image ?? "");
                  }
                });
              }
            });
        images.add(orderDetail.image ?? "");

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
                      optionModifyPanel.value == "Return_This_Product"
                          ? LocaleKeys.about_return_your_product.tr()
                          : allOrder
                          ? LocaleKeys.about_cancel_order.tr()
                          : LocaleKeys.about_cancel_product.tr(),
                      style: context.textTheme.bodyMedium?.rq.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.18,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 45.h),
                    (optionModifyPanel.value == "Return_This_Product" &&
                            reasonCost.value != 0)
                        ? const SizedBox.shrink()
                        : Text(
                            LocaleKeys.you_will_not_charged_fees.tr(),
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.18,
                              fontSize: 16.sp,
                              height: 1.3,
                            ),
                          ),
                    SizedBox(height: 20.h),
                    order?.paymentStatus == "unpaid"
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    SizedBox(
                      height: optionModifyPanel.value == "Return_This_Product"
                          ? 0.h
                          : 160.h,
                    ),
                    optionModifyPanel.value != "Return_This_Product"
                        ? const SizedBox.shrink()
                        : Container(
                            height: 130.h,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: ListView.builder(
                              itemCount: images.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                height: 130.h,
                                width: 100,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  child: MyCachedNetworkImage(
                                    imageUrl: images[index],
                                    width: 100,
                                    imageFit: BoxFit.contain,
                                    height: 130.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                                const SizedBox(width: 5),
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
                    BlocListener<OrderBloc, OrderState>(
                      listenWhen: (previous, current) =>
                          previous.cancelOrderStatus !=
                              current.cancelOrderStatus ||
                          previous.storeReturnRequestProductStatus !=
                              current.storeReturnRequestProductStatus ||
                          previous.updateReturnRequestProductStatus !=
                              current.updateReturnRequestProductStatus ||
                          previous.cancelOrderItemStatus !=
                              current.cancelOrderItemStatus ||
                          previous.confirmReturnRequestStatus !=
                              current.confirmReturnRequestStatus,
                      listener: (context, state) {
                        if (state.cancelOrderStatus ==
                                CancelOrderStatus.success ||
                            state.cancelOrderItemStatus ==
                                CancelOrderItemStatus.success ||
                            (state.storeReturnRequestProductStatus ==
                                    StoreReturnRequestProductStatus.success &&
                                state.confirmReturnRequestStatus ==
                                    ConfirmReturnRequestStatus.success) ||
                            (state.updateReturnRequestProductStatus ==
                                    UpdateReturnRequestProductStatus.success &&
                                state.confirmReturnRequestStatus ==
                                    ConfirmReturnRequestStatus.success)) {
                          orderBloc.add(
                            GetOrdersByOrderGroupIDEvent(
                              orderGroupId: widget.order.orderGroupId ?? "",
                            ),
                          );
                          agreeToPolicies.value = false;
                          panelController.close();
                          showPanel.value = false;
                          optionModifyPanel.value = null;
                          enableChangeAddress.value = false;
                          showShadowForConfirmOrder.value = false;
                          showShadowForPanel.value = false;
                          showShadowForCanselOrder.value = false;
                          showShadowForCancelAllOrder.value = false;
                          optionReturn.value = 0;
                          reasonCost.value = 0;
                          optionCansel.value = [];
                          showShadowForChangeAddress.value = false;
                          shadowForChangeVariant.value = false;
                        }
                      },
                      child: ValueListenableBuilder<int>(
                        valueListenable: returnBottomIndexTap,
                        builder: (context, _returnBottomIndexTap, _) {
                          return BlocBuilder<OrderBloc, OrderState>(
                            buildWhen: (previous, current) =>
                                previous.cancelOrderStatus !=
                                    current.cancelOrderStatus ||
                                previous.cancelOrderItemStatus !=
                                    current.cancelOrderItemStatus ||
                                previous.storeReturnRequestProductStatus !=
                                    current.storeReturnRequestProductStatus ||
                                previous.updateReturnRequestProductStatus !=
                                    current.updateReturnRequestProductStatus ||
                                previous.confirmReturnRequestStatus !=
                                    current.confirmReturnRequestStatus,
                            builder: (context, state) {
                              return state.cancelOrderStatus ==
                                          CancelOrderStatus.loading ||
                                      state.cancelOrderItemStatus ==
                                          CancelOrderItemStatus.loading ||
                                      ((state.storeReturnRequestProductStatus ==
                                                  StoreReturnRequestProductStatus
                                                      .loading ||
                                              state.updateReturnRequestProductStatus ==
                                                  UpdateReturnRequestProductStatus
                                                      .loading ||
                                              state.confirmReturnRequestStatus ==
                                                  ConfirmReturnRequestStatus
                                                      .loading) &&
                                          _returnBottomIndexTap == 0)
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[500]!,
                                      highlightColor: Colors.grey[300]!,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
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
                                        if (!(optionModifyPanel.value ==
                                            "Return_This_Product")) {
                                          if (allOrder) {
                                            orderBloc.add(
                                              CancelOrderEvent(
                                                cancelOrderParams:
                                                    CancelOrderParams(
                                                      orderId: order!.id
                                                          .toString(),
                                                    ),
                                              ),
                                            );
                                          } else {
                                            orderBloc.add(
                                              CancelOrderItemEvent(
                                                cancelOrderItemParams:
                                                    CancelOrderItemParams(
                                                      orderId: order!.id
                                                          .toString(),
                                                      detailId:
                                                          order!
                                                              .details?[indexTap
                                                                  .value]
                                                              .id
                                                              .toString() ??
                                                          "",
                                                      qty:
                                                          (order!
                                                                  .details?[indexTap
                                                                      .value]
                                                                  .qty!
                                                                  .round())
                                                              .toString(),
                                                    ),
                                              ),
                                            );
                                          }
                                        } else {
                                          returnRequestIdsToConfirm = [];
                                          state
                                              .orderReturnDetailsModel
                                              ?.data
                                              ?.returnRequestsData
                                              ?.forEach((element) {
                                                if ((element.status?.value ??
                                                            "")
                                                        .contains("draft") ||
                                                    (element.status?.name ?? "")
                                                        .contains("draft")) {
                                                  element.orderDetails?.forEach((
                                                    element,
                                                  ) {
                                                    if (element.alreadyReturn ??
                                                        false) {
                                                      returnRequestIdsToConfirm
                                                          .add(
                                                            element
                                                                .returnRequestId
                                                                .toString(),
                                                          );
                                                    }
                                                  });
                                                }
                                              });

                                          returnBottomIndexTap.value = 0;
                                          returnRequestsData = state
                                              .orderReturnDetailsModel
                                              ?.data
                                              ?.returnRequestsData!
                                              .firstWhere(
                                                (element) =>
                                                    element.orderId ==
                                                    order?.id,
                                                orElse: () =>
                                                    ReturnRequestsDatum(),
                                              );
                                          orderDetails =
                                              returnRequestsData
                                                  ?.orderDetails ??
                                              [];
                                          ReturnOrderDetail?
                                          orderDetail = orderDetails.firstWhere(
                                            (element) =>
                                                element.detailId ==
                                                order
                                                    ?.details?[indexTap.value]
                                                    .id,
                                            orElse: () => ReturnOrderDetail(),
                                          );
                                          if (!(returnRequestIdsToConfirm
                                              .contains(
                                                orderDetail.returnRequestId
                                                    .toString(),
                                              ))) {
                                            returnRequestIdsToConfirm.add(
                                              orderDetail.returnRequestId
                                                  .toString(),
                                            );
                                          }
                                          if (!(orderDetail.alreadyReturn ??
                                              false)) {
                                            orderBloc.add(
                                              StoreReturnRequestProductEvent(
                                                orderGroupId:
                                                    order?.orderGroupId ?? "",
                                                withConfirm: true,
                                                returnRequestId:
                                                    returnRequestIdsToConfirm,
                                                params:
                                                    ReturnRequestProductParams(
                                                      details: "",
                                                      images: orderPhotos.value,
                                                      isForExchange: '0',
                                                      quantity:
                                                          qtyOfReturnValueNotifier
                                                              .value
                                                              .toString(),
                                                      returnRequestReasonId:
                                                          optionReturn.value
                                                              .toString(),
                                                      productId: orderDetail
                                                          .productId
                                                          .toString(),
                                                      returnRequestId:
                                                          orderDetail
                                                              .returnRequestId
                                                              .toString(),
                                                      orderDetailId: orderDetail
                                                          .detailId
                                                          .toString(),
                                                    ),
                                              ),
                                            );
                                          } else {
                                            orderBloc.add(
                                              UpdateReturnRequestProductEvent(
                                                orderGroupId:
                                                    order?.orderGroupId ?? "",
                                                withConfirm: true,
                                                returnRequestId:
                                                    returnRequestIdsToConfirm,
                                                params: UpdateReturnRequestProductParams(
                                                  details: "",
                                                  id:
                                                      (orderDetail.returnRequestProductId ??
                                                              0)
                                                          .toString(),
                                                  images: orderPhotos.value,
                                                  quantity:
                                                      qtyOfReturnValueNotifier
                                                          .value
                                                          .toString(),
                                                  returnRequestReasonId:
                                                      optionReturn.value
                                                          .toString(),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: agreeToPolicies,
                                        builder:
                                            (context, _agreeToPolicies, _) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                    ),
                                                alignment: Alignment.center,
                                                width: 1.sw,
                                                height: 50.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      agreeToPolicies.value ==
                                                          true
                                                      ? const Color(0xff3066CC)
                                                      : const Color(0xffC4C2C2),
                                                  border:
                                                      agreeToPolicies.value ==
                                                          true
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
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  optionModifyPanel.value ==
                                                          "Return_This_Product"
                                                      ? LocaleKeys
                                                            .i_agree_return
                                                            .tr()
                                                      : LocaleKeys
                                                            .i_agree_cancel
                                                            .tr(),
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
                                              );
                                            },
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    !(optionModifyPanel.value == "Return_This_Product") ||
                            (!((returnRequestsData?.status?.name ?? "")
                                    .contains("draft") ||
                                (returnRequestsData?.status?.value ?? "")
                                    .contains("draft") ||
                                (returnRequestsData?.status?.value ?? "")
                                    .contains("cancel")))
                        ? const SizedBox.shrink()
                        : BlocListener<OrderBloc, OrderState>(
                            listenWhen: (previous, current) =>
                                previous.storeReturnRequestProductStatus !=
                                    current.storeReturnRequestProductStatus ||
                                previous.updateReturnRequestProductStatus !=
                                    current.updateReturnRequestProductStatus,
                            listener: (context, state) {
                              if (state.storeReturnRequestProductStatus ==
                                      StoreReturnRequestProductStatus.success ||
                                  state.updateReturnRequestProductStatus ==
                                      UpdateReturnRequestProductStatus
                                          .success) {
                                orderBloc.add(
                                  GetOrdersByOrderGroupIDEvent(
                                    orderGroupId:
                                        widget.order.orderGroupId ?? "",
                                  ),
                                );
                                agreeToPolicies.value = false;
                                panelController.close();
                                showPanel.value = false;
                                optionModifyPanel.value = null;
                                enableChangeAddress.value = false;
                                showShadowForPanel.value = false;
                                showShadowForCanselOrder.value = false;
                                optionReturn.value = 0;
                                reasonCost.value = 0;
                                optionCansel.value = [];
                                showShadowForChangeAddress.value = false;
                                showShadowForConfirmOrder.value = false;
                                showShadowForCancelAllOrder.value = false;
                                shadowForChangeVariant.value = false;
                              }
                            },
                            child: ValueListenableBuilder<int>(
                              valueListenable: returnBottomIndexTap,
                              builder: (context, _returnBottomIndexTap, _) {
                                return BlocBuilder<OrderBloc, OrderState>(
                                  buildWhen: (previous, current) =>
                                      previous.storeReturnRequestProductStatus !=
                                          current
                                              .storeReturnRequestProductStatus ||
                                      previous.updateReturnRequestProductStatus !=
                                          current
                                              .updateReturnRequestProductStatus,
                                  builder: (context, state) {
                                    returnRequestIdsToConfirm = [];
                                    state
                                        .orderReturnDetailsModel
                                        ?.data
                                        ?.returnRequestsData
                                        ?.forEach((element) {
                                          if ((element.status?.value ?? "")
                                                  .contains("draft") ||
                                              (element.status?.name ?? "")
                                                  .contains("draft")) {
                                            element.orderDetails?.forEach((
                                              element,
                                            ) {
                                              if (element.alreadyReturn ??
                                                  false) {
                                                returnRequestIdsToConfirm.add(
                                                  element.returnRequestId
                                                      .toString(),
                                                );
                                              }
                                            });
                                          }
                                        });
                                    if (!(returnRequestIdsToConfirm.contains(
                                      orderDetail.returnRequestId.toString(),
                                    ))) {
                                      returnRequestIdsToConfirm.add(
                                        orderDetail.returnRequestId.toString(),
                                      );
                                    }
                                    return (state.storeReturnRequestProductStatus ==
                                                    StoreReturnRequestProductStatus
                                                        .loading ||
                                                state.updateReturnRequestProductStatus ==
                                                    UpdateReturnRequestProductStatus
                                                        .loading) &&
                                            _returnBottomIndexTap == 1
                                        ? Shimmer.fromColors(
                                            baseColor: Colors.grey[500]!,
                                            highlightColor: Colors.grey[300]!,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                  ),
                                              alignment: Alignment.center,
                                              width: 1.sw,
                                              height: 50.h,
                                              decoration: BoxDecoration(
                                                color:
                                                    agreeToPolicies.value ==
                                                        true
                                                    ? const Color(0xff3066CC)
                                                    : const Color(0xffC4C2C2),
                                                border:
                                                    agreeToPolicies.value ==
                                                        true
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
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              returnBottomIndexTap.value = 1;

                                              ReturnOrderDetail? orderDetail =
                                                  orderDetails.firstWhere(
                                                    (element) =>
                                                        element.detailId ==
                                                        order
                                                            ?.details?[indexTap
                                                                .value]
                                                            .id,
                                                    orElse: () =>
                                                        ReturnOrderDetail(),
                                                  );
                                              if (!(orderDetail.alreadyReturn ??
                                                  false)) {
                                                orderBloc.add(
                                                  StoreReturnRequestProductEvent(
                                                    orderGroupId:
                                                        order?.orderGroupId ??
                                                        "",
                                                    withConfirm: false,
                                                    returnRequestId:
                                                        returnRequestIdsToConfirm,
                                                    params: ReturnRequestProductParams(
                                                      details: "",
                                                      images: orderPhotos.value,
                                                      isForExchange: '0',
                                                      quantity:
                                                          qtyOfReturnValueNotifier
                                                              .value
                                                              .toString(),
                                                      returnRequestReasonId:
                                                          optionReturn.value
                                                              .toString(),
                                                      productId: orderDetail
                                                          .productId
                                                          .toString(),
                                                      returnRequestId:
                                                          orderDetail
                                                              .returnRequestId
                                                              .toString(),
                                                      orderDetailId: orderDetail
                                                          .detailId
                                                          .toString(),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                orderBloc.add(
                                                  UpdateReturnRequestProductEvent(
                                                    orderGroupId:
                                                        order?.orderGroupId ??
                                                        "",
                                                    withConfirm: false,
                                                    returnRequestId:
                                                        returnRequestIdsToConfirm,
                                                    params: UpdateReturnRequestProductParams(
                                                      details: "",
                                                      id:
                                                          (orderDetail.returnRequestProductId ??
                                                                  0)
                                                              .toString(),
                                                      images: orderPhotos.value,
                                                      quantity:
                                                          qtyOfReturnValueNotifier
                                                              .value
                                                              .toString(),
                                                      returnRequestReasonId:
                                                          optionReturn.value
                                                              .toString(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                  ),
                                              alignment: Alignment.center,
                                              width: 1.sw,
                                              height: 50.h,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  157,
                                                  183,
                                                  231,
                                                ),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xffF8F8F8,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                LocaleKeys
                                                    .i_want_returm_more_products
                                                    .tr(),
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
                                );
                              },
                            ),
                          ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 200,
                      height: 40.h,
                      child: BlocBuilder<OrderBloc, OrderState>(
                        buildWhen: (previous, current) =>
                            previous.cancelOrderStatus !=
                                current.cancelOrderStatus ||
                            previous.cancelOrderItemStatus !=
                                current.cancelOrderItemStatus ||
                            previous.updateReturnRequestProductStatus !=
                                current.updateReturnRequestProductStatus ||
                            previous.storeReturnRequestProductStatus !=
                                current.storeReturnRequestProductStatus,
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              if (state.cancelOrderStatus ==
                                      CancelOrderStatus.loading ||
                                  state.cancelOrderItemStatus ==
                                      CancelOrderItemStatus.loading ||
                                  state.storeReturnRequestProductStatus ==
                                      StoreReturnRequestProductStatus.loading ||
                                  state.updateReturnRequestProductStatus ==
                                      UpdateReturnRequestProductStatus
                                          .loading) {
                                return;
                              }
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              enableChangeAddress.value = false;
                              showShadowForConfirmOrder.value = false;
                              showShadowForPanel.value = false;
                              showShadowForCancelAllOrder.value = false;
                              showShadowForChangeAddress.value = false;
                              showShadowForCanselOrder.value = false;
                              optionReturn.value = 0;
                              reasonCost.value = 0;
                              optionCansel.value = [];
                              shadowForChangeVariant.value = false;
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
                          width: 50,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: addressInfoWithContactInfoCart(
                            isChange: true,
                            customerAddressesInfo: CustomerAddressesInfo(
                              address:
                                  order!.shippingAddressData?.address ?? '',
                              addressDetail:
                                  order!.shippingAddressData?.addressDetail ??
                                  '',
                              contactInfo: ContactInfo(
                                alternativePhone:
                                    order!
                                        .shippingAddressData
                                        ?.alternativePhone ??
                                    '',
                                name:
                                    order!
                                        .shippingAddressData
                                        ?.contactPersonName ??
                                    '',
                                phone: order!.shippingAddressData?.phone ?? '',
                              ),
                              id: order!.shippingAddressData?.id,
                              regionDetails: RegionDetails(
                                building:
                                    order!.shippingAddressData?.building ?? '',
                                city: order!.shippingAddressData?.city ?? '',
                                country:
                                    order!.shippingAddressData?.country ?? '',
                                province:
                                    order!.shippingAddressData?.province ?? '',
                                street:
                                    order!.shippingAddressData?.street ?? '',
                                town: order!.shippingAddressData?.town ?? '',
                              ),
                            ),
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
                                      state.listOfAddressInfoClassToSave![state
                                              .currentAddressChoosed ??
                                          0],
                                  fromEdid: true,
                                ),
                              );
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
                                    const SizedBox(width: 5),
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
                                  orderGroupId: order!.orderGroupId ?? "",
                                ),
                              );
                              agreeToPolicies.value = false;
                              panelController.close();
                              showPanel.value = false;
                              optionModifyPanel.value = null;
                              showShadowForCanselOrder.value = false;
                              enableChangeAddress.value = false;
                              showShadowForCancelAllOrder.value = false;
                              showShadowForConfirmOrder.value = false;
                              optionReturn.value = 0;
                              reasonCost.value = 0;
                              optionCansel.value = [];
                              showShadowForPanel.value = false;
                              showShadowForChangeAddress.value = false;
                              shadowForChangeVariant.value = false;
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
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
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
                                                      order!.orderGroupId ?? "",
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
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
                                                      BorderRadius.circular(15),
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
                        BlocBuilder<OrderBloc, OrderState>(
                          buildWhen: (previous, current) =>
                              previous.changeOrderAddressStatus !=
                              current.changeOrderAddressStatus,
                          builder: (context, state) {
                            return Container(
                              width: 200,
                              height: 40.h,
                              child: InkWell(
                                onTap: () {
                                  if (state.changeOrderAddressStatus ==
                                      ChangeOrderAddressStatus.loading) {
                                    return;
                                  }
                                  agreeToPolicies.value = false;
                                  panelController.close();
                                  showPanel.value = false;
                                  optionModifyPanel.value = null;
                                  optionReturn.value = 0;
                                  reasonCost.value = 0;
                                  optionCansel.value = [];
                                  enableChangeAddress.value = false;
                                  showShadowForPanel.value = false;
                                  showShadowForChangeAddress.value = false;
                                  showShadowForCancelAllOrder.value = false;
                                  showShadowForConfirmOrder.value = false;
                                  shadowForChangeVariant.value = false;
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
                              ),
                            );
                          },
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
                    qtyToChangeController.value = 0;
                    colorIndexTap.value = null;
                    // qtyOfReturnController.clear();
                    sizeIndexTap.value = null;
                    qtyOfReturnValueNotifier.value = 0;
                    agreeToPolicies.value = false;
                    variantHasBeenChanged.value = false;
                    showPanel.value = false;
                    optionModifyPanel.value = null;
                    enableChangeAddress.value = false;
                    showShadowForConfirmOrder.value = false;
                    showShadowForCancelAllOrder.value = false;
                    showShadowForPanel.value = false;
                    optionReturn.value = 0;
                    reasonCost.value = 0;
                    optionCansel.value = [];
                    showShadowForChangeAddress.value = false;

                    showShadowForCanselOrder.value = false;
                    shadowForChangeVariant.value = false;
                  },
                  onPanelOpened: () {},
                  minHeight: 0,
                  maxHeight: _option == null ? 524 : (1.sh - 70),
                  panelBuilder: (sc) => panelBuilderContent(_option, sc),
                ),
              );
            },
          ),
        );
      },
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
                (element) => element.id == order!.shippingAddressData?.id,
              ) ??
              -1;
          firstAddressChoosed = indexTapAddress.value;
          if (indexTapAddress.value != firstAddressChoosed ||
              (state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .address !=
                      order!.shippingAddressData?.address ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .addressDetail !=
                      order!.shippingAddressData?.addressDetail ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.name !=
                      order!.shippingAddressData?.contactPersonName ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.phone !=
                      order!.shippingAddressData?.phone ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.country !=
                      order!.shippingAddressData?.country ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.city !=
                      order!.shippingAddressData?.city ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.province !=
                      order!.shippingAddressData?.province ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.street !=
                      order!.shippingAddressData?.street ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.building !=
                      order!.shippingAddressData?.building ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .regionDetails
                          ?.town !=
                      order!.shippingAddressData?.town ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .location
                          ?.latitude !=
                      order!.shippingAddressData?.latitude ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .location
                          ?.longitude !=
                      order!.shippingAddressData?.longitude ||
                  state
                          .listOfAddressInfoClassToSave![indexTapAddress.value]
                          .contactInfo
                          ?.alternativePhone !=
                      order!.shippingAddressData?.alternativePhone)) {
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
            valueListenable: indexTapAddress,
            builder: (context, _indexTap, _) {
              return Column(
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xffC4C2C2),
                      border: Border.all(color: const Color(0xffC4C2C2)),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 1.sw,
                    height: 200.h,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      border: Border.all(color: const Color(0xffF8F8F8)),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                              const SizedBox(width: 10),
                              SvgPicture.asset(
                                AppAssets.orderClockSvg,
                                height: 15.h,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                HelperFunctions.orderFormatDate(
                                  DateTime.tryParse(order!.createdAt ?? '') ??
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
                              const SizedBox(width: 5),
                              Text(
                                order!.orderGroupId ?? "",
                                style: context.textTheme.bodyMedium?.mq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height: 1.3,
                                    ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: 1.sw,
                          height: 16.h,
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              SvgPicture.asset(
                                AppAssets.preparingBagSvg,
                                height: 15.h,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                order!.orderGroupStatus?.label ?? "",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height: 1.3,
                                    ),
                              ),
                              const SizedBox(width: 5),
                              SvgPicture.asset(
                                order!.orderGroupStatus?.value == 'canceled'
                                    ? AppAssets.orderCanselSvg
                                    : order!.orderGroupStatus?.value ==
                                          'shipped'
                                    ? AppAssets.shippedBlackSvg
                                    : (order!.orderGroupStatus?.value ==
                                              'delivered' ||
                                          (order!.orderGroupStatus?.value ?? "")
                                              .contains("return"))
                                    ? AppAssets.deliveredBlackSvg
                                    : order!.orderGroupStatus?.value ==
                                          'pending'
                                    ? AppAssets.pendeingBlackCheck
                                    : AppAssets.orderPreparingSvg,
                                height: 15.h,
                              ),
                              const Spacer(),
                              SvgPicture.asset(
                                AppAssets.orderInvoice2Svg,
                                height: 15.h,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                (order!.details?.length ?? "").toString(),
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12.sp,
                                      height: 1.3,
                                    ),
                              ),
                              const SizedBox(width: 5),
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
                              const SizedBox(width: 5),
                              Text(
                                HelperFunctions.formatNumber(
                                  numberToFormate:
                                      (HelperFunctions.truncateToDecimalPlaces(
                                        order!.orderAmount!,
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
                              const SizedBox(width: 5),
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
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 125.h,
                          width: 1.sw,
                          padding: EdgeInsets.only(
                            left: LanguageService.languageCode == "ar" ? 0 : 10,
                            right: LanguageService.languageCode != "ar"
                                ? 0
                                : 10,
                          ),
                          child: ListView.builder(
                            itemCount: order!.details?.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 125.h,
                                width: 92,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  child: MyCachedNetworkImage(
                                    imageUrl:
                                        order!.details?[index].image ?? "",
                                    width: 92,
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
                  SizedBox(height: 10.h),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Color(0xffC4C2C2)),
                  ),
                  SizedBox(height: 10.h),
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
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          width: 1.sw,
                          height: 53.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _enableChangeAddress
                                ? const Color(0xff402CDD)
                                : const Color(0xffD3D3D3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${LocaleKeys.change_request.tr()} ",
                            style: context.textTheme.bodyMedium?.mq.copyWith(
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
      ),
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
          (index == ((order.details?.length ?? 0) - 1))
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
        children: [
          SizedBox(height: 10.h),
          Container(
            height: 50.h,
            width: 1.sw,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xffF8F8F8),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  width: ((1.sw - 58) / 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff402CDD)),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    LocaleKeys.delivery_address.tr(),
                    style: context.textTheme.bodyMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
                      height: 1.33,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  width: ((1.sw - 58) / 2),
                  decoration: const BoxDecoration(
                    //   border: Border.all(color: Color(0xff402CDD)),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    LocaleKeys.delivery_note.tr(),
                    style: context.textTheme.bodyMedium?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.18,
                      fontSize: 14,
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
                    fontSize: 12,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemBuilder: (context, index) =>
                            index == state.listOfAddressInfoClassToSave!.length
                            ? SizedBox(height: 50, width: 1.sw)
                            : InkWell(
                                onTap: () {
                                  if (index != firstAddressChoosed ||
                                      (state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .address !=
                                              order!
                                                  .shippingAddressData
                                                  ?.address ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .addressDetail !=
                                              order!
                                                  .shippingAddressData
                                                  ?.addressDetail ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.name !=
                                              order!
                                                  .shippingAddressData
                                                  ?.contactPersonName ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.phone !=
                                              order!
                                                  .shippingAddressData
                                                  ?.phone ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.country !=
                                              order!
                                                  .shippingAddressData
                                                  ?.country ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.city !=
                                              order!
                                                  .shippingAddressData
                                                  ?.city ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.province !=
                                              order!
                                                  .shippingAddressData
                                                  ?.province ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.street !=
                                              order!
                                                  .shippingAddressData
                                                  ?.street ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.building !=
                                              order!
                                                  .shippingAddressData
                                                  ?.building ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .regionDetails
                                                  ?.town !=
                                              order!
                                                  .shippingAddressData
                                                  ?.town ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .location
                                                  ?.latitude !=
                                              order!
                                                  .shippingAddressData
                                                  ?.latitude ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .location
                                                  ?.longitude !=
                                              order!
                                                  .shippingAddressData
                                                  ?.longitude ||
                                          state
                                                  .listOfAddressInfoClassToSave![index]
                                                  .contactInfo
                                                  ?.alternativePhone !=
                                              order!
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
                            const SizedBox(height: 10),
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
                          height: 40,
                          width: 1.sw - 56,

                          decoration: BoxDecoration(
                            color: const Color(0xffE8FFED),
                            borderRadius: BorderRadius.circular(15),
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
                              const SizedBox(width: 3),
                              Text(
                                "${LocaleKeys.add_new_shipping_address.tr()} ",
                                style: context.textTheme.bodyMedium?.mq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
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
      margin: const EdgeInsets.all(1),
      width: 1.sw,
      // height: 100.h,
      padding: EdgeInsets.only(
        right: LanguageService.languageCode == "ar" ? 19 : 9,
        left: LanguageService.languageCode != "ar" ? 19 : 9,
        bottom: 5,
        top: 1,
      ),
      decoration: BoxDecoration(
        color: isChange ? Colors.transparent : const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
        border: isChange
            ? Border.all(
                color: (index != indexTap)
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
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
                  width: 12,
                ),
                const SizedBox(width: 5),
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
                          margin: const EdgeInsets.only(top: 5),
                          width: 20,
                          height: 30.h,
                          child: SvgPicture.asset(
                            AppAssets.editSvg,
                            height: 30,
                            width: 20.h,
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
          SizedBox(
            width: 350.w,
            height: 20.h,
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
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
                  width: 12,
                ),
                const SizedBox(width: 5),
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
                    fontSize: 12.h,
                    height: 1.3,
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
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
                        width: 12,
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 130,
                        child: Text(
                          '${customerAddressesInfo.contactInfo?.name ?? ""}',
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
      ),
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
    if (_option == "Cancel") {
      return panelCanelContent(sc);
    }
    if (_option == "Return_This_Product") {
      return panelReturnedContent(sc);
    }
    if (_option == "Change_Product_Request") {
      return panelVaraintContent(sc);
    }
    ReturnOrderDetail? orderDetail = orderDetails.firstWhere(
      (element) => element.detailId == order!.details?[indexTap.value].id,
      orElse: () => ReturnOrderDetail(),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      height: _option == null ? 524 : (1.sh - 85.h),
      width: 1.sw,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xffC4C2C2),
              border: Border.all(color: const Color(0xffC4C2C2)),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 104,
            height: 144,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.white,
                child: MyCachedNetworkImage(
                  withInnerShadow: true,
                  withImageShadow: true,
                  radius: 15,
                  imageUrl: order!.details?[indexTap.value].image ?? "",
                  imageFit: BoxFit.contain,
                  width: 100,
                  height: 150,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${LocaleKeys.action_about_product.tr()}",
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff8D8D8D),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 1.sw,
            height: 0.5,
            decoration: BoxDecoration(
              color: const Color(0xffC4C2C2),
              border: Border.all(color: const Color(0xffC4C2C2)),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          BlocListener<OrderBloc, OrderState>(
            listenWhen: (previous, current) =>
                previous.getProductColorSizeSyncAttributeStatus !=
                current.getProductColorSizeSyncAttributeStatus,
            listener: (context, state) {
              if (state.getProductColorSizeSyncAttributeStatus ==
                  GetProductColorSizeSyncAttributeStatus.success) {
                firstVariant = order!.details![indexTap.value].variant;
                productColors =
                    state.colorSizeForProductModel?.data?.colors ?? [];
                productSyncColorImages =
                    state.colorSizeForProductModel?.data?.syncColorImages ?? [];
                productChoiceOptions =
                    state.colorSizeForProductModel?.data?.choiceOptions ?? [];
                if (productColors.isNotEmpty) {
                  firstColorOption =
                      order!.details![indexTap.value].variant
                          ?.split("-")
                          .toList()
                          .first ??
                      "";
                }
                if (productChoiceOptions.isNotEmpty) {
                  firstSizeOption =
                      order!.details![indexTap.value].variant
                          ?.split("-")
                          .toList()
                          .last ??
                      "";
                  firstSizeName = productChoiceOptions[0].options!
                      .firstWhere(
                        (element) => element.option == firstSizeOption,
                        orElse: () => Option(
                          option: firstSizeOption,
                          name: firstSizeOption,
                        ),
                      )
                      .name;
                }
                firstColorNum = state.colorSizeForProductModel?.data?.colors
                    ?.firstWhere(
                      (element) => element.option == firstColorOption,
                      orElse: () =>
                          ProductColor(color: "", name: "", option: ""),
                    )
                    .color;
                firstColorName = state.colorSizeForProductModel?.data?.colors
                    ?.firstWhere(
                      (element) => element.option == firstColorOption,
                      orElse: () =>
                          ProductColor(color: "", name: "", option: ""),
                    )
                    .name;

                if (productColors.isNotEmpty) {
                  productColors.removeWhere(
                    (element) => element.option == firstColorOption,
                  );
                  productSyncColorImages.removeWhere(
                    (element) => element.colorOption == firstColorOption,
                  );
                }
                if (productChoiceOptions.isNotEmpty) {
                  productChoiceOptions[0].options?.removeWhere(
                    (element) => element.option == firstSizeOption,
                  );
                }
                if (productColors.isNotEmpty) {
                  optionVariant.value = "color";
                } else if (productChoiceOptions.isNotEmpty) {
                  if ((productChoiceOptions[0].options?.length ?? 0) > 0) {
                    optionVariant.value = "size";
                  } else {
                    optionVariant.value = "qty";
                  }
                } else {
                  optionVariant.value = "qty";
                }
                qtyToChangeController.value =
                    order!.details?[indexTap.value].qty?.round() ?? 0;
                optionModifyPanel.value = "Change_Product_Request";
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BlocBuilder<OrderBloc, OrderState>(
                buildWhen: (previous, current) =>
                    previous.getProductColorSizeSyncAttributeStatus !=
                    current.getProductColorSizeSyncAttributeStatus,
                builder: (context, state) {
                  if (state.getProductColorSizeSyncAttributeStatus ==
                      GetProductColorSizeSyncAttributeStatus.loading) {
                    return Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 1.sw,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xffF8F8F8),
                          ),
                        ),
                      ),
                    );
                  }
                  return (order!.details?[indexTap.value].qty ?? 0) == 0 ||
                          (!(order!.canChangeVariant ?? false))
                      ? const SizedBox.shrink()
                      : optionOfModify(
                          onTap: () {
                            orderBloc.add(const ResetAllStatusEvent());
                            orderBloc.add(
                              GetProductColorSizeSyncAttributeEvent(
                                id:
                                    order!.details?[indexTap.value].productId
                                        .toString() ??
                                    "",
                              ),
                            );
                          },
                          svg: AppAssets.changeProductRequestSvg,
                          image2: order!.details?[indexTap.value].image ?? "",
                          tiltle: "${LocaleKeys.change_product_request.tr()}",
                          body: "${LocaleKeys.change_size_color_other.tr()}",
                        );
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          ((orderDetail.alreadyReturn ?? false) &&
                  !(order?.editReturnRequest ?? false))
              ? const SizedBox.shrink()
              : ((order?.canReturnOrder ??
                        false || (order?.editReturnRequest ?? false)) &&
                    (order!.details?[indexTap.value].qty ?? 0) > 0)
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: optionOfModify(
                    onTap: () {
                      orderBloc.add(const ResetAllStatusEvent());
                      optionModifyPanel.value = "Return_This_Product";
                      if ((orderDetail.alreadyReturn ?? false) &&
                          (order?.editReturnRequest ?? false) &&
                          (!(returnRequestsData?.status?.value ?? "").contains(
                            "cancel",
                          ))) {
                        //      qtyOfReturnController.text =
                        //    (orderDetails?.quantity ?? "").toString();
                        qtyOfReturnValueNotifier.value =
                            orderDetail.quantity ?? 0;
                        optionReturn.value =
                            orderDetail.returnRequestProductReasonId ?? 0;
                        ReturnReasonModel? reason = orderBloc
                            .state
                            .returnReasonsModel
                            ?.data
                            ?.returnReasons!
                            .firstWhere(
                              (element) =>
                                  element.id ==
                                  orderDetail.returnRequestProductReasonId,
                              orElse: () => ReturnReasonModel(cost: 0),
                            );
                        reasonCost.value = (reason?.isCostBySystem == 1)
                            ? 0
                            : reason?.cost ?? 0;
                        orderBloc.add(
                          StoreImagesForUpdateReturnEvent(
                            images: orderDetail.img ?? [],
                          ),
                        );
                      } else {
                        qtyOfReturnValueNotifier.value =
                            (order?.details?[indexTap.value].qty ?? 0).round();
                        orderBloc.add(
                          const StoreImagesForUpdateReturnEvent(images: []),
                        );
                      }
                    },
                    svg: AppAssets.returnThisProductSvg,
                    image2: "",
                    tiltle:
                        "${orderDetail.returnRequestProductId != null && returnRequestsData?.status?.value != "cancelled" && order?.returnRequestId != null && (order?.editReturnRequest ?? false) ? LocaleKeys.edit_return_request.tr() : LocaleKeys.return_this_product.tr()}",
                    body:
                        "${LocaleKeys.return_this_product_in_24_hours_and_back_your_money.tr()}",
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: optionOfModify(
              onTap: () {
                orderBloc.add(const ResetAllStatusEvent());
                optionModifyPanel.value = "Report_This_Product";
              },
              svg: AppAssets.reporthisProductSvg,
              image2: "",
              tiltle: "${LocaleKeys.report_this_product.tr()}",
              body:
                  "${LocaleKeys.delivery_time_delivery_man_delivery_car.tr()}",
            ),
          ),
          (order?.canCanceleOrder ?? false)
              ? const SizedBox(height: 5)
              : const SizedBox.shrink(),
          (order?.canCanceleOrder ?? false) &&
                  (order!.details?[indexTap.value].qty ?? 0) > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: optionOfModify(
                    onTap: () {
                      orderBloc.add(const ResetAllStatusEvent());
                      optionModifyPanel.value = "Cancel";
                    },
                    svg: AppAssets.orderCanselSvg,
                    image2: "",
                    tiltle: "${LocaleKeys.cancel_this_product.tr()}",
                    body: LocaleKeys.cancel_product_hours_back_money.tr(
                      args: ['3'],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 5),

          /*  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: optionOfModify(
                    onTap: () { orderBloc.add(ResetAllStatusEvent());
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
                orderBloc.add(const ResetAllStatusEvent());
                optionModifyPanel.value = "Hide_This_Product";
              },
              svg: AppAssets.hideThisProductSvg,
              image2: "",
              tiltle: "${LocaleKeys.hide_this_product.tr()}",
              body: "${LocaleKeys.hide_this_product_from_list.tr()}",
            ),
          ),
        ],
      ),
    );
  }

  Widget panelCanelContent(ScrollController sc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 10.h),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        SizedBox(height: 15.h),
        allOrder
            ? Container(
                width: 1.sw,
                height: 205.h,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F8F8),
                  border: Border.all(color: const Color(0xffF8F8F8)),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            AppAssets.orderClockSvg,
                            height: 15.h,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            HelperFunctions.orderFormatDate(
                              DateTime.tryParse(order!.createdAt ?? '') ??
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
                          SvgPicture.asset(
                            AppAssets.orderBag1Svg,
                            height: 15.h,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order!.orderGroupId ?? "",
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 1.sw,
                      height: 16.h,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            AppAssets.preparingBagSvg,
                            height: 15.h,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order!.orderGroupStatus?.label ?? "",
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 11.sp,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(width: 5),
                          SvgPicture.asset(
                            order!.orderGroupStatus?.value == 'canceled'
                                ? AppAssets.orderCanselSvg
                                : order!.orderGroupStatus?.value == 'shipped'
                                ? AppAssets.shippedBlackSvg
                                : (order!.orderGroupStatus?.value ==
                                          'delivered' ||
                                      (order!.orderGroupStatus?.value ?? "")
                                          .contains("return"))
                                ? AppAssets.deliveredBlackSvg
                                : order!.orderGroupStatus?.value == 'pending'
                                ? AppAssets.pendeingBlackCheck
                                : AppAssets.orderPreparingSvg,
                            height: 15.h,
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            AppAssets.orderInvoice2Svg,
                            height: 15.h,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            (order!.details?.length ?? "").toString(),
                            style: context.textTheme.bodyMedium?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            LocaleKeys.item.tr(),
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              fontSize: 12.sp,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            HelperFunctions.formatNumber(
                              numberToFormate:
                                  (HelperFunctions.truncateToDecimalPlaces(
                                    order!.orderAmount!,
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
                          const SizedBox(width: 5),
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
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 125.h,
                      width: 1.sw,
                      padding: EdgeInsets.only(
                        left: LanguageService.languageCode == "ar" ? 0 : 10,
                        right: LanguageService.languageCode != "ar" ? 0 : 10,
                      ),
                      child: ListView.builder(
                        itemCount: order!.details?.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 125.h,
                            width: 92,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              child: MyCachedNetworkImage(
                                imageUrl: order!.details?[index].image ?? "",
                                width: 92,
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
              )
            : Container(
                width: 104,
                height: 140.h,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: MyCachedNetworkImage(
                      withInnerShadow: true,
                      withImageShadow: true,
                      radius: 15,
                      imageUrl: order!.details?[indexTap.value].image ?? "",
                      imageFit: BoxFit.contain,
                      width: 100,
                      height: 140.h,
                    ),
                  ),
                ),
              ),
        SizedBox(height: 8.h),
        SvgPicture.asset(AppAssets.orderCanselSvg, width: 30),
        SizedBox(height: 14.h),
        Text(
          "${allOrder ? LocaleKeys.cancel_this_order.tr() : LocaleKeys.cancel_this_product.tr()}",
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
              "  ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((((allOrder ? order!.orderAmount! : ((order!.details?[indexTap.value].priceAfterDiscount ?? 0))))), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!) * (order!.details?[indexTap.value].qty ?? 0)), isNeedRounding: false)}",
              maxLines: 1,
              style: context.textTheme.bodyMedium?.bq.copyWith(
                color: const Color(0xff8D8D8D),
                letterSpacing: 0.18,
                fontSize: 12.sp,
                height: 1.3,
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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        SizedBox(height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${allOrder ? LocaleKeys.why_was_order_cancelled.tr() : LocaleKeys.why_was_product_cancel.tr()} ",
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
  }

  Widget panelVaraintContent(ScrollController sc) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          width: 104,
          height: 140.h,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              color: Colors.white,
              child: MyCachedNetworkImage(
                withInnerShadow: true,
                withImageShadow: true,
                radius: 15,
                imageUrl: order!.details?[indexTap.value].image ?? "",
                imageFit: BoxFit.contain,
                width: 100,
                height: 140,
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.changeProductRequestSvg,
              width: 30,
              // ignore: deprecated_member_use
              color: const Color(0xff1D1D1D),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: MyCachedNetworkImage(
                radius: 15,
                imageUrl: order!.details?[indexTap.value].image ?? "",
                imageFit: BoxFit.fill,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          "${LocaleKeys.change_product_request.tr()}",
          style: context.textTheme.bodyMedium?.mq.copyWith(
            color: const Color(0xff1D1D1D),
            letterSpacing: 0.18,
            fontSize: 14,
            height: 1.3,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Text(
            "${LocaleKeys.you_can_change_variant_product_without_conditions.tr()}",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff8D8D8D),
              letterSpacing: 0.18,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 1.sw,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 0.5,
          decoration: BoxDecoration(
            color: const Color(0xffC4C2C2),
            border: Border.all(color: const Color(0xffC4C2C2)),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(height: 10),
        changeSizeOrColorOrQty(),
        const Spacer(),
        ValueListenableBuilder<String?>(
          valueListenable: optionVariant,
          builder: (context, _option, _) {
            return ValueListenableBuilder<int?>(
              valueListenable: colorIndexTap,
              builder: (context, _colorIndexTap, _) {
                return ValueListenableBuilder<int?>(
                  valueListenable: sizeIndexTap,
                  builder: (context, _sizeIndexTap, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: qtyToChangeController,
                      builder: (context, _qtyToChangeController, _) {
                        return InkWell(
                          onTap: () {
                            if (_sizeIndexTap != null ||
                                _colorIndexTap != null ||
                                ((_qtyToChangeController !=
                                    (order!.details?[indexTap.value].qty!
                                        .round())))) {
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
                                color:
                                    (_sizeIndexTap != null ||
                                        ((_qtyToChangeController !=
                                            (order!
                                                .details?[indexTap.value]
                                                .qty!
                                                .round()))) ||
                                        _colorIndexTap != null)
                                    ? const Color(0xff402CDD)
                                    : const Color(0xffD3D3D3),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                "${LocaleKeys.change_request.tr()}",
                                maxLines: 1,
                                style: context.textTheme.bodyMedium?.mq
                                    .copyWith(
                                      color: Colors.white,
                                      letterSpacing: 0.18,
                                      fontSize: 16,
                                      height: 1.3,
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget changeSizeOrColorOrQty() {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.getProductColorSizeSyncAttributeStatus !=
          current.getProductColorSizeSyncAttributeStatus,
      builder: (context, state) {
        return ValueListenableBuilder<String?>(
          valueListenable: optionVariant,
          builder: (context, _option, _) {
            return Column(
              children: [
                Container(
                  width: 1.sw,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 50.h,
                  decoration: const BoxDecoration(
                    color: Color(0xffF8F8F8),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      productColors.isEmpty
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                optionVariant.value = "color";
                                sizeIndexTap.value = null;
                                qtyToChangeController.value =
                                    order!.details?[indexTap.value].qty
                                        ?.round() ??
                                    0;
                              },
                              child: Container(
                                height: 50.h,
                                alignment: Alignment.center,
                                width: (1.sw - 48) / 3,
                                decoration: BoxDecoration(
                                  border: _option == "color"
                                      ? Border.all(
                                          color: const Color(0xff402CDD),
                                        )
                                      : null,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "${LocaleKeys.change_color.tr()}",
                                  textAlign: TextAlign.center,
                                  style: _option == "color"
                                      ? context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.3,
                                            )
                                      : context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.3,
                                            ),
                                ),
                              ),
                            ),
                      (productChoiceOptions.isEmpty)
                          ? const SizedBox.shrink()
                          : (productChoiceOptions[0].options?.isEmpty ?? false)
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                qtyToChangeController.value =
                                    order!.details?[indexTap.value].qty
                                        ?.round() ??
                                    0;
                                optionVariant.value = "size";
                                colorIndexTap.value = null;
                              },
                              child: Container(
                                height: 50.h,
                                alignment: Alignment.center,
                                width: (1.sw - 48) / 3,
                                decoration: BoxDecoration(
                                  border: _option == "size"
                                      ? Border.all(
                                          color: const Color(0xff402CDD),
                                        )
                                      : null,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "${LocaleKeys.change_size.tr()}",
                                  textAlign: TextAlign.center,
                                  style: _option == "size"
                                      ? context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.3,
                                            )
                                      : context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: const Color(0xff1D1D1D),
                                              letterSpacing: 0.18,
                                              fontSize: 14.sp,
                                              height: 1.3,
                                            ),
                                ),
                              ),
                            ),
                      InkWell(
                        onTap: () {
                          optionVariant.value = "qty";
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.h,
                          width: (1.sw - 48) / 3,
                          decoration: BoxDecoration(
                            border: _option == "qty"
                                ? Border.all(color: const Color(0xff402CDD))
                                : null,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            "${LocaleKeys.change_qty.tr()}",
                            textAlign: TextAlign.center,
                            style: _option == "qty"
                                ? context.textTheme.bodyMedium?.mq.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14.sp,
                                    height: 1.3,
                                  )
                                : context.textTheme.bodyMedium?.rq.copyWith(
                                    color: const Color(0xff1D1D1D),
                                    letterSpacing: 0.18,
                                    fontSize: 14.sp,
                                    height: 1.3,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    child: MyCachedNetworkImage(
                      withInnerShadow: true,
                      withImageShadow: true,
                      radius: 15,
                      imageUrl: order!.details?[indexTap.value].image ?? "",
                      imageFit: BoxFit.fill,
                      width: 70.w,
                      height: 70.h,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${LocaleKeys.change_from.tr()} ${(_option == "color")
                      ? "${firstColorName}"
                      : (_option == "size")
                      ? "${firstSizeName}"
                      : "${LocaleKeys.qty.tr()} ${order!.details?[indexTap.value].qty?.round()}"}",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    letterSpacing: 0.18,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 1.sw,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 0.5,
                  decoration: BoxDecoration(
                    color: const Color(0xffC4C2C2),
                    border: Border.all(color: const Color(0xffC4C2C2)),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                SizedBox(height: 10.h),
                (_option == "color")
                    ? Text(
                        "${LocaleKeys.to_new_color.tr()} ?",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      )
                    : (_option == "size")
                    ? Text(
                        "${LocaleKeys.to_new_size.tr()} ?",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      )
                    : Text(
                        LocaleKeys.to_qty.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14.sp,
                          height: 1.3,
                        ),
                      ),
                SizedBox(height: 15.h),
                (_option == "color")
                    ? ValueListenableBuilder<int?>(
                        valueListenable: colorIndexTap,
                        builder: (context, _colorIndexTap, _) {
                          return Container(
                            width: 1.sw,
                            height: 105.h,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  state
                                          .colorSizeForProductModel
                                          ?.data
                                          ?.syncColorImages
                                          ?.length ??
                                      0,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        String newVariant =
                                            '${productSyncColorImages[index].colorOption}${(firstSizeOption == null || firstSizeOption == "") ? "" : '-'}${firstSizeOption}';
                                        int? newVariantQty = state
                                            .colorSizeForProductModel
                                            ?.data
                                            ?.variation
                                            ?.firstWhere(
                                              (element) =>
                                                  element.type == newVariant,
                                            )
                                            .qty;
                                        double? newVariantPrice = state
                                            .colorSizeForProductModel
                                            ?.data
                                            ?.variation
                                            ?.firstWhere(
                                              (element) =>
                                                  element.type == newVariant,
                                            )
                                            .offerPrice;
                                        if ((order!
                                                        .details?[indexTap
                                                            .value]
                                                        .qty ??
                                                    0) >
                                                (newVariantQty ?? 0) &&
                                            (state
                                                    .colorSizeForProductModel
                                                    ?.data
                                                    ?.collectedAfterOrdering ==
                                                0)) {
                                          showMessage(
                                            LocaleKeys.not_available_now_stock
                                                .tr(),
                                            hasError: true,
                                            context: context,
                                          );
                                          return;
                                        }
                                        if (((order!
                                                        .details?[indexTap
                                                            .value]
                                                        .priceAfterDiscount ??
                                                    0) /
                                                (order!
                                                        .details?[indexTap
                                                            .value]
                                                        .qty ??
                                                    1)) <
                                            (newVariantPrice ?? 0)) {
                                          if (((((newVariantPrice ?? 0) -
                                                          ((order!
                                                                      .details?[indexTap
                                                                          .value]
                                                                      .priceAfterDiscount ??
                                                                  0) /
                                                              (order!
                                                                      .details?[indexTap
                                                                          .value]
                                                                      .qty ??
                                                                  1))) *
                                                      (order!
                                                              .details?[indexTap
                                                                  .value]
                                                              .qty ??
                                                          0)) *
                                                  (GetIt.I<HomeBloc>()
                                                      .state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .exchangeRate!)) >
                                              (state
                                                      .customerWalletModel
                                                      ?.data
                                                      .totalWalletBalance ??
                                                  0)) {
                                            showMessage(
                                              '${LocaleKeys.you_dont_have_enough_credit_in_the_wallet.tr()} , new price : ${(newVariantPrice ?? 0) * ((order!.details?[indexTap.value].qty ?? 0)) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)} ${(GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.symbol!)}',
                                              hasError: true,
                                              context: context,
                                            );
                                            return;
                                          }
                                        }

                                        if (_colorIndexTap == index) {
                                          colorIndexTap.value = null;
                                          return;
                                        }
                                        colorIndexTap.value = index;
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 70.w,
                                              height: 70.h,
                                              decoration: BoxDecoration(
                                                border: _colorIndexTap == index
                                                    ? Border.all(
                                                        color: const Color(
                                                          0xff402CDD,
                                                        ),
                                                      )
                                                    : null,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                      Radius.circular(40),
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                      Radius.circular(40),
                                                    ),
                                                child: MyCachedNetworkImage(
                                                  withInnerShadow: true,
                                                  withImageShadow: true,
                                                  radius: 40,
                                                  imageUrl:
                                                      productSyncColorImages[index]
                                                          .images?[0] ??
                                                      "",
                                                  imageFit: BoxFit.fill,
                                                  width: 70.w,
                                                  height: 70.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            productColors[index].name ?? "",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  color: _colorIndexTap == index
                                                      ? const Color(0xff402CDD)
                                                      : const Color(0xff5D5C5D),
                                                  letterSpacing: 0.18,
                                                  fontSize: 14.sp,
                                                  height: 1.3,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : (_option == "size")
                    ? ValueListenableBuilder<int?>(
                        valueListenable: sizeIndexTap,
                        builder: (context, _sizeIndexTap, _) {
                          return Container(
                            width: 1.sw,
                            height: 105.h,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  productChoiceOptions[0].options?.length ?? 0,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        String newVariant =
                                            '${firstColorOption}${(firstColorOption == null || firstColorOption == "") ? "" : '-'}${productChoiceOptions[0].options?[index].option}';

                                        int? newVariantQty = state
                                            .colorSizeForProductModel
                                            ?.data
                                            ?.variation
                                            ?.firstWhere(
                                              (element) =>
                                                  element.type == newVariant,
                                            )
                                            .qty;
                                        double? newVariantPrice = state
                                            .colorSizeForProductModel
                                            ?.data
                                            ?.variation
                                            ?.firstWhere(
                                              (element) =>
                                                  element.type == newVariant,
                                            )
                                            .offerPrice;

                                        if ((order!
                                                        .details?[indexTap
                                                            .value]
                                                        .qty ??
                                                    0) >
                                                (newVariantQty ?? 0) &&
                                            (state
                                                    .colorSizeForProductModel
                                                    ?.data
                                                    ?.collectedAfterOrdering ==
                                                0)) {
                                          showMessage(
                                            LocaleKeys.not_available_now_stock
                                                .tr(),
                                            hasError: true,
                                            context: context,
                                          );
                                          return;
                                        }
                                        if (((order!
                                                        .details?[indexTap
                                                            .value]
                                                        .priceAfterDiscount ??
                                                    0) /
                                                (order!
                                                        .details?[indexTap
                                                            .value]
                                                        .qty ??
                                                    1)) <
                                            (newVariantPrice ?? 0)) {
                                          if (((((newVariantPrice ?? 0) -
                                                          ((order!
                                                                      .details?[indexTap
                                                                          .value]
                                                                      .priceAfterDiscount ??
                                                                  0) /
                                                              (order!
                                                                      .details?[indexTap
                                                                          .value]
                                                                      .qty ??
                                                                  1))) *
                                                      (order!
                                                              .details?[indexTap
                                                                  .value]
                                                              .qty ??
                                                          0)) *
                                                  (GetIt.I<HomeBloc>()
                                                      .state
                                                      .getCurrencyForCountryModel!
                                                      .data!
                                                      .currency!
                                                      .exchangeRate!)) >
                                              (state
                                                      .customerWalletModel
                                                      ?.data
                                                      .totalWalletBalance ??
                                                  0)) {
                                            showMessage(
                                              '${LocaleKeys.you_dont_have_enough_credit_in_the_wallet.tr()} , new price : ${(newVariantPrice ?? 0) * ((order!.details?[indexTap.value].qty ?? 0)) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)} ${(GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.symbol!)}',
                                              hasError: true,
                                              context: context,
                                            );
                                            return;
                                          }
                                        }
                                        if (_sizeIndexTap == index) {
                                          sizeIndexTap.value = null;
                                          return;
                                        }
                                        sizeIndexTap.value = index;
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 70.w,
                                            height: 70.h,
                                            decoration: BoxDecoration(
                                              border: _sizeIndexTap == index
                                                  ? Border.all(
                                                      color: const Color(
                                                        0xff402CDD,
                                                      ),
                                                    )
                                                  : null,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(40),
                                                  ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(40),
                                                  ),
                                              child: MyCachedNetworkImage(
                                                withInnerShadow: true,
                                                withImageShadow: true,
                                                radius: 40,
                                                imageUrl:
                                                    order!
                                                        .details?[indexTap
                                                            .value]
                                                        .image ??
                                                    "",
                                                imageFit: BoxFit.fill,
                                                width: 70.w,
                                                height: 70.h,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            productChoiceOptions[0]
                                                    .options?[index]
                                                    .name ??
                                                "",
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.rq
                                                .copyWith(
                                                  color: _sizeIndexTap == index
                                                      ? const Color(0xff402CDD)
                                                      : const Color(0xff5D5C5D),
                                                  letterSpacing: 0.18,
                                                  fontSize: 14.sp,
                                                  height: 1.3,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox(
                        width: 130,
                        height: 50.h,
                        child: ValueListenableBuilder<int>(
                          valueListenable: qtyToChangeController,
                          builder: (context, _qtyToChangeController, _) {
                            return Container(
                              width: 1.sw - 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF1D1D1D),
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              height: 50.h,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (order?.details?[indexTap.value].qty ==
                                            qtyToChangeController.value)
                                        ? const SizedBox.shrink()
                                        : InkWell(
                                            onTap: () {
                                              if (order
                                                      ?.details?[indexTap.value]
                                                      .qty ==
                                                  qtyToChangeController.value) {
                                                return;
                                              }
                                              qtyToChangeController.value =
                                                  qtyToChangeController.value +
                                                  1;
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 30,
                                              height: 50.h,
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.circular(
                                                    14,
                                                  ),
                                                  topRight: Radius.circular(14),
                                                ),
                                              ),
                                              child: Text(
                                                "+",
                                                textAlign: TextAlign.center,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: Colors.white,
                                                      letterSpacing: 0.18,
                                                      fontSize: 18.sp,
                                                    ),
                                              ),
                                            ),
                                          ),
                                    const Spacer(),
                                    Text(
                                      (_qtyToChangeController).toString(),
                                      style: context.textTheme.bodyMedium?.rq
                                          .copyWith(
                                            color: const Color(0xFF1D1D1D),
                                            letterSpacing: 0.18,
                                            fontSize: 20.sp,
                                          ),
                                    ),
                                    const Spacer(),
                                    (qtyToChangeController.value == 0)
                                        ? const SizedBox.shrink()
                                        : InkWell(
                                            onTap: () {
                                              if (qtyToChangeController.value ==
                                                  0) {
                                                return;
                                              }
                                              qtyToChangeController.value =
                                                  qtyToChangeController.value -
                                                  1;
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 30,
                                              height: 50.h,
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    14,
                                                  ),
                                                  topLeft: Radius.circular(14),
                                                ),
                                              ),
                                              child: Text(
                                                "-",
                                                textAlign: TextAlign.center,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: Colors.white,
                                                      letterSpacing: 0.18,
                                                      fontSize: 18.sp,
                                                    ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Widget panelReturnedContent(ScrollController sc) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (previous, current) =>
          previous.getReturnReasonsStatus != current.getReturnReasonsStatus,
      builder: (context, state) {
        List<ReturnReasonModel>? reasons =
            state.returnReasonsModel?.data?.returnReasons ?? [];
        final double maxRowWidth =
            MediaQuery.of(context).size.width - 10; // 20 يمين و20 يسار
        const double spacing = 5;

        // توزيع الأسباب في صفوف حسب العرض الفعلي
        List<List<ReturnReasonModel>> rows = [];
        List<ReturnReasonModel> currentRow = [];
        double currentWidth = 0;
        double _calculateButtonWidth(String text) {
          // يمكنك تعديل هذه القيم حسب التصميم والخط
          const double baseWidth = 0; // هامش أساسي للزر
          const double charWidth = 7; // تقدير تقريبي لحجم الحرف
          return baseWidth + (text.length * charWidth);
        }

        for (final reason in reasons) {
          final text = reason.reasonAeEn ?? '';
          final btnWidth = _calculateButtonWidth(text);
          // إذا كان إضافة الزر الحالي سيجعل الصف يتجاوز الحد، ابدأ صف جديد
          if (currentRow.isNotEmpty &&
              (currentWidth + btnWidth + spacing) > maxRowWidth) {
            rows.add(currentRow);
            currentRow = [];
            currentWidth = 0;
          }
          currentRow.add(reason);
          currentWidth += btnWidth + (currentRow.length > 1 ? spacing : 0);
        }
        if (currentRow.isNotEmpty) rows.add(currentRow);
        ReturnOrderDetail? orderDetail = orderDetails.firstWhere(
          (element) => element.detailId == order!.details?[indexTap.value].id,
          orElse: () => ReturnOrderDetail(),
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            SizedBox(height: 15.h),
            Container(
              width: 104,
              height: 140.h,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.white,
                  child: MyCachedNetworkImage(
                    withInnerShadow: true,
                    withImageShadow: true,
                    radius: 15,
                    imageUrl: order?.details?[indexTap.value].image ?? "",
                    imageFit: BoxFit.contain,
                    width: 100,
                    height: 140.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SvgPicture.asset(AppAssets.returnWihoutPhotoSvg),
            SizedBox(height: 14.h),
            Text(
              "${LocaleKeys.return_this_product.tr()}",
              style: context.textTheme.bodyMedium?.mq.copyWith(
                color: const Color(0xff402CDD),
                letterSpacing: 0.18,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "${LocaleKeys.you_can_return_product_without_conditions.tr()}",
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
                  "${LocaleKeys.return_policy_get_full_refund.tr()}",
                  maxLines: 1,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: qtyOfReturnValueNotifier,
                  builder: (context, _qtyOfReturnValueNotifier, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: reasonCost,
                      builder: (context, _reasonCost, _) {
                        return Text(
                          order!.paymentStatus == "unpaid"
                              ? " 0"
                              : "  ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces(((((order!.details?[indexTap.value].priceAfterDiscount ?? 0) / (order!.details?[indexTap.value].qty ?? 1)) * (_qtyOfReturnValueNotifier)) - (_reasonCost)) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!)), isNeedRounding: false)}",
                          maxLines: 1,
                          style: context.textTheme.bodyMedium?.bq.copyWith(
                            color: const Color(0xff8D8D8D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        );
                      },
                    );
                  },
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            SizedBox(height: 5.h),
            ValueListenableBuilder<int>(
              valueListenable: qtyOfReturnValueNotifier,
              builder: (context, _qtyOfReturnValueNotifier, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: optionReturn,
                  builder: (context, _optionReturn, _) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                        width: 1.sw - 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF1D1D1D)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        height: _optionReturn == 0 ? 60.h : 30.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (order?.details?[indexTap.value].qty ==
                                    _qtyOfReturnValueNotifier)
                                ? const SizedBox.shrink()
                                : InkWell(
                                    onTap: () {
                                      if (order?.details?[indexTap.value].qty ==
                                          _qtyOfReturnValueNotifier) {
                                        return;
                                      }
                                      qtyOfReturnValueNotifier.value =
                                          qtyOfReturnValueNotifier.value + 1;
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 20,
                                      height: _optionReturn == 0 ? 60.h : 30.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(14),
                                          topRight: Radius.circular(14),
                                        ),
                                      ),
                                      child: Text(
                                        "+",
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: Colors.white,
                                              letterSpacing: 0.18,
                                              fontSize: _optionReturn == 0
                                                  ? 18.sp
                                                  : 16.sp,
                                            ),
                                      ),
                                    ),
                                  ),
                            const Spacer(),
                            LanguageService.languageCode == "ar"
                                ? const SizedBox.shrink()
                                : Text(
                                    (_qtyOfReturnValueNotifier).toString(),
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xFF1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: _optionReturn == 0
                                              ? 18.sp
                                              : 16.sp,
                                        ),
                                  ),
                            LanguageService.languageCode == "ar"
                                ? const SizedBox.shrink()
                                : SizedBox(width: 10.h),
                            Text(
                              LocaleKeys.return_pieces_hint.tr(),
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xFF1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: _optionReturn == 0 ? 12.sp : 11.sp,
                              ),
                            ),
                            LanguageService.languageCode != "ar"
                                ? const SizedBox.shrink()
                                : SizedBox(width: 10.h),
                            LanguageService.languageCode != "ar"
                                ? const SizedBox.shrink()
                                : Text(
                                    (_qtyOfReturnValueNotifier).toString(),
                                    style: context.textTheme.bodyMedium?.rq
                                        .copyWith(
                                          color: const Color(0xFF1D1D1D),
                                          letterSpacing: 0.18,
                                          fontSize: _optionReturn == 0
                                              ? 18.sp
                                              : 16.sp,
                                        ),
                                  ),
                            const Spacer(),
                            (qtyOfReturnValueNotifier.value == 1)
                                ? const SizedBox.shrink()
                                : InkWell(
                                    onTap: () {
                                      if (qtyOfReturnValueNotifier.value == 1) {
                                        return;
                                      }
                                      qtyOfReturnValueNotifier.value =
                                          qtyOfReturnValueNotifier.value - 1;
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 20,
                                      height: _optionReturn == 0 ? 60.h : 30.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(14),
                                          topLeft: Radius.circular(14),
                                        ),
                                      ),
                                      child: Text(
                                        "-",
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium?.rq
                                            .copyWith(
                                              color: Colors.white,
                                              letterSpacing: 0.18,
                                              fontSize: _optionReturn == 0
                                                  ? 18.sp
                                                  : 16.sp,
                                            ),
                                      ),
                                    ),
                                  ),
                          ],
                        ) /*TextFormField(
                        onChanged: (value) {
                          qtyOfReturnValueNotifier.value =
                              int.tryParse(value) ?? 0;
                        },
                        controller: qtyOfReturnController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: ,
                          hintStyle: context.textTheme.bodyMedium?.rr.copyWith(
                            color: const Color(0xFF1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: _optionReturn == 0 ? 12.sp : 11.sp,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF8D8D8D)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF8D8D8D)),
                          ),
                        ),
                        style: TextStyle(
                          color: Color(0xFF1D1D1D),
                        ),
                        textAlign: TextAlign.center,
                      ),*/,
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 5.h),
            Container(
              width: 1.sw,
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${LocaleKeys.why_was_product_return.tr()}",
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
            SizedBox(height: 18.h),

            // جلب الأسباب من orderState
            state.getReturnReasonsStatus == GetReturnReasonsStatus.loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                height: 50.h,
                                width: 150.w,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                height: 50.h,
                                width: 150.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                height: 50.h,
                                width: 150.w,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                height: 50.h,
                                width: 150.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : state.getReturnReasonsStatus == GetReturnReasonsStatus.failure
                ? Container(
                    width: 120,
                    height: 50.h,
                    child: TryAgainWidget(
                      tryAgain: () =>
                          orderBloc.add(const GetReturnReasonsEvent()),
                    ),
                  )
                : Column(
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: 10,
                          ), // نفس المسافة بين الصفوف
                          child: Row(
                            children: [
                              for (ReturnReasonModel reason in row) ...[
                                optionReturnOrder(
                                  "${(reason.reasonAeEn ?? '') + '${(reason.isCostBySystem != 0) ? "" : '\n ${LocaleKeys.cost.tr()} ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((reason.cost ?? 0), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * homeBloc.state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!), isNeedRounding: false)} ${homeBloc.state.getCurrencyForCountryModel!.data!.currency!.symbol}'}'}",
                                  reason.id ?? -1, // النص من الـ API
                                  _calculateButtonWidth(
                                    reason.reasonAeEn ?? '',
                                  ), // يمكنك تعديل العرض حسب الحاجة أو حسب طول النص
                                  () {
                                    if (reason.isCostBySystem == 0 &&
                                        ((reason.cost ?? 0) >
                                            ((order
                                                    ?.details?[indexTap.value]
                                                    .priceAfterDiscount ??
                                                0)))) {
                                      return;
                                    }
                                    if (optionReturn.value == reason.id) {
                                      optionReturn.value = 0;
                                      reasonCost.value = 0;
                                      return;
                                    }

                                    optionReturn.value = reason.id ?? 0;
                                    reasonCost.value =
                                        (reason.isCostBySystem == 1)
                                        ? 0
                                        : reason.cost ?? 0;
                                  },
                                ),
                                const SizedBox(width: 5),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),

            SizedBox(height: 10.h),
            Container(
              width: 1.sw,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 0.5,
              decoration: BoxDecoration(
                color: const Color(0xffC4C2C2),
                border: Border.all(color: const Color(0xffC4C2C2)),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            SizedBox(height: 12.h),
            BlocBuilder<OrderBloc, OrderState>(
              buildWhen: (previous, current) =>
                  previous.uploadImagesForReturnProductStatus !=
                  current.uploadImagesForReturnProductStatus,
              builder: (context, state) {
                if (state.uploadImagesForReturnProductStatus ==
                    UploadImagesForReturnProductStatus.success) {
                  Future.delayed(
                    const Duration(milliseconds: 50),
                    () => orderPhotos.value = [...state.imagesForReturn ?? []],
                  );
                }
                return ValueListenableBuilder<int>(
                  valueListenable: optionReturn,
                  builder: (context, _optionReturn, _) {
                    return _optionReturn == 0
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ), // نفس المسافة بين الصفوف
                            child: ValueListenableBuilder<List<String?>?>(
                              valueListenable: orderPhotos,
                              builder: (context, _orderPhotos, _) {
                                return SizedBox(
                                  height: 175.h,
                                  width: 1.sw,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF8F8F8),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.r),
                                          ),
                                          border:
                                              (_orderPhotos?.length ?? 0) > 0
                                              ? null
                                              : Border.all(
                                                  color: const Color(
                                                    0xff402CDD,
                                                  ),
                                                ),
                                        ),
                                        child:
                                            (_orderPhotos?.length ?? 0) > 0 ||
                                                (state.uploadImagesForReturnProductStatus ==
                                                    UploadImagesForReturnProductStatus
                                                        .loading)
                                            ? Stack(
                                                children: [
                                                  (state.uploadImagesForReturnProductStatus ==
                                                          UploadImagesForReturnProductStatus
                                                              .loading)
                                                      ? ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              orderPhotos
                                                                  .value
                                                                  .length +
                                                              1,
                                                          itemBuilder: (context, index) {
                                                            if (index ==
                                                                orderPhotos
                                                                    .value
                                                                    .length) {
                                                              return Shimmer.fromColors(
                                                                baseColor: Colors
                                                                    .grey
                                                                    .shade300,
                                                                highlightColor:
                                                                    Colors
                                                                        .grey
                                                                        .shade50,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15.r,
                                                                        ),
                                                                  ),
                                                                  width: 57,
                                                                  height: 80.h,
                                                                ),
                                                              );
                                                            }
                                                            return Container(
                                                              width: 57,

                                                              height: 80.h,
                                                              margin: EdgeInsets.only(
                                                                right:
                                                                    LanguageService
                                                                            .languageCode ==
                                                                        "ar"
                                                                    ? 0
                                                                    : 5,
                                                                left:
                                                                    LanguageService
                                                                            .languageCode !=
                                                                        "ar"
                                                                    ? 0
                                                                    : 5,
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius.all(
                                                                          Radius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                    child: MyCachedNetworkImage(
                                                                      imageUrl:
                                                                          (_orderPhotos![index].toString().contains(
                                                                            "cloudinary",
                                                                          )
                                                                          ? _orderPhotos[index]!
                                                                          : ("${dotenv.env['Images_Url']}") +
                                                                                "/return_request_products/" +
                                                                                _orderPhotos[index]!),
                                                                      imageFit:
                                                                          BoxFit
                                                                              .fill,
                                                                      width: 57,
                                                                      height:
                                                                          80.h,
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        orderBloc.add(
                                                                          RemoveImagesForReturnProductEvent(
                                                                            index,
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              2,
                                                                            ),
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            15.h,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),

                                                                        child: SvgPicture.asset(
                                                                          AppAssets
                                                                              .cancelSvg,

                                                                          // ignore: deprecated_member_use
                                                                          height:
                                                                              5,
                                                                          width:
                                                                              5,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    right: 0,
                                                                    top: 0,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: orderPhotos
                                                              .value
                                                              .length,
                                                          itemBuilder: (context, index) {
                                                            return Container(
                                                              width: 57,
                                                              height: 80.h,
                                                              margin: EdgeInsets.only(
                                                                right:
                                                                    LanguageService
                                                                            .languageCode ==
                                                                        "ar"
                                                                    ? 0
                                                                    : 5,
                                                                left:
                                                                    LanguageService
                                                                            .languageCode !=
                                                                        "ar"
                                                                    ? 0
                                                                    : 5,
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius.all(
                                                                          Radius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                    child: MyCachedNetworkImage(
                                                                      imageUrl:
                                                                          (_orderPhotos![index].toString().contains(
                                                                            "cloudinary",
                                                                          )
                                                                          ? _orderPhotos[index]!
                                                                          : ("${dotenv.env['Images_Url']}") +
                                                                                "/return_request_products/" +
                                                                                _orderPhotos[index]!),
                                                                      imageFit:
                                                                          BoxFit
                                                                              .fill,
                                                                      width: 57,
                                                                      height:
                                                                          80.h,
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        orderBloc.add(
                                                                          RemoveImagesForReturnProductEvent(
                                                                            index,
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              2,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            15.h,
                                                                        child: SvgPicture.asset(
                                                                          AppAssets
                                                                              .cancelSvg,

                                                                          // ignore: deprecated_member_use
                                                                          height:
                                                                              5,
                                                                          width:
                                                                              5,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    right: 0,
                                                                    top: 0,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                  Positioned(
                                                    right:
                                                        LanguageService
                                                                .languageCode ==
                                                            "ar"
                                                        ? null
                                                        : 20,
                                                    left:
                                                        LanguageService
                                                                .languageCode !=
                                                            "ar"
                                                        ? null
                                                        : 20,
                                                    top: 30,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        void _showImagePreview(
                                                          File imageFile,
                                                        ) {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (
                                                                  BuildContext
                                                                  context,
                                                                ) {
                                                                  return SearchImagePreviewWidget(
                                                                    imageFile:
                                                                        imageFile,
                                                                    onSend: (File file) {
                                                                      orderBloc.add(
                                                                        UploadImagesForReturnProductEvent(
                                                                          file,
                                                                        ),
                                                                      );
                                                                    },
                                                                    onCancel: () =>
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop(),
                                                                  );
                                                                },
                                                          );
                                                        }

                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return GalleryAndCameraDialogWidget(
                                                              fromChat:
                                                                  true, // تفعيل معاينة الصور
                                                              onChooseFileFromGalleryAction:
                                                                  (
                                                                    AssetEntity?
                                                                    assetEntity,
                                                                  ) async {
                                                                    if (assetEntity !=
                                                                        null) {
                                                                      File
                                                                      file = (await assetEntity
                                                                          .originFile)!;
                                                                      String
                                                                      mimeStr =
                                                                          lookupMimeType(
                                                                            file.absolute.path,
                                                                          ) ??
                                                                          '';
                                                                      var fileType =
                                                                          mimeStr.split(
                                                                            '/',
                                                                          );

                                                                      if (fileType[0] !=
                                                                          'image') {
                                                                        showErrorMessage(
                                                                          context,
                                                                          LocaleKeys
                                                                              .video_file_not_supported
                                                                              .tr(),
                                                                        );
                                                                      } else {
                                                                        // إغلاق ديالوج الاختيار
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop();
                                                                        // تأخير صغير لضمان إغلاق الديالوج
                                                                        await Future.delayed(
                                                                          const Duration(
                                                                            milliseconds:
                                                                                100,
                                                                          ),
                                                                        );
                                                                        // عرض معاينة الصورة
                                                                        _showImagePreview(
                                                                          file,
                                                                        );
                                                                      }
                                                                    }
                                                                  },
                                                              onChooseFileFromCameraAction: (File? file) async {
                                                                if (file !=
                                                                    null) {
                                                                  String
                                                                  mimeStr =
                                                                      lookupMimeType(
                                                                        file
                                                                            .absolute
                                                                            .path,
                                                                      ) ??
                                                                      '';
                                                                  var fileType =
                                                                      mimeStr
                                                                          .split(
                                                                            '/',
                                                                          );
                                                                  if (fileType[0] !=
                                                                      'image') {
                                                                    showErrorMessage(
                                                                      context,
                                                                      LocaleKeys
                                                                          .video_file_not_supported
                                                                          .tr(),
                                                                    );
                                                                  } else {
                                                                    // إغلاق ديالوج الاختيار
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                    // تأخير صغير لضمان إغلاق الديالوج
                                                                    await Future.delayed(
                                                                      const Duration(
                                                                        milliseconds:
                                                                            100,
                                                                      ),
                                                                    );
                                                                    // عرض معاينة الصورة
                                                                    _showImagePreview(
                                                                      file,
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                              onImagePreviewAction:
                                                                  (File image) {
                                                                    // هذا سيتم استدعاؤه تلقائياً من GalleryAndCameraDialogWidget
                                                                    // عندما fromChat = true
                                                                    _showImagePreview(
                                                                      image,
                                                                    );
                                                                  },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            AppAssets
                                                                .addPhotoSvg,
                                                            // ignore: deprecated_member_use
                                                            color: const Color(
                                                              0xff402CDD,
                                                            ),
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
                                                  void _showImagePreview(
                                                    File imageFile,
                                                  ) {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext context) {
                                                        return SearchImagePreviewWidget(
                                                          imageFile: imageFile,
                                                          onSend: (File file) {
                                                            orderBloc.add(
                                                              UploadImagesForReturnProductEvent(
                                                                file,
                                                              ),
                                                            );
                                                          },
                                                          onCancel: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        );
                                                      },
                                                    );
                                                  }

                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return GalleryAndCameraDialogWidget(
                                                        fromChat:
                                                            true, // تفعيل معاينة الصور
                                                        onChooseFileFromGalleryAction:
                                                            (
                                                              AssetEntity?
                                                              assetEntity,
                                                            ) async {
                                                              if (assetEntity !=
                                                                  null) {
                                                                File
                                                                file = (await assetEntity
                                                                    .originFile)!;
                                                                String mimeStr =
                                                                    lookupMimeType(
                                                                      file
                                                                          .absolute
                                                                          .path,
                                                                    ) ??
                                                                    '';
                                                                var fileType =
                                                                    mimeStr
                                                                        .split(
                                                                          '/',
                                                                        );

                                                                if (fileType[0] !=
                                                                    'image') {
                                                                  showErrorMessage(
                                                                    context,
                                                                    LocaleKeys
                                                                        .video_file_not_supported
                                                                        .tr(),
                                                                  );
                                                                } else {
                                                                  // إغلاق ديالوج الاختيار
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  // تأخير صغير لضمان إغلاق الديالوج
                                                                  await Future.delayed(
                                                                    const Duration(
                                                                      milliseconds:
                                                                          100,
                                                                    ),
                                                                  );
                                                                  // عرض معاينة الصورة
                                                                  _showImagePreview(
                                                                    file,
                                                                  );
                                                                }
                                                              }
                                                            },
                                                        onChooseFileFromCameraAction: (File? file) async {
                                                          if (file != null) {
                                                            String mimeStr =
                                                                lookupMimeType(
                                                                  file
                                                                      .absolute
                                                                      .path,
                                                                ) ??
                                                                '';
                                                            var fileType =
                                                                mimeStr.split(
                                                                  '/',
                                                                );
                                                            if (fileType[0] !=
                                                                'image') {
                                                              showErrorMessage(
                                                                context,
                                                                LocaleKeys
                                                                    .video_file_not_supported
                                                                    .tr(),
                                                              );
                                                            } else {
                                                              // إغلاق ديالوج الاختيار
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                              // تأخير صغير لضمان إغلاق الديالوج
                                                              await Future.delayed(
                                                                const Duration(
                                                                  milliseconds:
                                                                      100,
                                                                ),
                                                              );
                                                              // عرض معاينة الصورة
                                                              _showImagePreview(
                                                                file,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        onImagePreviewAction:
                                                            (File image) {
                                                              // هذا سيتم استدعاؤه تلقائياً من GalleryAndCameraDialogWidget
                                                              // عندما fromChat = true
                                                              _showImagePreview(
                                                                image,
                                                              );
                                                            },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      AppAssets.addPhotoSvg,
                                                      // ignore: deprecated_member_use
                                                      color: const Color(
                                                        0xff402CDD,
                                                      ),
                                                      width: 20,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${LocaleKeys.add_photo.tr()}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: context
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.rq
                                                          .copyWith(
                                                            color: const Color(
                                                              0xff402CDD,
                                                            ),
                                                            letterSpacing: 0.18,
                                                            fontSize: 10.sp,
                                                            height: 1.3,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: 2.h),
                                      (_orderPhotos?.length ?? 0) > 0
                                          ? const SizedBox.shrink()
                                          : Padding(
                                              padding:
                                                  EdgeInsetsGeometry.symmetric(
                                                    horizontal: 20.sp,
                                                  ),
                                              child: Text(
                                                "${LocaleKeys.please_add_photos_of_product_received.tr()}",
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff402CDD,
                                                      ),
                                                      letterSpacing: 0.18,
                                                      fontSize: 10.sp,
                                                      height: 1.3,
                                                    ),
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                  },
                );
              },
            ),
            SizedBox(height: 2.h),
            BlocListener<OrderBloc, OrderState>(
              listenWhen: (previous, current) =>
                  previous.storeReturnRequestStatus !=
                      current.storeReturnRequestStatus ||
                  previous.orderReturnDetailsStatus !=
                      current.orderReturnDetailsStatus,
              listener: (context, state) {
                if (state.storeReturnRequestStatus ==
                        StoreReturnRequestStatus.success &&
                    state.orderReturnDetailsStatus ==
                        OrderReturnDetailsStatus.success) {
                  showShadowForCanselOrder.value = true;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ), // نفس المسافة بين الصفوف
                child: ValueListenableBuilder<int>(
                  valueListenable: qtyOfReturnValueNotifier,
                  builder: (context, _qtyOfReturnValueNotifier, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: optionReturn,
                      builder: (context, _optionReturn, _) {
                        return ValueListenableBuilder<List<String>>(
                          valueListenable: orderPhotos,
                          builder: (context, _orderPhotos, _) {
                            return BlocBuilder<OrderBloc, OrderState>(
                              buildWhen: (previous, current) =>
                                  previous.storeReturnRequestStatus !=
                                      current.storeReturnRequestStatus ||
                                  previous.orderReturnDetailsStatus !=
                                      current.orderReturnDetailsStatus,
                              builder: (context, state) {
                                return state.storeReturnRequestStatus ==
                                            StoreReturnRequestStatus.loading ||
                                        state.orderReturnDetailsStatus ==
                                            OrderReturnDetailsStatus.loading
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey[500]!,
                                        highlightColor: Colors.grey[300]!,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 1.sw,
                                          height: 53.h,
                                          decoration: BoxDecoration(
                                            color: agreeToPolicies.value == true
                                                ? const Color(0xff3066CC)
                                                : const Color(0xffC4C2C2),
                                            border:
                                                agreeToPolicies.value == true
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
                                          if ((_orderPhotos.length) > 0 &&
                                              _qtyOfReturnValueNotifier > 0 &&
                                              (_optionReturn != 0)) {
                                            orderBloc.add(
                                              StoreReturnRequestEvent(
                                                orderGroupId:
                                                    order?.orderGroupId ?? "",
                                                params: ReturnRequestParams(
                                                  isDraft: "1",
                                                  orderId: (order!.id ?? 0)
                                                      .toString(),
                                                  isForExchange: "0",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 1.sw,
                                          height: 53.h,
                                          decoration: BoxDecoration(
                                            color:
                                                (_orderPhotos.length) > 0 &&
                                                    (_optionReturn != 0) &&
                                                    _qtyOfReturnValueNotifier >
                                                        0
                                                ? const Color(0xff402CDD)
                                                : const Color(0xffD3D3D3),
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                          ),
                                          child: Text(
                                            "${(orderDetail.alreadyReturn ?? false) && order?.returnRequestId != null && (order?.editReturnRequest ?? false) ? LocaleKeys.edit_return_request.tr() : LocaleKeys.return_request.tr()}",
                                            maxLines: 1,
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.mq
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
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  Widget canselContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Column(
              children: [
                Row(
                  children: [
                    optionOfCanselOrder(
                      LocaleKeys.i_changed_mind.tr(),
                      130,
                      () {
                        List<String> options = optionCansel.value;
                        if (optionCansel.value.contains(
                          LocaleKeys.i_changed_mind.tr(),
                        )) {
                          options.remove(LocaleKeys.i_changed_mind.tr());

                          optionCansel.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_changed_mind.tr());

                        optionCansel.value = [...options];
                      },
                    ),
                    const SizedBox(width: 10),
                    optionOfCanselOrder(
                      LocaleKeys.i_fear_quality.tr(),
                      100,
                      () {
                        List<String> options = optionCansel.value;
                        if (optionCansel.value.contains(
                          LocaleKeys.i_fear_quality.tr(),
                        )) {
                          options.remove(LocaleKeys.i_fear_quality.tr());

                          optionCansel.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_fear_quality.tr());

                        optionCansel.value = [...options];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    optionOfCanselOrder(
                      LocaleKeys.i_fear_delivery_time.tr(),
                      160,
                      () {
                        List<String> options = optionCansel.value;
                        if (optionCansel.value.contains(
                          LocaleKeys.i_fear_delivery_time.tr(),
                        )) {
                          options.remove(LocaleKeys.i_fear_delivery_time.tr());

                          optionCansel.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_fear_delivery_time.tr());

                        optionCansel.value = [...options];
                      },
                    ),
                    const SizedBox(width: 10),
                    optionOfCanselOrder(
                      LocaleKeys.i_am_afraid_sizes.tr(),
                      125,
                      () {
                        List<String> options = optionCansel.value;
                        if (optionCansel.value.contains(
                          LocaleKeys.i_am_afraid_sizes.tr(),
                        )) {
                          options.remove(LocaleKeys.i_am_afraid_sizes.tr());

                          optionCansel.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_am_afraid_sizes.tr());

                        optionCansel.value = [...options];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    optionOfCanselOrder(
                      LocaleKeys.i_saw_better_price.tr(),
                      135,
                      () {
                        List<String> options = optionCansel.value;
                        if (optionCansel.value.contains(
                          LocaleKeys.i_saw_better_price.tr(),
                        )) {
                          options.remove(LocaleKeys.i_saw_better_price.tr());

                          optionCansel.value = [...options];

                          return;
                        }
                        options.add(LocaleKeys.i_saw_better_price.tr());

                        optionCansel.value = [...options];
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
                borderRadius: BorderRadius.circular(20),
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
              valueListenable: optionCansel,
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      allOrder
                          ? LocaleKeys.cancel_order.tr()
                          : LocaleKeys.cancel_this_product.tr(),
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

  Widget optionOfCanselOrder(
    String text,
    double width,
    void Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: ValueListenableBuilder<List<String>>(
        valueListenable: optionCansel,
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
              borderRadius: BorderRadius.circular(12),
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

  Widget optionReturnOrder(
    String text,
    int id,
    double width,
    void Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: ValueListenableBuilder<int>(
        valueListenable: optionReturn,
        builder: (context, _optionReturn, _) {
          return Container(
            alignment: Alignment.center,
            height: 40.h,
            width: width,
            decoration: BoxDecoration(
              border: _optionReturn != id
                  ? null
                  : Border.all(color: const Color(0xff402CDD)),
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.rq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.18,
                fontSize: 11.sp,
                height: 1.3,
              ),
            ),
          );
        },
      ),
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
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
                      SvgPicture.asset(svg, width: 30),
                      image2 == ""
                          ? const SizedBox.shrink()
                          : image2.split(".").last != "svg"
                          ? ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
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
                const SizedBox(height: 2),
                Text(
                  body,
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    overflow: TextOverflow.ellipsis,

                    letterSpacing: 0.18,
                    fontSize: 10.sp,
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
