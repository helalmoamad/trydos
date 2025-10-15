import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:html/parser.dart';
import 'package:trydos/features/app/my_text_widget.dart';
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
      height:
          (boutique.childCategoriesForProductIds!.length) == 0 ? 252.h : 354.h,
      width: 1.sw,
      child: Column(
        children: [
          Container(
            height: 252.h,
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
                height: 252.h,
                // ignore: deprecated_member_use
                color: const Color(0xfff0f0f0).withOpacity(0.5),
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
                    child: Stack(
                      children: [
                        withSlidingImages
                            ? CarouselSlider.builder(
                                itemCount: boutique.banners!.length,
                                itemBuilder: (context, index, _) {
                                  return MyCachedNetworkImage(
                                    imageUrl:
                                        boutique.banners![index].filePath!,
                                    imageFit: BoxFit.contain,
                                    width: 1.sw,
                                    height: 250.h,
                                    imageSource: 'home_page_boutique_card',
                                  );
                                },
                                options: CarouselOptions(
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 5),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 300),
                                  height: 250.h,
                                  viewportFraction: 1.0,
                                  pauseAutoPlayInFiniteScroll: true,
                                ))
                            : MyCachedNetworkImage(
                                imageUrl: boutique.banners![0].filePath!,
                                imageFit: BoxFit.contain,
                                width: 1.sw,
                                height: 250.h,
                                imageSource: 'home_page_boutique_card',
                              ),
                        Positioned(
                            bottom: 6.h,
                            left: LanguageService.rtl ? null : 12,
                            right: !LanguageService.rtl ? null : 12,
                            child: SizedBox(
                              width: 1.sw,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyTextWidget(
                                    boutique.name!,
                                    style: context.textTheme.titleMedium?.br
                                        .copyWith(
                                      fontSize: 16,
                                      color: const Color(0xffFFFFFF),
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0,
                                              1), // الاتجاه: 0 يمين/يسار، 1 للأسفل
                                          blurRadius: 2.0, // مدى التشتت (القوة)
                                          // ignore: deprecated_member_use
                                          color: Colors.black.withOpacity(
                                              0.7), // ظل أسود شبه شفاف
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                      stripHtmlTags(boutique.description ?? '')
                                          .trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.titleMedium?.mr
                                          .copyWith(
                                        fontSize: 12,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0,
                                                1), // الاتجاه: 0 يمين/يسار، 1 للأسفل
                                            blurRadius: 3,

                                            // ignore: deprecated_member_use
                                            color: Colors.black.withOpacity(
                                                0.8), // ظل أسود شبه شفاف
                                          ),
                                        ],
                                        color: const Color(0xffFFFFFF),
                                      ))
                                ],
                              ),
                            ))
                      ],
                    ))),
          ),
          (boutique.childCategoriesForProductIds!.length) == 0
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 102.h,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    cacheExtent: 0,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: (boutique.childCategoriesForProductIds!.length),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                          width: 90.w,
                          height: 90.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
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
                                            .childCategoriesForProductIds![
                                                index]
                                            .categorySlug,
                                        name: boutique
                                            .childCategoriesForProductIds![
                                                index]
                                            .categoryName,
                                        id: boutique
                                            .childCategoriesForProductIds![
                                                index]
                                            .categoryId,
                                        isSelected: true,
                                        flatPhotoPath: CategoryBanner(
                                            filePath: boutique
                                                .childCategoriesForProductIds![
                                                    index]
                                                .flatPhotoPath
                                                ?.filePath),
                                        mostViewedProductThumbnail: CategoryBanner(
                                            filePath: boutique
                                                .childCategoriesForProductIds![
                                                    index]
                                                .mostViewedProductThumbnail
                                                ?.filePath),
                                      )
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
                                  radius: 15.r,
                                  imageUrl: boutique
                                      .childCategoriesForProductIds![index]
                                      .mostViewedProductThumbnail!
                                      .filePath!,
                                  width: 90.w,
                                  imageFit: BoxFit.contain,
                                  height: 90.h)));
                    },
                  ),
                ),
        ],
      ),
    );
  }

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement?.text ?? '';
    return parsedString;
  }
}
