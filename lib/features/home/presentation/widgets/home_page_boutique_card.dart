import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart' show WidgetsKeys;
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as filters;
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
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
    required this.descriptionPlain,
  });
  final String category_Slug;
  final int index;
  final bool withSlidingImages;
  final HomeBoutiques boutique;
  final ValueNotifier<bool> isShowPanelForVerified;
  /// نص الوصف جاهز بدون HTML (يُمرَّر من الصفحة الرئيسية لتحسين الأداء)
  final String descriptionPlain;

  @override
  Widget build(BuildContext context) {
    BoutiqueBloc boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);

    AppBloc appBloc = BlocProvider.of<AppBloc>(context);

    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      width: 1.sw,
      child: Column(
        children: [
          InkWell(
            key: TestVariables.kTestMode
                ? Key('${WidgetsKeys.boutiqueCardKey}*tap*$index')
                : null,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              boutiqueBloc.add(
                ChangeAppliedFiltersEvent(
                  boutiqueSlug: boutique.slug!,
                  resetAppliedFilters: true,
                ),
              );
              boutiqueBloc.add(
                ChangeSelectedFiltersEvent(
                  requestToUpdateFilters: false,
                  boutiqueSlug: boutique.slug!,
                ),
              );

              boutiqueBloc.add(
                GetProductsWithFiltersEvent(
                  getWithoutFilter: true,
                  cashedOrginalBoutique: true,
                  boutiqueSlug: boutique.slug!,
                  fromSearch: false,
                  context: context,
                  offset: 1,
                ),
              );
              homeBloc.add(
                const IsChangedVariationWhenQtyZeroEvent(
                  isChangedVariationWhenQtyZero: false,
                ),
              );
              homeBloc.add(
                const IsChangedVariationWhenQtyZeroEvent(
                  isChangedVariationWhenQtyZero: false,
                ),
              );

              boutiqueBloc.add(
                AddSizeAndColorFilterinTextToSearchEvent(
                  sizeAndColorFilterinTextToSearch: const {},
                ),
              );
              appBloc.add(HideBottomNavigationBar(false));
              appBloc.add(ShowOrHideBars(true));
              appBloc.add(ChangeIndexForSearch(1));

              Future.delayed(
                const Duration(milliseconds: 300),
                () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProductListingPage(
                      isShowPanelForVerified: isShowPanelForVerified,
                      banner: boutique.banners,
                      withSlidingImages: withSlidingImages,
                      boutiqueSlug: boutique.slug!,
                      boutiqueName: boutique.name,
                      boutiqueFirstBanner: boutique.banners![0].filePath!,
                      boutiqueIcon: boutique.icon?.filePath ?? "",
                    ),
                    transitionsBuilder: (_, __, ___, child) =>
                        child, // بدون أي حركة
                    transitionDuration: Duration.zero, // انتقال فوري
                    reverseTransitionDuration: Duration.zero, // عودة فورية
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                withSlidingImages
                    ? CarouselSlider.builder(
                        itemCount: boutique.banners!.length,
                        itemBuilder: (context, index, _) {
                          return MyCachedNetworkImage(
                            imageUrl: boutique.banners![index].filePath!,
                            imageFit: BoxFit.fitWidth,
                            width: 1.sw,
                            height: 250.h,
                            radius: 0,
                            fromBoutique: true,
                            imageSource: 'home_page_boutique_card',
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 300,
                          ),
                          height: 250.h,
                          viewportFraction: 1.0,
                          pauseAutoPlayInFiniteScroll: true,
                        ),
                      )
                    : MyCachedNetworkImage(
                        imageUrl: boutique.banners![0].filePath!,
                        imageFit: BoxFit.fitWidth,
                        radius: 0,
                        fromBoutique: true,
                        width: 1.sw,
                        height: 250.h,
                        imageSource: 'home_page_boutique_card',
                      ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 60.h,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromARGB(200, 33, 33, 33),
                            Color.fromARGB(150, 58, 58, 58),
                            Color.fromARGB(90, 82, 82, 82),
                            Color.fromARGB(0, 82, 82, 82),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          style: context.textTheme.titleMedium?.br.copyWith(
                            fontSize: 16,
                            color: const Color(0xffFFFFFF),
                            shadows: [
                              Shadow(
                                offset: const Offset(
                                  0,
                                  1,
                                ), // الاتجاه: 0 يمين/يسار، 1 للأسفل
                                blurRadius: 2.0, // مدى التشتت (القوة)
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(
                                  0.7,
                                ), // ظل أسود شبه شفاف
                              ),
                            ],
                          ),
                        ),
                        Text(
                          descriptionPlain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.mq.copyWith(
                            fontSize: 12,
                            shadows: [
                              Shadow(
                                offset: const Offset(
                                  0,
                                  1,
                                ), // الاتجاه: 0 يمين/يسار، 1 للأسفل
                                blurRadius: 3,

                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(
                                  0.8,
                                ), // ظل أسود شبه شفاف
                              ),
                            ],
                            color: const Color(0xffFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          (boutique.mainCategoriesForProductIds!.length) < 2
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 102.h,
                  width: double.infinity,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          width: 90.w,
                          height: 90.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            border: Border.all(
                              width: 0.5,
                              color: const Color(0xffD3D3D3),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsetsGeometry.only(
                            top: 5,
                            right: LanguageService.rtl ? 0 : 10,
                            left: LanguageService.rtl ? 10 : 0,
                          ),
                          child: InkWell(
                            onTap: () {
                              if (boutique
                                      .mainCategoriesForProductIds![index]
                                      .isProduct ??
                                  false) {
                                BlocProvider.of<HomeBloc>(context).add(
                                  GetFullProductDetailsEvent(
                                    productSlug:
                                        boutique
                                            .mainCategoriesForProductIds![index]
                                            .categorySlug ??
                                        "",
                                  ),
                                );

                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () => Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => ProductDetailsPageNew(
                                            productSlugForOpeningChatDirectly:
                                                boutique
                                                    .mainCategoriesForProductIds![index]
                                                    .categorySlug ??
                                                "",
                                            productIdForOpeningChatDirectly:
                                                boutique
                                                    .mainCategoriesForProductIds![index]
                                                    .categoryId
                                                    .toString(),
                                          ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              boutiqueBloc.add(
                                ChangeAppliedFiltersEvent(
                                  boutiqueSlug: boutique.slug!,
                                  resetAppliedFilters: true,
                                ),
                              );
                              boutiqueBloc.add(
                                ChangeSelectedFiltersEvent(
                                  boutiqueSlug: boutique.slug!,
                                ),
                              );

                              boutiqueBloc.add(
                                ChangeAppliedFiltersEvent(
                                  filtersAppliedByUser: GetProductFiltersModel(
                                    filters: Filter(
                                      categories: [
                                        filters.Category(
                                          slug: boutique
                                              .mainCategoriesForProductIds![index]
                                              .categorySlug,
                                          name: boutique
                                              .mainCategoriesForProductIds![index]
                                              .categoryName,
                                          id: boutique
                                              .mainCategoriesForProductIds![index]
                                              .categoryId,
                                          isSelected: true,
                                          flatPhotoPath: CategoryBanner(
                                            filePath: boutique
                                                .mainCategoriesForProductIds![index]
                                                .flatPhotoPath
                                                ?.filePath,
                                          ),
                                          mostViewedProductThumbnail:
                                              CategoryBanner(
                                                filePath: boutique
                                                    .mainCategoriesForProductIds![index]
                                                    .mostViewedProductThumbnail,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  boutiqueSlug: boutique.slug!,
                                ),
                              );

                              boutiqueBloc.add(
                                GetProductsWithFiltersEvent(
                                  boutiqueSlug: boutique.slug!,
                                  fromSearch: false,
                                  context: context,
                                  offset: 1,
                                ),
                              );

                              homeBloc.add(
                                const IsChangedVariationWhenQtyZeroEvent(
                                  isChangedVariationWhenQtyZero: false,
                                ),
                              );
                              boutiqueBloc.add(
                                AddSizeAndColorFilterinTextToSearchEvent(
                                  sizeAndColorFilterinTextToSearch: const {},
                                ),
                              );
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
                                          boutiqueIcon:
                                              boutique.icon?.filePath ?? "",
                                        ),

                                    transitionsBuilder: (_, __, ___, child) =>
                                        child, // بدون أي حركة
                                    transitionDuration:
                                        Duration.zero, // انتقال فوري
                                    reverseTransitionDuration:
                                        Duration.zero, // عودة فورية
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                MyCachedNetworkImage(
                                  radius: 15.r,
                                  imageUrl:
                                      boutique
                                          .mainCategoriesForProductIds![index]
                                          .mostViewedProductThumbnail ??
                                      "",
                                  width: 90.w,
                                  imageFit: BoxFit.contain,
                                  height: 90.h,
                                ),
                                (boutique
                                            .mainCategoriesForProductIds![index]
                                            .mostViews ??
                                        false)
                                    ? Positioned(
                                        child: SvgPicture.asset(
                                          AppAssets.trendingSvg,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

}
