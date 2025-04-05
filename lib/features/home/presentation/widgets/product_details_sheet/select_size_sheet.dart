import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:tuple/tuple.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/theme_state.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SelectSizeContent extends StatefulWidget {
  SelectSizeContent({
    super.key,
    required this.scrollController,
    this.selectedColor,
    this.selectedColorName,
    required this.productId,
    required this.requestToNotifyMeFormFirstSize,
    required this.collectedAfterOrdering,
    required this.colorIsNotAvailableNotifier,
    required this.addToBagButtonShapeNotifier,
    required this.sizeIsNotAvailableNotifier,
    required this.fromListingPage,
  });

  final ScrollController scrollController;
  final Color? selectedColor;
  final String? selectedColorName;
  final String productId;
  final bool collectedAfterOrdering;
  final bool fromListingPage;

  bool requestToNotifyMeFormFirstSize;
  final ValueNotifier<int> addToBagButtonShapeNotifier;
  final ValueNotifier<String?> sizeIsNotAvailableNotifier;
  final ValueNotifier<String?> colorIsNotAvailableNotifier;

  @override
  State<SelectSizeContent> createState() => _SelectSizeContentState();
}

class _SelectSizeContentState extends ThemeState<SelectSizeContent> {
  List<String> sizes = [];
  List<int> sizesQuantities = [];

  final CarouselSliderController carouselController =
      CarouselSliderController();
  late final ValueNotifier<int> currentIndexInSizes;
  late HomeBloc homeBloc;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);

    if (!(homeBloc.state.sizesForEachColor.isNullOrEmpty) &&
        !(widget.fromListingPage)) {
      currentIndexInSizes = ValueNotifier(homeBloc.state.sizesForEachColor!
          .indexWhere((element) =>
              element == homeBloc.state.currentColorSizeForCart?["size"]));
      if (currentIndexInSizes.value == -1) {
        currentIndexInSizes = ValueNotifier(0);
      }
    }
    if (widget.fromListingPage &&
        (homeBloc
                    .state
                    .cachedProductWithoutRelatedProductsModel[widget.productId]
                    ?.product
                    ?.choiceOptions
                    ?.length ??
                0) >
            0) {
      currentIndexInSizes = ValueNotifier((homeBloc
                  .state
                  .cachedProductWithoutRelatedProductsModel[widget.productId]
                  ?.product
                  ?.choiceOptions?[0]
                  .options
                  ?.length ??
              0) ~/
          2);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      try {
        BlocProvider.of<HomeBloc>(context).add((SendErrorToMobileErrorLogEvent(
            errorExption: error.exceptionAsString().toString(),
            errorPath: error.stack.toString().split("#")[1],
            urlBackend: "Front Error",
            messageFromeBackend: "Front Error")));
      } catch (e) {}
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.changeSizesForEveryProduct !=
              current.changeSizesForEveryProduct ||
          previous.currentColorSizeForCart?["size"] !=
              current.currentColorSizeForCart?["size"],
      builder: (context, state) {
        sizes = state.sizesForEachColor ?? [];
        sizesQuantities = state.sizesQuantitiesForEachColor ?? [];

        if (sizes.length == 0) {
          return Container(
            color: Colors.white,
            height: 210,
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(AppAssets.sizeIconSvg),
                  const SizedBox(
                    width: 10,
                  ),
                  MyTextWidget(
                    '${LocaleKeys.please_select_the_appropriate.tr()} ',
                    style: textTheme.titleLarge?.rq
                        .copyWith(height: 0.86, color: const Color(0xff505050)),
                  ),
                  MyTextWidget(
                    '${LocaleKeys.size.tr()}',
                    style: textTheme.titleLarge?.mq
                        .copyWith(height: 0.86, color: const Color(0xff505050)),
                  )
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 100,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (ctx, index) => const SizedBox(
                            width: 6,
                          ),
                      itemBuilder: (ctx, index) {
                        if (index > 0 && index % 10 == 9) {
                          return const SizedBox(
                            width: 4,
                          );
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: const Color(0xff505050),
                              width: 0.3,
                              height: index > 0 && index % 10 == 4 ? 8 : 4.57,
                            ),
                          ],
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ValueListenableBuilder<int>(
                    valueListenable: currentIndexInSizes,
                    builder: (context, currentIndex, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0, 3),
                                        blurRadius: 3,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(180),
                                    color: sizesQuantities[currentIndex] == 0
                                        ? const Color(0xffFF5F61)
                                        : sizesQuantities[currentIndex] <= 10
                                            ? const Color(0xffFFAF5F)
                                            : const Color.fromARGB(
                                                255, 75, 61, 61),
                                  )),
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(180),
                                    border: widget.selectedColor != null
                                        ? Border.all(
                                            color: widget.selectedColor!,
                                            width: 0.5)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                          color: colorScheme.white,
                                          offset: const Offset(0, 4),
                                          blurRadius: 6,
                                          inset: true),
                                    ]),
                              )
                            ],
                          ),
                          CarouselSlider.builder(
                              itemCount: sizes.length,
                              carouselController: carouselController,
                              itemBuilder: (ctx, index, _) {
                                if (widget.requestToNotifyMeFormFirstSize) {
                                  Future.delayed(
                                    Duration(milliseconds: 300),
                                    () {
                                      if (sizesQuantities[currentIndex] == 0 &&
                                          !widget.collectedAfterOrdering) {
                                        widget.colorIsNotAvailableNotifier
                                                .value =
                                            widget.selectedColorName ?? null;

                                        widget.sizeIsNotAvailableNotifier
                                            .value = sizes[currentIndex];
                                        widget.requestToNotifyMeFormFirstSize =
                                            false;
                                      } else {
                                        widget.colorIsNotAvailableNotifier
                                            .value = null;
                                        widget.sizeIsNotAvailableNotifier
                                            .value = null;
                                      }
                                    },
                                  );
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Container(
                                    width: 65,
                                    child: GestureDetector(
                                      onTap: () =>
                                          carouselController.animateToPage(
                                        index,
                                      ),
                                      child: Center(
                                        child: Text(
                                          sizes[index],
                                          style: textTheme.headlineLarge?.bq
                                              .copyWith(
                                            height: 1.3,
                                            fontSize: 18.sp,
                                            /*index != currentIndex
                                                ? index < currentIndex
                                                    ? max(
                                                        10.sp,
                                                        (25 -
                                                                (currentIndex -
                                                                        index) *
                                                                    5)
                                                            .sp)
                                                    : max(
                                                        10.sp,
                                                        (25 -
                                                                (index -
                                                                        currentIndex) *
                                                                    5)
                                                            .sp)
                                                : 20.sp,*/
                                            color: index == currentIndex
                                                ? Colors.white
                                                : sizesQuantities[index] == 0
                                                    ? const Color(0xffFF5F61)
                                                    : sizesQuantities[index] <=
                                                            10
                                                        ? const Color(
                                                            0xffFFAF5F)
                                                        : const Color(
                                                            0xff505050),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                  initialPage: currentIndexInSizes.value,
                                  height: 80,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    currentIndexInSizes.value = index;
                                    homeBloc.add(AddCurrentColorSizeEvent(
                                        choice_1: sizes[index]));
                                    HapticFeedback.lightImpact();
                                    if (sizesQuantities[index] == 0 &&
                                        !widget.collectedAfterOrdering) {
                                      widget.sizeIsNotAvailableNotifier.value =
                                          sizes[index];
                                      widget.colorIsNotAvailableNotifier.value =
                                          widget.selectedColorName ?? null;
                                    } else {
                                      widget.sizeIsNotAvailableNotifier.value =
                                          null;
                                      widget.colorIsNotAvailableNotifier.value =
                                          null;
                                    }
                                  },
                                  viewportFraction: 0.22)),
                        ],
                      );
                    }),
              ),
              SizedBox(
                height: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 100,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (ctx, index) => const SizedBox(
                            width: 6,
                          ),
                      itemBuilder: (ctx, index) {
                        if (index > 0 && index % 10 == 9) {
                          return const SizedBox(
                            width: 4,
                          );
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: const Color(0xff505050),
                              width: 0.3,
                              height: index > 0 && index % 10 == 4 ? 8 : 4.57,
                            ),
                          ],
                        );
                      }),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder<int>(
                  valueListenable: currentIndexInSizes,
                  builder: (context, currentIndex, _) {
                    if (sizesQuantities[currentIndex] == 0) {
                      return MyTextWidget(
                        '${LocaleKeys.not_available_now_stock.tr()}',
                        style: textTheme.titleMedium?.mq.copyWith(
                            height: 1, color: const Color(0xffFF5F61)),
                      );
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyTextWidget(
                          '${sizes[currentIndex]} ',
                          style: textTheme.titleMedium?.bq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.recommended.tr()} ',
                          style: textTheme.titleMedium?.rq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.size.tr()} ',
                          style: textTheme.titleMedium?.bq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          '${LocaleKeys.for_you.tr()} ',
                          style: textTheme.titleMedium?.rq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        if (sizesQuantities[currentIndex] <= 10) ...{
                          MyTextWidget(
                            '${LocaleKeys.last.tr()} ',
                            style: textTheme.titleMedium?.rq.copyWith(
                                height: 1, color: const Color(0xffFFAF5F)),
                          ),
                          MyTextWidget(
                            '${sizesQuantities[currentIndex]}',
                            style: textTheme.titleMedium?.mq.copyWith(
                                height: 1, color: const Color(0xffFFAF5F)),
                          ),
                        }
                      ],
                    );
                  }),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 1.sw - 120,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.coloredSizeIconSvg,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            MyTextWidget(
                              '${LocaleKeys.need_help_finding_your_size.tr()}',
                              style: textTheme.titleLarge?.rq
                                  .copyWith(color: const Color(0xff505050)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F8F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.recyclingSvg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
