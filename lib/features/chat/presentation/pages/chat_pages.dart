import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/form_state_mixin.dart';
import 'package:trydos/core/utils/form_utils.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_bloc.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_event.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/presentation/pages/calls_page_content.dart';
import 'package:trydos/features/chat/presentation/pages/chat_page_content.dart';
class ChatPages extends StatefulWidget {
  const ChatPages({Key? key}) : super(key: key);

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends ThemeState<ChatPages> with FormStateMinxin {
  final ScrollController scrollController = ScrollController();

  List<Widget> chatPages=[
    const ChatPageContent(),
    const CallsPageContent(),
    const CallsPageContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          scrollBehavior: const CupertinoScrollBehavior(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: 1.sw,
                height: 50,
                color: colorScheme.white,
                padding:
                HWEdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                child: AppTextField(
                  controller: form.controllers[0],
                  filledColor: colorScheme.grey50,
                  bordersColor: colorScheme.grey50,
                  hintText: 'Search, Chat, Contact, Start New Chat',
                  hintTextStyle: textTheme.subtitle2?.lr
                      .copyWith(color: const Color(0xffD3D3D3)),

                  contentPadding:
                  HWEdgeInsetsDirectional.fromSTEB(20.w, 10, 20.w, 10),
                  prefixIcon: Padding(
                    padding:
                    HWEdgeInsetsDirectional.only(top: 10, bottom: 10),
                    child: SvgPicture.asset(
                      AppAssets.searchSvg,
                      height: 20,
                      width: 20.h,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
                  padding: HWEdgeInsets.symmetric(horizontal: 40.w),
                  height: 50,
                  width: 1.sw,
                  decoration: const BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1a000000),
                        offset: Offset(0, 0),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChatTabItem(
                            iconUrl: AppAssets.singleChatOutlinedActiveSvg,
                            activeIconUrl: AppAssets.singleChatSvg,
                            index: 0,
                            notificationCount: '9'),
                        ChatTabItem(
                            iconUrl: AppAssets.callsOutlinedActiveSvg,
                            activeIconUrl: AppAssets.callsSvg,
                            index: 1,
                            notificationCount: '9'),
                        ChatTabItem(
                            iconUrl: AppAssets.storyOutlinedSvg,
                            activeIconUrl: AppAssets.storyFilledSvg,
                            index: 2,
                            notificationCount: '9'),
                      ],
                    ),
                  ),
                )),
            BlocBuilder<AppBloc,AppState>(
              buildWhen: (p,c)=> p.tabIndexInChat!=c.tabIndexInChat,
              builder: (context , state) {
                return chatPages[state.tabIndexInChat];
              }
            ),
            SliverToBoxAdapter(
              child: 20.verticalSpace,
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}

class ChatTabItem extends StatelessWidget {
  const ChatTabItem({Key? key,
    required this.iconUrl,
    required this.index,
    required this.activeIconUrl,
    required this.notificationCount})
      : super(key: key);
  final String iconUrl;
  final String activeIconUrl;
  final String notificationCount;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    return InkWell(
      onTap: () => appBloc.add(ChangeTabInChat(index)),
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => p.tabIndexInChat != c.tabIndexInChat,
        builder: (context, state) {
          return SizedBox(
            width: 50.w,
            height: 28,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    state.tabIndexInChat != index ? iconUrl : activeIconUrl,
                    height: 25.w,
                    width: 25.w,
                  ),
                ),
                state.tabIndexInChat != index ? Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.chatNotificationSvg,
                        height: 12.h,
                        width: 12.h,
                      ),
                      4.horizontalSpace,
                      Text(
                        notificationCount,
                        maxLines: 1,
                        style: context.textTheme.caption?.rr
                            .copyWith(color: const Color(0xff007CFF)),
                      ),
                    ],
                  ),
                ) : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}
