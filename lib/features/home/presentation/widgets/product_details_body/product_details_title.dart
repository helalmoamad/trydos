import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/data/models/get_product_listing_without_filters_model.dart'
    as Brand;
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/features/home/presentation/widgets/product_listing/falsh_deal_counter.dart';
import 'package:trydos/features/home/presentation/widgets/rotating_text_widget.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../app/svg_network_widget.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:get_it/get_it.dart';

class ProductDetailsTitle extends StatelessWidget {
  final Brand.Brand? brand;

  final String productName;
  final String productId;
  final String thumbnail;
  final String colorName;
  final double orginalWidth;

  final double orginalHeight;
  ProductDetailsTitle(
      {super.key,
      this.brand,
      required this.productName,
      required this.thumbnail,
      required this.productId,
      required this.orginalHeight,
      required this.orginalWidth,
      required this.colorName});

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
      buildWhen: (p, c) =>
          p.getProductDetailWithoutSimilarRelatedProductsStatus !=
              c.getProductDetailWithoutSimilarRelatedProductsStatus ||
          p.cachedProductWithoutRelatedProductsModel[productId] !=
              c.cachedProductWithoutRelatedProductsModel[productId] ||
          p.currentSelectedColorForEveryProduct !=
              c.currentSelectedColorForEveryProduct ||
          p.getAndAddCountViewOfProductStatus[productId] !=
              c.getAndAddCountViewOfProductStatus[productId],
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  brand != null
                      ? brand!.icon != null
                          ? brand!.icon!.filePath != null
                              ? SvgNetworkWidget(
                                  svgUrl: brand!.icon!.filePath!,
                                  height: 18,
                                )
                              : SizedBox.shrink()
                          : SizedBox.shrink()
                      : SizedBox.shrink(),
                  state.getAndAddCountViewOfProductStatus[productId] == null ||
                          state.cachedProductWithoutRelatedProductsModel[
                                  productId] ==
                              null
                      ? Container(
                          width: 18,
                          height: 18,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade400,
                            highlightColor: Colors.grey.shade100,
                            child: SvgPicture.asset(AppAssets.eyeSvg),
                          ),
                        )
                      : (state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productId]!
                                      .product !=
                                  null
                              ? state
                                      .cachedProductWithoutRelatedProductsModel[
                                          productId]!
                                      .product!
                                      .viewsCount ==
                                  null
                              : true)
                          ? Container(
                              width: 18,
                              height: 18,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade400,
                                highlightColor: Colors.grey.shade100,
                                child: SvgPicture.asset(AppAssets.eyeSvg),
                              ),
                            )
                          : Row(
                              children: [
                                SvgPicture.asset(
                                  AppAssets.eyeSvg,
                                  height: 15,
                                  width: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                MyTextWidget(
                                  state.cachedProductWithoutRelatedProductsModel[
                                              productId] !=
                                          null
                                      ? state
                                                  .cachedProductWithoutRelatedProductsModel[
                                                      productId]!
                                                  .product !=
                                              null
                                          ? state
                                              .cachedProductWithoutRelatedProductsModel[
                                                  productId]!
                                              .product!
                                              .viewsCount
                                              .toString()
                                          : "0"
                                      : "0",
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                          color: Color(0xff505050),
                                          height: 1.26),
                                )
                              ],
                            )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: 1.sw - 20,
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    MyTextWidget(
                      productName,
                      style: context.textTheme.bodyMedium?.mq.copyWith(
                          color: Color(0xff5D5C5D),
                          height: 1.26,
                          fontSize: 15.sp),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: MyCachedNetworkImage(
                        ordinalHeight: orginalHeight,
                        ordinalwidth: orginalWidth,
                        imageFit: BoxFit.cover,
                        imageUrl: thumbnail,
                        height: 15,
                        width: 15,
                        circleDimensions: 7,
                        logoTextHeight: 7,
                        logoTextWidth: 12,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Color(0xff8D8D8D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: MyTextWidget(
                        colorName,
                        style: context.textTheme.bodyMedium?.rq.copyWith(
                            color: Color(0xff404E68),
                            height: 1.26,
                            fontSize: 15.sp),
                      ),
                    )
                  ],
                ),
              ),
            ),
            (state.cachedProductWithoutRelatedProductsModel[productId]?.product
                            ?.labelNames?.length ??
                        0) ==
                    0
                ? SizedBox(
                    height: 10,
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: RotatingTextWidget(
                      texts: state
                              .cachedProductWithoutRelatedProductsModel[
                                  productId]
                              ?.product
                              ?.labelNames ??
                          [],
                      rotationDuration: Duration(seconds: 5),
                      textStyle: context.textTheme.titleMedium?.rr.copyWith(
                        fontSize: 9.sp,
                        color: Color(0xff388CFF),
                        height: 0,
                      ),
                    )),
          ],
        );
      },
    );
  }
}
