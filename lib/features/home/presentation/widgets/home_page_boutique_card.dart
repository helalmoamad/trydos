import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as filters;
import 'package:trydos/service/language_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';

class HomePageBoutiqueCard extends StatelessWidget {
  HomePageBoutiqueCard({
    super.key,
    this.withSlidingImages = false,
    required this.boutique,
    required this.category_Slug,
    required this.isShowPanelForVerified,
    required this.index,
  });
  final String category_Slug;
  final int index;
  final bool withSlidingImages;
  final HomeBoutiques boutique;
  final ValueNotifier<bool> isShowPanelForVerified;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return _buildCardContent(context);
  }

  Widget _buildCardContent(BuildContext context) {
    BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    AppBloc appBloc = BlocProvider.of<AppBloc>(context);

    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
    return SizedBox(
      height: (boutique.mainCategoriesForProductIds!.length) == 0 ? 250 : 352,
      width: 1.sw,
      child: Column(
        children: [
          Container(
            height: 250,
            width: 1.sw,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Container(
                width: 1.sw,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xffE3E7EA).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      boutiqueBloc.add(ChangeAppliedFiltersEvent(
                        boutiqueSlug: boutique.slug!,
                        resetAppliedFilters: true,
                      ));
                      boutiqueBloc.add(ChangeSelectedFiltersEvent(
                        requestToUpdateFilters: false,
                        boutiqueSlug: boutique.slug!,
                      ));

                      boutiqueBloc.add(GetProductsWithFiltersEvent(
                          getWithoutFilter: true,
                          cashedOrginalBoutique: true,
                          boutiqueSlug: boutique.slug!,
                          fromSearch: false,
                          context: context,
                          offset: 1));
                      homeBloc.add(const IsChangedVariationWhenQtyZeroEvent(
                          isChangedVariationWhenQtyZero: false));
                      homeBloc.add(const IsChangedVariationWhenQtyZeroEvent(
                          isChangedVariationWhenQtyZero: false));

                      boutiqueBloc.add(AddSizeAndColorFilterinTextToSearchEvent(
                          sizeAndColorFilterinTextToSearch: const {}));
                      appBloc.add(HideBottomNavigationBar(false));
                      appBloc.add(ShowOrHideBars(true));
                      appBloc.add(ChangeIndexForSearch(1));

                      Future.delayed(
                          const Duration(milliseconds: 300),
                          () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      ProductListingPage(
                                    isShowPanelForVerified:
                                        isShowPanelForVerified,
                                    banner: boutique.banners,
                                    withSlidingImages: withSlidingImages,
                                    boutiqueSlug: boutique.slug!,
                                    boutiqueName: boutique.name,
                                    boutiqueFirstBanner:
                                        boutique.banners![0].filePath!,
                                    boutiqueIcon: boutique.icon?.filePath ?? "",
                                  ),
                                  transitionsBuilder: (_, __, ___, child) =>
                                      child, // بدون أي حركة
                                  transitionDuration:
                                      Duration.zero, // انتقال فوري
                                  reverseTransitionDuration:
                                      Duration.zero, // عودة فورية
                                ),
                              ));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(
                          children: [
                            MyCachedNetworkImage(
                              imageUrl: boutique.banners![0].filePath!,
                              imageFit: BoxFit.fitWidth,
                              width: 1.sw,
                              height: 250,
                              imageSource: 'home_page_boutique_card',
                            ),
                            Positioned(
                                bottom: 6,
                                left: LanguageService.rtl ? null : 12,
                                right: !LanguageService.rtl ? null : 12,
                                child: SizedBox(
                                  width: 1.sw - 100,
                                  height: 45,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextWidget(
                                        boutique.name!,
                                        style: context.textTheme.titleMedium?.br
                                            .copyWith(
                                          fontSize: 16,
                                          color: const Color(0xffFFFFFF),
                                        ),
                                      ),
                                      MyTextWidget(
                                        "10% Discount For All Zara Collection Now!",
                                        style: context.textTheme.titleMedium?.mr
                                            .copyWith(
                                          fontSize: 12,
                                          color: const Color(0xffFFFFFF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        )))),
          ),
          (boutique.mainCategoriesForProductIds!.length) == 0
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 102,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    cacheExtent: 0,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: (boutique.mainCategoriesForProductIds!.length),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                          width: 90,
                          height: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xffE3E7EA).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsetsGeometry.only(
                              top: 5,
                              right: LanguageService.rtl ? 0 : 10,
                              left: LanguageService.rtl ? 10 : 0),
                          child: InkWell(
                              onTap: () {
                                boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                  boutiqueSlug: boutique.slug!,
                                  resetAppliedFilters: true,
                                ));
                                boutiqueBloc.add(ChangeSelectedFiltersEvent(
                                  boutiqueSlug: boutique.slug!,
                                ));

                                boutiqueBloc.add(ChangeAppliedFiltersEvent(
                                  filtersAppliedByUser: GetProductFiltersModel(
                                    filters: Filter(categories: [
                                      filters.Category(
                                          slug: boutique
                                              .mainCategoriesForProductIds![
                                                  index]
                                              .categorySlug,
                                          name: boutique
                                              .mainCategoriesForProductIds![
                                                  index]
                                              .categoryName,
                                          id: boutique
                                              .mainCategoriesForProductIds![
                                                  index]
                                              .categoryId,
                                          isSelected: true,
                                          flatPhotoPath: CategoryBanner(
                                              filePath: boutique
                                                  .mainCategoriesForProductIds![
                                                      index]
                                                  .mostViewedProductThumbnail
                                                  ?.filePath),
                                          mostViewedProductThumbnail: CategoryBanner(
                                              filePath: boutique
                                                  .mainCategoriesForProductIds![
                                                      index]
                                                  .mostViewedProductThumbnail
                                                  ?.filePath))
                                    ]),
                                  ),
                                  boutiqueSlug: boutique.slug!,
                                ));

                                boutiqueBloc.add(GetProductsWithFiltersEvent(
                                    boutiqueSlug: boutique.slug!,
                                    fromSearch: false,
                                    context: context,
                                    offset: 1));

                                homeBloc.add(
                                    const IsChangedVariationWhenQtyZeroEvent(
                                        isChangedVariationWhenQtyZero: false));
                                boutiqueBloc.add(
                                    AddSizeAndColorFilterinTextToSearchEvent(
                                        sizeAndColorFilterinTextToSearch: const {}));
                                appBloc.add(HideBottomNavigationBar(false));
                                appBloc.add(ShowOrHideBars(true));
                                appBloc.add(ChangeIndexForSearch(1));

                                Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () => Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>
                                                ProductListingPage(
                                              isShowPanelForVerified:
                                                  isShowPanelForVerified,
                                              banner: boutique.banners,
                                              withSlidingImages:
                                                  withSlidingImages,
                                              boutiqueSlug: boutique.slug!,
                                              boutiqueName: boutique.name,
                                              boutiqueFirstBanner: boutique
                                                  .banners![0].filePath!,
                                              boutiqueIcon:
                                                  boutique.icon?.filePath ?? "",
                                            ),

                                            transitionsBuilder:
                                                (_, __, ___, child) =>
                                                    child, // بدون أي حركة
                                            transitionDuration:
                                                Duration.zero, // انتقال فوري
                                            reverseTransitionDuration:
                                                Duration.zero, // عودة فورية
                                          ),
                                        ));
                              },
                              child: MyCachedNetworkImage(
                                  radius: 15,
                                  imageUrl: boutique
                                      .mainCategoriesForProductIds![index]
                                      .mostViewedProductThumbnail!
                                      .filePath!,
                                  width: 90,
                                  imageFit: BoxFit.contain,
                                  height: 90)));
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
