import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/config/theme/typography.dart';

import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';

import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/pages/cart_page_new.dart';

import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/language_service.dart';

import 'package:tuple/tuple.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as filter;
import 'dart:ui' as ui;

import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_item.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';

class FlashDealProductsPage extends StatefulWidget {
  const FlashDealProductsPage({Key? key}) : super(key: key);

  @override
  State<FlashDealProductsPage> createState() => _FlashDealProductsPageState();
}

class _FlashDealProductsPageState extends State<FlashDealProductsPage> {
  final ValueNotifier<Tuple2<int, int>> setThisEnabledNotifier =
      ValueNotifier(Tuple2(-1, -1));
  late BoutiqueBloc boutiqueBloc;
  List<filter.Products> products = [];
  final ScrollController scrollController = ScrollController();
  ValueNotifier<int> tapIndexToAddProductToCart = ValueNotifier(-1);
  final PanelController panelControllerForCart = PanelController();
  late AuthBloc authBloc;

  late HomeBloc homeBloc;
  final ValueNotifier<String?> productNotAvailableNotifier =
      ValueNotifier(null);
  final ValueNotifier<int> currentActiveTab = ValueNotifier(-1);
  final ValueNotifier<bool> loadingForRquestProductDetails =
      ValueNotifier(false);

  int currentSelectedColor = -1;
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  Map<String, Key> reRenderingListViewKey = {};
  Map<String, int> lastIndexRequestedInEachMainCategoryForPrefetchBoutiques =
      {};

  String selectedCategorySlug = "Empty";
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  final PageController pageController = PageController();
  final FocusNode focusNode = FocusNode();
  String phoneNumber = '';
  int isVisWhatsApp = 0;
  Timer? debounce;
  bool changeAppearSizeForProduct = true;
  void _listenToScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(Duration(milliseconds: 600), () {
      if (setThisEnabledNotifier.value.item1 != -1) {
        setThisEnabledNotifier.value = Tuple2(-1, -1);
      }
      if (scrollController.offset >=
          (scrollController.position.maxScrollExtent * 0.6)) {
        if (boutiqueBloc.state.isGettingProductListingWithPagination) return;
        if (boutiqueBloc.state.getProductListingWithFiltersPaginationModels[
                "*flashDeal*withoutFilter"] ==
            null) {
          return;
        }
        if (boutiqueBloc
            .state
            .getProductListingWithFiltersPaginationModels[
                "*flashDeal*withoutFilter"]!
            .hasReachedMax) {
          return;
        }

        boutiqueBloc.add(GetProductsWithFiltersEvent(
            context: context,
            fromNotification: false,
            limit: 10,
            cashedOrginalBoutique: true,
            boutiqueSlug: "*flashDeal*",
            getWithPagination: true,
            offset: 2));
      }
    });
  }

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);

    homeBloc = BlocProvider.of<HomeBloc>(context);
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    scrollController.addListener(_listenToScroll);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_listenToScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
      print(error.toString());
    };
    return ValueListenableBuilder<int>(
      valueListenable: tapIndexToAddProductToCart,
      builder: (context, tapIndex, _) => Scaffold(
        appBar: tapIndex == -1
            ? null
            : TrydosAppBar(
                appBarParams: AppBarParams(
                    automaticallyImplyLeading: false,
                    hasLeading: false,
                    leading: SizedBox.shrink(),
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
                            int qtyItemsInCart =
                                state.cartCollection?.length ?? 0;
                            /*  state.cartCollection?.forEach(
                              (element) {
                                qtyItemsInCart =
                                    qtyItemsInCart + (element.quantity ?? 0);
                              },
                            );*/

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
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: 150,
                    height: 30,
                    child: MyTextWidget(
                      textAlign: TextAlign.start,
                      "${LocaleKeys.flash_deal.tr()}",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  BlocBuilder<BoutiqueBloc, BoutiqueState>(
                      buildWhen: (previous, current) =>
                          previous
                                  .getProductListingWithFiltersPaginationModels[
                                      "*flashDeal*withoutFilter"]
                                  ?.paginationStatus !=
                              current
                                  .getProductListingWithFiltersPaginationModels[
                                      "*flashDeal*withoutFilter"]
                                  ?.paginationStatus ||
                          previous.isGettingProductListingWithPagination !=
                              current.isGettingProductListingWithPagination,
                      builder: (context, state) {
                        products =
                            state.getProductListingWithFiltersPaginationModels[
                                        "*flashDeal*withoutFilter"] ==
                                    null
                                ? []
                                : state
                                    .getProductListingWithFiltersPaginationModels[
                                        "*flashDeal*withoutFilter"]!
                                    .items;
                        return products.isNullOrEmpty
                            ? SizedBox.shrink()
                            : Container(
                                width: 1.sw,
                                height:
                                    state.isGettingProductListingWithPagination
                                        ? 1.sh - 100
                                        : 1.sh - 70,
                                child: ValueListenableBuilder<Tuple2<int, int>>(
                                    valueListenable: setThisEnabledNotifier,
                                    builder: (context, slidingMode, _) {
                                      return Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            // حساب عرض العنصر مع مراعاة المسافات (مثلاً 16 بكسل)
                                            final double spacing = 5;
                                            final int crossAxisCount = 2;
                                            final double totalSpacing =
                                                spacing * (crossAxisCount + 1);
                                            final double itemWidth =
                                                (constraints.maxWidth -
                                                        totalSpacing) /
                                                    crossAxisCount;
                                            final double itemHeight = 375;

                                            return Column(
                                              children: [
                                                Expanded(
                                                  child: GridView.builder(
                                                    shrinkWrap: false,
                                                    addRepaintBoundaries: false,
                                                    addAutomaticKeepAlives:
                                                        false,
                                                    addSemanticIndexes: false,
                                                    cacheExtent: 0,
                                                    controller:
                                                        scrollController,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          crossAxisCount,
                                                      mainAxisSpacing: spacing,
                                                      crossAxisSpacing: spacing,
                                                      childAspectRatio:
                                                          itemWidth /
                                                              itemHeight,
                                                    ),
                                                    itemCount: products.length,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          GetIt.I<HomeBloc>().add(
                                                              ChangeStatusOFGetProductsDetailsToSuccessEvent(
                                                                  isStatusInitaial:
                                                                      true));

                                                          Future.delayed(
                                                              Duration(
                                                                  milliseconds:
                                                                      300),
                                                              () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (ctx) =>
                                                                              ProductDetailsPage(
                                                                        productItem:
                                                                            products[index],
                                                                      ),
                                                                    ),
                                                                  ));
                                                        },
                                                        child: ProductItem(
                                                          fromHomePage: false,
                                                          fromFlashDeal: true,
                                                          tapIndexToAddProductToCart:
                                                              tapIndexToAddProductToCart,
                                                          key: TestVariables
                                                                  .kTestMode
                                                              ? Key(
                                                                  '"featuresPtoduct"$index')
                                                              : null,
                                                          productItem:
                                                              products[index],
                                                          itemIndex: index,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    }),
                              );
                      }),
                  BlocBuilder<BoutiqueBloc, BoutiqueState>(
                      buildWhen: (previous, current) =>
                          previous.isGettingProductListingWithPagination !=
                          current.isGettingProductListingWithPagination,
                      builder: (context, state) {
                        if (state.isGettingProductListingWithPagination) {
                          return Center(
                            child: TrydosLoader(),
                          );
                        }
                        return SizedBox.shrink();
                      })
                ],
              ),
              BlocBuilder<BoutiqueBloc, BoutiqueState>(
                  buildWhen: (previous, current) {
                return previous
                        .getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"]
                        ?.paginationStatus !=
                    current
                        .getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"]
                        ?.paginationStatus;
              }, builder: (context, state) {
                products = state.getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"] ==
                        null
                    ? []
                    : state
                        .getProductListingWithFiltersPaginationModels[
                            "*flashDeal*withoutFilter"]!
                        .items;

                if (tapIndex != -1) {
                  homeBloc.add(IsChangedVariationWhenQtyZeroEvent(
                      isChangedVariationWhenQtyZero: false));

                  /* homeBloc.add(IsChangedvariationWhenQtyZeroEvent(
                                          isChangedvariationWhenQtyZero: false));
                                      currentSelectedColorAfterChangeVariant = -1;*/
                  changeAppearSizeForProduct = true;

                  homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
                      fromListingPage: true,
                      productSlug: products[tapIndex].slug,
                      productId: products[tapIndex].productId.toString()));

                  loadingForRquestProductDetails.value = true;
                  Future.delayed(Duration(milliseconds: 600),
                      () => loadingForRquestProductDetails.value = false);
                } else {
                  currentActiveTab.value = 0;

                  return SizedBox.shrink();
                }
                return ValueListenableBuilder<bool>(
                    valueListenable: loadingForRquestProductDetails,
                    builder: (context, _loadingForRquestProductDetails, _) {
                      return Positioned(
                          bottom: 0,
                          child: _loadingForRquestProductDetails
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  child: TrydosLoader(
                                    size: 15,
                                  ),
                                )
                              : Container(
                                  height: tapIndex == -1 ? 0 : (1.sh),
                                  width: 1.sw,
                                  child: BlocBuilder<HomeBloc, HomeState>(
                                      buildWhen: (previous, current) =>
                                          previous.getProductDetailWithoutSimilarRelatedProductsStatus != current.getProductDetailWithoutSimilarRelatedProductsStatus ||
                                          previous.getCartOverviewStatus !=
                                              current.getCartOverviewStatus ||
                                          previous.currentSelectedColorForEveryProduct !=
                                              current
                                                  .currentSelectedColorForEveryProduct ||
                                          previous.enableAddToCardAfterChangeVariantZero !=
                                              current
                                                  .enableAddToCardAfterChangeVariantZero ||
                                          previous.isChangedvariationWhenQtyZero !=
                                              current
                                                  .isChangedvariationWhenQtyZero ||
                                          previous.cartCollection !=
                                              current.cartCollection,
                                      builder: (context, state) {
                                        String productId = products[tapIndex]
                                            .productId
                                            .toString();
                                        String productSlug =
                                            products[tapIndex].slug.toString();
                                        List<String> syncColorNames = [];
                                        List<filter.SyncColorImage>
                                            syncColorImagesFromListing =
                                            products[tapIndex]
                                                    .syncColorImages ??
                                                [];
                                        List<filter.Color>? colorsFromListing =
                                            products[tapIndex].colors ?? [];

                                        currentSelectedColor =
                                            state.currentSelectedColorForEveryProduct[
                                                    productSlug] ??
                                                (products[tapIndex]
                                                            .syncColorImages
                                                            ?.length ??
                                                        0) ~/
                                                    2;
                                        String currentSelectedColorName =
                                            ((products[tapIndex]
                                                            .colors
                                                            ?.length ??
                                                        0) >
                                                    0)
                                                ? products[tapIndex]
                                                        .colors![
                                                            currentSelectedColor]
                                                        .name ??
                                                    ""
                                                : "";

                                        String currentVariantType =
                                            "${currentSelectedColorName != "" ? currentSelectedColorName : ""}" +
                                                "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") && (currentSelectedColorName != "") ? "-" : ""}" +
                                                "${(state.currentColorSizeForCart?["size"] != null && (state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]?.product?.choiceOptions?.isNullOrEmpty ?? false) && state.currentColorSizeForCart?["size"] != "") ? "${state.currentColorSizeForCart?["size"]}" : ""}";

                                        Variation? currentVariation = state
                                            .cachedProductWithoutRelatedProductsModel[
                                                products[tapIndex]
                                                    .productId
                                                    .toString()]
                                            ?.product
                                            ?.variation
                                            ?.firstWhere(
                                          (element) => element.type!
                                              .contains(currentVariantType),
                                          orElse: () {
                                            return Variation(
                                                variantNotifyForUser: false);
                                          },
                                        );

                                        if (state
                                                .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                            GetProductDetailWithoutSimilarRelatedProductsStatus
                                                .success) {
                                          for (var i = 0;
                                              i <
                                                  (products[tapIndex]
                                                          .syncColorImages
                                                          ?.length ??
                                                      0);
                                              i++) {
                                            syncColorNames.add(
                                                products[tapIndex]
                                                        .syncColorImages?[i]
                                                        .colorName ??
                                                    "");
                                          }
                                          state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  products[tapIndex]
                                                      .productId
                                                      .toString()]!
                                              .product
                                              ?.syncColorImages
                                              ?.forEach(
                                            (element) {
                                              if (!syncColorNames.contains(
                                                  element.colorName)) {
                                                syncColorImagesFromListing
                                                    .add(element);
                                              }
                                            },
                                          );

                                          state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  products[tapIndex]
                                                      .productId
                                                      .toString()]!
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
                                        }
                                        currentSelectedColor =
                                            state.currentSelectedColorForEveryProduct[
                                                    productSlug] ??
                                                (products[tapIndex]
                                                            .syncColorImages
                                                            ?.length ??
                                                        0) ~/
                                                    2;

                                        if (state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                GetProductDetailWithoutSimilarRelatedProductsStatus
                                                    .failure &&
                                            (prefsRepository.isTokenExpired ??
                                                false ||
                                                    prefsRepository
                                                            .marketToken ==
                                                        "" ||
                                                    prefsRepository
                                                            .marketToken ==
                                                        null)) {
                                          Future.delayed(
                                            Duration(seconds: 5),
                                            () {
                                              homeBloc.add(
                                                  GetProductDatailsWithoutRelatedProductsEvent(
                                                      fromListingPage: true,
                                                      productSlug:
                                                          products[tapIndex]
                                                              .slug,
                                                      productId:
                                                          products[tapIndex]
                                                              .productId
                                                              .toString()));
                                            },
                                          );
                                        }
                                        Future.delayed(
                                            Duration(milliseconds: 300), () {
                                          if ((state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                  GetProductDetailWithoutSimilarRelatedProductsStatus
                                                      .success &&
                                              tapIndex != -1)) {
                                            if (state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        products[tapIndex]
                                                            .productId
                                                            .toString()]
                                                    ?.product
                                                    ?.countryIsRestricted ==
                                                true) {
                                              productNotAvailableNotifier
                                                      .value =
                                                  LocaleKeys
                                                      .product_is_not_available_in_your_country
                                                      .tr();
                                            } else if (state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        products[tapIndex]
                                                            .productId
                                                            .toString()]
                                                    ?.product
                                                    ?.availableQuantity ==
                                                false) {
                                              productNotAvailableNotifier
                                                      .value =
                                                  LocaleKeys
                                                      .this_product_is_not_available_in_store
                                                      .tr();
                                            } else {
                                              productNotAvailableNotifier
                                                  .value = null;
                                            }
                                          }
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 300), () {
                                          if (state
                                                  .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                              GetProductDetailWithoutSimilarRelatedProductsStatus
                                                  .failure) {
                                            tapIndexToAddProductToCart.value =
                                                -1;
                                          }
                                        });
                                        homeBloc.add(AddSizesForColorsEvent(
                                            currentColorName: !products[tapIndex]
                                                    .colors
                                                    .isNullOrEmpty
                                                ? products[tapIndex].colors![currentSelectedColor].name ??
                                                    ""
                                                : "",
                                            variation: state.cachedProductWithoutRelatedProductsModel[
                                                        products[tapIndex]
                                                            .productId
                                                            .toString()] !=
                                                    null
                                                ? state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                products[tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                            .product !=
                                                        null
                                                    ? state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]!
                                                        .product!
                                                        .variation
                                                    : null
                                                : null));
                                        if (productId != "" &&
                                            tapIndex != -1 &&
                                            state.getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                GetProductDetailWithoutSimilarRelatedProductsStatus
                                                    .success &&
                                            changeAppearSizeForProduct) {
                                          if (!state
                                                  .cachedProductWithoutRelatedProductsModel
                                                  .containsKey(productId) ||
                                              (state.cachedProductWithoutRelatedProductsModel[
                                                          productId] !=
                                                      null
                                                  ? state
                                                              .cachedProductWithoutRelatedProductsModel[
                                                                  productId]!
                                                              .product !=
                                                          null
                                                      ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productId]!
                                                          .product!
                                                          .choiceOptions
                                                          .isNullOrEmpty
                                                      : true
                                                  : true)) {
                                            homeBloc.add(
                                                AddCurrentColorSizeEvent(
                                                    choice_1: null));
                                          } else if (!(state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                      productId] !=
                                                  null
                                              ? state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              productId]!
                                                          .product !=
                                                      null
                                                  ? state
                                                      .cachedProductWithoutRelatedProductsModel[
                                                          productId]!
                                                      .product!
                                                      .choiceOptions
                                                      .isNullOrEmpty
                                                  : true
                                              : true)) {
                                            String sizeSelect = (state
                                                            .cachedProductWithoutRelatedProductsModel[
                                                                productId]!
                                                            .product!
                                                            .choiceOptions
                                                            ?.length ??
                                                        0) ==
                                                    0
                                                ? ""
                                                : state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            productId]!
                                                        .product!
                                                        .choiceOptions![0]
                                                        .options?[(state
                                                                    .cachedProductWithoutRelatedProductsModel[
                                                                        productId]!
                                                                    .product
                                                                    ?.choiceOptions?[
                                                                        0]
                                                                    .options
                                                                    ?.length ??
                                                                0) ~/
                                                            2]
                                                        .name ??
                                                    "";

                                            homeBloc.add(
                                                AddCurrentColorSizeEvent(
                                                    choice_1: sizeSelect));
                                          }
                                          homeBloc.add(
                                              IsChangedVariationWhenQtyZeroEvent(
                                                  isChangedVariationWhenQtyZero:
                                                      true));

                                          currentActiveTab.value = 3;
                                          Future.delayed(
                                              Duration(milliseconds: 600), () {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              panelControllerForCart.open();
                                              changeAppearSizeForProduct =
                                                  false;
                                            });
                                          });
                                        }

                                        return state
                                                        .getProductDetailWithoutSimilarRelatedProductsStatus ==
                                                    GetProductDetailWithoutSimilarRelatedProductsStatus
                                                        .loading ||
                                                state.enableAddToCardAfterChangeVariantZero !=
                                                    EnableAddToCardAfterChangeVariantZero
                                                        .success ||
                                                state.cachedProductWithoutRelatedProductsModel[
                                                        products[tapIndex]
                                                            .productId
                                                            .toString()] ==
                                                    null
                                            ? Container(
                                                width: 1.sw,
                                                height: 1.sh - 150,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.3),
                                                child: TrydosLoader(
                                                  size: 25,
                                                ),
                                              )
                                            : ProductDetailsBottomSheet(
                                                initOfferPrice:
                                                    (products[tapIndex]
                                                                .offerPrice ??
                                                            0)
                                                        .toString(),
                                                initPrice:
                                                    (products[tapIndex].price ??
                                                            0)
                                                        .toString(),
                                                isGetFullProductDetails: false,
                                                productNotAvailableNotifier:
                                                    productNotAvailableNotifier,
                                                currentActiveTab:
                                                    currentActiveTab,
                                                qtyForproductWithoutVariant: state
                                                    .cachedProductWithoutRelatedProductsModel[
                                                        products[tapIndex]
                                                            .productId
                                                            .toString()]
                                                    ?.product
                                                    ?.availableQuantity,
                                                collectedAfterOrdering: state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.collectedAfterOrdering ==
                                                    1,
                                                tapIndexToAddProductToCart:
                                                    tapIndexToAddProductToCart,
                                                fromListingPage: true,
                                                productIdForCashData:
                                                    products[tapIndex]
                                                        .productId
                                                        .toString(),
                                                panelController:
                                                    panelControllerForCart,
                                                productSlugForTopic: state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.slug ??
                                                    "",
                                                productDescription:
                                                    HtmlParser.parseHTML(
                                                            products[tapIndex]
                                                                    .details ??
                                                                "")
                                                        .text,
                                                countOfPieces: state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()] !=
                                                        null
                                                    ? state
                                                                .cachedProductWithoutRelatedProductsModel[products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                                .cachedProductWithoutRelatedProductsModel[products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                                .product!
                                                                .countOfPieces ??
                                                            0
                                                        : 0
                                                    : 0,
                                                addToBagButtonShapeNotifier:
                                                    addToBagButtonShapeNotifier,
                                                currentColornum: products[
                                                            tapIndex]
                                                        .colors
                                                        .isNullOrEmpty
                                                    ? ''
                                                    : products[tapIndex]
                                                            .colors![
                                                                currentSelectedColor]
                                                            .color ??
                                                        "",
                                                boutiqueIcon: state.cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()] !=
                                                        null
                                                    ? state
                                                                .cachedProductWithoutRelatedProductsModel[
                                                                    products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .boutique !=
                                                                null
                                                            ? state.cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!.product!.boutique!.icon !=
                                                                    null
                                                                ? state
                                                                        .cachedProductWithoutRelatedProductsModel[products[tapIndex].productId.toString()]!
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
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()] !=
                                                        null
                                                    ? state
                                                                .cachedProductWithoutRelatedProductsModel[products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                                .product !=
                                                            null
                                                        ? state
                                                                    .cachedProductWithoutRelatedProductsModel[products[
                                                                            tapIndex]
                                                                        .productId
                                                                        .toString()]!
                                                                    .product!
                                                                    .boutique !=
                                                                null
                                                            ? state
                                                                .cachedProductWithoutRelatedProductsModel[products[
                                                                        tapIndex]
                                                                    .productId
                                                                    .toString()]!
                                                                .product!
                                                                .boutique!
                                                                .id!
                                                            : 0
                                                        : 0
                                                    : 0,
                                                currentColorName: products[
                                                            tapIndex]
                                                        .colors
                                                        .isNullOrEmpty
                                                    ? ''
                                                    : products[tapIndex]
                                                            .colors![
                                                                currentSelectedColor]
                                                            .name ??
                                                        "",
                                                productItem:
                                                    products[tapIndex].copyWith(
                                                  price: currentVariation
                                                              ?.price !=
                                                          null
                                                      ? currentVariation?.price
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.price,
                                                  offerPrice: currentVariation
                                                              ?.offerPrice !=
                                                          null
                                                      ? currentVariation
                                                          ?.offerPrice
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.offerPrice,
                                                  priceFormatted: currentVariation
                                                              ?.priceFormated !=
                                                          null
                                                      ? currentVariation
                                                          ?.priceFormated
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.priceFormatted,
                                                  offerPriceFormatted: currentVariation
                                                              ?.offerPriceFormated !=
                                                          null
                                                      ? currentVariation
                                                          ?.offerPriceFormated
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.offerPriceFormatted,
                                                  availableQuantity: state
                                                                  .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()] ==
                                                          null
                                                      ? 0
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.availableQuantity,
                                                  choiceOptions: state
                                                                  .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()] ==
                                                          null
                                                      ? []
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.choiceOptions,
                                                  colors: colorsFromListing,
                                                  images: state.cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()] ==
                                                          null
                                                      ? []
                                                      : state
                                                          .cachedProductWithoutRelatedProductsModel[
                                                              products[tapIndex]
                                                                  .productId
                                                                  .toString()]!
                                                          .product
                                                          ?.images,
                                                  syncColorImages:
                                                      syncColorImagesFromListing,
                                                ),
                                                currentColor:
                                                    currentSelectedColor,
                                                maxAllowedToAddCart: state
                                                        .cachedProductWithoutRelatedProductsModel[
                                                            products[tapIndex]
                                                                .productId
                                                                .toString()]
                                                        ?.product
                                                        ?.maxAllowedQty ??
                                                    "0",
                                              );
                                      }),
                                ));
                    });
              })
            ],
          ),
        ),
      ),
    );
  }
}
