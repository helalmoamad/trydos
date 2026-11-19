import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/chat/data/models/my_chats_response_model.dart';
import 'package:trydos/features/chat/presentation/pages/conversation_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_bubble_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/file_location_messages_v2.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// جسرٌ بين نموذج الرسالة في التطبيق وودجتات التصميم الجديد.
///
/// الودجتات في `chat_v2/` شكلٌ خالص لا تعرف `Message` ولا `MessageStatus`.
/// وهذا الملف يترجم بينهما، فيبقى الطرفان مستقلّين: نموذج الخادم يتغيّر بلا
/// أن يمسّ التصميم، والتصميم يُطابَق بلا أن يمسّ النموذج.
abstract class MessageAdapterV2 {
  /// حالة التسليم من سجلّ حالة الرسالة لدى الطرف الآخر.
  ///
  /// يُرجع `null` للرسائل الواردة: الملف لا يرسم علامات تسليم إلّا على ما
  /// أرسلتُه أنا.
  static BubbleStatus? statusOf({
    required bool isMine,
    required MessageStatus? status,
  }) {
    if (!isMine) return null;
    if (status?.isWatched ?? false) return BubbleStatus.read;
    if ((status?.isReceived ?? 0) == 1) return BubbleStatus.delivered;
    return BubbleStatus.sent;
  }

  /// مدّة المكالمة كما يكتبها التصميم: «3 Min».
  ///
  /// الويب يعرض الدقائق لا الثواني، فمكالمةٌ أقصر من دقيقة تُكتب دقيقةً
  /// واحدة لا صفراً.
  static String minutesOf(int seconds) {
    final int minutes = (seconds / 60).ceil();
    return LocaleKeys.n_min.tr().replaceAll('{n}', '$minutes');
  }

  /// حجم الملف وحده — «2.4 MB». النوع تُلحقه [FileMessageV2] بنفسها.
  ///
  /// الخادم لا يُرجع حجم الملف، فالحجم يُقرأ من النسخة المحلية وحدها: ما
  /// أرسلتُه للتوّ يظهر بحجمه، وما نزل من الخادم يظهر بنوعه فقط. وتجنّب
  /// طلبٍ إضافياً لمعرفة الحجم أهون من بطاقةٍ تنتظر الشبكة لترسم سطرها.
  static String fileSubtitle({required File? local}) {
    if (local == null) return '';
    return _sizeText(local) ?? '';
  }

  /// حجم ملفٍ محليّ مكتوباً، أو `null` إن تعذّرت قراءته.
  static String? _sizeText(File file) {
    final int bytes;
    try {
      bytes = file.lengthSync();
    } on FileSystemException {
      // ملفٌّ نُقل أو حُذف بعد إرساله — البطاقة تُرسم بنوعها وحده.
      return null;
    }
    if (bytes < 1024) return '$bytes B';
    final double kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }

  /// مدّةٌ بالثواني مكتوبةً `00:12`، وفارغةٌ إن لم يعرفها الخادم.
  ///
  /// حبّة المدّة في بطاقة الفيديو تختفي حين تعود فارغة، فلا تُرسم حبّةٌ
  /// خاوية بانتظار رقمٍ قد لا يأتي.
  static String clockOf(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// وقت الرسالة كما يعرضه التصميم: `12:56`.
  static String timeOf(DateTime? createdAt) {
    if (createdAt == null) return '';
    return DateFormat('HH:mm').format(createdAt.toLocal());
  }

  /// الفجوة فوق رسالةٍ بالنظر إلى سابقتها.
  ///
  /// تغليفٌ لـ[ChatDesign.gapAbove] يقرأ القاعدة من رسالتين بدل أعلامٍ
  /// ستّة، فلا يُعيد كلُّ موضعٍ حسابها بنفسه.
  static double gapBetween({
    required Message? previous,
    required Message current,
    required int? myChatId,
  }) {
    if (previous == null) {
      return ChatDesign.gapAbove(
        isFirst: true,
        isDayPill: false,
        afterDayPill: false,
        isNote: false,
        isSameSide: false,
        bothText: false,
      );
    }
    final bool bothText =
        previous.messageType?.name == 'TextMessage' &&
        current.messageType?.name == 'TextMessage';
    return ChatDesign.gapAbove(
      isFirst: false,
      isDayPill: current.isDateMessage ?? false,
      afterDayPill: previous.isDateMessage ?? false,
      isNote: false,
      isSameSide: previous.senderUserId == current.senderUserId,
      bothText: bothText,
    );
  }

  /// يبني فقاعةً نصّية من رسالة.
  static Widget textBubble({
    required Message message,
    required bool isMine,
    required MessageStatus? status,
  }) {
    return ChatBubbleV2(
      text: message.messageContent?.content?.toString() ?? '',
      time: timeOf(message.createdAt),
      isMine: isMine,
      status: statusOf(isMine: isMine, status: status),
      isEdited: message.isEdited == 1,
      isForwarded: message.isForward == 1,
      editedLabel: LocaleKeys.edit.tr(),
      forwardedLabel: LocaleKeys.forward.tr(),
    );
  }
}
