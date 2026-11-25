// `easy_localization` يصدّر `TextDirection` خاصّته (من `intl`) فيحجب التي في
// Flutter، والمطلوب هنا هي اتجاه الودجت لا اتجاه النصّ.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/chat/data/models/message_tag_model.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/domain/use_cases/toggle_message_tag_usecase.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/manager/chat_event.dart';
import 'package:trydos/features/chat/presentation/manager/chat_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// نافذة وسم رسالة.
///
/// تبقى مفتوحة بعد كل تغيير — كنافذة التذكير لا كنافذة التعديل: المستخدم قد
/// يضيف وسمين ويزيل ثالثاً في جلسة واحدة. الإغلاق بزرّه وحده.
Future<void> showMessageTagDialog(
  BuildContext context, {
  required String messageId,
  required String channelId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: BlocProvider.of<ChatBloc>(context),
      child: _MessageTagDialog(messageId: messageId, channelId: channelId),
    ),
  );
}

class _MessageTagDialog extends StatefulWidget {
  const _MessageTagDialog({required this.messageId, required this.channelId});

  final String messageId;
  final String channelId;

  @override
  State<_MessageTagDialog> createState() => _MessageTagDialogState();
}

class _MessageTagDialogState extends State<_MessageTagDialog> {
  static const Color _blue = Color(0xff1877F2);
  static const Color _disabled = Color(0xffBCC0C4);
  static const Color _cardBorder = Color(0xffE4E6EB);
  static const Color _rowFill = Color(0xffF2F3F5);
  static const Color _mutedText = Color(0xff8D8D8D);
  static const Color _text = Color(0xff1D1D1D);

  final TextEditingController _controller = TextEditingController();

  /// الوسم الذي ينتظر ردّ الخادم الآن، أو `null`.
  ///
  /// النافذة تعرض عدّة أسطر، ولا يكفي أن نعرف «هناك طلب جارٍ» — لولا هذا لظهر
  /// المؤشّر على كل سطر دفعةً واحدة.
  String? _pending;

  /// وسمٌ جديد كُتب في الحقل وينتظر ردّ الخادم.
  ///
  /// منفصلٌ عن [_pending] لأن الوسم الجديد لا سطر له بعد، فمؤشّره يحلّ محلّ
  /// كلمة «إضافة». وفصلهما يمنع ظهور مؤشّرين حين يُكتب اسم وسمٍ معروضٍ أصلاً
  /// كاقتراح.
  bool _addingTyped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _myId => GetIt.I<PrefsRepository>().myChatId;

  /// الرسالة المقصودة كما هي في الحالة الآن.
  Message? _messageOf(ChatState state) {
    for (final Chat chat in [...state.chats, ...state.pinnedChats]) {
      if (chat.id != widget.channelId) continue;
      for (final Message message in chat.messages ?? const <Message>[]) {
        if (message.id == widget.messageId ||
            message.localId == widget.messageId) {
          return message;
        }
      }
    }
    return null;
  }

  /// أسطر النافذة: وسوم هذه الرسالة أوّلاً، ثم اقتراحاتٌ من **هذه المحادثة
  /// وحدها**.
  ///
  /// الاقتراح وسمٌ استعملتُه أنا على رسالة أخرى هنا، فيظهر بلا عدّاد وبلا سهم
  /// — جاهزاً لإعادة الاستعمال بضغطة. ولا نجمع وسوم الآخرين: السطر الذي لم
  /// أضعه أنا لا معنى لاقتراحه عليّ.
  List<_TagRow> _rows(ChatState state) {
    final Message? message = _messageOf(state);
    final List<_TagRow> rows = [
      for (final MessageTag tag in message?.tags ?? const <MessageTag>[])
        _TagRow(name: tag.tag, count: tag.count, applied: tag.appliedBy(_myId)),
    ];

    final Set<String> seen = rows.map((e) => e.name).toSet();
    for (final String name in _suggestions(state)) {
      if (seen.add(name)) rows.add(_TagRow(name: name));
    }
    return rows;
  }

  /// وسومٌ وضعتُها أنا على رسائل هذه المحادثة.
  List<String> _suggestions(ChatState state) {
    final List<String> names = [];
    for (final Chat chat in [...state.chats, ...state.pinnedChats]) {
      if (chat.id != widget.channelId) continue;
      for (final Message message in chat.messages ?? const <Message>[]) {
        for (final MessageTag tag in message.tags) {
          if (tag.appliedBy(_myId) && !names.contains(tag.tag)) {
            names.add(tag.tag);
          }
        }
      }
    }
    return names;
  }

  void _toggle(String tag, {required bool add, bool fromField = false}) {
    setState(() {
      _pending = fromField ? null : tag;
      _addingTyped = fromField;
    });
    BlocProvider.of<ChatBloc>(context).add(
      ToggleMessageTagEvent(
        messageId: widget.messageId,
        channelId: widget.channelId,
        tag: tag,
        add: add,
      ),
    );
  }

  void _addTyped() {
    final String tag = ToggleMessageTagParams.normalizeTag(_controller.text);
    if (tag.isEmpty) return;
    _controller.clear();
    _toggle(tag, add: true, fromField: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (p, c) =>
          p.toggleMessageTagStatus != c.toggleMessageTagStatus &&
          c.toggleMessageTagStatus != ToggleMessageTagStatus.loading,
      listener: (context, state) {
        if (!mounted) return;
        setState(() {
          _pending = null;
          _addingTyped = false;
        });
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final List<_TagRow> rows = _rows(state);
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.message_tag_title.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _field(),
                  if (rows.isNotEmpty) SizedBox(height: 10.h),
                  // قائمة قابلة للتمرير بسقف ارتفاع: الوسوم تتراكم مع الوقت،
                  // وبلا سقف تخرج النافذة عن الشاشة.
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 220.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) => _row(rows[index]),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _closeButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: MessageTag.maxLength,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _addTyped(),
            style: TextStyle(fontSize: 13.sp, color: _text),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              hintText: LocaleKeys.new_tag_hint.tr(),
              hintStyle: TextStyle(fontSize: 13.sp, color: _mutedText),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _text, width: 1.4),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // أثناء الطلب يحلّ مؤشّر محلّ الكلمة في نفس المساحة: بدونه كانت
        // الضغطة لا تُحدث شيئاً مرئياً حتى يردّ الخادم، فلا يدري المستخدم
        // أوصلت ضغطته أم لا.
        //
        // والزرّ معطّل حتى يُكتب شيء، ومعطّل أثناء الطلب — فضغطتان متلاحقتان
        // تنشئان وسمين.
        if (_addingTyped)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_blue),
              ),
            ),
          )
        else
          _TextButton(
            label: LocaleKeys.add.tr().trim(),
            enabled:
                _controller.text.trim().isNotEmpty &&
                _pending == null &&
                !_alreadyTyped(),
            onTap: _addTyped,
          ),
      ],
    );
  }

  /// هل الوسم المكتوب موجودٌ أصلاً على هذه الرسالة بوضعي أنا؟
  ///
  /// لو تُرك الزرّ مفعّلاً لأرسلنا `add` لوسم مضاف — طلبٌ بلا أثر يربك
  /// المستخدم بمؤشّر لا يغيّر شيئاً.
  bool _alreadyTyped() {
    final String typed = ToggleMessageTagParams.normalizeTag(_controller.text);
    final Message? message = _messageOf(
      BlocProvider.of<ChatBloc>(context).state,
    );
    return (message?.tags ?? const <MessageTag>[]).any(
      (e) => e.tag == typed && e.appliedBy(_myId),
    );
  }

  Widget _row(_TagRow row) {
    final bool busy = _pending == row.name;
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: busy ? null : () => _toggle(row.name, add: !row.applied),
      child: Container(
        // الحشو الأمامي 14 والخلفي 10: السهم يلتصق بنهاية الحقل كما في
        // التصميم.
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 10.w, 12.h),
        decoration: BoxDecoration(
          color: row.applied ? _rowFill : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            // الاسم داخل `Expanded` **بلا `Spacer` بعده**.
            //
            // كان `Flexible` للاسم و`Spacer` للدفع، ولكلٍّ منهما عامل تمدّد
            // `1`، فيقتسمان الفراغ نصفين: الاسم القصير يترك نصفه شاغراً،
            // والسهم يُدفَع بنصفٍ واحد فقط — فيستقرّ في المنتصف. و`Expanded`
            // يبتلع الفراغ كلّه فينتهي السهم حيث يجب.
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: _mutedText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Flexible(
                    child: Text(
                      row.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp, color: _text),
                    ),
                  ),
                  if (row.applied && row.count > 0) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '${row.count}',
                      style: TextStyle(fontSize: 10.sp, color: _mutedText),
                    ),
                  ],
                ],
              ),
            ),
            // السهم الأزرق يقول «هذا الوسم مضاف»، وهو زرّ الإزالة نفسه.
            // وأثناء طلب الإزالة يحلّ محلّه مؤشّر صغير في نفس المساحة، فلا
            // يقفز السطر.
            if (busy)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_blue),
                ),
              )
            else if (row.applied)
              _DirectionalArrow(size: 16.sp, color: _blue),
          ],
        ),
      ),
    );
  }

  Widget _closeButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          backgroundColor: _rowFill,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          LocaleKeys.close.tr(),
          style: TextStyle(fontSize: 13.sp, color: _blue),
        ),
      ),
    );
  }
}

/// السهم الأزرق، منعكساً مع اتجاه اللغة.
///
/// `Icons.reply` يشير يساراً دائماً ولا ينعكس من تلقائه، فيبدو في العربية
/// وكأنه يشير خارج السطر. فنعكسه بأنفسنا حين يكون الاتجاه من اليمين.
class _DirectionalArrow extends StatelessWidget {
  const _DirectionalArrow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return Transform.scale(
      scaleX: rtl ? -1 : 1,
      child: Icon(Icons.reply, size: size, color: color),
    );
  }
}

/// سطرٌ في النافذة: وسمٌ على الرسالة، أو اقتراحٌ من المحادثة.
class _TagRow {
  final String name;
  final int count;

  /// وسمتُ أنا هذه الرسالة به. الاقتراح `false` دائماً.
  final bool applied;

  const _TagRow({required this.name, this.count = 0, this.applied = false});
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onTap : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: enabled
              ? _MessageTagDialogState._text
              : _MessageTagDialogState._disabled,
        ),
      ),
    );
  }
}
