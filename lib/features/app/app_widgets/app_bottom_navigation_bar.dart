import 'package:adobe_xd/adobe_xd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/features/authentication/presentation/pages/login_page.dart';
import '../../../core/domin/repositories/prefs_repository.dart';
import '../../../core/utils/theme_state.dart';
import '../../../routes/router.dart';
import '../../authentication/presentation/pages/first_registeration_page.dart';
import '../../chat/presentation/manager/chat_bloc.dart';
import '../../chat/presentation/manager/chat_event.dart';
import '../blocs/app_bloc/app_bloc.dart';
import '../blocs/app_bloc/app_event.dart';
import '../blocs/app_bloc/app_state.dart';

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends ThemeState<AppBottomNavBar> {
  late AppBloc appBloc;
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    appBloc = BlocProvider.of<AppBloc>(context);
    super.initState();
  }

  Widget inActiveLogo = SizedBox(
      height: 30,
      width: 50,
      child: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(size: 15.0, middle: 0.7759),
            Pin(size: 1.9, end: 4.3),
            child: SvgPicture.string(
              '<svg viewBox="621.9 468.8 15.0 1.9" ><path transform="translate(623.56, 467.89)" d="M 5.852773666381836 2.810980558395386 C 5.373507976531982 2.810980558395386 4.874990463256836 2.788495540618896 4.371073246002197 2.744148015975952 C 4.267918109893799 2.735065698623657 4.191650390625 2.644083261489868 4.200733184814453 2.54092812538147 C 4.209808349609375 2.43777322769165 4.300786018371582 2.361511707305908 4.403945922851562 2.370588064193726 C 4.896980285644531 2.413983106613159 5.384435653686523 2.435980558395386 5.852773666381836 2.435980558395386 C 6.344360828399658 2.435980558395386 6.85343074798584 2.411808252334595 7.365853309631348 2.364138126373291 C 7.468964576721191 2.35454249382019 7.560320854187012 2.430355787277222 7.569912910461426 2.533465623855591 C 7.579505920410156 2.636568069458008 7.503695487976074 2.727933168411255 7.400593280792236 2.737525701522827 C 6.876672744750977 2.786267995834351 6.355910778045654 2.810980558395386 5.852773666381836 2.810980558395386 Z M 1.42882513999939 2.264083623886108 C 1.414918661117554 2.264083623886108 1.400803565979004 2.262527465820312 1.386673450469971 2.259280443191528 C 0.4645707011222839 2.047450542449951 -0.4848842620849609 1.778980612754822 -1.515939235687256 1.438540458679199 C -1.614264249801636 1.406073093414307 -1.667656660079956 1.30003809928894 -1.635189294815063 1.201705574989319 C -1.602721691131592 1.103373169898987 -1.496686935424805 1.049980401992798 -1.398354291915894 1.08244800567627 C -0.3784667551517487 1.419205546379089 0.5599857568740845 1.684600591659546 1.470628261566162 1.893805623054504 C 1.571555614471436 1.916988134384155 1.634578466415405 2.017600536346436 1.611388444900513 2.118528127670288 C 1.591451644897461 2.205317735671997 1.514240741729736 2.264083623886108 1.42882513999939 2.264083623886108 Z M 10.33655834197998 2.227602958679199 C 10.25249099731445 2.227602958679199 10.17602157592773 2.170664310455322 10.15477275848389 2.085407972335815 C 10.12972354888916 1.984930634498596 10.19087028503418 1.883170485496521 10.29134845733643 1.858128070831299 C 11.24700546264648 1.619905591011047 12.19931888580322 1.314078092575073 13.12184047698975 0.9491281509399414 C 13.21813106536865 0.9110350608825684 13.32707786560059 0.9582184553146362 13.3651704788208 1.054510593414307 C 13.4032621383667 1.150803089141846 13.35608005523682 1.259740591049194 13.25978755950928 1.29783308506012 C 12.32192039489746 1.668850541114807 11.35371589660645 1.979778051376343 10.38205337524414 2.221990585327148 C 10.36683177947998 2.225785255432129 10.35156726837158 2.227602958679199 10.33655834197998 2.227602958679199 Z" fill="#e6e6e6" stroke="none" stroke-width="0.5" stroke-dasharray="4 4" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 7.5, end: 0.0),
            Pin(size: 7.5, end: 4.5),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: SvgPicture.string(
                '<svg viewBox="637.5 463.0 7.5 7.5" ><path transform="translate(637.5, 463.02)" d="M 3.749999523162842 7.5 C 1.678932905197144 7.5 0 5.821067333221436 0 3.75 C 0 1.678933024406433 1.678932905197144 0 3.749999523162842 0 C 5.821067810058594 0 7.499999046325684 1.678933024406433 7.499999046325684 3.75 C 7.499999046325684 5.821067333221436 5.821067810058594 7.5 3.749999523162842 7.5 Z" fill="#e6e6e6" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                allowDrawingOutsideViewBox: true,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 30.0, start: 0.0),
            Pin(start: 0.0, end: 0.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: SvgPicture.string(
                '<svg viewBox="594.0 445.0 30.0 30.0" ><path transform="translate(594.0, 445.0)" d="M 15 0 C 6.715729713439941 0 0 6.715729713439941 0 15 C 0 23.28426742553711 6.715729713439941 30 15 30 C 23.28426742553711 30 30 23.28426742553711 30 15 C 30 6.715729713439941 23.28426742553711 0 15 0 Z" fill="#f53c3c" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                allowDrawingOutsideViewBox: true,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ));
  Widget activeLogo = SizedBox(
    height: 30,
    width: 50,
    child: Stack(
      children: <Widget>[
        Pinned.fromPins(
          Pin(size: 15.0, middle: 0.7759),
          Pin(size: 1.9, end: 4.3),
          child: SvgPicture.string(
            '<svg viewBox="52.9 878.8 15.0 1.9" ><path transform="translate(54.56, 877.89)" d="M 5.852773666381836 2.810980558395386 C 5.373507976531982 2.810980558395386 4.874990463256836 2.788495540618896 4.371073246002197 2.744148015975952 C 4.267918109893799 2.735065698623657 4.191650390625 2.644083261489868 4.200733184814453 2.54092812538147 C 4.209808349609375 2.43777322769165 4.300786018371582 2.361511707305908 4.403945922851562 2.370588064193726 C 4.896980285644531 2.413983106613159 5.384435653686523 2.435980558395386 5.852773666381836 2.435980558395386 C 6.344360828399658 2.435980558395386 6.85343074798584 2.411808252334595 7.365853309631348 2.364138126373291 C 7.468964576721191 2.35454249382019 7.560320854187012 2.430355787277222 7.569912910461426 2.533465623855591 C 7.579505920410156 2.636568069458008 7.503695487976074 2.727933168411255 7.400593280792236 2.737525701522827 C 6.876672744750977 2.786267995834351 6.355910778045654 2.810980558395386 5.852773666381836 2.810980558395386 Z M 1.42882513999939 2.264083623886108 C 1.414918661117554 2.264083623886108 1.400803565979004 2.262527465820312 1.386673450469971 2.259280443191528 C 0.4645707011222839 2.047450542449951 -0.4848842620849609 1.778980612754822 -1.515939235687256 1.438540458679199 C -1.614264249801636 1.406073093414307 -1.667656660079956 1.30003809928894 -1.635189294815063 1.201705574989319 C -1.602721691131592 1.103373169898987 -1.496686935424805 1.049980401992798 -1.398354291915894 1.08244800567627 C -0.3784667551517487 1.419205546379089 0.5599857568740845 1.684600591659546 1.470628261566162 1.893805623054504 C 1.571555614471436 1.916988134384155 1.634578466415405 2.017600536346436 1.611388444900513 2.118528127670288 C 1.591451644897461 2.205317735671997 1.514240741729736 2.264083623886108 1.42882513999939 2.264083623886108 Z M 10.33655834197998 2.227602958679199 C 10.25249099731445 2.227602958679199 10.17602157592773 2.170664310455322 10.15477275848389 2.085407972335815 C 10.12972354888916 1.984930634498596 10.19087028503418 1.883170485496521 10.29134845733643 1.858128070831299 C 11.24700546264648 1.619905591011047 12.19931888580322 1.314078092575073 13.12184047698975 0.9491281509399414 C 13.21813106536865 0.9110350608825684 13.32707786560059 0.9582184553146362 13.3651704788208 1.054510593414307 C 13.4032621383667 1.150803089141846 13.35608005523682 1.259740591049194 13.25978755950928 1.29783308506012 C 12.32192039489746 1.668850541114807 11.35371589660645 1.979778051376343 10.38205337524414 2.221990585327148 C 10.36683177947998 2.225785255432129 10.35156726837158 2.227602958679199 10.33655834197998 2.227602958679199 Z" fill="#000000" stroke="none" stroke-width="0.5" stroke-dasharray="4 4" stroke-miterlimit="4" stroke-linecap="round" /></svg>',
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
        Pinned.fromPins(
          Pin(size: 7.5, end: 0.0),
          Pin(size: 7.5, end: 4.5),
          child: Stack(
            children: [
              SvgPicture.string(
                '<svg viewBox="68.5 873.0 7.5 7.5" ><path transform="translate(68.5, 873.02)" d="M 3.749999523162842 7.5 C 1.678932905197144 7.5 0 5.821067333221436 0 3.75 C 0 1.678933024406433 1.678932905197144 0 3.749999523162842 0 C 5.821067810058594 0 7.499999046325684 1.678933024406433 7.499999046325684 3.75 C 7.499999046325684 5.821067333221436 5.821067810058594 7.5 3.749999523162842 7.5 Z" fill="#000000" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                allowDrawingOutsideViewBox: true,
                fit: BoxFit.fill,
              ),
              // Container(
              //   height: 20,
              //   width: 1.sw,
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         color: const Color(0xffffffff).withOpacity(0.5),
              //       ),
              //       const BoxShadow(
              //         color: Color(0xff000000),
              //         spreadRadius: -4.0,
              //         offset: Offset(0,3),
              //         blurRadius: 4.0,
              //       ),
              //     ],
              //     // gradient: LinearGradient(
              //     //   begin: Alignment(1, 1),
              //     //   end: Alignment(1, -4),
              //     //   colors: [
              //     //     const Color(0x00ffffff),
              //     //     const Color(0x00ffffff).withOpacity(0.6),
              //     //     const Color(0x00ffffff).withOpacity(0.3)
              //     //   ],
              //     //   stops: [0.0, 0.559, 1.0],
              //     // ),
              //     borderRadius: BorderRadius.circular(20.0),
              //   ),
              // ),
            ],
          ),
        ),
        Pinned.fromPins(
          Pin(size: 30.0, start: 0.0),
          Pin(start: 0.0, end: 0.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SvgPicture.string(
                '<svg viewBox="25.0 855.0 30.0 30.0" ><path transform="translate(25.0, 855.0)" d="M 15 0 C 6.715729713439941 0 0 6.715729713439941 0 15 C 0 23.28426742553711 6.715729713439941 30 15 30 C 23.28426742553711 30 30 23.28426742553711 30 15 C 30 6.715729713439941 23.28426742553711 0 15 0 Z" fill="#f53c3c" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                allowDrawingOutsideViewBox: true,
                fit: BoxFit.fill,
              ),
              // Container(
              //   width: 1.sw,
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         color: const Color(0xffffffff).withOpacity(0.5),
              //       ),
              //       const BoxShadow(
              //         color: Color(0xfff53c3c),
              //           blurRadius: 6,
              //           spreadRadius: -4
              //       ),
              //     ],
              //     // gradient: LinearGradient(
              //     //   begin: Alignment(1, 1),
              //     //   end: Alignment(1, -3),
              //     //   colors: [
              //     //     const Color(0x00ffffff),
              //     //     const Color(0x00ffffff).withOpacity(0.6),
              //     //     const Color(0x00ffffff).withOpacity(0.3)
              //     //   ],
              //     //   stops: [0.0, 0.559, 1.0],
              //     // ),
              //     borderRadius: BorderRadius.circular(20.0),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (oldState, newState) =>
          oldState.currentIndex != newState.currentIndex,
      builder: (context, state) {
        return Container(
          width: 1.sw,
          height: 70.h,
          decoration: BoxDecoration(
            color: colorScheme.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 0),
                  color: colorScheme.black.withOpacity(0.1),
                  blurRadius: 6)
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeBasePage(0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 0 ? activeLogo : inActiveLogo,
                      10.verticalSpace,
                      state.currentIndex == 0
                          ? SvgPicture.asset(
                              AppAssets.logoTextActiveSvg,
                              height: 10.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.logoTextInactiveSvg,
                              height: 10.h,
                            ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => appBloc.add(ChangeBasePage(1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 1
                          ? SvgPicture.asset(
                              AppAssets.bagsSvg,
                              height: 30.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.cartSvg,
                              height: 30.h,
                            ),
                      10.verticalSpace,
                      Text(
                        'Cart',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            color: state.currentIndex != 1
                                ? colorScheme.grey200
                                : colorScheme.black,
                            letterSpacing: 0.28),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!prefsRepository.registeredToChat) {
                      context.go(GRouter.config.applicationRoutes.kRegistrationPagePath);
                    }else{
                      appBloc.add(ChangeBasePage(2));
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 2
                          ? SvgPicture.asset(
                              AppAssets.activeChatSvg,
                              height: 30.h,
                            )
                          : SvgPicture.asset(
                              AppAssets.chatSvg,
                              height: 30.h,
                            ),
                      10.verticalSpace,
                      Text(
                        'Chat',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            letterSpacing: 0.28,
                            color: state.currentIndex != 2
                                ? colorScheme.grey200
                                : colorScheme.black),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onLongPress: (){
                    context.go(GRouter.config.applicationRoutes.kFeedBackPagePath);
                  },
                  onTap: () {
                    appBloc.add(ChangeBasePage(0));
                    context.go(GRouter.config.applicationRoutes.kRegistrationPage);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.currentIndex == 3
                          ? Container(
                              height: 30.h,
                              width: 30.h,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(AppAssets.profileJpg),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    width: 1.0, color: const Color(0xfff53c3c)),
                              ),
                            )
                          // Container(
                          //     height: 30.h,
                          //     width: 30.h,
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(15.r),
                          //         border: Border.all(
                          //             color: colorScheme.error, width: 1)),
                          //     child: Image.asset(
                          //       AppAssets.profilePng,
                          //       fit: BoxFit.fitHeight,
                          //     ),
                          //       )
                          : SizedBox(
                              height: 30.h,
                              width: 30.h,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 30.h,
                                    width: 30.h,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(AppAssets.profileJpg),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          offset: Offset(0, 3),
                                          blurRadius: 3,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  // Container(
                                  //   height: 6,
                                  //   width: 1.sw,
                                  //   decoration: BoxDecoration(
                                  //     gradient: LinearGradient(
                                  //       begin: const Alignment(1, 1),
                                  //       end: const Alignment(1, -3),
                                  //       colors: [
                                  //         colorScheme.white,
                                  //         colorScheme.white.withOpacity(0.6),
                                  //       ],
                                  //       stops: const [0.0, 1.0],
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(20.0),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                      10.verticalSpace,
                      Text(
                        'Me',
                        maxLines: 1,
                        style: textTheme.overline?.lr.copyWith(
                            letterSpacing: 0.28,
                            color: state.currentIndex != 3
                                ? colorScheme.grey200
                                : colorScheme.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
