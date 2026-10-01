import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/helper/helper_functions.dart';
import 'package:trydos/features/chat/data/models/message_reminder_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/features/chat/presentation/widgets/message_reminder_dialog.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:trydos/routes/router.dart';

/// صفّ «التذكيرات» فوق قائمة المحادثات.
///
/// مغلقاً: جرس + العنوان + العدد في الطرف المقابل. مفتوحاً: العنوان وسهم
/// أزرق للرجوع — لأن القائمة حينها **تحلّ محلّ المحادثات** فالعدد بلا معنى،
/// وهو ظاهر أمام المستخدم.
///
/// يختفي كلّياً حين لا تذكيرات، فلا صفّ فارغ يزاحم القائمة.
class RemindersHeaderSliver extends StatelessWidget {
  const RemindersHeaderSliver({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  final ValueNotifier<bool> isOpen;

  /// الفتح والإغلاق يمرّان بالصفحة لا بالمُخطِر مباشرةً — هي وحدها تعرف
  /// القائمة الأخرى فتغلقها.
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) => p.reminders.length != c.reminders.length,
      builder: (context, state) {
        if (state.reminders.isEmpty) {
          // آخر تذكير غادر والقائمة مفتوحة: تُغلق نفسها وإلّا بقي المستخدم
          // أمام شاشة فارغة بلا طريق للرجوع.
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
                            // أيقونة التطبيق نفسها الظاهرة على الرسالة
                            // المذكَّرة، لا أيقونة Material — حتى يكون الرمز
                            // واحداً أينما دلّ على تذكير. وتبقى في الحالتين:
                            // هي هويّة الصفّ، وغيابها بعد الفتح يجعل الرأس
                            // سطراً مجرّداً بلا دلالة.
                            SvgPicture.asset(
                              AppAssets.notificationIconSvg,
                              width: 14.sp,
                              height: 14.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                LocaleKeys.reminders.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff1D1D1D),
                                ),
                              ),
                            ),
                            if (!open) ...[
                              Text(
                                '${state.reminders.length}',
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

/// قائمة التذكيرات نفسها. تُبنى بدل سليفر المحادثات لا فوقه.
class RemindersListSliver extends StatelessWidget {
  const RemindersListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) => p.reminders != c.reminders,
      builder: (context, state) {
        final List<MessageReminderItem> reminders = state.reminders;
        return SliverList.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) => _ReminderRow(
            key: ValueKey(reminders[index].reminder.id),
            item: reminders[index],
          ),
        );
      },
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
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _openChat(context),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 6.w, 10.h),
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
                          // الرسائل غير النصّية تصل بمحتوى فارغ، فنكتفي بكلمة
                          // عامّة بدل سطر خالٍ.
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
                            SvgPicture.asset(
                              AppAssets.notificationIconSvg,
                              width: 12.sp,
                              height: 12.sp,
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
          ),
          Container(height: 0.5, color: const Color(0xffE4E6EB)),
        ],
      ),
    );
  }
}
