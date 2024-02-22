import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/helper/helper_functions.dart';
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
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/calls_page_content.dart';
import 'package:trydos/features/chat/presentation/pages/chat_page_content.dart';
import 'package:trydos/features/chat/presentation/pages/story_page_content.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../app/app_widgets/loading_indicator/trydos_loader.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/my_text_widget.dart';
import '../../../calls/presentation/pages/in_app_view.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';
import 'contacts_page.dart';

class ChatPages extends StatefulWidget {
  const ChatPages({Key? key,
    this.hideCallsAndStories = false,
    required this.description,
    this.onSendForwardMessage})
      : super(key: key);
  final bool hideCallsAndStories;
  final Function(int receiverId, String channelId)? onSendForwardMessage;
  final String description;

  @override
  State<ChatPages> createState() => _ChatPagesState();
}

class _ChatPagesState extends ThemeState<ChatPages> with FormStateMinxin {
  late CallsBloc callsBloc;
  final ScrollController scrollController = ScrollController();
  late ChatBloc chatBloc;

  List<Widget> chatPages = [
    const CallsPageContent(),
    const CallsPageContent(),
  ];

  void saveUserContacts() async {
    // await
    // [
    //   Permission.accessMediaLocation,Permission.mediaLibrary,
    //   Permission.bluetooth,Permission.camera, Permission.microphone]
    //     .request();
    List<Map<String, dynamic>> contacts =
    await HelperFunctions.getContactsFromDevice();
    //todo debug
//    Fluttertoast.showToast(msg: contacts.toString(),toastLength: Toast.LENGTH_LONG);
    chatBloc.add(SaveContactsEvent(contacts: contacts));
  }

  @override
  void initState() {
    callsBloc = BlocProvider.of<CallsBloc>(context);

    callsBloc.add(GetMyCallsEvent());
    chatPages.insert(
      0,
      ChatPageContent(onSendForwardMessage: widget.onSendForwardMessage),
    );
    if (widget.hideCallsAndStories) {
      BlocProvider.of<AppBloc>(context).add(ChangeTabInChat(0));
    }
    saveUserContacts();

    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      debugPrint("asfsd${details.toString()}");
      GetIt.I<PrefsRepository>().saveRequestsData(
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          error: details.toString());
    };
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<AppBloc>(context).add(ChangeBasePage(0));
        return false;
      },
      child: BlocListener<CallsBloc, CallsState>(
        listenWhen: (p, c) =>
        p.makeCallStatus != c.makeCallStatus &&
            c.makeCallStatus == MakeCallStatus.loading,
        listener: (context, state) {
          callInProgressDialog(context);
        },
        child: BlocListener<CallsBloc, CallsState>(
          listenWhen: (p, c) =>
          p.makeCallStatus != c.makeCallStatus &&
              c.makeCallStatus == MakeCallStatus.failure,
          listener: (context, state) {
            Navigator.pop(context);
            showMessage('${state.receiverCallName ?? 'User'} in another call',
                showInRelease: true);
          },
          child: BlocListener<CallsBloc, CallsState>(
            listenWhen: (p, c) =>
            p.makeCallStatus != c.makeCallStatus &&
                c.makeCallStatus == MakeCallStatus.startCall,
            listener: (context, state) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) =>
                      AgoraInAppWebView(
                        type: state.isVideoCall ? 'video' : 'voice',
                        isReceivingCall: false,
                        channelId: state.channelIdForCurrentCall!,
                        auth_token: GetIt
                            .I<PrefsRepository>()
                            .chatToken!,
                        uId: GetIt
                            .I<PrefsRepository>()
                            .myChatId
                            .toString(),
                        action: 'sent',
                        messageId: state.messageId!,
                      )));
            },
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context
                      .go(GRouter.config.applicationRoutes.kMyContactsPagePath);
                },
                backgroundColor: const Color(0xff388cff),
                child: Center(
                    child: Icon(Icons.message_rounded,
                        size: 25.sp, color: colorScheme.white)),
              ),
              backgroundColor: const Color(0xffF8F8F8),
              appBar: widget.hideCallsAndStories
                  ? TrydosAppBar(
                appBarParams: AppBarParams(
                    dividerBottom: false,
                    hasLeading: false,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    child: SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              GoRouter.of(context).pop();
                            },
                            child: Padding(
                              padding: HWEdgeInsetsDirectional.fromSTEB(
                                  20.w, 15, 0, 15),
                              child: SvgPicture.asset(
                                AppAssets.backFromCallSvg,
                                width: 8.w,
                                color: const Color(0xff388CFF),
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          MyTextWidget(
                            widget.description,
                            style: textTheme.subtitle1?.rr
                                .copyWith(color: const Color(0xff388CFF)),
                          ),
                        ],
                      ),
                    )),
              )
                  : null,
              body: SafeArea(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  scrollBehavior: const CupertinoScrollBehavior(),
                  slivers: [
                    //todo search bar
                    SliverToBoxAdapter(
                      child: Container(
                        width: 1.sw,
                        height: 50,
                        color: colorScheme.white,
                        padding: HWEdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5),
                        child: AppTextField(
                          controller: form.controllers[0],
                          filledColor: colorScheme.grey50,
                          bordersColor: colorScheme.grey50,
                          hintText: 'Search, Chat, Contact, Start New Chat',
                          hintTextStyle: textTheme.subtitle2?.lr
                              .copyWith(color: const Color(0xffD3D3D3)),
                          onChange: ChatPageContentState.searchInChats,
                          contentPadding: HWEdgeInsetsDirectional.fromSTEB(
                              20.w, 10, 20.w, 10),
                          prefixIcon: Padding(
                            padding: HWEdgeInsetsDirectional.only(
                                top: 10, bottom: 10),
                            child: SvgPicture.asset(
                              AppAssets.searchSvg,
                              height: 20,
                              width: 20.h,
                            ),
                          ),
                        ),
                      ),
                    ),
//todo appNavigationBar
                    if (!widget.hideCallsAndStories) ...{
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  BlocBuilder<ChatBloc, ChatState>(
                                    buildWhen: (p, c) =>
                                    p.unReadMessagesFromAllChats !=
                                        c.unReadMessagesFromAllChats,
                                    builder: (context, state) {
                                      return ChatTabItem(
                                          iconUrl:
                                          AppAssets.singleChatOutlinedActiveSvg,
                                          activeIconUrl: AppAssets
                                              .singleChatSvg,
                                          index: 0,
                                          notificationCount:
                                          state.unReadMessagesFromAllChats);
                                    },
                                  ),
                                  ChatTabItem(
                                      iconUrl: AppAssets.callsOutlinedActiveSvg,
                                      activeIconUrl: AppAssets.callsSvg,
                                      index: 1,
                                      notificationCount: 9),
                                  ChatTabItem(
                                      iconUrl: AppAssets.storyOutlinedSvg,
                                      activeIconUrl: AppAssets.storyFilledSvg,
                                      index: 2,
                                      notificationCount: 9),
                                ],
                              ),
                            ),
                          )),
                    },
                    BlocBuilder<AppBloc, AppState>(
                        buildWhen: (p, c) =>
                        p.tabIndexInChat != c.tabIndexInChat,
                        builder: (context, state) {
                          return chatPages[state.tabIndexInChat];
                        }),

                    SliverToBoxAdapter(
                      child: 20.verticalSpace,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
  final int notificationCount;
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
                state.tabIndexInChat != index
                    ? Visibility(
                  visible: notificationCount != 0,
                  child: Positioned(
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
                        MyTextWidget(
                          notificationCount.toString(),
                          maxLines: 1,
                          style: context.textTheme.caption?.rr
                              .copyWith(color: const Color(0xff007CFF)),
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}
