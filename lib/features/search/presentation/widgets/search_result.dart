import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/data/model/pagination_model.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/my_text_widget.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import 'package:trydos/features/home/presentation/manager/home_state.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import '../../../../core/utils/theme_state.dart';
import '../../../home/presentation/manager/home_bloc.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends ThemeState<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.getProductListingWithFiltersPaginationModels !=
          c.getProductListingWithFiltersPaginationModels,
      builder: (context, state) {
        if (state.getProductListingWithFiltersPaginationModels
                ?.paginationStatus !=
            PaginationStatus.success) {
          return Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 20.0),
                child: MyTextWidget(
                  LocaleKeys.find_products.tr(),
                  style: textTheme.caption?.rq
                      .copyWith(height: 15 / 12, color: Color(0xff505050)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              ScrollConfiguration(
                behavior: CupertinoScrollBehavior(),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (ctx, index) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      InkWell(
                        child: Container(
                            height: 50,
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Color(0xffF8F8F8),
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                                Flexible(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 300.0,
                                      height: 200.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            )),
                      ),
                      Container(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 300.0,
                            height: 200.0,
                            color: Color(0xffF8F8F8),
                          ),
                        ),
                        height: 50,
                        width: 35,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xff388CFF), width: 0.3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                      )
                    ],
                  ),
                  itemCount: 5,
                  separatorBuilder: (ctx, index) => SizedBox(
                    height: 5,
                  ),
                ),
              ),
            ],
          );
        }
        if (state.getProductListingWithFiltersPaginationModels == null) {
          return SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0),
              child: MyTextWidget(
                LocaleKeys.find_products.tr(),
                style: textTheme.caption?.rq
                    .copyWith(height: 15 / 12, color: Color(0xff505050)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ScrollConfiguration(
              behavior: CupertinoScrollBehavior(),
              child: ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (ctx, index) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    InkWell(
                      onTap: () {
                        HelperFunctions.slidingNavigation(
                            context,
                            ProductDetailsPage(
                              productItem: state
                                  .getProductListingWithFiltersPaginationModels!
                                  .items[index],
                            ));
                      },
                      child: Container(
                          height: 50,
                          width: 1.sw,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Color(0xffF8F8F8),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 35,
                              ),
                              Flexible(
                                child: MyTextWidget(
                                  state
                                      .getProductListingWithFiltersPaginationModels!
                                      .items[index]
                                      .name!,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: context.textTheme.bodyText2?.lq
                                      .copyWith(
                                          height: 15 / 12,
                                          color: Color(0xffC4C2C2)),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                          )),
                    ),
                    Container(
                      height: 50,
                      width: 35,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xff388CFF), width: 0.3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(5),
                          ),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                state
                                    .getProductListingWithFiltersPaginationModels!
                                    .items[index]
                                    .images![0]
                                    .filePath!,
                              ))),
                    )
                  ],
                ),
                itemCount: state
                    .getProductListingWithFiltersPaginationModels!.items.length,
                separatorBuilder: (ctx, index) => SizedBox(
                  height: 5,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
