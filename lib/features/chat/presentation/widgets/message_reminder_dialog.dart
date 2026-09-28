import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trydos/features/chat/data/models/message_reminder_model.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// يصيغ موعد التذكير للعرض: «28 سبتمبر، 03:12 ص».
String formatReminderMoment(BuildContext context, DateTime moment) {
  final String locale = context.locale.toString();
  final DateTime local = moment.toLocal();
  return '${DateFormat('d MMMM', locale).format(local)}، '
      '${DateFormat('hh:mm a', locale).format(local)}';
}

/// نافذة ضبط تذكير على رسالة.
///
/// تبقى مفتوحة بعد الضبط لتعرض الموعد وتتيح تغييره أو إلغاءه — بعكس نافذة
/// التعديل التي تُغلق بالنجاح. الإغلاق بزرّه وحده.
Future<void> showMessageReminderDialog(
  BuildContext context, {
  required String messageId,
  required String channelId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: BlocProvider.of<ChatBloc>(context),
      child: _MessageReminderDialog(
        messageId: messageId,
        channelId: channelId,
      ),
    ),
  );
}

class _MessageReminderDialog extends StatefulWidget {
  const _MessageReminderDialog({
    required this.messageId,
    required this.channelId,
  });

  final String messageId;
  final String channelId;

  @override
  State<_MessageReminderDialog> createState() => _MessageReminderDialogState();
}

class _MessageReminderDialogState extends State<_MessageReminderDialog> {
  static const Color _blue = Color(0xff1877F2);
  static const Color _disabled = Color(0xffE4E6EB);
  static const Color _cardFill = Color(0xffFFFFFF);
  static const Color _cardBorder = Color(0xffE4E6EB);
  static const Color _bannerFill = Color(0xffF2F3F5);
  static const Color _danger = Color(0xffFA6868);
  static const Color _mutedText = Color(0xff8D8D8D);

  /// موعد اختاره المستخدم من المنتقي ولم يضبطه بعد.
  DateTime? _picked;

  /// تذكير هذه الرسالة كما هو في الحالة الآن — يتغيّر مع كل ضبط أو إلغاء.
  MessageReminderInfo? _reminderOf(ChatState state) {
    for (final Chat chat in [...state.chats, ...state.pinnedChats]) {
      if (chat.id != widget.channelId) continue;
      for (final Message message in chat.messages ?? const <Message>[]) {
        if (message.id == widget.messageId ||
            message.localId == widget.messageId) {
          return message.reminder;
        }
      }
    }
    return null;
  }

  void _setAt(DateTime moment) {
    BlocProvider.of<ChatBloc>(context).add(
      SetMessageReminderEvent(
        messageId: widget.messageId,
        channelId: widget.channelId,
        remindAt: moment,
      ),
    );
  }

  /// «صباح الغد» = الثامنة صباحاً من اليوم التالي.
  DateTime get _tomorrowMorning {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 8);
  }

  Future<void> _pickMoment() async {
    final DateTime now = DateTime.now();
    final DateTime? day = await showDatePicker(
      context: context,
      initialDate: _picked ?? now.add(const Duration(minutes: 20)),
      firstDate: now,
      // الخادم يرفض ما بعد 2038-01-19، فلا نعرض ما سيُرفض.
      lastDate: DateTime(2038, 1, 18),
    );
    if (day == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _picked ?? now.add(const Duration(minutes: 20)),
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _picked = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final MessageReminderInfo? reminder = _reminderOf(state);
        final bool isBusy =
            state.setMessageReminderStatus == SetMessageReminderStatus.loading;
        // الموعد المختار يجب أن يكون في المستقبل — الخادم يرفض الماضي.
        final bool canSet =
            _picked != null && _picked!.isAfter(DateTime.now()) && !isBusy;

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocaleKeys.remind_me.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1D1D1D),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (reminder?.remindAt != null) ...[
                    _CurrentReminderBanner(
                      moment: formatReminderMoment(
                        context,
                        reminder!.remindAt!,
                      ),
                      onCancel: isBusy
                          ? null
                          : () => BlocProvider.of<ChatBloc>(context).add(
                              CancelMessageReminderEvent(
                                reminderId: reminder.id,
                                messageId: widget.messageId,
                                channelId: widget.channelId,
                              ),
                            ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  _QuickOption(
                    label: LocaleKeys.after_20_minutes.tr(),
                    onTap: isBusy
                        ? null
                        : () => _setAt(
                            DateTime.now().add(const Duration(minutes: 20)),
                          ),
                  ),
                  _QuickOption(
                    label: LocaleKeys.after_an_hour.tr(),
                    onTap: isBusy
                        ? null
                        : () =>
                              _setAt(DateTime.now().add(const Duration(hours: 1))),
                  ),
                  _QuickOption(
                    label: LocaleKeys.after_3_hours.tr(),
                    onTap: isBusy
                        ? null
                        : () =>
                              _setAt(DateTime.now().add(const Duration(hours: 3))),
                  ),
                  _QuickOption(
                    label: LocaleKeys.tomorrow_morning.tr(),
                    onTap: isBusy ? null : () => _setAt(_tomorrowMorning),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    LocaleKeys.choose_date_and_time.tr(),
                    style: TextStyle(fontSize: 12.sp, color: _mutedText),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isBusy ? null : _pickMoment,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffF7F8FA),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16.sp,
                                  color: _mutedText,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    _picked == null
                                        ? LocaleKeys.choose_date_and_time.tr()
                                        : formatReminderMoment(
                                            context,
                                            _picked!,
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: _picked == null
                                          ? _mutedText
                                          : const Color(0xff1D1D1D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: canSet ? () => _setAt(_picked!) : null,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 44.h,
                          width: 72.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: canSet ? _blue : _disabled,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            LocaleKeys.set_reminder.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: canSet ? Colors.white : _mutedText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 44.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bannerFill,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        LocaleKeys.close.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff505050),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// شريط «التذكير مضبوط على …» مع زرّ الإلغاء.
class _CurrentReminderBanner extends StatelessWidget {
  const _CurrentReminderBanner({required this.moment, required this.onCancel});

  final String moment;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _MessageReminderDialogState._bannerFill,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${LocaleKeys.reminder_is_set_on.tr()} $moment',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xff505050),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onCancel,
            child: Text(
              LocaleKeys.cancel_reminder.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _MessageReminderDialogState._danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// خيار سريع (بعد 20 دقيقة، بعد ساعة، …).
class _QuickOption extends StatelessWidget {
  const _QuickOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: _MessageReminderDialogState._cardFill,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: _MessageReminderDialogState._cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xff1D1D1D),
            ),
          ),
        ),
      ),
    );
  }
}
