import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import '../../../../../common/constant/design/assets_provider.dart';
import '../../../../../core/utils/theme_state.dart';

class SelectSizeContent extends StatefulWidget {
  const SelectSizeContent({
    super.key,
    required this.scrollController,
    required this.selectedColor,
    required this.addToBagButtonShapeNotifier,
    required this.sizeIsNotAvailableNotifier,
  });

  final ScrollController scrollController;
  final Color selectedColor;

  final ValueNotifier<int> addToBagButtonShapeNotifier;
  final ValueNotifier<String?> sizeIsNotAvailableNotifier;

  @override
  State<SelectSizeContent> createState() => _SelectSizeContentState();
}

class _SelectSizeContentState extends ThemeState<SelectSizeContent> {
  List<String> sizes = [];

  final CarouselController carouselController = CarouselController();
  late final ValueNotifier<int> currentIndexInSizes;
  late HomeBloc homeBloc;
  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    currentIndexInSizes = ValueNotifier(0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.currentSelectedColorForEveryProduct !=
          c.currentSelectedColorForEveryProduct,
      builder: (context, state) {
        sizes = state.sizes ?? [];

        currentIndexInSizes.value = sizes.length ~/ 2;
        if (sizes.length > 0) {
          homeBloc.add(
              AddCurrentColorSizeEvent(choice_1: sizes[sizes.length ~/ 2]));
        }
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
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(AppAssets.sizeIconSvg),
                  const SizedBox(
                    width: 10,
                  ),
                  MyTextWidget(
                    'Please Select The Appropriate ',
                    style: textTheme.bodyText2?.rq
                        .copyWith(height: 0.86, color: const Color(0xff505050)),
                  ),
                  MyTextWidget(
                    'Size',
                    style: textTheme.bodyText2?.mq
                        .copyWith(height: 0.86, color: const Color(0xff505050)),
                  )
                ],
              ),
              const SizedBox(
                height: 14,
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
                                    color: sizes[currentIndex] == 'S'
                                        ? const Color(0xffFF5F61)
                                        : sizes[currentIndex] == 'XS'
                                            ? const Color(0xffFFAF5F)
                                            : const Color(0xff505050),
                                  )),
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(180),
                                    border: Border.all(
                                        color: widget.selectedColor,
                                        width: 0.5),
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
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Center(
                                    child: Text(
                                      sizes[index],
                                      style: textTheme.headline2?.bq.copyWith(
                                        height: 1.3,
                                        fontSize: index != currentIndex
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
                                            : 30.sp,
                                        color: index == currentIndex
                                            ? Colors.white
                                            : sizes[index] == 'S'
                                                ? const Color(0xffFF5F61)
                                                : sizes[index] == 'XS'
                                                    ? const Color(0xffFFAF5F)
                                                    : const Color(0xff505050),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                  initialPage: sizes.length ~/ 2,
                                  height: 80,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    homeBloc.add(AddCurrentColorSizeEvent(
                                        choice_1: sizes[index]));
                                    HapticFeedback.lightImpact();
                                    currentIndexInSizes.value = index;
                                    if (sizes[index] == 'S') {
                                      widget.sizeIsNotAvailableNotifier.value =
                                          sizes[index];
                                    } else {
                                      widget.sizeIsNotAvailableNotifier.value =
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
                    if (sizes[currentIndex] == 'S') {
                      return MyTextWidget(
                        'Not Available Now, Stock Is Sold Out',
                        style: textTheme.caption?.mq.copyWith(
                            height: 1, color: const Color(0xffFF5F61)),
                      );
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyTextWidget(
                          'M ',
                          style: textTheme.caption?.bq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          'Recommended ',
                          style: textTheme.caption?.rq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          'Size ',
                          style: textTheme.caption?.bq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        MyTextWidget(
                          'For You ',
                          style: textTheme.caption?.rq.copyWith(
                              height: 1, color: const Color(0xff505050)),
                        ),
                        if (sizes[currentIndex] == 'XS') ...{
                          MyTextWidget(
                            'Last ',
                            style: textTheme.caption?.rq.copyWith(
                                height: 1, color: const Color(0xffFFAF5F)),
                          ),
                          MyTextWidget(
                            '2',
                            style: textTheme.caption?.mq.copyWith(
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
                              'Need Help Finding Your Size?',
                              style: textTheme.bodyText2?.rq
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
