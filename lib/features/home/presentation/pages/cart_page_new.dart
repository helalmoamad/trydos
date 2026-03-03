import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_delivary_adress.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/cart_sheet_header.dart';
import 'package:trydos/features/home/presentation/widgets/cart_section/product_collection_in_cart_page1.dart';
import 'package:trydos/features/story/presentation/widget/try_again.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../manager/orderBloc/order_bloc.dart';
import '../manager/orderBloc/order_event.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class CartPage extends StatefulWidget {
  final bool? fromeFilters;

  const CartPage({super.key, this.fromeFilters});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late HomeBloc homeBloc;
  late OrderBloc orderBloc;

  late AppBloc appBloc;
  late BoutiqueBloc boutiqueBloc;
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  late AuthBloc authBloc;
  bool showDialogToResetSession = true;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  final ValueNotifier<bool> moreInfo = ValueNotifier(false);
  final PanelController panelController = PanelController();
  int maxShippingDay = 0;
  bool? fromForGroundNotification;

  @override
  void initState() {
    LastPagesTracker.push("Cart Page");
    isExpanded.value = false;
    print('Firebase app:Firebase.app//////s${Firebase.apps.length}');

    appBloc = BlocProvider.of<AppBloc>(context);
    authBloc = BlocProvider.of<AuthBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    orderBloc = BlocProvider.of<OrderBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    orderBloc.add(GetCustomerAddressesEvent(setDefault: true));
    homeBloc.add(const GetCartItemEvent());

    authBloc.add(GetCustomerInfoEvent());

    fromForGroundNotification =
        appBloc.state.isFromForGroundNotification ?? false;
    homeBloc.add(
      GetCurrenciesForWalletEvent(
        currencySymbol:
            homeBloc.state.getCurrencyForCountryModel?.data?.currency?.code ??
            "",
      ),
    );
    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.CART_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.CART_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      // Log view cart event
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.VIEW_CART,
        executedEventName: AnalyticsButtonsEventNameConst.CART_ICON,
        extraParams: {'screen_name': GlobalScreenConst.CART_SCREEN},
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    List<Map<String, String>> cartImages = [];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            (previous.checkWithGetCartStatus !=
                current.checkWithGetCartStatus &&
            current.checkWithGetCartStatus ==
                CheckWithGetCartStatus.successForCart),
        listener: (context, state) {
          if (state.checkWithGetCartStatus ==
              CheckWithGetCartStatus.successForCart) {
            if (!state.cartCollection.isNullOrEmpty) {
              if (!state.cartCollection!.any(
                (element) =>
                    (element.isActive == false ||
                    element.isCountryRestricted == true ||
                    element.checkAvailability == false),
              )) {
                String cartGroupId = state.cartCollection?[0].cartGroupId ?? '';
                List<String> cartGroupIds =
                    state.cartCollection
                        ?.map((e) => e.cartGroupId ?? '')
                        .toList() ??
                    [];
                cartGroupIds = cartGroupIds.toSet().toList();

                String priceSymbol =
                    state.getCurrencyForCountryModel!.data!.currency!.symbol ??
                    "";
                List<Map<String, String>> analyticsCartList = [];
                if (state.cartCollection.isNullOrEmpty) {
                  state.cartCollection!.forEach((element) {
                    Map<String, String> item = {
                      'item_id': element.productId.toString(),
                      'item_name': element.name.toString(),
                      'price': element.price.toString(),
                      'quantity': element.quantity.toString(),
                      'brand': element.brand!.name.toString(),
                      'category': '',
                      'item_variant': element.variant.toString(),
                    };

                    analyticsCartList.add(item);
                  });
                }
                /////////////////////////////////
                Future.delayed(const Duration(milliseconds: 300), () {
                  FirebaseAnalyticsService.logEventForSession(
                    executedEventName: GlobalScreenConst.CART_SCREEN,
                    eventName: AnalyticsEventsConst.BEGIN_CHECKOUT,
                    extraParams: {
                      'currency': priceSymbol.toString(),
                      'value': state.getCartShippingItemsModel!.data!.total
                          .toString(),
                      'items': analyticsCartList.toString(),
                    },
                  );
                }); ////////////////////////////////

                Future.delayed(
                  const Duration(milliseconds: 600),
                  () => HelperFunctions.slidingNavigation(
                    context,
                    CartDelivaryAddress(
                      maxShippingDay: maxShippingDay.toString(),
                      listCartGroupIds: cartGroupIds,
                      cartItems: cartImages,
                      cartGroupId: cartGroupId,
                      currencySympole: priceSymbol,
                    ),
                  ),
                );
              } else {
                //////////////////////////
                showWarningMessage(
                  context,
                  "${LocaleKeys.you_have_to_delete_all_unavailable_products.tr()}",
                );
              }
            }
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            return previous.getCartItemsStatus != current.getCartItemsStatus ||
                previous.getCurrencyForCountryModel !=
                    current.getCurrencyForCountryModel ||
                previous.deleteItemInCartStatus !=
                    current.deleteItemInCartStatus ||
                previous.getOldCartItemsStatus !=
                    current.getOldCartItemsStatus ||
                previous.convertItemFromcartToOldCartStatus !=
                    current.convertItemFromcartToOldCartStatus ||
                //  previous.getListOfProductsFoundedInCartStatus !=
                //    current.getListOfProductsFoundedInCartStatus ||
                previous.hideItemInOldCartStatus !=
                    current.hideItemInOldCartStatus ||
                previous.addItemInCartStatus != current.addItemInCartStatus ||
                previous.updateItemInCartStatus !=
                    current.updateItemInCartStatus ||
                previous.cartCollection!.length !=
                    current.cartCollection?.length ||
                previous.oldcartCollection?.length !=
                    current.oldcartCollection?.length ||
                previous.getCartOverviewStatus !=
                    current.getCartOverviewStatus ||
                previous.checkWithGetCartStatus !=
                    current.checkWithGetCartStatus;
          },
          builder: (context, state) {
            cartImages = [];

            state.cartCollection?.forEach((element) {
              cartImages.add({
                "image": element.image ?? "",
                "size": element.variations == null
                    ? ""
                    : element.variations?.size ?? "",
                "color": element.variations == null
                    ? ""
                    : element.variations?.color ?? "",
              });
            });
            /*if ((prefsRepository.isTokenExpired ??
                        false ||
                            prefsRepository.marketToken == "" ||
                            prefsRepository.marketToken == null) &&
                    showDialogToResetSession &&
                    GetIt.I<AuthBloc>().state.registerGuestStatus !=
                        RegisterGuestStatus.loading) {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 400,
                      height: 300,
                      child: AlertDialog(
                        title: MyTextWidget(
                          "${LocaleKeys.it_has_been_along_time_since_your_account.tr()}",
                        ),
                        actions: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            width: 300,
                            child: Row(
                              mainAxisAlignment: (prefsRepository
                                          .isVerifiedPhonePeforeExpiredToken ??
                                      false)
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceAround,
                              children: [
                                (prefsRepository
                                            .isVerifiedPhonePeforeExpiredToken ??
                                        false)
                                    ? SizedBox.shrink()
                                    : Container(
                                        alignment: Alignment.center,
                                        width: 130,
                                        child: AppElevatedButton(
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () async {
                                            showDialogToResetSession = false;
            
                                            String? deviceId =
                                                await HelperFunctions
                                                    .getDeviceId();
            
                                            GetIt.I<AuthBloc>().add(
                                                RegisterGuestEvent(
                                                    oldGuestUserId:
                                                        prefsRepository.myMarketId
                                                            .toString(),
                                                    deviceId: deviceId!));
                                            setState(() {});
                                          },
                                          text:
                                              "${LocaleKeys.reset_your_count.tr()}",
                                        ),
                                      ),
                                Container(
                                  alignment: Alignment.center,
                                  width: 130,
                                  child: AppElevatedButton(
                                    textStyle: TextStyle(fontSize: 16),
                                    onPressed: () {
                                      showDialogToResetSession = false;
            
                                      Future.delayed(
                                        Duration(microseconds: 300),
                                        () {
                                          Navigator.of(context)
                                              .push(PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                RegistrationPage(
                                              fromExpiredToken: true,
                                            ),
                                          ));
                                        },
                                      );
                                    },
                                    text: '${LocaleKeys.go_to_log_in.tr()}',
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }*/
            if (state.cartCollection == null || state.cartCollection!.isEmpty) {
              isExpanded.value = false;
              isVerified.value = true;
            }
            if (state.getCartItemsStatus == GetCartItemsStatus.failure &&
                (state.getCartShippingItemsModel == null)) {
              return Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: TryAgainWidget(
                    tryAgain: () {
                      BlocProvider.of<HomeBloc>(
                        context,
                      ).add(const GetCartItemEvent());
                    },
                  ),
                ),
              );
            }

            if (state.getCartShippingItemsModel == null &&
                    state.getCartItemsStatus != GetCartItemsStatus.success ||
                (state.getOldCartModel == null &&
                    state.getOldCartItemsStatus !=
                        GetOLdCartItemsStatus.success)) {
              return Center(child: TrydosLoader());
            }

            double totlalPrice = 0;
            double totlalPriceWithDiscount = 0;
            String? priceSymbol;
            double totlalQuantity = 0;
            double totlalPriceWithoutShipping = 0;
            double totlalDiscount = 0;
            maxShippingDay = 0;

            totlalPrice =
                HelperFunctions.truncateToDecimalPlaces(
                  (state.getCartShippingItemsModel?.data?.total ?? 0),
                  state
                      .getCurrencyForCountryModel!
                      .data!
                      .currency!
                      .decimalDigits!,
                ) *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;

            totlalPriceWithoutShipping =
                HelperFunctions.truncateToDecimalPlaces(
                  (state.getCartShippingItemsModel?.data?.subTotal ?? 0),
                  state
                      .getCurrencyForCountryModel!
                      .data!
                      .currency!
                      .decimalDigits!,
                ) *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
            print(
              "totlalPriceWithoutShipping ${state.getCartShippingItemsModel?.data?.productsDiscount}",
            );
            totlalPriceWithDiscount =
                (((state.getCartShippingItemsModel?.data?.productsDiscount ?? 0)
                    .abs()) +
                (state.getCartShippingItemsModel?.data?.total ?? 0));
            totlalPriceWithDiscount =
                ((HelperFunctions.truncateToDecimalPlaces(
                  totlalPriceWithDiscount,
                  state
                      .getCurrencyForCountryModel!
                      .data!
                      .currency!
                      .decimalDigits!,
                )) *
                state
                    .getCurrencyForCountryModel!
                    .data!
                    .currency!
                    .exchangeRate!);
            totlalDiscount =
                HelperFunctions.truncateToDecimalPlaces(
                  (state.getCartShippingItemsModel?.data?.productsDiscount ?? 0)
                      .abs(),
                  state
                      .getCurrencyForCountryModel!
                      .data!
                      .currency!
                      .decimalDigits!,
                ) *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;

            priceSymbol =
                state.getCurrencyForCountryModel!.data!.currency!.symbol ?? "";

            state.cartCollection?.forEach((element) {
              if ((element.shippingDays ?? 0) > maxShippingDay) {
                maxShippingDay = element.shippingDays ?? 0;
              }
              totlalQuantity = (state.cartCollection?.length ?? 0).toDouble();
              // totlalQuantity + (element.quantity ?? 0);

              //   totlalOfferPrice =
              //       totlalOfferPrice + element.offerPrice! * element.quantity!;
              //   totlalOfferPrice = totlalPrice + element.price! * element.quantity!;
              //   totlalDiscount = totlalDiscount +
              //       (element.price! - element.offerPrice!) * element.quantity!;
            });
            maxShippingDay =
                maxShippingDay + (state.startingSetting?.shippingDay ?? 0);
            //  totlalOfferPrice = totlalOfferPrice *
            //     state.getCurrencyForCountryModel!.data!.currency!
            //         .exchangeRate!;
            // totlalPrice = totlalPrice *
            //     state.getCurrencyForCountryModel!.data!.currency!
            //         .exchangeRate!;
            //totlalDiscount = totlalDiscount *
            //   state.getCurrencyForCountryModel!.data!.currency!
            //     .exchangeRate!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 60.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.h),
                    width: 1.sw,
                    height: 50.h,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          height: 50.h,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  // didCallOnWillPop = true;
                                  if (Navigator.canPop(context)) {
                                    if (focusNode.hasFocus) {
                                      focusNode.previousFocus();
                                    }
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                      return;
                                      // منع الإغلاق بعد تنفيذ pop
                                    }

                                    // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                    appBloc.add(ChangeBasePage(0));
                                    boutiqueBloc.add(
                                      ResetAllSelectedAppliedFilterEvent(),
                                    );
                                    return;
                                  } else {
                                    appBloc.add(ChangeBasePage(0));
                                    return;
                                  }
                                },
                                child: !(LanguageService.languageCode != "ar")
                                    ? Transform.rotate(
                                        angle: pi,
                                        child: Container(
                                          width: 40.w,
                                          child: SvgPicture.asset(
                                            AppAssets.backIconArrowSvg,
                                            height: 20.h,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 40.w,
                                        child: SvgPicture.asset(
                                          AppAssets.backIconArrowSvg,
                                          height: 20.h,
                                        ),
                                      ),
                              ),
                              const Spacer(),
                              SvgPicture.asset(AppAssets.bagsSvg, height: 20),
                              SizedBox(width: 7.w),
                              Text(
                                "${LocaleKeys.shopping_bag.tr()} ",
                                style: context.textTheme.bodyMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 1.33,
                                    ),
                              ),
                              Text(
                                "${state.cartCollection?.length} ",
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 13.sp,
                                      height: 1.33,
                                    ),
                              ),
                              Text(
                                "${LocaleKeys.item.tr()}",
                                strutStyle: LanguageService.languageCode != "ar"
                                    ? null
                                    : StrutStyle(height: 1.2.sp, leading: 0.3),
                                style: context.textTheme.bodyMedium?.bq
                                    .copyWith(
                                      color: const Color(0xff505050),
                                      letterSpacing: 0.18,
                                      fontSize: 14.sp,
                                      height: 1.33,
                                    ),
                              ),
                              SizedBox(
                                width: LanguageService.languageCode != "ar"
                                    ? 0
                                    : 20.w,
                              ),
                              const Spacer(),
                              SvgPicture.asset(
                                AppAssets.shareSvg,
                                height: 20,
                                width: 20,
                                // ignore: deprecated_member_use
                                color: const Color(0xff3C3C3C),
                              ),
                            ],
                          ),
                        ),
                        /*container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xffF8F8F8)),
                                margin: EdgeInsets.only(top: 5.h),
                                height: 30.h,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          /* HelperFunctions.slidingNavigation(
                                                    context,
                                                    CartPage2(
                                                      getCartShippingItemsModel: state
                                                          .getCartShippingItemsModel!,
                                                    ));*/
                                        },
                                        child: SvgPicture.asset(
                                            AppAssets.countItemSvg)),
                                    Text(" ${state.cartCollection!.length} ",
                                        style: context.textTheme.bodyMedium?.mr
                                            .copyWith(
                                                fontSize: 13,
                                                color: const Color(0xff5D5C5D),
                                                letterSpacing: 0.18,
                                                height: 1.33)),
                                    Text(
                                      "item ",
                                      style: context.textTheme.bodyMedium?.la
                                          .copyWith(
                                              fontSize: 13,
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              height: 1.33),
                                    ),
                                    Text(
                                      "${totlaPrice.toStringAsFixed(state.startingSetting?.decimalPointSetting ?? 2)}",
                                      style: context.textTheme.bodyMedium?.mr
                                          .copyWith(
                                              fontSize: 13,
                                              color: const Color(0xff5D5C5D),
                                              letterSpacing: 0.18,
                                              height: 1.33),
                                    ),
                                    Text(
                                      " ${priceSymbol ?? '\$'} ",
                                      style: context.textTheme.bodyMedium?.la
                                          .copyWith(
                                              fontSize: 13,
                                              color: const Color(0xff8D8D8D),
                                              letterSpacing: 0.18,
                                              height: 1.33),
                                    ),
                                  ],
                                ),
                              ),*/
                      ],
                    ),
                  ),
                  Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Container(
                      color:
                          ((state.cartCollection == null ||
                                  state.cartCollection!.isEmpty) &&
                              (state.oldcartCollection == null ||
                                  state.oldcartCollection!.isEmpty))
                          ? const Color(0xffF8F8F8)
                          : const Color(0xffFEFEFE),
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: [
                          ((state.cartCollection == null ||
                                      state.cartCollection!.isEmpty) &&
                                  (state.oldcartCollection == null ||
                                      state.oldcartCollection!.isEmpty))
                              ? Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            (1.sh / 2) -
                                            ((widget.fromeFilters ?? false)
                                                ? 140.h
                                                : 200.h),
                                      ),
                                      Container(
                                        height: 20,
                                        child: SvgPicture.asset(
                                          AppAssets.cartSvg,
                                          // ignore: deprecated_member_use
                                          color: const Color(0xff8E8E8E),

                                          height: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${LocaleKeys.your_cart_empty.tr()}",
                                        style: context.textTheme.bodyMedium?.mq
                                            .copyWith(
                                              fontSize: 13.sp,
                                              color: const Color(0xff8E8E8E),
                                              letterSpacing: 0.18,
                                              height: 1.33,
                                            ),
                                      ),
                                      const SizedBox(height: 15),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          "${LocaleKeys.see_our_many_offers.tr()}",
                                          style: context
                                              .textTheme
                                              .bodyMedium
                                              ?.rq
                                              .copyWith(
                                                fontSize: 11.sp,
                                                color: const Color(0xff505050),
                                                letterSpacing: 0.18,
                                                height: 1.33,
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: 370.h),
                                    ],
                                  ),
                                )
                              : Container(
                                  height: widget.fromeFilters ?? false
                                      ? (1.sh - 140.h)
                                      : 1.sh - 210.h,
                                  child: ListView(
                                    padding: const EdgeInsets.only(),
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      (state.cartCollection == null ||
                                              state.cartCollection!.isEmpty)
                                          ? const SizedBox.shrink()
                                          : ProductCollectionInCartPage1(
                                              isOldCart: false,
                                              oldCartCollection:
                                                  state.oldcartCollection ?? [],
                                              cartCollection:
                                                  state.cartCollection ?? [],
                                              priceSymbol: priceSymbol,
                                            ),
                                      const SizedBox(height: 20),
                                      state.oldcartCollection != null
                                          ? !state.oldcartCollection!.isEmpty
                                                ? Center(
                                                    child: MyTextWidget(
                                                      "${LocaleKeys.old_cart.tr()}",
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink()
                                          : const SizedBox.shrink(),
                                      const SizedBox(height: 10),
                                      state.oldcartCollection != null
                                          ? !state.oldcartCollection!.isEmpty
                                                ? Container(
                                                    height: 70,
                                                    padding: EdgeInsets.all(
                                                      20.w,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            GetIt.I<HomeBloc>().add(
                                                              HideItemInOldCartEvent(
                                                                hideAll: true,
                                                              ),
                                                            );
                                                          },
                                                          child: MyTextWidget(
                                                            "${LocaleKeys.hide_all.tr()}",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink()
                                          : const SizedBox.shrink(),
                                      (state.oldcartCollection == null ||
                                              state.oldcartCollection!.isEmpty)
                                          ? const SizedBox.shrink()
                                          : ProductCollectionInCartPage1(
                                              isOldCart: true,
                                              oldCartCollection:
                                                  state.oldcartCollection ?? [],
                                              cartCollection:
                                                  state.cartCollection ?? [],
                                              priceSymbol: priceSymbol,
                                            ),
                                    ],
                                  ),
                                ),
                          ValueListenableBuilder<bool>(
                            valueListenable: moreInfo,
                            builder: (context, isMoreInfo, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: isExpanded,
                                builder: (context, expanded, _) {
                                  return !(expanded || isMoreInfo)
                                      ? const SizedBox.shrink()
                                      : InkWell(
                                          onTap: () {
                                            isExpanded.value = false;
                                            moreInfo.value = false;
                                            Future.delayed(
                                              const Duration(microseconds: 300),
                                              () {
                                                panelController.close();
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 600.h,
                                            color: const Color.fromRGBO(
                                              29,
                                              29,
                                              29,
                                              0.6,
                                            ),
                                          ),
                                        );
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: moreInfo,
                            builder: (context, isMoreInfo, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: isVerified,
                                builder: (context, isverified, _) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: isExpanded,
                                    builder: (context, expanded, _) {
                                      return Positioned(
                                        bottom: -15,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                ((state.cartCollection ==
                                                        null ||
                                                    state
                                                        .cartCollection!
                                                        .isEmpty))
                                                ? null
                                                : const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      30,
                                                    ),
                                                    topRight: Radius.circular(
                                                      30,
                                                    ),
                                                  ),
                                          ),
                                          height: isMoreInfo
                                              ? 1.sh - 220.h
                                              : null,
                                          width: 1.sw,
                                          child: SlidingUpPanel(
                                            controller: panelController,
                                            borderRadius:
                                                ((state.cartCollection ==
                                                        null ||
                                                    state
                                                        .cartCollection!
                                                        .isEmpty))
                                                ? null
                                                : const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      30,
                                                    ),
                                                    topRight: Radius.circular(
                                                      30,
                                                    ),
                                                  ),
                                            onPanelClosed: () {
                                              isExpanded.value = false;
                                              moreInfo.value = false;
                                            },
                                            onPanelOpened: () =>
                                                isExpanded.value =
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty)) ||
                                                        isMoreInfo
                                                    ? false
                                                    : true,
                                            minHeight:
                                                ((state.cartCollection ==
                                                        null ||
                                                    state
                                                        .cartCollection!
                                                        .isEmpty))
                                                ? 100
                                                : !isverified
                                                ? 600
                                                : 258,
                                            maxHeight: isMoreInfo
                                                ? 1.sh - 250.h
                                                : ((state.cartCollection ==
                                                          null ||
                                                      state
                                                          .cartCollection!
                                                          .isEmpty))
                                                ? 120
                                                : !isverified
                                                ? 720
                                                : 447,
                                            panelBuilder: (sc) => Container(
                                              alignment: Alignment.topLeft,
                                              decoration: BoxDecoration(
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0xffF8F8F8),
                                                    spreadRadius: 0.1,
                                                    blurRadius: 0.1,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: const Color(
                                                    0xffF8F8F8,
                                                  ),
                                                ),
                                                color: const Color(0xffFFFFFF),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        30,
                                                      ),
                                                      topRight: Radius.circular(
                                                        30,
                                                      ),
                                                    ),
                                              ),
                                              height:
                                                  ((state.cartCollection ==
                                                          null ||
                                                      state
                                                          .cartCollection!
                                                          .isEmpty))
                                                  ? 100.h
                                                  : expanded
                                                  ? !isverified
                                                        ? 780.h
                                                        : 485.h
                                                  : !isverified
                                                  ? 610.h
                                                  : 260.h,
                                              width: 1.sw,
                                              child: Container(
                                                decoration:
                                                    ((state.cartCollection ==
                                                            null ||
                                                        state
                                                            .cartCollection!
                                                            .isEmpty))
                                                    ? null
                                                    : BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xffFFFFFF,
                                                          ),
                                                        ),
                                                        color: const Color(
                                                          0xffFFFFFF,
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    30,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    30,
                                                                  ),
                                                            ),
                                                      ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? const SizedBox.shrink()
                                                        : const SizedBox(
                                                            height: 10,
                                                          ),
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? const SizedBox.shrink()
                                                        : InkWell(
                                                            onTap: () {
                                                              if (isverified) {
                                                                moreInfo.value =
                                                                    true;
                                                                Future.delayed(
                                                                  const Duration(
                                                                    microseconds:
                                                                        500,
                                                                  ),
                                                                  () {
                                                                    panelController
                                                                        .open();
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            child: Center(
                                                              child: SvgPicture.asset(
                                                                AppAssets
                                                                    .chatWithQuestionSvg,
                                                                height: 14,
                                                              ),
                                                            ),
                                                          ),
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? const SizedBox.shrink()
                                                        : const SizedBox(
                                                            height: 5,
                                                          ),
                                                    ((state.cartCollection ==
                                                                null ||
                                                            state
                                                                .cartCollection!
                                                                .isEmpty))
                                                        ? const SizedBox.shrink()
                                                        : Container(
                                                            height: 27,
                                                            child: CartDetailsSheetHeader(
                                                              shippingCost:
                                                                  (state
                                                                      .getCartShippingItemsModel
                                                                      ?.data
                                                                      ?.totalShippingCost ??
                                                                  0),
                                                            ),
                                                          ),
                                                    !isMoreInfo
                                                        ? const SizedBox.shrink()
                                                        : SizedBox(
                                                            height: 1.sh / 2.1,
                                                          ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xffF8F8F8,
                                                          ),
                                                        ),
                                                        color: const Color(
                                                          0xffF8F8F8,
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius.all(
                                                              Radius.circular(
                                                                30,
                                                              ),
                                                            ),
                                                      ),
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : Container(
                                                                  margin:
                                                                      const EdgeInsets.all(
                                                                        18,
                                                                      ),
                                                                  width: 65,
                                                                  height: 18,
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SvgPicture.asset(
                                                                        AppAssets
                                                                            .countItemSvg,
                                                                        // ignore: deprecated_member_use
                                                                        color: const Color(
                                                                          0xff1D1D1D,
                                                                        ),
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      Text(
                                                                        " ${LocaleKeys.item.tr()} ",
                                                                        style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                          fontSize:
                                                                              13.sp,
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "${totlalQuantity.round()}",
                                                                        style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                          fontSize:
                                                                              13.sp,
                                                                          color: const Color(
                                                                            0xff1D1D1D,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.18,
                                                                          height:
                                                                              1.33,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : Container(
                                                                  width: 400.w,
                                                                  height: 50.h,
                                                                  padding: EdgeInsets.only(
                                                                    right:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 10.w
                                                                        : 0,
                                                                    left:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 0
                                                                        : 10.w,
                                                                  ),
                                                                  margin: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                17.h,
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 25,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 25
                                                                                  : 10.w,
                                                                            ),
                                                                            child: Text(
                                                                              "${LocaleKeys.details.tr()} ",
                                                                              strutStyle:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? null
                                                                                  : const StrutStyle(
                                                                                      height: 0.1,
                                                                                      leading: 0.1,
                                                                                    ),
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                fontSize: 13.sp,
                                                                                color: const Color(
                                                                                  0xff1D1D1D,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height:
                                                                                    LanguageService.languageCode !=
                                                                                        "ar"
                                                                                    ? 1.33
                                                                                    : 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Text(
                                                                            " ${HelperFunctions.formatNumber(numberToFormate: totlalPriceWithoutShipping, isNeedRounding: false)}  ",
                                                                            style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff1D1D1D,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            "${priceSymbol ?? "\$"}",
                                                                            style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff1D1D1D,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            18.h,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 10.w
                                                                              : 25,
                                                                          left:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 25
                                                                              : 10.w,
                                                                        ),
                                                                        child: Text(
                                                                          "${LocaleKeys.normal_price.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                            fontSize:
                                                                                11.sp,
                                                                            color: const Color(
                                                                              0xff1D1D1D,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            height:
                                                                                1.33,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : SizedBox(
                                                                  height: 5.h,
                                                                ),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : Container(
                                                                  padding: EdgeInsets.only(
                                                                    right:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 10.w
                                                                        : 0,
                                                                    left:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 0
                                                                        : 10.w,
                                                                  ),
                                                                  width: 400.w,
                                                                  height: 50.h,
                                                                  margin: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 4,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 8.w,
                                                                            ),
                                                                            child: SvgPicture.asset(
                                                                              AppAssets.totalDiscountCartSvg,
                                                                              // ignore: deprecated_member_use
                                                                              color: const Color(
                                                                                0xffFE0364,
                                                                              ),
                                                                              height: 12,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                17.h,
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 2,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 10.w,
                                                                            ),
                                                                            child: Text(
                                                                              "${LocaleKeys.total_discount.tr()} ${(totlalPrice == 0 ? 0 : ((totlalDiscount) / totlalPriceWithoutShipping) * 100).toStringAsFixed(0)}% ",
                                                                              strutStyle:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? null
                                                                                  : const StrutStyle(
                                                                                      height: 0.1,
                                                                                      leading: 0.1,
                                                                                    ),
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                fontSize: 13.sp,
                                                                                color: const Color(
                                                                                  0xffA28E5B,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height:
                                                                                    LanguageService.languageCode !=
                                                                                        "ar"
                                                                                    ? 1.33
                                                                                    : 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Text(
                                                                            "- ${HelperFunctions.formatNumber(numberToFormate: (totlalDiscount), isNeedRounding: false)}  ",
                                                                            style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xffA28E5B,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            "${priceSymbol ?? "\$"}",
                                                                            style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xffA28E5B,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            17.h,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 10.w
                                                                              : 25,
                                                                          left:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 25
                                                                              : 10.w,
                                                                        ),
                                                                        child: Text(
                                                                          "${LocaleKeys.all_inclusve_without_addition.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                            fontSize:
                                                                                11.sp,
                                                                            color: const Color(
                                                                              0xffA28E5B,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            height:
                                                                                1.33,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : SizedBox(
                                                                  height: 5.h,
                                                                ),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : Container(
                                                                  padding: EdgeInsets.only(
                                                                    right:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 10.w
                                                                        : 2,
                                                                    left:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 2
                                                                        : 10.w,
                                                                  ),
                                                                  width: 400.w,
                                                                  height: 50.h,
                                                                  margin: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 2,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 10.w,
                                                                            ),
                                                                            child: SvgPicture.asset(
                                                                              AppAssets.giftCartSvg,
                                                                              // ignore: deprecated_member_use
                                                                              color: const Color(
                                                                                0xff5BA260,
                                                                              ),
                                                                              height: 12,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                17.h,
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 2,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 10.w,
                                                                            ),
                                                                            child: Text(
                                                                              "${LocaleKeys.gift.tr()}",
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                fontSize: 13.sp,
                                                                                color: const Color(
                                                                                  0xff5BA260,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height: 1.33,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          Text(
                                                                            "- ${0}  ",
                                                                            style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff5BA260,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            "${priceSymbol ?? "\$"}",
                                                                            style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff5BA260,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            17.h,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 10.w
                                                                              : 25,
                                                                          left:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 25
                                                                              : 10.w,
                                                                        ),
                                                                        child: Text(
                                                                          "${LocaleKeys.first_shopping.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                            fontSize:
                                                                                11.sp,
                                                                            color: const Color(
                                                                              0xff5BA260,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            height:
                                                                                1.33,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          SizedBox(height: 5.h),
                                                          !expanded
                                                              ? const SizedBox.shrink()
                                                              : Container(
                                                                  padding: EdgeInsets.only(
                                                                    right:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 10.w
                                                                        : 2,
                                                                    left:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 2
                                                                        : 10.w,
                                                                  ),
                                                                  width: 400.w,
                                                                  height: 50.h,
                                                                  margin: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10.w,
                                                                  ),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10
                                                                                  : 2,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 10,
                                                                            ),
                                                                            child: SvgPicture.asset(
                                                                              AppAssets.shappingCartSvg,
                                                                              // ignore: deprecated_member_use
                                                                              color: const Color(
                                                                                0xffBEF4CD,
                                                                              ),
                                                                              height: 12,
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                17.h,
                                                                            margin: EdgeInsets.only(
                                                                              right:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 10.w
                                                                                  : 2,
                                                                              left:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? 2
                                                                                  : 10.w,
                                                                            ),
                                                                            child: Text(
                                                                              "${LocaleKeys.shipping.tr()} ",
                                                                              strutStyle:
                                                                                  LanguageService.languageCode !=
                                                                                      "ar"
                                                                                  ? null
                                                                                  : const StrutStyle(
                                                                                      height: 0.1,
                                                                                      leading: 0.1,
                                                                                    ),
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                fontSize: 13.sp,
                                                                                color: const Color(
                                                                                  0xff2FA52F,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height:
                                                                                    LanguageService.languageCode !=
                                                                                        "ar"
                                                                                    ? 1.33
                                                                                    : 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          /*    Text(
                                                                                      "0",
                                                                                      style: context.textTheme.bodyMedium?.br.copyWith(decoration: TextDecoration.lineThrough, decorationColor: const Color(0xff2FA52F), color: const Color(0xff2FA52F), fontSize: 13, letterSpacing: 0.18, height: 1.33),
                                                                                    ),*/
                                                                          Text(
                                                                            " ${HelperFunctions.formatNumber(numberToFormate: (HelperFunctions.truncateToDecimalPlaces((state.getCartShippingItemsModel?.data?.totalShippingCost ?? 0), state.getCurrencyForCountryModel!.data!.currency!.decimalDigits!) * state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!), isNeedRounding: false)}  ",
                                                                            style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff2FA52F,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            "${priceSymbol ?? "\$"}",
                                                                            style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                              fontSize: 13.sp,
                                                                              color: const Color(
                                                                                0xff2FA52F,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            18.h,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 10.w
                                                                              : 25,
                                                                          left:
                                                                              LanguageService.languageCode !=
                                                                                  "ar"
                                                                              ? 25
                                                                              : 10.w,
                                                                        ),
                                                                        child: Text(
                                                                          (state.getCartShippingItemsModel?.data?.totalShippingCost ??
                                                                                      0) !=
                                                                                  0
                                                                              ? ""
                                                                              : "${LocaleKeys.shipping_is_completely_free_without_any_extras.tr()} ",
                                                                          style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                            fontSize:
                                                                                11.sp,
                                                                            color: const Color(
                                                                              0xff2FA52F,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.18,
                                                                            height:
                                                                                1.33,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          SizedBox(
                                                            height: expanded
                                                                ? 0
                                                                : 10.h,
                                                          ),
                                                          ((state.cartCollection ==
                                                                      null ||
                                                                  state
                                                                      .cartCollection!
                                                                      .isEmpty))
                                                              ? const SizedBox.shrink()
                                                              : InkWell(
                                                                  onTap: () => Future.delayed(
                                                                    const Duration(
                                                                      microseconds:
                                                                          500,
                                                                    ),
                                                                    () {
                                                                      if (isExpanded
                                                                              .value ||
                                                                          moreInfo
                                                                              .value) {
                                                                        isExpanded.value =
                                                                            false;
                                                                        moreInfo.value =
                                                                            false;
                                                                        panelController
                                                                            .close();
                                                                      } else {
                                                                        panelController
                                                                            .open();
                                                                      }
                                                                    },
                                                                  ),
                                                                  child: Container(
                                                                    width:
                                                                        400.w,
                                                                    height:
                                                                        50.h,
                                                                    decoration: const BoxDecoration(
                                                                      color: Color(
                                                                        0xffF8F8F8,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                            Radius.circular(
                                                                              12,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                    padding: EdgeInsets.only(
                                                                      right:
                                                                          LanguageService.languageCode !=
                                                                              "ar"
                                                                          ? 10.w
                                                                          : 2,
                                                                      left:
                                                                          LanguageService.languageCode !=
                                                                              "ar"
                                                                          ? 2
                                                                          : 10.w,
                                                                    ),
                                                                    margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.w,
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              height: 17.h,
                                                                              margin: EdgeInsets.only(
                                                                                right:
                                                                                    LanguageService.languageCode !=
                                                                                        "ar"
                                                                                    ? 10.w
                                                                                    : 25,
                                                                                left:
                                                                                    LanguageService.languageCode !=
                                                                                        "ar"
                                                                                    ? 25
                                                                                    : 10.w,
                                                                              ),
                                                                              child: Text(
                                                                                "${LocaleKeys.total.tr()}",
                                                                                style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                  fontSize: 13.sp,
                                                                                  color: const Color(
                                                                                    0xff1D1D1D,
                                                                                  ),
                                                                                  letterSpacing: 0.18,
                                                                                  height: 1.33,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const Spacer(),
                                                                            (totlalDiscount ==
                                                                                    0)
                                                                                ? const SizedBox.shrink()
                                                                                : Text(
                                                                                    "${HelperFunctions.formatNumber(numberToFormate: totlalPriceWithDiscount, isNeedRounding: false)}  ",
                                                                                    style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                      fontSize: 16,
                                                                                      color: const Color(
                                                                                        0xff1D1D1D,
                                                                                      ),
                                                                                      letterSpacing: 0.18,
                                                                                      height: 1.33,
                                                                                    ),
                                                                                  ),
                                                                            Text(
                                                                              "${HelperFunctions.formatNumber(numberToFormate: totlalPrice, isNeedRounding: false)}  ",
                                                                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                fontSize: 16.sp,
                                                                                color: const Color(
                                                                                  0xff1D1D1D,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height: 1.33,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            Text(
                                                                              "${priceSymbol ?? "\$"}",
                                                                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                                                                fontSize: 16.sp,
                                                                                color: const Color(
                                                                                  0xff1D1D1D,
                                                                                ),
                                                                                letterSpacing: 0.18,
                                                                                height: 1.33,
                                                                              ),
                                                                            ),

                                                                            /*  Container(
                                                                                          width: 20,
                                                                                          height: 20,
                                                                                          child: Container(
                                                                                              alignment: Alignment.centerRight,
                                                                                              height: 14,
                                                                                              child: SvgPicture.asset(
                                                                                                AppAssets.chatWithQuestionSvg,
                                                                                                color: Color(0xff8E8E8E),
                                                                                                height: 14,
                                                                                              ))),
                                                                                              */
                                                                            SizedBox(
                                                                              width: 5.w,
                                                                            ),
                                                                            ValueListenableBuilder<
                                                                              bool
                                                                            >(
                                                                              valueListenable: isExpanded,
                                                                              builder:
                                                                                  (
                                                                                    context,
                                                                                    _expanded,
                                                                                    _,
                                                                                  ) {
                                                                                    return ValueListenableBuilder<
                                                                                      bool
                                                                                    >(
                                                                                      valueListenable: moreInfo,
                                                                                      builder:
                                                                                          (
                                                                                            context,
                                                                                            _MoreInfo,
                                                                                            _,
                                                                                          ) {
                                                                                            return (_expanded ||
                                                                                                    _MoreInfo)
                                                                                                ? RotatedBox(
                                                                                                    quarterTurns: 2,
                                                                                                    child: Container(
                                                                                                      width: 20,
                                                                                                      height: 8,
                                                                                                      alignment: Alignment.bottomCenter,
                                                                                                      child: SvgPicture.asset(
                                                                                                        AppAssets.expandDetaileSvg,
                                                                                                        height: 8,
                                                                                                      ),
                                                                                                    ),
                                                                                                  )
                                                                                                : Container(
                                                                                                    width: 20,
                                                                                                    height: 12,
                                                                                                    alignment: Alignment.bottomCenter,
                                                                                                    child: SvgPicture.asset(
                                                                                                      AppAssets.expandDetaileSvg,
                                                                                                      height: 8,
                                                                                                    ),
                                                                                                  );
                                                                                          },
                                                                                    );
                                                                                  },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              17.h,
                                                                          margin: EdgeInsets.only(
                                                                            right:
                                                                                LanguageService.languageCode !=
                                                                                    "ar"
                                                                                ? 10.w
                                                                                : 25,
                                                                            left:
                                                                                LanguageService.languageCode !=
                                                                                    "ar"
                                                                                ? 25
                                                                                : 10.w,
                                                                          ),
                                                                          child: Text(
                                                                            "${LocaleKeys.click_to_show_all_discount.tr()} ",
                                                                            style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                              fontSize: 11.sp,
                                                                              color: const Color(
                                                                                0xff8D8D8D,
                                                                              ),
                                                                              letterSpacing: 0.18,
                                                                              height: 1.33,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    expanded
                                                        ? const Spacer()
                                                        : const SizedBox.shrink(),
                                                    SizedBox(
                                                      height: expanded
                                                          ? 0
                                                          : ((state.cartCollection ==
                                                                    null ||
                                                                state
                                                                    .cartCollection!
                                                                    .isEmpty))
                                                          ? 0
                                                          : isMoreInfo
                                                          ? 10
                                                          : 60,
                                                    ),
                                                    !isverified
                                                        ? AnimatedPadding(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      300,
                                                                ),
                                                            curve:
                                                                Curves.easeOut,
                                                            padding: EdgeInsets.only(
                                                              bottom:
                                                                  MediaQuery.of(
                                                                        context,
                                                                      )
                                                                      .viewInsets
                                                                      .bottom,
                                                            ),
                                                            child: Container(
                                                              height: 250,
                                                              child: Stack(
                                                                children: [
                                                                  PageView(
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    controller:
                                                                        pageController,
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
                                                                                BlocProvider.of<
                                                                                      HomeBloc
                                                                                    >(
                                                                                      context,
                                                                                    )
                                                                                    .add(
                                                                                      const CheckWithGetCartEvent(
                                                                                        isForPlaceOrder: false,
                                                                                      ),
                                                                                    );
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
                                                                              moveToNextStep:
                                                                                  (
                                                                                    String phoneNumber,
                                                                                  ) {
                                                                                    this.phoneNumber = phoneNumber.replaceAll(
                                                                                      ' ',
                                                                                      '',
                                                                                    );
                                                                                    pageController.animateToPage(
                                                                                      1,
                                                                                      duration: const Duration(
                                                                                        milliseconds: 500,
                                                                                      ),
                                                                                      curve: Curves.easeInOut,
                                                                                    );
                                                                                    setState(
                                                                                      () {},
                                                                                    );
                                                                                  },
                                                                            ),
                                                                            VerificationMethods(
                                                                              phoneNumber: phoneNumber,
                                                                              isFromLogin: true,
                                                                              onChooseWhatsapp: () {
                                                                                isVisWhatsApp = 1;
                                                                                pageController.animateToPage(
                                                                                  2,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );

                                                                                if (prefsRepository.isTimerForOtpRunning ??
                                                                                    false) {
                                                                                  showWarningMessage(
                                                                                    context,
                                                                                    '${LocaleKeys.you_must_wait_for_some_seconds_before_try_again.tr()}',
                                                                                  );
                                                                                  return;
                                                                                }
                                                                                /* authBloc.add(SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 1));*/
                                                                              },
                                                                              goBackToPhone: () {
                                                                                pageController.animateToPage(
                                                                                  0,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                              },
                                                                              onChooseSms: () {
                                                                                isVisWhatsApp = 0;
                                                                                pageController.animateToPage(
                                                                                  3,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                                /*authBloc.add(SendOtpEvent(phone: phoneNumber, isViaWhatsApp: 0));*/
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
                                                                                BlocProvider.of<
                                                                                      HomeBloc
                                                                                    >(
                                                                                      context,
                                                                                    )
                                                                                    .add(
                                                                                      const CheckWithGetCartEvent(
                                                                                        isForPlaceOrder: false,
                                                                                      ),
                                                                                    );
                                                                              },
                                                                              fromLogin: false,
                                                                              onLoginFailed: () {
                                                                                pageController.animateToPage(
                                                                                  3,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                              },
                                                                              goBack: () {
                                                                                pageController.animateToPage(
                                                                                  1,
                                                                                  duration: const Duration(
                                                                                    milliseconds: 500,
                                                                                  ),
                                                                                  curve: Curves.easeInOut,
                                                                                );
                                                                              },
                                                                              methodIcon:
                                                                                  isVisWhatsApp ==
                                                                                      1
                                                                                  ? AppAssets.whatsappSvg
                                                                                  : AppAssets.smsSvg,
                                                                              phoneNumber: phoneNumber,
                                                                            ),
                                                                          ],
                                                                  ),
                                                                  Positioned(
                                                                    top: 0,
                                                                    left:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? null
                                                                        : 0,
                                                                    right:
                                                                        LanguageService.languageCode !=
                                                                            "ar"
                                                                        ? 0
                                                                        : null,
                                                                    child: Container(
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                            10,
                                                                          ),
                                                                      height:
                                                                          20,
                                                                      width: 40,
                                                                      child: InkWell(
                                                                        onTap: () =>
                                                                            isVerified.value =
                                                                                true,
                                                                        child: SvgPicture.asset(
                                                                          AppAssets
                                                                              .closeSvg,
                                                                          height:
                                                                              15,
                                                                          width:
                                                                              30,
                                                                          // ignore: deprecated_member_use
                                                                          color: const Color(
                                                                            0xffFF5F61,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            margin: EdgeInsets.only(
                                                              bottom:
                                                                  ((state.cartCollection ==
                                                                          null ||
                                                                      state
                                                                          .cartCollection!
                                                                          .isEmpty))
                                                                  ? 20
                                                                  : 10,
                                                            ),
                                                            height: 70.h,
                                                            child: BlocBuilder<AuthBloc, AuthState>(
                                                              buildWhen: (p, c) =>
                                                                  p.verifyOtpSignInStatus !=
                                                                      c.verifyOtpSignInStatus ||
                                                                  p.verifyOtpSignUpStatus !=
                                                                      c.verifyOtpSignUpStatus ||
                                                                  c.verifyOtpFromGuestStatus !=
                                                                      p.verifyOtpFromGuestStatus,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    authState,
                                                                  ) {
                                                                    return (authState.verifyOtpFromGuestStatus ==
                                                                                VerifyOtpFromGuestStatus.loading ||
                                                                            state.getCartOverviewStatus ==
                                                                                GetCartOverviewStatus.loading ||
                                                                            state.addItemInCartStatus ==
                                                                                AddItemInCartStatus.loading ||
                                                                            state.deleteItemInCartStatus ==
                                                                                DeleteItemInCartStatus.loading ||
                                                                            state.updateItemInCartStatus ==
                                                                                UpdateItemInCartStatus.loading ||
                                                                            state.checkWithGetCartStatus ==
                                                                                CheckWithGetCartStatus.loading)
                                                                        ? Shimmer.fromColors(
                                                                            baseColor:
                                                                                Colors.grey[200]!,
                                                                            highlightColor:
                                                                                Colors.grey[100]!,
                                                                            child: Container(
                                                                              alignment: Alignment.center,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        "${LocaleKeys.confirm.tr()} ",
                                                                                        style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                          fontSize: 18.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        "&",
                                                                                        style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                          fontSize: 18.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        " ${LocaleKeys.continues.tr()}",
                                                                                        style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                          fontSize: 18,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        "${totlalQuantity.round()} ",
                                                                                        style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                          fontSize: 14.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        "${LocaleKeys.item.tr()}",
                                                                                        style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                          fontSize: 14.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        " ${HelperFunctions.formatNumber(numberToFormate: totlalPrice, isNeedRounding: false)} ",
                                                                                        style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                          fontSize: 14.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          letterSpacing: 0.18,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 2,
                                                                                      ),
                                                                                      Text(
                                                                                        priceSymbol ??
                                                                                            '\$',
                                                                                        style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                          decorationColor: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                          fontSize: 14.sp,
                                                                                          color: const Color(
                                                                                            0xffFEFEFE,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              margin: EdgeInsets.symmetric(
                                                                                horizontal: 20.w,
                                                                              ),
                                                                              width: 390.w,
                                                                              height: 70.h,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  20,
                                                                                ),
                                                                                color: const Color(
                                                                                  0xff3C3C3C,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : InkWell(
                                                                            onTap: () {
                                                                              if ((state.cartCollection ==
                                                                                      null ||
                                                                                  state.cartCollection!.isEmpty)) {
                                                                                if (Navigator.canPop(
                                                                                  context,
                                                                                )) {
                                                                                  if (Navigator.of(
                                                                                    context,
                                                                                  ).canPop()) {
                                                                                    Navigator.of(
                                                                                      context,
                                                                                    ).pop();
                                                                                    return;
                                                                                  }

                                                                                  // يسمح بالإغلاق إذا لم تنطبق أي من الشروط

                                                                                  appBloc.add(
                                                                                    ChangeBasePage(
                                                                                      0,
                                                                                    ),
                                                                                  );
                                                                                  boutiqueBloc.add(
                                                                                    ResetAllSelectedAppliedFilterEvent(),
                                                                                  );
                                                                                  return;
                                                                                } else {
                                                                                  appBloc.add(
                                                                                    ChangeBasePage(
                                                                                      0,
                                                                                    ),
                                                                                  );
                                                                                  return;
                                                                                }
                                                                              } else if (state.getCartOverviewStatus ==
                                                                                  GetCartOverviewStatus.failure) {
                                                                                homeBloc.add(
                                                                                  GetCartOverviewEvent(),
                                                                                );
                                                                                return;
                                                                              } else if (state.checkWithGetCartStatus ==
                                                                                  CheckWithGetCartStatus.failure) {
                                                                                homeBloc.add(
                                                                                  const CheckWithGetCartEvent(
                                                                                    isForPlaceOrder: false,
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              } else if (state.cartCollection!.any(
                                                                                (
                                                                                  element,
                                                                                ) =>
                                                                                    (element.isActive ==
                                                                                        false ||
                                                                                    element.isCountryRestricted ==
                                                                                        true ||
                                                                                    element.checkAvailability ==
                                                                                        false),
                                                                              )) {
                                                                                showWarningMessage(
                                                                                  context,
                                                                                  "${LocaleKeys.you_have_to_delete_all_unavailable_products.tr()}",
                                                                                );
                                                                                return;
                                                                              } else {
                                                                                if (prefsRepository.isVerifiedPhone !=
                                                                                    true) {
                                                                                  if ((prefsRepository.isVerifiedPhonePeforeExpiredToken ??
                                                                                      false)) {
                                                                                    authBloc.add(
                                                                                      SendOtpEvent(
                                                                                        phone: prefsRepository.myPhoneNumber!,
                                                                                        isViaWhatsApp: 1,
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                  isVerified.value = false;
                                                                                } else {
                                                                                  BlocProvider.of<
                                                                                        HomeBloc
                                                                                      >(
                                                                                        context,
                                                                                      )
                                                                                      .add(
                                                                                        const CheckWithGetCartEvent(
                                                                                          isForPlaceOrder: false,
                                                                                        ),
                                                                                      );
                                                                                }
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              alignment: Alignment.center,
                                                                              child:
                                                                                  ((state.cartCollection ==
                                                                                          null ||
                                                                                      state.cartCollection!.isEmpty))
                                                                                  ? Text(
                                                                                      "${LocaleKeys.back_to_home.tr()}",
                                                                                      style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                        fontSize: 18.sp,
                                                                                        color: const Color(
                                                                                          0xffFEFEFE,
                                                                                        ),
                                                                                        letterSpacing: 0.18,
                                                                                      ),
                                                                                    )
                                                                                  : Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              "${LocaleKeys.confirm.tr()} ",
                                                                                              style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                                fontSize: 17.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              "&",
                                                                                              style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                                fontSize: 17.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              " ${LocaleKeys.continues.tr()}",
                                                                                              style: context.textTheme.bodyMedium?.lq.copyWith(
                                                                                                fontSize: 17.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              "${totlalQuantity.round()} ",
                                                                                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                                fontSize: 14.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              "${LocaleKeys.item.tr()}",
                                                                                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                                fontSize: 14.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              " ${HelperFunctions.formatNumber(numberToFormate: totlalPrice, isNeedRounding: false)} ",
                                                                                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                                                                                fontSize: 14.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                letterSpacing: 0.18,
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              width: 2,
                                                                                            ),
                                                                                            Text(
                                                                                              priceSymbol ??
                                                                                                  '\$',
                                                                                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                                                                                decorationColor: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                                fontSize: 14.sp,
                                                                                                color: const Color(
                                                                                                  0xffFEFEFE,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 5,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                              margin: EdgeInsets.symmetric(
                                                                                horizontal: 20.w,
                                                                              ),
                                                                              width: 390.w,
                                                                              height: 70.h,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  20,
                                                                                ),
                                                                                color: const Color(
                                                                                  0xff3C3C3C,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                  },
                                                            ),
                                                          ),
                                                    const SizedBox(height: 5),
                                                  ],
                                                ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
