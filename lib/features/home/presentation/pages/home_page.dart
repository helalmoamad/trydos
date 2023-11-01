import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/tabs_bar.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/home/presentation/manager/home_bloc.dart';
import 'package:trydos/features/home/presentation/widgets/home_page_card.dart';
import 'package:trydos/features/home/presentation/widgets/sliver_list_seprated.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../story/presentation/widget/stories_list.dart';
import '../widgets/home_page_card2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppBloc appBloc;
  double? _previousOffset;
  double? _velocity;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    scrollController.addListener(() {
      if (scrollController.position.pixels <= 80) {
        print(scrollController.position.pixels);
        appBloc.add(ShowOrHideBars(true));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      GetIt.I<PrefsRepository>().saveRequestsData(
          null, null, null, null, null, null, null,
          error: error.toString());
    };
    return SafeArea(
        child: Padding(
      padding: HWEdgeInsets.symmetric(horizontal: 0.w),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          final currentOffset = notification.metrics.pixels;
          if (_previousOffset != null) {
            final distance = (currentOffset - _previousOffset!).abs();
            final time =
                notification.dragDetails?.sourceTimeStamp?.inMilliseconds ??
                    0.000001;
            _velocity = distance / time;
            if (scrollController.position.pixels <= 80) {
              _previousOffset = currentOffset;
              return true;
            }
            if (_velocity! <= (1.5e-8) && _velocity! >= (1.42e-8)) {
              appBloc.add(ShowOrHideBars(true));
            } else {
              appBloc.add(ShowOrHideBars(false));
            }
          }
          print(_velocity);
          _previousOffset = currentOffset;
          return true;
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                scrollBehavior: const CupertinoScrollBehavior(),
                slivers: [
                  SliverToBoxAdapter(child: 50.verticalSpace),
                  SliverToBoxAdapter(
                    child: 40.verticalSpace,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                        padding: HWEdgeInsetsDirectional.only(start: 30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.storyFilmSvg,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Story',
                              style: context.textTheme.bodyText2?.rr.copyWith(
                                  height: 0.86, color: Color(0xff3C3C3C)),
                            )
                          ],
                        )),
                  ),
                  SliverToBoxAdapter(
                    child: 20.verticalSpace,
                  ),
                  SliverToBoxAdapter(
                    child: StoriesList(),
                  ),
                  SliverToBoxAdapter(
                    child: 20.verticalSpace,
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (p, c) =>
                        p.getHomeSectionsStatus != c.getHomeSectionsStatus,
                    builder: (context, state) {
                      return sliverListSeparated(
                        itemBuilder: (_, index) => Padding(
                            padding: HWEdgeInsets.symmetric(horizontal: 15.w),
                            child: state.getHomeSectionsStatus ==
                                    GetHomeSectionsStatus.loading
                                ? Shimmer.fromColors(
                                    child: Container(
                                      width: 1.sw,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    baseColor: Colors.grey,
                                    highlightColor:
                                        Color.fromARGB(31, 146, 144, 144))
                                : HomePageCard2()
                            // HomePageCard(showWhite: index % 2 == 0),
                            ),
                        separator: SizedBox(height: 20,),
                        childCount: 8,
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: 20.verticalSpace,
                  ),
                ],
              ),
              BlocBuilder<AppBloc, AppState>(
                  buildWhen: (p, c) => p.showBars != c.showBars,
                  builder: (context, state) {
                    if (state.showBars == true) {
                      return const TabsBar();
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            ],
          ),
        ),
      ),
    ));
  }
}
