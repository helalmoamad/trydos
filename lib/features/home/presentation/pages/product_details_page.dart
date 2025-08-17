import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';

import 'package:trydos/features/app/my_text_widget.dart';

import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';

import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';

import 'package:trydos/features/home/presentation/pages/product_details_display_pictures_page.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/display_sizes_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/features/home/presentation/widgets/second_counter_for_redeem.dart';
import 'package:trydos/main.dart';

import 'package:trydos/routes/router.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../service/language_service.dart';

import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';

import '../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;

import '../manager/homeBloc/home_state.dart';
import '../widgets/product_details_body/badges_list.dart';
import '../widgets/product_details_body/display_colors_card.dart';
import '../widgets/product_details_body/product_details_chip_widget.dart';
import '../widgets/product_details_body/product_details_description_widget.dart';
import '../widgets/product_details_body/product_details_image_widget.dart';
import '../widgets/product_details_body/product_shipping_and_delivery.dart';
import '../widgets/product_details_body/sliding_up_panel_for_buyers_camera_shots.dart';
import '../widgets/product_details_body/sliding_up_panel_for_reels.dart';
import '../widgets/product_stories_section/product_stories_card.dart';
import '../widgets/product_details_body/buyers_camera_shots.dart';

// ignore: must_be_immutable
class ProductDetailsPage extends StatefulWidget {
  ProductDetailsPage({
    super.key,
    this.productItem,
    this.fromCart,
    this.fromNotification = false,
    this.fromNotificationComment = false,
    this.productIdForOpeningChatDirectly,
    this.productSlugForOpeningChatDirectly,
  });

  final productListingModel.Products? productItem;
  final String? productIdForOpeningChatDirectly;
  final String? productSlugForOpeningChatDirectly;
  final bool fromNotification;
  final bool? fromCart;
  bool fromNotificationComment;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ScrollController scrollController = ScrollController();
  productListingModel.Products? productItem;
  late HomeBloc homeBloc;
  late ChatBloc chatBloc;
  late AppBloc appBloc;
  int? initialColor;

  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  bool enable = true;
  bool FromForGroundNotification = false;
  double? valueOnY;
  final PanelController panelControllerForBuyersCameraShots = PanelController();
  final PanelController panelControllerForReels = PanelController();
  final PanelController panelControllerForCart = PanelController();
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> visibleSizeAndColorCard = ValueNotifier(false);
  final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
  bool isChangedvariationWhenQtyZeroForFirst = false;
  final ValueNotifier<String?> productNotAvailableNotifier =
      ValueNotifier(null);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? changeVariationIfQtyZero;
  bool showDialogToResetSession = true;
  bool getAllDataForProductForFirst = true;

  int currentSelectedColor = -1;
  int currentSelectedColorAfterChangeVariant = -1;
  @override
  void initState() {
    changeVariationIfQtyZero = true;
    if (widget.productItem != null) {
      productItem = widget.productItem!;
    }

    homeBloc = BlocProvider.of<HomeBloc>(context);
    productIdToSaveRedeemTimer.remove(productItem?.productId.toString());
    //homeBloc.add(AddProductIdToSaveRedeemTimerEvent(
    //   on: false, productIdToSaveRedeemTimer: productIdToSaveRedeemTimer));
    homeBloc.add(IsChangedColorBeforOpenPanelEvent(
        iChangedColorBeforOpenPanelEvent: false));
    initialColor = homeBloc.state.currentSelectedColorForEveryProduct[
            widget.productItem?.slug.toString()] ??
        -1;
    homeBloc.add(IsChangedVariationWhenQtyZeroEvent(
        isChangedVariationWhenQtyZero: false));

    chatBloc = BlocProvider.of<ChatBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.add(IsFromNotificationByForGround(widget.fromNotification));
    if (widget.productItem != null) {
      homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
          productSlug: productItem?.slug,
          productId: productItem?.productId.toString()));
    }

    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    // context.go(GRouter.config.kRootRoute);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.surface,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.PRODUCT_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );

      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (productItem == null) {
      return;
    }

    late DateTime _endTime;
    final now = DateTime.now();
    final prefs = GetIt.I<PrefsRepository>();
    int? savedSeconds = prefs
        .getRedeemSecondRemainingForProduct(productItem!.productId.toString());
    if (savedSeconds != null && savedSeconds > 0) {
      _endTime = DateTime.now().add(Duration(seconds: savedSeconds));
    } else {
      _endTime =
          prefs.getRedeemDateForProduct(productItem!.productId.toString()) ??
              DateTime.now();
    }
    final diff = _endTime.difference(now);
    int secondsToSave = (diff.inSeconds) > 0 ? diff.inSeconds : 0;

    prefs.setRedeemSecondRemainingForProduct(
        productItem!.productId.toString(), secondsToSave);
    //  homeBloc.add(AddProductIdToSaveRedeemTimerEvent(
    //      on: true, productIdToSaveRedeemTimer: productIdToSaveRedeemTimer));
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return WillPopScope(
      onWillPop: () {
        homeBloc.add(IsChangedColorBeforOpenPanelEvent(
            iChangedColorBeforOpenPanelEvent: false));
        if (widget.fromCart ?? false) {
          homeBloc.add(GetCartItemEvent());
        }
        if (panelControllerForCart.isPanelOpen) {
          panelControllerForCart.close();
          currentActiveTab.value = 0;
          return Future.value(false);
        }
        if (widget.fromNotification) {
          context.go(GRouter.config.kRootRoute);

          return Future.value(false);
        }
        if (Navigator.of(context).canPop()) {
          if (widget.productItem != null && initialColor != -1) {
            homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: initialColor ?? 0,
                productSlug: widget.productItem!.slug.toString()));
          }

          Navigator.of(context).pop();

          return Future.value(false);
        }

        return Future.value(true);
      },
      child: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
              appBar: TrydosAppBar(
                appBarParams: AppBarParams(
                    onBack: () {
                      homeBloc.add(IsChangedColorBeforOpenPanelEvent(
                          iChangedColorBeforOpenPanelEvent: false));
                      if (widget.productItem != null && initialColor != -1) {
                        homeBloc.add(AddCurrentSelectedColorEvent(
                            currentSelectedColor: initialColor ?? 0,
                            productSlug: widget.productItem!.slug.toString()));
                      }
                    },
                    scrolledUnderElevation: 0,
                    backIconColor: Colors.black,
                    action: [
                      LanguageService.rtl ? Spacer() : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10.0),
                        child: BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (previous, current) =>
                              previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                                  current
                                      .getProductDetailWithoutSimilarRelatedProductsStatus ||
                              previous.updateItemInCartStatus !=
                                  current.updateItemInCartStatus ||
                              previous.addItemInCartStatus !=
                                  current.addItemInCartStatus ||
                              previous.deleteItemInCartStatus !=
                                  current.deleteItemInCartStatus ||
                              previous.getCartItemsStatus !=
                                  current.getCartItemsStatus,
                          builder: (context, state) {
                            /* if ((prefsRepository.isTokenExpired ??
                                    false ||
                                        prefsRepository.marketToken == "" ||
                                        prefsRepository.marketToken == null) &&
                                showDialogToResetSession &&
                                GetIt.I<AuthBloc>().state.registerGuestStatus !=
                                    RegisterGuestStatus.loading) {
                              showDialogToResetSession = false;
                              Future.delayed(
                                  Duration(seconds: 3),
                                  () => showDialog(
                                        context: context,
                                        builder: (context) => Center(
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
                                                      : MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    (prefsRepository
                                                                .isVerifiedPhonePeforeExpiredToken ??
                                                            false)
                                                        ? SizedBox.shrink()
                                                        : Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 130,
                                                            child:
                                                                AppElevatedButton(
                                                              textStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          16),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                String?
                                                                    deviceId =
                                                                    await HelperFunctions
                                                                        .getDeviceId();

                                                                GetIt.I<AuthBloc>().add(RegisterGuestEvent(
                                                                    oldGuestUserId:
                                                                        prefsRepository
                                                                            .myMarketId
                                                                            .toString(),
                                                                    deviceId:
                                                                        deviceId!));
                                                              },
                                                              text:
                                                                  "${LocaleKeys.reset_your_count.tr()}",
                                                            ),
                                                          ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 130,
                                                      child: AppElevatedButton(
                                                        textStyle: TextStyle(
                                                            fontSize: 16),
                                                        onPressed: () {
                                                          showDialogToResetSession =
                                                              false;
                                                          Navigator.of(context)
                                                              .pop();

                                                          Navigator.of(context)
                                                              .push(
                                                                  PageRouteBuilder(
                                                            pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                RegistrationPage(
                                                              fromExpiredToken:
                                                                  true,
                                                            ),
                                                          ));
                                                        },
                                                        text:
                                                            '${LocaleKeys.go_to_log_in.tr()}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                      ));
                            }*/
                            if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                        .failure &&
                                (prefsRepository.isTokenExpired ??
                                    false ||
                                        prefsRepository.marketToken == "" ||
                                        prefsRepository.marketToken == null)) {
                              Future.delayed(
                                Duration(seconds: 5),
                                () {
                                  if (widget.productItem != null) {
                                    homeBloc.add(
                                        GetProductDatailsWithoutRelatedProductsEvent(
                                            productSlug: productItem?.slug,
                                            productId: productItem?.productId
                                                .toString()));
                                  } else {
                                    BlocProvider.of<HomeBloc>(context)
                                        .add(GetFullProductDetailsEvent(
                                      productSlug: widget
                                              .productSlugForOpeningChatDirectly ??
                                          "",
                                    ));
                                  }
                                },
                              );
                            }
                            int qtyItemsInCart =
                                state.cartCollection?.length ?? 0;
                            /* state.cartCollection?.forEach(
                              (element) {
                                qtyItemsInCart =
                                    qtyItemsInCart + (element.quantity ?? 0);
                              },
                            );*/
                            (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                            return Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: LanguageService.languageCode != "ar"
                                  ? 40
                                  : 50,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CartPage(
                                          fromeFilters: true,
                                        ),
                                      ),
                                    );
                                    //////////////////////////////
                                    // FirebaseAnalyticsService.logEventForSession(
                                    //   eventName:
                                    //       AnalyticsEventsConst.buttonClicked,
                                    //   executedEventName:
                                    //       AnalyticsButtonsEventNameConst
                                    //           .showShoppingBagButton,
                                    // );
                                  },
                                  child: Stack(children: [
                                    Positioned(
                                      child:
                                          SvgPicture.asset(AppAssets.bagsSvg),
                                      right:
                                          LanguageService.languageCode != "ar"
                                              ? 0
                                              : null,
                                      left: LanguageService.languageCode == "ar"
                                          ? 0
                                          : null,
                                      bottom: 5,
                                    ),
                                    Positioned(
                                      child: Container(
                                        width: (qtyItemsInCart > 0) ? 15 : 0,
                                        alignment: Alignment.center,
                                        height: (qtyItemsInCart > 0) ? 15 : 0,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: MyTextWidget(
                                          (qtyItemsInCart > 0)
                                              ? "${qtyItemsInCart}"
                                              : "",
                                          maxLines: 1,
                                          style: textTheme.titleSmall?.ra
                                              .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  letterSpacing: 0.28),
                                        ),
                                      ),
                                      top: 0,
                                      left: LanguageService.languageCode != "ar"
                                          ? 5
                                          : null,
                                      right: LanguageService.languageCode !=
                                              "en"
                                          ? (qtyItemsInCart.toString().length >
                                                  1)
                                              ? 0
                                              : 10
                                          : null,
                                    )
                                  ])),
                            );
                          },
                        ),
                      ),
                    ],
                    withShadow: false),
              ),
              backgroundColor: Color(0xffF4F4F4),
              body: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) =>
                    p.getFullProductDetailsStatus !=
                    c.getFullProductDetailsStatus,
                builder: (context, state) {
                  if (widget.productItem == null) {
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.loading) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 1.sw,
                            height: 500,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...List.generate(
                                        2,
                                        (index) => Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.w, right: 10.w),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade600,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.r),
                                                ),
                                                height: 450.h,
                                                width: 320.w,
                                              ),
                                            )))
                                  ],
                                )),
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: 12.w, left: 12.w),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  height: 50.h,
                                  width: 300.w,
                                  color: Colors.grey.shade600,
                                ),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: 12.w, left: 12.w),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  height: 50.h,
                                  width: 300.w,
                                  color: Colors.grey.shade600,
                                ),
                              )),
                          Spacer(),
                          Container(
                            height: 120.h, // ارتفاع الـ panel المغلقة
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Handle Bar (شريط الإغلاق)
                                Container(
                                  margin: EdgeInsets.only(top: 7.h),
                                  child: Container(
                                    width: 25.w,
                                    height: 3.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ),
                                // Bottom Action Bar (شريط الإجراءات السفلي)
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 10.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Left side - Add to Bag Button
                                        Container(
                                          width: 100.w,
                                          height: 70.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(25.r),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Shopping Bag Icon
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade50,
                                                child: SvgPicture.asset(
                                                  AppAssets.bagSvg,
                                                  height: 30.h,
                                                  width: 30.w,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              // "Add To Bag" Text
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade50,
                                                child: Container(
                                                  width: 60.w,
                                                  height: 10.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.r),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 30.w),
                                        // Right side - Action Icons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Heart Icon (Like)
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: SvgPicture.asset(
                                                    AppAssets.favoriteSvg,
                                                    height: 30.h,
                                                    width: 30.w,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: Container(
                                                    width: 15.w,
                                                    height: 10.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.r),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 35.w),
                                            // Chat Bubble Icon
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: SvgPicture.asset(
                                                    AppAssets.chatMarkSvg,
                                                    height: 30.h,
                                                    width: 30.w,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: Container(
                                                    width: 15.w,
                                                    height: 10.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.r),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 35.w),
                                            // Share Icon
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: SvgPicture.asset(
                                                    AppAssets.shareSvg,
                                                    height: 30.h,
                                                    width: 30.w,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade50,
                                                  child: Container(
                                                    width: 15.w,
                                                    height: 10.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.r),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 35.w),
                                            // More Options Icon
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: SvgPicture.asset(
                                                AppAssets.moreOptionSvg,
                                                height: 30.h,
                                                width: 30.w,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.failure) {
                      return Center(
                        child: MyTextWidget(
                            '${LocaleKeys.failed_to_get_product_details.tr()}'),
                      );
                    }
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.success) {
                      if (state
                              .productContentForStatusOfOpeningProductDetailsDirectly
                              ?.countryIsRestricted ==
                          true) {
                        productNotAvailableNotifier.value = LocaleKeys
                            .product_is_not_available_in_your_country
                            .tr();
                      } else if (state
                              .productContentForStatusOfOpeningProductDetailsDirectly
                              ?.isActive ==
                          false) {
                        productNotAvailableNotifier.value = LocaleKeys
                            .this_product_is_not_available_in_store
                            .tr();
                      } else {
                        productNotAvailableNotifier.value = null;
                      }
                    }
                    productItem = state
                        .productContentForStatusOfOpeningProductDetailsDirectly!;
                  }
                  return BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (p, c) =>
                        p.getStoriesForProductStatus !=
                            c.getStoriesForProductStatus ||
                        p.getFullProductDetailsStatus !=
                            c.getFullProductDetailsStatus ||
                        p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            c
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        p.currentSelectedColorForEveryProduct[
                                productItem?.slug.toString()] !=
                            c.currentSelectedColorForEveryProduct[
                                productItem?.slug.toString()] ||
                        p.cachedProductWithoutRelatedProductsModel !=
                            c.cachedProductWithoutRelatedProductsModel,
                    builder: (context, state) {
                      if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          getAllDataForProductForFirst) {
                        if (state.cachedProductWithoutRelatedProductsModel[
                                productItem?.productId.toString()] !=
                            null) {
                          if (state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem?.productId.toString()]!
                                  .product !=
                              null) {
                            if (productItem != null) {
                              List<String> syncColorNames = [];
                              List<productListingModel.SyncColorImage>
                                  syncColorImagesFromListing =
                                  widget.productItem?.syncColorImages ?? [];

                              for (var i = 0;
                                  i <
                                      (widget.productItem?.syncColorImages
                                              ?.length ??
                                          0);
                                  i++) {
                                syncColorNames.add(widget.productItem
                                        ?.syncColorImages?[i].colorName ??
                                    "");
                              }
                              state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem?.productId.toString()]!
                                  .product
                                  ?.syncColorImages
                                  ?.forEach(
                                (element) {
                                  if (!syncColorNames
                                      .contains(element.colorOption)) {
                                    syncColorImagesFromListing.add(element);
                                  }
                                },
                              );
                              List<productListingModel.Color>?
                                  colorsFromListing =
                                  widget.productItem?.colors ?? [];
                              state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem?.productId.toString()]!
                                  .product
                                  ?.colors
                                  ?.forEach(
                                (element) {
                                  if (!(syncColorNames
                                      .contains(element.name))) {
                                    colorsFromListing.add(element);
                                  }
                                },
                              );
                              productItem = productItem!.copyWith(
                                collectedAfterOrdering: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.collectedAfterOrdering,
                                countOfPieces: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.countOfPieces,
                                countOfLikes: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.countOfLikes,
                                deliveryAt: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.deliveryAt,
                                countryIsRestricted: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.countryIsRestricted,
                                isActive: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.isActive,
                                leftStock: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.leftStock,
                                isProductNotifiedForUser: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.isProductNotifiedForUser,
                                price: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.price,
                                offerPrice: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.offerPrice,
                                offerPriceFormatted: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.offerPriceFormatted,
                                priceFormatted: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.priceFormatted,
                                availableQuantity: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.availableQuantity,
                                choiceOptions: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.choiceOptions,
                                colors: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.colors,
                                images: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.images,
                                syncColorImages: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product
                                    ?.syncColorImages,
                              );
                              getAllDataForProductForFirst = false;
                            }
                          }
                        }
                      }
                      if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          widget.productSlugForOpeningChatDirectly == null)) {
                        if (state
                                .cachedProductWithoutRelatedProductsModel[
                                    widget.productItem?.productId.toString()]
                                ?.product
                                ?.countryIsRestricted ==
                            true) {
                          productNotAvailableNotifier.value = LocaleKeys
                              .product_is_not_available_in_your_country
                              .tr();
                        } else if (state
                                .cachedProductWithoutRelatedProductsModel[
                                    widget.productItem?.productId.toString()]
                                ?.product
                                ?.isActive ==
                            false) {
                          productNotAvailableNotifier.value = LocaleKeys
                              .this_product_is_not_available_in_store
                              .tr();
                        } else {
                          productNotAvailableNotifier.value = null;
                        }
                      }
                      state
                          .cachedProductWithoutRelatedProductsModel[
                              productItem?.productId.toString()]
                          ?.product
                          ?.variation
                          ?.forEach(
                        (element) {},
                      );
                      String productId = widget
                              .productIdForOpeningChatDirectly ??
                          (state.cachedProductWithoutRelatedProductsModel[
                                      productItem?.productId.toString()] !=
                                  null
                              ? state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productItem?.productId
                                                  .toString()]!
                                          .product !=
                                      null
                                  ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem?.productId.toString()]!
                                      .product!
                                      .id
                                      .toString()
                                  : ""
                              : "");
                      if (productId == "") {
                        productId =
                            widget.productItem?.productId.toString() ?? '';
                      }
                      String productSlug = widget
                              .productSlugForOpeningChatDirectly ??
                          (state.cachedProductWithoutRelatedProductsModel[
                                      productItem?.productId.toString()] !=
                                  null
                              ? state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productItem?.productId
                                                  .toString()]!
                                          .product !=
                                      null
                                  ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem?.productId.toString()]!
                                      .product!
                                      .slug
                                      .toString()
                                  : ""
                              : "");
                      if (productSlug == "") {
                        productSlug = widget.productItem?.slug.toString() ?? '';
                      }
                      /*     if (state
                                .getProductDetailWithoutSimilarRelatedProductsStatus ==
                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                .failure) {
                          return Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  homeBloc.add(
                                      GetProductDatailsWithoutRelatedProductsEvent(
                                          productId:
                                              productItem.id.toString()));
                                },
                                child: MyTextWidget(LocaleKeys.try_again.tr())),
                          );
                        }*/
                      if (!state.cachedProductWithoutRelatedProductsModel
                              .containsKey(productItem!.productId.toString()) ||
                          (state.cachedProductWithoutRelatedProductsModel[
                                      productItem!.productId.toString()] !=
                                  null
                              ? state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productItem!.productId
                                                  .toString()]!
                                          .product !=
                                      null
                                  ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem!.productId.toString()]!
                                      .product!
                                      .choiceOptions
                                      .isNullOrEmpty
                                  : true
                              : true)) {
                        homeBloc.add(AddCurrentColorSizeEvent(
                            choice_1: null, choiceOption: null));
                      }

                      int currentSelectedColor =
                          state.currentSelectedColorForEveryProduct[
                                  productSlug] ??
                              (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                      if (currentSelectedColor >
                          (productItem?.syncColorImages?.length ?? 0)) {
                        currentSelectedColor = 0;
                      }
                      Future.delayed(
                        Duration(milliseconds: 600),
                        () {
                          homeBloc.add(AddSizesForColorsEvent(
                              currentColorName:
                                  !productItem!.colors.isNullOrEmpty
                                      ? productItem!
                                              .colors![currentSelectedColor]
                                              .option ??
                                          ""
                                      : "",
                              variation: state.cachedProductWithoutRelatedProductsModel[
                                          productItem?.productId.toString()] !=
                                      null
                                  ? state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  productItem?.productId
                                                      .toString()]!
                                              .product !=
                                          null
                                      ? state
                                          .cachedProductWithoutRelatedProductsModel[
                                              productItem?.productId
                                                  .toString()]!
                                          .product!
                                          .variation
                                      : null
                                  : null));
                        },
                      );

                      return RefreshIndicator(
                        onRefresh: () async {
                          isChangedvariationWhenQtyZeroForFirst = false;
                          getAllDataForProductForFirst = true;

                          // إعادة تحميل بيانات المنتج
                          if (widget.productItem != null) {
                            homeBloc.add(
                                GetProductDatailsWithoutRelatedProductsEvent(
                                    productSlug: productItem?.slug,
                                    productId:
                                        productItem?.productId.toString()));
                          } else {
                            homeBloc.add(GetFullProductDetailsEvent(
                                productSlug:
                                    widget.productSlugForOpeningChatDirectly ??
                                        ""));
                          }
                        },
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                        child: ScrollConfiguration(
                          behavior: const CupertinoScrollBehavior(),
                          child: ListView(
                            shrinkWrap: true,
                            controller: scrollController,
                            physics: enable
                                ? const AlwaysScrollableScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            children: [
                              Stack(
                                alignment: LanguageService.rtl
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                children: [
                                  SizedBox(
                                    height: 464,
                                    child: ScrollConfiguration(
                                      behavior: const CupertinoScrollBehavior(),
                                      child: ListView.separated(
                                        itemCount: productItem!
                                                .syncColorImages.isNullOrEmpty
                                            ? productItem!.images!.length
                                            : !productItem!
                                                    .syncColorImages![
                                                        currentSelectedColor]
                                                    .images
                                                    .isNullOrEmpty
                                                ? productItem!
                                                    .syncColorImages![
                                                        currentSelectedColor]
                                                    .images!
                                                    .length
                                                : 0,
                                        primary: false,
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 15),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              // pushOverscrollRoute(
                                              //     context: context,
                                              //     transitionDuration:
                                              //         Duration(milliseconds: 250),
                                              //     reverseTransitionDuration:
                                              //         Duration(milliseconds: 400),
                                              //     child:
                                              //         ProductDetailsDisplayPicturesPage(
                                              //             pictureIndex: index),
                                              //     workNormally: true,
                                              //     withRoundedCorners: true,
                                              //     isArabicLanguage:
                                              //         LanguageService.rtl,
                                              //     dragToPopDirection:
                                              //         DragToPopDirection.toBottom,
                                              //     scrollToPopOption:
                                              //         ScrollToPopOption.start,
                                              //     fullscreenDialog: true);
                                              HelperFunctions.slidingNavigation(
                                                context,
                                                ProductDetailsDisplayPicturesPage(
                                                  currentIndex: index,
                                                  images: productItem!
                                                          .syncColorImages
                                                          .isNullOrEmpty
                                                      ? productItem!.images ??
                                                          []
                                                      : productItem!
                                                              .syncColorImages![
                                                                  currentSelectedColor]
                                                              .images ??
                                                          [],
                                                ),
                                              );
                                              //////////////////////////////
                                              // FirebaseAnalyticsService
                                              //     .logEventForSession(
                                              //   eventName: AnalyticsEventsConst
                                              //       .buttonClicked,
                                              //   executedEventName:
                                              //       AnalyticsButtonsEventNameConst
                                              //           .showProductPhotosButton,
                                              // );
                                            },
                                            child: ProductDetailsImageWidget(
                                              index: index,
                                              productNotAvailableNotifier:
                                                  productNotAvailableNotifier,
                                              flashDealEndDate: productItem
                                                      ?.flashDealEndDate ??
                                                  "",
                                              productId:
                                                  productItem?.productId ?? 0,
                                              visibleRedeem: visibleRedeem,
                                              isRedeem: state.cachedProductWithoutRelatedProductsModel[
                                                          productItem?.productId
                                                              .toString()] !=
                                                      null
                                                  ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productItem
                                                                  ?.productId
                                                                  .toString()]!
                                                          .product
                                                          ?.isRedeem ==
                                                      true
                                                  : false,
                                              /*    flashDealTime: index != 0
                                                  ? ""
                                                  : productItem!
                                                          .flashDealEndDate ??
                                                      "",
                                              lableNames: index != 0
                                                  ? []
                                                  : productItem!.labelNames ??
                                                      [],*/
                                              height: 464,
                                              width: 320,
                                              orginalHeight: widget
                                                          .productItem ==
                                                      null
                                                  ? 0
                                                  : widget
                                                          .productItem!
                                                          .syncColorImages
                                                          .isNullOrEmpty
                                                      ? double.tryParse(
                                                          productItem!
                                                              .images![index]
                                                              .originalHeight!)
                                                      : double.tryParse(productItem!
                                                          .syncColorImages![
                                                              currentSelectedColor]
                                                          .images![index]
                                                          .originalHeight!),
                                              orginalWidth: widget
                                                          .productItem ==
                                                      null
                                                  ? 0
                                                  : widget
                                                          .productItem!
                                                          .syncColorImages
                                                          .isNullOrEmpty
                                                      ? double.tryParse(
                                                          productItem!
                                                              .images![index]
                                                              .originalWidth!)
                                                      : double.tryParse(productItem!
                                                          .syncColorImages![
                                                              currentSelectedColor]
                                                          .images![index]
                                                          .originalWidth!),
                                              imageUrl: productItem!
                                                      .syncColorImages
                                                      .isNullOrEmpty
                                                  ? productItem!
                                                      .images![index].filePath!
                                                  : productItem!
                                                      .syncColorImages![
                                                          currentSelectedColor]
                                                      .images![index]
                                                      .filePath,
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            width: 9,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 464,
                                    color: Colors.transparent,
                                  )
                                ],
                              ),
                              ProductDetailsTitle(
                                productId: productItem!.productId.toString(),
                                orginalHeight: 0,
                                orginalWidth: 0,
                                brand: productItem!.brand,
                                productName: productItem!.name ?? "",
                                thumbnail: (!productItem!
                                        .syncColorImages.isNullOrEmpty)
                                    ? (!productItem!.syncColorImages![0].images
                                            .isNullOrEmpty)
                                        ? (productItem!
                                                .syncColorImages![
                                                    currentSelectedColor]
                                                .images![0]
                                                .filePath ??
                                            productItem!.images?[0].filePath ??
                                            "")
                                        : (productItem!.images![0].filePath ??
                                            "")
                                    : (productItem!.images![0].filePath ?? ""),
                                colorName: !productItem!
                                            .syncColorImages.isNullOrEmpty &&
                                        !productItem!.syncColorImages![0].images
                                            .isNullOrEmpty
                                    ? productItem!
                                            .syncColorImages![
                                                currentSelectedColor]
                                            .colorName ??
                                        " "
                                    : " ",
                              ),

                              if (!state
                                  .cachedProductWithoutRelatedProductsModel
                                  .containsKey(
                                      productItem!.productId.toString())) ...{
                                SizedBox.shrink()
                              } else ...{
                                ProductDetailsDescriptionWidget(
                                  description: productItem!.details ?? " ",
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                BadgesList(
                                  lable: state.cachedProductWithoutRelatedProductsModel[
                                              productItem!.productId
                                                  .toString()] !=
                                          null
                                      ? state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      productItem!.productId
                                                          .toString()]!
                                                  .product !=
                                              null
                                          ? state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      productItem!.productId
                                                          .toString()]!
                                                  .product!
                                                  .labels ??
                                              []
                                          : []
                                      : [],
                                ),
                              },
                              SizedBox(
                                height: 15,
                              ),
                              if (!state
                                      .cachedProductWithoutRelatedProductsModel
                                      .containsKey(
                                          productItem!.productId.toString()) ||
                                  (state.cachedProductWithoutRelatedProductsModel[
                                              productItem!.productId
                                                  .toString()] !=
                                          null
                                      ? state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      productItem!.productId
                                                          .toString()]!
                                                  .product !=
                                              null
                                          ? state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  productItem!.productId
                                                      .toString()]!
                                              .product!
                                              .descriptors
                                              .isNullOrEmpty
                                          : true
                                      : true)) ...{
                                SizedBox.shrink()
                              } else ...{
                                SizedBox(
                                    height: 52,
                                    child: ScrollConfiguration(
                                      behavior: const CupertinoScrollBehavior(),
                                      child: ListView.separated(
                                        itemCount: state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]!
                                            .product!
                                            .descriptors!
                                            .length,
                                        physics: const ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        itemBuilder: (context, index) {
                                          return ProductDetailsChipWidget(
                                            withIcon: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem!.productId
                                                            .toString()]!
                                                    .product!
                                                    .descriptors![index]
                                                    .descriptorGroup!
                                                    .icon !=
                                                null,
                                            descriptor: state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product!
                                                .descriptors![index],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(
                                            width: 8,
                                          );
                                        },
                                      ),
                                    )),
                              },
                              SizedBox(
                                height: 15,
                              ),
                              if (!productItem!
                                  .syncColorImages.isNullOrEmpty) ...{
                                ValueListenableBuilder<bool>(
                                  valueListenable: visibleSizeAndColorCard,
                                  builder:
                                      (context, _visibleSizeAndColorCard, _) {
                                    return !_visibleSizeAndColorCard
                                        ? SizedBox.shrink()
                                        : DisplayColorsCard(
                                            productItem: productItem!.copyWith(
                                                syncColorImages: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.syncColorImages,
                                                choiceOptions: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.choiceOptions,
                                                colors: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.colors,
                                                productId: state.cachedProductWithoutRelatedProductsModel[
                                                            productItem
                                                                ?.productId
                                                                .toString()] !=
                                                        null
                                                    ? state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]!.product !=
                                                            null
                                                        ? state
                                                            .cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]!
                                                            .product!
                                                            .id
                                                        : null
                                                    : null),
                                            scrollController: scrollController,
                                            currentColorForProduct:
                                                currentSelectedColor,
                                          );
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              },
                              if (!state
                                      .cachedProductWithoutRelatedProductsModel
                                      .containsKey(
                                          productItem!.productId.toString()) ||
                                  (state.cachedProductWithoutRelatedProductsModel[
                                              productItem!.productId
                                                  .toString()] !=
                                          null
                                      ? state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      productItem!.productId
                                                          .toString()]!
                                                  .product !=
                                              null
                                          ? state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  productItem!.productId
                                                      .toString()]!
                                              .product!
                                              .choiceOptions
                                              .isNullOrEmpty
                                          : true
                                      : true)) ...{
                                SizedBox.shrink()
                              } else ...{
                                ValueListenableBuilder<bool>(
                                  valueListenable: visibleSizeAndColorCard,
                                  builder:
                                      (context, _visibleSizeAndColorCard, _) {
                                    return !_visibleSizeAndColorCard
                                        ? SizedBox.shrink()
                                        : DisplaySizesCard(
                                            productItem: productItem!.copyWith(
                                                syncColorImages: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.syncColorImages,
                                                choiceOptions: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.choiceOptions,
                                                colors: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product
                                                    ?.colors,
                                                productId: state.cachedProductWithoutRelatedProductsModel[
                                                            productItem
                                                                ?.productId
                                                                .toString()] !=
                                                        null
                                                    ? state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]!.product !=
                                                            null
                                                        ? state
                                                            .cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]!
                                                            .product!
                                                            .id
                                                        : null
                                                    : null),
                                            currentColorForProduct:
                                                currentSelectedColor,
                                            scrollController: scrollController,
                                            variation: state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product!
                                                .variation,
                                          );
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              },
                              // ProductStoriesCard(),
                              ProductStoriesCard(),
                              ProductShippingAndDelivery(
                                countryName: state.getAllowedCountriesModel
                                        ?.data?.countries
                                        ?.firstWhere((element) {
                                      return element.iso!.toLowerCase().contains(
                                          '${GetIt.I<PrefsRepository>().userCountryIsAvailable == 1 ? GetIt.I<PrefsRepository>().userChoosedCountryIso?.toLowerCase() : GetIt.I<PrefsRepository>().countryIso?.toLowerCase()}');
                                    },
                                            orElse: () => Country(
                                                id: 0,
                                                iso: "",
                                                name: "")).name ??
                                    "",
                                shippingCost: (state
                                                .cachedProductWithoutRelatedProductsModel[
                                            productItem!.productId
                                                .toString()] !=
                                        null
                                    ? state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product!
                                                .shippingCost ??
                                            0
                                        : 0
                                    : 0),
                                shippingDay: ((state.cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()] !=
                                                null
                                            ? state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            productItem!
                                                                .productId
                                                                .toString()]!
                                                        .product !=
                                                    null
                                                ? state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            productItem!
                                                                .productId
                                                                .toString()]!
                                                        .product!
                                                        .shippingDays ??
                                                    0
                                                : 0
                                            : 0) +
                                        (state.startingSetting?.shippingDay ??
                                            0))
                                    .toString(),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              BuyersCameraShots(
                                productItem: productItem!.copyWith(
                                    productId: state.cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()] !=
                                            null
                                        ? state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem?.productId
                                                            .toString()]!
                                                    .product !=
                                                null
                                            ? state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem?.productId
                                                        .toString()]!
                                                .product!
                                                .id
                                            : null
                                        : null),
                                panelControllerForBuyersCameraShots:
                                    panelControllerForBuyersCameraShots,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: (2 * 73.5 / (1.sh - 100.h)).sh,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (p, c) =>
                  p.getFullProductDetailsStatus !=
                  c.getFullProductDetailsStatus,
              builder: (context, state) {
                if (widget.productItem == null) {
                  if (state.getFullProductDetailsStatus !=
                          GetFullProductDetailsStatus
                              .success /* ||
                      (state.productContentForStatusOfOpeningProductDetailsDirectly
                                  ?.countryIsRestricted ==
                              true &&
                          state.getFullProductDetailsStatus ==
                              GetFullProductDetailsStatus.success)*/
                      ) {
                    return SizedBox.shrink();
                  }
                  productItem = state
                      .productContentForStatusOfOpeningProductDetailsDirectly!;
                  Future.delayed(Duration(seconds: 1), () {
                    if (widget.fromNotificationComment) {
                      panelControllerForCart.open();
                      currentActiveTab.value = 0;
                      widget.fromNotificationComment = false;
                    }
                  });
                }
                String productId =
                    state.cachedProductWithoutRelatedProductsModel[
                                productItem?.productId.toString()] !=
                            null
                        ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product !=
                                null
                            ? state
                                .cachedProductWithoutRelatedProductsModel[
                                    productItem?.productId.toString()]!
                                .product!
                                .id
                                .toString()
                            : ""
                        : "";
                String productSlug =
                    state.cachedProductWithoutRelatedProductsModel[
                                productItem?.productId.toString()] !=
                            null
                        ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]!
                                    .product !=
                                null
                            ? state
                                .cachedProductWithoutRelatedProductsModel[
                                    productItem?.productId.toString()]!
                                .product!
                                .slug
                                .toString()
                            : ""
                        : "";
                if (productId == "") {
                  productId = widget.productItem?.productId.toString() ?? '';
                }
                if (productSlug == "") {
                  productSlug = widget.productItem?.slug.toString() ?? '';
                }
                return BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) {
                    return previous.currentSelectedColorForEveryProduct[
                                productSlug] !=
                            current.currentSelectedColorForEveryProduct[
                                productSlug] ||
                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            current
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        previous.changeSizesForEveryProduct !=
                            current.changeSizesForEveryProduct ||
                        previous.currentColorSizeForCart?["choiceOption"] !=
                            current.currentColorSizeForCart?["choiceOption"];
                  },
                  builder: (context, state) {
                    /* if (state
                            .getProductDetailWithoutSimilarRelatedProductsStatus !=
                        GetProductDetailWithoutSimilarRelatedProductsStatus
                            .success) {
                      return SizedBox.shrink();
                    }*/
                    currentSelectedColor = state
                            .currentSelectedColorForEveryProduct[productSlug] ??
                        (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                    String currentSelectedColorOption =
                        ((productItem?.colors?.length ?? 0) > 0)
                            ? productItem!
                                    .colors![currentSelectedColor].option ??
                                ""
                            : "";

                    String currentVariantType =
                        "${currentSelectedColorOption != "" ? currentSelectedColorOption : ""}" +
                            "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? true) && state.currentColorSizeForCart?["choiceOption"] != "") && (currentSelectedColorOption != "") ? "-" : ""}" +
                            "${(state.currentColorSizeForCart?["choiceOption"] != null && !(state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? true) && state.currentColorSizeForCart?["choiceOption"] != "") ? "${state.currentColorSizeForCart?["choiceOption"]}" : ""}";
                    Variation? currentVariation = state
                        .cachedProductWithoutRelatedProductsModel[
                            productItem?.productId.toString()]
                        ?.product
                        ?.variation
                        ?.firstWhere(
                      (element) => element.type!.contains(currentVariantType),
                      orElse: () {
                        return Variation(variantNotifyForUser: false);
                      },
                    );
                    print(currentVariation?.type);

                    if ((state
                                .cachedProductWithoutRelatedProductsModel[
                                    productItem!.productId.toString()]
                                ?.product
                                ?.id !=
                            null &&
                        state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                .success)) {
                      Future.delayed(Duration(seconds: 2),
                          () => visibleSizeAndColorCard.value = true);
                      Future.delayed(
                        Duration(milliseconds: 1200),
                        () {
                          if (!isChangedvariationWhenQtyZeroForFirst) {
                            isChangedvariationWhenQtyZeroForFirst = true;
                            changeVariationWhenNotAvailable(
                                currentVariation: currentVariation,
                                variation:
                                    state.cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()] ==
                                            null
                                        ? []
                                        : state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem?.productId
                                                        .toString()]!
                                                .product
                                                ?.variation ??
                                            [],
                                productSlug: productSlug,
                                productId: productId);
                            changeVariationIfQtyZero = false;
                          }
                        },
                      );
                    }
                    List<String> syncColorNames = [];
                    List<productListingModel.Color>? colorsFromListing =
                        widget.productItem?.colors ?? [];
                    List<productListingModel.SyncColorImage>
                        syncColorImagesFromListing =
                        widget.productItem?.syncColorImages ?? [];

                    if (state
                            .getProductDetailWithoutSimilarRelatedProductsStatus ==
                        GetProductDetailWithoutSimilarRelatedProductsStatus
                            .success) {
                      for (var i = 0;
                          i <
                              (widget.productItem?.syncColorImages?.length ??
                                  0);
                          i++) {
                        syncColorNames.add(
                            widget.productItem?.syncColorImages?[i].colorName ??
                                "");
                      }
                      state
                          .cachedProductWithoutRelatedProductsModel[
                              productItem?.productId.toString()]!
                          .product
                          ?.syncColorImages
                          ?.forEach(
                        (element) {
                          if (!syncColorNames.contains(element.colorOption)) {
                            syncColorImagesFromListing.add(element);
                          }
                        },
                      );

                      state
                          .cachedProductWithoutRelatedProductsModel[
                              productItem?.productId.toString()]!
                          .product
                          ?.colors
                          ?.forEach(
                        (element) {
                          if (!(syncColorNames.contains(element.name))) {
                            colorsFromListing.add(element);
                          }
                        },
                      );
                    }
                    if (state
                            .getProductDetailWithoutSimilarRelatedProductsStatus ==
                        GetProductDetailWithoutSimilarRelatedProductsStatus
                            .loading) {
                      return Container(
                        height: 120.h, // ارتفاع الـ panel المغلقة
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle Bar (شريط الإغلاق)
                            Container(
                              margin: EdgeInsets.only(top: 7.h),
                              child: Container(
                                width: 25.w,
                                height: 3.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                            // Bottom Action Bar (شريط الإجراءات السفلي)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side - Add to Bag Button
                                    Container(
                                      width: 100.w,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Shopping Bag Icon
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor: Colors.grey.shade50,
                                            child: SvgPicture.asset(
                                              AppAssets.bagSvg,
                                              height: 30.h,
                                              width: 30.w,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 5.h),
                                          // "Add To Bag" Text
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor: Colors.grey.shade50,
                                            child: Container(
                                              width: 60.w,
                                              height: 10.h,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(2.r),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 30.w),
                                    // Right side - Action Icons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Heart Icon (Like)
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: SvgPicture.asset(
                                                AppAssets.favoriteSvg,
                                                height: 30.h,
                                                width: 30.w,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: Container(
                                                width: 15.w,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 35.w),
                                        // Chat Bubble Icon
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: SvgPicture.asset(
                                                AppAssets.chatMarkSvg,
                                                height: 30.h,
                                                width: 30.w,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: Container(
                                                width: 15.w,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 35.w),
                                        // Share Icon
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: SvgPicture.asset(
                                                AppAssets.shareSvg,
                                                height: 30.h,
                                                width: 30.w,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade50,
                                              child: Container(
                                                width: 15.w,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 35.w),
                                        // More Options Icon
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade50,
                                          child: SvgPicture.asset(
                                            AppAssets.moreOptionSvg,
                                            height: 30.h,
                                            width: 30.w,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ValueListenableBuilder<bool>(
                        valueListenable: visibleRedeem,
                        builder: (context, _visibleRedeem, _) {
                          return ProductDetailsBottomSheet(
                            isRedeem: (prefsRepository
                                            .getRedeemDateForProduct(
                                                productItem!.productId
                                                    .toString())
                                            ?.isAfter(DateTime.now()
                                                .add(Duration(seconds: 1))) ==
                                        true &&
                                    state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]
                                            ?.product
                                            ?.isRedeem ==
                                        true) ||
                                (GetIt.I<PrefsRepository>()
                                            .getRedeemSecondRemainingForProduct(
                                                (productItem?.productId ?? 0)
                                                    .toString()) ??
                                        0) >
                                    0,
                            redeemPrice: state
                                            .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()] !=
                                    null
                                ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product !=
                                        null
                                    ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product!
                                            .redeemPrice ??
                                        0
                                    : 0
                                : 0,
                            redeemVariantPrice: (currentVariation
                                        ?.redeemPrice !=
                                    null)
                                ? currentVariation?.redeemPrice ?? 0
                                : state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem?.productId.toString()]
                                        ?.product
                                        ?.redeemPrice ??
                                    0,
                            initOfferPrice: (state
                                            .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()] !=
                                    null
                                ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product !=
                                        null
                                    ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product!
                                            .offerPrice ??
                                        0
                                    : 0
                                : 0),
                            initPrice: (state
                                            .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()] !=
                                    null
                                ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product !=
                                        null
                                    ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem?.productId
                                                    .toString()]!
                                            .product!
                                            .price ??
                                        0
                                    : 0
                                : 0),
                            isGetFullProductDetails: widget.productItem == null,
                            currentSelectedColorAfterChangeVariant:
                                currentSelectedColorAfterChangeVariant,
                            productNotAvailableNotifier:
                                productNotAvailableNotifier,
                            currentActiveTab: currentActiveTab,
                            qtyForproductWithoutVariant: widget.productItem ==
                                    null
                                ? productItem?.availableQuantity
                                : state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()]
                                    ?.product
                                    ?.availableQuantity,
                            collectedAfterOrdering: widget.productItem == null
                                ? productItem?.collectedAfterOrdering == 1
                                : state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem!.productId.toString()]
                                        ?.product
                                        ?.collectedAfterOrdering ==
                                    1,
                            productIdForCashData: productId,
                            panelController: panelControllerForCart,
                            productSlugForTopic: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()]
                                    ?.product
                                    ?.slug ??
                                "",
                            productDescription:
                                HtmlParser.parseHTML(productItem!.details ?? "")
                                    .text,
                            countOfPieces: state
                                            .cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()] !=
                                    null
                                ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]!
                                            .product !=
                                        null
                                    ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]!
                                            .product!
                                            .countOfPieces ??
                                        0
                                    : 0
                                : 0,
                            addToBagButtonShapeNotifier:
                                addToBagButtonShapeNotifier,
                            currentColornum: productItem!.colors.isNullOrEmpty
                                ? ''
                                : productItem!
                                        .colors![currentSelectedColor].color ??
                                    "",
                            boutiqueIcon: state.cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()] !=
                                    null
                                ? state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]!.product !=
                                        null
                                    ? state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product!
                                                .boutique !=
                                            null
                                        ? state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        productItem!.productId
                                                            .toString()]!
                                                    .product!
                                                    .boutique!
                                                    .icon !=
                                                null
                                            ? state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]!
                                                    .product!
                                                    .boutique!
                                                    .icon!
                                                    .filePath ??
                                                ""
                                            : ""
                                        : ""
                                    : ""
                                : "",
                            boutiqueId: state
                                            .cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()] !=
                                    null
                                ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]!
                                            .product !=
                                        null
                                    ? state
                                                .cachedProductWithoutRelatedProductsModel[
                                                    productItem!.productId
                                                        .toString()]!
                                                .product!
                                                .boutique !=
                                            null
                                        ? state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem!.productId
                                                    .toString()]!
                                            .product!
                                            .boutique!
                                            .id!
                                        : 0
                                    : 0
                                : 0,
                            currentColorName: productItem!.colors.isNullOrEmpty
                                ? ''
                                : productItem!
                                        .colors![currentSelectedColor].name ??
                                    "",
                            currentColorOption:
                                productItem!.colors.isNullOrEmpty
                                    ? ''
                                    : productItem!.colors![currentSelectedColor]
                                            .option ??
                                        productItem!
                                            .colors![currentSelectedColor]
                                            .option ??
                                        "",
                            productItem: productItem!.copyWith(
                                availableQuantity: state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()] == null
                                    ? 0
                                    : state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem?.productId.toString()]!
                                        .product
                                        ?.availableQuantity,
                                choiceOptions: state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()] == null
                                    ? []
                                    : state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem?.productId.toString()]!
                                        .product
                                        ?.choiceOptions,
                                colors: colorsFromListing,
                                images: state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()] ==
                                        null
                                    ? []
                                    : state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem?.productId.toString()]!
                                        .product
                                        ?.images,
                                syncColorImages: syncColorImagesFromListing,
                                productId: int.tryParse(productId),
                                price: (currentVariation?.price != null) ? currentVariation?.price : state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]?.product?.price,
                                offerPrice: currentVariation?.offerPrice != null ? currentVariation?.offerPrice : state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]?.product?.offerPrice,
                                priceFormatted: currentVariation?.priceFormated != null ? currentVariation?.priceFormated : state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]?.product?.priceFormatted,
                                offerPriceFormatted: currentVariation?.offerPriceFormated != null ? currentVariation?.offerPriceFormated : state.cachedProductWithoutRelatedProductsModel[productItem?.productId.toString()]?.product?.offerPriceFormatted),
                            currentColor: currentSelectedColor,
                            maxAllowedToAddCart: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem!.productId.toString()]
                                    ?.product
                                    ?.maxAllowedQty ??
                                "0",
                          );
                        });
                  },
                );
              },
            ),
            SlidingUpPanelForBuyersCameraShots(
                panelController: panelControllerForBuyersCameraShots,
                panelControllerForReels: panelControllerForReels),
            SlidingUpPanelForReels(panelController: panelControllerForReels),
          ],
        ),
      ),
    );
  }

  void changeVariationWhenNotAvailable(
      {required Variation? currentVariation,
      required String productId,
      required String productSlug,
      required List<Variation> variation}) async {
    if (!widget.fromNotification &&
        !widget.fromNotificationComment &&
        !(widget.fromCart ?? false) &&
        (changeVariationIfQtyZero ?? false) &&
        currentVariation?.qty != null &&
        currentVariation?.qty == 0) {
      if (currentVariation!.type!.contains("-")) {
        currentVariation = variation.firstWhere(
            (element) =>
                (element.qty ?? 0) > 0 &&
                (element.type!.split("-").toList()[0] ==
                    currentVariation?.type!.split("-").toList()[0]),
            orElse: () =>
                variation.firstWhere((element) => (element.qty ?? 0) > 0,
                    orElse: () => currentVariation!) ??
                currentVariation!);
        int index = productItem?.syncColorImages?.indexWhere((element) =>
                element.colorOption ==
                (currentVariation!.type!.split("-").toList()[0])) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productSlug: productSlug)));

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: productItem?.choiceOptions?[0].options
                    ?.firstWhere((element) =>
                        element.option ==
                        (currentVariation!.type!.split("-").toList()[1]))
                    .name,
                choiceOption:
                    (currentVariation!.type!.split("-").toList()[1]))));
      } else if ((productItem?.syncColorImages?.length ?? 0) > 0) {
        currentVariation = variation.firstWhere(
            (element) => ((element.qty ?? 0) > 0 &&
                element.type == currentVariation?.type),
            orElse: () =>
                variation.firstWhere((element) => (element.qty ?? 0) > 0,
                    orElse: () => currentVariation!) ??
                currentVariation!);
        int index = productItem?.syncColorImages?.indexWhere(
                (element) => element.colorOption == (currentVariation!.type)) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;
        print(
            "DFDFEDFEWFEFEFEWFEWF++++.........******//////${currentSelectedColorAfterChangeVariant}");

        await Future.delayed(
            Duration(milliseconds: 50),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productSlug: productSlug)));
      } else {
        currentSelectedColorAfterChangeVariant = currentSelectedColor;
        currentVariation = variation.firstWhere(
            (element) => (element.qty ?? 0) > 0,
            orElse: () => currentVariation!);
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: productItem?.choiceOptions?[0].options
                    ?.firstWhere(
                        (element) => element.option == (currentVariation!.type))
                    .name,
                choiceOption: (currentVariation!.type))));
      }
    } else {
      if ((currentVariation?.type ?? "").contains("-")) {
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: productItem?.choiceOptions?[0].options
                    ?.firstWhere((element) =>
                        element.option ==
                        (currentVariation!.type!.split("-").toList()[1]))
                    .name,
                choiceOption:
                    (currentVariation!.type!.split("-").toList()[1]))));
      } else if (((productItem?.syncColorImages?.length ?? 0) == 0)) {
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: productItem?.choiceOptions?.length == 0
                    ? ""
                    : productItem?.choiceOptions?[0].options
                        ?.firstWhere((element) =>
                            element.option == (currentVariation!.type))
                        .name,
                choiceOption: currentVariation!.type)));
      }

      currentSelectedColorAfterChangeVariant = currentSelectedColor;
    }

    await Future.delayed(
        Duration(seconds: 1),
        () => homeBloc.add(IsChangedVariationWhenQtyZeroEvent(
            isChangedVariationWhenQtyZero: true)));
  }
}
