import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_card.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            WidgetsBinding.instance.addPostFrameCallback((_) => onToggle(false));
          }
          return const SliverToBoxAdapter();
        }

        return SliverToBoxAdapter(
          child: ValueListenableBuilder<bool>(
            valueListenable: isOpen,
            builder: (context, open, _) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onToggle(!open),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.archiveSvg,
                              width: 14.sp,
                              height: 14.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                LocaleKeys.archived.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff1D1D1D),
                                ),
                              ),
                            ),
                            // عدد المحادثات المؤرشفة، كعدّاد صفّ التذكيرات.
                            // يُخفى عند الفتح لأن القائمة أمام المستخدم حينها.
                            if (!open) ...[
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xff8D8D8D),
                                ),
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 22.sp,
                              color: open
                                  ? const Color(0xff388cff)
                                  : const Color(0xff8D8D8D),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 0.5, color: const Color(0xffE4E6EB)),
                  ],
                ),
              );
            },
          ),
        );
      },
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
