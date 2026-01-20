import 'dart:async';

import 'package:easy_localization/easy_localization.dart' as translate;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';

import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/home/data/models/get_cart_item_model.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_bottom_bar_new.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_comments_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_header.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_more_options_content.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_sheet_share_content.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';

import 'package:trydos/service/language_service.dart';
import '../../../../../core/domin/repositories/prefs_repository.dart';

import '../../manager/homeBloc/home_bloc.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ProductDetailsBottomSheetNew extends StatefulWidget {
  final productListingModel.Products productItem;
  final int currentColor;
  final ValueNotifier<bool>? showShadowForPanel;
  final int boutiqueId;
  final String currentVariant;
  final String boutiqueIcon;
  final String currentColorName;
  final String currentColorOption;
  final String productSlugForTopic;
  final String productDescription;
  final String currentColornum;
  final PanelController panelController;
  final String productIdForCashData;
  final int? currentSelectedColorAfterChangeVariant;
  final int countOfPieces;
  final bool? isGetFullProductDetails;
  final bool? fromListingPage;
  final String? flashDealEndDate;
  final bool? isFlashDealEnded;
  final ValueNotifier<bool>? visibleFlashDeal;
  final double initPrice;
  final double initOfferPrice;
  final bool isRedeem;
  final double redeemPrice;
  final double redeemVariantPrice;
  final bool collectedAfterOrdering;
  final ValueNotifier<bool>? isVerified;
  final String maxAllowedToAddCart;
  final ValueNotifier<int> addToBagButtonShapeNotifier;
  final ValueNotifier<int>? tapIndexToAddProductToCart;
  final ValueNotifier<int> currentActiveTab;
  final ValueNotifier<bool> visibleRedeemNotifier;
  final ValueNotifier<String?> productNotAvailableNotifier;
  ProductDetailsBottomSheetNew({
    super.key,
    required this.productItem,
    required this.redeemVariantPrice,
    required this.redeemPrice,
    required this.isRedeem,
    required this.visibleRedeemNotifier,
    this.currentSelectedColorAfterChangeVariant,
    this.tapIndexToAddProductToCart,
    this.showShadowForPanel,
    this.isVerified,
    required this.flashDealEndDate,
    required this.isFlashDealEnded,
    required this.visibleFlashDeal,
    required this.currentVariant,
    required this.productIdForCashData,
    required this.isGetFullProductDetails,
    required this.collectedAfterOrdering,
    required this.currentColorOption,
    required this.panelController,
    required this.addToBagButtonShapeNotifier,
    required this.currentActiveTab,
    required this.boutiqueIcon,
    required this.productNotAvailableNotifier,
    this.fromListingPage = false,
    required this.productSlugForTopic,
    required this.productDescription,
    required this.maxAllowedToAddCart,
    required this.countOfPieces,
    required this.currentColornum,
    required this.initOfferPrice,
    required this.initPrice,
    required this.boutiqueId,
    required this.currentColor,
    required this.currentColorName,
  });

  @override
  State<ProductDetailsBottomSheetNew> createState() =>
      _ProductDetailsBottomSheetNewState();
}

class _ProductDetailsBottomSheetNewState
    extends State<ProductDetailsBottomSheetNew> {
  final ValueNotifier<List<String>> idsOfChatCardsToShare = ValueNotifier([]);

  final ValueNotifier<double> workOnBlurNotifier = ValueNotifier(10);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final ValueNotifier<String?> sizeIsNotAvailableNotifier = ValueNotifier(null);

  final ValueNotifier<String?> colorIsNotAvailableNotifier = ValueNotifier(
    null,
  );

  List<String> colorsForEachProduct = [];
  List<String> sizesForEachProduct = [];
  bool requestToNotifyMeFormFirstSize = true;
  List<int> colorsQuantityForEachProduct = [];
  Timer? debounce;
  List<productListingModel.SyncColorImageProduct> syncColorImageList = [];
  List<String> images = [];
  late int currentIndexInSlider;
  int? qtyForProductWithoutVariant;
  late HomeBloc homeBloc;

  final ScrollController singleChildScrollViewsScrollController =
      ScrollController();
  bool isFirstOpenPanel = true;
  final ValueNotifier<String?> animatedMessage = ValueNotifier(null);
  final ValueNotifier<bool> showAnimatedMessage = ValueNotifier(false);

  void showAnimatedMessageFunc(String message) {
    animatedMessage.value = message;
    showAnimatedMessage.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      showAnimatedMessage.value = false;
      // animatedMessage.value = null; // إذا أردت تصفير الرسالة بعد الإخفاء
    });
  }

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    syncColorImageList = widget.productItem.syncColorImages ?? [];
    syncColorImageList.removeWhere((element) => element.images.isNullOrEmpty);

    images = syncColorImageList.map((e) => e.images![0].filePath!).toList();

    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();

    singleChildScrollViewsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.changeSizesForEveryProduct !=
              current.changeSizesForEveryProduct ||
          previous.isChangedvariationWhenQtyZero !=
              current.isChangedvariationWhenQtyZero ||
          previous.currentSelectedColorForEveryProductStatus !=
              current.currentSelectedColorForEveryProductStatus ||
          previous.currentHeightWhenAddToBag !=
              current.currentHeightWhenAddToBag ||
          previous.currentColorSizeForCart?["choiceOption"] !=
              current.currentColorSizeForCart?["choiceOption"],
      builder: (context, state) {
        Future.delayed(const Duration(milliseconds: 100), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (singleChildScrollViewsScrollController.hasClients) {
              singleChildScrollViewsScrollController.jumpTo(
                singleChildScrollViewsScrollController.position.maxScrollExtent,
              );
            }
          });
        });
        colorsQuantityForEachProduct =
            state.colorsQuantitiesForEachProduct ?? [];
        colorsForEachProduct = state.colorsForEachProduct ?? [];
        sizesForEachProduct = state.sizesForEachColor ?? [];
        qtyForProductWithoutVariant =
            state.authProductDetailsModel?.data?.availableQuantity;
        return SingleChildScrollView(
          controller: singleChildScrollViewsScrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: widget.currentActiveTab,
                builder: (context, currentTab, _) {
                  if (currentTab == 0) {
                    FirebaseAnalyticsService.logEventForSession(
                      executedEventName:
                          AnalyticsButtonsEventNameConst.VIEW_COMMENTS_BUTTON,
                      eventName: AnalyticsEventsConst.VIEW_COMMENTS,
                      extraParams: {
                        'item_id': widget.productItem.productId.toString(),
                        'item_name': widget.productItem.name.toString(),
                        'price': widget.productItem.price.toString(),
                        'brand': widget.productItem.brand == null
                            ? ""
                            : widget.productItem.brand!.name.toString(),
                        'category': widget.productItem.categories!
                            .map((e) => e.id.toString())
                            .toList()
                            .toString(),
                        'count_likes': widget.productItem.countOfLikes
                            .toString(),
                        'review_count': widget.productItem.reviewsCount
                            .toString(),
                        'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
                      },
                    );
                  }
                  LastPagesTracker.push(
                    'ProductDetailsBottomSheetNew currentTab : $currentTab',
                  );
                  return ValueListenableBuilder<double>(
                    valueListenable: workOnBlurNotifier,
                    child: SizedBox(
                      width: 1.sw,
                      height: currentTab == 3
                          ? 1.sh -
                                ((widget.fromListingPage ?? false)
                                    ? ((state.currentHeightWhenAddToBag ?? 0) +
                                          10)
                                    : ((state.currentHeightWhenAddToBag ?? 0) -
                                          2))
                          : currentTab == -1
                          ? 75
                          : 450,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          currentTab != 3
                              ? const SizedBox.shrink()
                              : Container(
                                  alignment: Alignment.topCenter,
                                  width: 80,
                                  height: 60.h,
                                  padding: EdgeInsets.only(
                                    top: 10.h,
                                    left: 15,
                                    right: 15,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xff513AAF),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: 50,
                                    height: 20,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(AppAssets.buyNewSvg),
                                        const SizedBox(width: 5),
                                        MyTextWidget(
                                          LocaleKeys.buy.tr(),
                                          style: context
                                              .textTheme
                                              .titleMedium
                                              ?.mq
                                              .copyWith(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          SlidingUpPanel(
                            controller: widget.panelController,
                            maxHeight: currentTab == -1
                                ? 45
                                : currentTab == 3
                                ? 621
                                      .h //330.h + 70.w + 305
                                : 433,
                            minHeight: (widget.fromListingPage ?? false)
                                ? 0
                                : 45,
                            onPanelClosed: () {
                              isFirstOpenPanel = true;
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  widget.showShadowForPanel?.value = false;
                                },
                              );

                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  widget.tapIndexToAddProductToCart?.value = -1;
                                },
                              );
                              widget.addToBagButtonShapeNotifier.value = 0;

                              sizeIsNotAvailableNotifier.value = null;
                              colorIsNotAvailableNotifier.value = null;

                              widget.currentActiveTab.value = -1;
                            },
                            onPanelOpened: () {
                              if (isFirstOpenPanel) {
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    WidgetsBinding.instance.addPostFrameCallback((
                                      _,
                                    ) {
                                      if (singleChildScrollViewsScrollController
                                          .hasClients) {
                                        singleChildScrollViewsScrollController
                                            .jumpTo(
                                              singleChildScrollViewsScrollController
                                                  .position
                                                  .maxScrollExtent,
                                            );
                                      }
                                    });
                                  },
                                );
                                widget.showShadowForPanel?.value = true;

                                if (sizesForEachProduct.length == 0) {
                                  if (!colorsQuantityForEachProduct
                                      .isNullOrEmpty) {
                                    if (colorsQuantityForEachProduct[widget
                                                .currentColor] ==
                                            0 &&
                                        !widget.collectedAfterOrdering) {
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () =>
                                            colorIsNotAvailableNotifier.value =
                                                colorsForEachProduct[widget
                                                    .currentColor],
                                      );
                                    } else {
                                      colorIsNotAvailableNotifier.value = null;
                                    }
                                  } else {
                                    colorIsNotAvailableNotifier.value = null;
                                  }
                                  if (!colorsQuantityForEachProduct
                                      .isNullOrEmpty) {
                                    if (colorsQuantityForEachProduct[widget
                                                .currentColor] ==
                                            0 &&
                                        !widget.collectedAfterOrdering) {
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () =>
                                            colorIsNotAvailableNotifier.value =
                                                colorsForEachProduct[widget
                                                    .currentColor],
                                      );
                                    } else {
                                      colorIsNotAvailableNotifier.value = null;
                                    }
                                  } else {
                                    colorIsNotAvailableNotifier.value = null;
                                  }
                                }
                                isFirstOpenPanel = false;
                              }
                            },
                            boxShadow: const [
                              CustomBoxShadow(
                                color: Color.fromARGB(255, 212, 209, 209),
                                blurRadius: 0.1,
                                blurStyle: BlurStyle.outer,
                              ),
                            ],
                            isDraggable: (currentTab == -1 ? false : true),
                            panelBuilder: (controller) => currentTab == 3
                                ? Column(
                                    children: [
                                      SizedBox(height: 5.h),
                                      Divider(
                                        thickness: 2,
                                        radius: BorderRadius.circular(5),
                                        endIndent: (1.sw - 40) / 2,
                                        indent: (1.sw - 40) / 2,
                                        color: const Color(0xffC4C2C2),
                                      ),
                                      productInfoWidget(),
                                      (sizesForEachProduct.length != 0) ||
                                              (colorsForEachProduct.length != 0)
                                          ? const SizedBox.shrink()
                                          : const SizedBox(height: 10),
                                      (sizesForEachProduct.length != 0) ||
                                              (colorsForEachProduct.length != 0)
                                          ? const SizedBox.shrink()
                                          : ((qtyForProductWithoutVariant ??
                                                        0) <
                                                    11 &&
                                                (!widget
                                                    .collectedAfterOrdering))
                                          ? MyTextWidget(
                                              "${LocaleKeys.last.tr()} ${(qtyForProductWithoutVariant ?? 0)}",
                                              style: context
                                                  .textTheme
                                                  .titleLarge
                                                  ?.rq
                                                  .copyWith(
                                                    height: 1.1,
                                                    fontSize: 11,
                                                    color: const Color(
                                                      0xffFF6200,
                                                    ),
                                                  ),
                                            )
                                          : const SizedBox.shrink(),

                                      (widget
                                                      .productItem
                                                      .syncColorImages
                                                      ?.length ??
                                                  0) ==
                                              0
                                          ? const SizedBox.shrink()
                                          : _availableColorWidget(state: state),
                                      widget
                                              .productItem
                                              .choiceOptions
                                              .isNullOrEmpty
                                          ? const SizedBox.shrink()
                                          : (widget
                                                        .productItem
                                                        .choiceOptions?[0]
                                                        .options
                                                        ?.length ??
                                                    0) ==
                                                0
                                          ? const SizedBox.shrink()
                                          : _availableSizeWidget(),
                                      const Spacer(),
                                      SizedBox(height: 12.h),
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x1a000000),
                                              offset: Offset(0, -2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                          border: Border(
                                            top: BorderSide(
                                              color: widget.isRedeem
                                                  ? const Color(0xffFF6200)
                                                  : Colors.white,
                                            ),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30),
                                          ),
                                        ),
                                        child: _headerWidget(),
                                      ),
                                      SizedBox(height: 5.h),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            _headerWidget(),
                                            currentTab != -1
                                                ? Positioned(
                                                    top: 7,
                                                    child: SvgPicture.asset(
                                                      AppAssets.minusMarkSvg,
                                                      width: 25,
                                                      // ignore: deprecated_member_use
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                        currentTab < 3 && currentTab >= 0
                                            ? SizedBox(
                                                height: 425.h,
                                                child: currentTab == 0
                                                    ? ProductDetailsSheetCommentsContent(
                                                        productSlugForTopic: widget
                                                            .productSlugForTopic,
                                                        ownerId: widget
                                                            .productItem
                                                            .ownerId,
                                                        isVerified:
                                                            widget.isVerified,
                                                        ownerType: widget
                                                            .productItem
                                                            .ownerType,
                                                        currentVariant: widget
                                                            .currentVariant,
                                                        productSlug:
                                                            widget
                                                                .productItem
                                                                .slug ??
                                                            "",
                                                        productId: widget
                                                            .productItem
                                                            .productId
                                                            .toString(),
                                                        scrollController:
                                                            currentTab == 0
                                                            ? controller
                                                            : null,
                                                      )
                                                    : currentTab == 1
                                                    ? BlocBuilder<
                                                        HomeBloc,
                                                        HomeState
                                                      >(
                                                        buildWhen: (p, c) =>
                                                            p.currentColorSizeForCart?["choiceOption"] !=
                                                            c.currentColorSizeForCart?["choiceOption"],
                                                        builder: (context, state) {
                                                          return ProductDetailsSheetShareContent(
                                                            currentSize:
                                                                state.currentColorSizeForCart !=
                                                                    null
                                                                ? state.currentColorSizeForCart!["choiceOption"] ??
                                                                      ""
                                                                : "",
                                                            currentColor: widget
                                                                .currentColorName,
                                                            productDescription:
                                                                widget
                                                                    .productDescription,
                                                            productItem: widget
                                                                .productItem,
                                                            scrollController:
                                                                currentTab == 1
                                                                ? controller
                                                                : null,
                                                            idsOfChatCardsToShare:
                                                                idsOfChatCardsToShare,
                                                          );
                                                        },
                                                      )
                                                    : currentTab == 2
                                                    ? ProductDetailsSheetMoreOptionsContent(
                                                        productSlugForTopic: widget
                                                            .productSlugForTopic,
                                                        productSlug:
                                                            widget
                                                                .productItem
                                                                .slug ??
                                                            "",
                                                        scrollController:
                                                            currentTab == 2
                                                            ? controller
                                                            : null,
                                                        productId: widget
                                                            .productItem
                                                            .productId
                                                            .toString(),
                                                      )
                                                    : const SizedBox.shrink(),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                            border: Border(
                              top: BorderSide(
                                color: widget.isRedeem
                                    ? const Color(0xffFF6200)
                                    : Colors.white,
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    builder: (context, blurValue, child) {
                      return child!;
                    },
                  );
                },
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: idsOfChatCardsToShare,
                builder: (context, channelIds, _) {
                  return channelIds.isEmpty
                      ? BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (p, c) =>
                              p.currentColorSizeForCart?["choiceOption"] !=
                              c.currentColorSizeForCart?["choiceOption"],
                          builder: (context, state) {
                            return ProductDetailsSheetBottomBarNew(
                              isRedeem: widget.isRedeem,
                              isVerified: widget.isVerified,
                              redeemVariantPrice: widget.redeemVariantPrice,
                              flashDealEndDate: widget.flashDealEndDate,
                              isFlashDealEnded: widget.isFlashDealEnded,
                              visibleFlashDeal: widget.visibleFlashDeal,
                              visibleRedeemNotifier:
                                  widget.visibleRedeemNotifier,
                              colorOption: widget.currentColorOption,
                              isGetFullProductDetails:
                                  widget.isGetFullProductDetails ?? false,
                              choiceOption:
                                  state.currentColorSizeForCart != null
                                  ? state.currentColorSizeForCart!["choiceOption"] ??
                                        ""
                                  : "",
                              productNotAvailableNotifier:
                                  widget.productNotAvailableNotifier,
                              products: widget.productItem,
                              collectedAfterOrder:
                                  widget.collectedAfterOrdering,
                              colorIsNotAvailableNotifier:
                                  colorIsNotAvailableNotifier,
                              productSlug: widget.productItem.slug ?? "",
                              countOfPieces: widget.countOfPieces,
                              colorNum: widget.currentColornum,
                              size: state.currentColorSizeForCart != null
                                  ? state.currentColorSizeForCart!["size"] ?? ""
                                  : "",
                              colorName: widget.currentColorName,
                              productIdForCashProducts:
                                  widget.productIdForCashData,
                              productIdForRequestApi: widget
                                  .productItem
                                  .productId
                                  .toString(),
                              imageUrl:
                                  !widget
                                      .productItem
                                      .syncColorImages
                                      .isNullOrEmpty
                                  ? widget
                                            .productItem
                                            .syncColorImages![widget
                                                .currentColor]
                                            .images![0]
                                            .filePath ??
                                        ""
                                  : (widget.productItem.images?.isNotEmpty ??
                                        false)
                                  ? widget
                                            .productItem
                                            .images![widget.currentColor]
                                            .filePath ??
                                        ""
                                  : "",
                              panelController: widget.panelController,
                              clickOnComments: () {
                                widget.panelController.open();
                                widget.currentActiveTab.value = 0;

                                //////////////////////////////
                                // FirebaseAnalyticsService.logEventForSession(
                                //   eventName:
                                //       AnalyticsEventsConst.buttonClicked,
                                //   executedEventName:
                                //       AnalyticsButtonsEventNameConst
                                //           .showCommentsButton,
                                // );
                              },
                              clickOnFavorite: () {
                                widget.currentActiveTab.value = -1;
                              },
                              clickOnMoreOptions: () {
                                widget.panelController.open();
                                widget.currentActiveTab.value = 2;

                                //////////////////////////////
                                // FirebaseAnalyticsService.logEventForSession(
                                //   eventName:
                                //       AnalyticsEventsConst.buttonClicked,
                                //   executedEventName:
                                //       AnalyticsButtonsEventNameConst
                                //           .moreOptionsButton,
                                // );
                              },
                              clickOnShare: () {
                                widget.panelController.open();
                                widget.currentActiveTab.value = 1;

                                if (GetIt.I<PrefsRepository>().chatToken !=
                                    null) {
                                  BlocProvider.of<ChatBloc>(
                                    context,
                                  ).add(const GetChatsEvent());
                                  BlocProvider.of<ChatBloc>(
                                    context,
                                  ).add(const SaveContactsEvent());
                                }
                                //////////////////////////////
                                // FirebaseAnalyticsService.logEventForSession(
                                //   eventName:
                                //       AnalyticsEventsConst.buttonClicked,
                                //   executedEventName:
                                //       AnalyticsButtonsEventNameConst
                                //           .shareProductButton,
                                // );
                              },
                              currentActiveTab: widget.currentActiveTab,
                              sizeIsNotAvailableNotifier:
                                  sizeIsNotAvailableNotifier,
                              addToBagButtonShapeNotifier:
                                  widget.addToBagButtonShapeNotifier,
                            );
                          },
                        )
                      : ShareButton(
                          onTap: () {
                            BlocProvider.of<ChatBloc>(context).add(
                              ShareProductWithContactsOrChannelsEvent(
                                product: widget.productItem,
                                productId: widget.productItem.productId
                                    .toString(),
                                productName: widget.productItem.name.toString(),
                                productSlug: widget.productItem.slug.toString(),
                                productDescription: widget.productItem.details
                                    .toString(),
                                originalImageWidth: "320",
                                originalImageHeight: "464",
                                productImageUrl:
                                    // gallery3dControllerForCircles != null
                                    widget.productItem.images![0].filePath
                                        .toString(),
                                channelIds: channelIds,
                              ),
                            );
                            idsOfChatCardsToShare.value = [];
                            widget.currentActiveTab.value = -1;
                            widget.panelController.close();
                            widget.showShadowForPanel?.value = false;
                            //////////////////////////////
                            // FirebaseAnalyticsService.logEventForSession(
                            //   eventName: AnalyticsEventsConst.buttonClicked,
                            //   executedEventName:
                            //       AnalyticsButtonsEventNameConst
                            //           .sendProductToChatButton,
                            // );
                          },
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget productInfoWidget() {
    return Padding(
      padding: EdgeInsets.all(12.0.h),
      child: SizedBox(
        height: 170.h,
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170.h,
              width: 1.sw,
              child: Row(
                children: [
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.currentSelectedColorForEveryProduct[widget
                            .productItem
                            .slug
                            .toString()] !=
                        current.currentSelectedColorForEveryProduct[widget
                            .productItem
                            .slug
                            .toString()],
                    builder: (context, state) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: widget.isRedeem
                                  ? const Color(0xffFF6200)
                                  : Colors.white,
                            ),
                          ),
                          child: MyCachedNetworkImage(
                            innerShadowYOffset: 1,
                            withInnerShadow: true,
                            imageUrl:
                                (widget
                                    .productItem
                                    .syncColorImages
                                    .isNullOrEmpty)
                                ? widget.productItem.images![0].filePath ?? ''
                                : widget
                                          .productItem
                                          .syncColorImages![state
                                                  .currentSelectedColorForEveryProduct[widget
                                                  .productItem
                                                  .slug
                                                  .toString()] ??
                                              0]
                                          .images?[0]
                                          .filePath ??
                                      '',
                            imageFit: BoxFit.contain,
                            width: 123.w,
                            height: 170.h,
                          ),
                        ),
                      );
                    },
                  ),
                  ///////////////////
                  const SizedBox(width: 10),
                  ///////////////////
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.h),
                        SvgNetworkWidget(
                          svgUrl:
                              widget.productItem.brand?.icon?.filePath ?? '',
                          color: const Color(0xff1D1D1D),
                          height: 10.h,
                        ),

                        ///////////////////
                        SizedBox(height: 5.h),
                        ///////////////////
                        Text(
                          widget.productItem.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 11.sp,
                            height: 1.3,
                          ),
                        ),
                        ///////////////////
                        SizedBox(height: 5.h),
                        ///////////////////
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.orderAddressSvg,
                              // ignore: deprecated_member_use
                              color: const Color(0xff1D1D1D),
                              height: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${LocaleKeys.shipping.tr()}:',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff8D8D8D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              ' 3 ${LocaleKeys.day.tr()} ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '${LocaleKeys.details.tr()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.mq.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xff505050),
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.9,
                              ),
                            ),
                            ///////////////////

                            ///////////////////
                          ],
                        ),
                        ///////////////////
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.shappingCartNew,
                              // ignore: deprecated_member_use
                              color: const Color(0xff388CFF),
                              height: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              LocaleKeys.today_shipping.tr(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              " ${LocaleKeys.if_buy_before.tr()} ",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff8D8D8D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '13:00',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff505050),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '  ${LocaleKeys.today.tr()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff8D8D8D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            ///////////////////

                            ///////////////////
                          ],
                        ),
                        ///////////////////
                        SizedBox(height: 5.h),
                        ///////////////////
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.deliveredBlackSvg,
                              // ignore: deprecated_member_use
                              color: const Color(0xff388CFF),
                              height: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${LocaleKeys.at_your_address_in.tr()} Lebanon Monday ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '2.Jun',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.bq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            SvgPicture.asset(
                              AppAssets.deliveryGuranteeSvg,
                              height: 13,
                            ),

                            ///////////////////

                            ///////////////////
                          ],
                        ),
                        ///////////////////
                        SizedBox(height: 5.h),
                        ///////////////////
                        Row(
                          children: [
                            Text(
                              '${LocaleKeys.get_a.tr()} ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 9.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '25% ${LocaleKeys.refund.tr()} ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                letterSpacing: 0.18,
                                fontSize: 9.sp,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              LocaleKeys.of_the_product_price_if_shipping.tr(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.bodyMedium?.rq.copyWith(
                                color: const Color(0xff1D1D1D),
                                letterSpacing: 0.18,
                                fontSize: 9.sp,
                                height: 1.3,
                              ),
                            ),

                            ///////////////////

                            ///////////////////
                          ],
                        ),
                        const Spacer(),

                        ///////////////////
                        Container(
                          width: 1.sw,
                          height: 20.h,
                          child: Row(
                            children: [
                              MyTextWidget(
                                HelperFunctions.formatNumber(
                                  numberToFormate: double.parse(
                                    (HelperFunctions.truncateToDecimalPlaces(
                                              (widget.productItem.price ?? 0),
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
                                                .exchangeRate!)
                                        .toString(),
                                  ),
                                ),
                                //  .toStringAsFixed(widget.decimalPoint),
                                style: context.textTheme.headlineMedium?.rq
                                    .copyWith(
                                      color: const Color(0xffC4C2C2),
                                      fontSize: 13.sp,
                                      decoration: TextDecoration.lineThrough,
                                      height: 0,
                                    ),
                              ),
                              const SizedBox(width: 5),
                              BlocBuilder<HomeBloc, HomeState>(
                                buildWhen: (previous, current) =>
                                    previous.updateItemInCartStatus !=
                                        current.updateItemInCartStatus ||
                                    previous.addItemInCartStatus !=
                                        current.addItemInCartStatus ||
                                    previous.deleteItemInCartStatus !=
                                        current.deleteItemInCartStatus ||
                                    previous.getCartItemsStatus !=
                                        current.getCartItemsStatus ||
                                    previous.getCurrencyForCountryModel !=
                                        current.getCurrencyForCountryModel ||
                                    previous.currentColorSizeForCart?["choiceOption"] !=
                                        current
                                            .currentColorSizeForCart?["choiceOption"] ||
                                    previous.currentSelectedColorForEveryProduct !=
                                        current
                                            .currentSelectedColorForEveryProduct,
                                builder: (context, state) {
                                  double offPriceInCart =
                                      state.cartCollection?.firstWhere(
                                        (element) {
                                          if (element
                                                  .variations
                                                  ?.isNullOrEmpty ??
                                              true) {
                                            return (element.productId
                                                    .toString() ==
                                                widget.productIdForCashData);
                                          }
                                          return (element.productId
                                                      .toString() ==
                                                  widget.productIdForCashData &&
                                              ('${element.variations![0].colorOption ?? ""}${(((element.variations![0].colorOption ?? "") != "") && ((element.variations![0].sizeOption ?? "") != "")) ? "-" : ""}${element.variations![0].sizeOption ?? ""}') ==
                                                  widget.currentVariant);
                                        },
                                        orElse: () =>
                                            Cart(id: 0, offerPrice: 0),
                                      ).offerPrice ??
                                      0;

                                  return MyTextWidget(
                                    HelperFunctions.formatNumber(
                                      numberToFormate: double.parse(
                                        (offPriceInCart > 0 &&
                                                (!(widget.isRedeem)))
                                            ? (HelperFunctions.truncateToDecimalPlaces(
                                                        (offPriceInCart),
                                                        homeBloc
                                                            .state
                                                            .getCurrencyForCountryModel!
                                                            .data!
                                                            .currency!
                                                            .decimalDigits!,
                                                      ) *
                                                      state
                                                          .getCurrencyForCountryModel!
                                                          .data!
                                                          .currency!
                                                          .exchangeRate!)
                                                  .toString()
                                            : (HelperFunctions.truncateToDecimalPlaces(
                                                        (widget
                                                                .productItem
                                                                .offerPrice ??
                                                            0),
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
                                                          .exchangeRate!)
                                                  .toString(),
                                      ),
                                    ),
                                    //      .toStringAsFixed(widget.decimalPoint),
                                    style: context.textTheme.headlineMedium?.bq
                                        .copyWith(
                                          fontSize: 13.sp,
                                          decoration: widget.isRedeem
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: const Color(0xff505050),
                                          height: 0,
                                        ),
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                              widget.isRedeem
                                  ? const SizedBox.shrink()
                                  : MyTextWidget(
                                      homeBloc
                                              .state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .symbol ??
                                          "",
                                      style: context.textTheme.titleMedium?.lq
                                          .copyWith(
                                            fontSize: 11.sp,
                                            color: const Color(0xffC4C2C2),
                                            height: 0,
                                          ),
                                    ),
                              const SizedBox(width: 5),
                              widget.isRedeem
                                  ? MyTextWidget(
                                      HelperFunctions.formatNumber(
                                        numberToFormate:
                                            HelperFunctions.truncateToDecimalPlaces(
                                              (widget.redeemVariantPrice),
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
                                                .exchangeRate!,
                                      ),
                                      //      .toStringAsFixed(widget.decimalPoint),
                                      style: context
                                          .textTheme
                                          .headlineMedium
                                          ?.bq
                                          .copyWith(
                                            fontSize: 13.sp,
                                            color: Colors.deepOrangeAccent,
                                            height: 0,
                                          ),
                                    )
                                  : const SizedBox.shrink(),
                              widget.isRedeem
                                  ? MyTextWidget(
                                      homeBloc
                                              .state
                                              .getCurrencyForCountryModel!
                                              .data!
                                              .currency!
                                              .symbol ??
                                          "",
                                      style: context.textTheme.titleMedium?.lq
                                          .copyWith(
                                            fontSize: 11.sp,
                                            color: Colors.deepOrangeAccent,
                                            height: 0,
                                          ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        Text(
                          '${LocaleKeys.all_inclusive_without_additions.tr()}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: const Color(0xff1D1D1D),
                            letterSpacing: 0.18,
                            fontSize: 10.sp,
                            height: 1.3,
                          ),
                        ),

                        ///////////////////
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableColorWidget({required HomeState state}) {
    int tapIndex =
        state.currentSelectedColorForEveryProduct[widget.productItem.slug
            .toString()] ??
        0;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (sizesForEachProduct.length == 0) {
        if (colorsQuantityForEachProduct.length > 0) {
          if (colorsQuantityForEachProduct[tapIndex] == 0 &&
              !widget.collectedAfterOrdering) {
            colorIsNotAvailableNotifier.value = colorsForEachProduct[tapIndex];
          } else {
            colorIsNotAvailableNotifier.value = null;
          }
        } else {
          colorIsNotAvailableNotifier.value = null;
        }
      }
    });

    return Padding(
      padding: EdgeInsets.all(12.0.h),
      child: SizedBox(
        width: 1.sw,
        height: (sizesForEachProduct.length != 0) ? 128.h : 160.h,
        child: Column(
          children: [
            Container(
              width: 1.sw,
              height: 28.h,
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  SvgPicture.asset(AppAssets.colorPickerSvg, height: 14.h),
                  const SizedBox(width: 5),
                  MyTextWidget(
                    '${LocaleKeys.selected_color.tr()}',
                    style: context.textTheme.titleLarge?.rq.copyWith(
                      color: const Color(0xff1D1D1D),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: 1.sw,
              height: 90.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: widget.productItem.syncColorImages?.length ?? 0,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 54,
                    height: 90.h,
                    child: GestureDetector(
                      onTap: () {
                        if (index ==
                            state.currentSelectedColorForEveryProduct[widget
                                .productItem
                                .slug
                                .toString()]) {
                          return;
                        }
                        FirebaseAnalyticsService.logEventForSession(
                          executedEventName: AnalyticsButtonsEventNameConst
                              .CHOOSE_AVAILABLE_COLOR_BUTTON,
                          eventName: AnalyticsEventsConst.changeColor,
                          extraParams: {
                            'item_id': widget.productItem.productId.toString(),
                            'item_name': widget.productItem.name.toString(),
                            'brand': widget.productItem.brand!.name.toString(),
                            'category': widget.productItem.categories!
                                .map((e) => e.name)
                                .toList()
                                .toString(),
                            'selected_color':
                                widget.productItem.colors![index].name ??
                                ''.toString(),
                            'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
                            'selected_size':
                                BlocProvider.of<HomeBloc>(context)
                                    .state
                                    .currentColorSizeForCart?['choiceOption'] ??
                                '',
                          },
                        );
                        sizeIsNotAvailableNotifier.value = null;
                        colorIsNotAvailableNotifier.value = null;
                        BlocProvider.of<HomeBloc>(context).add(
                          AddCurrentSelectedColorEvent(
                            currentSelectedColor: index,
                            productSlug: widget.productItem.slug.toString(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 50,
                              height: 74.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      index ==
                                          state
                                              .currentSelectedColorForEveryProduct[widget
                                              .productItem
                                              .slug
                                              .toString()]
                                      ? const Color(0xff513AAF)
                                      : Colors.transparent,
                                ),
                              ),
                              child: MyCachedNetworkImage(
                                withInnerShadow: true,
                                imageFit: BoxFit.contain,
                                innerShadowYOffset: 1,
                                imageUrl:
                                    (widget
                                            .productItem
                                            .syncColorImages?[index]
                                            .images
                                            ?.isNotEmpty ??
                                        false)
                                    ? widget
                                              .productItem
                                              .syncColorImages![index]
                                              .images![0]
                                              .filePath ??
                                          ''
                                    : '',
                                radius: 6,
                                width: 50,
                                height: 73.h,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ((widget.productItem.variation?.firstWhere(
                                                (element) {
                                                  return element.type ==
                                                      "${widget.productItem.syncColorImages?[index].colorOption}${(state.currentColorSizeForCart?["choiceOption"] ?? "") == "" ? "" : "-"}${state.currentColorSizeForCart?["choiceOption"] ?? ""}";
                                                },
                                                orElse: () => Variation(),
                                              ).qty ??
                                              0)
                                          .round() <
                                      11 &&
                                  (index !=
                                      ((state.currentSelectedColorForEveryProduct[widget
                                                  .productItem
                                                  .slug
                                                  .toString()] ==
                                              null)
                                          ? 0
                                          : state
                                                .currentSelectedColorForEveryProduct[widget
                                                .productItem
                                                .slug
                                                .toString()])))
                              ? MyTextWidget(
                                  "${LocaleKeys.last.tr()} ${(widget.productItem.variation?.firstWhere((element) {
                                        return element.type == "${widget.productItem.syncColorImages?[index].colorOption}${(state.currentColorSizeForCart?["choiceOption"] ?? "") == "" ? "" : "-"}${state.currentColorSizeForCart?["choiceOption"] ?? ""}";
                                      }, orElse: () => Variation()).qty ?? 0).round()}",
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        height: 1.1,
                                        fontSize: 7.sp,
                                        color: const Color(0xffFF6200),
                                      ),
                                )
                              : ((widget.initOfferPrice) >
                                        ((widget.productItem.variation
                                                ?.firstWhere((element) {
                                                  return element.type ==
                                                      "${widget.productItem.syncColorImages?[index].colorOption}${(state.currentColorSizeForCart?["choiceOption"] ?? "") == "" ? "" : "-"}${state.currentColorSizeForCart?["choiceOption"] ?? ""}";
                                                }, orElse: () => Variation())
                                                .offerPrice ??
                                            0)) &&
                                    (index !=
                                        ((state.currentSelectedColorForEveryProduct[widget
                                                    .productItem
                                                    .slug
                                                    .toString()] ==
                                                null)
                                            ? 0
                                            : state
                                                  .currentSelectedColorForEveryProduct[widget
                                                  .productItem
                                                  .slug
                                                  .toString()])))
                              ? MyTextWidget(
                                  "${LocaleKeys.get.tr()} ${(((widget.initOfferPrice - (widget.productItem.variation?.firstWhere((element) => element.type == "${widget.productItem.syncColorImages?[index].colorOption}${(state.currentColorSizeForCart?["choiceOption"] ?? "") == "" ? "" : "-"}${state.currentColorSizeForCart?["choiceOption"] ?? ""}", orElse: () => Variation()).offerPrice ?? 0)) / widget.initOfferPrice) * 100).toStringAsFixed(0)}%",
                                  style: context.textTheme.titleLarge?.bq
                                      .copyWith(
                                        color: const Color(0xff513AAF),
                                        fontSize: 7.sp,
                                      ),
                                )
                              : MyTextWidget(
                                  widget
                                          .productItem
                                          .syncColorImages?[index]
                                          .colorName ??
                                      "",
                                  style: context.textTheme.titleLarge?.sbt
                                      .copyWith(
                                        color: const Color(0xff505050),
                                        fontSize: 7.sp,
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
        ),
      ),
    );
  }

  Widget _availableSizeWidget() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.currentSelectedColorForEveryProduct[widget.productItem.slug
                  .toString()] !=
              c.currentSelectedColorForEveryProduct[widget.productItem.slug
                  .toString()] ||
          p.changeSizesForEveryProduct != c.changeSizesForEveryProduct ||
          p.getFirebaseSettingForNotificationStatus !=
              c.getFirebaseSettingForNotificationStatus ||
          p.currentColorSizeForCart?["choiceOption"] !=
              c.currentColorSizeForCart?["choiceOption"],
      builder: (context, state) {
        List<String> sizes = [];
        List<int> sizesQuantities = [];
        sizes = state.sizesForEachColor ?? [];
        int tappedIndex = 0;
        sizesQuantities = state.sizesQuantitiesForEachColor ?? [];
        tappedIndex = sizes.indexWhere(
          (element) =>
              element == state.currentColorSizeForCart?["choiceOption"],
        );

        if (sizes.isEmpty || sizesQuantities.isEmpty) {
          return const SizedBox.shrink();
        }
        if (debounce?.isActive ?? false) {
          debounce!.cancel();
        }
        if (tappedIndex == -1) {
          tappedIndex = (sizes.length) ~/ 2;
        }
        debounce = Timer(const Duration(milliseconds: 600), () {
          FirebaseAnalyticsService.logEventForSession(
            executedEventName: AnalyticsButtonsEventNameConst.SIZE_SLIDE,
            eventName: AnalyticsEventsConst.CHANGE_SIZE,
            extraParams: {
              'item_id': widget.productItem.productId.toString(),
              'item_name': widget.productItem.name.toString(),
              'brand': widget.productItem.brand!.name.toString(),
              'category': widget.productItem.categories!
                  .map((e) => e.name)
                  .toList()
                  .toString(),
              'selected_size': sizes[tappedIndex],
              'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
              'selected_color':
                  widget
                      .productItem
                      .colors?[state.currentSelectedColorForEveryProduct[widget
                              .productItem
                              .slug
                              .toString()] ??
                          0]
                      .name ??
                  '',
            },
          );

          print("sizesQuantities: ${sizesQuantities[tappedIndex]}");
          if (sizesQuantities[tappedIndex] == 0 &&
              !widget.collectedAfterOrdering) {
            Future.delayed(const Duration(milliseconds: 300), () {
              sizeIsNotAvailableNotifier.value = sizes[tappedIndex];
              colorIsNotAvailableNotifier.value = widget
                  .productItem
                  .colors?[state.currentSelectedColorForEveryProduct[widget
                          .productItem
                          .slug
                          .toString()] ??
                      0]
                  .option;
            });
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              sizeIsNotAvailableNotifier.value = null;
              colorIsNotAvailableNotifier.value = null;
            });
          }
        });

        return Padding(
          padding: EdgeInsets.all(12.0.h),
          child: SizedBox(
            width: 1.sw,
            height: 150.h,
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      SvgPicture.asset(
                        AppAssets.sizeIconSvg,
                        height: 14,
                        // ignore: deprecated_member_use
                        color: const Color(0xff1D1D1D),
                      ),
                      const SizedBox(width: 5),
                      MyTextWidget(
                        '${LocaleKeys.select_your_required_size.tr()}',
                        style: context.textTheme.titleLarge?.rq.copyWith(
                          color: const Color(0xff1D1D1D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                SizedBox(
                  width: 1.sw,
                  height: 21.h,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        _sizesType(" CM ", const Color(0xffF4F4F4)),
                        const SizedBox(width: 2),
                        _sizesType(" INC ", null),
                        const Spacer(),
                        _sizesType(" Standart ", const Color(0xffF4F4F4)),
                        const SizedBox(width: 2),
                        _sizesType(" EU ", null),
                        const SizedBox(width: 2),
                        _sizesType(" IN ", null),
                        const SizedBox(width: 2),
                        _sizesType(" US ", null),
                        const SizedBox(width: 2),
                        _sizesType(" Uk ", null),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 1.sw,
                  height: 52.h,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        homeBloc.add(
                          AddCurrentColorSizeEvent(
                            choice_1: widget
                                .productItem
                                .choiceOptions?[0]
                                .options
                                ?.firstWhere(
                                  (element) => element.option == sizes[index],
                                )
                                .name,
                            choiceOption: sizes[index],
                          ),
                        );
                      },
                      child: ValueListenableBuilder<String?>(
                        valueListenable: colorIsNotAvailableNotifier,
                        builder: (context, _colorIsNotAvailableNotifier, child) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: sizeIsNotAvailableNotifier,
                            builder: (context, _selectedSizeByUser, child) {
                              String variant =
                                  "${widget.currentColorOption}${(_selectedSizeByUser != null && widget.currentColorOption != "" ? "-" : "")}${_selectedSizeByUser ?? ""}";
                              bool isVariantRequestNotification = false;
                              if (sizes[index] == _selectedSizeByUser) {
                                state
                                    .firebaseSettingForNotificationModel
                                    ?.data
                                    ?.firebaseSettings
                                    ?.subscribedTopics
                                    ?.forEach((element) {
                                      if (element.topic?.contains(
                                            "product_availability_${widget.productIdForCashData}",
                                          ) ??
                                          false) {
                                        if (variant == "") {
                                          isVariantRequestNotification = false;
                                        } else if (element.variants!.contains(
                                          variant,
                                        )) {
                                          isVariantRequestNotification = true;
                                        }
                                      } else {
                                        isVariantRequestNotification = false;
                                      }
                                    });
                              }

                              return Stack(
                                children: [
                                  _sizesWidget(
                                    '${widget.productItem.choiceOptions?[0].options?.firstWhere(
                                          (element) => element.option == sizes[index],
                                          orElse: () => Options(name: "", option: ""),
                                        ).name ?? ""} ',
                                    "",
                                    sizeIsNotAvailableNotifier.value ==
                                            sizes[index]
                                        ? const Color(0xffFFF2F2)
                                        : sizes[index] ==
                                              state
                                                  .currentColorSizeForCart?["choiceOption"]
                                        ? const Color(0xffF4F4F4)
                                        : null,
                                    (sizesQuantities[index] == 0 &&
                                            (!widget.collectedAfterOrdering))
                                        ? const Color(0xffFF5F61)
                                        : sizes[index] ==
                                              state
                                                  .currentColorSizeForCart?["choiceOption"]
                                        ? const Color(0xff513AAF)
                                        : null,
                                  ),
                                  isVariantRequestNotification
                                      ? Positioned(
                                          left: 8,
                                          top: 0,
                                          child: SvgPicture.asset(
                                            AppAssets.notificationIconSvg,
                                            height: 12,
                                            // ignore: deprecated_member_use
                                            color: const Color(0xff513AAF),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    itemCount:
                        widget.productItem.choiceOptions?[0].options?.length,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 15.h,
                  width: 1.sw,
                  child: ValueListenableBuilder<String?>(
                    valueListenable: sizeIsNotAvailableNotifier,
                    builder: (context, selectedSizeByUser, child) {
                      return sizeIsNotAvailableNotifier.value != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyTextWidget(
                                  '${widget.productItem.choiceOptions?[0].options?.firstWhere((element) => element.option == state.currentColorSizeForCart?["choiceOption"]).name ?? ""} ',
                                  style: context.textTheme.titleLarge?.bq
                                      .copyWith(
                                        height: 1.1,
                                        fontSize: 11,
                                        color: const Color(0xffFF5F61),
                                      ),
                                ),
                                MyTextWidget(
                                  LocaleKeys.not_available_now_stock.tr(),
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        height: 1.0,
                                        fontSize: 11,
                                        color: const Color(0xffFF5F61),
                                      ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.recommendPng,
                                  width: 14,
                                  height: 14,
                                ),
                                const SizedBox(width: 5),
                                MyTextWidget(
                                  '${widget.productItem.choiceOptions?[0].options?.firstWhere(
                                        (element) => element.option == state.currentColorSizeForCart?["choiceOption"],
                                        orElse: () => Options(name: "", option: ""),
                                      ).name ?? ""} ',
                                  style: context.textTheme.titleLarge?.bq
                                      .copyWith(
                                        height: 1.3,
                                        fontSize: 11,
                                        color: const Color(0xff404040),
                                      ),
                                ),
                                MyTextWidget(
                                  "${LocaleKeys.recommended.tr()} ",
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        height: 1.1,
                                        fontSize: 11,
                                        color: const Color(0xff404040),
                                      ),
                                ),
                                MyTextWidget(
                                  "${LocaleKeys.size.tr()} ",
                                  style: context.textTheme.titleLarge?.bq
                                      .copyWith(
                                        height: 1.1,
                                        fontSize: 11,
                                        color: const Color(0xff404040),
                                      ),
                                ),
                                MyTextWidget(
                                  "${LocaleKeys.for_you.tr()} ",
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        height: 1.1,
                                        fontSize: 11,
                                        color: const Color(0xff404040),
                                      ),
                                ),
                                (sizesQuantities[tappedIndex] < 11 &&
                                        (!widget.collectedAfterOrdering))
                                    ? MyTextWidget(
                                        "${LocaleKeys.last.tr()} ${sizesQuantities[tappedIndex]}",
                                        style: context.textTheme.titleLarge?.rq
                                            .copyWith(
                                              height: 1.1,
                                              fontSize: 11,
                                              color: const Color(0xffFF6200),
                                            ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sizesType(String text, Color? color) {
    return Container(
      alignment: Alignment.center,
      height: 22.h,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color ?? const Color(0xffFCFCFC),
        border: Border.all(color: const Color(0xffD3D3D3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: MyTextWidget(
        text,
        style: context.textTheme.titleLarge?.rq.copyWith(
          fontSize: 11,
          color: const Color(0xff1D1D1D),
        ),
      ),
    );
  }

  Widget _sizesWidget(
    String text,
    String? num,
    Color? color,
    Color? borderColor,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: LanguageService.languageCode != "ar" ? 0 : 3,
        right: LanguageService.languageCode == "ar" ? 0 : 3,
      ),
      alignment: Alignment.center,
      height: 46.h,
      width: 60,
      decoration: BoxDecoration(
        color: color ?? const Color(0xffFCFCFC),
        border: Border.all(color: borderColor ?? const Color(0xffD3D3D3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTextWidget(
            text,
            style: context.textTheme.titleLarge?.rq.copyWith(
              fontSize: 11,
              color: const Color(0xff1D1D1D),
            ),
          ),
          num == null || num == ""
              ? const SizedBox.shrink()
              : MyTextWidget(
                  num,
                  style: context.textTheme.titleLarge?.rq.copyWith(
                    fontSize: 11,
                    color: const Color(0xff1D1D1D),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _headerWidget() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.getCurrencyForCountryModel !=
              current.getCurrencyForCountryModel ||
          previous.currentColorSizeForCart?["choiceOption"] !=
              current.currentColorSizeForCart?["choiceOption"] ||
          previous.currentSelectedColorForEveryProduct !=
              current.currentSelectedColorForEveryProduct,
      builder: (context, state) {
        return ProductDetailsSheetHeader(
          productId: widget.productItem.productId ?? 0,
          currentVariant: widget.currentVariant,
          redeemVariantPrice:
              HelperFunctions.truncateToDecimalPlaces(
                widget.redeemVariantPrice,
                state
                    .getCurrencyForCountryModel!
                    .data!
                    .currency!
                    .decimalDigits!,
              ) *
              state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!,
          isRedeem: widget.isRedeem,
          redeemPrice:
              HelperFunctions.truncateToDecimalPlaces(
                widget.redeemPrice,
                state
                    .getCurrencyForCountryModel!
                    .data!
                    .currency!
                    .decimalDigits!,
              ) *
              state.getCurrencyForCountryModel!.data!.currency!.exchangeRate!,
          currentActiveTab: widget.currentActiveTab,
          initOfferPrice:
              (HelperFunctions.truncateToDecimalPlaces(
                        widget.initOfferPrice,
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
                          .exchangeRate!)
                  .toString(),
          initPrice:
              (HelperFunctions.truncateToDecimalPlaces(
                        widget.initPrice,
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
                          .exchangeRate!)
                  .toString(),
          shippingCost: widget.productItem.shippingCost ?? 0,
          decimalPoint: state.startingSetting?.decimalPointSettings ?? 2,
          priceSymbol:
              state.getCurrencyForCountryModel!.data!.currency!.symbol ?? "",
          addToBagButtonShapeNotifier: widget.addToBagButtonShapeNotifier,
          price:
              (HelperFunctions.truncateToDecimalPlaces(
                        widget.productItem.price!,
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
                          .exchangeRate!)
                  .toString(),
          offerPrice:
              (HelperFunctions.truncateToDecimalPlaces(
                        widget.productItem.offerPrice!,
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
                          .exchangeRate!)
                  .toString(),
        );
      },
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      children: [
        12.verticalSpace,
        Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Container(
              padding: HWEdgeInsets.symmetric(vertical: 20),
              margin: HWEdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff3c3c3c),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1a000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.shareSvg,
                      // ignore: deprecated_member_use
                      color: Colors.white,
                      height: 20,
                    ),
                    10.horizontalSpace,
                    MyTextWidget(
                      '${LocaleKeys.send.tr()}',
                      style: context.textTheme.bodyLarge?.rq.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}
