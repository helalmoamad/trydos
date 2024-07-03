import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/svg_network_widget.dart';
import 'package:trydos/features/home/data/models/main_categories_response_model.dart';
import 'package:trydos/features/home/presentation/manager/home_event.dart';
import '../../../common/constant/design/assets_provider.dart';
import '../../../common/constant/design/constant_design.dart';
import '../../../common/constant/widgets_key.dart';
import '../../../core/utils/responsive_padding.dart';
import '../../home/presentation/manager/home_bloc.dart';
import '../../home/presentation/manager/home_state.dart';
import '../animated_search_bar/animated_search_bar.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';
import '../my_text_widget.dart';

class TabsBar extends StatefulWidget {
  const TabsBar({
    Key? key,
    required this.buildSearchResult,
    required this.hideTrendingAndHistory,
  }) : super(key: key);
  final ValueNotifier<int> buildSearchResult;
  final ValueNotifier<bool> hideTrendingAndHistory;

  @override
  State<TabsBar> createState() => _TabsBarState();
}

class _TabsBarState extends State<TabsBar> {
  late AppBloc appBloc;
  late HomeBloc homeBloc;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  final FocusNode focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    focusNode.addListener(() {
      if(focusNode.hasFocus){
        widget.hideTrendingAndHistory.value = true;
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (oldState, newState) =>
                oldState.getMainCategoriesStatus ==
                    GetMainCategoriesStatus.loading &&
                newState.getMainCategoriesStatus ==
                    GetMainCategoriesStatus.success,
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
                      key: Key(WidgetsKey.mainCategoriesTabNullKey),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BlocBuilder<AppBloc, AppState>(
                                  buildWhen: (p, c) =>
                                      p.currentIndex != c.currentIndex,
                                  builder: (context, state) {
                                    return AnimatedSearchBar(
                                      width: 1.sw,
                                      height: 40,
                                      onClickClose: () {
                                        appBloc.add(ChangeBasePage(0));
                                        appBloc.add(
                                            HideBottomNavigationBar(false));
                                      },
                                      textController: controller,
                                      focusNode: focusNode,
                                      onSuffixTap: () {
                                        Future.delayed(
                                            Duration(milliseconds: 300), () {
                                          appBloc.add(ChangeBasePage(4));
                                          appBloc.add(
                                              HideBottomNavigationBar(true));
                                        });
                                      },
                                      suffixWidget: Center(
                                        child: SvgPicture.asset(
                                          AppAssets.searchOutlinedSvg,
                                          height: 20,
                                          width: 20,
                                          color: Color(0xff388CFF),
                                        ),
                                      ),
                                      prefixWidget: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15, top: 10, bottom: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.realCameraSvg,
                                              height: 20,
                                              width: 20,
                                            ),
                                            SvgPicture.asset(
                                              AppAssets.microphoneSvg,
                                              height: 20,
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      animationDurationInMilli: 400,
                                      searchDecoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: focusNode.hasFocus
                                                  ? Color(0xffE6E6E6)
                                                  : Color(0xffF8F8F8),
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: context.colorScheme.error,
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: context.colorScheme.error,
                                              width: 0.4),
                                          borderRadius: BorderRadius.circular(
                                              kbrBorderTextField),
                                        ),
                                        filled: true,
                                        fillColor: focusNode.hasFocus
                                            ? colorScheme.white
                                            : Color(0xffF8F8F8),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: SvgPicture.asset(
                                            AppAssets.searchOutlinedSvg,
                                            height: 20,
                                            width: 20,
                                            color: Color(0xff388CFF),
                                          ),
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 10, bottom: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.realCameraSvg,
                                                height: 20,
                                                width: 20,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              SvgPicture.asset(
                                                AppAssets.microphoneSvg,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        //context.colorScheme.white,
                                        contentPadding:
                                            HWEdgeInsetsDirectional.only(
                                                start: 20,
                                                end: 10,
                                                bottom: 12,
                                                top: 12),
                                        hintText: 'Search',
                                        hintStyle: context
                                            .textTheme.subtitle1?.lq
                                            .copyWith(color: Color(0xffC4C2C2)),
                                        labelStyle: context.textTheme.bodyText2
                                            ?.copyWith(
                                                color:
                                                    context.colorScheme.hint),
                                      ),
                                      onChanged: (String text) {
                                        widget.buildSearchResult.value =
                                            text.length;
                                      }, hideTrendingAndHistory: widget.hideTrendingAndHistory,
                                    );
                                  },
                                ),
                                BlocBuilder<AppBloc, AppState>(
                                  buildWhen: (p, c) =>
                                      p.currentIndex != c.currentIndex,
                                  builder: (context, state) {
                                    if (state.currentIndex != 4) {
                                      return SizedBox(
                                        width: 1.sw - 50,
                                        child: Row(
                                            key: Key(WidgetsKey.mainCategoriesTabKey),
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              (homeState
                                                      .mainCategoriesResponseModel
                                                      ?.data
                                                      ?.mainCategories
                                                      ?.length ??
                                                  0),
                                              (index) {
                                                MainCategory mainCategory = homeState
                                                    .mainCategoriesResponseModel!
                                                    .data!
                                                    .mainCategories![index];
                                                return Padding(
                                                    padding: HWEdgeInsetsDirectional.only(
                                                        end: 15.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        /* appBloc.add(ChangeTab(index));
                                                          BlocProvider.of<HomeBloc>(context).add(
                                                                        GetHomeSectionsEvent(
                                                                            mainCategory.slug.toString()));*/
                                                        appBloc.add(
                                                            ChangeTab(index));
                                                        homeBloc.add(GetHomeBoutiqesEvent(
                                                            getWithPagination:
                                                                false,
                                                            offset: "1",
                                                            categorySlug: homeState
                                                                .mainCategoriesResponseModel!
                                                                .data!
                                                                .mainCategories![
                                                                    index]
                                                                .slug!));
                                                        /*   homeBloc.add(
                                                  GetProductsWithoutFiltersEvent(
                                                      offset: 1,
                                                      category: homeState
                                                          .mainCategoriesResponseModel!
                                                          .data!
                                                          .mainCategories![index]
                                                          .slug!,
                                                      selectedProssesType:
                                                          'category'));*/
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgNetworkWidget(
                                                            svgUrl: mainCategory
                                                                .icon
                                                                .toString(),
                                                            height: 20,
                                                            color: state.tabIndex ==
                                                                    index
                                                                ? Colors.black
                                                                : Color(
                                                                    0xffC4C2C2),
                                                          ),
                                                          4.verticalSpace,
                                                          MyTextWidget(
                                                            mainCategory.name
                                                                .toString(),
                                                            maxLines: 1,
                                                            style: textTheme
                                                                .overline?.lr
                                                                .copyWith(
                                                                    letterSpacing:
                                                                        0,
                                                                    color: state.tabIndex !=
                                                                            index
                                                                        ? Color(
                                                                            0xffC4C2C2)
                                                                        : Color(
                                                                            0xff505050)),
                                                          ),
                                                        ],
                                                      ),
                                                    ));
                                              },
                                            )),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                )
                              ]),
                        ));
                  });
            }));
  }
}
