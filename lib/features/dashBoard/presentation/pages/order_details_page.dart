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
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart'
    show CallsBloc, CallsState, MakeCallStatus;
import 'package:trydos/features/calls/presentation/pages/in_app_view.dart'
    show AgoraInAppWebView;
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/dashBoard/data/models/get_new_ordersToDashboard.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/home/data/models/get_list_of_customer_addresses_model.dart';
import 'package:trydos/features/home/data/models/get_order_rating_model.dart'
    show Comment;
import 'package:trydos/features/home/data/models/get_orders_model.dart';
import 'package:trydos/features/home/domain/use_cases/cancel_order_usecase.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_bloc.dart';
import 'package:trydos/features/home/presentation/manager/orderBloc/order_event.dart'
    show
        ChangeOrderByGroupStatus,
        CancelOrderEvent,
        GetCustomerAddressesEvent,
        FetchOrderReturnDetailsEvent,
        ResetAllStatusEvent;
import 'package:trydos/features/home/presentation/manager/orderBloc/order_state.dart';
import 'package:trydos/features/home/presentation/pages/Order/order_status.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/widgets/star_rating_widget.dart';
import 'package:trydos/routes/router.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../common/helper/helper_functions.dart';
import '../../../../../generated/locale_keys.g.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class OrderDetailsNew extends StatefulWidget {
  const OrderDetailsNew({
    super.key,
    this.fromNotification = false,
    this.currentStatus = "",
    this.orderIdToOpenPackage = "",
    this.indexGroupe = -1,
    this.orderIdFormNotification,
    this.parentOrderIdFormNotification,
    required this.orders,
    required this.orderNumber,
  });

  final UserOrderNew orders;
  final bool fromNotification;
  final String? orderIdFormNotification;
  final String? parentOrderIdFormNotification;
  final String? orderNumber;
  final String orderIdToOpenPackage;
  final String? currentStatus;
  final int indexGroupe;
  @override
  State<OrderDetailsNew> createState() => _OrderDetails1State();
}

class _OrderDetails1State extends State<OrderDetailsNew> {
  List<String?> addressParts = [];

  late ChatBloc chatBloc;
  late OrderBloc orderBloc;

  late HomeBloc homeBloc;
  late DashboardBloc dashboardBloc;
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> enableChangeAddress = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForChangeAddress = ValueNotifier(false);
  final PanelController panelController = PanelController();
  final ValueNotifier<bool> showPanel = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForCanselOrder = ValueNotifier(false);
  final ValueNotifier<int> indexTapAddress = ValueNotifier(0);
  final PageController pageController = PageController();
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<int> indexTapPackage = ValueNotifier(0);
  final ValueNotifier<String?> optionModifyPanel = ValueNotifier(null);
  final ScrollController singleChildController = ScrollController();
  final ValueNotifier<bool> agreeToPolicies = ValueNotifier(false);
  final ValueNotifier<List<String>> optionCanselOrReturn = ValueNotifier([]);
  UserOrderNew? orders;
  String? apiOrderStatus;
  UserOrderNew? orderBeforePendingUpdate;
  int? pendingOrderDetailId;
  String? pendingOrderDetailStatus;
  int firstAddressChoosed = 0;
  bool firstOpenPage = true;
  String phoneNumber = '';
  final FocusNode focusNode = FocusNode();
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  bool requestReturnApiFromNotification = false;
  bool requestReturnApi = false;
  bool canFetchReturnDetails = false;
  bool fromNotification = false;
  @override
  void initState() {
    LastPagesTracker.push("OrderDetails1 Page");
    fromNotification = widget.fromNotification;
    orders = widget.orders;
    apiOrderStatus = widget.orders.orderStatus;
    dashboardBloc = GetIt.I<DashboardBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    // Future<void> _refreshData() async {
    //   fromNotification = false;
    //   if (canFetchReturnDetails) {
    //     orderBloc.add(FetchOrderReturnDetailsEvent(orders.orderGroupId ?? ""));
    //   } else {
    //     orderBloc.add(
    //       FetchOrderReturnDetailsEvent(
    //         orders.orderGroupId ?? "",
    //         notFound: true,
    //       ),
    //     );
    //   }

    //   orderBloc.add(
    //     GetOrdersByOrderGroupIDEvent(
    //       orderGroupId: widget.orders.orderGroupId ?? "",
    //     ),
    //   );

    //   // 🚀 إزالة التأخير المصطنع - دع البيانات تحدد سرعة التحميل!
    //   await Future.delayed(
    //     const Duration(seconds: 3),
    //   ); // ❌ تم حذف التأخير المصطنع
    // }
    Future<void> _refreshData() async {}

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
      child: Stack(
        children: [
          BlocListener<DashboardBloc, DashBoardState>(
            bloc: dashboardBloc,
            listenWhen: (previous, current) =>
                previous.changeOrderDetailStatusStatus !=
                current.changeOrderDetailStatusStatus,
            listener: (context, state) {
              if (state.changeOrderDetailStatusStatus ==
                  ChangeOrderDetailStatusStatus.failure) {
                if (!mounted) {
                  return;
                }

                setState(() {
                  if (orderBeforePendingUpdate != null) {
                    orders = orderBeforePendingUpdate;
                  }
                  orderBeforePendingUpdate = null;
                  pendingOrderDetailId = null;
                  pendingOrderDetailStatus = null;
                });
                return;
              }

              if (state.changeOrderDetailStatusStatus !=
                  ChangeOrderDetailStatusStatus.success) {
                return;
              }

              UserOrderNew? updatedCurrentOrder;
              final updatedOrders = state.new_orders;
              if (updatedOrders != null) {
                final matchedOrders = updatedOrders.where(
                  (order) => order.id == orders?.id,
                );
                if (matchedOrders.isNotEmpty) {
                  updatedCurrentOrder = matchedOrders.first;
                }
              }

              if (updatedCurrentOrder == null &&
                  orders != null &&
                  pendingOrderDetailId != null &&
                  pendingOrderDetailStatus != null) {
                updatedCurrentOrder = _applyOrderDetailStatusLocally(
                  orders!,
                  pendingOrderDetailId!,
                  pendingOrderDetailStatus!,
                );
              }

              if (!mounted) {
                return;
              }

              setState(() {
                if (updatedCurrentOrder != null) {
                  orders = updatedCurrentOrder;
                  apiOrderStatus = updatedCurrentOrder.orderStatus;
                }
                orderBeforePendingUpdate = null;
                pendingOrderDetailId = null;
                pendingOrderDetailStatus = null;
              });
            },
            child: BlocListener<OrderBloc, OrderState>(
              listenWhen: (p, c) =>
                  p.getOrdersByOrderGroupIDStatus !=
                  c.getOrdersByOrderGroupIDStatus,
              listener: (context, state) {},
              child: BlocBuilder<OrderBloc, OrderState>(
                buildWhen: (p, c) =>
                    p.getOrdersByOrderGroupIDStatus !=
                    c.getOrdersByOrderGroupIDStatus,
                builder: (context, state) {
                  return ValueListenableBuilder<int>(
                    valueListenable: indexTapPackage,
                    builder: (context, _indexTapPackage, _) {
                      addressParts = [
                        // orders.shippingAddressData?.country,
                        // orders.shippingAddressData?.province,
                        // orders.shippingAddressData?.city,
                        // orders.shippingAddressData?.town,
                        // orders.shippingAddressData?.street,
                        // orders.shippingAddressData?.building,
                      ];

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
                                          const SizedBox(width: 12),
                                          SvgPicture.asset(
                                            AppAssets.bagsSvg,
                                            width: 23,
                                          ),
                                          ///////////////////////////
                                          const SizedBox(width: 4),
                                          ///////////////////////////
                                          Text(
                                            LocaleKeys.order_details.tr(),
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.mq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff1D1D1D,
                                                  ),
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
                                                  .getOrdersByOrderGroupIDStatus ==
                                              GetOrdersByOrderGroupIDStatus
                                                  .loading) {
                                            return;
                                          }
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
                                                  GetOrdersByOrderGroupIDStatus
                                                      .loading
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
                                body: RefreshIndicator(
                                  backgroundColor: Colors.white,
                                  color: Colors.black,
                                  onRefresh: _refreshData,
                                  child: SingleChildScrollView(
                                    controller: singleChildController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 11.h),
                                        ///////////////////
                                        BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (previous, current) =>
                                              (previous
                                                  .getCurrencyForCountryModel !=
                                              current
                                                  .getCurrencyForCountryModel),
                                          builder: (context, state) {
                                            double orderAmount = 0;
                                            orders!.details.forEach(
                                              (element) => orderAmount =
                                                  orderAmount +
                                                  (HelperFunctions.truncateToDecimalPlaces(
                                                        element.unitPrice,
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
                                              height: 95,
                                              child: buildFirstSection(
                                                context: context,
                                                orderNumber:
                                                    widget.orderNumber!,
                                                orderDate:
                                                    orders!.createdAt.date +
                                                    ' | ' +
                                                    orders!.createdAt.time,
                                                orderAmount: orders!.orderAmount
                                                    .toString(),
                                                orderCurrency: "USD",
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 8.h),
                                        ///////////////////////
                                        SizedBox(
                                          height: 85,
                                          child:
                                              state.getOrdersByOrderGroupIDStatus ==
                                                  GetOrdersByOrderGroupIDStatus
                                                      .loading
                                              ? TrydosLoader(size: 16)
                                              :
                                                //  حالات العناصر و الوقت المتوقع للتوصيل
                                                buildSecondSection(
                                                  context: context,
                                                  expectedDeliveryDate: orders!
                                                      .remainingInMinutes
                                                      .toString(),
                                                  orderStatus:
                                                      apiOrderStatus ??
                                                      orders!.orderStatus,
                                                  orderStatusLable:
                                                      apiOrderStatus ??
                                                      orders!.orderStatus,
                                                  // deliverdTo:
                                                  //     orders
                                                  //         .shippingAddressData
                                                  //         ?.contactPersonName ??
                                                  //     '',
                                                ),
                                        ),
                                        SizedBox(height: 8.h),
                                        SizedBox(height: 8.h),
                                        buildFourthSection(
                                          context: context,
                                          itemsCount: orders!.details.length
                                              .toString(),
                                        ),
                                        SizedBox(height: 8.h),
                                        for (var entry
                                            in orders!.details.asMap().entries)
                                          buildProductOrderCard(
                                            index: entry.key + 1,
                                            context: context,
                                            imageUrl:
                                                // dotenv.env['Images_Url']! +
                                                entry.value.cartImage,
                                            brand: entry.value.brandIcon,
                                            title: entry.value.productName,
                                            color: entry.value.color,
                                            size: entry.value.size,
                                            id: entry.value.id.toString(),
                                            quantity: entry.value.qty,
                                            status: _buildDetailCardStatusLabel(
                                              entry.value,
                                            ),
                                            price: entry.value.unitPrice
                                                .toString(),
                                            primaryActionLabel:
                                                _buildPrimaryActionLabel(
                                                  entry.value,
                                                ),
                                            isPrimaryActionEnabled:
                                                _isPrimaryActionEnabled(
                                                  entry.value,
                                                ),
                                            onPrimaryAction: () {
                                              final nextStatus =
                                                  _buildNextDetailStatus(
                                                    entry.value,
                                                  );

                                              if (nextStatus == null) {
                                                return;
                                              }

                                              final currentOrder = orders;
                                              if (currentOrder == null) {
                                                return;
                                              }

                                              final updatedOrder =
                                                  _applyOrderDetailStatusLocally(
                                                    currentOrder,
                                                    entry.value.id,
                                                    nextStatus,
                                                  );

                                              setState(() {
                                                orderBeforePendingUpdate =
                                                    currentOrder;
                                                orders = updatedOrder;
                                                pendingOrderDetailId =
                                                    entry.value.id;
                                                pendingOrderDetailStatus =
                                                    nextStatus;
                                              });

                                              dashboardBloc.add(
                                                ChangeOrderDetailStatusEvent(
                                                  order_detail_id:
                                                      entry.value.id,
                                                  status: nextStatus,
                                                ),
                                              );
                                            },
                                            onCancel: () {},
                                          ),
                                        SizedBox(height: 8.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              shadowForPanel(),
                              panelWidget(),
                              // ValueListenableBuilder<int>(
                              //   valueListenable: indexTapAddress,
                              //   builder: (context, _indexTap, _) {
                              //     return shadowForChangeAddressContent(_indexTap);
                              //   },
                              // ),
                              // shadowForCanselOrRutuenOrder(false),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isVerified,
            builder: (context, _isverified, _) {
              return _isverified
                  ? const SizedBox.shrink()
                  : Container(
                      width: 1.sw,
                      height: 1.sh,
                      color: const Color.fromRGBO(0, 0, 0, 0.5),
                    );
            },
          ),
          Positioned(
            bottom: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isVerified,
              builder: (context, _isverified, _) {
                return _isverified ? const SizedBox.shrink() : _veryfiedOtp();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _veryfiedOtp() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: Colors.white,
        height: 450,
        width: 1.sw,
        child: Scaffold(
          body: SizedBox(
            height: 400,
            width: 1.sw,
            child: Stack(
              children: [
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children:
                      (prefsRepository.isVerifiedPhonePeforeExpiredToken ??
                          false)
                      ? [
                          VerifyOtp(
                            fromProfile: false,
                            navigateToProfile: () {},
                            fromExpired: true,
                            isVisWhatsApp: 1,
                            navigateToAddName: () {},
                            navigateTocartOrProfile: () {
                              isVerified.value = true;
                            },
                            fromLogin: false,
                            onLoginFailed: () {
                              //   pageController.animateToPage(3, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                            goBack: () {
                              // pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                            methodIcon: AppAssets.whatsappSvg,
                            phoneNumber: prefsRepository.myPhoneNumber!,
                          ),
                        ]
                      : [
                          InsertPhoneTab(
                            focusNode: focusNode,
                            moveToNextStep: (String phoneNumber) {
                              this.phoneNumber = phoneNumber.replaceAll(
                                ' ',
                                '',
                              );
                              pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              setState(() {});
                            },
                          ),
                          VerificationMethods(
                            isFromLogin: false,
                            phoneNumber: phoneNumber,
                            onChooseWhatsapp: () {
                              isVisWhatsApp = 1;
                              print("###################33333# isVisWhatsApp}");
                              pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );

                              if (prefsRepository.isTimerForOtpRunning ??
                                  false) {
                                showWarningMessage(
                                  context,
                                  ' ${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                                );
                                return;
                              }
                              /*   authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                            },
                            goBackToPhone: () {
                              pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            onChooseSms: () {
                              isVisWhatsApp = 0;
                              pageController.animateToPage(
                                3,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              /* authBloc.add(
                              SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));*/
                            },
                          ),
                          VerifyOtp(
                            fromProfile: false,
                            navigateToProfile: () {},
                            fromExpired: true,
                            isVisWhatsApp: isVisWhatsApp,
                            navigateToAddName: () {},
                            navigateTocartOrProfile: () {
                              isVerified.value = true;
                            },
                            fromLogin: false,
                            onLoginFailed: () {
                              pageController.animateToPage(
                                3,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            goBack: () {
                              pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            methodIcon: isVisWhatsApp == 1
                                ? AppAssets.whatsappSvg
                                : AppAssets.smsSvg,
                            phoneNumber: phoneNumber,
                          ),
                        ],
                ),
                Positioned(
                  top: 0,
                  left: LanguageService.languageCode != "ar" ? null : 0,
                  right: LanguageService.languageCode != "ar" ? 0 : null,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 20,
                    width: 40,
                    child: InkWell(
                      onTap: () => isVerified.value = true,
                      child: SvgPicture.asset(
                        AppAssets.closeSvg,
                        height: 15,
                        width: 30,
                        // ignore: deprecated_member_use
                        color: const Color(0xffFF5F61),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    orders!.orderAmount == "unpaid"
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
                                        fontSize: 14,
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
                              // orderBloc.add(
                              //   GetOrdersByOrderGroupIDEvent(
                              //     orderGroupId: orders.orderGroupId ?? "",
                              //   ),
                              // );
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
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 50,
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
                                                  orderId: orders!.id
                                                      .toString(),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        alignment: Alignment.center,
                                        width: 1.sw,
                                        height: 50,
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
                      width: 200,
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

  // Widget shadowForChangeAddressContent(int tapIndex) {
  //   return BlocBuilder<OrderBloc, OrderState>(
  //     buildWhen: (previous, current) =>
  //         previous.getCustomerAddressStatus !=
  //             current.getCustomerAddressStatus ||
  //         previous.editAddressToOrderStatus !=
  //             current.editAddressToOrderStatus ||
  //         previous.setCustomerAddressDefaultStatus !=
  //             current.setCustomerAddressDefaultStatus ||
  //         previous.addAddressToOrderStatus != current.addAddressToOrderStatus ||
  //         previous.removeAddressToOrderStatus !=
  //             current.removeAddressToOrderStatus,
  //     builder: (context, state) {
  //       return ValueListenableBuilder<bool>(
  //         valueListenable: showShadowForChangeAddress,
  //         builder: (context, isShowShadowForChangeAddress, _) {
  //           return !isShowShadowForChangeAddress
  //               ? const SizedBox.shrink()
  //               : Container(
  //                   height: 1.sh,
  //                   width: 1.sw,
  //                   color: const Color.fromRGBO(29, 29, 29, 0.95),
  //                   child: Column(
  //                     children: [
  //                       const Spacer(),
  //                       SvgPicture.asset(AppAssets.clarificationSvg),
  //                       SizedBox(height: 20.h),
  //                       Text(
  //                         LocaleKeys.clarification.tr(),
  //                         style: context.textTheme.bodyMedium?.mq.copyWith(
  //                           color: Colors.white,
  //                           letterSpacing: 0.18,
  //                           fontSize: 40.h,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Text(
  //                         LocaleKeys.about_change_request_address.tr(),
  //                         style: context.textTheme.bodyMedium?.rq.copyWith(
  //                           color: Colors.white,
  //                           letterSpacing: 0.18,
  //                           fontSize: 16.sp,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       SizedBox(height: 20.h),
  //                       SvgPicture.asset(
  //                         AppAssets.orderChangeAddressSvg,
  //                         width: 50,
  //                         // ignore: deprecated_member_use
  //                         color: Colors.white,
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Text(
  //                         LocaleKeys.change_below_address.tr(),
  //                         style: context.textTheme.bodyMedium?.mq.copyWith(
  //                           color: const Color(0xffD3D3D3),
  //                           letterSpacing: 0.18,
  //                           fontSize: 16.sp,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 24),
  //                         child: addressInfoWithContactInfoCart(
  //                           isChange: true,
  //                           customerAddressesInfo: CustomerAddressesInfo(
  //                             address:
  //                                 orders.shippingAddressData?.address ?? '',
  //                             addressDetail:
  //                                 orders.shippingAddressData?.addressDetail ??
  //                                 '',
  //                             contactInfo: ContactInfo(
  //                               alternativePhone:
  //                                   orders
  //                                       .shippingAddressData
  //                                       ?.alternativePhone ??
  //                                   '',
  //                               name:
  //                                   orders
  //                                       .shippingAddressData
  //                                       ?.contactPersonName ??
  //                                   '',
  //                               phone: orders.shippingAddressData?.phone ?? '',
  //                             ),
  //                             id: orders.shippingAddressData?.id,
  //                             regionDetails: RegionDetails(
  //                               building:
  //                                   orders.shippingAddressData?.building ?? '',
  //                               city: orders.shippingAddressData?.city ?? '',
  //                               country:
  //                                   orders.shippingAddressData?.country ?? '',
  //                               province:
  //                                   orders.shippingAddressData?.province ?? '',
  //                               street:
  //                                   orders.shippingAddressData?.street ?? '',
  //                               town: orders.shippingAddressData?.town ?? '',
  //                             ),
  //                           ),
  //                           context: context,
  //                           index: 0,
  //                           indexTap: 1,
  //                           onTapDelete: () {},
  //                           onTapEdit: () {
  //                             /*    //     panelController.close();
  //                               HelperFunctions.slidingNavigation(
  //                                 context,
  //                                 AddShippingAdress(
  //                                   addressInfoClassToEdid:
  //                                       state.listOfAddressInfoClassToSave![
  //                                           state.currentAddressChoosed ?? 0],
  //                                   fromEdid: true,
  //                                 ),
  //                               );*/
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Text(
  //                         LocaleKeys.to_new_address.tr(),
  //                         style: context.textTheme.bodyMedium?.mq.copyWith(
  //                           color: Colors.white,
  //                           letterSpacing: 0.18,
  //                           fontSize: 16.sp,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       SizedBox(height: 10.h),
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 24),
  //                         child: addressInfoWithContactInfoCart(
  //                           isChange: true,
  //                           customerAddressesInfo:
  //                               state.listOfAddressInfoClassToSave![tapIndex],
  //                           context: context,
  //                           index: 0,
  //                           indexTap: 0,
  //                           onTapDelete: () {},
  //                           onTapEdit: () {
  //                             // panelController.close();
  //                             HelperFunctions.slidingNavigation(
  //                               context,
  //                               AddShippingAdress(
  //                                 addressInfoClassToEdid: state
  //                                     .listOfAddressInfoClassToSave![tapIndex],
  //                                 fromEdid: true,
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 15.h),
  //                       Text(
  //                         LocaleKeys
  //                             .we_will_ignore_first_address_send_order_new_address
  //                             .tr(),
  //                         textAlign: TextAlign.center,
  //                         style: context.textTheme.bodyMedium?.mq.copyWith(
  //                           color: Colors.white,
  //                           letterSpacing: 0.18,
  //                           fontSize: 12.sp,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       SizedBox(height: 40.h),
  //                       SvgPicture.asset(AppAssets.termsCanselSvg),
  //                       SizedBox(height: 10.h),
  //                       Text(
  //                         "${LocaleKeys.terms_of_change_address_terms.tr()} ",
  //                         style: context.textTheme.bodyMedium?.rq.copyWith(
  //                           color: Colors.white,
  //                           letterSpacing: 0.18,
  //                           fontSize: 14.sp,
  //                           height: 1.3,
  //                         ),
  //                       ),
  //                       ValueListenableBuilder<bool>(
  //                         valueListenable: agreeToPolicies,
  //                         builder: (context, _agreeToPolicies, _) {
  //                           return Container(
  //                             alignment: Alignment.center,
  //                             height: 40.h,
  //                             width: 1.sw,
  //                             child: InkWell(
  //                               onTap: () =>
  //                                   agreeToPolicies.value = !_agreeToPolicies,
  //                               child: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   SvgPicture.asset(
  //                                     AppAssets.detectedSvg,
  //                                     // ignore: deprecated_member_use
  //                                     color: _agreeToPolicies
  //                                         ? const Color(0xff388CFF)
  //                                         : const Color(0xff8E8E8E),
  //                                   ),
  //                                   const SizedBox(width: 5),
  //                                   Text(
  //                                     "${LocaleKeys.i_read_and_agree_to_the.tr()} ",
  //                                     style: context.textTheme.bodyMedium?.rq
  //                                         .copyWith(
  //                                           color: Colors.white,
  //                                           letterSpacing: 0.18,
  //                                           fontSize: 14.sp,
  //                                           height: 1.3,
  //                                         ),
  //                                   ),
  //                                   Text(
  //                                     LocaleKeys.change_addres_terms.tr(),
  //                                     style: context.textTheme.bodyMedium?.mq
  //                                         .copyWith(
  //                                           decorationColor: Colors.white,
  //                                           decoration:
  //                                               TextDecoration.underline,
  //                                           color: Colors.white,
  //                                           letterSpacing: 0.18,
  //                                           fontSize: 16.sp,
  //                                           height: 1.3,
  //                                         ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       BlocListener<OrderBloc, OrderState>(
  //                         listenWhen: (previous, current) =>
  //                             previous.changeOrderAddressStatus !=
  //                             current.changeOrderAddressStatus,
  //                         listener: (context, state) {
  //                           if (state.changeOrderAddressStatus ==
  //                               ChangeOrderAddressStatus.success) {
  //                             orderBloc.add(
  //                               GetOrdersByOrderGroupIDEvent(
  //                                 orderGroupId: orders.orderGroupId ?? "",
  //                               ),
  //                             );
  //                             agreeToPolicies.value = false;
  //                             panelController.close();
  //                             showPanel.value = false;
  //                             optionModifyPanel.value = null;
  //                             showShadowForCanselOrder.value = false;
  //                             enableChangeAddress.value = false;
  //                             optionCanselOrReturn.value = [];
  //                             showShadowForPanel.value = false;
  //                             showShadowForChangeAddress.value = false;
  //                           }
  //                         },
  //                         child: BlocBuilder<OrderBloc, OrderState>(
  //                           buildWhen: (previous, current) =>
  //                               previous.changeOrderAddressStatus !=
  //                               current.changeOrderAddressStatus,
  //                           builder: (context, state) {
  //                             return state.changeOrderAddressStatus ==
  //                                     ChangeOrderAddressStatus.loading
  //                                 ? Shimmer.fromColors(
  //                                     baseColor: Colors.grey[500]!,
  //                                     highlightColor: Colors.grey[300]!,
  //                                     child: Container(
  //                                       margin: const EdgeInsets.symmetric(
  //                                         horizontal: 24,
  //                                       ),
  //                                       alignment: Alignment.center,
  //                                       width: 1.sw,
  //                                       height: 50.h,
  //                                       decoration: BoxDecoration(
  //                                         color: agreeToPolicies.value == true
  //                                             ? const Color(0xff3066CC)
  //                                             : const Color(0xffC4C2C2),
  //                                         border: agreeToPolicies.value == true
  //                                             ? Border.all(
  //                                                 color: const Color(
  //                                                   0xffF8F8F8,
  //                                                 ),
  //                                               )
  //                                             : Border.all(
  //                                                 color: const Color(
  //                                                   0xffC4C2C2,
  //                                                 ),
  //                                               ),
  //                                         borderRadius: BorderRadius.circular(
  //                                           15,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   )
  //                                 : InkWell(
  //                                     onTap: () {
  //                                       if (agreeToPolicies.value == false) {
  //                                         return;
  //                                       }
  //                                       orderBloc.add(
  //                                         ChangeOrderAddressEvent(
  //                                           changeOrderAddressParams:
  //                                               ChangeOrderAddressParams(
  //                                                 orderGroupId:
  //                                                     orders.orderGroupId ?? "",
  //                                                 newShippingAddressId:
  //                                                     state
  //                                                         .listOfAddressInfoClassToSave?[indexTapAddress
  //                                                             .value]
  //                                                         .id
  //                                                         .toString() ??
  //                                                     '',
  //                                               ),
  //                                         ),
  //                                       );
  //                                     },
  //                                     child: ValueListenableBuilder<bool>(
  //                                       valueListenable: agreeToPolicies,
  //                                       builder:
  //                                           (context, _agreeToPolicies, _) {
  //                                             return Container(
  //                                               margin:
  //                                                   const EdgeInsets.symmetric(
  //                                                     horizontal: 24,
  //                                                   ),
  //                                               alignment: Alignment.center,
  //                                               width: 1.sw,
  //                                               height: 50.h,
  //                                               decoration: BoxDecoration(
  //                                                 color:
  //                                                     agreeToPolicies.value ==
  //                                                         true
  //                                                     ? Colors.white
  //                                                     : const Color(0xffC4C2C2),
  //                                                 border:
  //                                                     agreeToPolicies.value ==
  //                                                         false
  //                                                     ? null
  //                                                     : Border.all(
  //                                                         color: const Color(
  //                                                           0xff402CDD,
  //                                                         ),
  //                                                       ),
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(15),
  //                                               ),
  //                                               child: Text(
  //                                                 LocaleKeys.i_agree_change
  //                                                     .tr(),
  //                                                 textAlign: TextAlign.center,
  //                                                 style: context
  //                                                     .textTheme
  //                                                     .bodyMedium
  //                                                     ?.bq
  //                                                     .copyWith(
  //                                                       color:
  //                                                           agreeToPolicies
  //                                                                   .value ==
  //                                                               true
  //                                                           ? const Color(
  //                                                               0xff402CDD,
  //                                                             )
  //                                                           : Colors.white,
  //                                                       letterSpacing: 0.18,
  //                                                       fontSize: 16.sp,
  //                                                       height: 1.3,
  //                                                     ),
  //                                               ),
  //                                             );
  //                                           },
  //                                     ),
  //                                   );
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                       Container(
  //                         width: 200,
  //                         height: 40.h,
  //                         child: BlocBuilder<OrderBloc, OrderState>(
  //                           buildWhen: (previous, current) =>
  //                               previous.changeOrderAddressStatus !=
  //                               current.changeOrderAddressStatus,
  //                           builder: (context, state) {
  //                             return InkWell(
  //                               onTap: () {
  //                                 if (state.changeOrderAddressStatus ==
  //                                     ChangeOrderAddressStatus.loading) {
  //                                   return;
  //                                 }
  //                                 agreeToPolicies.value = false;
  //                                 panelController.close();
  //                                 showPanel.value = false;
  //                                 optionModifyPanel.value = null;
  //                                 optionCanselOrReturn.value = [];
  //                                 enableChangeAddress.value = false;
  //                                 showShadowForPanel.value = false;
  //                                 showShadowForChangeAddress.value = false;

  //                                 showShadowForCanselOrder.value = false;
  //                               },
  //                               child: Text(
  //                                 LocaleKeys.i_disagree.tr(),
  //                                 textAlign: TextAlign.center,
  //                                 style: context.textTheme.bodyMedium?.rq
  //                                     .copyWith(
  //                                       color: Colors.white,

  //                                       decorationColor: Colors.white,
  //                                       decoration: TextDecoration.underline,
  //                                       letterSpacing: 0.18,
  //                                       fontSize: 16.sp,
  //                                       height: 1.3,
  //                                     ),
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: 10.h),
  //                     ],
  //                   ),
  //                 );
  //         },
  //       );
  //     },
  //   );
  // }

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
                    : Colors.white,
              )
            : index != indexTap
            ? null
            : Border.all(color: const Color(0xff388CFF)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
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
                            height: 30.h,
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
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
                const SizedBox(width: 40),
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
                        width: 12,
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 130,
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
                  maxHeight: (_option == null || (_option == "All_Order"))
                      ? 512
                      : (1.sh - 70),
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
      //return panelAddressContent(sc);
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
                        SvgPicture.asset(AppAssets.orderClockSvg, height: 15.h),
                        const SizedBox(width: 5),
                        Text(
                          HelperFunctions.orderFormatDate(
                            DateTime.tryParse(orders!.createdAt.date) ??
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
                          "",
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
                          orders!.orderStatus,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 11.sp,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        SvgPicture.asset(
                          AppAssets.orderPreparingSvg,
                          height: 15.h,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppAssets.orderInvoice2Svg,
                          height: 15.h,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          (orders!.details.length).toString(),
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
                                  orders!.orderAmount,
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
                      itemCount: orders!.details.length,
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
                              imageUrl: orders!.details[index].cartImage,
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
            SizedBox(height: 8.h),
            SvgPicture.asset(AppAssets.orderCanselSvg, width: 30),
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
                  "  ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((orders!.orderAmount), homeBloc.state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * (GetIt.I<HomeBloc>().state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!)), isNeedRounding: false)}",
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Column(
              children: [
                const Row(
                  children: [
                    // optionOfCanselOrReturnOrder(
                    //   LocaleKeys.i_changed_mind.tr(),
                    //   130,
                    //   () {
                    //     List<String> options = optionCanselOrReturn.value;
                    //     if (optionCanselOrReturn.value.contains(
                    //       LocaleKeys.i_changed_mind.tr(),
                    //     )) {
                    //       options.remove(LocaleKeys.i_changed_mind.tr());

                    //       optionCanselOrReturn.value = [...options];

                    //       return;
                    //     }
                    //     options.add(LocaleKeys.i_changed_mind.tr());

                    //     optionCanselOrReturn.value = [...options];
                    //   },
                    // ),
                    SizedBox(width: 10),
                    // optionOfCanselOrReturnOrder(
                    //   LocaleKeys.i_fear_quality.tr(),
                    //   100,
                    //   () {
                    //     List<String> options = optionCanselOrReturn.value;
                    //     if (optionCanselOrReturn.value.contains(
                    //       LocaleKeys.i_fear_quality.tr(),
                    //     )) {
                    //       options.remove(LocaleKeys.i_fear_quality.tr());

                    //       optionCanselOrReturn.value = [...options];

                    //       return;
                    //     }
                    //     options.add(LocaleKeys.i_fear_quality.tr());

                    //     optionCanselOrReturn.value = [...options];
                    //   },
                    // ),
                  ],
                ),
                SizedBox(height: 10.h),
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
                      borderRadius: BorderRadius.circular(20),
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

  // Widget optionOfCanselOrReturnOrder(
  //   String text,
  //   double width,
  //   void Function()? onTap,
  // ) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: ValueListenableBuilder<List<String>>(
  //       valueListenable: optionCanselOrReturn,
  //       builder: (context, _optionCansel, _) {
  //         return Container(
  //           alignment: Alignment.center,
  //           height: 40,
  //           width: width,
  //           decoration: BoxDecoration(
  //             border: !_optionCansel.contains(text)
  //                 ? null
  //                 : Border.all(color: const Color(0xff402CDD)),
  //             color: const Color(0xffF8F8F8),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Text(
  //             text,
  //             style: context.textTheme.bodyMedium?.rq.copyWith(
  //               color: const Color(0xff5D5C5D),
  //               letterSpacing: 0.18,
  //               fontSize: 12,
  //               height: 1.3,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget panelAddressContent(ScrollController sc) {
  //   return BlocListener<OrderBloc, OrderState>(
  //     listenWhen: (previous, current) =>
  //         previous.getCustomerAddressStatus != current.getCustomerAddressStatus,
  //     listener: (context, state) {
  //       if (state.getCustomerAddressStatus ==
  //           GetCustomerAddressesStatus.success) {
  //         indexTapAddress.value =
  //             orderBloc.state.listOfAddressInfoClassToSave?.indexWhere(
  //               (element) => element.id == orders.shippingAddressData?.id,
  //             ) ??
  //             -1;
  //         firstAddressChoosed = indexTapAddress.value;
  //         if (indexTapAddress.value == -1) {
  //           enableChangeAddress.value = true;
  //         } else if (indexTapAddress.value != firstAddressChoosed ||
  //             (state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .address !=
  //                     orders.shippingAddressData?.address ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .addressDetail !=
  //                     orders.shippingAddressData?.addressDetail ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .contactInfo
  //                         ?.name !=
  //                     orders.shippingAddressData?.contactPersonName ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .contactInfo
  //                         ?.phone !=
  //                     orders.shippingAddressData?.phone ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.country !=
  //                     orders.shippingAddressData?.country ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.city !=
  //                     orders.shippingAddressData?.city ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.province !=
  //                     orders.shippingAddressData?.province ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.street !=
  //                     orders.shippingAddressData?.street ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.building !=
  //                     orders.shippingAddressData?.building ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .regionDetails
  //                         ?.town !=
  //                     orders.shippingAddressData?.town ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .location
  //                         ?.latitude !=
  //                     orders.shippingAddressData?.latitude ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .location
  //                         ?.longitude !=
  //                     orders.shippingAddressData?.longitude ||
  //                 state
  //                         .listOfAddressInfoClassToSave![indexTapAddress.value]
  //                         .contactInfo
  //                         ?.alternativePhone !=
  //                     orders.shippingAddressData?.alternativePhone)) {
  //           enableChangeAddress.value = true;
  //         } else {
  //           enableChangeAddress.value = false;
  //         }
  //       }
  //     },
  //     child: BlocBuilder<OrderBloc, OrderState>(
  //       buildWhen: (previous, current) =>
  //           previous.getCustomerAddressStatus !=
  //               current.getCustomerAddressStatus ||
  //           previous.editAddressToOrderStatus !=
  //               current.editAddressToOrderStatus ||
  //           previous.setCustomerAddressDefaultStatus !=
  //               current.setCustomerAddressDefaultStatus ||
  //           previous.addAddressToOrderStatus !=
  //               current.addAddressToOrderStatus ||
  //           previous.removeAddressToOrderStatus !=
  //               current.removeAddressToOrderStatus,
  //       builder: (context, state) {
  //         return ValueListenableBuilder<int>(
  //           valueListenable: indexTapPackage,
  //           builder: (context, _indexTapPackage, _) {
  //             return ValueListenableBuilder<int>(
  //               valueListenable: indexTapAddress,
  //               builder: (context, _indexTap, _) {
  //                 return Column(
  //                   children: [
  //                     SizedBox(height: 10.h),
  //                     Container(
  //                       width: 40,
  //                       height: 2,
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xffC4C2C2),
  //                         border: Border.all(color: const Color(0xffC4C2C2)),
  //                         borderRadius: const BorderRadius.all(
  //                           Radius.circular(2),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 10.h),
  //                     Container(
  //                       width: 1.sw,
  //                       height: 200.h,
  //                       margin: const EdgeInsets.symmetric(horizontal: 10),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xffF8F8F8),
  //                         border: Border.all(color: const Color(0xffF8F8F8)),
  //                         borderRadius: const BorderRadius.all(
  //                           Radius.circular(15),
  //                         ),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           SizedBox(height: 10.h),
  //                           Container(
  //                             width: 1.sw,
  //                             height: 16.h,
  //                             child: Row(
  //                               children: [
  //                                 const SizedBox(width: 10),
  //                                 SvgPicture.asset(
  //                                   AppAssets.orderClockSvg,
  //                                   height: 15.h,
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   HelperFunctions.orderFormatDate(
  //                                     DateTime.tryParse(
  //                                           orders.createdAt ?? '',
  //                                         ) ??
  //                                         DateTime.now(),
  //                                   ),
  //                                   style: context.textTheme.bodyMedium?.rq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const Spacer(),
  //                                 SvgPicture.asset(
  //                                   AppAssets.orderBag1Svg,
  //                                   height: 15.h,
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   orders.orderGroupId ?? "",
  //                                   style: context.textTheme.bodyMedium?.mq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 10),
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(height: 10.h),
  //                           Container(
  //                             width: 1.sw,
  //                             height: 16.h,
  //                             child: Row(
  //                               children: [
  //                                 const SizedBox(width: 10),
  //                                 SvgPicture.asset(
  //                                   AppAssets.preparingBagSvg,
  //                                   height: 15.h,
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   orders.orderGroupStatus?.label ?? "",
  //                                   style: context.textTheme.bodyMedium?.rq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 SvgPicture.asset(
  //                                   AppAssets.orderPreparingSvg,
  //                                   height: 15.h,
  //                                 ),
  //                                 const Spacer(),
  //                                 SvgPicture.asset(
  //                                   AppAssets.orderInvoice2Svg,
  //                                   height: 15.h,
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   (orders.details?.length ?? "").toString(),
  //                                   style: context.textTheme.bodyMedium?.bq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   LocaleKeys.item.tr(),
  //                                   style: context.textTheme.bodyMedium?.mq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   HelperFunctions.formatNumber(
  //                                     numberToFormate:
  //                                         (HelperFunctions.truncateToDecimalPlaces(
  //                                           orders.orderAmount!,
  //                                           homeBloc
  //                                               .state
  //                                               .getCurrencyForCountryModel!
  //                                               .data!
  //                                               .currency!
  //                                               .decimalDigits!,
  //                                         ) *
  //                                         homeBloc
  //                                             .state
  //                                             .getCurrencyForCountryModel!
  //                                             .data!
  //                                             .currency!
  //                                             .exchangeRate!),
  //                                     isNeedRounding: false,
  //                                   ),
  //                                   style: context.textTheme.bodyMedium?.bq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 Text(
  //                                   homeBloc
  //                                       .state
  //                                       .getCurrencyForCountryModel!
  //                                       .data!
  //                                       .currency!
  //                                       .symbol!,
  //                                   style: context.textTheme.bodyMedium?.rq
  //                                       .copyWith(
  //                                         color: const Color(0xff1D1D1D),
  //                                         letterSpacing: 0.18,
  //                                         fontSize: 12.sp,
  //                                         height: 1.3,
  //                                       ),
  //                                 ),
  //                                 const SizedBox(width: 10),
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(height: 10.h),
  //                           Container(
  //                             height: 125.h,
  //                             width: 1.sw,
  //                             padding: EdgeInsets.only(
  //                               left: LanguageService.languageCode == "ar"
  //                                   ? 0
  //                                   : 10,
  //                               right: LanguageService.languageCode != "ar"
  //                                   ? 0
  //                                   : 10,
  //                             ),
  //                             child: ListView.builder(
  //                               itemCount: orders.details?.length,
  //                               scrollDirection: Axis.horizontal,
  //                               itemBuilder: (context, index) {
  //                                 return Container(
  //                                   height: 125.h,
  //                                   width: 92,
  //                                   decoration: const BoxDecoration(
  //                                     borderRadius: BorderRadius.all(
  //                                       Radius.circular(15),
  //                                     ),
  //                                   ),
  //                                   child: ClipRRect(
  //                                     borderRadius: const BorderRadius.all(
  //                                       Radius.circular(15),
  //                                     ),
  //                                     child: MyCachedNetworkImage(
  //                                       imageUrl:
  //                                           orders.details?[index].image ?? "",
  //                                       width: 92,
  //                                       imageFit: BoxFit.contain,
  //                                       height: 125.h,
  //                                     ),
  //                                   ),
  //                                 );
  //                               },
  //                             ),
  //                           ),
  //                           SizedBox(height: 10.h),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 10.h),
  //                     SvgPicture.asset(
  //                       AppAssets.orderChangeAddressSvg,
  //                       height: 30.h,
  //                     ),
  //                     SizedBox(height: 15.h),
  //                     Text(
  //                       LocaleKeys.change_delivery_address.tr(),
  //                       style: context.textTheme.bodyMedium?.mq.copyWith(
  //                         color: const Color(0xff1D1D1D),
  //                         letterSpacing: 0.18,
  //                         fontSize: 14.sp,
  //                         height: 1.3,
  //                       ),
  //                     ),
  //                     SizedBox(height: 10.h),
  //                     Text(
  //                       LocaleKeys.you_can_change_delivery_address_delivery_note
  //                           .tr(),
  //                       style: context.textTheme.bodyMedium?.rq.copyWith(
  //                         color: const Color(0xff8D8D8D),
  //                         letterSpacing: 0.18,
  //                         fontSize: 12.sp,
  //                         height: 1.3,
  //                       ),
  //                     ),
  //                     const Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 24),
  //                       child: Divider(color: Color(0xffC4C2C2)),
  //                     ),
  //                     SizedBox(height: 10.h),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 5),
  //                       child: addressWidgets(context, state, _indexTap, sc),
  //                     ),
  //                     const Spacer(),
  //                     ValueListenableBuilder<bool>(
  //                       valueListenable: enableChangeAddress,
  //                       builder: (context, _enableChangeAddress, _) {
  //                         return InkWell(
  //                           onTap: () {
  //                             if (_enableChangeAddress) {
  //                               showShadowForChangeAddress.value = true;
  //                             }
  //                           },
  //                           child: Container(
  //                             margin: const EdgeInsets.symmetric(
  //                               horizontal: 24,
  //                             ),
  //                             width: 1.sw,
  //                             height: 53.h,
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(20),
  //                               color: _enableChangeAddress
  //                                   ? const Color(0xff402CDD)
  //                                   : const Color(0xffD3D3D3),
  //                             ),
  //                             alignment: Alignment.center,
  //                             child: Text(
  //                               "${LocaleKeys.change_request.tr()} ",
  //                               style: context.textTheme.bodyMedium?.mq
  //                                   .copyWith(
  //                                     color: const Color(0xffFFFFFF),
  //                                     letterSpacing: 0.18,
  //                                     fontSize: 16.sp,
  //                                     height: 1.33,
  //                                   ),
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     SizedBox(height: 10.h),
  //                   ],
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget addressWidgets(
  //   BuildContext context,
  //   OrderState state,
  //   int _indexTap,
  //   ScrollController sc,
  // ) {
  //   return Container(
  //     width: 1.sw,
  //     height: 410.h,
  //     child: Column(
  //       children: [
  //         SizedBox(height: 10.h),
  //         Container(
  //           height: 50.h,
  //           width: 1.sw,
  //           margin: const EdgeInsets.symmetric(horizontal: 24),
  //           decoration: const BoxDecoration(
  //             color: Color(0xffF8F8F8),
  //             borderRadius: BorderRadius.all(Radius.circular(15)),
  //           ),
  //           child: Row(
  //             children: [
  //               Container(
  //                 alignment: Alignment.center,
  //                 height: 50.h,
  //                 width: ((1.sw - 58) / 2),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: const Color(0xff402CDD)),
  //                   borderRadius: const BorderRadius.all(Radius.circular(15)),
  //                 ),
  //                 child: Text(
  //                   LocaleKeys.delivery_address.tr(),
  //                   style: context.textTheme.bodyMedium?.mq.copyWith(
  //                     color: const Color(0xff1D1D1D),
  //                     letterSpacing: 0.18,
  //                     fontSize: 14,
  //                     height: 1.33,
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                 alignment: Alignment.center,
  //                 height: 50.h,
  //                 width: ((1.sw - 58) / 2),
  //                 decoration: const BoxDecoration(
  //                   //   border: Border.all(color: Color(0xff402CDD)),
  //                   borderRadius: BorderRadius.all(Radius.circular(15)),
  //                 ),
  //                 child: Text(
  //                   LocaleKeys.delivery_note.tr(),
  //                   style: context.textTheme.bodyMedium?.rq.copyWith(
  //                     color: const Color(0xff1D1D1D),
  //                     letterSpacing: 0.18,
  //                     fontSize: 14,
  //                     height: 1.33,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 20.h),
  //         state.getCustomerAddressStatus ==
  //                     GetCustomerAddressesStatus.loading ||
  //                 state.addAddressToOrderStatus ==
  //                     AddAddressToOrderStatus.loading ||
  //                 state.removeAddressToOrderStatus ==
  //                     RemoveAddressToOrderStatus.loading ||
  //                 state.editAddressToOrderStatus ==
  //                     EditAddressToOrderStatus.loading
  //             ? TrydosLoader(size: 16)
  //             : Text(
  //                 "${LocaleKeys.your_address_list.tr()} ",
  //                 style: context.textTheme.bodyMedium?.mq.copyWith(
  //                   color: const Color(0xff1D1D1D),
  //                   letterSpacing: 0.18,
  //                   fontSize: 12,
  //                   height: 1.33,
  //                 ),
  //               ),
  //         SizedBox(height: 10.h),
  //         state.getCustomerAddressStatus ==
  //                     GetCustomerAddressesStatus.loading ||
  //                 state.addAddressToOrderStatus ==
  //                     AddAddressToOrderStatus.loading ||
  //                 state.removeAddressToOrderStatus ==
  //                     RemoveAddressToOrderStatus.loading ||
  //                 state.editAddressToOrderStatus ==
  //                     EditAddressToOrderStatus.loading
  //             ? const SizedBox.shrink()
  //             : Stack(
  //                 children: [
  //                   Container(
  //                     height: 295.h,
  //                     width: 1.sw,
  //                     child: ListView.separated(
  //                       padding: const EdgeInsets.symmetric(horizontal: 24),
  //                       itemBuilder: (context, index) =>
  //                           index == state.listOfAddressInfoClassToSave!.length
  //                           ? SizedBox(height: 50, width: 1.sw)
  //                           : InkWell(
  //                               onTap: () {
  //                                 if (index != firstAddressChoosed ||
  //                                     (state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .address !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.address ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .addressDetail !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.addressDetail ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .contactInfo
  //                                                 ?.name !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.contactPersonName ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .contactInfo
  //                                                 ?.phone !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.phone ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.country !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.country ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.city !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.city ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.province !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.province ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.street !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.street ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.building !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.building ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .regionDetails
  //                                                 ?.town !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.town ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .location
  //                                                 ?.latitude !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.latitude ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .location
  //                                                 ?.longitude !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.longitude ||
  //                                         state
  //                                                 .listOfAddressInfoClassToSave![index]
  //                                                 .contactInfo
  //                                                 ?.alternativePhone !=
  //                                             orders
  //                                                 .shippingAddressData
  //                                                 ?.alternativePhone)) {
  //                                   enableChangeAddress.value = true;
  //                                 } else {
  //                                   enableChangeAddress.value = false;
  //                                 }
  //                                 indexTapAddress.value = index;
  //                               },
  //                               child: addressInfoWithContactInfoCart(
  //                                 isChange: false,
  //                                 customerAddressesInfo: state
  //                                     .listOfAddressInfoClassToSave![index],
  //                                 context: context,
  //                                 index: index,
  //                                 indexTap: _indexTap,
  //                                 onTapDelete: () {},
  //                                 onTapEdit: () {
  //                                   //   panelController.close();
  //                                   HelperFunctions.slidingNavigation(
  //                                     context,
  //                                     AddShippingAdress(
  //                                       addressInfoClassToEdid: state
  //                                           .listOfAddressInfoClassToSave![index],
  //                                       fromEdid: true,
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                       separatorBuilder: (context, index) =>
  //                           const SizedBox(height: 10),
  //                       itemCount:
  //                           state.listOfAddressInfoClassToSave!.length + 1,
  //                       controller: sc,
  //                     ),
  //                   ),
  //                   Positioned(
  //                     child: InkWell(
  //                       onTap: () {
  //                         // panelController.close();
  //                         HelperFunctions.slidingNavigation(
  //                           context,
  //                           const AddShippingAdress(),
  //                         );
  //                       },
  //                       child: Container(
  //                         height: 40,
  //                         width: 1.sw - 56,

  //                         decoration: BoxDecoration(
  //                           color: const Color(0xffE8FFED),
  //                           borderRadius: BorderRadius.circular(15),
  //                           border: Border.all(color: const Color(0xffC4C2C2)),
  //                         ),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Center(
  //                               child: Stack(
  //                                 alignment: Alignment.center,
  //                                 children: [
  //                                   SvgPicture.asset(
  //                                     AppAssets.addShippingAddressSvg,
  //                                   ),
  //                                   Positioned(
  //                                     top: 2,
  //                                     child: SvgPicture.asset(
  //                                       AppAssets.addShippingAddressWhiteSvg,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             const SizedBox(width: 3),
  //                             Text(
  //                               "${LocaleKeys.add_new_shipping_address.tr()} ",
  //                               style: context.textTheme.bodyMedium?.mq
  //                                   .copyWith(
  //                                     color: const Color(0xff1D1D1D),
  //                                     letterSpacing: 0.18,
  //                                     fontSize: 12,
  //                                     height: 1.33,
  //                                   ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     bottom: 0,
  //                   ),
  //                 ],
  //                 alignment: Alignment.center,
  //               ),
  //       ],
  //     ),
  //   );
  // }

  Widget optionsForAllOrder() {
    return ValueListenableBuilder<int>(
      valueListenable: indexTapPackage,
      builder: (context, _indexTapPackage, _) {
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
                            DateTime.tryParse(orders!.createdAt.date) ??
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
                          "",
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
                          orders!.orderStatus,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        SvgPicture.asset(
                          AppAssets.orderPreparingSvg,
                          height: 15.h,
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          AppAssets.orderInvoice2Svg,
                          height: 15.h,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          (orders!.details.length).toString(),
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
                                  orders!.orderAmount,
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
                      itemCount: orders!.details.length,
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
                              imageUrl: orders!.details[index].cartImage,
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
            // orders.canUpdateAddress ?? false
            //     ? Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 24),
            //         child: optionOfModify(
            //           onTap: () {
            //             orderBloc.add(const ResetAllStatusEvent());
            //             optionModifyPanel.value = "Change_Address";
            //           },
            //           svg: AppAssets.orderChangeAddressSvg,
            //           image2: "",
            //           tiltle: "${LocaleKeys.change_delivery_address.tr()}",
            //           body:
            //               "${LocaleKeys.you_can_change_delivery_address_delivery_note.tr()}",
            //         ),
            //       )
            //     : const SizedBox.shrink(),
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
            // (orders.canCanceleOrder ?? false)
            //     ? Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 24),
            //         child: optionOfModify(
            //           onTap: () {
            //             orderBloc.add(const ResetAllStatusEvent());
            //             optionModifyPanel.value = "Cancel_This_Order";
            //           },
            //           svg: AppAssets.orderCanselSvg,
            //           image2: "",
            //           tiltle:
            //               "${LocaleKeys.cancel_this_order.tr()} ${orders.id}",
            //           body: LocaleKeys.cancel_order_hours_back_money.tr(
            //             namedArgs: {'hours': '3'},
            //           ),
            //         ),
            //       )
            //     : const SizedBox.shrink(),
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
                ),
                ///////////////////
                const SizedBox(height: 3),
                ///////////////////
                OrderStatusClass.statusOrderIsDelivered(orderStatus)
                    ? SvgPicture.asset(AppAssets.delivered_bagSvg, width: 13)
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
                                  width: 13,
                                ),
                          //////////////////////////
                          const SizedBox(width: 2),
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
                            width: 13,
                          ),
                        ],
                      ),
                ///////////////////
                const SizedBox(height: 2),

                ///////////////////
                OrderStatusClass.statusOrderIsDelivered(orderStatus)
                    ? Text(
                        LocaleKeys.delivered.tr(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      )
                    : Text(
                        (details?[index].variation.isNullOrEmpty ?? false)
                            ? ''
                            : details?[index].variation?[0].color?.name ?? '',
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
                const SizedBox(height: 2),
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
                                  isVerified.value = false;
                                  if ((prefsRepository
                                          .isVerifiedPhonePeforeExpiredToken ??
                                      false)) {
                                    GetIt.I<AuthBloc>().add(
                                      SendOtpEvent(
                                        phone: prefsRepository.myPhoneNumber!,
                                        isViaWhatsApp: 1,
                                      ),
                                    );
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
                                              ownerId: "orders.ownerId",
                                              ownerType: "orders.ownerType",
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
                                            ownerId: "orders.ownerId",
                                            ownerType: "orders.ownerType",
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
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 5);
          },
        ),
      ),
    );
  }

  // count of items section
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
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(AppAssets.bagsSvg, width: 20),
                ///////////////////
                const SizedBox(height: 2),
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
                const SizedBox(height: 2),
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
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 17),
                ///////////////////
                const SizedBox(height: 2),
                ///////////////////
                Text(
                  LocaleKeys.order_status.tr(),
                  style: context.textTheme.bodyMedium?.rq.copyWith(
                    color: const Color(0xff8D8D8D),
                    letterSpacing: 0.18,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                ///////////////////
                const SizedBox(height: 2),
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
                        text: apiOrderStatus ?? orders!.orderStatus,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          color: const Color(0xff1D1D1D),
                          letterSpacing: 0.18,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
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
                return ((apiOrderStatus ?? orders!.orderStatus) !=
                            "out_for_delivery") &&
                        (!(fromNotification &&
                            ((!(widget.parentOrderIdFormNotification == null ||
                                    widget.parentOrderIdFormNotification ==
                                        "" ||
                                    widget.parentOrderIdFormNotification ==
                                        "-1")) ||
                                (!(widget.orderIdFormNotification == null ||
                                    widget.orderIdFormNotification == "" ||
                                    widget.orderIdFormNotification == "-1")))))
                    ? const SizedBox.shrink()
                    : Container(
                        height: 40,
                        child: BlocListener<CallsBloc, CallsState>(
                          listenWhen: (p, c) =>
                              p.makeCallStatus != c.makeCallStatus &&
                              p.makeCallStatus == MakeCallStatus.init &&
                              c.makeCallStatus == MakeCallStatus.loading,
                          listener: (context, state) {
                            print(
                              "GGGGGGFFFFFFFFFFFFFDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQ////",
                            );
                            callInProgressDialog(context);
                          },
                          child: BlocListener<CallsBloc, CallsState>(
                            listenWhen: (p, c) =>
                                p.makeCallStatus != c.makeCallStatus &&
                                c.makeCallStatus == MakeCallStatus.failure,
                            listener: (context, state) {
                              Navigator.pop(context);
                              showWarningMessage(
                                context,
                                '${state.receiverCallName ?? LocaleKeys.user.tr()} ${LocaleKeys.in_another_call.tr()}',
                              );
                            },
                            child: BlocListener<CallsBloc, CallsState>(
                              listenWhen: (p, c) =>
                                  p.makeCallStatus != c.makeCallStatus &&
                                  c.makeCallStatus == MakeCallStatus.startCall,
                              listener: (context, state) {
                                print(
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
                                      channelId: state.channelIdForCurrentCall!,
                                      auth_token:
                                          GetIt.I<PrefsRepository>().chatToken!,
                                      uId: GetIt.I<PrefsRepository>().myChatId
                                          .toString(),
                                      action: 'sent',
                                      messageId: state.messageId!,
                                    ),
                                  ),
                                );
                              },
                              child: BlocListener<ChatBloc, ChatState>(
                                listenWhen: (previous, current) =>
                                    previous.getOrderRecipientIdStatus !=
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
                                    requestReturnApiFromNotification = false;
                                    Future.delayed(
                                      const Duration(seconds: 3),
                                      () {
                                        if (canFetchReturnDetails) {
                                          orderBloc.add(
                                            const FetchOrderReturnDetailsEvent(
                                              "orders.orderGroupId",
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }

                                  if (state.getOrderRecipientIdStatus ==
                                      GetOrderRecipientIdStatus.success) {
                                    String receiverName =
                                        HelperFunctions.getTheFirstTwoLettersOfName(
                                          LocaleKeys.delivery_worker.tr(),
                                        );
                                    String fullReceiverName = LocaleKeys
                                        .delivery_worker
                                        .tr();
                                    String? recipientUserId =
                                        state.recipientUserId;
                                    print("recipientUserId $recipientUserId");
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
                                      (element) => element.channelMembers!.any((
                                        element,
                                      ) {
                                        return element.userId.toString() ==
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
                                        horizontal: 5,
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
                                          chatBloc.add(
                                            GetOrderRecipientIdEvent(
                                              originalUserId:
                                                  GetIt.I<PrefsRepository>()
                                                      .myMarketId
                                                      .toString(),

                                              orderId: orders!.id.toString(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.chatSvg,
                                              width: 15,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              LocaleKeys
                                                  .chat_with_delivery_person
                                                  .tr(),
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.rq
                                                  .copyWith(
                                                    color: const Color(
                                                      0xffFFFFFF,
                                                    ),
                                                    fontSize: 9,
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
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppAssets.groupStarsRattingSvg),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.rate_and_get_money.tr(),
            style: context.textTheme.bodyMedium?.mq.copyWith(
              color: const Color(0xff1D1D1D),
              letterSpacing: 0.18,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.rating_section_description.tr(),
            style: context.textTheme.bodyMedium?.rq.copyWith(
              color: const Color(0xff5D5C5D),
              letterSpacing: 0.18,
              fontSize: 10,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
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
                        // ignore: deprecated_member_use
                        color: const Color(0xffFFD800),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        LocaleKeys.rate_and_get_money.tr(),
                        style: context.textTheme.bodyMedium?.mq.copyWith(
                          fontSize: 14,
                          height: 1.7,
                          color: const Color(0xffFFD800),
                        ),
                      ),
                      const SizedBox(width: 12),
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
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
            ///////////////////
            BlocBuilder<OrderBloc, OrderState>(
              buildWhen: (previous, current) =>
                  previous.getOrdersByOrderGroupIDStatus !=
                  current.getOrdersByOrderGroupIDStatus,
              builder: (context, state) {
                return state.getOrdersByOrderGroupIDStatus ==
                        GetOrdersByOrderGroupIDStatus.loading
                    ? TrydosLoader(size: 16)
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
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
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
            const SizedBox(height: 4),
            ///////////////////
            Text(
              LocaleKeys.phone.tr(),
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
            const SizedBox(height: 4),
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
    final detailStatusLabel = _buildDetailStatusLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(AppAssets.cartCart, width: 15),

              title: LocaleKeys.order_status.tr(),
              value: orderStatus == 'delivered'
                  ? '$orderStatusLable ${LocaleKeys.to.tr()} $deliverdTo'
                  : detailStatusLabel,
              amount: '',
              isTextSpan: false,
              titleIcons: const SizedBox(
                width: 8,
              ), // buildTitleIcons(status: orderStatus),
              valueIcons: _buildOrderDetailProgressIcons(),

              //buildValueIcons(status: orderStatus),
              currency: '',
            ),
          ),
          //////////////////////////
          const SizedBox(width: 8),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(AppAssets.BlackAlarm, width: 20),
                  ///////////////////
                ],
              ),
              title: _localizedText(
                ar: 'المدة المتبقية للإجراء',
                en: 'Duration To Do Action',
              ),
              value: _localizedText(
                ar: 'المتبقي ${orders!.remainingInMinutes} د',
                en: 'Remaining ${orders!.remainingInMinutes}M',
              ),
              titleIcons: const SizedBox.shrink(),
              valueIcons: const SizedBox.shrink(),
              amount: '',
              isTextSpan: false,
              currency: '',
            ),
          ),
        ],
      ),
    );
  }

  String _buildDetailStatusLabel() {
    final details = orders?.details ?? const <OrderDetail>[];
    if (details.isEmpty) {
      return orders?.orderStatus ?? '';
    }

    final hasPendingConfirmation = details.any(
      (detail) => !detail.isConfirm && !detail.isPacked,
    );
    final allPacked = details.every((detail) => detail.isPacked);

    if (hasPendingConfirmation) {
      return _localizedText(
        ar: 'بانتظار التأكيد',
        en: 'Waiting for confirmation',
      );
    }

    if (allPacked) {
      return _localizedText(ar: 'تم التغليف', en: 'Packed');
    }

    return _localizedText(ar: 'قيد التغليف', en: 'Packing in progress');
  }

  Widget _buildOrderDetailProgressIcons() {
    final details = orders?.details ?? const <OrderDetail>[];
    final allConfirmed =
        details.isNotEmpty && details.every((detail) => detail.isConfirm);
    final allPacked =
        details.isNotEmpty && details.every((detail) => detail.isPacked);

    return Row(
      children: [
        const SizedBox(width: 8),
        SvgPicture.asset(AppAssets.trueBlack, width: 15),
        const SizedBox(width: 5),
        SvgPicture.asset(
          allConfirmed ? AppAssets.manpackBlack : AppAssets.manpackGray,
          width: 15,
        ),
        const SizedBox(width: 5),
        SvgPicture.asset(
          allPacked ? AppAssets.womanpackBlack : AppAssets.womanpackGrey,
          width: 15,
        ),
        const SizedBox(width: 5),
        SvgPicture.asset(
          allPacked ? AppAssets.certificataBlack : AppAssets.certificataGrey,
          width: 15,
        ),
        const SizedBox(width: 3),
      ],
    );
  }

  String _buildDetailCardStatusLabel(OrderDetail detail) {
    if (!detail.isConfirm && !detail.isPacked) {
      return _localizedText(
        ar: 'بانتظار التأكيد',
        en: 'Waiting for confirmation',
      );
    }

    if (detail.isConfirm && !detail.isPacked) {
      return _localizedText(ar: 'قيد التغليف', en: 'Packing in progress');
    }

    if (detail.isPacked) {
      return _localizedText(ar: 'تم التغليف', en: 'Packed');
    }

    return '';
  }

  String _buildPrimaryActionLabel(OrderDetail detail) {
    if (pendingOrderDetailId == detail.id) {
      if (detail.isPacked) {
        return _localizedText(ar: 'تم التغليف', en: 'Packed');
      }

      if (detail.isConfirm && !detail.isPacked) {
        return _localizedText(ar: 'تغليف', en: 'Mark as Packed');
      }

      return _localizedText(ar: 'جاري التحديث...', en: 'Updating...');
    }

    if (!detail.isConfirm && !detail.isPacked) {
      return _localizedText(ar: 'تأكيد', en: 'Confirm');
    }

    if (detail.isConfirm && !detail.isPacked) {
      return _localizedText(ar: 'تغليف', en: 'Mark as Packed');
    }

    return _localizedText(ar: 'تم التغليف', en: 'Packed');
  }

  bool _isPrimaryActionEnabled(OrderDetail detail) {
    return (!detail.isConfirm && !detail.isPacked) ||
        (detail.isConfirm && !detail.isPacked);
  }

  String? _buildNextDetailStatus(OrderDetail detail) {
    if (!detail.isConfirm && !detail.isPacked) {
      return 'confirmed';
    }

    if (detail.isConfirm && !detail.isPacked) {
      return 'packed';
    }

    return null;
  }

  UserOrderNew _applyOrderDetailStatusLocally(
    UserOrderNew currentOrder,
    int orderDetailId,
    String status,
  ) {
    final updatedDetails = currentOrder.details.map((detail) {
      if (detail.id != orderDetailId) {
        return detail;
      }

      return OrderDetail(
        id: detail.id,
        orderId: detail.orderId,
        cartImage: detail.cartImage,
        brandIcon: detail.brandIcon,
        qty: detail.qty,
        unitPrice: detail.unitPrice,
        isConfirm: status == 'confirmed' ? true : detail.isConfirm,
        isPacked: status == 'packed' ? true : detail.isPacked,
        productName: detail.productName,
        color: detail.color,
        size: detail.size,
      );
    }).toList();

    final updatedOrderStatus = _deriveOrderStatusFromDetails(
      currentOrder.orderStatus,
      updatedDetails,
    );

    return UserOrderNew(
      id: currentOrder.id,
      orderStatus: updatedOrderStatus,
      details: updatedDetails,
      orderAmount: currentOrder.orderAmount,
      createdAt: currentOrder.createdAt,
      items: currentOrder.items,
      remainingInMinutes: currentOrder.remainingInMinutes,
      availableOrderStatusChange: currentOrder.availableOrderStatusChange,
    );
  }

  String _deriveOrderStatusFromDetails(
    String currentStatus,
    List<OrderDetail> details,
  ) {
    if (details.isEmpty) {
      return currentStatus;
    }

    final hasPendingConfirmation = details.any(
      (detail) => !detail.isConfirm && !detail.isPacked,
    );

    if (hasPendingConfirmation) {
      return 'pending';
    }

    return 'packaged';
  }

  String _localizedText({required String ar, required String en}) {
    return LanguageService.languageCode == 'ar' ? ar : en;
  }

  Widget buildTitleIcons({required String status}) {
    if (OrderStatusClass.statusOrderIsPending(status))
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.pendingBlueCheckSvg, width: 15),
        ],
      );
    else if (OrderStatusClass.statusOrderIsPreparing(status))
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingBlueSvg, width: 15),
        ],
      );
    else
      return const SizedBox.shrink();
  }

  Widget buildValueIcons({required String status}) {
    if (OrderStatusClass.statusOrderIsPending(status))
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.pendeingBlackCheck, width: 15),
        ],
      );
    else if (OrderStatusClass.statusOrderIsPreparing(status))
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingBlackSvg, width: 15),
          /////////////////////////////
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingGreySvg, width: 15),
          /////////////////////////////
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.preparingGrey2Svg, width: 15),
        ],
      );
    else if (OrderStatusClass.statusOrderIsShipped(status))
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedBlackSvg, width: 15),
          /////////////////////////////
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedGreySvg, width: 15),
          /////////////////////////////
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.shippedGrey_2Svg, width: 15),
        ],
      );
    else
      return Row(
        children: [
          const SizedBox(width: 5),
          //////////////////////////
          SvgPicture.asset(AppAssets.deliveredBlackSvg, width: 15),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(AppAssets.shippedGreySvg, width: 20),
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
          const SizedBox(width: 8),
          //////////////////////////
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: SvgPicture.asset(AppAssets.orderClockSvg, width: 20),
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
          const SizedBox(width: 8),
          //////////////////////////
          ///هي للانفويس
          Expanded(
            child: buildDetailsMainInfoWidget(
              context: context,
              firstItem: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(AppAssets.orderInvoice2Svg, width: 20),
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
                    fontSize: 12,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.bq.copyWith(
                          fontWeight: FontWeight.normal,
                          color: const Color(0xff1D1D1D),
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

  Widget buildProductOrderCard({
    required int index,
    required BuildContext context,
    required String imageUrl,
    required String brand,
    required String title,
    required String color,
    required String size,
    required String id,
    required int quantity,
    required String status,
    required String price,
    required String primaryActionLabel,
    required bool isPrimaryActionEnabled,
    required VoidCallback onPrimaryAction,
    required VoidCallback onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsetsGeometry.only(bottom: 5, left: 2, right: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          /// ───────── Product Info ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              /// Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgNetworkWidget(svgUrl: brand, width: 220, height: 8),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_localizedText(ar: 'اللون', en: 'Color')}: $color',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                        Text(
                          '${_localizedText(ar: 'المقاس', en: 'Size')}: $size',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                        const Text(
                          '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'ID: $id',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF505050),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_localizedText(ar: 'الكمية', en: 'Quantity')}: $quantity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                        const Text(
                          '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF505050),
                          ),
                        ),
                        RichText(
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
                                text: price,
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      letterSpacing: 0.18,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                              ),
                              const TextSpan(text: ' '),
                              const TextSpan(text: 'USD'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      '${_localizedText(ar: 'الحالة', en: 'Status')}: $status',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF505050),
                      ),
                    ),
                  ],
                ),
              ),

              /// Price
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF8F8F8),
                ),
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Color(0xFF8D8D8D),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ───────── Buttons ─────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isPrimaryActionEnabled ? onPrimaryAction : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isPrimaryActionEnabled ? Colors.blue : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    primaryActionLabel,
                    style: TextStyle(
                      color: isPrimaryActionEnabled ? Colors.blue : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _localizedText(ar: 'إلغاء', en: 'Cancel'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
