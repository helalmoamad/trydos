import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/app_widgets/app_bottom_navigation_bar.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/pages/home_page.dart';
import 'package:trydos/features/home/presentation/pages/product_details_display_pictures_page.dart';
import 'package:trydos/features/home/presentation/pages/cart_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/display_sizes_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/features/home/presentation/widgets/product_stories_section/story/widget/stories_list.dart';
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

import '../manager/home_state.dart';
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
    this.productIdForOpeningChatDirectly,
  });

  final productListingModel.Products? productItem;
  final String? productIdForOpeningChatDirectly;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ScrollController scrollController = ScrollController();
  late productListingModel.Products productItem;
  late HomeBloc homeBloc;
  late ChatBloc chatBloc;
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  bool enable = true;
  double? valueOnY;
  final PanelController panelControllerForBuyersCameraShots = PanelController();
  final PanelController panelControllerForReels = PanelController();

  @override
  void initState() {
    if (widget.productItem != null) {
      productItem = widget.productItem!;
    }
    homeBloc = BlocProvider.of<HomeBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);
    if (widget.productItem != null) {
      homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
          productId: productItem.id.toString()));
    }
    Future.delayed(Duration(seconds: 3), () {
      homeBloc.add(GetAndAddCountViewOfProductEvent(
          productId: productItem.id.toString()));
      homeBloc.add(GetCommentForProductEvent(
          productId: widget.productIdForOpeningChatDirectly ??
              productItem.id.toString()));
      homeBloc.add(GetStoryForProductEvent(
          productId: widget.productIdForOpeningChatDirectly ??
              productItem.id.toString()));
    });
    chatBloc.add(GetSharedProductCountEvent(
        productId: widget.productIdForOpeningChatDirectly ??
            productItem.id.toString()));

    super.initState();
  }

  @override
  void didChangeDependencies() {
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
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Scaffold(
            appBar: TrydosAppBar(
              appBarParams: AppBarParams(
                  scrolledUnderElevation: 0,
                  backIconColor: Colors.black,
                  action: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
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
                              eventName: AnalyticsEventsConst.buttonClicked,
                              executedEventName: AnalyticsExecutedEventNameConst
                                  .showShoppingBagButton,
                            );
                          },
                          child: SvgPicture.asset(AppAssets.bagsSvg)),
                    ),
                    LanguageService.rtl ? Spacer() : SizedBox.shrink(),
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
                      child: MyTextWidget('Failed To Get Product Details'),
                    );
                  }
                  productItem = state
                      .productContentForStatusOfOpeningProductDetailsDirectly!;
                }
                return BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) =>
                      p.getStoriesForProductStatus !=
                          c.getStoriesForProductStatus ||
                      p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                          c
                              .getProductDetailWithoutSimilarRelatedProductsStatus ||
                      p.currentSelectedColorForEveryProduct !=
                          c.currentSelectedColorForEveryProduct ||
                      p.cachedProductWithoutRelatedProductsModel !=
                          c.cachedProductWithoutRelatedProductsModel,
                  builder: (context, state) {
                    String productId = productItem.id.toString();
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

                    int currentSelectedColor =
                        state.currentSelectedColorForEveryProduct[productId] ??
                            (productItem.syncColorImages?.length ?? 0) ~/ 2;

                    homeBloc.add(AddSizesFotColorsEvent(
                        currentColorName: !productItem.colors.isNullOrEmpty
                            ? productItem.colors![currentSelectedColor].name ??
                                ""
                            : "",
                        variation:
                            state.cachedProductWithoutRelatedProductsModel[
                                        productItem.id.toString()] !=
                                    null
                                ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem.id.toString()]!
                                    .product!
                                    .variation
                                : null));

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
                                    itemCount: productItem
                                            .syncColorImages.isNullOrEmpty
                                        ? productItem.images!.length
                                        : !productItem
                                                .syncColorImages![
                                                    currentSelectedColor]
                                                .images
                                                .isNullOrEmpty
                                            ? productItem
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
                                              images: productItem
                                                      .syncColorImages
                                                      .isNullOrEmpty
                                                  ? productItem.images ?? []
                                                  : productItem
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
                                          orginalHeight: productItem
                                                  .syncColorImages.isNullOrEmpty
                                              ? double.parse(productItem
                                                  .images![index]
                                                  .originalHeight!)
                                              : double.parse(productItem
                                                  .syncColorImages![
                                                      currentSelectedColor]
                                                  .images![index]
                                                  .originalHeight!),
                                          orginalWidth: productItem
                                                  .syncColorImages.isNullOrEmpty
                                              ? double.parse(productItem
                                                  .images![index]
                                                  .originalWidth!)
                                              : double.parse(productItem
                                                  .syncColorImages![
                                                      currentSelectedColor]
                                                  .images![index]
                                                  .originalWidth!),
                                          imageUrl: productItem
                                                  .syncColorImages.isNullOrEmpty
                                              ? productItem
                                                  .images![index].filePath!
                                              : productItem
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
                            productId: productItem.id.toString(),
                            orginalHeight: double.parse(
                                productItem.thumbnail!.originalHeight!),
                            orginalWidth: double.parse(
                                productItem.thumbnail!.originalWidth!),
                            brand: productItem.brand,
                            productName: productItem.name ?? "",
                            thumbnail: productItem.thumbnail!.filePath ?? '',
                            colorName: !productItem
                                        .syncColorImages.isNullOrEmpty &&
                                    !productItem.syncColorImages![0].images
                                        .isNullOrEmpty
                                ? productItem
                                        .syncColorImages![currentSelectedColor]
                                        .colorName ??
                                    " "
                                : " ",
                          ),

                          if (!state.cachedProductWithoutRelatedProductsModel
                              .containsKey(productItem.id.toString())) ...{
                            SizedBox.shrink()
                          } else ...{
                            ProductDetailsDescriptionWidget(
                              description: productItem.details ?? " ",
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            BadgesList(
                              lable: state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productItem.id.toString()]!
                                      .product!
                                      .labels ??
                                  [],
                            ),
                          },
                          SizedBox(
                            height: 15,
                          ),
                          if (!state.cachedProductWithoutRelatedProductsModel
                                  .containsKey(productItem.id.toString()) ||
                              state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem.id.toString()]!
                                  .product!
                                  .descriptors
                                  .isNullOrEmpty) ...{
                            SizedBox.shrink()
                          } else ...{
                            SizedBox(
                                height: 52,
                                child: ScrollConfiguration(
                                  behavior: const CupertinoScrollBehavior(),
                                  child: ListView.separated(
                                    itemCount: state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem.id.toString()]!
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
                                                    productItem.id.toString()]!
                                                .product!
                                                .descriptors![index]
                                                .descriptorGroup!
                                                .icon !=
                                            null,
                                        descriptor: state
                                            .cachedProductWithoutRelatedProductsModel[
                                                productItem.id.toString()]!
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
                          if (!productItem.syncColorImages.isNullOrEmpty) ...{
                            DisplayColorsCard(
                              productItem: productItem,
                              scrollController: scrollController,
                              currentColorForProduct: currentSelectedColor,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          },
                          if (!state.cachedProductWithoutRelatedProductsModel
                                  .containsKey(productItem.id.toString()) ||
                              state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem.id.toString()]!
                                  .product!
                                  .choiceOptions
                                  .isNullOrEmpty) ...{
                            SizedBox.shrink()
                          } else ...{
                            DisplaySizesCard(
                              productItem: productItem,
                              currentColorForProduct: currentSelectedColor,
                              scrollController: scrollController,
                              variation: state
                                  .cachedProductWithoutRelatedProductsModel[
                                      productItem.id.toString()]!
                                  .product!
                                  .variation,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          },
                          // ProductStoriesCard(),
                          ProductStoriesCard(),
                          ProductShippingAndDelivery(),
                          SizedBox(
                            height: 15,
                          ),
                          BuyersCameraShots(
                            productItem: productItem,
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
                p.getFullProductDetailsStatus != c.getFullProductDetailsStatus,
            builder: (context, state) {
              if (widget.productItem == null) {
                if (state.getFullProductDetailsStatus !=
                    GetFullProductDetailsStatus.success) {
                  return SizedBox.shrink();
                }
                productItem = state
                    .productContentForStatusOfOpeningProductDetailsDirectly!;
              }
              return BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    previous.CurrentColorSizeForCart?["size"] !=
                        current.CurrentColorSizeForCart?["size"] ||
                    previous.currentSelectedColorForEveryProduct !=
                        current.currentSelectedColorForEveryProduct ||
                    previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                        current
                            .getProductDetailWithoutSimilarRelatedProductsStatus,
                builder: (context, state) {
                  String productId = productItem.id.toString();
                  int currentSelectedColor =
                      state.currentSelectedColorForEveryProduct[productId] ??
                          (productItem.syncColorImages?.length ?? 0) ~/ 2;
                  return ProductDetailsBottomSheet(
                    productDescription:
                        HtmlParser.parseHTML(productItem.details ?? "").text,
                    countOfPieces:
                        state.cachedProductWithoutRelatedProductsModel[
                                    productItem.id.toString()] !=
                                null
                            ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem.id.toString()]!
                                    .product!
                                    .countOfPieces ??
                                0
                            : 0,
                    currentSize: state.CurrentColorSizeForCart != null
                        ? state.CurrentColorSizeForCart!["size"] ?? ""
                        : "",
                    addToBagButtonShapeNotifier: addToBagButtonShapeNotifier,
                    sizes: state.sizes ?? [],
                    sizesQuantities: state.sizesQuantities ?? [],
                    currentColornum: productItem.colors.isNullOrEmpty
                        ? ''
                        : productItem.colors![currentSelectedColor].color ?? "",
                    boutiqueIcon: state
                                    .cachedProductWithoutRelatedProductsModel[
                                productItem.id.toString()] !=
                            null
                        ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem.id.toString()]!
                                    .product!
                                    .boutique !=
                                null
                            ? state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem.id.toString()]!
                                        .product!
                                        .boutique!
                                        .icon !=
                                    null
                                ? state
                                        .cachedProductWithoutRelatedProductsModel[
                                            productItem.id.toString()]!
                                        .product!
                                        .boutique!
                                        .icon!
                                        .filePath ??
                                    ""
                                : ""
                            : ""
                        : "",
                    boutiqueId: state.cachedProductWithoutRelatedProductsModel[
                                productItem.id.toString()] !=
                            null
                        ? state
                                    .cachedProductWithoutRelatedProductsModel[
                                        productItem.id.toString()]!
                                    .product!
                                    .boutique !=
                                null
                            ? state
                                .cachedProductWithoutRelatedProductsModel[
                                    productItem.id.toString()]!
                                .product!
                                .boutique!
                                .id!
                            : 0
                        : 0,
                    currentColorName: productItem.colors.isNullOrEmpty
                        ? ''
                        : productItem.colors![currentSelectedColor].name ?? "",
                    productItem: productItem,
                    currentColor: currentSelectedColor,
                    maxAllowedToAddCart: state
                            .cachedProductWithoutRelatedProductsModel[
                                productItem.id.toString()]
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
    );
  }
}
