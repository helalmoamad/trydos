import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:trydos/features/home/presentation/widgets/cart_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/display_sizes_card.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import 'package:trydos/features/home/presentation/widgets/product_stories_section/story/widget/stories_list.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../generated/locale_keys.g.dart';
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
    required this.productItem,
  });

  final productListingModel.Products productItem;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ScrollController scrollController = ScrollController();

  late HomeBloc homeBloc;
  late ChatBloc chatBloc;
  final ValueNotifier<int> addToBagButtonShapeNotifier = ValueNotifier(0);
  bool enable = true;
  double? valueOnY;
  final PanelController panelControllerForBuyersCameraShots = PanelController();
  final PanelController panelControllerForReels = PanelController();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    chatBloc = BlocProvider.of<ChatBloc>(context);

    homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
        productId: widget.productItem.id.toString()));
    Future.delayed(Duration(seconds: 3), () {
      homeBloc.add(GetCommentForProductEvent(
          productId: widget.productItem.id.toString()));
    });
    homeBloc.add(
        GetStoryForProductEvent(productId: widget.productItem.id.toString()));
    if(GetIt.I<PrefsRepository>().chatToken != null) {
      BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
      BlocProvider.of<ChatBloc>(context).add(SaveContactsEvent());
    }
    //  chatBloc.add(GetSharedProductCountEvent(
    //     productId: widget.productItem.id.toString()));

    super.initState();
  }

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.surface,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
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
                            onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CartPage(
                                      fromeFilters: true,
                                    ),
                                  ),
                                ),
                            child: SvgPicture.asset(AppAssets.bagsSvg)),
                      ),
                      LanguageService.rtl ? Spacer() : SizedBox.shrink(),
                    ],
                    withShadow: false),
              ),
              backgroundColor: Color(0xffF4F4F4),
              body: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) =>
                    p.getStoriesForProductStatus !=
                        c.getStoriesForProductStatus ||
                    p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                        c.getProductDetailWithoutSimilarRelatedProductsStatus ||
                    p.currentSelectedColorForEveryProduct !=
                        c.currentSelectedColorForEveryProduct ||
                    p.cachedProductWithoutRelatedProductsModel !=
                        c.cachedProductWithoutRelatedProductsModel,
                builder: (context, state) {
                  String productId = widget.productItem.id.toString();
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
                                        widget.productItem.id.toString()));
                          },
                          child: MyTextWidget(LocaleKeys.try_again.tr())),
                    );
                  }*/

                  int currentSelectedColor = state
                          .currentSelectedColorForEveryProduct[productId] ??
                      (widget.productItem.syncColorImages?.length ?? 0) ~/ 2;

                  homeBloc.add(AddSizesFotColorsEvent(
                      currentColorName: !widget.productItem.colors.isNullOrEmpty
                          ? widget.productItem.colors![currentSelectedColor]
                                  .name ??
                              ""
                          : "",
                      variation: state.cachedProductWithoutRelatedProductsModel[
                                  widget.productItem.id.toString()] !=
                              null
                          ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  widget.productItem.id.toString()]!
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
                                      itemCount: widget.productItem
                                              .syncColorImages.isNullOrEmpty
                                          ? widget.productItem.images!.length
                                          : !widget
                                                  .productItem
                                                  .syncColorImages![
                                                      currentSelectedColor]
                                                  .images
                                                  .isNullOrEmpty
                                              ? widget
                                                  .productItem
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
                                                    images: widget
                                                            .productItem
                                                            .syncColorImages
                                                            .isNullOrEmpty
                                                        ? widget.productItem
                                                                .images ??
                                                            []
                                                        : widget
                                                                .productItem
                                                                .syncColorImages![
                                                                    currentSelectedColor]
                                                                .images ??
                                                            [],
                                                  ));
                                            },
                                            child: ProductDetailsImageWidget(
                                              orginalHeight: widget
                                                      .productItem
                                                      .syncColorImages
                                                      .isNullOrEmpty
                                                  ? double.parse(widget
                                                      .productItem
                                                      .images![index]
                                                      .originalHeight!)
                                                  : double.parse(widget
                                                      .productItem
                                                      .syncColorImages![
                                                          currentSelectedColor]
                                                      .images![index]
                                                      .originalHeight!),
                                              orginalWidth: widget
                                                      .productItem
                                                      .syncColorImages
                                                      .isNullOrEmpty
                                                  ? double.parse(widget
                                                      .productItem
                                                      .images![index]
                                                      .originalWidth!)
                                                  : double.parse(widget
                                                      .productItem
                                                      .syncColorImages![
                                                          currentSelectedColor]
                                                      .images![index]
                                                      .originalWidth!),
                                              imageUrl: widget
                                                      .productItem
                                                      .syncColorImages
                                                      .isNullOrEmpty
                                                  ? widget.productItem
                                                      .images![index].filePath!
                                                  : widget
                                                      .productItem
                                                      .syncColorImages![
                                                          currentSelectedColor]
                                                      .images![index]
                                                      .filePath,
                                            ));
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(
                                          width: 9,
                                        );
                                      },
                                    ))),
                            Container(
                              width: 40,
                              height: 464,
                              color: Colors.transparent,
                            )
                          ],
                        ),
                        ProductDetailsTitle(
                          orginalHeight: double.parse(
                              widget.productItem.thumbnail!.originalHeight!),
                          orginalWidth: double.parse(
                              widget.productItem.thumbnail!.originalWidth!),
                          brand: widget.productItem.brand,
                          productName: widget.productItem.name ?? "",
                          thumbnail:
                              widget.productItem.thumbnail!.filePath ?? '',
                          colorName: !widget.productItem.syncColorImages
                                      .isNullOrEmpty &&
                                  !widget.productItem.syncColorImages![0].images
                                      .isNullOrEmpty
                              ? widget
                                      .productItem
                                      .syncColorImages![currentSelectedColor]
                                      .colorName ??
                                  " "
                              : " ",
                        ),

                        if (!state.cachedProductWithoutRelatedProductsModel
                            .containsKey(widget.productItem.id.toString())) ...{
                          SizedBox.shrink()
                        } else ...{
                          ProductDetailsDescriptionWidget(
                            description: widget.productItem.details ?? " ",
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          BadgesList(
                              lable: state
                                      .cachedProductWithoutRelatedProductsModel[
                                          widget.productItem.id.toString()]!
                                      .product!
                                      .labels ??
                                  []),
                        },
                        SizedBox(
                          height: 15,
                        ),
                        if (!state.cachedProductWithoutRelatedProductsModel
                                .containsKey(
                                    widget.productItem.id.toString()) ||
                            state
                                .cachedProductWithoutRelatedProductsModel[
                                    widget.productItem.id.toString()]!
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
                                          widget.productItem.id.toString()]!
                                      .product!
                                      .descriptors!
                                      .length,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  itemBuilder: (context, index) {
                                    return ProductDetailsChipWidget(
                                      withIcon: state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  widget.productItem.id
                                                      .toString()]!
                                              .product!
                                              .descriptors![index]
                                              .descriptorGroup!
                                              .icon !=
                                          null,
                                      descriptor: state
                                          .cachedProductWithoutRelatedProductsModel[
                                              widget.productItem.id.toString()]!
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
                        if (!widget
                            .productItem.syncColorImages.isNullOrEmpty) ...{
                          DisplayColorsCard(
                            productItem: widget.productItem,
                            scrollController: scrollController,
                            currentColorForProduct: currentSelectedColor,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        },
                        if (!state.cachedProductWithoutRelatedProductsModel
                                .containsKey(
                                    widget.productItem.id.toString()) ||
                            state
                                .cachedProductWithoutRelatedProductsModel[
                                    widget.productItem.id.toString()]!
                                .product!
                                .choiceOptions
                                .isNullOrEmpty) ...{
                          SizedBox.shrink()
                        } else ...{
                          DisplaySizesCard(
                              productItem: widget.productItem,
                              currentColorForProduct: currentSelectedColor,
                              scrollController: scrollController,
                              variation: state
                                  .cachedProductWithoutRelatedProductsModel[
                                      widget.productItem.id.toString()]!
                                  .product!
                                  .variation),
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
                          productItem: widget.productItem,
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
              )),
          BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) =>
                  previous.CurrentColorSizeForCart?["size"] !=
                      current.CurrentColorSizeForCart?["size"] ||
                  previous.currentSelectedColorForEveryProduct !=
                      current.currentSelectedColorForEveryProduct ||
                  previous.getProductDetailWithoutSimilarRelatedProductsStatus !=
                      current
                          .getProductDetailWithoutSimilarRelatedProductsStatus,
              builder: (context, state) {
                String productId = widget.productItem.id.toString();
                int currentSelectedColor =
                    state.currentSelectedColorForEveryProduct[productId] ??
                        (widget.productItem.syncColorImages?.length ?? 0) ~/ 2;
                return ProductDetailsBottomSheet(
                  countOfPieces: state.cachedProductWithoutRelatedProductsModel[
                              widget.productItem.id.toString()] !=
                          null
                      ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  widget.productItem.id.toString()]!
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
                  currentColornum: widget.productItem.colors.isNullOrEmpty
                      ? ''
                      : widget.productItem.colors![currentSelectedColor]
                              .color ??
                          "",
                  boutiqueIcon: state.cachedProductWithoutRelatedProductsModel[
                              widget.productItem.id.toString()] !=
                          null
                      ? state
                                  .cachedProductWithoutRelatedProductsModel[
                                      widget.productItem.id.toString()]!
                                  .product!
                                  .boutique !=
                              null
                          ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          widget.productItem.id.toString()]!
                                      .product!
                                      .boutique!
                                      .icon !=
                                  null
                              ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          widget.productItem.id.toString()]!
                                      .product!
                                      .boutique!
                                      .icon!
                                      .filePath ??
                                  ""
                              : ""
                          : ""
                      : "",
                  boutiqueId: state.cachedProductWithoutRelatedProductsModel[
                              widget.productItem.id.toString()] !=
                          null
                      ? state
                                  .cachedProductWithoutRelatedProductsModel[
                                      widget.productItem.id.toString()]!
                                  .product!
                                  .boutique !=
                              null
                          ? state
                              .cachedProductWithoutRelatedProductsModel[
                                  widget.productItem.id.toString()]!
                              .product!
                              .boutique!
                              .id!
                          : 0
                      : 0,
                  currentColorName: widget.productItem.colors.isNullOrEmpty
                      ? ''
                      : widget.productItem.colors![currentSelectedColor].name ??
                          "",
                  productItem: widget.productItem,
                  currentColor: currentSelectedColor,
                  maxAllowedToAddCart: state
                          .cachedProductWithoutRelatedProductsModel[
                              widget.productItem.id.toString()]
                          ?.product
                          ?.maxAllowedQty ??
                      "0",
                );
              }),
          SlidingUpPanelForBuyersCameraShots(
              panelController: panelControllerForBuyersCameraShots,
              panelControllerForReels: panelControllerForReels),
          SlidingUpPanelForReels(panelController: panelControllerForReels),
        ],
      ),
    );
  }
}
