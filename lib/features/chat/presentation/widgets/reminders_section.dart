import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/chat/data/models/message_reminder_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/widgets/message_reminder_dialog.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';

/// قسم «التذكيرات» فوق قائمة المحادثات.
///
/// يختفي كلّياً حين لا تذكيرات — لا صفّ فارغ يزاحم القائمة. ويُفتح ويُطوى
/// بالضغط على رأسه، فلا يأكل الشاشة حين تكثر التذكيرات.
class RemindersSection extends StatefulWidget {
  const RemindersSection({super.key});

  @override
  State<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<RemindersSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) => p.reminders != c.reminders,
      builder: (context, state) {
        final List<MessageReminderItem> reminders = state.reminders;
        if (reminders.isEmpty) return const SliverToBoxAdapter();

        return SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 18.sp,
                          color: const Color(0xff388cff),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          LocaleKeys.reminders.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1D1D1D),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _CountBadge(count: reminders.length),
                        const Spacer(),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.chevron_right_rounded,
                          size: 22.sp,
                          color: const Color(0xff8D8D8D),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_expanded)
                  ...reminders.map(
                    (item) => _ReminderRow(key: ValueKey(item.reminder.id), item: item),
                  ),
                Container(height: 0.5, color: const Color(0xffE4E6EB)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xff388cff),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// سطر تذكير واحد: المُرسِل، نوع الرسالة، الموعد، وزرّ الإلغاء.
class _ReminderRow extends StatelessWidget {
  const _ReminderRow({super.key, required this.item});

  final MessageReminderItem item;

  /// يفتح المحادثة التي تخصّ التذكير.
  ///
  /// نفس مسار فتح محادثة من إشعار: المعرّفات وحدها تكفي، وبقية البيانات
  /// تقرأها الصفحة من الحالة.
  void _openChat(BuildContext context) {
    final String? channelId = item.message?.channelId;
    if (channelId == null || channelId.isEmpty || channelId == 'null') return;
    final String senderName = item.message?.senderUser?.name ?? '';
    context.push(
      '${GRouter.config.applicationRoutes.kSinglePageChatPagePath}'
      '?chatId=$channelId'
      '&receiverName=${HelperFunctions.getTheFirstTwoLettersOfName(senderName)}'
      '&fullReceiverName=$senderName'
      '&receiverPhone=${LocaleKeys.uk.tr()}'
      '&senderName=$senderName',
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? remindAt = item.reminder.remindAt;
    return InkWell(
      onTap: () => _openChat(context),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.message?.senderUser?.name ?? LocaleKeys.uk.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1D1D1D),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    // الرسائل غير النصّية تصل بمحتوى فارغ، فنكتفي بكلمة عامّة.
                    (item.message?.content?.trim().isNotEmpty ?? false)
                        ? item.message!.content!
                        : LocaleKeys.message.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xff8D8D8D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 12.sp,
                        color: const Color(0xff388cff),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        remindAt == null
                            ? ''
                            : formatReminderMoment(context, remindAt),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xff388cff),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => BlocProvider.of<ChatBloc>(context).add(
                CancelMessageReminderEvent(
                  reminderId: item.reminder.id,
                  messageId: item.messageId,
                  channelId: item.message?.channelId,
                ),
              ),
              icon: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: const Color(0xff8D8D8D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
