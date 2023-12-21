import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';

import '../../../common/constant/design/assets_provider.dart';
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
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (oldState, newState) =>
      oldState.tabIndex != newState.tabIndex,
      builder: (context, state) {
        return Container(
          width: 1.sw,
          height: 50.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: colorScheme.white,
            boxShadow: const [
              BoxShadow(
                color:  Color(0x1a000000),
                offset: Offset(0, 0),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeTab(0)),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.tabIndex == 0
                          ? SvgPicture.asset(
                        AppAssets.manActiveSvg,
                        height: 25.h,
                      )
                          : SvgPicture.asset(
                        AppAssets.manInactiveSvg,
                        height: 25.h,
                      ),
                      4.verticalSpace,
                      Text(
                        'Man',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                          letterSpacing: 0,
                            color: state.tabIndex != 0
                                ? Color(0xffC4C2C2)
                                : Color(0xff505050)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeTab(1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.tabIndex == 1
                          ? SvgPicture.asset(
                        AppAssets.womenActiveSvg,
                        height: 25.h,
                      )
                          : SvgPicture.asset(
                        AppAssets.womenInactiveSvg,
                        height: 25.h,
                      ),
                      4.verticalSpace,
                      Text(
                        'Women',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            letterSpacing: 0,
                            color: state.tabIndex != 1
                                ? Color(0xffC4C2C2)
                                : Color(0xff505050)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeTab(2)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.tabIndex == 2
                          ? SvgPicture.asset(
                        AppAssets.childrenActiveSvg,
                        height: 25.h,
                      )
                          : SvgPicture.asset(
                        AppAssets.childrenInactiveSvg,
                        height: 25.h,
                      ),
                      4.verticalSpace,
                      Text(
                        'Children',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            letterSpacing: 0,
                            color: state.tabIndex != 2
                                ? Color(0xffC4C2C2)
                                : Color(0xff505050)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeTab(3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.tabIndex == 3
                          ? SvgPicture.asset(
                        AppAssets.homeActiveSvg,
                        height: 25.h,
                      )
                          : SvgPicture.asset(
                        AppAssets.homeInactiveSvg,
                        height: 25.h,
                      ),
                      4.verticalSpace,
                      Text(
                        'Home',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            letterSpacing: 0,
                            color: state.tabIndex != 3
                                ? Color(0xffC4C2C2)
                                : Color(0xff505050)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child:InkWell(
              onTap: () => appBloc.add(ChangeTab(4)),
                 child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  state.tabIndex == 4
                      ? SvgPicture.asset(
                    AppAssets.electronicActiveSvg,
                    height: 25.h,
                  )
                      : SvgPicture.asset(
                    AppAssets.electronicInactiveSvg,
                    height: 25.h,
                  ),
                  4.verticalSpace,
                  Text(
                    'Electronic',
                    maxLines: 1,
                    style: textTheme.overline?.lr.copyWith(
                        letterSpacing: 0,
                        color: state.tabIndex != 4
                            ? Color(0xffC4C2C2)
                            : Color(0xff505050)),
                  ),
                ],
              )))
            ],
          ),
        );
      },
    );
  }
}

