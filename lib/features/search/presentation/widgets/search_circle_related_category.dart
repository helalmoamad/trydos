import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

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

class SearchChipRelatedCategory extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isLoading;
  const SearchChipRelatedCategory({
    Key? key,
    required this.title,
    required this.controller,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<SearchChipRelatedCategory> createState() =>
      _SearchChipRelatedCategoryState();
}

class _SearchChipRelatedCategoryState extends State<SearchChipRelatedCategory> {
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
        int visible = filters.relatedCategories?.length ?? 0;
        return visible > 0
            ? Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.h,
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
                    SizedBox(height: 10.w),
                    SizedBox(
                      height: 40.h,
                      child: ScrollConfiguration(
                        behavior: const CupertinoScrollBehavior(),
                        child: ListView.separated(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            bool isSelected =
                                state
                                    .choosedFiltersByUser[key]
                                    ?.filters
                                    ?.categories
                                    ?.any(
                                      (element) =>
                                          (element.id ==
                                          filters.relatedCategories?[index].id),
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
                                    if (isSelected) {
                                      List<Categories.Category> category =
                                          prevChoosedFilterToAddToIt
                                              .categories ??
                                          [];

                                      category.removeWhere(
                                        (element) =>
                                            element.id ==
                                            filters
                                                .relatedCategories?[index]
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
                                                  filters
                                                      .relatedCategories![index],
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
                                            color: isSelected
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
                                                    .relatedCategories![index]
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                              child:
                                                  filters
                                                          .relatedCategories?[index]
                                                          .flatPhotoPath
                                                          ?.filePath !=
                                                      null
                                                  ? mediaServerIsS3
                                                        ? MyCachedNetworkImage(
                                                            imageUrl: filters
                                                                .relatedCategories![index]
                                                                .flatPhotoPath!
                                                                .filePath!,
                                                            height: 15,
                                                            imageFit:
                                                                BoxFit.contain,
                                                            width: 15.w,
                                                          )
                                                        : SvgNetworkWidget(
                                                            svgUrl: filters
                                                                .relatedCategories![index]
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
                                        visible: isSelected,
                                        child: FilterSelectedMark(
                                          width: 12.w,
                                          height: 12.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(width: 10.w);
                          },
                          itemCount: filters.relatedCategories?.length ?? 0,
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
