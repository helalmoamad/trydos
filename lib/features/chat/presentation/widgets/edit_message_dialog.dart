import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// نافذة تعديل نص رسالة.
///
/// «حفظ» معطّل حتى يصير النص غير فارغ **ومختلفاً** عن الأصل — فحفظ نص لم يتغيّر
/// طلب شبكة بلا أثر. وأثناء الطلب يتحوّل الزر إلى shimmer بدل مؤشّر تحميل، وهو
/// أسلوب المشروع في أزرار الانتظار.
///
/// النافذة لا تُغلق إلا بالنجاح: الفشل يُبقي النص الذي كتبه المستخدم أمامه بدل
/// أن يضيع.
Future<void> showEditMessageDialog(
  BuildContext context, {
  required String messageId,
  required String channelId,
  required String initialContent,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: BlocProvider.of<ChatBloc>(context),
      child: _EditMessageDialog(
        messageId: messageId,
        channelId: channelId,
        initialContent: initialContent,
      ),
    ),
  );
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({
    required this.messageId,
    required this.channelId,
    required this.initialContent,
  });

  final String messageId;
  final String channelId;
  final String initialContent;

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  static const Color _blue = Color(0xff1877F2);
  static const Color _fieldFill = Color(0xffF7F8FA);
  static const Color _disabledFill = Color(0xffE4E6EB);
  static const Color _cancelFill = Color(0xffF2F3F5);
  static const Color _mutedText = Color(0xff8D8D8D);

  late final TextEditingController _controller = TextEditingController(
    text: widget.initialContent,
  );
  late final FocusNode _focusNode = FocusNode();

  /// يُقرأ في كل بناء من المستمع أدناه، فلا حاجة إلى setState لكل حرف.
  bool get _canSave {
    final String text = _controller.text.trim();
    return text.isNotEmpty && text != widget.initialContent.trim();
  }

  @override
  void initState() {
    super.initState();
    // المؤشّر في نهاية النص لا في بدايته — المستخدم يُكمل رسالته عادةً.
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    BlocProvider.of<ChatBloc>(context).add(
      UpdateMessageEvent(
        messageId: widget.messageId,
        channelId: widget.channelId,
        content: _controller.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (p, c) => p.updateMessageStatus != c.updateMessageStatus,
      listener: (context, state) {
        if (state.updateMessageStatus == UpdateMessageStatus.success) {
          Navigator.of(context).pop();
        }
      },
      buildWhen: (p, c) => p.updateMessageStatus != c.updateMessageStatus,
      builder: (context, state) {
        final bool isSaving =
            state.updateMessageStatus == UpdateMessageStatus.loading;
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    LocaleKeys.edit_message.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1D1D1D),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  LocaleKeys.your_message.tr(),
                  style: TextStyle(fontSize: 12.sp, color: _mutedText),
                ),
                SizedBox(height: 8.h),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, _, __) {
                    return TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      enabled: !isSaving,
                      maxLines: 4,
                      minLines: 3,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xff1D1D1D),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _fieldFill,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: _blue, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: _blue, width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: _disabledFill,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: LocaleKeys.cancel.tr(),
                        background: _cancelFill,
                        foreground: _mutedText,
                        // لا إلغاء أثناء الحفظ: الطلب في الطريق ونتيجته ستغلق
                        // النافذة بنفسها.
                        onTap: isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, _, __) {
                          if (isSaving) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: _disabledFill,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            );
                          }
                          return _DialogButton(
                            label: LocaleKeys.save.tr(),
                            background: _canSave ? _blue : _disabledFill,
                            foreground: _canSave ? Colors.white : _mutedText,
                            onTap: _canSave ? _save : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
