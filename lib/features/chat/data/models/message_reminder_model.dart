import 'dart:convert' as convert;

/// تذكير على رسالة. شخصي للمستخدم الحالي — لا يراه بقية أعضاء القناة.
class MessageReminderInfo {
  final String id;
  final DateTime? remindAt;
  final DateTime? createdAt;

  const MessageReminderInfo({required this.id, this.remindAt, this.createdAt});

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory MessageReminderInfo.fromJson(Map<String, dynamic> json) =>
      MessageReminderInfo(
        id: json["id"].toString(),
        remindAt: _date(json["remind_at"]),
        createdAt: _date(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "remind_at": remindAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };

  /// التذكير محفوظ داخل حالة `hydrated_bloc`، والرسائل المخزَّنة قبل هذه
  /// الميزة لا تحويه. أي شكل غير متوقّع يُقرأ كـ «بلا تذكير» بدل أن يرمي.
  static MessageReminderInfo? tryFromJson(dynamic value) {
    if (value is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(value);
    if (json["id"] == null) return null;
    return MessageReminderInfo.fromJson(json);
  }
}

/// مُرسِل الرسالة كما يصل داخل قائمة التذكيرات — حقول عرض فقط.
class ReminderMessageSender {
  final int? id;
  final String? name;
  final String? photoPath;

  const ReminderMessageSender({this.id, this.name, this.photoPath});

  factory ReminderMessageSender.fromJson(Map<String, dynamic> json) =>
      ReminderMessageSender(
        id: int.tryParse(json["id"].toString()),
        name: json["name"]?.toString(),
        photoPath: json["photo_path"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "photo_path": photoPath,
  };
}

/// لمحة عن الرسالة المرتبطة بالتذكير. ليست `Message` كاملة — الخادم يرسل
/// الحقول اللازمة للعرض فقط.
class ReminderMessagePreview {
  final String? id;
  final String? channelId;
  final String? messageType;
  final String? content;
  final ReminderMessageSender? senderUser;
  final DateTime? createdAt;

  const ReminderMessagePreview({
    this.id,
    this.channelId,
    this.messageType,
    this.content,
    this.senderUser,
    this.createdAt,
  });

  factory ReminderMessagePreview.fromJson(Map<String, dynamic> json) =>
      ReminderMessagePreview(
        id: json["id"]?.toString(),
        channelId: json["channel_id"]?.toString(),
        messageType: json["message_type"]?.toString(),
        content: json["content"]?.toString(),
        senderUser: json["sender_user"] is Map
            ? ReminderMessageSender.fromJson(
                Map<String, dynamic>.from(json["sender_user"]),
              )
            : null,
        createdAt: MessageReminderInfo._date(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "channel_id": channelId,
    "message_type": messageType,
    "content": content,
    "sender_user": senderUser?.toJson(),
    "created_at": createdAt?.toIso8601String(),
  };
}

/// عنصر واحد في قائمة «تذكيراتي»: التذكير + الرسالة التي يشير إليها.
class MessageReminderItem {
  final MessageReminderInfo reminder;
  final String messageId;
  final ReminderMessagePreview? message;

  const MessageReminderItem({
    required this.reminder,
    required this.messageId,
    this.message,
  });

  factory MessageReminderItem.fromJson(Map<String, dynamic> json) =>
      MessageReminderItem(
        // حقول التذكير مسطّحة في نفس الكائن، لا داخل مفتاح فرعي.
        reminder: MessageReminderInfo.fromJson(json),
        messageId: json["message_id"].toString(),
        message: json["message"] is Map
            ? ReminderMessagePreview.fromJson(
                Map<String, dynamic>.from(json["message"]),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
    ...reminder.toJson(),
    "message_id": messageId,
    "message": message?.toJson(),
  };

  static List<MessageReminderItem> listFromJson(dynamic value) {
    if (value is String) return listFromJson(convert.jsonDecode(value));
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => MessageReminderItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
