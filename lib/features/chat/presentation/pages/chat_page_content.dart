import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/data/models/my_contacts_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/utils/chat_search_match.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';
import 'package:trydos/features/chat/presentation/widgets/contact_card.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/my_text_widget.dart';
import '../../../home/presentation/widgets/sliver_list_seprated.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_state.dart';
import '../utils/firebase_presence.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({Key? key, this.onSendForwardMessage})
    : super(key: key);
  final Function(int receiverId, String channelId)? onSendForwardMessage;

  @override
  State<ChatPageContent> createState() => ChatPageContentState();
}

class ChatPageContentState extends State<ChatPageContent> {
  late Timer timers;
  late ChatBloc chatBloc;
  int differencetime = 0;
  @override
  void initState() {
    LastPagesTracker.push('ChatPageContent');
    // نصّ البحث ساكن، وحقلُه يُنشأ مع هذه الصفحة فارغاً. فبلا تصفيرٍ هنا تعود
    // الصفحة مفلترةً بنصٍّ لا يظهر في الحقل — قائمةٌ ناقصة بلا سبب مرئي.
    _query = '';
    searchContacts.value = const [];
    chatBloc = BlocProvider.of<ChatBloc>(context);
    differencetime = GetIt.I<PrefsRepository>().getdurtion ?? 0;

    FirebasePresence.sendUserStatus(
      DateTime.now().toUtc().add(Duration(minutes: differencetime)).toString(),
    );

    timers = Timer.periodic(const Duration(minutes: 4), (timer) {
      FirebasePresence.sendUserStatus(
        DateTime.now()
            .toUtc()
            .add(Duration(minutes: differencetime))
            .toString(),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    timers.cancel();
    super.dispose();
  }
  // todo 9/21 unused code
  //  late ChatBloc chatBloc;

  //  @override
  //  void initState() {
  //
  //    chatBloc = BlocProvider.of<ChatBloc>(context);
  //    super.initState();
  //  }
  static ValueNotifier<List<Chat>> searchChats = ValueNotifier([]);

  /// جهات اتصال طابقت البحث **ولا محادثة لها بعد**.
  ///
  /// تظهر تحت المحادثات، ومن لا تطبيق لديه يحمل زرّ الدعوة (يتكفّل به
  /// [ContactCard]). فارغةٌ دائماً ما دام الحقل فارغاً: دفتر الهاتف كاملاً
  /// تحت قائمة المحادثات ليس قائمة محادثات.
  static ValueNotifier<List<Contact>> searchContacts = ValueNotifier([]);
  static List<Chat> initialChats = [];

  /// نصّ البحث الحالي.
  ///
  /// تحتفظ به الحالة لأن القائمة تُعاد بناؤها مع كل رسالة واردة، وكانت تمسح
  /// نتائج البحث معها. الآن تُعاد التصفية بنفس النصّ بدل إلغائها.
  static String _query = '';

  static searchInChats(String? text) {
    _query = text ?? '';
    final int? myId = GetIt.I<PrefsRepository>().myChatId;

    if (_query.trim().isEmpty) {
      searchChats.value = initialChats;
      searchContacts.value = const [];
      return;
    }

    final List<Chat> chats = [];
    // معرّفات من ظهروا كمحادثات، كي لا يتكرّر الشخص سطرين.
    final Set<int> shownUserIds = {};

    for (final Chat chat in initialChats) {
      // `firstWhere` بلا `orElse` كانت ترمي `StateError` مع أوّل حرف يُكتب
      // متى كانت القناة بلا عضوٍ غيري — أو `channelMembers` فارغة أو `null`.
      final ChannelMember? member = chat.channelMembers
          ?.where((element) => element.userId != myId)
          .firstOrNull;

      if (ChatSearchMatch.matches(
        name: chat.channelName,
        phone: member?.user?.mobilePhone,
        query: _query,
      )) {
        chats.add(chat);
        if (member?.userId != null) shownUserIds.add(member!.userId!);
      }
    }

    // ثم جهات الاتصال: البحث شامل، فمن لم تراسله بعد يظهر أيضاً — ومن لا
    // تطبيق لديه يظهر بزرّ دعوة.
    final List<Contact> contacts = [];
    for (final Contact contact in GetIt.I<ChatBloc>().state.contacts) {
      if (contact.contactUserId != null &&
          shownUserIds.contains(contact.contactUserId)) {
        continue;
      }
      if (ChatSearchMatch.matches(
        name: contact.name,
        phone: contact.mobilePhone,
        query: _query,
      )) {
        contacts.add(contact);
      }
    }

    searchChats.value = chats;
    searchContacts.value = contacts;
  }

  @override
  // ! asd
  Widget build(BuildContext context) {
    //todo  9/21  change it to BlocBuilder
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) =>
          p.getChatsStatus != c.getChatsStatus ||
          p.unReadMessagesFromAllChats != c.unReadMessagesFromAllChats ||
          (p.changeChatPropertyStatus != c.changeChatPropertyStatus &&
              c.changeChatPropertyStatus != ChangeChatPropertyStatus.success) ||
          p.deleteChatStatus != c.deleteChatStatus ||
          // بدونها لا تُرشَّح المحادثة المؤرشفة من القائمة إلّا حين يصادف أن
          // يعيد بناءَها سببٌ آخر — فتبقى ظاهرة بعد الأرشفة.
          p.archiveChatStatus != c.archiveChatStatus ||
          c.createAnewChat ||
          c.sendMessageStatus == SendMessageStatus.loading ||
          p.receiveMessageStatus != c.receiveMessageStatus ||
          p.deleteMessageStatus != c.deleteMessageStatus,
      builder: (context, state) {
        if ((state.getChatsStatus == GetChatsStatus.loading ||
                state.getChatsStatus == GetChatsStatus.init) &&
            state.chats.isEmpty &&
            state.pinnedChats.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 1.sh - 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [TrydosLoader()],
              ),
            ),
          );
        }
        if (state.getChatsStatus == GetChatsStatus.failure &&
            searchChats.value.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  GetIt.I<ChatBloc>().add(const GetChatsEvent(limit: 10));
                },
                child: MyTextWidget(LocaleKeys.try_again.tr()),
              ),
            ),
          );
        }
        // todo (future update) here we can return try again if the status failure
        List<Chat> chats = List.of(state.pinnedChats);
        chats.addAll(List.of(state.chats));
        // todo  (future update) remove this from here handle it in the back of in bloc

        chats.removeWhere(
          (element) =>
              // int.tryParse(element.id.toString()) == null &&
              (element.messages.isNullOrEmpty),
        );

        // البحث يبقى على القائمة الكاملة — المؤرشفة تُخفى من العرض لا من
        // البحث، فمن يبحث عن محادثة أرشفها يجدها.
        initialChats = chats;
        // تُعاد التصفية بنفس النصّ لا تُلغى.
        //
        // كان هنا `searchChats.value = [...chats]` فتعود القائمة كاملةً بعد
        // كل بناء — ووصولُ رسالة أو تغيّر عدّاد غير المقروء منه. فبينما
        // المستخدم يقرأ نتائج بحثه تصل رسالة فيضيع ما بحث عنه.
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          searchInChats(_query);
        });
        return SlidableAutoCloseBehavior(
          child: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p, c) =>
                p.pusherActivityIds.length != c.pusherActivityIds.length,
            builder: (context, appState) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      width: 1.sw,
                      color: colorScheme.white,
                      child:
                          state.getChatsStatus != GetChatsStatus.success &&
                              state.firstRequestForGetChats &&
                              state.chats.isEmpty &&
                              state.pinnedChats.isEmpty
                          ? TrydosLoader()
                          : const SizedBox.shrink(),
                    ),
                  ),
                  ValueListenableBuilder<List<Chat>>(
                    valueListenable: searchChats,
                    builder: (context, searchedChats, _) {
                      return sliverListSeparated(
                        separator: const SizedBox.shrink(),
                        childCount: searchedChats.length,
                        itemBuilder: (_, index) {
                          bool thereActivity =
                              int.tryParse(
                                    searchedChats[index].id.toString(),
                                  ) !=
                                  null
                              ? appState.pusherActivityIds.containsKey(
                                  int.parse(searchedChats[index].id.toString()),
                                )
                              : false;
                          if (searchedChats[index].isPrivate == true) {
                            return const SizedBox.shrink();
                          }
                          // المؤرشفة تُخفى هنا فقط — تبقى في الحالة فيعمل
                          // فتحها ووصول رسائلها كما لو لم تُؤرشف. نفس معاملة
                          // `isPrivate` أعلاه.
                          if (searchedChats[index].isArchivedForMe(
                            GetIt.I<PrefsRepository>().myChatId,
                          )) {
                            return const SizedBox.shrink();
                          }
                          return ChatCard(
                            key: TestVariables.kTestMode
                                ? Key(
                                    '${WidgetsKeys.chatConversationCardKey}$index',
                                  )
                                : null,
                            onSendForwardMessage: widget.onSendForwardMessage,
                            chat: searchedChats[index],
                            thereActivity: thereActivity,
                            index: index,
                            activityDescription: thereActivity
                                ? appState.pusherActivityDescription[int.parse(
                                    searchedChats[index].id.toString(),
                                  )]
                                : null,
                            messageId:
                                searchedChats[index].messages?.first.id ?? "",
                          );
                        },
                      );
                    },
                  ),
                  // جهات الاتصال المطابِقة — تحت المحادثات، وعند البحث فقط.
                  ValueListenableBuilder<List<Contact>>(
                    valueListenable: searchContacts,
                    builder: (context, contacts, _) {
                      return sliverListSeparated(
                        separator: const SizedBox.shrink(),
                        childCount: contacts.length,
                        itemBuilder: (_, index) =>
                            ContactCard(index: index, contact: contacts[index]),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      width: 1.sw,
                      color: colorScheme.white,
                      child:
                          state.getChatsStatus != GetChatsStatus.success &&
                              !state.firstRequestForGetChats
                          ? TrydosLoader()
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
