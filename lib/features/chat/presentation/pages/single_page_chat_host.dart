/// مُضيفُ شاشة المحادثة: يختار نسختَها بحسب مفتاح التصميم.
///
/// > شاشةُ المحادثة هي الشاشةُ الوحيدةُ التي أُعيد تصميمُها **في موضعها**،
/// > فلم يبقَ فيها فرعٌ قديمٌ كامل. فنسختُها القديمةُ أُخرجت من التاريخ
/// > (`11a612ac`) إلى [single_page_chat_v1.dart] كما هي، حرفاً بحرف، ولم
/// > تحتج تعديلَ سطرٍ واحدٍ لتُترجَم.
/// >
/// > وبانيا الصنفين مطابقان تماماً، فالاختيارُ تعبيرٌ واحد. ويُجمَع هنا لا
/// > في مواضع النداء الثلاثة، فيبقى للتصميمين بابٌ واحد.
library;

import 'package:flutter/material.dart';

import 'package:trydos/main.dart' show kDesignV2;

import 'single_page_chat.dart';
import 'single_page_chat_v1.dart' as v1;

/// شاشةُ المحادثة بالتصميم المُشغَّل — وسائطُها وسائطُ الصنف نفسِها.
Widget singlePageChat({
  Key? key,
  int? dataLength,
  required String chatId,
  required String receiverName,
  required String receiverPhone,
  required String fullReceiverName,
  required String senderName,
  bool? fromSearch = false,
  String? fromOrder = 'false',
  String? senderPhoto,
  String? receiverPhoto,
}) {
  return kDesignV2
      ? SinglePageChat(
          key: key,
          dataLength: dataLength,
          chatId: chatId,
          receiverName: receiverName,
          receiverPhone: receiverPhone,
          fullReceiverName: fullReceiverName,
          senderName: senderName,
          fromSearch: fromSearch,
          fromOrder: fromOrder,
          senderPhoto: senderPhoto,
          receiverPhoto: receiverPhoto,
        )
      : v1.SinglePageChat(
          key: key,
          dataLength: dataLength,
          chatId: chatId,
          receiverName: receiverName,
          receiverPhone: receiverPhone,
          fullReceiverName: fullReceiverName,
          senderName: senderName,
          fromSearch: fromSearch,
          fromOrder: fromOrder,
          senderPhoto: senderPhoto,
          receiverPhoto: receiverPhoto,
        );
}

/// هل هذا الودجتُ شاشةَ محادثةٍ، بأيِّ التصميمين؟
///
/// تسأله شاشةُ المكالمة داخل التطبيق لتعرف أنّها فوق محادثةٍ مفتوحة — ولو
/// سألت عن صنفٍ واحدٍ لأخطأت في النسخة الأخرى.
bool isSinglePageChat(Widget widget) =>
    widget is SinglePageChat || widget is v1.SinglePageChat;
