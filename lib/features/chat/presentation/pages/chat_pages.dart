import 'dart:async';

import 'package:trydos/features/chat/presentation/widgets/chat_v2/new_chat_sheet_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/contact_card.dart';
import 'package:trydos/features/chat/presentation/widgets/invite_options_sheet.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';

import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_list_header_v2.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/constant.dart';
import 'package:trydos/common/test_utils/test_var.dart';
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
import 'package:trydos/features/chat/presentation/pages/stories_page_content.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_bloc.dart';
import 'package:trydos/features/home/presentation/manager/BoutiqueBloc/boutique_event.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_events.dart';
import 'package:trydos/service/firebase_analytics_service/analytics_const/analytics_screens.dart';
import 'package:trydos/service/firebase_analytics_service/firebase_analytics_service.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/my_text_widget.dart';
import '../../../calls/presentation/pages/in_app_view.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';
import '../widgets/archived_section.dart';
import '../widgets/reminders_section.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/helper/dev_log.dart';
import 'package:trydos/features/app/app_widgets/nav_v2/nav_bar_design.dart';

class ChatPages extends StatefulWidget {
  const ChatPages({
    Key? key,
    this.hideCallsAndStories = false,
    required this.description,
    this.onSendForwardMessage,
  }) : super(key: key);
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
  Timer? debounce;

  /// هل قائمة التذكيرات مفتوحة؟ حين تُفتح تحلّ محلّ قائمة المحادثات.
  ///
  /// `ValueNotifier` لا `setState`: التبديل يمسّ سليفرين فقط، وإعادة بناء
  /// الصفحة كاملة تعيد بناء قائمة المحادثات بلا سبب.
  final ValueNotifier<bool> _remindersOpen = ValueNotifier(false);

  /// وكذلك قائمة المؤرشفة. واحدة مفتوحة فقط — كلتاهما تستبدل قائمة المحادثات،
  /// ففتحهما معاً يعني قائمتين فوق بعضهما.
  final ValueNotifier<bool> _archivedOpen = ValueNotifier(false);

  void _openReminders(bool open) {
    if (open) _archivedOpen.value = false;
    _remindersOpen.value = open;
  }

  void _openArchived(bool open) {
    if (open) _remindersOpen.value = false;
    _archivedOpen.value = open;
  }

  List<Widget> chatPages = [
    const CallsPageContent(),
    const StoriesForChatPageContent(),
  ];

  void saveUserContacts() async {
    // await
    // [
    //   Permission.accessMediaLocation,Permission.mediaLibrary,
    //   Permission.bluetooth,Permission.camera, Permission.microphone]
    //     .request();
    //todo debug
    //    Fluttertoast.showToast(msg: contacts.toString(),toastLength: Toast.LENGTH_LONG);
    chatBloc.add(const SaveContactsEvent());
  }

  @override
  void initState() {
    LastPagesTracker.push('ChatPages');
    scrollController.addListener(_getChatsPaginationListener);
    chatBloc = BlocProvider.of<ChatBloc>(context);
    callsBloc = BlocProvider.of<CallsBloc>(context);

    callsBloc.add(GetMissedCallCountEvent());
    callsBloc.add(GetMyCallsEvent());
    devLog("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH!2");
    chatBloc.add(const GetChatsEvent(limit: 10));
    chatBloc.add(const SaveContactsEvent());
    // التذكيرات تُحفظ مع الحالة فتظهر فوراً، وهذا الطلب يصالحها مع الخادم
    // (ما حان وقته يختفي، وما ضُبط من جهاز آخر يظهر).
    chatBloc.add(const GetMyRemindersEvent());
    chatPages.insert(
      0,
      ChatPageContent(onSendForwardMessage: widget.onSendForwardMessage),
    );

    if (widget.hideCallsAndStories) {
      BlocProvider.of<AppBloc>(context).add(ChangeTabInChat(0));
    }
    saveUserContacts();
    _requestCallKitPermission();
    super.initState();
  }

  @override
  void dispose() {
    _remindersOpen.dispose();
    _archivedOpen.dispose();
    super.dispose();
  }

  Future<void> _requestCallKitPermission() async {
    // 1. طلب إذن الإشعارات العادي
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "نحتاج لإذن الإشعارات لتنبيهك بالمكالمات الواردة",
      "postNotificationMessagePermission":
          "سوف نرسل لك إشعارات عند وجود مكالمة",
    });

    // 2. طلب إذن الظهور فوق التطبيقات (Overlay) - ضروري جداً لـ Redmi و Infinix
    /*if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }*/

    //await prefs.setCallkitPermissionRequested(true);
  }

  bool _eventLogged = false;
  @override
  void didChangeDependencies() {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        executedEventName: GlobalScreenConst.CHAT_SCREEN,
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        extraParams: {
          'screen_name': GlobalScreenConst.CHAT_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  void _getChatsPaginationListener() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 600), () {
      if ((scrollController.offset >=
              scrollController.position.maxScrollExtent * 0.7) &&
          BlocProvider.of<AppBloc>(context).state.tabIndexInChat == 0) {
        chatBloc.add(const GetChatsEvent(limit: 10, getWithPagination: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        BlocProvider.of<AppBloc>(context).add(ChangeBasePage(0));
        BlocProvider.of<BoutiqueBloc>(
          context,
        ).add(ResetAllSelectedAppliedFilterEvent());
        return false;
      },
      child: BlocListener<CallsBloc, CallsState>(
        listenWhen: (p, c) =>
            p.makeCallStatus != c.makeCallStatus &&
            p.makeCallStatus == MakeCallStatus.init &&
            c.makeCallStatus == MakeCallStatus.loading,
        listener: (context, state) {
          devLog(
            "GGGGGGFFFFFFFFFFFFFDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQ////",
          );
          callInProgressDialog(context);
        },
        child: BlocListener<CallsBloc, CallsState>(
          listenWhen: (p, c) =>
              p.makeCallStatus != c.makeCallStatus &&
              c.makeCallStatus == MakeCallStatus.failure,
          listener: (context, state) {
            Navigator.pop(context);
            showWarningMessage(
              context,
              '${state.receiverCallName ?? LocaleKeys.user.tr()} ${LocaleKeys.in_another_call.tr()}',
            );
          },
          child: BlocListener<CallsBloc, CallsState>(
            listenWhen: (p, c) =>
                p.makeCallStatus != c.makeCallStatus &&
                c.makeCallStatus == MakeCallStatus.startCall,
            listener: (context, state) {
              devLog(
                "GGGGGGFFFFFFFFFFFFFDDDDDDDDDDDDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSQ",
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AgoraInAppWebView(
                    type: state.isVideoCall ? 'video' : 'voice',
                    isReceivingCall: false,
                    isPrivate: false,
                    channelId: state.channelIdForCurrentCall!,
                    auth_token: GetIt.I<PrefsRepository>().chatToken!,
                    uId: GetIt.I<PrefsRepository>().myChatId.toString(),
                    action: 'sent',
                    messageId: state.messageId!,
                  ),
                ),
              );
            },
            child: Scaffold(
              // الزرّ الدائري الذي يبدأ محادثة.
              //
              // > 52 بكسلاً، على بعد 20 من الحافّة اليمنى و16 فوق شريط
              // > التبويبات. وعلى تبويب المحادثات وحده.
              //
              // وهو في الملف يفتح **نافذة «محادثة جديدة»** لا صفحةً أخرى؛
              // والانتقال القديم إلى صفحة جهات الاتصال معلَّقٌ أدناه.
              floatingActionButton: kChatDesignV2
                  ? _newChatButton()
                  : FloatingActionButton(
                      key: TestVariables.kTestMode
                          ? const Key(WidgetsKeys.myContactsFloatingActionKey)
                          : null,
                      onPressed: () {
                        context.go(
                          GRouter.config.applicationRoutes.kMyContactsPagePath,
                        );
                      },
                      backgroundColor: const Color(0xff388cff),
                      child: Center(
                        child: Icon(
                          Icons.message_rounded,
                          size: 25.sp,
                          color: colorScheme.white,
                        ),
                      ),
                    ),
              backgroundColor: const Color(0xffF8F8F8),
              appBar: widget.hideCallsAndStories
                  ? TrydosAppBar(
                      appBarParams: AppBarParams(
                        hasLeading: false,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        child: SafeArea(
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  GoRouter.of(context).pop();
                                },
                                child: Padding(
                                  padding: HWEdgeInsetsDirectional.fromSTEB(
                                    20.w,
                                    15,
                                    0,
                                    15,
                                  ),
                                  child: SvgPicture.asset(
                                    AppAssets.backFromCallSvg,
                                    width: 8.w,
                                    // ignore: deprecated_member_use
                                    color: const Color(0xff388CFF),
                                  ),
                                ),
                              ),
                              10.horizontalSpace,
                              MyTextWidget(
                                widget.description,
                                style: textTheme.bodyMedium?.rq.copyWith(
                                  color: const Color(0xff388CFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
              body: SafeArea(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  scrollBehavior: const CupertinoScrollBehavior(),
                  slivers: [
                    // الترويسة بالتصميم الجديد: حقل البحث وشريط التبويبين
                    // في ودجت واحدة — [ChatListHeaderV2]. والقديمة معلَّقة
                    // أدناه بين `if (!kChatDesignV2)`.
                    if (kChatDesignV2)
                      SliverToBoxAdapter(
                        child: BlocBuilder<AppBloc, AppState>(
                          buildWhen: (p, c) =>
                              p.tabIndexInChat != c.tabIndexInChat,
                          builder: (context, app) {
                            return BlocBuilder<ChatBloc, ChatState>(
                              buildWhen: (p, c) =>
                                  p.unReadMessagesFromAllChats !=
                                  c.unReadMessagesFromAllChats,
                              builder: (context, chat) {
                                return BlocBuilder<CallsBloc, CallsState>(
                                  buildWhen: (p, c) =>
                                      p.missedCallCount != c.missedCallCount,
                                  builder: (context, calls) {
                                    return ChatListHeaderV2(
                                      controller: form.controllers[0],
                                      hint: LocaleKeys
                                          .search_chat_contact_startNewChat
                                          .tr(),
                                      onQueryChanged:
                                          ChatPageContentState.searchInChats,
                                      tab: app.tabIndexInChat == 1
                                          ? ChatListTabV2.calls
                                          : ChatListTabV2.chats,
                                      onTab: (t) =>
                                          BlocProvider.of<AppBloc>(context).add(
                                            ChangeTabInChat(
                                              t == ChatListTabV2.calls ? 1 : 0,
                                            ),
                                          ),
                                      chatsLabel: LocaleKeys.chats_tab.tr(),
                                      callsLabel: LocaleKeys.calls_tab.tr(),
                                      chatsCount:
                                          '${chat.unReadMessagesFromAllChats}',
                                      callsCount: '${calls.missedCallCount}',
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    //todo search bar
                    if (!kChatDesignV2)
                      SliverToBoxAdapter(
                        child: Container(
                          width: 1.sw,
                          height: 50,
                          color: colorScheme.white,
                          padding: HWEdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5,
                          ),
                          child: AppTextField(
                            controller: form.controllers[0],
                            filledColor: colorScheme.grey50,
                            bordersColor: colorScheme.grey50,
                            hintText: LocaleKeys
                                .search_chat_contact_startNewChat
                                .tr(),
                            hintTextStyle: textTheme.bodySmall?.lq.copyWith(
                              color: const Color(0xffD3D3D3),
                            ),
                            onChange: ChatPageContentState.searchInChats,
                            contentPadding: HWEdgeInsetsDirectional.fromSTEB(
                              20.w,
                              10,
                              20.w,
                              10,
                            ),
                            prefixIcon: Padding(
                              padding: HWEdgeInsetsDirectional.only(
                                top: 10,
                                bottom: 10,
                              ),
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
                    //
                    // شريط التبويبات القديم — الثلاثة بأيقوناتها. وفي التصميم
                    // الجديد صار جزءاً من [ChatListHeaderV2] أعلاه، وتبويباته
                    // **اثنان** كما في الملف: محادثات ومكالمات.
                    //
                    // وتبويب **الستوري** ليس في التصميم الجديد. ويبقى محتواه
                    // (`StoriesForChatPageContent`، آخر `chatPages`) سليماً
                    // ليُعاد بسطرٍ واحد متى عاد إلى التصميم.
                    if (!kChatDesignV2 && !widget.hideCallsAndStories) ...{
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
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BlocBuilder<ChatBloc, ChatState>(
                                  buildWhen: (p, c) =>
                                      p.unReadMessagesFromAllChats !=
                                      c.unReadMessagesFromAllChats,
                                  builder: (context, state) {
                                    return ChatTabItem(
                                      iconUrl:
                                          AppAssets.singleChatOutlinedActiveSvg,
                                      activeIconUrl: AppAssets.singleChatSvg,
                                      index: 0,
                                      notificationCount:
                                          state.unReadMessagesFromAllChats,
                                    );
                                  },
                                ),
                                BlocBuilder<CallsBloc, CallsState>(
                                  buildWhen: (p, c) =>
                                      p.missedCallCount != c.missedCallCount,
                                  builder: (context, state) {
                                    return ChatTabItem(
                                      iconUrl: AppAssets.callsOutlinedActiveSvg,
                                      activeIconUrl: AppAssets.callsSvg,
                                      index: 1,
                                      notificationCount: state.missedCallCount,
                                    );
                                  },
                                ),
                                ChatTabItem(
                                  iconUrl: AppAssets.storyOutlinedSvg,
                                  activeIconUrl: AppAssets.storyFilledSvg,
                                  index: 2,
                                  notificationCount: 9,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    },
                    // صفّ الأرشيف وحده فوق القائمة، ويختفي حين لا مؤرشفة.
                    //
                    // وصفُّ **التذكيرات** ليس في التصميم الجديد: الملف يجعل
                    // التذكير نافذةً داخل المحادثة (`ReminderSheet.tsx`) لا
                    // صفّاً في القائمة. ومنطقُه ومحتواه (`RemindersListSliver`
                    // و`_remindersOpen`) باقيان سليمين ليُعاد بسطرٍ واحد.
                    if (!kChatDesignV2)
                      RemindersHeaderSliver(
                        isOpen: _remindersOpen,
                        onToggle: _openReminders,
                      ),
                    ArchivedHeaderSliver(
                      isOpen: _archivedOpen,
                      onToggle: _openArchived,
                    ),
                    // كلتا القائمتين **تحلّ محلّ** المحادثات لا تتمدّد فوقها:
                    // صفحة بذاتها، والرجوع بالضغط على الصفّ نفسه.
                    ValueListenableBuilder<bool>(
                      valueListenable: _remindersOpen,
                      builder: (context, remindersOpen, _) {
                        if (remindersOpen) return const RemindersListSliver();
                        return ValueListenableBuilder<bool>(
                          valueListenable: _archivedOpen,
                          builder: (context, archivedOpen, _) {
                            if (archivedOpen) {
                              return ArchivedListSliver(
                                onSendForwardMessage:
                                    widget.onSendForwardMessage,
                              );
                            }
                            return BlocBuilder<AppBloc, AppState>(
                              buildWhen: (p, c) =>
                                  p.tabIndexInChat != c.tabIndexInChat,
                              builder: (context, state) {
                                return chatPages[state.tabIndexInChat];
                              },
                            );
                          },
                        );
                      },
                    ),

                    SliverToBoxAdapter(child: 20.verticalSpace),
                    // غرفة الشريط السفليّ: الصفحة تمتدّ تحته (extendBody).
                    const SliverNavTabRoom(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// الزرّ الدائري الذي يبدأ محادثة — `Home Page – 41`.
  ///
  /// > 52 بكسلاً بنصف قطر 26، بنفسجيّ بظلٍّ `0 4 12` من البنفسجي 35٪،
  /// > وفيه علامةُ زائد 26 بيضاء. على بعد 20 من الحافّة اليمنى، و16 فوق
  /// > شريط التبويبات.
  ///
  /// وهو يفتح نافذة «محادثة جديدة» ([NewChatSheetV2]) كما في الملف.
  Widget _newChatButton() {
    return Padding(
      // `FloatingActionButton` يبعد 16 عن الحافّة افتراضاً، والملف 20.
      padding: EdgeInsets.only(
        right: (ChatListDesign.fabRight - 16).w,
        // 16 فوق **أعلى** الشريط السفليّ، لا فوق أسفل الشاشة.
        //
        // الجسم يمتدّ تحت الشريط (`extendBody`)، فالزرّ بغير هذا يقع تحته.
        // و[navTabRoom] هي غرفةُ الشريط (58 + 15 + الحافّة الآمنة)، ومنها
        // يُطرح هامشُ `FloatingActionButton` الافتراضيّ كي لا يُحسب مرّتين.
        bottom: kNavDesignV2
            ? navTabRoom(context) +
                  ChatListDesign.fabAboveBar.h -
                  kFloatingActionButtonMargin
            : ChatListDesign.fabAboveBar.h,
      ),
      child: SizedBox(
        width: ChatListDesign.fabSize.w,
        height: ChatListDesign.fabSize.w,
        child: FloatingActionButton(
          key: TestVariables.kTestMode
              ? const Key(WidgetsKeys.myContactsFloatingActionKey)
              : null,
          onPressed: _openNewChatSheet,
          backgroundColor: ChatListDesign.purple,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add_rounded,
            size: 26.sp,
            color: ChatListDesign.white,
          ),
        ),
      ),
    );
  }

  /// يفتح نافذة «محادثة جديدة» بجهات الاتصال التي في الحالة.
  ///
  /// **لا تُنشئ قناةً جديدة**: اختيارُ جهةٍ يفتح محادثتها القائمة عبر
  /// [openChatWithContact] — وهو المسار نفسه الذي تسلكه صفحة جهات الاتصال.
  /// وجهةٌ بلا قناةٍ بعد لا يفعل اختيارُها شيئاً، كما كان قبل التصميم الجديد.
  void _openNewChatSheet() {
    NewChatSheetV2.show(
      context,
      // تستمع للبلوك: إضافةُ جهةٍ أو سحبةُ تحديثٍ تُعيد بناء القائمة والنافذة
      // مفتوحة، بدل أن تبقى على لقطة اللحظة التي فُتحت فيها.
      sheet: BlocBuilder<ChatBloc, ChatState>(
        bloc: chatBloc,
        buildWhen: (p, c) =>
            p.contacts != c.contacts ||
            p.saveContactsStatus != c.saveContactsStatus ||
            p.getContactsStatus != c.getContactsStatus,
        builder: (context, state) => _newChatSheet(state.contacts),
      ),
    );
  }

  NewChatSheetV2 _newChatSheet(List<Contact> contacts) {
    return NewChatSheetV2(
      contacts: [
        for (final Contact c in contacts)
          (
            id: '${c.contactUserId ?? c.id}',
            name: c.name ?? LocaleKeys.uk.tr(),
            phone: c.mobilePhone ?? '',
            initials: HelperFunctions.getTheFirstTwoLettersOfName(
              c.name ?? LocaleKeys.uk.tr(),
            ),
            photo: null,
            // جهةٌ بلا `contactUserId` لا تملك التطبيق — وهو الشرط نفسه
            // الذي تستعمله صفحة جهات الاتصال لإظهار زرّ الدعوة.
            hasApp: c.contactUserId != null,
          ),
      ],
      onPick: (id) {
        Navigator.pop(context);
        final Contact? picked = contacts
            .where((c) => '${c.contactUserId ?? c.id}' == id)
            .firstOrNull;
        if (picked == null) return;
        final String name = picked.name ?? LocaleKeys.uk.tr();
        openChatWithContact(
          context,
          contact: picked,
          receiverName: HelperFunctions.getTheFirstTwoLettersOfName(name),
          fullReceiverName: name,
        );
      },
      // إضافة جهةٍ جديدة: تمرّ بطرف `save_contacts` — وهو يقبل جهةً
      // واحدة كما يقبل الدفتر كلَّه — ثم يطلب البلوكُ `GetContactsEvent`
      // فتظهر الجهة في القائمة بلا أن يُغلق المستخدمُ النافذة.
      onAdd: (name, phone) =>
          chatBloc.add(AddContactEvent(name: name, phone: phone)),
      // سحبةٌ إلى الأسفل تُحدِّث الجهات من الخادم.
      onRefresh: () async {
        chatBloc.add(const GetContactsEvent());
        await chatBloc.stream.firstWhere(
          (s) => s.getContactsStatus != GetContactsStatus.loading,
        );
      },
      listTitle: LocaleKeys.new_chat_title.tr(),
      formTitle: LocaleKeys.new_contact_title.tr(),
      newContactLabel: LocaleKeys.new_contact_title.tr(),
      nameLabel: LocaleKeys.full_name.tr(),
      namePlaceholder: LocaleKeys.enter_full_name.tr(),
      phoneLabel: LocaleKeys.phone_number.tr(),
      phonePlaceholder: LocaleKeys.phone_number.tr(),
      saveLabel: LocaleKeys.save.tr(),
      cancelLabel: LocaleKeys.cancel.tr(),
      // دعوةُ جهةٍ لا تملك التطبيق — نافذة الخيارات نفسها التي تفتحها
      // صفحة جهات الاتصال.
      inviteLabel: LocaleKeys.invite.tr(),
      onInvite: () => showInviteOptions(
        context,
        inviteLink: buildInviteLink(),
        onShare: shareInviteLink,
      ),
      // وميضُ زرّ الحفظ: يبقى ما دام الحفظ أو جلبُ الجهات جارياً.
      busy:
          chatBloc.state.saveContactsStatus == SaveContactsStatus.loading ||
          chatBloc.state.getContactsStatus == GetContactsStatus.loading,
      saveFailed:
          chatBloc.state.saveContactsStatus == SaveContactsStatus.failure,
    );
  }

  @override
  // TODO: implement numberOfFields
  int get numberOfFields => 1;
}

class ChatTabItem extends StatelessWidget {
  const ChatTabItem({
    Key? key,
    required this.iconUrl,
    required this.index,
    required this.activeIconUrl,
    required this.notificationCount,
  }) : super(key: key);
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
                                style: context.textTheme.titleMedium?.rq
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
