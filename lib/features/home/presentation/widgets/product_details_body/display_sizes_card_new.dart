import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trydos/common/constant/design/assets_provider.dart';

import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_detail_without_related_products_model.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/language_service.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_events.dart';
import '../../../../../service/firebase_analytics_service/analytics_const/analytics_buttons_event_name.dart';
import '../../../../../service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../data/models/get_product_listing_without_filters_model.dart'
    as product;
import '../../../../../core/utils/theme_state.dart';
import '../../manager/homeBloc/home_bloc.dart';
import '../../manager/homeBloc/home_event.dart';
import '../../manager/homeBloc/home_state.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class DisplaySizesCardNew extends StatefulWidget {
  const DisplaySizesCardNew(
      {super.key,
      required this.variation,
      required this.productItem,
      required this.currentColorForProduct});

  final List<Variation>? variation;
  final product.Products productItem;
  final int currentColorForProduct;

  @override
  State<DisplaySizesCardNew> createState() => _DisplaySizesCardNewState();
}

class _DisplaySizesCardNewState extends ThemeState<DisplaySizesCardNew> {
  List<String>? sizes;

  late HomeBloc homeBloc;

  final ValueNotifier<int> currentSelectedSizeIndex = ValueNotifier(0);

  List<int> sizesQuantities = [];

  RenderBox? renderBox;

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    sizes = [];
    if (widget.variation != null) {
      widget.variation!.forEach((element) {
        if ((homeBloc
                    .state
                    .cachedProductWithoutRelatedProductsModel[
                        widget.productItem.productId.toString()]!
                    .product!
                    .colors
                    .isNullOrEmpty ||
                element.type!.split("-")[0] ==
                    homeBloc
                        .state
                        .cachedProductWithoutRelatedProductsModel[
                            widget.productItem.productId.toString()]!
                        .product!
                        .colors?[widget.currentColorForProduct]
                        .option) &&
            element.qty != null) {
          sizes!.add(element.type!.split("-")[homeBloc
                  .state
                  .cachedProductWithoutRelatedProductsModel[
                      widget.productItem.productId.toString()]!
                  .product!
                  .colors
                  .isNullOrEmpty
              ? 0
              : 1]);
        }
      });
    }
    int currentIndexOfSelectedSize = sizes!.indexWhere((size) =>
        size ==
        BlocProvider.of<HomeBloc>(context)
            .state
            .currentColorSizeForCart?['choiceOption']);

    if (currentIndexOfSelectedSize == -1) {
      if (sizes!.length <= 8) {
        currentSelectedSizeIndex.value = 0;
      } else {
        currentSelectedSizeIndex.value = sizes!.length ~/ 4;
      }
    } else {
      currentSelectedSizeIndex.value = currentIndexOfSelectedSize;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (p, c) =>
          p.currentColorSizeForCart?['choiceOption'] !=
          c.currentColorSizeForCart?['choiceOption'],
      listener: (context, state) {
        currentSelectedSizeIndex.value = sizes?.indexWhere((size) =>
                size == state.currentColorSizeForCart?['choiceOption']) ??
            currentSelectedSizeIndex.value;
      },
      child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) =>
              p.currentSelectedColorForEveryProduct !=
                  c.currentSelectedColorForEveryProduct ||
              p.sizesForEachColor != c.sizesForEachColor,
          builder: (context, state) {
            sizes = state.sizesForEachColor;
            sizesQuantities = state.sizesQuantitiesForEachColor ?? [];

            return Container(
              height: 137,
              padding: const EdgeInsets.all(8),
              width: 1.sw,
              margin: EdgeInsets.only(
                top: 10,
                bottom: 15,
                left: LanguageService.languageCode == "ar" ? 0 : 15,
                right: LanguageService.languageCode != "ar" ? 0 : 15,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xffFCFCFC)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 1.sw,
                    height: 20,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.sizeIconSvg,
                          // ignore: deprecated_member_use
                          color: const Color(0xff1D1D1D),
                          height: 20,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        _sizesType(" CM ", const Color(0xffF4F4F4)),
                        const SizedBox(
                          width: 2,
                        ),
                        _sizesType(" INC ", null),
                        const Spacer(),
                        _sizesType(" Standart ", const Color(0xffF4F4F4)),
                        const SizedBox(
                          width: 2,
                        ),
                        _sizesType(" EU ", null),
                        const SizedBox(
                          width: 2,
                        ),
                        _sizesType(" IN ", null),
                        const SizedBox(
                          width: 2,
                        ),
                        _sizesType(" US ", null),
                        const SizedBox(
                          width: 2,
                        ),
                        _sizesType(" Uk ", null),
                        const SizedBox(
                          width: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyTextWidget(
                    LocaleKeys.n_sizes.tr(),
                    style: textTheme.titleLarge?.rr
                        .copyWith(fontSize: 9, color: const Color(0xff1D1D1D)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      MyTextWidget(
                        "${sizes?.length.toString() ?? ""} ",
                        style: textTheme.titleLarge?.br.copyWith(
                            fontSize: 11, color: const Color(0xff1D1D1D)),
                      ),
                      MyTextWidget(
                        LocaleKeys.size_available.tr(),
                        style: textTheme.titleLarge?.rr.copyWith(
                            fontSize: 9, color: const Color(0xff1D1D1D)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder<int>(
                      valueListenable: currentSelectedSizeIndex,
                      builder: (context, _visibleSizeAndColorCard, _) {
                        return SizedBox(
                          width: 1.sw,
                          height: 46,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => _sizesWidget(
                                sizes?[index] ?? "",
                                "",
                                index,
                                index == currentSelectedSizeIndex.value
                                    ? const Color(0xffF4F4F4)
                                    : null),
                            itemCount: sizes?.length,
                          ),
                        );
                      })
                ],
              ),
            );
          }),
    );
  }

  Widget _sizesType(String text, Color? color) {
    return Container(
      alignment: Alignment.center,
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: color ?? const Color(0xffFCFCFC),
          border: Border.all(color: const Color(0xffD3D3D3)),
          borderRadius: BorderRadius.circular(6)),
      child: MyTextWidget(
        text,
        style: textTheme.titleLarge?.rr
            .copyWith(fontSize: 11, color: const Color(0xff1D1D1D)),
      ),
    );
  }

  Widget _sizesWidget(String text, String? num, int index, Color? color) {
    return InkWell(
        onTap: () {
          currentSelectedSizeIndex.value = index;
          BlocProvider.of<HomeBloc>(context).add(AddCurrentColorSizeEvent(
              choice_1: widget.productItem.choiceOptions?[0].options
                  ?.firstWhere((element) => element.option == sizes?[index])
                  .name,
              choiceOption: sizes?[index]));

          FirebaseAnalyticsService.logEventForSession(
            executedEventName: AnalyticsButtonsEventNameConst.SIZE_SLIDE,
            eventName: AnalyticsEventsConst.CHANGE_SIZE,
            extraParams: {
              'item_id': widget.productItem.productId.toString(),
              'item_name': widget.productItem.name.toString(),
              'brand': widget.productItem.brand!.name.toString(),
              'category': widget.productItem.categories!
                  .map(
                    (e) => e.name,
                  )
                  .toList()
                  .toString(),
              'selected_size': sizes?[index] ?? '',
              'screen_name': GlobalScreenConst.PRODUCT_SCREEN,
              'selected_color': widget.productItem
                      .colors?[widget.currentColorForProduct].name ??
                  ''
            },
          );
        },
        child: Container(
            margin: EdgeInsets.only(
              left: LanguageService.languageCode != "ar" ? 0 : 3,
              right: LanguageService.languageCode == "ar" ? 0 : 3,
            ),
            alignment: Alignment.center,
            height: 44,
            width: 60,
            decoration: BoxDecoration(
                color: color ?? const Color(0xffFCFCFC),
                border: Border.all(color: const Color(0xffD3D3D3)),
                borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyTextWidget(
                  text,
                  style: textTheme.titleLarge?.rr
                      .copyWith(fontSize: 11, color: const Color(0xff1D1D1D)),
                ),
                num == null || num == ""
                    ? const SizedBox.shrink()
                    : MyTextWidget(
                        num,
                        style: textTheme.titleLarge?.rr.copyWith(
                            fontSize: 11, color: const Color(0xff1D1D1D)),
                      ),
              ],
            )));
  }
}
