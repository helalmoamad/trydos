/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/product_listing_filter_list.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as product_listing;
import '../../../home/presentation/widgets/product_listing/categories_filter_list.dart';

class SearchChipCategory extends StatefulWidget {
  final String title;
  final bool isLoading;
  final TextEditingController controller;

  const SearchChipCategory(
      {Key? key,
      required this.title,
      required this.controller,
      required this.isLoading})
      : super(key: key);

  @override
  State<SearchChipCategory> createState() => _SearchChipCategoryState();
}

class _SearchChipCategoryState extends State<SearchChipCategory> {
  final ValueNotifier<bool> scaleTheTopItemInFiltersStack =
      ValueNotifier(false);
  final ValueNotifier<int> expandingFiltersStack = ValueNotifier(-1);
  final ScrollController scrollController = ScrollController();
  late HomeBloc homeBloc;

  List<String> selectedCategorySlugs = [];

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        String key = 'search';
        Filter filters = state.getProductFiltersModel[key]?.filters ?? Filter();
        int visible = filters.categories?.length ?? 0;
        return visible > 0
            ? Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xffC4C2C2), width: 0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyTextWidget(
                            widget.title,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                                color: Color(0xff505050), height: 15 / 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          widget.isLoading
                              ? Container(
                                  width: 15,
                                  height: 15,
                                  child: Center(
                                    child: TrydosLoader(
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ))
                              : SizedBox.shrink(),
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.backArrowArabic,
                            matchTextDirection: true,
                            color: Color(0xffC4C2C2),
                            width: 10,
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 90,
                      child: ScrollConfiguration(
                          behavior: CupertinoScrollBehavior(),
                          child: CategoriesFilterList(
                            controller: widget.controller,
                            boutiqueSlug: 'search',
                            fromSearch: true,
                            expandingFiltersStack: expandingFiltersStack,
                            scaleTheTopItemInFiltersStack:
                                scaleTheTopItemInFiltersStack,
                            workWithChoosedFilter: true,
                          )),
                    ),
                  ],
                ))
            : SizedBox.shrink();
      },
    );
  }
}*/

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';

import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';

import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_state.dart';
import 'package:trydos/main.dart';

import '../../../../common/constant/design/assets_provider.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/data/models/get_product_filters_model.dart';
import '../../../home/data/models/get_product_listing_with_filters_model.dart'
    as Categories;
import '../../../home/presentation/widgets/product_listing/product_listing_filter_list.dart';

class SearchChipCategory extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isLoading;
  const SearchChipCategory({
    Key? key,
    required this.title,
    required this.controller,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<SearchChipCategory> createState() => _SearchChipCategoryState();
}

class _SearchChipCategoryState extends State<SearchChipCategory> {
  final ScrollController scrollController = ScrollController();
  late BoutiqueBloc boutiqueBloc;
  Timer? debounce;
  List<String> selectedCaregorySlugs = [];

  void _onScroll() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }

    debounce = Timer(const Duration(milliseconds: 600), () {
      if (!scrollController.hasClients ||
          scrollController.positions.length != 1) {
        return;
      }

      final position = scrollController.position;
      if (position.pixels >= (position.maxScrollExtent * 0.6)) {
        boutiqueBloc.add(
          GetFiltersWithPaginatioEvent(
            fromHomePageSearch: true,
            searchText: widget.controller.text,
            boutiqueSlug: "search",
          ),
        );
      }
    });
  }

  @override
  void initState() {
    boutiqueBloc = BlocProvider.of<BoutiqueBloc>(context);
    scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoutiqueBloc, BoutiqueState>(
      builder: (context, state) {
        String key = 'search';
        Filter filters = state.getProductFiltersModel[key]?.filters ?? Filter();
        int visible = filters.categories?.length ?? 0;
        return visible > 0
            ? Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.w,
                ).copyWith(bottom: 10.h),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: const Color(0xffC4C2C2),
                    width: 0.3,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyTextWidget(
                            widget.title,
                            style: context.textTheme.titleMedium?.rq.copyWith(
                              color: const Color(0xff505050),
                              height: 15 / 12,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          widget.isLoading
                              ? Container(
                                  width: 15.w,
                                  height: 15.h,
                                  child: Center(
                                    child: TrydosLoader(
                                      color: Colors.black,
                                      size: 15.h,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const Spacer(),
                          SvgPicture.asset(
                            AppAssets.backArrowArabic,
                            matchTextDirection: true,
                            // ignore: deprecated_member_use
                            color: const Color(0xffC4C2C2),
                            width: 10.w,
                            height: 10.h,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 40.h,
                      child: ScrollConfiguration(
                        behavior: const CupertinoScrollBehavior(),
                        child: ListView.separated(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            bool isChildCategorySlug = false;
                            filters.categories?[index].subCategories?.forEach((
                              elements,
                            ) {
                              if (state
                                      .choosedFiltersByUser[key]
                                      ?.filters
                                      ?.categories
                                      ?.any(
                                        (element) =>
                                            (element.slug == elements.slug),
                                      ) ??
                                  false) {
                                isChildCategorySlug = true;
                              }
                              ;
                            });
                            bool isSelected =
                                state
                                    .choosedFiltersByUser[key]
                                    ?.filters
                                    ?.categories
                                    ?.any(
                                      (element) =>
                                          (element.id ==
                                          filters.categories?[index].id),
                                    ) ??
                                false;
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if ((widget.isLoading)) {
                                      return;
                                    }
                                    Filter? prevChoosedFilterToAddToIt = state
                                        .choosedFiltersByUser[key]
                                        ?.filters;
                                    if (prevChoosedFilterToAddToIt == null) {
                                      prevChoosedFilterToAddToIt = Filter();
                                    }
                                    if (isSelected || isChildCategorySlug) {
                                      List<Categories.Category> category =
                                          prevChoosedFilterToAddToIt
                                              .categories ??
                                          [];
                                      Categories.Category? categoryForSub =
                                          !category.isNullOrEmpty ||
                                              category != []
                                          ? category.firstWhere(
                                              (element) =>
                                                  element.id ==
                                                  filters.categories?[index].id,
                                              orElse: () =>
                                                  Categories.Category(),
                                            )
                                          : Categories.Category();
                                      List<Categories.SubCategory>?
                                      subCategory =
                                          categoryForSub.subCategories;

                                      category.removeWhere(
                                        (element) =>
                                            element.id ==
                                            filters.categories?[index].id,
                                      );
                                      subCategory?.forEach((elements) {
                                        category.removeWhere(
                                          (element) =>
                                              element.id == elements.id,
                                        );
                                      });
                                      if (isChildCategorySlug) {
                                        category = [];
                                      }

                                      prevChoosedFilterToAddToIt =
                                          prevChoosedFilterToAddToIt
                                              .copyWithSaveOtherField(
                                                searchText:
                                                    widget
                                                            .controller
                                                            .text
                                                            .length >
                                                        2
                                                    ? widget.controller.text
                                                    : null,
                                                categories: category,
                                              );
                                    } else {
                                      prevChoosedFilterToAddToIt =
                                          prevChoosedFilterToAddToIt
                                              .copyWithSaveOtherField(
                                                searchText:
                                                    widget
                                                            .controller
                                                            .text
                                                            .length >
                                                        2
                                                    ? widget.controller.text
                                                    : null,
                                                categories: [
                                                  ...prevChoosedFilterToAddToIt
                                                          .categories ??
                                                      [],
                                                  filters.categories![index],
                                                ],
                                              );
                                    }
                                    boutiqueBloc.add(
                                      ChangeSelectedFiltersEvent(
                                        fromHomePageSearch: true,
                                        boutiqueSlug: key,
                                        requestToUpdateFilters:
                                            (widget.controller.text.length > 2)
                                            ? false
                                            : true,
                                        filtersChoosedByUser:
                                            GetProductFiltersModel(
                                              filters:
                                                  prevChoosedFilterToAddToIt,
                                            ),
                                      ),
                                    );
                                    if (widget.controller.text.length > 2) {
                                      boutiqueBloc.add(
                                        GetProductsWithFiltersEvent(
                                          fromChoosed: true,
                                          offset: 1,
                                          boutiqueSlug: 'search',
                                          resetChoosedFilters: false,
                                          fromSearch: true,
                                          searchText: widget.controller.text,
                                        ),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          color: const Color(0xffF8F8F8),
                                          border: Border.all(
                                            color:
                                                isSelected ||
                                                    isChildCategorySlug
                                                ? const Color(0xffFF5F61)
                                                : const Color(0xffF8F8F8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(),
                                        child: Row(
                                          children: [
                                            Center(
                                              child: MyTextWidget(
                                                filters
                                                    .categories![index]
                                                    .name!,
                                                style: context
                                                    .textTheme
                                                    .titleLarge
                                                    ?.rq
                                                    .copyWith(
                                                      height: 12 / 14,
                                                      color: const Color(
                                                        0xff8D8D8D,
                                                      ),
                                                      fontSize: 13.sp,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5.w,
                                              ),
                                              child:
                                                  filters
                                                          .categories?[index]
                                                          .flatPhotoPath
                                                          ?.filePath !=
                                                      null
                                                  ? mediaServerIsS3
                                                        ? MyCachedNetworkImage(
                                                            imageUrl: filters
                                                                .categories![index]
                                                                .flatPhotoPath!
                                                                .filePath!,
                                                            height: 15,
                                                            imageFit:
                                                                BoxFit.contain,
                                                            width: 15.w,
                                                          )
                                                        : SvgNetworkWidget(
                                                            svgUrl: filters
                                                                .categories![index]
                                                                .flatPhotoPath!
                                                                .filePath!,
                                                            height: 15.h,
                                                          )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            isSelected || isChildCategorySlug,
                                        child: FilterSelectedMark(
                                          width: 12.w,
                                          height: 12.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: isSelected || isChildCategorySlug,
                                  child: SizedBox(
                                    height: 40.h,
                                    child: ScrollConfiguration(
                                      behavior: const CupertinoScrollBehavior(),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, indexs) {
                                          bool isSubSelected =
                                              state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters
                                                  ?.categories
                                                  ?.any(
                                                    (element) =>
                                                        element.id ==
                                                        filters
                                                            .categories?[index]
                                                            .subCategories?[indexs]
                                                            .id,
                                                  ) ??
                                              false;
                                          return InkWell(
                                            onTap: () {
                                              Filter?
                                              prevChoosedFilterToAddToIt = state
                                                  .choosedFiltersByUser[key]
                                                  ?.filters;
                                              if (prevChoosedFilterToAddToIt ==
                                                  null) {
                                                prevChoosedFilterToAddToIt =
                                                    Filter();
                                              }
                                              if (isSubSelected) {
                                                List<Categories.Category>
                                                subCategory =
                                                    prevChoosedFilterToAddToIt
                                                        .categories ??
                                                    [];
                                                subCategory.removeWhere(
                                                  (element) =>
                                                      element.id ==
                                                      filters
                                                          .categories?[index]
                                                          .subCategories?[indexs]
                                                          .id,
                                                );
                                                prevChoosedFilterToAddToIt =
                                                    prevChoosedFilterToAddToIt
                                                        .copyWithSaveOtherField(
                                                          searchText:
                                                              widget
                                                                      .controller
                                                                      .text
                                                                      .length >
                                                                  2
                                                              ? widget
                                                                    .controller
                                                                    .text
                                                              : null,
                                                          categories:
                                                              subCategory,
                                                        );
                                              } else {
                                                List<Categories.Category>?
                                                categoryParent =
                                                    prevChoosedFilterToAddToIt
                                                        .categories;
                                                categoryParent?.removeWhere(
                                                  (element) =>
                                                      element.slug ==
                                                      filters
                                                          .categories?[index]
                                                          .slug,
                                                );
                                                prevChoosedFilterToAddToIt =
                                                    prevChoosedFilterToAddToIt.copyWithSaveOtherField(
                                                      searchText:
                                                          widget
                                                                  .controller
                                                                  .text
                                                                  .length >
                                                              2
                                                          ? widget
                                                                .controller
                                                                .text
                                                          : null,
                                                      categories: [
                                                        ...categoryParent ?? [],
                                                        Categories.Category(
                                                          isSelected: true,
                                                          name: filters
                                                              .categories?[index]
                                                              .subCategories?[indexs]
                                                              .name,
                                                          flatPhotoPath: filters
                                                              .categories?[index]
                                                              .subCategories?[indexs]
                                                              .flatPhotoPath,
                                                          id: filters
                                                              .categories?[index]
                                                              .subCategories?[indexs]
                                                              .id,
                                                          slug: filters
                                                              .categories?[index]
                                                              .subCategories?[indexs]
                                                              .slug,
                                                        ),
                                                      ],
                                                    );
                                              }
                                              boutiqueBloc.add(
                                                ChangeSelectedFiltersEvent(
                                                  fromHomePageSearch: true,
                                                  boutiqueSlug: key,
                                                  requestToUpdateFilters:
                                                      (widget
                                                              .controller
                                                              .text
                                                              .length >
                                                          2)
                                                      ? false
                                                      : true,
                                                  filtersChoosedByUser:
                                                      GetProductFiltersModel(
                                                        filters:
                                                            prevChoosedFilterToAddToIt,
                                                      ),
                                                ),
                                              );
                                              if (widget
                                                      .controller
                                                      .text
                                                      .length >
                                                  2) {
                                                boutiqueBloc.add(
                                                  GetProductsWithFiltersEvent(
                                                    fromChoosed: true,
                                                    offset: 1,
                                                    boutiqueSlug: 'search',
                                                    resetChoosedFilters: false,
                                                    fromSearch: true,
                                                    searchText:
                                                        widget.controller.text,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    color: const Color(
                                                      0xffF8F8F8,
                                                    ),
                                                    border: Border.all(
                                                      color: isSubSelected
                                                          ? const Color(
                                                              0xffFF5F61,
                                                            )
                                                          : const Color(
                                                              0xffF8F8F8,
                                                            ),
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(),
                                                  child: Row(
                                                    children: [
                                                      Center(
                                                        child: MyTextWidget(
                                                          filters
                                                              .categories![index]
                                                              .subCategories![indexs]
                                                              .name!,
                                                          style: context
                                                              .textTheme
                                                              .titleLarge
                                                              ?.rq
                                                              .copyWith(
                                                                height: 12 / 14,
                                                                fontSize: 13.sp,
                                                                color:
                                                                    const Color(
                                                                      0xff8D8D8D,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                            ),
                                                        child:
                                                            filters
                                                                    .categories![index]
                                                                    .subCategories![indexs]
                                                                    .flatPhotoPath
                                                                    ?.filePath !=
                                                                null
                                                            ? mediaServerIsS3
                                                                  ? MyCachedNetworkImage(
                                                                      imageUrl: filters
                                                                          .categories![index]
                                                                          .subCategories![indexs]
                                                                          .flatPhotoPath!
                                                                          .filePath!,
                                                                      height:
                                                                          15,
                                                                      imageFit:
                                                                          BoxFit
                                                                              .contain,
                                                                      width:
                                                                          15.w,
                                                                    )
                                                                  : SvgNetworkWidget(
                                                                      svgUrl: filters
                                                                          .categories![index]
                                                                          .subCategories![indexs]
                                                                          .flatPhotoPath!
                                                                          .filePath!,
                                                                      height:
                                                                          15,
                                                                    )
                                                            : const SizedBox.shrink(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: isSubSelected,
                                                  child: FilterSelectedMark(
                                                    width: 12.w,
                                                    height: 12.h,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(width: 10.w);
                                        },
                                        itemCount:
                                            filters
                                                .categories![index]
                                                .subCategories
                                                ?.length ??
                                            0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(width: 10.w);
                          },
                          itemCount: filters.categories?.length ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
