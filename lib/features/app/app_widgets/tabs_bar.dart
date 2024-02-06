import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/my_cached_network_image.dart';
import 'package:trydos/features/app/trydos_shimmer_loading.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';

import '../../../common/constant/design/assets_provider.dart';
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../home/presentation/manager/home_bloc.dart';
import '../../home/presentation/manager/home_state.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';

class TabsBar extends StatefulWidget {
  const TabsBar({Key? key}) : super(key: key);

  @override
  State<TabsBar> createState() => _TabsBarState();
}

class _TabsBarState extends State<TabsBar> {
  late AppBloc appBloc;

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (oldState, newState) =>
            oldState.getMainCategoriesStatus ==
                GetMainCategoriesStatus.loading &&
            newState.getMainCategoriesStatus == GetMainCategoriesStatus.success,
        builder: (context, homeState) {
          if (homeState.mainCategoriesResponseModel == null) {
            return Container(
              width: 1.sw,
              height: 55.h,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: colorScheme.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1a000000),
                    offset: Offset(0, 0),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      5,
                      (index) => TrydosLoader(
                            size: 15.sp,
                          ))),
            );
          }
          return BlocBuilder<AppBloc, AppState>(
            buildWhen: (oldState, newState) =>
                oldState.tabIndex != newState.tabIndex,
            builder: (context, state) {
              return Container(
                width: 1.sw,
                height: 55.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: colorScheme.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1a000000),
                      offset: Offset(0, 0),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(
                          homeState.mainCategoriesResponseModel?.data
                                  ?.mainCategories?.length ??
                              0, (index) {
                    MainCategory mainCategory = homeState
                        .mainCategoriesResponseModel!
                        .data!
                        .mainCategories![index];
                    return Padding(
                      padding: HWEdgeInsets.only(right: 15.0),
                      child: InkWell(
                        onTap: () {
                          appBloc.add(ChangeTab(index));
                          BlocProvider.of<HomeBloc>(context).add(
                              GetHomeSectionsEvent(
                                  mainCategory.slug.toString()));
                        },
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.network(
                              mainCategory.icon.toString(),
                              height: 25.h,
                              color: state.tabIndex == index
                                  ? Colors.black
                                  : Color(0xff0ffC4C2C2),
                            ),
                            4.verticalSpace,
                            Text(
                              mainCategory.name.toString(),
                              maxLines: 1,
                              style: textTheme.overline?.lr.copyWith(
                                  letterSpacing: 0,
                                  color: state.tabIndex != index
                                      ? Color(0xffC4C2C2)
                                      : Color(0xff505050)),
                            ),
                          ],
                        ),
                      ),
                    );
                  })),
                ),
              );
            },
          );
        });
  }
}
