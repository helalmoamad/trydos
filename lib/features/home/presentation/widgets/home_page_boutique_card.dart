import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart' show WidgetsKeys;
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_home_boutiqes_model.dart';
import 'package:trydos/features/home/data/models/get_product_filters_model.dart';
import 'package:trydos/features/home/data/models/get_product_listing_with_filters_model.dart'
    as filters;
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/features/home/presentation/pages/product_listing_page.dart';
import 'package:trydos/service/language_service.dart';

class HomePageBoutiqueCard extends StatelessWidget {
  const HomePageBoutiqueCard({
    super.key,
    this.withSlidingImages = false,
    required this.boutique,
    required this.category_Slug,
    required this.index,
    required this.descriptionPlain,
  });

  final String category_Slug;
  final int index;
  final bool withSlidingImages;
  final HomeBoutiques boutique;
  final String descriptionPlain;

  /// دالة تنقل موحدة إلى صفحة قائمة المنتجات (Product Listing)
  void _navigateToProductListing(BuildContext context) {
    final boutiqueBloc = context.read<BoutiqueBloc>();
    final appBloc = context.read<AppBloc>();
    final homeBloc = context.read<HomeBloc>();

    final boutiqueSlug = boutique.slug ?? '';

    boutiqueBloc.add(
      ChangeAppliedFiltersEvent(
        boutiqueSlug: boutiqueSlug,
        resetAppliedFilters: true,
      ),
    );
    boutiqueBloc.add(
      ChangeSelectedFiltersEvent(
        requestToUpdateFilters: false,
        boutiqueSlug: boutiqueSlug,
      ),
    );
    boutiqueBloc.add(
      GetProductsWithFiltersEvent(
        getWithoutFilter: true,
        cashedOrginalBoutique: true,
        boutiqueSlug: boutiqueSlug,
        fromSearch: false,

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
    appBloc.add(ChangeIndexForSearch(0));

    final firstBanner =
        (boutique.banners != null && boutique.banners!.isNotEmpty)
        ? (boutique.banners![0].filePath ?? '')
        : '';

    Future.delayed(
      const Duration(milliseconds: 300),
      () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ProductListingPage(
            banner: boutique.banners,
            withSlidingImages: withSlidingImages,
            boutiqueSlug: boutiqueSlug,
            boutiqueName: boutique.name,
            boutiqueFirstBanner: firstBanner,
            boutiqueIcon: boutique.icon?.filePath ?? "",
          ),
          transitionsBuilder: (_, __, ___, child) => child,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = boutique.mainCategoriesForProductIds ?? [];
    final hasSubCategories = subCategories.isNotEmpty;
    final banners = boutique.banners ?? [];

    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.black12),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1️⃣ البنرات العلوية ومعلومات البوتيك
          InkWell(
            key: TestVariables.kTestMode
                ? Key('${WidgetsKeys.boutiqueCardKey}*tap*$index')
                : null,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _navigateToProductListing(context),
            child: Stack(
              children: [
                withSlidingImages && banners.length > 1
                    ? CarouselSlider.builder(
                        key: ValueKey("${boutique.slug}*carousel*"),
                        itemCount: banners.length,
                        itemBuilder: (context, bannerIdx, _) {
                          return MyCachedNetworkImage(
                            imageUrl: banners[bannerIdx].filePath ?? '',
                            imageFit: BoxFit.fitWidth,
                            width: 1.sw,
                            height: 400.h,
                            radius: 0,
                            fromBoutique: true,
                            imageSource: 'home_page_boutique_card',
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 600,
                          ),
                          height: 250.h,
                          viewportFraction: 1.0,
                          pauseAutoPlayInFiniteScroll: true,
                        ),
                      )
                    : MyCachedNetworkImage(
                        imageUrl: banners.isNotEmpty
                            ? banners[0].filePath ?? ''
                            : '',
                        imageFit: BoxFit.fitWidth,
                        radius: 0,
                        fromBoutique: true,
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
                          boutique.name ?? '',
                          style: context.textTheme.titleMedium?.br.copyWith(
                            fontSize: 16,
                            color: const Color(0xffFFFFFF),
                          ),
                        ),
                        Text(
                          descriptionPlain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.mq.copyWith(
                            fontSize: 12,

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

          // 2️⃣ شريط المنتجات والـ Categories التابع للبوتيك باستخدام Row أفقية فائقة الأداء
          if (hasSubCategories)
            Container(
              height: 102.h,
              width: double.infinity,
              alignment: AlignmentDirectional.centerStart,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(subCategories.length, (subIdx) {
                    final item = subCategories[subIdx];
                    return Container(
                      width: 90.w,
                      height: 90.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: const Color(0xffD3D3D3),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.only(
                        top: 5,
                        right: LanguageService.rtl ? 0 : 10,
                        left: LanguageService.rtl ? 10 : 0,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          if (item.isProduct ?? false) {
                            context.read<HomeBloc>().add(
                              GetFullProductDetailsEvent(
                                productSlug: item.categorySlug ?? "",
                              ),
                            );

                            Future.delayed(
                              const Duration(seconds: 1),
                              () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      ProductDetailsPageNew(
                                        productSlugForOpeningChatDirectly:
                                            item.categorySlug ?? "",
                                        productIdForOpeningChatDirectly: item
                                            .categoryId
                                            .toString(),
                                      ),
                                ),
                              ),
                            );
                            return;
                          }

                          final boutiqueBloc = context.read<BoutiqueBloc>();
                          final boutiqueSlug = boutique.slug ?? '';

                          boutiqueBloc.add(
                            ChangeAppliedFiltersEvent(
                              boutiqueSlug: boutiqueSlug,
                              resetAppliedFilters: true,
                            ),
                          );
                          boutiqueBloc.add(
                            ChangeSelectedFiltersEvent(
                              boutiqueSlug: boutiqueSlug,
                            ),
                          );
                          boutiqueBloc.add(
                            ChangeAppliedFiltersEvent(
                              filtersAppliedByUser: GetProductFiltersModel(
                                filters: Filter(
                                  categories: [
                                    filters.Category(
                                      slug: item.categorySlug,
                                      name: item.categoryName,
                                      id: item.categoryId,
                                      isSelected: true,
                                      flatPhotoPath: CategoryBanner(
                                        filePath: item.flatPhotoPath?.filePath,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              boutiqueSlug: boutiqueSlug,
                            ),
                          );
                          boutiqueBloc.add(
                            GetProductsWithFiltersEvent(
                              boutiqueSlug: boutiqueSlug,
                              fromSearch: false,

                              offset: 1,
                            ),
                          );
                          context.read<HomeBloc>().add(
                            const IsChangedVariationWhenQtyZeroEvent(
                              isChangedVariationWhenQtyZero: false,
                            ),
                          );
                          boutiqueBloc.add(
                            AddSizeAndColorFilterinTextToSearchEvent(
                              sizeAndColorFilterinTextToSearch: const {},
                            ),
                          );
                          context.read<AppBloc>()
                            ..add(HideBottomNavigationBar(false))
                            ..add(ShowOrHideBars(true))
                            ..add(ChangeIndexForSearch(0));

                          final firstBanner =
                              (boutique.banners != null &&
                                  boutique.banners!.isNotEmpty)
                              ? (boutique.banners![0].filePath ?? '')
                              : '';

                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ProductListingPage(
                                  banner: boutique.banners,
                                  withSlidingImages: withSlidingImages,
                                  boutiqueSlug: boutiqueSlug,
                                  boutiqueName: boutique.name,
                                  boutiqueFirstBanner: firstBanner,
                                  boutiqueIcon: boutique.icon?.filePath ?? "",
                                ),
                                transitionsBuilder: (_, __, ___, child) =>
                                    child,
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            MyCachedNetworkImage(
                              radius: 15.r,
                              imageUrl: item.mostViewedProductThumbnail ?? "",
                              width: 90.w,
                              imageFit: BoxFit.contain,
                              height: 90.h,
                            ),
                            if (item.mostViews ?? false)
                              Positioned(
                                child: SvgPicture.asset(AppAssets.trendingSvg),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
