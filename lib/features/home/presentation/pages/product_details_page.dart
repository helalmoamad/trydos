import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/app/app_widgets/trydos_app_bar/app_bar_params.dart';
import 'package:trydos/features/app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart'
    as productDetail;
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/pages/product_details_display_pictures_page.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_body/product_details_title.dart';
import 'package:trydos/features/home/presentation/widgets/product_details_sheet/product_details_bottom_sheet.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../service/language_service.dart';
import '../../../../trydos_application.dart';
import '../../../app/my_text_widget.dart';

import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../data/models/get_product_listing_without_filters_model.dart'
    as productListingModel;

import '../manager/home_state.dart';
import '../widgets/product_details_body/badges_list.dart';
import '../widgets/product_details_body/display_colors_card.dart';
import '../widgets/product_details_body/product_details_chip_widget.dart';
import '../widgets/product_details_body/product_details_description_widget.dart';
import '../widgets/product_details_body/product_details_image_widget.dart';
import '../widgets/product_details_body/sliding_up_panel_for_buyers_camera_shots.dart';
import '../widgets/product_details_body/sliding_up_panel_for_reels.dart';
import '../widgets/product_stories_section/product_stories_card.dart';
import '../widgets/product_details_body/buyers_camera_shots.dart';

class ProductDetailsPage extends StatefulWidget {
  ProductDetailsPage({
    super.key,
    required this.productItem,
  });

  final productListingModel.Product productItem;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  bool enable = true;
  double? valueOnY;
  final PanelController panelControllerForBuyersCameraShots = PanelController();
  final PanelController panelControllerForReels = PanelController();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.add(GetProductDatailsWithoutRelatedProductsEvent(
        productId: widget.productItem.id.toString()));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (error) {
      debugPrint(error.toString());
    };
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
                appBar: TrydosAppBar(
                  appBarParams: AppBarParams(
                      scrolledUnderElevation: 0,
                      backIconColor: Colors.black,
                      withShadow: false),
                ),
                backgroundColor: Color(0xffF4F4F4),
                body: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) =>
                      p.getProductDetailWithoutSimilarRelatedProductsStatus !=
                          c.getProductDetailWithoutSimilarRelatedProductsStatus ||
                      p.currentIndex != c.currentIndex,
                  builder: (context, state) {
                    if (state
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
                    }
                    if(!state.cachedProductWithoutRelatedProductsModel.containsKey(widget.productItem.id.toString())) {
                        return Center(
                          child: TrydosLoader(),
                        );
                    }
                    String productId = widget.productItem.id.toString();
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
                                        itemCount: !widget
                                                    .productItem
                                                    .syncColorImages
                                                    .isNullOrEmpty &&
                                                !widget
                                                    .productItem
                                                    .syncColorImages![0]
                                                    .images
                                                    .isNullOrEmpty
                                            ? widget
                                                .productItem
                                                .syncColorImages![
                                                    state.currentIndex]
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
                                                              .syncColorImages![
                                                                  state.currentIndex ??
                                                                      0]
                                                              .images ??
                                                          [],
                                                    ));
                                              },
                                              child: widget
                                                          .productItem
                                                          .syncColorImages![
                                                              state
                                                                  .currentIndex]
                                                          .images!
                                                          .isNotEmpty ||
                                                      widget
                                                              .productItem
                                                              .syncColorImages![
                                                                  state
                                                                      .currentIndex]
                                                              .images !=
                                                          []
                                                  ? ProductDetailsImageWidget(
                                                      imageUrl: widget
                                                          .productItem
                                                          .syncColorImages![
                                                              state
                                                                  .currentIndex]
                                                          .images![index],
                                                    )
                                                  : const SizedBox.shrink());
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
                            brand: widget.productItem.brand!,
                            productName: widget.productItem.name!,
                            ViewerCount: state
                                .cachedProductWithoutRelatedProductsModel[productId]!
                                .product!
                                .reviewsCount
                                .toString(),
                            thumbnail: widget.productItem.thumbnail ?? '',
                            colorName: !widget.productItem.syncColorImages
                                        .isNullOrEmpty &&
                                    !widget.productItem.syncColorImages![0]
                                        .images.isNullOrEmpty
                                ? widget
                                        .productItem
                                        .syncColorImages![
                                            state.currentIndex ?? 0]
                                        .colorName ??
                                    " "
                                : " ",
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          ProductDetailsDescriptionWidget(
                            description: state
                                .cachedProductWithoutRelatedProductsModel[productId]!
                                    .product!
                                    .description ??
                                " ",
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          BadgesList(),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                              height: 52,
                              child: ScrollConfiguration(
                                behavior: const CupertinoScrollBehavior(),
                                child: ListView.separated(
                                  itemCount: 5,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  itemBuilder: (context, index) {
                                    return ProductDetailsChipWidget(
                                      withIcon: index % 2 != 0,
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      width: 8,
                                    );
                                  },
                                ),
                              )),
                          SizedBox(
                            height: 15,
                          ),
                          DisplayColorsCard(
                              productItem: widget.productItem,
                              scrollController: scrollController),
                          SizedBox(
                            height: 15,
                          ),
                         // ProductStoriesCard(),
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
            ProductDetailsBottomSheet(
              productItem: widget.productItem,
            ),
            SlidingUpPanelForBuyersCameraShots(
                panelController: panelControllerForBuyersCameraShots,
                panelControllerForReels: panelControllerForReels),
            SlidingUpPanelForReels(panelController: panelControllerForReels),
          ],
        ));
  }
}
