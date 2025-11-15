import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/helper/show_message.dart';
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

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';

import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/widgets/insert_phone_tab.dart';
import 'package:trydos/features/authentication/presentation/widgets/verification_methods.dart';
import 'package:trydos/features/authentication/presentation/widgets/verify_otp.dart';

import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/home/data/models/get_allowed_country_model.dart';

import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';

import 'package:trydos/features/home/presentation/pages/product_details_display_pictures_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/buyer_comment.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/buyer_seller.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/buyers_comments_panel.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/buyers_product_rate_panel.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/buyers_seller_panel.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/color_images_panel.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/display_colors_card_new.dart';

import 'package:trydos/features/home/presentation/widgets/product_details_body/display_sizes_card_new.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/globale_info_of_product.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/lable_info_of_product.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_video.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/shipping_delivery_date_panel.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet_new.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_header.dart';

import 'package:trydos/main.dart';

import 'package:trydos/routes/router.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';

import '../../../../common/helper/helper_functions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';

import '../../../../service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import '../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../service/language_service.dart';

import '../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;

import '../manager/homeBloc/home_state.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import '../widgets/product_details_body/product_details_chip_widget.dart';
import '../widgets/product_details_body/product_details_description_widget.dart';
import '../widgets/product_details_body/product_details_image_widget.dart';
import '../widgets/product_details_body/product_shipping_and_delivery.dart';
import '../widgets/product_details_body/sliding_up_panel_for_buyers_camera_shots.dart';
import '../widgets/product_details_body/sliding_up_panel_for_reels.dart';

import '../widgets/product_stories_section/story/widget/stories_list.dart';

import 'dart:async';

// ignore: must_be_immutable
class ProductDetailsPageNew extends StatefulWidget {
  ProductDetailsPageNew({
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
  State<ProductDetailsPageNew> createState() => _ProductDetailsPageNewState();
}

class _ProductDetailsPageNewState extends State<ProductDetailsPageNew> {
  productListingModel.Products? productItem;
  late HomeBloc homeBloc;
  late ChatBloc chatBloc;
  late AppBloc appBloc;
  int? initialColor;

  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  final ValueNotifier<bool> isVerified = ValueNotifier(true);
  final PanelController panelControllerForBuyersCameraShots = PanelController();
  final PanelController panelControllerForReels = PanelController();
  final PanelController panelBuyersComments = PanelController();
  final PanelController panelColorImages = PanelController();
  final PanelController panelBuyersSeller = PanelController();
  final PanelController panelBuyersProductRate = PanelController();
  final PanelController panelShippingDeliveryDate = PanelController();
  final PanelController panelControllerForCart = PanelController();
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> visibleSizeAndColorCard = ValueNotifier(false);
  final ValueNotifier<bool> visibleRedeem = ValueNotifier(false);
  final ValueNotifier<bool> showShadowForPanel = ValueNotifier(false);
  final ValueNotifier<bool> visibleVedio = ValueNotifier(true);
  final ValueNotifier<bool> visibleFlashDeal = ValueNotifier(false);
  final ValueNotifier<String> currentFilterForCommend = ValueNotifier("all");
  final PageController pageController = PageController();
  bool isChangedvariationWhenQtyZeroForFirst = false;
  final ValueNotifier<String?> productNotAvailableNotifier = ValueNotifier(
    null,
  );
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  bool? changeVariationIfQtyZero;

  bool getAllDataForProductForFirst = true;
  bool changeAppearSizeForProduct = true;
  int currentSelectedColor = 0;
  int currentSelectedColorAfterChangeVariant = -1;
  List<String> productSlugToOnVoideo = [];
  final FocusNode focusNode = FocusNode();
  Timer? _analyticsTimer;
  String currentVariantType = "";
  @override
  void initState() {
    LastPagesTracker.push(
      "Product Details Page , Product Name:${widget.productItem?.name}",
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        videoProductInListingController.forEach((key, value) {
          if (value.value.isPlaying) {
            value.pause();
            productSlugToOnVoideo.add(key);
          }
        });
      } catch (e) {} // آمن هنا
    });

    changeVariationIfQtyZero = true;
    if (widget.productItem != null) {
      productItem = widget.productItem!;
    }

    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(AddCurrentColorSizeEvent());
    productIdToSaveRedeemTimer.remove(productItem?.productId.toString());

    initialColor =
        homeBloc.state.currentSelectedColorForEveryProduct[widget
            .productItem
            ?.slug
            .toString()] ??
        -1;
    currentSelectedColor =
        homeBloc.state.currentSelectedColorForEveryProduct[widget
            .productItem
            ?.slug
            .toString()] ??
        0;
    homeBloc.add(
      const IsChangedVariationWhenQtyZeroEvent(
        finishLoadingAfterChangedVariationWhenQtyZero: false,
        isChangedVariationWhenQtyZero: false,
      ),
    );

    chatBloc = BlocProvider.of<ChatBloc>(context);
    appBloc = BlocProvider.of<AppBloc>(context);
    appBloc.add(IsFromNotificationByForGround(widget.fromNotification));
    if (widget.productItem != null) {
      homeBloc.add(
        GetProductDatailsWithoutRelatedProductsEvent(
          productSlug: productItem?.slug,
          currentColorOption:
              (productItem!.syncColorImages.isNullOrEmpty || initialColor == -1)
              ? ""
              : productItem!.syncColorImages![initialColor!].colorName,
          productId: productItem?.productId.toString(),
        ),
      );
    }

    // Timer لإرسال الحدث كل 20 ثانية

    FirebaseAnalyticsService.logEventForSession(
      executedEventName: GlobalScreenConst.PRODUCT_SCREEN,
      eventName: AnalyticsEventsConst.SCREEN_VIEW,
      extraParams: {
        'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
        'screen_path': '',
        'platform': GlobalPlatform.MOBILE,
      },
    );

    super.initState();
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    // context.go(GRouter.config.kRootRoute);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
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
    _analyticsTimer?.cancel();
    if (!(productItem == null || widget.productItem != null)) {
      late DateTime _endTime;
      final now = DateTime.now();
      final prefs = GetIt.I<PrefsRepository>();
      int? savedSeconds = prefs.getRedeemSecondRemainingForProduct(
        productItem!.productId.toString(),
      );
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
        productItem!.productId.toString(),
        secondsToSave,
      );
      //  homeBloc.add(AddProductIdToSaveRedeemTimerEvent(
      //      on: true, productIdToSaveRedeemTimer: productIdToSaveRedeemTimer));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () {
        try {
          if (widget.fromCart ?? false) {
            homeBloc.add(const GetCartItemEvent());
          }
          if (panelControllerForCart.isPanelOpen) {
            panelControllerForCart.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (panelBuyersComments.isPanelOpen) {
            panelBuyersComments.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (panelColorImages.isPanelOpen) {
            panelColorImages.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (panelBuyersSeller.isPanelOpen) {
            panelBuyersSeller.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (panelBuyersProductRate.isPanelOpen) {
            panelBuyersProductRate.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (panelShippingDeliveryDate.isPanelOpen) {
            panelShippingDeliveryDate.close();
            currentActiveTab.value = 0;
            return Future.value(false);
          }
          if (widget.fromNotification) {
            context.go(GRouter.config.kRootRoute);

            return Future.value(false);
          }
        } catch (e) {}

        try {
          productSlugToOnVoideo.forEach((key) {
            Future.delayed(
              const Duration(milliseconds: 300),
              () => videoProductInListingController[key]?.play(),
            );
          });
        } catch (e) {}
        if (Navigator.of(context).canPop()) {
          if (widget.productItem != null && initialColor != -1) {
            homeBloc.add(
              AddCurrentSelectedColorEvent(
                currentSelectedColor: initialColor ?? 0,
                productSlug: widget.productItem!.slug.toString(),
              ),
            );
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
                  backgroundColor: Colors.white,
                  onBack: () {
                    try {
                      productSlugToOnVoideo.forEach((key) {
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          () => videoProductInListingController[key]?.play(),
                        );
                      });
                    } catch (e) {}

                    if (widget.productItem != null && initialColor != -1) {
                      homeBloc.add(
                        AddCurrentSelectedColorEvent(
                          currentSelectedColor: initialColor ?? 0,
                          productSlug: widget.productItem!.slug.toString(),
                        ),
                      );
                    }
                  },
                  scrolledUnderElevation: 0,
                  backIconColor: Colors.black,
                  action: appBarActionList(),
                ),
              ),
              backgroundColor: Colors.white,
              body: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) =>
                    p.getFullProductDetailsStatus !=
                    c.getFullProductDetailsStatus,
                builder: (context, state) {
                  if (widget.productItem == null) {
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.loading) {
                      return productDetailsLoading();
                    }
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.failure) {
                      return Center(
                        child: Text(
                          "${LocaleKeys.failed_to_get_product_details.tr()}",
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            fontSize: 12.sp,
                            color: const Color(0xff8D8D8D),
                            letterSpacing: 0.18,
                            height: 1.4,
                          ),
                        ),
                      );
                    }
                    if (state.getFullProductDetailsStatus ==
                        GetFullProductDetailsStatus.success) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      });
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
                            c.getProductDetailWithoutSimilarRelatedProductsStatus ||
                        p.authProductDetailsStatus !=
                            c.authProductDetailsStatus ||
                        p.currentSelectedColorForEveryProduct[productItem?.slug
                                .toString()] !=
                            c.currentSelectedColorForEveryProduct[productItem
                                ?.slug
                                .toString()] ||
                        p.cachedProductWithoutRelatedProductsModel !=
                            c.cachedProductWithoutRelatedProductsModel,
                    builder: (context, state) {
                      if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          getAllDataForProductForFirst &&
                          state.authProductDetailsStatus ==
                              AuthProductDetailsStatus.success) {
                        if (state
                                .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()] !=
                            null) {
                          if (state
                                  .cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()]!
                                  .product !=
                              null) {
                            if (productItem != null) {
                              List<String> syncColorNames = [];
                              List<productListingModel.SyncColorImageProduct>
                              syncColorImagesFromListing =
                                  widget.productItem?.syncColorImages ?? [];

                              for (
                                var i = 0;
                                i <
                                    (widget
                                            .productItem
                                            ?.syncColorImages
                                            ?.length ??
                                        0);
                                i++
                              ) {
                                syncColorNames.add(
                                  widget
                                          .productItem
                                          ?.syncColorImages?[i]
                                          .colorName ??
                                      "",
                                );
                              }
                              state
                                  .cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()]!
                                  .product
                                  ?.syncColorImages
                                  ?.forEach((element) {
                                    if (!syncColorNames.contains(
                                      element.colorOption,
                                    )) {
                                      syncColorImagesFromListing.add(element);
                                    }
                                  });
                              List<productListingModel.ProductColor>?
                              colorsFromListing =
                                  widget.productItem?.colors ?? [];
                              state
                                  .cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()]!
                                  .product
                                  ?.colors
                                  ?.forEach((element) {
                                    if (!(syncColorNames.contains(
                                      element.name,
                                    ))) {
                                      colorsFromListing.add(element);
                                    }
                                  });
                              productItem = productItem!.copyWith(
                                collectedAfterOrdering: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.collectedAfterOrdering,
                                ownerId: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.ownerId,
                                ownerType: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.ownerType,
                                countOfPieces: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.countOfPieces,
                                countOfLikes: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.countOfLikes,
                                deliveryAt: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.deliveryAt,
                                countryIsRestricted: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.countryIsRestricted,
                                isActive: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.isActive,
                                leftStock: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.leftStock,
                                isProductNotifiedForUser: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.isProductNotifiedForUser,
                                price: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.price,
                                offerPrice: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.offerPrice,
                                offerPriceFormatted: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.offerPriceFormatted,
                                priceFormatted: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.priceFormatted,
                                availableQuantity: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.availableQuantity,
                                choiceOptions: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.choiceOptions,
                                colors: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.colors,
                                images: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.images,
                                syncColorImages: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.syncColorImages,
                              );
                              Future.delayed(
                                const Duration(milliseconds: 100),
                              ).then((value) {
                                FirebaseAnalyticsService.logEventForSession(
                                  executedEventName:
                                      AnalyticsButtonsEventNameConst
                                          .VIEW_ITEM_BUTTON,
                                  eventName: AnalyticsEventsConst.viewItem,
                                  extraParams: {
                                    'item_id': productItem!.productId
                                        .toString(),
                                    'item_name': productItem!.name.toString(),
                                    'price': productItem!.price.toString(),
                                    'brand': productItem!.brand == null
                                        ? ""
                                        : productItem!.brand!.name.toString(),
                                    'category': productItem!.categories!
                                        .map((e) => e.id.toString())
                                        .toList()
                                        .toString(),
                                    'count_likes': productItem!.countOfLikes
                                        .toString(),
                                    'review_count': productItem!.reviewsCount
                                        .toString(),
                                    'screen_name':
                                        GlobalScreenConst.PRODUCT_SCREEN,
                                  },
                                );
                              });
                              _analyticsTimer = Timer.periodic(
                                const Duration(seconds: 20),
                                (_) {
                                  FirebaseAnalyticsService.logEventForSession(
                                    executedEventName: "",
                                    eventName:
                                        AnalyticsEventsConst.viewTimeProduct,
                                    extraParams: {
                                      'item_id': productItem!.productId
                                          .toString(),
                                      'item_name': productItem!.name.toString(),
                                      'price': productItem!.price.toString(),
                                      'brand': productItem!.brand == null
                                          ? ""
                                          : productItem!.brand!.name.toString(),
                                      'category': productItem!.categories!
                                          .map((e) => e.id.toString())
                                          .toList()
                                          .toString(),
                                      'count_likes': productItem!.countOfLikes
                                          .toString(),
                                      'review_count': productItem!.reviewsCount
                                          .toString(),
                                      'screen_name':
                                          GlobalScreenConst.PRODUCT_SCREEN,
                                    },
                                  );
                                },
                              );

                              getAllDataForProductForFirst = false;
                            }
                          }
                        }
                      }
                      if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          widget.productSlugForOpeningChatDirectly == null &&
                          state.authProductDetailsStatus ==
                              AuthProductDetailsStatus.success)) {
                        if (state
                                .cachedProductWithoutRelatedProductsModel[widget
                                    .productItem
                                    ?.productId
                                    .toString()]
                                ?.product
                                ?.countryIsRestricted ==
                            true) {
                          productNotAvailableNotifier.value = LocaleKeys
                              .product_is_not_available_in_your_country
                              .tr();
                        } else if (state
                                .cachedProductWithoutRelatedProductsModel[widget
                                    .productItem
                                    ?.productId
                                    .toString()]
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

                      String productId =
                          widget.productIdForOpeningChatDirectly ??
                          (state.cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()] !=
                                  null
                              ? state
                                            .cachedProductWithoutRelatedProductsModel[productItem
                                                ?.productId
                                                .toString()]!
                                            .product !=
                                        null
                                    ? state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product!
                                          .id
                                          .toString()
                                    : ""
                              : "");
                      if (productId == "") {
                        productId =
                            widget.productItem?.productId.toString() ?? '';
                      }
                      String productSlug =
                          widget.productSlugForOpeningChatDirectly ??
                          (state.cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()] !=
                                  null
                              ? state
                                            .cachedProductWithoutRelatedProductsModel[productItem
                                                ?.productId
                                                .toString()]!
                                            .product !=
                                        null
                                    ? state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product!
                                          .slug
                                          .toString()
                                    : ""
                              : "");
                      if (productSlug == "") {
                        productSlug = widget.productItem?.slug.toString() ?? '';
                      }
                      List<String> productCategory = [];
                      if (widget.productItem != null) {
                        productCategory.add(widget.productItem!.name ?? '');
                        productCategory.add(
                          widget.productItem!.categoriesTree ?? '',
                        );
                      }
                      if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          state.authProductDetailsStatus ==
                              AuthProductDetailsStatus.success &&
                          changeAppearSizeForProduct) {
                        changeAppearSizeForProduct = false;
                        if (!state.cachedProductWithoutRelatedProductsModel
                                .containsKey(
                                  productItem!.productId.toString(),
                                ) ||
                            (state.cachedProductWithoutRelatedProductsModel[productItem!
                                        .productId
                                        .toString()] !=
                                    null
                                ? state
                                              .cachedProductWithoutRelatedProductsModel[productItem!
                                                  .productId
                                                  .toString()]!
                                              .product !=
                                          null
                                      ? state
                                            .cachedProductWithoutRelatedProductsModel[productItem!
                                                .productId
                                                .toString()]!
                                            .product!
                                            .choiceOptions
                                            .isNullOrEmpty
                                      : true
                                : true)) {
                          homeBloc.add(AddCurrentColorSizeEvent());
                        } else if (!(state
                                    .cachedProductWithoutRelatedProductsModel[productId] !=
                                null
                            ? state
                                          .cachedProductWithoutRelatedProductsModel[productId]!
                                          .product !=
                                      null
                                  ? state
                                        .cachedProductWithoutRelatedProductsModel[productId]!
                                        .product!
                                        .choiceOptions
                                        .isNullOrEmpty
                                  : true
                            : true)) {
                          String sizeSelect =
                              (state
                                          .cachedProductWithoutRelatedProductsModel[productId]!
                                          .product!
                                          .choiceOptions
                                          ?.length ??
                                      0) ==
                                  0
                              ? ""
                              : state
                                        .cachedProductWithoutRelatedProductsModel[productId]!
                                        .product!
                                        .choiceOptions![0]
                                        .options?[(state
                                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                                    .product
                                                    ?.choiceOptions?[0]
                                                    .options
                                                    ?.length ??
                                                0) ~/
                                            2]
                                        .name ??
                                    "";
                          String sizeOptionSelect =
                              (state
                                          .cachedProductWithoutRelatedProductsModel[productId]!
                                          .product!
                                          .choiceOptions
                                          ?.length ??
                                      0) ==
                                  0
                              ? ""
                              : state
                                        .cachedProductWithoutRelatedProductsModel[productId]!
                                        .product!
                                        .choiceOptions![0]
                                        .options?[(state
                                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                                    .product
                                                    ?.choiceOptions?[0]
                                                    .options
                                                    ?.length ??
                                                0) ~/
                                            2]
                                        .option ??
                                    "";
                          homeBloc.add(
                            AddCurrentColorSizeEvent(
                              choice_1: sizeSelect,
                              choiceOption: sizeOptionSelect,
                            ),
                          );
                        }
                      }
                      if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                  .success &&
                          state.authProductDetailsStatus ==
                              AuthProductDetailsStatus.success) {
                        if (!productItem!.categories.isNullOrEmpty) {
                          productCategory = productItem!.categories!
                              .map((e) => e.name ?? "")
                              .toList();
                        }
                        productCategory.insert(0, productItem!.name ?? "");
                        currentSelectedColor =
                            state
                                .currentSelectedColorForEveryProduct[productSlug] ??
                            (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                        if (currentSelectedColor >
                            (productItem?.syncColorImages?.length ?? 0)) {
                          currentSelectedColor = 0;
                        }
                        Future.delayed(const Duration(milliseconds: 600), () {
                          homeBloc.add(
                            AddSizesForColorsEvent(
                              currentColorName:
                                  !productItem!.colors.isNullOrEmpty
                                  ? productItem!
                                            .colors![currentSelectedColor]
                                            .option ??
                                        ""
                                  : "",
                              variation:
                                  state.authProductDetailsModel?.data != null
                                  ? state
                                        .authProductDetailsModel
                                        ?.data!
                                        .variation
                                  : null,
                            ),
                          );
                        });
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          isChangedvariationWhenQtyZeroForFirst = false;
                          getAllDataForProductForFirst = true;

                          // إعادة تحميل بيانات المنتج
                          if (widget.productItem != null) {
                            homeBloc.add(
                              GetProductDatailsWithoutRelatedProductsEvent(
                                productSlug: productItem?.slug,
                                productId: productItem?.productId.toString(),
                              ),
                            );
                          } else {
                            homeBloc.add(
                              GetFullProductDetailsEvent(
                                productSlug:
                                    widget.productSlugForOpeningChatDirectly ??
                                    "",
                              ),
                            );
                          }
                        },
                        color: Colors.white,
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                        child: ScrollConfiguration(
                          behavior: const CupertinoScrollBehavior(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              productImagesWidget(
                                currentSelectedColor: currentSelectedColor,
                                productItem: productItem,
                                isRedeem:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] !=
                                        null
                                    ? state
                                              .cachedProductWithoutRelatedProductsModel[productItem
                                                  ?.productId
                                                  .toString()]!
                                              .product
                                              ?.isRedeem ==
                                          true
                                    : widget.productItem?.isRedeem == true,
                              ),
                              ProductDetailsTitle(
                                productId: productItem!.productId.toString(),
                                orginalHeight: 0,
                                orginalWidth: 0,
                                brand: productItem!.brand,
                                productName: productCategory.join(' | '),
                                thumbnail:
                                    (!productItem!
                                        .syncColorImages
                                        .isNullOrEmpty)
                                    ? (!productItem!
                                              .syncColorImages![0]
                                              .images
                                              .isNullOrEmpty)
                                          ? (productItem!
                                                    .syncColorImages![currentSelectedColor]
                                                    .images![0]
                                                    .filePath ??
                                                productItem!
                                                    .images?[0]
                                                    .filePath ??
                                                "")
                                          : (productItem!.images![0].filePath ??
                                                "")
                                    : (productItem!.images![0].filePath ?? ""),
                                colorName:
                                    !productItem!
                                            .syncColorImages
                                            .isNullOrEmpty &&
                                        !productItem!
                                            .syncColorImages![0]
                                            .images
                                            .isNullOrEmpty
                                    ? productItem!
                                              .syncColorImages![currentSelectedColor]
                                              .colorName ??
                                          ""
                                    : "",
                              ),

                              if (!state
                                  .cachedProductWithoutRelatedProductsModel
                                  .containsKey(
                                    productItem!.productId.toString(),
                                  )) ...{
                                const SizedBox.shrink(),
                              } else ...{
                                ProductDetailsDescriptionWidget(
                                  description: productItem!.details ?? " ",
                                  productItem: productItem!,
                                ),

                                /*BadgesList(
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
                                ),*/
                              },
                              GlobaleInfoProduct(
                                panelController: panelBuyersProductRate,
                                productId: (productItem?.productId ?? "")
                                    .toString(),
                              ),
                              const lableInfoProduct(),

                              if (!state
                                      .cachedProductWithoutRelatedProductsModel
                                      .containsKey(
                                        productItem!.productId.toString(),
                                      ) ||
                                  (state.cachedProductWithoutRelatedProductsModel[productItem!
                                              .productId
                                              .toString()] !=
                                          null
                                      ? state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()]!
                                                    .product !=
                                                null
                                            ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem!
                                                      .productId
                                                      .toString()]!
                                                  .product!
                                                  .descriptors
                                                  .isNullOrEmpty
                                            : true
                                      : true)) ...{
                                const SizedBox.shrink(),
                              } else ...{
                                SizedBox(
                                  height: 52,
                                  child: ScrollConfiguration(
                                    behavior: const CupertinoScrollBehavior(),
                                    child: ListView.separated(
                                      itemCount: state
                                          .cachedProductWithoutRelatedProductsModel[productItem!
                                              .productId
                                              .toString()]!
                                          .product!
                                          .descriptors!
                                          .length,
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      itemBuilder: (context, index) {
                                        return ProductDetailsChipWidget(
                                          withIcon:
                                              state
                                                  .cachedProductWithoutRelatedProductsModel[productItem!
                                                      .productId
                                                      .toString()]!
                                                  .product!
                                                  .descriptors![index]
                                                  .descriptorGroup!
                                                  .icon !=
                                              null,
                                          descriptor: state
                                              .cachedProductWithoutRelatedProductsModel[productItem!
                                                  .productId
                                                  .toString()]!
                                              .product!
                                              .descriptors![index],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 5);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              },

                              if ((productItem!.syncColorImages?.length ?? 0) >
                                  1) ...{
                                ValueListenableBuilder<bool>(
                                  valueListenable: visibleSizeAndColorCard,
                                  builder: (context, _visibleSizeAndColorCard, _) {
                                    return !_visibleSizeAndColorCard
                                        ? const SizedBox.shrink()
                                        : InkWell(
                                            onTap: () {
                                              LastPagesTracker.push(
                                                "DisplayColorsCardNew Page",
                                              );
                                              panelColorImages.open();
                                            },
                                            child: DisplayColorsCardNew(
                                              productItem: productItem!.copyWith(
                                                syncColorImages: state
                                                    .cachedProductWithoutRelatedProductsModel[productItem
                                                        ?.productId
                                                        .toString()]!
                                                    .product
                                                    ?.syncColorImages,
                                                ownerId: state
                                                    .cachedProductWithoutRelatedProductsModel[productItem
                                                        ?.productId
                                                        .toString()]!
                                                    .product
                                                    ?.ownerId,
                                                ownerType: state
                                                    .cachedProductWithoutRelatedProductsModel[productItem
                                                        ?.productId
                                                        .toString()]!
                                                    .product
                                                    ?.ownerType,
                                                choiceOptions: state
                                                    .cachedProductWithoutRelatedProductsModel[productItem
                                                        ?.productId
                                                        .toString()]!
                                                    .product
                                                    ?.choiceOptions,
                                                colors: state
                                                    .cachedProductWithoutRelatedProductsModel[productItem
                                                        ?.productId
                                                        .toString()]!
                                                    .product
                                                    ?.colors,
                                                productId:
                                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                                            ?.productId
                                                            .toString()] !=
                                                        null
                                                    ? state
                                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                                      ?.productId
                                                                      .toString()]!
                                                                  .product !=
                                                              null
                                                          ? state
                                                                .cachedProductWithoutRelatedProductsModel[productItem
                                                                    ?.productId
                                                                    .toString()]!
                                                                .product!
                                                                .id
                                                          : null
                                                    : null,
                                              ),
                                              currentColorForProduct:
                                                  currentSelectedColor,
                                            ),
                                          );
                                  },
                                ),
                                /*    SizedBox(
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
                                ),*/
                              },
                              ProductShippingAndDelivery(
                                panelController: panelShippingDeliveryDate,
                                countryName:
                                    state
                                        .getAllowedCountriesModel
                                        ?.data
                                        ?.countries
                                        ?.firstWhere(
                                          (element) {
                                            return element.iso!
                                                .toLowerCase()
                                                .contains(
                                                  '${GetIt.I<PrefsRepository>().userCountryIsAvailable == 1 ? GetIt.I<PrefsRepository>().userChoosedCountryIso?.toLowerCase() : GetIt.I<PrefsRepository>().countryIso?.toLowerCase()}',
                                                );
                                          },
                                          orElse: () =>
                                              Country(id: 0, iso: "", name: ""),
                                        )
                                        .name ??
                                    "",
                                shippingCost:
                                    (state.cachedProductWithoutRelatedProductsModel[productItem!
                                            .productId
                                            .toString()] !=
                                        null
                                    ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem!
                                                      .productId
                                                      .toString()]!
                                                  .product !=
                                              null
                                          ? state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()]!
                                                    .product!
                                                    .shippingCost ??
                                                0
                                          : 0
                                    : 0),
                                shippingDay:
                                    ((state.cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()] !=
                                                    null
                                                ? state
                                                              .cachedProductWithoutRelatedProductsModel[productItem!
                                                                  .productId
                                                                  .toString()]!
                                                              .product !=
                                                          null
                                                      ? state
                                                                .cachedProductWithoutRelatedProductsModel[productItem!
                                                                    .productId
                                                                    .toString()]!
                                                                .product!
                                                                .shippingDays ??
                                                            0
                                                      : 0
                                                : 0) +
                                            (state
                                                    .startingSetting
                                                    ?.shippingDay ??
                                                0))
                                        .toString(),
                              ),
                              // ProductStoriesCard(),
                              storySection(),
                              BuyerComment(
                                isVerified: isVerified,
                                panelBuyersComments: panelBuyersComments,
                                ownerId: productItem?.ownerId,
                                ownerType: productItem?.ownerType,
                                productId: (productItem?.productId).toString(),
                              ),
                              BuyerSellerChat(
                                panelBuyersSeller: panelBuyersSeller,
                                isVerified: isVerified,
                                currentVariant: currentVariantType,
                                ownerId: productItem?.ownerId,
                                ownerType: productItem?.ownerType,
                                productId: (productItem?.productId).toString(),
                              ),
                              if (!state
                                      .cachedProductWithoutRelatedProductsModel
                                      .containsKey(
                                        productItem!.productId.toString(),
                                      ) ||
                                  (state.cachedProductWithoutRelatedProductsModel[productItem!
                                              .productId
                                              .toString()] !=
                                          null
                                      ? state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()]!
                                                    .product !=
                                                null
                                            ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem!
                                                      .productId
                                                      .toString()]!
                                                  .product!
                                                  .choiceOptions
                                                  .isNullOrEmpty
                                            : true
                                      : true)) ...{
                                const SizedBox.shrink(),
                              } else ...{
                                ValueListenableBuilder<bool>(
                                  valueListenable: visibleSizeAndColorCard,
                                  builder: (context, _visibleSizeAndColorCard, _) {
                                    return !_visibleSizeAndColorCard
                                        ? const SizedBox.shrink()
                                        : DisplaySizesCardNew(
                                            productItem: productItem!.copyWith(
                                              syncColorImages: state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product
                                                  ?.syncColorImages,
                                              ownerId: state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product
                                                  ?.ownerId,
                                              ownerType: state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product
                                                  ?.ownerType,
                                              choiceOptions: state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product
                                                  ?.choiceOptions,
                                              colors: state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product
                                                  ?.colors,
                                              productId:
                                                  state.cachedProductWithoutRelatedProductsModel[productItem
                                                          ?.productId
                                                          .toString()] !=
                                                      null
                                                  ? state
                                                                .cachedProductWithoutRelatedProductsModel[productItem
                                                                    ?.productId
                                                                    .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                              .cachedProductWithoutRelatedProductsModel[productItem
                                                                  ?.productId
                                                                  .toString()]!
                                                              .product!
                                                              .id
                                                        : null
                                                  : null,
                                            ),
                                            currentColorForProduct:
                                                currentSelectedColor,
                                            variation:
                                                state
                                                        .authProductDetailsModel
                                                        ?.data ==
                                                    null
                                                ? []
                                                : state
                                                      .authProductDetailsModel
                                                      ?.data!
                                                      .variation,
                                          );
                                  },
                                ),
                              },
                              buyerReview(),

                              /*  BuyersCameraShots(
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
                              ),*/
                              SizedBox(height: (2 * 73.5 / (1.sh - 100.h)).sh),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: showShadowForPanel,
              builder: (context, _showShadowForPanel, _) {
                return _showShadowForPanel
                    ? GestureDetector(
                        onTap: () {
                          showShadowForPanel.value = false;
                          currentActiveTab.value = -1;
                          panelControllerForCart.close();
                        },
                        child: Container(
                          height: 1.sh,
                          width: 1.sw,
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.55),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (p, c) =>
                  p.getFullProductDetailsStatus !=
                      c.getFullProductDetailsStatus ||
                  p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                      c.getProductDetailWithoutSimilarRelatedProductsStatus ||
                  p.authProductDetailsStatus != c.authProductDetailsStatus,
              builder: (context, state) {
                if (widget.productItem == null) {
                  if (state.getFullProductDetailsStatus !=
                      GetFullProductDetailsStatus
                          .success /* ||
                      (state.productContentForStatusOfOpeningProductDetailsDirectly
                                  ?.countryIsRestricted ==
                              true &&
                          state.getFullProductDetailsStatus ==
                              GetFullProductDetailsStatus.success)*/ ) {
                    return const SizedBox.shrink();
                  }
                  productItem = state
                      .productContentForStatusOfOpeningProductDetailsDirectly!;
                  Future.delayed(const Duration(seconds: 1), () {
                    if (widget.fromNotificationComment) {
                      LastPagesTracker.push("panelControllerForCart Page");
                      panelControllerForCart.open();
                      currentActiveTab.value = 0;
                      widget.fromNotificationComment = false;
                    }
                  });
                }
                String productId =
                    state.cachedProductWithoutRelatedProductsModel[productItem
                            ?.productId
                            .toString()] !=
                        null
                    ? state
                                  .cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()]!
                                  .product !=
                              null
                          ? state
                                .cachedProductWithoutRelatedProductsModel[productItem
                                    ?.productId
                                    .toString()]!
                                .product!
                                .id
                                .toString()
                          : ""
                    : "";
                String productSlug =
                    state.cachedProductWithoutRelatedProductsModel[productItem
                            ?.productId
                            .toString()] !=
                        null
                    ? state
                                  .cachedProductWithoutRelatedProductsModel[productItem
                                      ?.productId
                                      .toString()]!
                                  .product !=
                              null
                          ? state
                                .cachedProductWithoutRelatedProductsModel[productItem
                                    ?.productId
                                    .toString()]!
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
                    return previous
                                .currentSelectedColorForEveryProduct[productSlug] !=
                            current
                                .currentSelectedColorForEveryProduct[productSlug] ||
                        previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            current
                                .getProductDetailWithoutSimilarRelatedProductsStatus ||
                        previous.authProductDetailsStatus !=
                            current.authProductDetailsStatus ||
                        previous.changeSizesForEveryProduct !=
                            current.changeSizesForEveryProduct ||
                        previous.finishLoadingAfterChangedVariationWhenQtyZero !=
                            current
                                .finishLoadingAfterChangedVariationWhenQtyZero ||
                        previous.currentColorSizeForCart?["choiceOption"] !=
                            current.currentColorSizeForCart?["choiceOption"];
                  },
                  builder: (context, state) {
                    if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                .success &&
                        state.authProductDetailsStatus ==
                            AuthProductDetailsStatus.success) {
                      productItem = productItem!.copyWith(
                        collectedAfterOrdering: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.collectedAfterOrdering,
                        ownerId: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.ownerId,
                        ownerType: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.ownerType,
                        countOfPieces: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.countOfPieces,
                        countOfLikes: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.countOfLikes,
                        deliveryAt: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.deliveryAt,
                        countryIsRestricted: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.countryIsRestricted,
                        isActive: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.isActive,
                        leftStock: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.leftStock,
                        isProductNotifiedForUser: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.isProductNotifiedForUser,
                        price: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.price,
                        offerPrice: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.offerPrice,
                        offerPriceFormatted: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.offerPriceFormatted,
                        priceFormatted: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.priceFormatted,
                        availableQuantity: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.availableQuantity,
                        choiceOptions: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.choiceOptions,
                        colors: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.colors,
                        images: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.images,
                        syncColorImages: state
                            .cachedProductWithoutRelatedProductsModel[productItem
                                ?.productId
                                .toString()]!
                            .product
                            ?.syncColorImages,
                      );
                    }

                    /* if (state
                            .getProductDetailWithoutSimilarRelatedProductsStatus !=
                        GetProductDetailWithoutSimilarRelatedProductsStatus
                            .success) {
                      return SizedBox.shrink();
                    }*/
                    String currentSelectedColorOption = "";
                    Variation? currentVariation;

                    if ((state
                                .cachedProductWithoutRelatedProductsModel[productItem!
                                    .productId
                                    .toString()]
                                ?.product
                                ?.id !=
                            null &&
                        state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                .success &&
                        state.authProductDetailsStatus ==
                            AuthProductDetailsStatus.success)) {
                      currentSelectedColor =
                          state
                              .currentSelectedColorForEveryProduct[productSlug] ??
                          (productItem?.syncColorImages?.length ?? 0) ~/ 2;
                      currentSelectedColorOption =
                          ((productItem?.colors?.length ?? 0) > 0)
                          ? productItem!.colors![currentSelectedColor].option ??
                                ""
                          : "";

                      currentVariantType =
                          "${currentSelectedColorOption != "" ? currentSelectedColorOption : ""}" +
                          "${!(state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? true) && (currentSelectedColorOption != "") ? "-" : ""}" +
                          "${!(state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? true) ? "${(state.currentColorSizeForCart?["choiceOption"] == null || state.currentColorSizeForCart?["choiceOption"] == "") ? state.cachedProductWithoutRelatedProductsModel[productItem!.productId.toString()]?.product?.choiceOptions![0].options![(state.cachedProductWithoutRelatedProductsModel[productId]!.product?.choiceOptions?[0].options?.length ?? 0) ~/ 2].option : state.currentColorSizeForCart?["choiceOption"]}" : ""}";
                      currentVariation = state
                          .authProductDetailsModel
                          ?.data
                          ?.variation
                          ?.firstWhere(
                            (element) =>
                                element.type!.contains(currentVariantType),
                            orElse: () {
                              return Variation(variantNotifyForUser: false);
                            },
                          );

                      Future.delayed(
                        const Duration(milliseconds: 600),
                        () => visibleSizeAndColorCard.value = true,
                      );
                      Future.delayed(const Duration(milliseconds: 1200), () {
                        if (!isChangedvariationWhenQtyZeroForFirst) {
                          isChangedvariationWhenQtyZeroForFirst = true;
                          changeVariationWhenNotAvailable(
                            currentVariation: currentVariation,
                            collectAfterOrder:
                                (state
                                        .cachedProductWithoutRelatedProductsModel[productItem!
                                            .productId
                                            .toString()]
                                        ?.product
                                        ?.collectedAfterOrdering ??
                                    0) ==
                                1,
                            variation:
                                state
                                    .authProductDetailsModel
                                    ?.data
                                    ?.variation ??
                                [],
                            productSlug: productSlug,
                            productId: productId,
                          );
                          changeVariationIfQtyZero = false;
                        }
                      });
                    }

                    if ((state.getProductDetailWithoutSimilarRelatedProductsStatus !=
                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                .success ||
                        state.authProductDetailsStatus !=
                            AuthProductDetailsStatus.success)) {
                      if (productItem != null) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: visibleRedeem,
                          builder: (context, _visibleRedeem, _) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: visibleFlashDeal,
                              builder: (context, _visibleFlashDeal, _) {
                                DateTime endDate;

                                try {
                                  endDate = DateFormat(
                                    'MM/dd/yyyy',
                                    'en_US',
                                  ).parse(productItem?.flashDealEndDate ?? "");
                                  endDate = endDate.add(
                                    const Duration(days: 1),
                                  );
                                } catch (e) {
                                  endDate = DateTime.now();
                                  print('Error parsing date: $e');
                                }

                                return Container(
                                  height: 80, // ارتفاع الـ panel المغلقة
                                  child: ProductDetailsSheetHeader(
                                    redeemVariantPrice:
                                        (productItem!.redeemPrice ?? 0) *
                                        state
                                            .getCurrencyForCountryModel!
                                            .data!
                                            .currency!
                                            .exchangeRate!,
                                    currentVariant: currentVariantType,
                                    isRedeem:
                                        (prefsRepository
                                                    .getRedeemDateForProduct(
                                                      productItem!.productId
                                                          .toString(),
                                                    )
                                                    ?.isAfter(
                                                      DateTime.now().add(
                                                        const Duration(
                                                          seconds: 1,
                                                        ),
                                                      ),
                                                    ) ==
                                                true &&
                                            state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()]
                                                    ?.product
                                                    ?.isRedeem ==
                                                true) ||
                                        (GetIt.I<PrefsRepository>()
                                                    .getRedeemSecondRemainingForProduct(
                                                      (productItem?.productId ??
                                                              0)
                                                          .toString(),
                                                    ) ??
                                                0) >
                                            0,
                                    redeemPrice:
                                        (productItem!.redeemPrice ?? 0) *
                                        state
                                            .getCurrencyForCountryModel!
                                            .data!
                                            .currency!
                                            .exchangeRate!,
                                    currentActiveTab: currentActiveTab,
                                    initOfferPrice:
                                        ((productItem!.flashDealStatus == 1
                                                    ? productItem!
                                                              .flashDealPrice ??
                                                          0
                                                    : productItem!.offerPrice ??
                                                          0) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toString(),
                                    initPrice:
                                        ((productItem!.price ?? 0) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toString(),
                                    shippingCost:
                                        productItem!.shippingCost ?? 0,
                                    decimalPoint:
                                        state
                                            .startingSetting
                                            ?.decimalPointSettings ??
                                        2,
                                    priceSymbol:
                                        state
                                            .getCurrencyForCountryModel!
                                            .data!
                                            .currency!
                                            .symbol ??
                                        "",
                                    addToBagButtonShapeNotifier:
                                        addToBagButtonShapeNotifier,
                                    price:
                                        ((productItem!.price ?? 0) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toString(),
                                    offerPrice:
                                        ((productItem!.flashDealStatus == 1
                                                    ? productItem!
                                                              .flashDealPrice ??
                                                          0
                                                    : productItem!.offerPrice ??
                                                          0) *
                                                state
                                                    .getCurrencyForCountryModel!
                                                    .data!
                                                    .currency!
                                                    .exchangeRate!)
                                            .toString(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

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
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side - Add to Bag Button
                                    Container(
                                      width: 100.w,
                                      height: 70.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(
                                          25.r,
                                        ),
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
                                              // ignore: deprecated_member_use
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
                                                // ignore: deprecated_member_use
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
                                                        2.r,
                                                      ),
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
                                                // ignore: deprecated_member_use
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
                                                        2.r,
                                                      ),
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
                                                // ignore: deprecated_member_use
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
                                                        2.r,
                                                      ),
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
                                            // ignore: deprecated_member_use
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
                        return ValueListenableBuilder<bool>(
                          valueListenable: visibleFlashDeal,
                          builder: (context, _visibleFlashDeal, _) {
                            bool isFlashDealEnded = false;
                            DateTime endDate;
                            Duration _duration = const Duration();
                            final now = DateTime.now();
                            try {
                              endDate = DateFormat(
                                'MM/dd/yyyy',
                                'en_US',
                              ).parse(productItem?.flashDealEndDate ?? "");
                              endDate = endDate.add(const Duration(days: 1));
                            } catch (e) {
                              endDate = DateTime.now();
                              print('Error parsing date: $e');
                            }
                            _duration = endDate.difference(now);
                            if (_duration.isNegative ||
                                _duration.inSeconds < 1) {
                              isFlashDealEnded = true;
                            }

                            return ProductDetailsBottomSheetNew(
                              isVerified: isVerified,
                              showShadowForPanel: showShadowForPanel,
                              currentVariant: currentVariantType,
                              visibleRedeemNotifier: visibleRedeem,
                              visibleFlashDeal: visibleFlashDeal,
                              isFlashDealEnded: isFlashDealEnded,
                              flashDealEndDate:
                                  productItem?.flashDealEndDate ?? "",
                              isRedeem:
                                  (prefsRepository
                                              .getRedeemDateForProduct(
                                                productItem!.productId
                                                    .toString(),
                                              )
                                              ?.isAfter(
                                                DateTime.now().add(
                                                  const Duration(seconds: 1),
                                                ),
                                              ) ==
                                          true &&
                                      state
                                              .cachedProductWithoutRelatedProductsModel[productItem!
                                                  .productId
                                                  .toString()]
                                              ?.product
                                              ?.isRedeem ==
                                          true) ||
                                  (GetIt.I<PrefsRepository>()
                                              .getRedeemSecondRemainingForProduct(
                                                (productItem?.productId ?? 0)
                                                    .toString(),
                                              ) ??
                                          0) >
                                      0,
                              redeemPrice:
                                  state.cachedProductWithoutRelatedProductsModel[productItem
                                          ?.productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem
                                                    ?.productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product!
                                                  .redeemPrice ??
                                              0
                                        : 0
                                  : 0,
                              redeemVariantPrice:
                                  (currentVariation?.redeemPrice != null)
                                  ? currentVariation?.redeemPrice ?? 0
                                  : state
                                            .cachedProductWithoutRelatedProductsModel[productItem
                                                ?.productId
                                                .toString()]
                                            ?.product
                                            ?.redeemPrice ??
                                        0,
                              initOfferPrice:
                                  (state.cachedProductWithoutRelatedProductsModel[productItem
                                          ?.productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem
                                                    ?.productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product!
                                                  .offerPrice ??
                                              0
                                        : 0
                                  : 0),
                              initPrice:
                                  (state.cachedProductWithoutRelatedProductsModel[productItem
                                          ?.productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem
                                                    ?.productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem
                                                      ?.productId
                                                      .toString()]!
                                                  .product!
                                                  .price ??
                                              0
                                        : 0
                                  : 0),
                              isGetFullProductDetails:
                                  widget.productItem == null,
                              currentSelectedColorAfterChangeVariant:
                                  currentSelectedColorAfterChangeVariant,
                              productNotAvailableNotifier:
                                  productNotAvailableNotifier,
                              currentActiveTab: currentActiveTab,
                              collectedAfterOrdering: widget.productItem == null
                                  ? productItem?.collectedAfterOrdering == 1
                                  : state
                                            .cachedProductWithoutRelatedProductsModel[productItem!
                                                .productId
                                                .toString()]
                                            ?.product
                                            ?.collectedAfterOrdering ==
                                        1,
                              productIdForCashData: productId,
                              panelController: panelControllerForCart,
                              productSlugForTopic:
                                  state
                                      .cachedProductWithoutRelatedProductsModel[productItem!
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.slug ??
                                  "",
                              productDescription: HtmlParser.parseHTML(
                                productItem!.details ?? "",
                              ).text,
                              countOfPieces:
                                  state.cachedProductWithoutRelatedProductsModel[productItem!
                                          .productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem!
                                                    .productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                  .cachedProductWithoutRelatedProductsModel[productItem!
                                                      .productId
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
                                            .colors![currentSelectedColor]
                                            .color ??
                                        "",
                              boutiqueIcon:
                                  state.cachedProductWithoutRelatedProductsModel[productItem!
                                          .productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem!
                                                    .productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                      .cachedProductWithoutRelatedProductsModel[productItem!
                                                          .productId
                                                          .toString()]!
                                                      .product!
                                                      .boutique !=
                                                  null
                                              ? state
                                                            .cachedProductWithoutRelatedProductsModel[productItem!
                                                                .productId
                                                                .toString()]!
                                                            .product!
                                                            .boutique!
                                                            .icon !=
                                                        null
                                                    ? state
                                                              .cachedProductWithoutRelatedProductsModel[productItem!
                                                                  .productId
                                                                  .toString()]!
                                                              .product!
                                                              .boutique!
                                                              .icon!
                                                              .filePath ??
                                                          ""
                                                    : ""
                                              : ""
                                        : ""
                                  : "",
                              boutiqueId:
                                  state.cachedProductWithoutRelatedProductsModel[productItem!
                                          .productId
                                          .toString()] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productItem!
                                                    .productId
                                                    .toString()]!
                                                .product !=
                                            null
                                        ? state
                                                      .cachedProductWithoutRelatedProductsModel[productItem!
                                                          .productId
                                                          .toString()]!
                                                      .product!
                                                      .boutique !=
                                                  null
                                              ? state
                                                    .cachedProductWithoutRelatedProductsModel[productItem!
                                                        .productId
                                                        .toString()]!
                                                    .product!
                                                    .boutique!
                                                    .id!
                                              : 0
                                        : 0
                                  : 0,
                              currentColorName:
                                  productItem!.colors.isNullOrEmpty
                                  ? ''
                                  : productItem!
                                            .colors![currentSelectedColor]
                                            .name ??
                                        "",
                              currentColorOption:
                                  productItem!.colors.isNullOrEmpty
                                  ? ''
                                  : productItem!
                                            .colors![currentSelectedColor]
                                            .option ??
                                        productItem!
                                            .colors![currentSelectedColor]
                                            .option ??
                                        "",
                              productItem: productItem!.copyWith(
                                availableQuantity:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] ==
                                        null
                                    ? 0
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product
                                          ?.availableQuantity,
                                ownerId: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.ownerId,
                                ownerType: state
                                    .cachedProductWithoutRelatedProductsModel[productItem
                                        ?.productId
                                        .toString()]!
                                    .product
                                    ?.ownerType,
                                choiceOptions:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] ==
                                        null
                                    ? []
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product
                                          ?.choiceOptions,
                                colors:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] ==
                                        null
                                    ? []
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product
                                          ?.colors,
                                images:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] ==
                                        null
                                    ? []
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product
                                          ?.images,
                                syncColorImages:
                                    state.cachedProductWithoutRelatedProductsModel[productItem
                                            ?.productId
                                            .toString()] ==
                                        null
                                    ? []
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]!
                                          .product
                                          ?.syncColorImages,
                                productId: int.tryParse(productId),
                                price: (currentVariation?.price != null)
                                    ? currentVariation?.price
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]
                                          ?.product
                                          ?.price,
                                offerPrice: currentVariation?.offerPrice != null
                                    ? currentVariation?.offerPrice
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]
                                          ?.product
                                          ?.offerPrice,
                                priceFormatted:
                                    currentVariation?.priceFormated != null
                                    ? currentVariation?.priceFormated
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]
                                          ?.product
                                          ?.priceFormatted,
                                offerPriceFormatted:
                                    currentVariation?.offerPriceFormated != null
                                    ? currentVariation?.offerPriceFormated
                                    : state
                                          .cachedProductWithoutRelatedProductsModel[productItem
                                              ?.productId
                                              .toString()]
                                          ?.product
                                          ?.offerPriceFormatted,
                              ),
                              currentColor: currentSelectedColor,
                              maxAllowedToAddCart:
                                  state
                                      .cachedProductWithoutRelatedProductsModel[productItem!
                                          .productId
                                          .toString()]
                                      ?.product
                                      ?.maxAllowedQty ??
                                  "0",
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            SlidingUpPanelForBuyersCameraShots(
              panelController: panelControllerForBuyersCameraShots,
              panelControllerForReels: panelControllerForReels,
            ),
            SlidingUpPanelForReels(panelController: panelControllerForReels),
            BuyersProductRatePanel(
              panelController: panelBuyersProductRate,
              productFirstId: (productItem?.productId ?? "").toString(),
            ),
            BuyersCommentsPanel(
              isVerified: isVerified,
              currentFilterForCommend: currentFilterForCommend,
              panelController: panelBuyersComments,
              productFirstId: (productItem?.productId ?? "").toString(),
            ),
            BuyerSellerPanel(
              isVerified: isVerified,
              currentFilterForCommend: currentFilterForCommend,
              panelController: panelBuyersSeller,
              productFirstId: (productItem?.productId ?? "").toString(),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return previous
                            .getProductDetailWithoutSimilarRelatedProductsStatus !=
                        current
                            .getProductDetailWithoutSimilarRelatedProductsStatus ||
                    previous.getFullProductDetailsStatus !=
                        current.getFullProductDetailsStatus;
              },
              builder: (context, state) {
                String productId =
                    (productItem?.productId ??
                            (state
                                .productContentForStatusOfOpeningProductDetailsDirectly
                                ?.productId))
                        .toString();
                if (state.cachedProductWithoutRelatedProductsModel[productId] ==
                    null) {
                  return const SizedBox.shrink();
                }
                return ShippingDeliveryDatePanel(
                  countryName:
                      state.getAllowedCountriesModel?.data?.countries?.firstWhere((
                        element,
                      ) {
                        return element.iso!.toLowerCase().contains(
                          '${GetIt.I<PrefsRepository>().userCountryIsAvailable == 1 ? GetIt.I<PrefsRepository>().userChoosedCountryIso?.toLowerCase() : GetIt.I<PrefsRepository>().countryIso?.toLowerCase()}',
                        );
                      }, orElse: () => Country(id: 0, iso: "", name: "")).name ??
                      "",
                  shippingCost:
                      (state.cachedProductWithoutRelatedProductsModel[productId] !=
                          null
                      ? state
                                    .cachedProductWithoutRelatedProductsModel[productId]!
                                    .product !=
                                null
                            ? state
                                      .cachedProductWithoutRelatedProductsModel[productId]!
                                      .product!
                                      .shippingCost ??
                                  0
                            : 0
                      : 0),
                  shippingDay:
                      ((state.cachedProductWithoutRelatedProductsModel[productId] !=
                                      null
                                  ? state
                                                .cachedProductWithoutRelatedProductsModel[productId]!
                                                .product !=
                                            null
                                        ? state
                                                  .cachedProductWithoutRelatedProductsModel[productId]!
                                                  .product!
                                                  .shippingDays ??
                                              0
                                        : 0
                                  : 0) +
                              (state.startingSetting?.shippingDay ?? 0))
                          .toString(),
                  panelController: panelShippingDeliveryDate,
                );
              },
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.getFullProductDetailsStatus !=
                      current.getFullProductDetailsStatus ||
                  previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                      current
                          .getProductDetailWithoutSimilarRelatedProductsStatus ||
                  previous.authProductDetailsStatus !=
                      current.authProductDetailsStatus,
              builder: (context, state) => ColorImagesPanel(
                currentActiveTab: currentActiveTab,
                panelControllerForCart: panelControllerForCart,
                productItem:
                    productItem ??
                    state
                        .productContentForStatusOfOpeningProductDetailsDirectly ??
                    productListingModel.Products(
                      isProductNotifiedForUser: false,
                    ),
                visibleRedeem: visibleRedeem,
                panelController: panelColorImages,
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
            ValueListenableBuilder<bool>(
              valueListenable: isVerified,
              builder: (context, _isverified, _) {
                return _isverified ? const SizedBox.shrink() : _veryfiedOtp();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> appBarActionList() {
    return [
      LanguageService.rtl ? const Spacer() : const SizedBox.shrink(),
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 10.0),
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                  current.getProductDetailWithoutSimilarRelatedProductsStatus ||
              previous.authProductDetailsStatus !=
                  current.authProductDetailsStatus ||
              previous.updateItemInCartStatus !=
                  current.updateItemInCartStatus ||
              previous.getCartOverviewStatus != current.getCartOverviewStatus ||
              previous.addItemInCartStatus != current.addItemInCartStatus ||
              previous.deleteItemInCartStatus !=
                  current.deleteItemInCartStatus ||
              previous.getCartItemsStatus != current.getCartItemsStatus,
          builder: (context, state) {
            if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                        GetProductDetailWithoutSimilarRelatedProductsStatus
                            .failure ||
                    state.authProductDetailsStatus ==
                        AuthProductDetailsStatus.failure) &&
                (prefsRepository.isTokenExpired ??
                    false ||
                        prefsRepository.marketToken == "" ||
                        prefsRepository.marketToken == null)) {
              Future.delayed(const Duration(seconds: 5), () {
                if (widget.productItem != null) {
                  homeBloc.add(
                    GetProductDatailsWithoutRelatedProductsEvent(
                      productSlug: productItem?.slug,
                      productId: productItem?.productId.toString(),
                    ),
                  );
                } else {
                  BlocProvider.of<HomeBloc>(context).add(
                    GetFullProductDetailsEvent(
                      productSlug:
                          widget.productSlugForOpeningChatDirectly ?? "",
                    ),
                  );
                }
              });
            }
            int qtyItemsInCart = state.cartCollection?.length ?? 0;
            double totlalPrice =
                ((state.getCartShippingItemsModel?.data?.total ?? 0) -
                    (state.getCartShippingItemsModel?.data?.totalShippingCost ??
                        0)) *
                state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!;
            String priceSymbol =
                state.getCurrencyForCountryModel!.data!.currency!.symbol ?? "";
            (productItem?.syncColorImages?.length ?? 0) ~/ 2;
            return state.getCartOverviewStatus ==
                        GetCartOverviewStatus.loading ||
                    state.updateItemInCartStatus ==
                        UpdateItemInCartStatus.loading ||
                    state.deleteItemInCartStatus ==
                        DeleteItemInCartStatus.loading ||
                    state.addItemInCartStatus == AddItemInCartStatus.loading
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade100,
                        highlightColor: Colors.grey.shade300,
                        child: Container(
                          height: 25.h,
                          width: 75,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SvgPicture.asset(
                        AppAssets.bagsOrderSvg,
                        width: 20,
                        // ignore: deprecated_member_use
                        color: const Color(0xff513AAF),
                      ),
                    ],
                  )
                : Container(
                    alignment: Alignment.center,
                    height: 35,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CartPage(fromeFilters: true),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${qtyItemsInCart.round()} ",
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              fontSize: 13.sp,
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            "${LocaleKeys.item.tr()}",
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              fontSize: 11.sp,
                              color: const Color(0xff8D8D8D),
                              letterSpacing: 0.18,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            " ${HelperFunctions.formatNumber(number: totlalPrice)} ",
                            style: context.textTheme.bodyMedium?.mq.copyWith(
                              fontSize: 13.sp,
                              color: const Color(0xff1D1D1D),
                              letterSpacing: 0.18,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            priceSymbol,
                            style: context.textTheme.bodyMedium?.rq.copyWith(
                              decorationColor: const Color(0xffFEFEFE),
                              fontSize: 11.sp,
                              height: 1.4,
                              color: const Color(0xff8D8D8D),
                            ),
                          ),
                          const SizedBox(width: 5),
                          SvgPicture.asset(
                            AppAssets.bagsOrderSvg,
                            width: 20,
                            // ignore: deprecated_member_use
                            color: const Color(0xff513AAF),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    ];
  }

  Widget storySection() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getStoryWithPagintionStatusLoading !=
              current.getStoryWithPagintionStatusLoading ||
          previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
              current.getProductDetailWithoutSimilarRelatedProductsStatus ||
          previous.getStoriesForProductStatus !=
              current.getStoriesForProductStatus,
      builder: (context, state) {
        return (state.storiesCollections.length) == 0 ||
                state.getStoriesForProductStatus !=
                    GetStoriesForProductStatus.success ||
                state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                    GetProductDetailWithoutSimilarRelatedProductsStatus.loading
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: SvgPicture.asset(AppAssets.productStorySvg),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextWidget(
                          '${LocaleKeys.product_story.tr()}',
                          style: context.textTheme.titleLarge?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          AppAssets.registerInfoSvg,
                          height: 10,
                          width: 10,
                          // ignore: deprecated_member_use
                          color: const Color(0xffC4C2C2),
                        ),
                      ],
                    ),
                  ),
                  const StoriesList(), //
                ],
              );
      },
    );
  }

  Widget productDetailsLoading() {
    return Column(
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
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        height: 450.h,
                        width: 320.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          ),
        ),
        const SizedBox(height: 20),
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
          ),
        ),
        const Spacer(),
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
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side - Add to Bag Button
                      Container(
                        width: 100.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Shopping Bag Icon
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade50,
                              child: SvgPicture.asset(
                                AppAssets.bagSvg,
                                height: 30.h,
                                width: 30.w,
                                // ignore: deprecated_member_use
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
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 30.w),
                      // Right side - Action Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Heart Icon (Like)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: SvgPicture.asset(
                                  AppAssets.favoriteSvg,
                                  height: 30.h,
                                  width: 30.w,
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  width: 15.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 35.w),
                          // Chat Bubble Icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: SvgPicture.asset(
                                  AppAssets.chatMarkSvg,
                                  height: 30.h,
                                  width: 30.w,
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  width: 15.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 35.w),
                          // Share Icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: SvgPicture.asset(
                                  AppAssets.shareSvg,
                                  height: 30.h,
                                  width: 30.w,
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  width: 15.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2.r),
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
                              // ignore: deprecated_member_use
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
        ),
      ],
    );
  }

  Widget buyerReview() {
    return Container(
      width: 1.sw,
      height: 50,
      color: const Color(0xffFCFCFC),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextWidget(
            '${LocaleKeys.buyers_reviews_on_product_sizing.tr()}',
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 25,
            width: 1.sw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buyerReviewSingle(LocaleKeys.true_label.tr(), 70),
                _buyerReviewSingle(LocaleKeys.small.tr(), 3),
                _buyerReviewSingle(LocaleKeys.large.tr(), 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyerReviewSingle(String text, int numOfPercent) {
    return SizedBox(
      width: 120.w,
      height: 25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyTextWidget(
                text,
                style: context.textTheme.titleLarge?.rq.copyWith(
                  color: const Color(0xff1D1D1D),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 5),
              MyTextWidget(
                "${numOfPercent}%",
                style: context.textTheme.titleLarge?.bq.copyWith(
                  color: const Color(0xff1D1D1D),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                height: 5,
                width: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xffD3D3D3)),
                ),
              ),
              Container(
                height: 5,
                width: (numOfPercent / 100) * 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xff1D1D1D),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xff1D1D1D)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget productImagesWidget({
    required bool isRedeem,
    required productListingModel.Products? productItem,
    required int currentSelectedColor,
  }) {
    return SizedBox(
      height: 464,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: const CupertinoScrollBehavior(),
            child: ListView.separated(
              itemCount: productItem!.syncColorImages.isNullOrEmpty
                  ? productItem.images!.length
                  : !productItem
                        .syncColorImages![currentSelectedColor]
                        .images
                        .isNullOrEmpty
                  ? productItem
                        .syncColorImages![currentSelectedColor]
                        .images!
                        .length
                  : 0,
              primary: false,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 15,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    HelperFunctions.slidingNavigation(
                      context,
                      ProductDetailsDisplayPicturesPage(
                        currentIndex: index,
                        brand: productItem.brand?.name ?? "",
                        category: productItem.categories?.first.name ?? "",
                        images: productItem.syncColorImages.isNullOrEmpty
                            ? productItem.images ?? []
                            : productItem
                                      .syncColorImages![currentSelectedColor]
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
                  child: ValueListenableBuilder<bool>(
                    valueListenable: visibleFlashDeal,
                    builder: (context, _visibleFlashDeal, _) {
                      bool isFlashDealEnded = false;
                      DateTime endDate;
                      Duration _duration = const Duration();
                      final now = DateTime.now();
                      try {
                        endDate = DateFormat(
                          'MM/dd/yyyy',
                          'en_US',
                        ).parse(productItem.flashDealEndDate ?? "");
                        endDate = endDate.add(const Duration(days: 1));
                      } catch (e) {
                        endDate = DateTime.now();
                        print('Error parsing date: $e');
                      }
                      _duration = endDate.difference(now);
                      if (_duration.isNegative || _duration.inSeconds < 1) {
                        isFlashDealEnded = true;
                      }

                      return ValueListenableBuilder<bool>(
                        valueListenable: visibleRedeem,
                        builder: (context, _visibleRedeem, _) {
                          return ProductDetailsImageWidget(
                            key: ValueKey(
                              "ProductDetailsImageWidget${productItem.productId}",
                            ),
                            borderRadius: BorderRadius.circular(0),
                            borderColor:
                                (GetIt.I<PrefsRepository>()
                                                .getRedeemDateForProduct(
                                                  productItem.productId
                                                      .toString(),
                                                )
                                                ?.isAfter(
                                                  DateTime.now().add(
                                                    const Duration(seconds: 1),
                                                  ),
                                                ) ==
                                            true &&
                                        isRedeem == true) ||
                                    (GetIt.I<PrefsRepository>()
                                                .getRedeemSecondRemainingForProduct(
                                                  productItem.productId
                                                      .toString(),
                                                ) ??
                                            0) >
                                        0 ||
                                    (!isFlashDealEnded)
                                ? const Color(0xffFF6200)
                                : null,
                            visibleRedeemNotifier: visibleRedeem,
                            visibleRedeem:
                                (GetIt.I<PrefsRepository>()
                                            .getRedeemDateForProduct(
                                              productItem.productId.toString(),
                                            )
                                            ?.isAfter(
                                              DateTime.now().add(
                                                const Duration(seconds: 1),
                                              ),
                                            ) ==
                                        true &&
                                    isRedeem == true) ||
                                (GetIt.I<PrefsRepository>()
                                            .getRedeemSecondRemainingForProduct(
                                              productItem.productId.toString(),
                                            ) ??
                                        0) >
                                    0,
                            visibleFlashDeal: visibleFlashDeal,
                            isFlashDealEnded: isFlashDealEnded,
                            index: index,
                            flashDealEndDate:
                                productItem.flashDealEndDate ?? "",
                            productId: productItem.productId ?? 0,
                            isRedeem: isRedeem,
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
                            orginalHeight: widget.productItem == null
                                ? 0
                                : widget
                                      .productItem!
                                      .syncColorImages
                                      .isNullOrEmpty
                                ? double.tryParse(
                                    productItem.images![index].originalHeight!,
                                  )
                                : double.tryParse(
                                    productItem
                                        .syncColorImages![currentSelectedColor]
                                        .images![index]
                                        .originalHeight!,
                                  ),
                            orginalWidth: widget.productItem == null
                                ? 0
                                : widget
                                      .productItem!
                                      .syncColorImages
                                      .isNullOrEmpty
                                ? double.tryParse(
                                    productItem.images![index].originalWidth!,
                                  )
                                : double.tryParse(
                                    productItem
                                        .syncColorImages![currentSelectedColor]
                                        .images![index]
                                        .originalWidth!,
                                  ),
                            imageUrl: productItem.syncColorImages.isNullOrEmpty
                                ? productItem.images![index].filePath!
                                : productItem
                                      .syncColorImages![currentSelectedColor]
                                      .images![index]
                                      .filePath,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 5);
              },
            ),
          ),
          productItem.videos.isNullOrEmpty
              ? const SizedBox.shrink()
              : ValueListenableBuilder<bool>(
                  valueListenable: visibleVedio,
                  builder: (context, _visibleVedio, _) {
                    return !_visibleVedio
                        ? const SizedBox.shrink()
                        : Positioned(
                            bottom: 20,
                            right: LanguageService.languageCode != "ar"
                                ? 10
                                : null,
                            left: LanguageService.languageCode != "ar"
                                ? null
                                : 10,
                            child: Container(
                              width: 140,
                              height: 200,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 140,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xff513AAF),
                                      ),
                                    ),
                                    child: ProductVedio(
                                      imageSource:
                                          productItem
                                              .syncColorImages
                                              .isNullOrEmpty
                                          ? productItem.images![0].filePath!
                                          : productItem
                                                .syncColorImages![currentSelectedColor]
                                                .images![0]
                                                .filePath,
                                      videoSource:
                                          productItem.videos.isNullOrEmpty
                                          ? null
                                          : productItem.videos!.first.contains(
                                              "cloudinary",
                                            )
                                          ? productItem.videos!.first
                                          : ("${dotenv.env['Video_url']}" +
                                                (productItem.videos!.first)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                  },
                ),
          productItem.videos.isNullOrEmpty
              ? const SizedBox.shrink()
              : ValueListenableBuilder<bool>(
                  valueListenable: visibleVedio,
                  builder: (context, _visibleVedio, _) {
                    return !_visibleVedio
                        ? const SizedBox.shrink()
                        : Positioned(
                            bottom: 207,
                            right: LanguageService.languageCode != "ar"
                                ? 132
                                : null,
                            left: LanguageService.languageCode != "ar"
                                ? null
                                : 132,
                            child: InkWell(
                              onTap: () => visibleVedio.value = false,
                              child: Container(
                                alignment: Alignment.center,
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xffFF5F61),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.cancelSvg,
                                  width: 10,
                                  // ignore: deprecated_member_use
                                  color: const Color(0xffFF5F61),
                                ),
                              ),
                            ),
                          );
                  },
                ),
        ],
      ),
    );
  }

  void changeVariationWhenNotAvailable({
    required Variation? currentVariation,
    required String productId,
    required bool collectAfterOrder,
    required String productSlug,
    required List<Variation> variation,
  }) async {
    if (!widget.fromNotification &&
        !widget.fromNotificationComment &&
        !(widget.fromCart ?? false) &&
        (changeVariationIfQtyZero ?? false) &&
        currentVariation?.qty != null &&
        currentVariation?.qty == 0 &&
        (!(collectAfterOrder))) {
      if (currentVariation!.type!.contains("-")) {
        currentVariation = variation.firstWhere(
          (element) =>
              (element.qty ?? 0) > 0 &&
              (element.type!.split("-").toList()[0] ==
                  currentVariation?.type!.split("-").toList()[0]),
          orElse: () => variation.firstWhere(
            (element) => (element.qty ?? 0) > 0,
            orElse: () => currentVariation!,
          ),
        );
        int index =
            productItem?.syncColorImages?.indexWhere(
              (element) =>
                  element.colorOption ==
                  (currentVariation!.type!.split("-").toList()[0]),
            ) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;
        await Future.delayed(
          const Duration(milliseconds: 300),
          () => homeBloc.add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: index != -1 ? index : 0,
              productSlug: productSlug,
            ),
          ),
        );

        await Future.delayed(
          const Duration(milliseconds: 300),
          () => homeBloc.add(
            AddCurrentColorSizeEvent(
              choice_1: productItem?.choiceOptions?[0].options
                  ?.firstWhere(
                    (element) =>
                        element.option ==
                        (currentVariation!.type!.split("-").toList()[1]),
                  )
                  .name,
              choiceOption: (currentVariation!.type!.split("-").toList()[1]),
            ),
          ),
        );
      } else if ((productItem?.syncColorImages?.length ?? 0) > 0) {
        currentVariation = variation.firstWhere(
          (element) =>
              ((element.qty ?? 0) > 0 &&
              element.type == currentVariation?.type),
          orElse: () => variation.firstWhere(
            (element) => (element.qty ?? 0) > 0,
            orElse: () => currentVariation!,
          ),
        );
        int index =
            productItem?.syncColorImages?.indexWhere(
              (element) => element.colorOption == (currentVariation!.type),
            ) ??
            -1;
        currentSelectedColorAfterChangeVariant = index;

        await Future.delayed(
          const Duration(milliseconds: 50),
          () => homeBloc.add(
            AddCurrentSelectedColorEvent(
              currentSelectedColor: index != -1 ? index : 0,
              productSlug: productSlug,
            ),
          ),
        );
      } else {
        currentSelectedColorAfterChangeVariant = currentSelectedColor;
        currentVariation = variation.firstWhere(
          (element) => (element.qty ?? 0) > 0,
          orElse: () => currentVariation!,
        );
        await Future.delayed(
          const Duration(milliseconds: 300),
          () => homeBloc.add(
            AddCurrentColorSizeEvent(
              choice_1: productItem?.choiceOptions?[0].options
                  ?.firstWhere(
                    (element) => element.option == (currentVariation!.type),
                  )
                  .name,
              choiceOption: (currentVariation!.type),
            ),
          ),
        );
      }
    } else {
      if ((currentVariation?.type ?? "").contains("-")) {
        await Future.delayed(
          const Duration(milliseconds: 300),
          () => homeBloc.add(
            AddCurrentColorSizeEvent(
              choice_1: productItem?.choiceOptions?[0].options
                  ?.firstWhere(
                    (element) =>
                        element.option ==
                        (currentVariation!.type!.split("-").toList()[1]),
                  )
                  .name,
              choiceOption: (currentVariation!.type!.split("-").toList()[1]),
            ),
          ),
        );
      } else if (((productItem?.syncColorImages?.length ?? 0) == 0)) {
        await Future.delayed(
          const Duration(milliseconds: 300),
          () => homeBloc.add(
            AddCurrentColorSizeEvent(
              choice_1: productItem?.choiceOptions?.length == 0
                  ? ""
                  : productItem?.choiceOptions?[0].options
                        ?.firstWhere(
                          (element) =>
                              element.option == (currentVariation!.type),
                        )
                        .name,
              choiceOption: currentVariation!.type,
            ),
          ),
        );
      }

      currentSelectedColorAfterChangeVariant = currentSelectedColor;
    }
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => homeBloc.add(
        const IsChangedVariationWhenQtyZeroEvent(
          isChangedVariationWhenQtyZero: true,
        ),
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
}
