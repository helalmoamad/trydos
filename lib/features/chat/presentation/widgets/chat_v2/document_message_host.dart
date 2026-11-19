import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/file_location_messages_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/message_adapter_v2.dart';
import 'package:trydos/common/helper/file_saving.dart';

/// يملك تنزيل الملف وفتحه ويغذّي [FileMessageV2] بحالته.
///
/// المنطق هنا هو منطق `DocumentMessage` القديم نفسه: ما أرسلتُه يُحفظ محلياً
/// فور ظهوره، وما وصلني يُنزَّل عند أوّل ضغطة ثم يُفتح. و[FileMessageV2] شكلٌ
/// خالص لا يعرف تنزيلاً — فيبقى التصميم قابلاً للمطابقة بلا أن يجرّ معه
/// حزمة ملفات، ويبقى المنطق في مكانٍ واحد.
class DocumentMessageHost extends StatefulWidget {
  const DocumentMessageHost({
    super.key,
    required this.name,
    required this.isMine,
    required this.time,
    required this.channelId,
    this.file,
    this.fileUrl,
    this.status,
  });

  final String name;
  final bool isMine;
  final String time;

  /// القناة — `FileSaving` يحفظ تحتها.
  final String channelId;

  /// النسخة المحلّية، إن وُجدت.
  final File? file;
  final String? fileUrl;

  final BubbleStatus? status;

  @override
  State<DocumentMessageHost> createState() => _DocumentMessageHostState();
}

class _DocumentMessageHostState extends State<DocumentMessageHost> {
  /// النسخة المحلّية الحاضرة — تتبدّل حين ينتهي التنزيل.
  File? _local;

  /// تنزيلٌ جارٍ — الضغط أثناءه لا يبدأ ثانياً.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _local = widget.file;

    // ما أرسلتُه يُحفظ محلياً كما كان يفعل `DocumentMessage`.
    if (widget.isMine) {
      final String? source = widget.fileUrl ?? widget.file?.path;
      if (source != null) {
        FileSaving().downloadFileToLocalStorage(source, widget.channelId);
      }
    }
  }

  @override
  void didUpdateWidget(DocumentMessageHost old) {
    super.didUpdateWidget(old);
    // الخادم أكّد الرسالة وأعطاها ملفاً: تُؤخذ النسخة الجديدة.
    if (widget.file != null && widget.file?.path != old.file?.path) {
      _local = widget.file;
    }
  }

  Future<void> _open() async {
    if (_busy) return;

    final File? ready = _local;
    if (ready != null) {
      await _reveal(ready.path);
      return;
    }

    final String? url = widget.fileUrl;
    if (url == null || url.isEmpty) return;

    setState(() => _busy = true);
    FileSaving().downloadFileToLocalStorage(
      url,
      widget.channelId,
      action: (File? file) {
        if (!mounted) return;
        setState(() {
          _local = file;
          _busy = false;
        });
        if (file != null) _reveal(file.path);
      },
    );
  }

  Future<void> _reveal(String path) async {
    final OpenResult result = await OpenFile.open(path);
    if (result.type == ResultType.done || !mounted) return;
    // صيغةٌ لا يفتحها الجهاز — تُقال بلا نافذةٍ تحجب المحادثة.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    return FileMessageV2(
      name: widget.name,
      sizeText: MessageAdapterV2.fileSubtitle(local: _local),
      time: widget.time,
      isMine: widget.isMine,
      status: widget.status,
      onTap: _open,
    );
  }
}
