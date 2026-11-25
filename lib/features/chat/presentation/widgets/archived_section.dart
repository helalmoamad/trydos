// `easy_localization` يُصدِّر `TextDirection` من `intl` فيحجب الذي في
// Flutter، ولذلك يُستورَد الأصل بسابقة.
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/pick_sheet_v2.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page_design.dart';

/// المحادثات المؤرشفة كما هي في الحالة.
///
/// تُقرأ من نفس القوائم لا من قائمة ثالثة — الأرشفة علمٌ على المحادثة، والفرز
/// هنا في طبقة العرض وحدها.
List<Chat> archivedChatsOf(ChatState state) {
  final int? myChatId = GetIt.I<PrefsRepository>().myChatId;
  return [...state.pinnedChats, ...state.chats]
      .where(
        (chat) =>
            chat.isArchivedForMe(myChatId) &&
            !(chat.isPrivate ?? false) &&
            !(chat.messages?.isEmpty ?? true),
      )
      .toList();
}

/// صفّ «المؤرشفة» تحت صفّ «التذكيرات».
///
/// مغلقاً: أيقونة + العنوان + **عدد المحادثات المؤرشفة**. مفتوحاً: العنوان
/// وسهم أزرق للرجوع — نفس تصميم صفّ التذكيرات.
///
/// يختفي كلّياً حين لا مؤرشفة.
class ArchivedHeaderSliver extends StatelessWidget {
  const ArchivedHeaderSliver({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  final ValueNotifier<bool> isOpen;

  /// كما في [RemindersHeaderSliver]: الصفحة وحدها تعرف القائمة الأخرى.
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final int count = archivedChatsOf(state).length;
        if (count == 0) {
          // آخر محادثة غادرت الأرشيف والقائمة مفتوحة: تُغلق نفسها، وإلّا بقي
          // المستخدم أمام شاشة فارغة بلا صفّ يرجع منه.
          if (isOpen.value) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => onToggle(false),
            );
          }
          return const SliverToBoxAdapter();
        }

        return SliverToBoxAdapter(
          child: ValueListenableBuilder<bool>(
            valueListenable: isOpen,
            builder: (context, open, _) {
              // صفّ الأرشيف بالتصميم الجديد.
              //
              // منقولٌ من `ChatListScreen.tsx` على فرع `development`:
              //
              // > صفُّ المحادثات المؤرشفة، فوق القائمة ما دام فيها شيء:
              // > علامةُ أرشفة خانةِ السحب حيث عمودُ الصورة، و«Archived»
              // > 14 Medium عند x=90، والعدد 14 رمادياً على اليمين. ونقرةٌ
              // > عليه تفتح نافذة المؤرشفة.
              //
              // والصفّ القديم — بالشيفرون وخطّه — معلَّقٌ أدناه.
              return GestureDetector(
                // **نافذةٌ لا قائمة**: الملف يفتح `ArchivedSheet` فوق
                // الشاشة، ونحن كنّا نستبدل قائمةَ المحادثات بقائمة
                // المؤرشفة والرجوعُ بالضغط على الصفّ نفسه.
                //
                // و`onToggle` و`ArchivedListSliver` في تاريخ المستودع، على
                // فرع `dev_new`.
                onTap: () => _openArchivedSheetV2(context),
                behavior: HitTestBehavior.opaque,
                child: Directionality(
                  // جهاتٌ مطلقة كالملف: العلامة يساراً والعدد يميناً.
                  textDirection: ui.TextDirection.ltr,
                  child: Container(
                    height: ChatListDesign.archivedHeight.h,
                    margin: EdgeInsets.only(top: ChatListDesign.rowGap.h),
                    color: ChatListDesign.page,
                    child: Row(
                      children: [
                        // العلامة في وسط عمود الصورة: 12 ثم نصف (66-25).
                        Padding(
                          padding: EdgeInsets.only(
                            left:
                                (ChatListDesign.photoX +
                                        (ChatListDesign.photoW - 25) / 2)
                                    .w,
                          ),
                          child: const XdIcon('swipeArchive', width: 25),
                        ),
                        Padding(
                          // الكلمة عند x=90، والعلامة تنتهي عند موضعها + 25.
                          padding: EdgeInsets.only(
                            left:
                                (ChatListDesign.textX -
                                        (ChatListDesign.photoX +
                                            (ChatListDesign.photoW - 25) / 2 +
                                            25))
                                    .w,
                          ),
                          child: DesignText(
                            LocaleKeys.archived.tr(),
                            size: 14,
                            family: 'Quicksand-Medium',
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 13.w),
                          child: DesignText(
                            '$count',
                            size: 14,
                            family: 'Quicksand-Regular',
                            color: ChatListDesign.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// يفتح نافذة المؤرشفة — [ArchivedSheetV2] داخل [PickSheetV2].
  ///
  /// صفوفُها هي صفُّ النوافذ المشترك ([SheetChatRowV2]) نفسه الذي تستعمله
  /// نافذة «تحويل إلى»، ومعه زرُّ الإعادة 44 بنفسجياً باهتاً — كما في الملف.
  void _openArchivedSheetV2(BuildContext context) {
    final ChatBloc bloc = BlocProvider.of<ChatBloc>(context);
    PickSheetV2.show<void>(
      context,
      title: LocaleKeys.archived.tr(),
      children: [
        BlocBuilder<ChatBloc, ChatState>(
          bloc: bloc,
          builder: (context, state) {
            final List<Chat> rows = archivedChatsOf(state);
            return ArchivedSheetV2(
              emptyLabel: LocaleKeys.no_results.tr(),
              chats: [
                for (final Chat chat in rows)
                  (
                    id: chat.id.toString(),
                    name: chat.channelName ?? LocaleKeys.no_channal_name.tr(),
                    secondLine:
                        chat.messages?.firstOrNull?.messageContent?.content
                            ?.toString() ??
                        '',
                    initials: HelperFunctions.getTheFirstTwoLettersOfName(
                      chat.channelName ?? LocaleKeys.no_channal_name.tr(),
                    ),
                    photo: null,
                  ),
              ],
              onOpen: (id) {
                Navigator.of(context).pop();
                // فتحُ المحادثة يمرّ بالصفّ نفسه الذي تمرّ به القائمة، فلا
                // مسارَ ثانٍ يتباعد عنه.
                final Chat? chat = rows
                    .where((c) => c.id.toString() == id)
                    .firstOrNull;
                if (chat == null) return;
                bloc.add(
                  ChangeGlobalUsedVariablesInBloc(currentOpenedChatId: chat.id),
                );
              },
              onUnarchive: (id) =>
                  bloc.add(ArchiveChatEvent(channelId: id, archived: false)),
            );
          },
        ),
      ],
    );
  }
}

/// قائمة المحادثات المؤرشفة. تُبنى بدل سليفر المحادثات لا فوقه.
///
/// تستعمل [ChatCard] نفسها التي تستعملها القائمة العادية، فتأتي مجّاناً: فتح
/// المحادثة، والسحب للتثبيت والكتم و**إلغاء الأرشفة**، وشارة غير المقروء.
class ArchivedListSliver extends StatelessWidget {
  const ArchivedListSliver({super.key, this.onSendForwardMessage});

  final Function(int receiverId, String channelId)? onSendForwardMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final List<Chat> archived = archivedChatsOf(state);
        return SliverToBoxAdapter(
          child: SlidableAutoCloseBehavior(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                archived.length,
                (index) => ChatCard(
                  key: ValueKey('archived_${archived[index].id}'),
                  onSendForwardMessage: onSendForwardMessage,
                  chat: archived[index],
                  thereActivity: false,
                  index: index,
                  messageId: archived[index].messages?.first.id ?? "",
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
