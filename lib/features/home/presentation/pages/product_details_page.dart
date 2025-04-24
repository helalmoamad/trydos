import 'dart:math';

import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/base_page.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_elvated_button.dart';
import 'package:trydos/features/app/app_widgets/app_bottom_navigation_bar.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/authentication/presentation/pages/first_registeration_page.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_display_pictures_page.dart';
import 'package:trydos/features/home/presentation/pages/cart_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/display_sizes_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/features/home/presentation/widgets/product_stories_section/story/widget/stories_list.dart';
import 'package:trydos/main.dart';
import 'package:trydos/routes/router.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_executed_event_name.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../service/language_service.dart';

import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../chat/presentation/manager/chat_bloc.dart';
import '../../../chat/presentation/manager/chat_event.dart';
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
  bool isChangedvariationWhenQtyZeroForFirst = false;
  final ValueNotifier<String?> productNotAvailableNotifier =
      ValueNotifier(null);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? changeVariationIfQtyZero;
  bool showDialogToResetSession = true;

  int currentSelectedColor = -1;
  int currentSelectedColorAfterChangeVariant = -1;
  @override
  void initState() {
    changeVariationIfQtyZero = true;
    if (widget.productItem != null) {
      productItem = widget.productItem!;
    }

    homeBloc = BlocProvider.of<HomeBloc>(context);
    initialColor = homeBloc.state.currentSelectedColorForEveryProduct[
            widget.productItem?.productId.toString()] ??
        -1;
    homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
        isChangedvariationWhenQtyZero: false));

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

  @override
  void didChangeDependencies() {
    // context.go(GRouter.config.kRootRoute);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.surface,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    FirebaseAnalyticsService.logScreen(
      screen: AnalyticsScreensConst.productDetailsScreen,
    );
    super.didChangeDependencies();
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
                productId: widget.productItem!.productId.toString()));
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
                      if (widget.productItem != null && initialColor != -1) {
                        homeBloc.add(AddCurrentSelectedColorEvent(
                            currentSelectedColor: initialColor ?? 0,
                            productId:
                                widget.productItem!.productId.toString()));
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
                                    BlocProvider.of<HomeBloc>(context).add(
                                        GetFullProductDetailsEvent(
                                            productSlug: widget
                                                    .productSlugForOpeningChatDirectly ??
                                                "",
                                            productId: widget
                                                .productIdForOpeningChatDirectly));
                                  }
                                },
                              );
                            }
                            int qtyItemsInCart = 0;
                            state.cartCollection?.forEach(
                              (element) {
                                qtyItemsInCart =
                                    qtyItemsInCart + (element.quantity ?? 0);
                              },
                            );
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
                                    FirebaseAnalyticsService.logEventForSession(
                                      eventName:
                                          AnalyticsEventsConst.buttonClicked,
                                      executedEventName:
                                          AnalyticsExecutedEventNameConst
                                              .showShoppingBagButton,
                                    );
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
                      return Center(
                        child: TrydosLoader(),
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
                        p.currentSelectedColorForEveryProduct !=
                            c.currentSelectedColorForEveryProduct ||
                        p.cachedProductWithoutRelatedProductsModel !=
                            c.cachedProductWithoutRelatedProductsModel,
                    builder: (context, state) {
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
                        homeBloc.add(AddCurrentColorSizeEvent(choice_1: null));
                      }

                      int currentSelectedColor = state
                              .currentSelectedColorForEveryProduct[productId] ??
                          (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                      if (currentSelectedColor >
                          (productItem?.syncColorImages?.length ?? 0)) {
                        currentSelectedColor = 0;
                      }
                      print(
                          "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR${currentSelectedColor}");
                      Future.delayed(
                        Duration(milliseconds: 600),
                        () {
                          homeBloc.add(AddSizesForColorsEvent(
                              currentColorName:
                                  !productItem!.colors.isNullOrEmpty
                                      ? productItem!
                                              .colors![currentSelectedColor]
                                              .name ??
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

                      return ScrollConfiguration(
                        behavior: const CupertinoScrollBehavior(),
                        child: ListView(
                          shrinkWrap: true,
                          controller: scrollController,
                          physics: enable
                              ? const ClampingScrollPhysics()
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
                                                    ? productItem!.images ?? []
                                                    : productItem!
                                                            .syncColorImages![
                                                                currentSelectedColor]
                                                            .images ??
                                                        [],
                                              ),
                                            );
                                            //////////////////////////////
                                            FirebaseAnalyticsService
                                                .logEventForSession(
                                              eventName: AnalyticsEventsConst
                                                  .buttonClicked,
                                              executedEventName:
                                                  AnalyticsExecutedEventNameConst
                                                      .showProductPhotosButton,
                                            );
                                          },
                                          child: ProductDetailsImageWidget(
                                            height: 464,
                                            width: 320,
                                            orginalHeight: productItem!
                                                    .syncColorImages
                                                    .isNullOrEmpty
                                                ? double.parse(productItem!
                                                    .images![index]
                                                    .originalHeight!)
                                                : double.parse(productItem!
                                                    .syncColorImages![
                                                        currentSelectedColor]
                                                    .images![index]
                                                    .originalHeight!),
                                            orginalWidth: productItem!
                                                    .syncColorImages
                                                    .isNullOrEmpty
                                                ? double.parse(productItem!
                                                    .images![index]
                                                    .originalWidth!)
                                                : double.parse(productItem!
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
                              orginalHeight: double.parse(
                                  productItem!.thumbnail!.originalHeight!),
                              orginalWidth: double.parse(
                                  productItem!.thumbnail!.originalWidth!),
                              brand: productItem!.brand,
                              productName: productItem!.name ?? "",
                              thumbnail: (!productItem!
                                          .syncColorImages.isNullOrEmpty &&
                                      !productItem!.syncColorImages![0].images
                                          .isNullOrEmpty)
                                  ? (productItem!
                                          .syncColorImages![
                                              currentSelectedColor]
                                          .images![0]
                                          .filePath ??
                                      widget.productItem?.thumbnail?.filePath ??
                                      "")
                                  : widget.productItem?.thumbnail?.filePath ??
                                      "",
                              colorName:
                                  !productItem!.syncColorImages.isNullOrEmpty &&
                                          !productItem!.syncColorImages![0]
                                              .images.isNullOrEmpty
                                      ? productItem!
                                              .syncColorImages![
                                                  currentSelectedColor]
                                              .colorName ??
                                          " "
                                      : " ",
                            ),

                            if (!state.cachedProductWithoutRelatedProductsModel
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
                            if (!state.cachedProductWithoutRelatedProductsModel
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
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
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
                                              productId: state.cachedProductWithoutRelatedProductsModel[
                                                          productItem?.productId
                                                              .toString()] !=
                                                      null
                                                  ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productItem
                                                                      ?.productId
                                                                      .toString()]!
                                                              .product !=
                                                          null
                                                      ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productItem
                                                                  ?.productId
                                                                  .toString()]!
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
                            if (!state.cachedProductWithoutRelatedProductsModel
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
                                              productId: state.cachedProductWithoutRelatedProductsModel[
                                                          productItem?.productId
                                                              .toString()] !=
                                                      null
                                                  ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productItem
                                                                      ?.productId
                                                                      .toString()]!
                                                              .product !=
                                                          null
                                                      ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productItem
                                                                  ?.productId
                                                                  .toString()]!
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
                              shippingCost: (state
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
                                              .shippingCost ??
                                          0
                                      : 0
                                  : 0),
                              shippingDay:
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
                                                      .shippingDays ??
                                                  0
                                              : 0
                                          : 0)
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
                          GetFullProductDetailsStatus.success ||
                      (state.productContentForStatusOfOpeningProductDetailsDirectly
                                  ?.countryIsRestricted ==
                              true &&
                          state.getFullProductDetailsStatus ==
                              GetFullProductDetailsStatus.success)) {
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
                if (productId == "") {
                  productId = widget.productItem?.productId.toString() ?? '';
                }
                return BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) {
                    return previous.currentSelectedColorForEveryProduct[
                                productId] !=
                            current.currentSelectedColorForEveryProduct[
                                productId] ||
                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            current
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        previous.changeSizesForEveryProduct !=
                            current.changeSizesForEveryProduct ||
                        previous.currentColorSizeForCart?["size"] !=
                            current.currentColorSizeForCart?["size"];
                  },
                  builder: (context, state) {
                    currentSelectedColor =
                        state.currentSelectedColorForEveryProduct[productId] ??
                            (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                    String currentSelectedColorName =
                        ((productItem?.colors?.length ?? 0) > 0)
                            ? productItem!.colors![currentSelectedColor].name ??
                                ""
                            : "";

                    String currentVariantType =
                        "${currentSelectedColorName != "" ? currentSelectedColorName : ""}" +
                            "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") && (currentSelectedColorName != "") ? "-" : ""}" +
                            "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") ? "${state.currentColorSizeForCart?["size"]}" : ""}";

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
                                product: state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem?.productId.toString()]
                                    ?.product,
                                productId: productId);
                            changeVariationIfQtyZero = false;
                          }
                        },
                      );
                    }

                    return ProductDetailsBottomSheet(
                      isGetFullProductDetails: widget.productItem == null,
                      currentSelectedColorAfterChangeVariant:
                          currentSelectedColorAfterChangeVariant,
                      productNotAvailableNotifier: productNotAvailableNotifier,
                      currentActiveTab: currentActiveTab,
                      qtyForproductWithoutVariant: widget.productItem == null
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
                      productIdForCashData:
                          widget.productIdForOpeningChatDirectly ??
                              widget.productItem!.productId.toString(),
                      panelController: panelControllerForCart,
                      productSlugForTopic: state
                              .cachedProductWithoutRelatedProductsModel[
                                  productItem!.productId.toString()]
                              ?.product
                              ?.slugEnTopic ??
                          "",
                      productDescription:
                          HtmlParser.parseHTML(productItem!.details ?? "").text,
                      countOfPieces: state
                                      .cachedProductWithoutRelatedProductsModel[
                                  productItem!.productId.toString()] !=
                              null
                          ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem!.productId.toString()]!
                                      .product !=
                                  null
                              ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem!.productId.toString()]!
                                      .product!
                                      .countOfPieces ??
                                  0
                              : 0
                          : 0,
                      addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
                      currentColornum: productItem!.colors.isNullOrEmpty
                          ? ''
                          : productItem!.colors![currentSelectedColor].color ??
                              "",
                      boutiqueIcon: state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()] !=
                              null
                          ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem!.productId.toString()]!
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
                                          productItem!.productId.toString()]!
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
                                          productItem!.productId.toString()]!
                                      .product!
                                      .boutique!
                                      .id!
                                  : 0
                              : 0
                          : 0,
                      currentColorName: productItem!.colors.isNullOrEmpty
                          ? ''
                          : productItem!.colors![currentSelectedColor].name ??
                              "",
                      productItem: productItem!.copyWith(
                          productId: int.tryParse(productId),
                          price: currentVariation?.price != null
                              ? currentVariation?.price
                              : productItem!.price,
                          offerPrice: currentVariation?.offerPrice != null
                              ? currentVariation?.offerPrice
                              : productItem!.offerPrice,
                          priceFormatted:
                              currentVariation?.priceFormated != null
                                  ? currentVariation?.priceFormated
                                  : productItem!.priceFormatted,
                          offerPriceFormatted:
                              currentVariation?.offerPriceFormated != null
                                  ? currentVariation?.offerPriceFormated
                                  : productItem!.offerPriceFormatted),
                      currentColor: currentSelectedColor,
                      maxAllowedToAddCart: state
                              .cachedProductWithoutRelatedProductsModel[
                                  productItem!.productId.toString()]
                              ?.product
                              ?.maxAllowedQty ??
                          "0",
                    );
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
      required Product? product}) async {
    if (!widget.fromNotification &&
        !widget.fromNotificationComment &&
        !(widget.fromCart ?? false) &&
        (changeVariationIfQtyZero ?? false) &&
        currentVariation?.qty != null &&
        currentVariation?.qty == 0) {
      if (currentVariation!.type!.contains("-")) {
        currentVariation = product?.variation?.firstWhere(
            (element) =>
                (element.qty ?? 0) > 0 &&
                (element.type!.split("-").toList()[0] ==
                    currentVariation?.type!.split("-").toList()[0]),
            orElse: () =>
                product.variation
                    ?.firstWhere((element) => (element.qty ?? 0) > 0) ??
                currentVariation!);
        int index = productItem?.syncColorImages?.indexWhere((element) =>
                element.colorName ==
                (currentVariation!.type!.split("-").toList()[0])) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productId: productId)));

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: (currentVariation!.type!.split("-").toList()[1]))));
      } else if ((productItem?.syncColorImages?.length ?? 0) > 0) {
        currentVariation = product?.variation?.firstWhere(
            (element) => ((element.qty ?? 0) > 0 &&
                element.type == currentVariation?.type),
            orElse: () =>
                product.variation
                    ?.firstWhere((element) => (element.qty ?? 0) > 0) ??
                currentVariation!);
        int index = productItem?.syncColorImages?.indexWhere(
                (element) => element.colorName == (currentVariation!.type)) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;

        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentSelectedColorEvent(
                currentSelectedColor: index != -1 ? index : 0,
                productId: productId)));
      } else {
        currentSelectedColorAfterChangeVariant = currentSelectedColor;
        currentVariation = product?.variation?.firstWhere(
            (element) => (element.qty ?? 0) > 0,
            orElse: () => currentVariation!);
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(
                AddCurrentColorSizeEvent(choice_1: (currentVariation!.type))));
      }
    } else {
      if (currentVariation!.type!.contains("-")) {
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(AddCurrentColorSizeEvent(
                choice_1: (currentVariation!.type!.split("-").toList()[1]))));
      } else if (((productItem?.syncColorImages?.length ?? 0) == 0)) {
        await Future.delayed(
            Duration(milliseconds: 300),
            () => homeBloc.add(
                AddCurrentColorSizeEvent(choice_1: currentVariation!.type)));
      }

      currentSelectedColorAfterChangeVariant = currentSelectedColor;
    }
    await Future.delayed(
        Duration(seconds: 1),
        () => homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
            isChangedvariationWhenQtyZero: true)));
  }
}
